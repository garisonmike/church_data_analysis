import 'dart:io';
import 'dart:typed_data';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/download_state_service.dart';
import 'package:church_analytics/services/update_download_result.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// CancelToken
// ---------------------------------------------------------------------------

/// A simple cooperative cancellation token for [UpdateDownloadService].
///
/// Pass an instance to [UpdateDownloadService.download] or
/// [UpdateDownloadService.resume] and call [cancel] at any time to request
/// early termination.  The download loop checks [isCancelled] after each
/// received chunk.
class CancelToken {
  bool _isCancelled = false;

  /// Signals that the download should stop at the next chunk boundary.
  void cancel() => _isCancelled = true;

  /// Whether [cancel] has been called.
  bool get isCancelled => _isCancelled;
}

// ---------------------------------------------------------------------------
// PauseToken (FEAT-006)
// ---------------------------------------------------------------------------

/// A cooperative pause token for [UpdateDownloadService] (FEAT-006).
///
/// Pass an instance to [UpdateDownloadService.download] or
/// [UpdateDownloadService.resume] and call [pause] at any time to request
/// that the download stop at the next chunk boundary and save its progress.
///
/// When the download loop sees [isPaused] is `true` it flushes the file sink,
/// closes it, and returns [UpdateDownloadResult.paused] with the partial file
/// path and byte count.  The partial file remains on disk so that
/// [UpdateDownloadService.resume] can pick up from where it left off.
///
/// Calling [resume] on a token that has not been paused is a no-op.
///
/// ```dart
/// final pauseToken = PauseToken();
///
/// // In the download callback:
/// pauseToken.pause();  // download will stop at the next chunk
///
/// // Later, to continue:
/// final result = await service.resume(
///   manifest: manifest,
///   partialFilePath: pausedResult.partialFilePath!,
///   pauseToken: PauseToken(), // fresh token for the resumed segment
/// );
/// ```
class PauseToken {
  bool _isPaused = false;

  /// Signals that the download should pause at the next chunk boundary.
  void pause() => _isPaused = true;

  /// Clears a previous [pause] call.
  ///
  /// Only useful if the pause was set before the download loop had a chance to
  /// observe it (i.e. within the same chunk window).  Once the download loop
  /// has returned [UpdateDownloadResult.paused], this token is no longer
  /// observed and a new download call with a fresh [PauseToken] is needed.
  void resume() => _isPaused = false;

  /// Whether [pause] has been called and not subsequently cancelled by [resume].
  bool get isPaused => _isPaused;
}

// ---------------------------------------------------------------------------
// FreeSpaceResolver typedef
// ---------------------------------------------------------------------------

/// Returns the number of free bytes available in the filesystem that contains
/// [directoryPath], or `null` when the information is unavailable.
///
/// Injectable for testing; use [defaultFreeSpaceResolver] in production.
typedef FreeSpaceResolver = Future<int?> Function(String directoryPath);

/// Production [FreeSpaceResolver] that queries the OS for available disk space.
///
/// Supports Linux, Android (via `df -B1 --output=avail`), macOS (via `df -k`),
/// and Windows (via `fsutil volume diskfree`).  Returns `null` on web and on
/// any platform where the query fails (fail-open — never blocks a download
/// unnecessarily).
Future<int?> defaultFreeSpaceResolver(String directoryPath) async {
  if (kIsWeb) return null;
  try {
    if (Platform.isLinux || Platform.isAndroid) {
      final result = await Process.run('df', [
        '-B1',
        '--output=avail',
        directoryPath,
      ]);
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).trim().split('\n');
        if (lines.length >= 2) return int.tryParse(lines.last.trim());
      }
    } else if (Platform.isMacOS) {
      final result = await Process.run('df', ['-k', directoryPath]);
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).trim().split('\n');
        if (lines.length >= 2) {
          final cols = lines.last.trim().split(RegExp(r'\s+'));
          if (cols.length >= 4) {
            final kb = int.tryParse(cols[3]);
            if (kb != null) return kb * 1024;
          }
        }
      }
    } else if (Platform.isWindows) {
      final drive = directoryPath.length >= 2
          ? directoryPath.substring(0, 2)
          : directoryPath;
      final result = await Process.run('fsutil', ['volume', 'diskfree', drive]);
      if (result.exitCode == 0) {
        final match = RegExp(
          r'Total free bytes\s*:\s*(\d+)',
        ).firstMatch(result.stdout as String);
        if (match != null) return int.tryParse(match.group(1)!);
      }
    }
  } catch (_) {
    // Swallow all errors — free-space check is best-effort.
  }
  return null;
}

