import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/update_download_result.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
/// SHA-256 verification against [PlatformAsset.sha256] is stubbed out in this
/// skeleton.  Full implementation is provided by UPDATE-006.
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
  /// Returns [UpdateDownloadResult.success] with the saved file path on
  /// success, or [UpdateDownloadResult.failure] on any error.
  ///
  /// Partial files are **always** deleted before returning a failure.
  Future<UpdateDownloadResult> download({
    required UpdateManifest manifest,
    required Directory destDir,
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
      // Fail-open: skipped whenever Content-Length or free space is unknown.
      final uri = Uri.parse(asset.downloadUrl);
      final contentLength = await _fetchContentLength(uri);
      if (contentLength != null) {
        final freeBytes = await _freeSpaceResolver(destDir.path);
        if (freeBytes != null && freeBytes < contentLength) {
          return UpdateDownloadResult.failure(
            'Not enough disk space to download the installer. '
            '${formatBytes(contentLength)} required, '
            '${formatBytes(freeBytes)} available. '
            'Free up disk space and try again.',
            errorType: UpdateErrorType.downloadError,
          );
        }
      }

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return UpdateDownloadResult.failure(
          'Server returned HTTP ${response.statusCode} while downloading the '
          'installer.',
          errorType: UpdateErrorType.downloadError,
        );
      }

      await file.writeAsBytes(response.bodyBytes, flush: true);

      // TODO(UPDATE-006): Verify SHA-256 checksum.
      // final computed = sha256OfBytes(response.bodyBytes).toHex();
      // if (computed != asset.sha256) {
      //   await _deletePartial(file);
      //   return UpdateDownloadResult.failure(
      //     'Checksum mismatch: expected ${asset.sha256}, got $computed.',
      //     errorType: UpdateErrorType.checksumMismatch,
      //   );
      // }

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

  /// Issues a HEAD request to [url] and returns the `Content-Length` value,
  /// or `null` if the header is absent, non-numeric, or the request fails.
  ///
  /// Failures are silently swallowed — this is a best-effort preflight that
  /// must never block a legitimate download.
  Future<int?> _fetchContentLength(Uri url) async {
    try {
      final response = await _client.head(url);
      if (response.statusCode == 200) {
        return int.tryParse(response.headers['content-length'] ?? '');
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

  /// Silently deletes [file] if it exists — best-effort partial-file cleanup.
  Future<void> _deletePartial(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best-effort — never propagate a cleanup failure.
    }
  }
}
