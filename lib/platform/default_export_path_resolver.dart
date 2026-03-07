import 'dart:io' show Directory, Platform;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:path_provider/path_provider.dart'
    show
        StorageDirectory,
        getApplicationDocumentsDirectory,
        getDownloadsDirectory,
        getExternalStorageDirectories;

// ---------------------------------------------------------------------------
// Typedefs for injectable path_provider functions
// ---------------------------------------------------------------------------

/// Returns the platform downloads directory, or `null` when unavailable.
///
/// Matches the signature of [getDownloadsDirectory] from the
/// `path_provider` package.
typedef GetDownloadsDirFn = Future<Directory?> Function();

/// Returns external-storage directories for the given [StorageDirectory] type.
///
/// Matches the signature of [getExternalStorageDirectories] from the
/// `path_provider` package.
typedef GetExternalStorageDirsFn =
    Future<List<Directory>?> Function(StorageDirectory type);

/// Returns the user-overridden export directory path, or `null` when no
/// override has been set.
///
/// Typically backed by [SettingsRepository.getDefaultExportPath].
typedef GetCustomPathFn = String? Function();

// ---------------------------------------------------------------------------
// DefaultExportPathResolver
// ---------------------------------------------------------------------------

/// Resolves the platform-appropriate default export directory for the app.
///
/// ## Platform behaviour
///
/// | Platform | Resolved path |
/// |----------|---------------|
/// | Android  | `<external Downloads>/ChurchAnalytics/` |
/// | Linux / Windows / macOS | `~/Downloads/ChurchAnalytics/` |
/// | iOS      | `<app documents>/ChurchAnalytics/` |
/// | Web      | `null` — blob download; no filesystem path exists |
///
/// The directory is **created automatically** if it does not already exist,
/// before the path is returned.
///
/// ## Testability
///
/// Inject [getDownloads] and/or [getExternalDirs] to avoid real
/// `path_provider` channel calls in unit tests:
///
/// ```dart
/// final resolver = DefaultExportPathResolver(
///   getDownloads: () async => Directory('/tmp/test_downloads'),
/// );
/// final dir = await resolver.resolve();
/// expect(dir, '/tmp/test_downloads/ChurchAnalytics');
/// ```
class DefaultExportPathResolver {
  /// The subfolder name appended to the platform downloads directory to
  /// produce the final export directory path.
  static const String appFolderName = 'ChurchAnalytics';

  final GetDownloadsDirFn? _getDownloads;
  final GetExternalStorageDirsFn? _getExternalDirs;
  final GetCustomPathFn? _getCustomPath;

  /// Creates a resolver with optional injectable overrides.
  ///
  /// [getCustomPath] — when provided and returns a non-null, non-empty path,
  /// that directory is used as the highest-priority export location (ahead of
  /// the platform default).  Typically backed by
  /// `SettingsRepository.getDefaultExportPath`.
  ///
  /// [getDownloads] — overrides [getDownloadsDirectory] on
  /// Linux/Windows/macOS.
  /// [getExternalDirs] — overrides [getExternalStorageDirectories] on
  /// Android.
  const DefaultExportPathResolver({
    GetCustomPathFn? getCustomPath,
    GetDownloadsDirFn? getDownloads,
    GetExternalStorageDirsFn? getExternalDirs,
  }) : _getCustomPath = getCustomPath,
       _getDownloads = getDownloads,
       _getExternalDirs = getExternalDirs;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Returns the absolute path to the default export directory.
  ///
  /// Returns `null` on Web (blob download — no filesystem path concept).
  ///
  /// On all native platforms the directory is created if it does not already
  /// exist.  On error (e.g. missing plugin channel in test environments) the
  /// method falls back to `<system temp>/exports` and still returns a
  /// non-null path.
  Future<String?> resolve() async {
    // Web uses an in-memory blob download — there is no filesystem path.
    if (kIsWeb) return null;

    try {
      return await _resolveNative();
    } catch (e) {
      // Fallback for unit-test environments and device contexts that lack
      // a working path_provider channel. Use the app documents directory, which
      // is always accessible on all platforms (unlike system temp on Android,
      // which maps to a private /data/user/... path that PathSafetyGuard rejects).
      try {
        final appDocs = await getApplicationDocumentsDirectory();
        final fallback = Directory('${appDocs.path}/$appFolderName');
        if (!await fallback.exists()) {
          await fallback.create(recursive: true);
        }
        if (kDebugMode) {
          debugPrint(
            '[DefaultExportPathResolver] path_provider unavailable — '
            'falling back to: ${fallback.path}',
          );
        }
        return fallback.path;
      } catch (_) {
        // Last-resort: system temp (only reached in pure-dart unit tests where
        // no platform channels are available at all).
        final fallback = Directory('${Directory.systemTemp.path}/exports');
        if (!await fallback.exists()) {
          await fallback.create(recursive: true);
        }
        if (kDebugMode) {
          debugPrint(
            '[DefaultExportPathResolver] all path_provider calls failed — '
            'last-resort fallback: ${fallback.path}',
          );
        }
        return fallback.path;
      }
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<String> _resolveNative() async {
    // Highest priority: user-overridden custom path.
    if (_getCustomPath != null) {
      final custom = _getCustomPath();
      if (custom != null && custom.isNotEmpty) {
        try {
          final customDir = Directory(custom);
          if (!await customDir.exists()) {
            await customDir.create(recursive: true);
          }
          if (kDebugMode) {
            debugPrint(
              '[DefaultExportPathResolver] using custom path: $custom',
            );
          }
          return custom;
        } catch (e) {
          // Custom path is inaccessible — fall through to platform default.
          if (kDebugMode) {
            debugPrint(
              '[DefaultExportPathResolver] custom path inaccessible '
              '($custom): $e — falling back to platform default.',
            );
          }
        }
      }
    }

    // Platform default: <downloads>/ChurchAnalytics/
    final baseDir = await _resolveBaseDir();
    final exportDir = Directory('${baseDir.path}/$appFolderName');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    if (kDebugMode) {
      debugPrint('[DefaultExportPathResolver] resolved: ${exportDir.path}');
    }
    return exportDir.path;
  }

  Future<Directory> _resolveBaseDir() async {
    if (Platform.isAndroid) {
      // Try the well-known public Downloads directory first. This path is
      // reliable across Android versions and OEMs without extra permissions.
      const publicDownloads = '/storage/emulated/0/Download';
      final publicDir = Directory(publicDownloads);
      if (await publicDir.exists()) return publicDir;

      // Fall back to the path_provider-reported external storage dirs.
      final fn = _getExternalDirs ?? getExternalStorageDirectories;
      final dirs = await fn(StorageDirectory.downloads);
      if (dirs != null && dirs.isNotEmpty) return dirs.first;
      return getApplicationDocumentsDirectory();
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final fn = _getDownloads ?? getDownloadsDirectory;
      return await fn() ?? await getApplicationDocumentsDirectory();
    }

    // iOS and any other native (Fuchsia, etc.) — use app documents directory.
    return getApplicationDocumentsDirectory();
  }
}