// ---------------------------------------------------------------------------
// UpdateDownloadService
// ---------------------------------------------------------------------------

/// Downloads the installer file described by an [UpdateManifest].
///
/// ## Streaming to disk (FEAT-006)
/// Each received chunk is written directly to the destination file via an
/// [IOSink].  This avoids holding the entire installer in RAM during the
/// download (previously a [BytesBuilder] was used).  The SHA-256 checksum is
/// verified by streaming the completed file from disk after all chunks arrive.
///
/// ## Pause and resume (FEAT-006)
/// Pass a [PauseToken] to [download] or [resume].  When [PauseToken.pause] is
/// called, the chunk loop flushes and closes the file sink at the next chunk
/// boundary and returns [UpdateDownloadResult.paused] with the partial file
/// path and byte offset.  Call [resume] with that path to issue a
/// `Range: bytes=<offset>-` HTTP request and append the remaining bytes.
///
/// ## Pre-download disk space check (UPDATE-010)
/// Before issuing the full GET request, the service sends a HEAD request to
/// obtain the installer's `Content-Length`.  When both the content length and
/// the available disk space in [destDir]'s filesystem are determinable, and
/// available space is less than the required size, the download is aborted
/// immediately with a clear, actionable error message.
///
/// The check is **fail-open**: if either value cannot be determined (HEAD not
/// supported, `Content-Length` absent, or free-space query fails), the
/// download proceeds without restriction.
///
/// ## Error handling & partial-file cleanup
/// Any failure — HTTP error, network exception, or checksum mismatch — deletes
/// the partial destination file before returning an
/// [UpdateDownloadResult.failure].  Callers never have to clean up leftover
/// files on error.  A [UpdateDownloadResult.paused] result intentionally
/// retains the partial file.
///
/// ## Checksum verification (UPDATE-006)
/// SHA-256 of the completed file is streamed from disk and compared against
/// [PlatformAsset.sha256].  A mismatch deletes the file and returns
/// [UpdateErrorType.checksumMismatch].
class UpdateDownloadService {
  UpdateDownloadService({
    http.Client? client,
    FreeSpaceResolver? freeSpaceResolver,
  }) : _client = client ?? http.Client(),
       _freeSpaceResolver = freeSpaceResolver ?? defaultFreeSpaceResolver;

  final http.Client _client;
  final FreeSpaceResolver _freeSpaceResolver;

  // -------------------------------------------------------------------------
  // Public API — URL resolution
  // -------------------------------------------------------------------------

  /// Returns the download URL for the current platform's installer asset from
  /// [manifest], or `null` when the platform is unsupported or running on web.
  ///
  /// Used by [AboutUpdatesCard] to issue an Accept-Ranges HEAD request before
  /// showing the Pause button, without duplicating the platform-resolution
  /// logic.
  String? resolveDownloadUrl(UpdateManifest manifest) {
    final asset = _resolvePlatformAsset(manifest);
    return asset?.downloadUrl;
  }

  // -------------------------------------------------------------------------
  // Public API — initial download
  // -------------------------------------------------------------------------

