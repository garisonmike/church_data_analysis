import 'package:church_analytics/platform/default_export_path_resolver.dart';
import 'package:church_analytics/platform/file_storage.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/platform/filename_conflict_resolver.dart';
import 'package:church_analytics/platform/filename_sanitizer.dart';
import 'package:church_analytics/platform/path_safety_guard.dart';
import 'package:church_analytics/repositories/settings_repository.dart';
import 'package:church_analytics/services/activity_log_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// ---------------------------------------------------------------------------
// Error classification
// ---------------------------------------------------------------------------

/// Classifies the category of a failed export or import operation.
///
/// Used by [ExportResult] and [ImportResult] to render user-friendly error
/// messages and suggested remediations in the UI.
enum ExportErrorType {
  /// The platform denied access to the target path.
  permissionDenied,

  /// The supplied path is syntactically or semantically invalid.
  invalidPath,

  /// Insufficient free space on the target storage device.
  storageFull,

  /// The platform layer returned `null` without explanation.
  platformError,

  /// Any other failure not covered by the above categories.
  unknown,
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// Result of an export operation performed by [FileService].
class ExportResult {
  /// Whether the export succeeded.
  final bool success;

  /// Absolute path to the written file; `null` on failure or Web blob export.
  final String? filePath;

  /// Filename-only component of [filePath] (e.g. `"data.csv"`).
  /// `null` on failure.
  final String? filename;

  /// Human-readable error description; `null` on success.
  final String? error;

  /// Categorized error type for UI rendering; `null` on success.
  final ExportErrorType? errorType;

  /// Raw exception detail string for debugging; `null` on success.
  final String? errorDetail;

  const ExportResult._({
    required this.success,
    this.filePath,
    this.filename,
    this.error,
    this.errorType,
    this.errorDetail,
  });

  /// Creates a successful result with the saved [filePath].
  factory ExportResult.success(String filePath) {
    // Extract just the filename from the full path.
    final name = filePath.contains('/')
        ? filePath.split('/').last
        : filePath.contains(r'\')
        ? filePath.split(r'\').last
        : filePath;
    return ExportResult._(
      success: true,
      filePath: filePath,
      filename: name.isEmpty ? filePath : name,
    );
  }

  /// Creates a failure result with a descriptive [error] message.
  ///
  /// [errorType] is auto-classified from [error] if not supplied.
  /// Pass [errorDetail] to carry the raw exception string for debugging.
  factory ExportResult.failure(
    String error, {
    ExportErrorType? errorType,
    String? errorDetail,
  }) => ExportResult._(
    success: false,
    error: error,
    errorType: errorType ?? _classifyError(error),
    errorDetail: errorDetail,
  );

  /// A brief, user-facing remediation hint based on [errorType].
  String get remediation {
    switch (errorType) {
      case ExportErrorType.permissionDenied:
        return 'Check your storage permissions in Settings.';
      case ExportErrorType.invalidPath:
        return 'Try selecting a different save location.';
      case ExportErrorType.storageFull:
        return 'Free up storage space and try again.';
      case ExportErrorType.platformError:
      case ExportErrorType.unknown:
      case null:
        return 'Try again or contact support.';
    }
  }

  /// Infers [ExportErrorType] from a raw error string.
  static ExportErrorType _classifyError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('permission') ||
        lower.contains('denied') ||
        lower.contains('access')) {
      return ExportErrorType.permissionDenied;
    }
    if (lower.contains('no space') ||
        lower.contains('storage full') ||
        lower.contains('disk full') ||
        lower.contains('enospc')) {
      return ExportErrorType.storageFull;
    }
    if (lower.contains('path') ||
        lower.contains('invalid') ||
        lower.contains('not found') ||
        lower.contains('enoent')) {
      return ExportErrorType.invalidPath;
    }
    if (lower.contains('null') || lower.contains('platform')) {
      return ExportErrorType.platformError;
    }
    return ExportErrorType.unknown;
  }
}

/// Result of an import (file pick + read) operation performed by [FileService].
class ImportResult {
  /// Whether a file was successfully picked and is ready for processing.
  final bool success;

  /// The picked file descriptor; `null` when cancelled or on error.
  final PlatformFileResult? file;

  /// Human-readable error description; `null` on success or cancellation.
  final String? error;

  const ImportResult._({required this.success, this.file, this.error});

