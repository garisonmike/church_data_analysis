import 'dart:io' show File;

import 'package:church_analytics/platform/filename_sanitizer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;

/// A function that reports whether a file exists at [path].
///
/// Injected into [FilenameConflictResolver] so that the resolver can be tested
/// without touching the real filesystem.
typedef FileExistsFn = Future<bool> Function(String path);

/// Resolves duplicate-filename conflicts for export operations.
///
/// ## Behaviour
///
/// When [resolve] is called with a [filePath] that already exists on disk, it
/// searches for the first free candidate by appending ` (N)` to the stem:
///
/// ```
/// report.csv           (exists)
/// report (1).csv       (exists)
/// report (2).csv       ← first free, returned
/// ```
///
/// If all candidates up to [maxAttempts] are taken (extremely unlikely in
/// practice), a millisecond-precision Unix timestamp is appended as a final
/// fallback: `report_1709737200000.csv`.
///
/// ## Scope
///
/// This resolver operates on **user-supplied paths** (`forcedPath` in
/// [FileService]).  When no explicit path is given (the platform chooses the
/// default `Downloads/ChurchAnalytics/` directory), the platform layer's own
/// deduplication (`_ensureUniqueFile` in `FileStorageImpl`) applies — that
/// path is not visible to [FileService] before the write.
///
/// ## Testability
///
/// Pass a custom [fileExists] function to avoid real filesystem I/O in tests:
///
/// ```dart
/// final resolver = FilenameConflictResolver(
///   fileExists: (path) async => existingPaths.contains(path),
/// );
/// ```
class FilenameConflictResolver {
  final FileExistsFn _fileExists;

  /// Creates a resolver with an optional [fileExists] override.
  ///
  /// Defaults to a platform-native implementation: always returns `false` on
  /// Web (no filesystem access), and delegates to [File.exists] on native.
  const FilenameConflictResolver({FileExistsFn? fileExists})
    : _fileExists = fileExists ?? _platformFileExists;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns a path that does not yet exist on disk.
  ///
  /// If [filePath] is free, it is returned unchanged.
  /// Otherwise candidates are tried in order:
  ///   `stem (1).ext`, `stem (2).ext`, …, up to [maxAttempts].
  ///
  /// [maxAttempts] defaults to 999 — more than sufficient for any real-world
  /// export scenario.
  Future<String> resolve(String filePath, {int maxAttempts = 999}) async {
    if (!await _fileExists(filePath)) return filePath;

    final dir = p.dirname(filePath);
    final base = p.basename(filePath);
    final (stem, ext) = FilenameSanitizer.splitExtension(base);

    for (int i = 1; i <= maxAttempts; i++) {
      final candidate = p.join(dir, '$stem ($i)$ext');
      if (!await _fileExists(candidate)) return candidate;
    }

    // Timestamp fallback (should never be reached in practice).
    final ts = DateTime.now().millisecondsSinceEpoch;
    return p.join(dir, '${stem}_$ts$ext');
  }

  // ---------------------------------------------------------------------------
  // Default file-exists implementation
  // ---------------------------------------------------------------------------

  static Future<bool> _platformFileExists(String path) async {
    // Web has no filesystem: a path supplied by the user cannot conflict.
    if (kIsWeb) return false;
    return File(path).exists();
  }
}
