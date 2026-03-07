import 'dart:io';
import 'dart:typed_data';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/update_download_result.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// CancelToken
// ---------------------------------------------------------------------------

/// A simple cooperative cancellation token for [UpdateDownloadService].
///
/// Pass an instance to [UpdateDownloadService.download] and call [cancel] at
/// any time to request early termination.  The download loop checks
/// [isCancelled] after each received chunk.
class CancelToken {
  bool _isCancelled = false;

  /// Signals that the download should stop at the next chunk boundary.
  void cancel() => _isCancelled = true;

  /// Whether [cancel] has been called.
  bool get isCancelled => _isCancelled;
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
      // GNU coreutils df: report available bytes in 1-byte units.
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
      // BSD df: report in 512-byte blocks; -k switches to kilobytes.
      final result = await Process.run('df', ['-k', directoryPath]);
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).trim().split('\n');
        if (lines.length >= 2) {
          final cols = lines.last.trim().split(RegExp(r'\s+'));
          // macOS df columns: Filesystem / 1K-blocks / Used / Avail / ...
          if (cols.length >= 4) {
            final kb = int.tryParse(cols[3]);
            if (kb != null) return kb * 1024;
          }
        }
      }
    } else if (Platform.isWindows) {
      // Use "fsutil volume diskfree <drive_letter:>" on Windows.
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
/// files.
///
/// ## Platform support
/// The service resolves the download URL from [UpdateManifest.platforms] using
/// the current runtime platform.  It returns
/// [UpdateErrorType.unsupportedPlatform] when no URL is available (e.g. web).
///
/// ## Checksum verification (UPDATE-006)
/// SHA-256 of the downloaded installer is computed and compared against
/// [PlatformAsset.sha256].  A mismatch deletes the partial file and returns
/// [UpdateErrorType.checksumMismatch].
///
/// ## Usage
/// ```dart
/// final result = await UpdateDownloadService().download(
///   manifest: manifest,
///   destDir: await getTemporaryDirectory(),
/// );
/// if (result.isSuccess) {
///   // launch the installer at result.filePath!
/// }
/// ```
class UpdateDownloadService {
  UpdateDownloadService({
    http.Client? client,
    FreeSpaceResolver? freeSpaceResolver,
  }) : _client = client ?? http.Client(),
       _freeSpaceResolver = freeSpaceResolver ?? defaultFreeSpaceResolver;

  final http.Client _client;
  final FreeSpaceResolver _freeSpaceResolver;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Downloads the installer described by [manifest] and saves it in [destDir].
  ///
  /// ### Progress reporting
  /// When [onProgress] is provided, it is called after each received chunk
  /// with a value between `0.0` and `1.0` representing the fraction downloaded.
  /// Progress is only emitted when the server includes a non-zero
  /// `Content-Length` header; otherwise [onProgress] is never called.
  ///
  /// ### Cancellation
  /// Pass a [CancelToken] and call [CancelToken.cancel] to abort the stream
  /// at the next chunk boundary.  The partial file is deleted and
  /// [UpdateErrorType.downloadCancelled] is returned.
  ///
  /// ### SHA-256 verification (UPDATE-006)
  /// After all bytes are received, the SHA-256 checksum is computed and
  /// compared against [PlatformAsset.sha256].  A mismatch deletes the file
  /// and returns [UpdateErrorType.checksumMismatch].
  ///
  /// Returns [UpdateDownloadResult.success] with the saved file path on
  /// success, or [UpdateDownloadResult.failure] on any error.
  ///
  /// Partial files are **always** deleted before returning a failure.
  Future<UpdateDownloadResult> download({
    required UpdateManifest manifest,
    required Directory destDir,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // Resolve the platform-appropriate download asset from the manifest.
    final asset = _resolvePlatformAsset(manifest);
    if (asset == null) {
      return UpdateDownloadResult.failure(
        'No installer is available for the current platform.',
        errorType: UpdateErrorType.unsupportedPlatform,
      );
    }

    final filename = asset.downloadUrl.split('/').last;
    final file = File('${destDir.path}/$filename');

    try {
      // Security: validate HTTPS before issuing the request.
      UpdateUrlValidator.validateHttpsUrl(asset.downloadUrl);

      // Pre-download disk space check (UPDATE-010).
      // Fail-open: skipped whenever Content-Length is unavailable, zero, or
      // the free-space query fails.
      // NOTE: GitHub Releases download URLs typically resolve through CDN
      // redirects (HTTP 302).  _fetchContentLength returns null for any
      // non-200 status, so the check is silently skipped in that case.
      final uri = Uri.parse(asset.downloadUrl);
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

      // Stream the download so we can report progress and support cancellation.
      final request = http.Request('GET', uri);
      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        return UpdateDownloadResult.failure(
          'Server returned HTTP ${streamedResponse.statusCode} while '
          'downloading the installer.',
          errorType: UpdateErrorType.downloadError,
        );
      }

      final responseContentLength = streamedResponse.contentLength;
      final byteBuilder = BytesBuilder(copy: false);
      int received = 0;

      await for (final chunk in streamedResponse.stream) {
        // Cooperative cancellation: check token at each chunk boundary.
        if (cancelToken?.isCancelled == true) {
          await _deletePartial(file);
          return UpdateDownloadResult.failure(
            'Download cancelled by user.',
            errorType: UpdateErrorType.downloadCancelled,
          );
        }
        byteBuilder.add(chunk);
        received += chunk.length;
        if (responseContentLength != null && responseContentLength > 0) {
          onProgress?.call(received / responseContentLength);
        }
      }

      final bytes = byteBuilder.takeBytes();
      await file.writeAsBytes(bytes, flush: true);

      // SHA-256 checksum verification (UPDATE-006).
      final computed = _sha256Hex(bytes);
      if (computed != asset.sha256.toLowerCase()) {
        await _deletePartial(file);
        return UpdateDownloadResult.failure(
          'Checksum mismatch: expected ${asset.sha256}, got $computed. '
          'The downloaded file may be corrupted or tampered with. '
          'Please download a fresh copy from GitHub Releases.',
          errorType: UpdateErrorType.checksumMismatch,
        );
      }

      return UpdateDownloadResult.success(file.path);
    } on UpdateSecurityException catch (e) {
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        e.message,
        errorType: UpdateErrorType.securityError,
      );
    } catch (e) {
      // Always clean up the partial file before surfacing the failure.
      await _deletePartial(file);
      return UpdateDownloadResult.failure(
        '$e',
        errorType: UpdateErrorType.downloadError,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------------

  /// Issues a HEAD request to [url] and returns the `Content-Length` value in
  /// bytes, or `null` when the value is unavailable.
  ///
  /// Returns `null` when:
  /// - The response status is not 200 (including redirects — see note below).
  /// - The `Content-Length` header is absent or non-numeric.
  /// - The request throws for any reason.
  /// - The returned value is zero or negative (malformed response).
  ///
  /// **CDN redirect note:** GitHub Releases download URLs typically issue an
  /// HTTP 302 redirect to a CDN (e.g. objects.githubusercontent.com).  If the
  /// HTTP client does not follow the redirect for HEAD requests, this method
  /// will receive a 302 and return `null`, causing the disk-space check to be
  /// skipped (fail-open).  This is the expected behaviour: the download still
  /// proceeds and a partial-write failure is handled by the catch block.
  ///
  /// Failures are silently swallowed — this is a best-effort preflight that
  /// must never block a legitimate download.
  Future<int?> _fetchContentLength(Uri url) async {
    try {
      final response = await _client.head(url);
      if (response.statusCode == 200) {
        final parsed = int.tryParse(response.headers['content-length'] ?? '');
        // Guard against zero / negative — treat as unavailable.
        return (parsed != null && parsed > 0) ? parsed : null;
      }
    } catch (_) {
      // Best-effort — HEAD not supported or network error; skip the check.
    }
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

  /// Returns the [PlatformAsset] for the current runtime platform, or `null`
  /// if no matching asset is present in the manifest (e.g. running on web).
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
    } catch (_) {
      // Platform API unavailable (e.g. in certain test environments).
    }
    return null;
  }

  /// Computes the SHA-256 checksum of [bytes] and returns it as a lowercase
  /// 64-character hex string.
  static String _sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();

  /// Silently deletes [file] if it exists — best-effort partial-file cleanup.
  Future<void> _deletePartial(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best-effort — never propagate a cleanup failure.
    }
  }
}
