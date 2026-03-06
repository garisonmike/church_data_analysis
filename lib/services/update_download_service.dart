import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/update_download_result.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Downloads the installer file described by an [UpdateManifest].
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
  UpdateDownloadService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

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

      final response = await _client.get(Uri.parse(asset.downloadUrl));
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
        errorType: UpdateErrorType.downloadError,
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