  /// Creates a successful result carrying the picked [file].
  factory ImportResult.success(PlatformFileResult file) =>
      ImportResult._(success: true, file: file);

  /// Creates a result representing a user-cancelled pick (no error).
  factory ImportResult.cancelled() => const ImportResult._(success: false);

  /// Creates an error result with a descriptive [error] message.
  factory ImportResult.failure(String error) =>
      ImportResult._(success: false, error: error);
}

// ---------------------------------------------------------------------------
// FileService
// ---------------------------------------------------------------------------

/// The single gateway for all file I/O operations in the application.
///
/// ### Responsibilities
/// - Delegates raw I/O to [FileStorage] (platform implementations).
/// - Resolves the default export directory via [DefaultExportPathResolver]
///   when no [forcedPath] is supplied to [exportFile] / [exportFileBytes].
///   On Android the target is `<external Downloads>/ChurchAnalytics/`; on
///   Linux/Windows/macOS it is `~/Downloads/ChurchAnalytics/`.  Web uses a
///   blob download (no filesystem path — the resolver returns `null`).
/// - Applies [PathSafetyGuard] to every export path for audit logging.
///   Enforcement (redirect to default) is provided at the UI layer by
///   `_pickExportPath` / `normalizeExportPath` in `reports_screen.dart`.
/// - Calls [ActivityLogService] for every export and import operation.
///   The default implementation is a no-op stub until STORAGE-004 lands.
/// - Resolves duplicate filenames via [FilenameConflictResolver] so that no
///   existing file is silently overwritten.  When the target path already
///   exists the write is redirected to `stem (1).ext`, `stem (2).ext`, etc.
///   This applies to both forced-path exports and default-directory exports
///   (native platforms only — Web does not have per-file conflict detection).
///
/// ### Path safety note
/// When a [forcedPath] is supplied to [exportFile] / [exportFileBytes],
/// [PathSafetyGuard] is called for audit purposes.  The path is **not**
/// silently redirected at this layer (the caller has already validated it
/// via `_pickExportPath`).
///
/// ### Riverpod
/// Use [fileServiceProvider] to obtain the singleton instance via Riverpod.
/// Services that do not participate in the widget tree may create a default
/// instance with `FileService()`.
class FileService {
  final FileStorage _fileStorage;
  final ActivityLogService _activityLog;
  final FilenameConflictResolver _conflictResolver;
  final DefaultExportPathResolver _exportPathResolver;

  FileService({
    FileStorage? fileStorage,
    ActivityLogService? activityLog,
    FilenameConflictResolver? conflictResolver,
    DefaultExportPathResolver? exportPathResolver,
  }) : _fileStorage = fileStorage ?? getFileStorage(),
       _activityLog = activityLog ?? const NoOpActivityLogService(),
       _conflictResolver = conflictResolver ?? const FilenameConflictResolver(),
       _exportPathResolver =
           exportPathResolver ?? const DefaultExportPathResolver();

  // -------------------------------------------------------------------------
  // Export
  // -------------------------------------------------------------------------

  /// Saves [content] (UTF-8 text) to a file named [filename].
  ///
  /// The filename is sanitized via [FilenameSanitizer] before being passed to
  /// the platform layer — invalid characters are stripped, Windows reserved
  /// names are prefixed, and the length is capped automatically.
  ///
  /// When [forcedPath] is provided and that path already exists on disk,
  /// [FilenameConflictResolver] automatically redirects the write to the first
  /// free path (`stem (1).ext`, `stem (2).ext`, …) so no existing file is
  /// silently overwritten.
  ///
  /// When [forcedPath] is omitted on native platforms, [DefaultExportPathResolver]
  /// supplies the default export directory (`Downloads/ChurchAnalytics/`) and
  /// the full destination path is built before writing so [FilenameConflictResolver]
  /// can also deduplicate within the default directory.  On Web the platform
  /// triggers a browser blob download and no filesystem path is used.
  Future<ExportResult> exportFile({
    required String filename,
    required String content,
    String? forcedPath,
  }) async {
    try {
      final safeFilename = _sanitizeFilename(filename);
      final effectivePath = await _buildExportPath(safeFilename, forcedPath);
      final resolvedPath = await _resolveConflict(effectivePath);
      _auditPath(safeFilename, resolvedPath);

      final savedPath = await _fileStorage.saveFile(
        fileName: safeFilename,
        content: content,
        fullPath: resolvedPath,
      );

      if (savedPath == null) {
        _activityLog.logExport(
          filename: safeFilename,
          path: resolvedPath,
          success: false,
          error: 'Platform returned null — file may not have been saved.',
        );
        return ExportResult.failure(
          'Failed to save "$safeFilename". The platform did not confirm a write location.',
        );
      }

      _activityLog.logExport(
        filename: safeFilename,
        path: savedPath,
        success: true,
      );
      return ExportResult.success(savedPath);
    } catch (e) {
      final safeFilename = _sanitizeFilename(filename);
      final msg = 'Export of "$safeFilename" failed: $e';
      _activityLog.logExport(
        filename: safeFilename,
        path: forcedPath,
        success: false,
        error: msg,
      );
      return ExportResult.failure(msg);
    }
  }