  /// Downloads the installer described by [manifest] and saves it in [destDir].
  ///
  /// ### Progress reporting
  /// When [onProgress] is provided, it is called after each chunk with a value
  /// between `0.0` and `1.0`.  Progress is only emitted when the server
  /// includes a non-zero `Content-Length` header.
  ///
  /// ### Cancellation
  /// Pass a [CancelToken] and call [CancelToken.cancel] to abort at the next
  /// chunk boundary.  The partial file is deleted and
  /// [UpdateErrorType.downloadCancelled] is returned.
  ///
  /// ### Pause (FEAT-006)
  /// Pass a [PauseToken] and call [PauseToken.pause] to suspend the download
  /// at the next chunk boundary.  The partial file is **kept** on disk and
  /// [UpdateDownloadResult.paused] is returned with its path and byte count.
  /// Call [resume] to continue from that offset.
  ///
  /// ### SHA-256 verification (UPDATE-006)
  /// After all bytes arrive the checksum is computed by streaming the file from
  /// disk.  A mismatch deletes the file and returns
  /// [UpdateErrorType.checksumMismatch].
  Future<UpdateDownloadResult> download({
    required UpdateManifest manifest,
    required Directory destDir,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
    PauseToken? pauseToken,
  }) async {
    final asset = _resolvePlatformAsset(manifest);
    if (asset == null) {
      return UpdateDownloadResult.failure(
        'No installer is available for the current platform.',
        errorType: UpdateErrorType.unsupportedPlatform,
      );
    }

    final filename = asset.downloadUrl.split('/').last;
    final file = File('${destDir.path}/$filename');

    // FEAT-005: if the file already exists verify its SHA-256 before
    // issuing any network request.
    //   Match    → skip the download, return success immediately.
    //   Mismatch → stale/corrupt file; delete and start fresh.
    if (await file.exists()) {
      try {
        final existingHash = await _sha256HexOfFile(file);
        if (existingHash == asset.sha256.toLowerCase()) {
          onProgress?.call(1.0);
          return UpdateDownloadResult.success(file.path);
        }
        await _deletePartial(file);
      } catch (_) {
        await _deletePartial(file);
      }
    }

    try {
      UpdateUrlValidator.validateHttpsUrl(asset.downloadUrl);

      final uri = Uri.parse(asset.downloadUrl);

      // Pre-download disk-space check (UPDATE-010, fail-open).
      final contentLength = await _fetchContentLength(uri);
      if (contentLength != null && contentLength > 0) {
        final freeBytes = await _freeSpaceResolver(destDir.path);
        if (freeBytes != null && freeBytes < contentLength) {
          return UpdateDownloadResult.failure(
            'Not enough disk space to download the installer. '
            '${formatBytes(contentLength)} required, '
            '${formatBytes(freeBytes)} available. '
            'Free up disk space and try again.',
            errorType: UpdateErrorType.insufficientDiskSpace,
          );
        }
      }

      final request = http.Request('GET', uri);
      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        return UpdateDownloadResult.failure(
          'Server returned HTTP ${streamedResponse.statusCode} while '
          'downloading the installer.',
          errorType: UpdateErrorType.downloadError,
        );
      }

      // Stream chunks directly to disk (FEAT-006: no BytesBuilder in RAM).
      // FEAT-007: persist download state so an interrupted download is
      // detectable on the next app launch via StartupGateScreen.
      await DownloadStateService.persist(
        url: asset.downloadUrl,
        destPath: file.path,
        sha256: asset.sha256,
      );

      final result = await _streamToDisk(
        file: file,
        stream: streamedResponse.stream,
        totalBytes: streamedResponse.contentLength,
        startOffset: 0,
        expectedSha256: asset.sha256,
        onProgress: onProgress,
        cancelToken: cancelToken,
        pauseToken: pauseToken,
        mode: FileMode.write,
      );

      // FEAT-007: clear the state record for any terminal result.
      // A paused result keeps the record so the partial file is discoverable
      // on the next launch.
      if (!result.isPaused) await DownloadStateService.clear();
      return result;
    } on UpdateSecurityException catch (e) {
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        e.message,
        errorType: UpdateErrorType.securityError,
      );
    } catch (e) {
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        '$e',
        errorType: UpdateErrorType.downloadError,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Public API — resume (FEAT-006)
  // -------------------------------------------------------------------------

  /// Resumes a previously paused download by issuing a `Range: bytes=N-`
  /// HTTP request and appending the remaining bytes to [partialFilePath]
  /// (FEAT-006).
  ///
  /// ### When to call
  /// Call this after [download] (or a previous [resume]) returns
  /// [UpdateDownloadResult.paused].  Pass the [partialFilePath] from that
  /// result.
  ///
  /// ### Range request
  /// The `Range` header is set to `bytes=<file_length>-`.  The server must
  /// respond with **206 Partial Content**; a 200 response (server does not
  /// support range requests) causes a failure so the caller can fall back to
  /// a fresh [download].
  ///
  /// ### Progress reporting
  /// [onProgress] reports the overall fraction including already-downloaded
  /// bytes.  If the server omits `Content-Range` / `Content-Length` in the
  /// 206 response, progress is not emitted for the resumed segment.
  ///
  /// ### Fallback
  /// If [partialFilePath] does not exist on disk (e.g. it was cleaned up by
  /// the OS), this method falls back to a full [download] automatically.
  Future<UpdateDownloadResult> resume({
    required UpdateManifest manifest,
    required String partialFilePath,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
    PauseToken? pauseToken,
  }) async {
    final asset = _resolvePlatformAsset(manifest);
    if (asset == null) {
      return UpdateDownloadResult.failure(
        'No installer is available for the current platform.',
        errorType: UpdateErrorType.unsupportedPlatform,
      );
    }

    final file = File(partialFilePath);

    // Fallback: if the partial file is gone (OS cleaned it up) restart fresh.
    if (!await file.exists()) {
      return download(
        manifest: manifest,
        destDir: file.parent,
        onProgress: onProgress,
        cancelToken: cancelToken,
        pauseToken: pauseToken,
      );
    }

    final startOffset = await file.length();

    // If the file is already complete (rare: paused right at the last byte)
    // verify the checksum and return success.
    if (startOffset > 0) {
      try {
        final existingHash = await _sha256HexOfFile(file);
        if (existingHash == asset.sha256.toLowerCase()) {
          onProgress?.call(1.0);
          return UpdateDownloadResult.success(file.path);
        }
      } catch (_) {
        // Unreadable — fall through to the range request.
      }
    }

    try {
      UpdateUrlValidator.validateHttpsUrl(asset.downloadUrl);

      final uri = Uri.parse(asset.downloadUrl);
      final request = http.Request('GET', uri);
      request.headers['Range'] = 'bytes=$startOffset-';

      final streamedResponse = await _client.send(request);

      // 206 = server honours the Range request.
      // 416 = Range Not Satisfiable (file already complete on server side).
      if (streamedResponse.statusCode == 416) {
        // We requested a range past the end — the file may actually be
        // complete already.  Re-verify the checksum and return success if
        // it passes; otherwise delete and report an error.
        final computed = await _sha256HexOfFile(file);
        if (computed == asset.sha256.toLowerCase()) {
          onProgress?.call(1.0);
          return UpdateDownloadResult.success(file.path);
        }
        await _deletePartial(file);
        return UpdateDownloadResult.failure(
          'The partial file appears corrupt (Range Not Satisfiable and '
          'checksum mismatch). Please download again.',
          errorType: UpdateErrorType.checksumMismatch,
        );
      }

      if (streamedResponse.statusCode != 206) {
        // Server returned 200 (no range support) or an error.
        // Delete the partial file so the caller can restart cleanly.
        await _deletePartial(file);
        return UpdateDownloadResult.failure(
          'The server does not support resumable downloads '
          '(HTTP ${streamedResponse.statusCode}). '
          'Please tap "Download Update" to start again.',
          errorType: UpdateErrorType.downloadError,
        );
      }

      // For progress, total = bytes already on disk + bytes remaining in 206.
      final remainingLength = streamedResponse.contentLength;
      final totalBytes =
          remainingLength != null ? startOffset + remainingLength : null;

      final result = await _streamToDisk(
        file: file,
        stream: streamedResponse.stream,
        totalBytes: totalBytes,
        startOffset: startOffset,
        expectedSha256: asset.sha256,
        onProgress: onProgress,
        cancelToken: cancelToken,
        pauseToken: pauseToken,
        mode: FileMode.append,
      );

      // FEAT-007: clear the state record for any terminal result.
      if (!result.isPaused) await DownloadStateService.clear();
      return result;
    } on UpdateSecurityException catch (e) {
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        e.message,
        errorType: UpdateErrorType.securityError,
      );
    } catch (e) {
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        '$e',
        errorType: UpdateErrorType.downloadError,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Public API — resumeFile (FEAT-007)
  // -------------------------------------------------------------------------

  /// Resumes an interrupted download using raw values from [DownloadStateRecord],
  /// without requiring a full [UpdateManifest].
  ///
  /// This overload is used by [StartupGateScreen] on launch: when a partial
  /// download is detected in [SharedPreferences], the startup screen has the
  /// URL, dest path, and SHA-256 from the persisted record but does not have
  /// access to a live manifest (the manifest is fetched by [AboutUpdatesCard]
  /// on demand, not stored on disk).
  ///
  /// Behaviour is identical to [resume] except that:
  /// - The asset URL and checksum are supplied directly.
  /// - No manifest platform lookup is performed.
  /// - If [partialFilePath] does not exist, the download state record is cleared
  ///   and [UpdateErrorType.downloadError] is returned (callers should offer a
  ///   fresh download from [AboutUpdatesCard]).
  ///
  /// [DownloadStateService.clear] is called for all terminal results (success,
  /// error, cancel).  A paused result keeps the record so the next launch can
  /// detect it again.
  Future<UpdateDownloadResult> resumeFile({
    required String downloadUrl,
    required String partialFilePath,
    required String expectedSha256,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
    PauseToken? pauseToken,
  }) async {
    final file = File(partialFilePath);

    if (!await file.exists()) {
      await DownloadStateService.clear();
      return UpdateDownloadResult.failure(
        'The partial download file no longer exists on disk. '
        'Please download the update again from Settings → Updates.',
        errorType: UpdateErrorType.downloadError,
      );
    }

    final startOffset = await file.length();

    // Fast-path: file may already be complete (e.g. download finished but
    // installer was never launched before the app closed).
    if (startOffset > 0) {
      try {
        final existingHash = await _sha256HexOfFile(file);
        if (existingHash == expectedSha256.toLowerCase()) {
          await DownloadStateService.clear();
          onProgress?.call(1.0);
          return UpdateDownloadResult.success(file.path);
        }
      } catch (_) {
        // Unreadable partial file — fall through to the range request.
      }
    }

    try {
      UpdateUrlValidator.validateHttpsUrl(downloadUrl);

      final uri = Uri.parse(downloadUrl);
      final request = http.Request('GET', uri);
      request.headers['Range'] = 'bytes=$startOffset-';

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode == 416) {
        // Range Not Satisfiable — attempt checksum anyway.
        final computed = await _sha256HexOfFile(file);
        if (computed == expectedSha256.toLowerCase()) {
          await DownloadStateService.clear();
          onProgress?.call(1.0);
          return UpdateDownloadResult.success(file.path);
        }
        await _deletePartial(file);
        await DownloadStateService.clear();
        return UpdateDownloadResult.failure(
          'The partial file appears corrupt. Please download the update again.',
          errorType: UpdateErrorType.checksumMismatch,
        );
      }

      if (streamedResponse.statusCode != 206) {
        await _deletePartial(file);
        await DownloadStateService.clear();
        return UpdateDownloadResult.failure(
          'The server does not support resumable downloads '
          '(HTTP ${streamedResponse.statusCode}). '
          'Please download the update again from Settings → Updates.',
          errorType: UpdateErrorType.downloadError,
        );
      }

      final remainingLength = streamedResponse.contentLength;
      final totalBytes =
          remainingLength != null ? startOffset + remainingLength : null;

      final result = await _streamToDisk(
        file: file,
        stream: streamedResponse.stream,
        totalBytes: totalBytes,
        startOffset: startOffset,
        expectedSha256: expectedSha256,
        onProgress: onProgress,
        cancelToken: cancelToken,
        pauseToken: pauseToken,
        mode: FileMode.append,
        keepOnCancel: true, // FEAT-007: cancel in crash-resume context keeps the file
      );

      if (!result.isPaused && !result.isCancelledResumable) await DownloadStateService.clear();
      return result;
    } on UpdateSecurityException catch (e) {
      await _deletePartial(file);
      await DownloadStateService.clear();
      return UpdateDownloadResult.failure(
        e.message,
        errorType: UpdateErrorType.securityError,
      );
    } catch (e) {
      await _deletePartial(file);
      await DownloadStateService.clear();
      return UpdateDownloadResult.failure(
        '$e',
        errorType: UpdateErrorType.downloadError,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Core streaming helper (FEAT-006)
  // -------------------------------------------------------------------------

  /// Writes [stream] to [file] chunk by chunk, honouring [cancelToken] and
  /// [pauseToken] at each boundary.
  ///
  /// [startOffset] is the number of bytes already on disk before streaming
  /// begins — used to compute overall progress correctly when resuming.
  ///
  /// [totalBytes] is the grand total expected size of the completed file
  /// (startOffset + remaining).  When `null`, [onProgress] is not called.
  ///
  /// [mode] must be [FileMode.write] for a fresh download and
  /// [FileMode.append] for a resumed segment.
  ///
  /// When [keepOnCancel] is `true` the cancel path flushes and closes the
  /// sink but does **not** delete the partial file, returning
  /// [UpdateDownloadResult.cancelledResumable] instead.  This is used by the
  /// resume-from-crash flow so that the partial file survives a mid-resume
  /// cancel and can be offered again on the next launch.
  ///
  /// After the stream ends, SHA-256 of the full file is verified against
  /// [asset].  On checksum mismatch the file is deleted.  On pause or cancel
  /// the file is flushed first (paused keeps it; cancelled deletes it).
  Future<UpdateDownloadResult> _streamToDisk({
    required File file,
    required Stream<List<int>> stream,
    required int? totalBytes,
    required int startOffset,
    required String expectedSha256, // FEAT-007: raw digest instead of PlatformAsset
    required FileMode mode,
    bool keepOnCancel = false,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
    PauseToken? pauseToken,
  }) async {
    final sink = file.openWrite(mode: mode);
    int received = startOffset;

    try {
      await for (final chunk in stream) {
        // Cancellation: clean up and exit.
        if (cancelToken?.isCancelled == true) {
          await sink.flush();
          await sink.close();
          if (keepOnCancel) {
            // Resume-from-crash context: keep the partial file so the
            // StartupGateScreen can offer "Resume or Discard?" again on the
            // next launch.
            return UpdateDownloadResult.cancelledResumable(
              file.path,
              bytesReceived: received,
            );
          }
          await _deletePartial(file);
          return UpdateDownloadResult.failure(
            'Download cancelled by user.',
            errorType: UpdateErrorType.downloadCancelled,
          );
        }

        // Pause (FEAT-006): flush, keep partial file, return paused result.
        if (pauseToken?.isPaused == true) {
          await sink.flush();
          await sink.close();
          return UpdateDownloadResult.paused(
            file.path,
            bytesReceived: received,
          );
        }

        sink.add(chunk);
        received += chunk.length;
        if (totalBytes != null && totalBytes > 0) {
          onProgress?.call(received / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();
    } catch (e) {
      // Ensure the sink is closed even on unexpected stream errors.
      try {
        await sink.close();
      } catch (_) {}
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        'Stream error during download: $e',
        errorType: UpdateErrorType.downloadError,
      );
    }

    // SHA-256 checksum verification (UPDATE-006).
    // Computed by streaming the completed file from disk — no RAM spike.
    final computed = await _sha256HexOfFile(file);
    if (computed != expectedSha256.toLowerCase()) {
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        'Checksum mismatch: expected $expectedSha256, got $computed. '
        'The downloaded file may be corrupted or tampered with. '
        'Please download a fresh copy from GitHub Releases.',
        errorType: UpdateErrorType.checksumMismatch,
      );
    }

    return UpdateDownloadResult.success(file.path);
  }

  // -------------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------------

  /// Issues a HEAD request to [url] and returns the `Content-Length` value in
  /// bytes, or `null` when the value is unavailable.
  Future<int?> _fetchContentLength(Uri url) async {
    try {
      final response = await _client.head(url);
      if (response.statusCode == 200) {
        final parsed = int.tryParse(response.headers['content-length'] ?? '');
        return (parsed != null && parsed > 0) ? parsed : null;
      }
    } catch (_) {}
    return null;
  }

  /// Formats [bytes] as a human-readable size string (B, KB, MB, or GB).
  static String formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  /// Returns the [PlatformAsset] for the current runtime platform.
  PlatformAsset? _resolvePlatformAsset(UpdateManifest manifest) {
    if (kIsWeb) return null;
    final key = _currentPlatformKey();
    if (key == null) return null;
    return manifest.platforms[key];
  }

  /// Maps the current [Platform] to the manifest platform key.
  String? _currentPlatformKey() {
    try {
      if (Platform.isWindows) return 'windows';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isLinux) return 'linux';
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    } catch (_) {}
    return null;
  }

  /// Computes SHA-256 of [file] by streaming its contents from disk.
  ///
  /// Returns the lowercase 64-character hex digest.  Does not load the entire
  /// file into RAM.
  static Future<String> _sha256HexOfFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  /// Computes SHA-256 of [bytes].  Kept for test compatibility.
  // ignore: unused_element
  static String _sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();

  /// Silently deletes [file] if it exists — best-effort partial-file cleanup.
  Future<void> _deletePartial(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
