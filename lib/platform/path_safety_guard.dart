import 'dart:io';

import 'package:flutter/foundation.dart';

/// The result of a [PathSafetyGuard.guard] call.
///
/// When [wasOverridden] is `true` the original [path] failed the safety check
/// and callers should fall back to the platform default export directory and
/// surface a non-blocking warning to the user.
class PathGuardResult {
  /// The path that passed the safety check, or `null` when the path was
  /// rejected and no automatic fallback was available.
  final String? resolvedPath;

  /// `true` when the original path was rejected by the guard.
  final bool wasOverridden;

  /// The original, rejected path — `null` when no override occurred.
  final String? originalPath;

  const PathGuardResult.safe(String path)
    : resolvedPath = path,
      wasOverridden = false,
      originalPath = null;

  /// Convenience constructor for a path that was rejected.
  const PathGuardResult.overridden(String original)
    : resolvedPath = null,
      wasOverridden = true,
      originalPath = original;
}

/// Guards export file-system paths against hidden or app-internal directories
/// that are inaccessible to normal users.
///
/// ### Background
/// On Android, `getExternalStorageDirectory` may occasionally return a path
/// inside the app sandbox (e.g. `/data/data/<pkg>/`) rather than the shared
/// external storage. Writing an export to such a path produces a file that
/// users cannot access without root privileges, causing a silent data-loss
/// scenario.  Similar issues arise on Linux/desktop when paths land in
/// `/tmp/`, hidden dot-folders, or other non-user-facing locations.
///
/// ### Usage
/// ```dart
/// if (!PathSafetyGuard.isUserAccessible(path)) {
///   // warn and fall back to the platform default
/// }
/// ```
class PathSafetyGuard {
  // ---------------------------------------------------------------------------
  // Pattern sets (all lower-cased; matching is case-insensitive on Windows)
  // ---------------------------------------------------------------------------

  /// Patterns that are considered internal / hidden on Android.
  @visibleForTesting
  static const List<String> androidHiddenPatterns = [
    '/data/data/',
    '/data/user/',
    '/code_cache/',
    '/app_webview/',
    '/app_flutter/',
    '/databases/', // app-private SQLite stores
    '/shared_prefs/', // app-private shared preferences
  ];

  /// Patterns that are considered hidden or non-user-accessible on
  /// Linux / Windows / macOS desktop.
  @visibleForTesting
  static const List<String> desktopHiddenPatterns = [
    '/tmp/',
    '/proc/',
    '/sys/',
    '/run/',
  ];

  /// Patterns that are hidden regardless of platform (dot-folders, caches).
  @visibleForTesting
  static const List<String> commonHiddenPatterns = [
    '/cache/',
    '/.', // hidden dot-directories (e.g. ~/.config, /storage/emulated/0/.thumbnails)
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns `true` when [path] points to a location that a normal user can
  /// read and write without special permissions.
  ///
  /// Returns `true` unconditionally on Web because there is no file-system
  /// path concept on that platform.
  ///
  /// The check is purely pattern-based and runs synchronously; it does **not**
  /// verify whether the path actually exists on disk.
  static bool isUserAccessible(String path) {
    if (kIsWeb) return true;

    // Normalise separators so Windows paths are handled uniformly.
    final normalised = path.replaceAll('\\', '/').toLowerCase();

    for (final pattern in commonHiddenPatterns) {
      if (normalised.contains(pattern)) {
        _log('Path rejected (common hidden pattern "$pattern"): $path');
        return false;
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      for (final pattern in androidHiddenPatterns) {
        if (normalised.contains(pattern)) {
          _log('Path rejected (Android hidden pattern "$pattern"): $path');
          return false;
        }
      }
    } else if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      for (final pattern in desktopHiddenPatterns) {
        if (normalised.contains(pattern)) {
          _log('Path rejected (desktop hidden pattern "$pattern"): $path');
          return false;
        }
      }
    }

    return true;
  }

  /// Checks [path] with [isUserAccessible] and returns a [PathGuardResult].
  ///
  /// - When the path is safe: returns `PathGuardResult.safe(path)`.
  /// - When the path is rejected: returns `PathGuardResult.overridden(path)`.
  ///   The caller is responsible for falling back to the platform default
  ///   export directory (see `DefaultExportPathResolver`, STORAGE-002) and for
  ///   surfacing a non-blocking warning to the user.
  static PathGuardResult guard(String path) {
    if (isUserAccessible(path)) {
      return PathGuardResult.safe(path);
    }
    return PathGuardResult.overridden(path);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[PathSafetyGuard] $message');
    }
  }
}