  /// Saves raw [bytes] to a file named [filename].
  ///
  /// The filename is sanitized via [FilenameSanitizer] before being passed to
  /// the platform layer (see [exportFile] for details).  Duplicate-path
  /// resolution and default-directory resolution apply in the same way as
  /// [exportFile].
  ///
  /// Provide [forcedPath] to write to a specific absolute path;
  /// omit it to let [DefaultExportPathResolver] supply the default export
  /// directory (`Downloads/ChurchAnalytics/`) on native platforms.
  Future<ExportResult> exportFileBytes({
    required String filename,
    required Uint8List bytes,
    String? forcedPath,
  }) async {
    try {
      final safeFilename = _sanitizeFilename(filename);
      final effectivePath = await _buildExportPath(safeFilename, forcedPath);
      final resolvedPath = await _resolveConflict(effectivePath);
      _auditPath(safeFilename, resolvedPath);

      final savedPath = await _fileStorage.saveFileBytes(
        fileName: safeFilename,
        bytes: bytes,
        fullPath: resolvedPath,
      );

      if (savedPath == null) {
        _activityLog.logExport(
          filename: safeFilename,
          path: resolvedPath,
          success: false,
          error: 'Platform returned null — file may not have been saved.',
        );
        return ExportResult.failure(
          'Failed to save "$safeFilename". The platform did not confirm a write location.',
        );
      }

      _activityLog.logExport(
        filename: safeFilename,
        path: savedPath,
        success: true,
      );
      return ExportResult.success(savedPath);
    } catch (e) {
      final safeFilename = _sanitizeFilename(filename);
      final msg = 'Export of "$safeFilename" (bytes) failed: $e';
      _activityLog.logExport(
        filename: safeFilename,
        path: forcedPath,
        success: false,
        error: msg,
      );
      return ExportResult.failure(msg);
    }
  }

  // -------------------------------------------------------------------------
  // Import
  // -------------------------------------------------------------------------

  /// Presents a file picker restricted to [allowedExtensions] and returns an
  /// [ImportResult] with the selected file.
  ///
  /// Returns [ImportResult.cancelled] when the user dismisses the picker.
  Future<ImportResult> importFile({
    required List<String> allowedExtensions,
  }) async {
    try {
      final file = await _fileStorage.pickFile(
        allowedExtensions: allowedExtensions,
      );

      if (file == null) {
        return ImportResult.cancelled();
      }

      _activityLog.logImport(filename: file.name, success: true);
      return ImportResult.success(file);
    } catch (e) {
      const msg = 'File selection failed';
      _activityLog.logImport(filename: '', success: false, error: msg);
      return ImportResult.failure('$msg: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Low-level pass-throughs (needed by parsing services)
  // -------------------------------------------------------------------------

  /// Presents a file picker and returns the raw [PlatformFileResult].
  ///
  /// Prefer [importFile] for simple one-shot imports.  Use this method only
  /// when downstream code performs multi-step processing on the result
  /// (e.g. parsing CSV or XLSX content) and needs the file descriptor directly.
  ///
  /// Activity is logged on success, matching the behaviour of [importFile].
  Future<PlatformFileResult?> pickFile({
    required List<String> allowedExtensions,
  }) async {
    final file = await _fileStorage.pickFile(
      allowedExtensions: allowedExtensions,
    );
    if (file != null) {
      _activityLog.logImport(filename: file.name, success: true);
    }
    return file;
  }

  /// Presents a save-location picker and returns the chosen path.
  ///
  /// Returns `null` when the user cancels or when the platform does not
  /// support save-location dialogs (Web).
  Future<String?> pickSaveLocation({
    required String suggestedName,
    required List<String> allowedExtensions,
  }) => _fileStorage.pickSaveLocation(
    suggestedName: suggestedName,
    allowedExtensions: allowedExtensions,
  );

  /// Reads the content of [file] as a UTF-8 string.
  Future<String> readFileAsString(PlatformFileResult file) =>
      _fileStorage.readFileAsString(file);

  /// Reads the content of [file] as raw bytes.
  Future<Uint8List> readFileAsBytes(PlatformFileResult file) =>
      _fileStorage.readFileAsBytes(file);

  /// Returns the absolute path to the platform default export directory.
  ///
  /// Delegates to [DefaultExportPathResolver.resolve].
  /// Returns `null` on Web (blob download — no filesystem path).
  ///
  /// Used by the Settings UI (STORAGE-005) to display the current
  /// default export location to the user.
  Future<String?> getDefaultExportPath() => _exportPathResolver.resolve();

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Returns a sanitized copy of [filename] using [FilenameSanitizer].
  ///
  /// Emits a [debugPrint] warning when the name was modified so that
  /// callers can detect malformed inputs during development.
  String _sanitizeFilename(String filename) {
    final safe = FilenameSanitizer.sanitize(filename);
    if (safe != filename && kDebugMode) {
      debugPrint('[FileService] Filename sanitized: "$filename" → "$safe"');
    }
    return safe;
  }

  /// Builds the full export path for a given [safeFilename].
  ///
  /// When [forcedPath] is non-null it is returned as-is (the caller chose an
  /// explicit destination).
  ///
  /// When [forcedPath] is `null` the method asks [DefaultExportPathResolver]
  /// for the default export directory and joins it with [safeFilename].  On
  /// Web the resolver returns `null`, so this method also returns `null` and
  /// the platform layer's blob-download logic takes over.
  Future<String?> _buildExportPath(
    String safeFilename,
    String? forcedPath,
  ) async {
    if (forcedPath != null) return forcedPath;
    final dir = await _exportPathResolver.resolve();
    if (dir == null) return null; // Web: blob download, no path.
    return p.join(dir, safeFilename);
  }

  /// Resolves a non-conflicting path via [FilenameConflictResolver].
  ///
  /// Returns [path] unchanged when it is `null` (Web blob-download export).
  /// When [path] already exists on disk the resolver returns the first free
  /// candidate (`stem (1).ext`, `stem (2).ext`, …) so no existing file is
  /// silently overwritten.
  Future<String?> _resolveConflict(String? path) async {
    if (path == null) return null;
    final resolved = await _conflictResolver.resolve(path);
    if (resolved != path && kDebugMode) {
      debugPrint('[FileService] Conflict resolved: "$path" → "$resolved"');
    }
    return resolved;
  }

  /// Runs [PathSafetyGuard] against [path] for audit purposes.
  ///
  /// Logs a debug warning when the path matches a hidden-directory pattern.
  /// Does **not** redirect or block so that the behaviour is consistent with
  /// tests that use `Directory.systemTemp` and callers that have already
  /// validated the path via `_pickExportPath`.
  void _auditPath(String filename, String? path) {
    if (path == null) return;
    final result = PathSafetyGuard.guard(path);
    if (result.wasOverridden && kDebugMode) {
      debugPrint(
        '[FileService] WARNING: export of "$filename" targets a '
        'potentially inaccessible path: "$path". '
        'Consider using the default export directory instead.',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Riverpod [Provider] for the application-wide [FileService] singleton.
///
/// Consume this provider in [ConsumerWidget] classes that need to perform
/// file I/O:
/// ```dart
/// final fileService = ref.read(fileServiceProvider);
/// final result = await fileService.exportFile(filename: 'data.csv', content: csv);
/// ```
///
/// Injects [DefaultExportPathResolver] with the user-override getter from
/// [SettingsRepository] so that a custom export folder (if set) is always
/// used as the highest-priority default path.
final fileServiceProvider = Provider<FileService>((ref) {
  final settingsRepo = ref.read(settingsRepositoryProvider);
  return FileService(
    activityLog: ref.read(activityLogServiceProvider),
    exportPathResolver: DefaultExportPathResolver(
      getCustomPath: settingsRepo.getDefaultExportPath,
    ),
  );
});
