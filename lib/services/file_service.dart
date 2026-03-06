import 'package:church_analytics/platform/file_storage.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/platform/filename_sanitizer.dart';
import 'package:church_analytics/platform/path_safety_guard.dart';
import 'package:church_analytics/services/activity_log_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// Result of an export operation performed by [FileService].
class ExportResult {
  /// Whether the export succeeded.
  final bool success;

  /// Absolute path to the written file; `null` on failure.
  final String? filePath;

  /// Human-readable error description; `null` on success.
  final String? error;

  const ExportResult._({required this.success, this.filePath, this.error});

  /// Creates a successful result with the saved [filePath].
  factory ExportResult.success(String filePath) =>
      ExportResult._(success: true, filePath: filePath);

  /// Creates a failure result with a descriptive [error] message.
  factory ExportResult.failure(String error) =>
      ExportResult._(success: false, error: error);
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
/// - Applies [PathSafetyGuard] to every export path for audit logging.
///   Enforcement (redirect to default) is provided at the UI layer by
///   `_pickExportPath` / `normalizeExportPath` in `reports_screen.dart`.
///   Full auto-resolution enforcement will be added in STORAGE-002.
/// - Calls [ActivityLogService] for every export and import operation.
///   The default implementation is a no-op stub until STORAGE-004 lands.
///
/// ### Path safety note
/// When a [forcedPath] is supplied to [exportFile] / [exportFileBytes],
/// [PathSafetyGuard] is called for audit purposes.  The path is **not**
/// silently redirected at this layer (the caller has already validated it
/// via `_pickExportPath`).  Future STORAGE-002 work will enforce
/// redirection when the path is auto-resolved (null [forcedPath]).
///
/// ### Riverpod
/// Use [fileServiceProvider] to obtain the singleton instance via Riverpod.
/// Services that do not participate in the widget tree may create a default
/// instance with `FileService()`.
class FileService {
  final FileStorage _fileStorage;
  final ActivityLogService _activityLog;

  FileService({FileStorage? fileStorage, ActivityLogService? activityLog})
    : _fileStorage = fileStorage ?? getFileStorage(),
      _activityLog = activityLog ?? const NoOpActivityLogService();

  // -------------------------------------------------------------------------
  // Export
  // -------------------------------------------------------------------------

  /// Saves [content] (UTF-8 text) to a file named [filename].
  ///
  /// The filename is sanitized via [FilenameSanitizer] before being passed to
  /// the platform layer — invalid characters are stripped, Windows reserved
  /// names are prefixed, and the length is capped automatically.
  ///
  /// Provide [forcedPath] to write to a specific absolute path;
  /// omit it to let the platform choose the default export directory
  /// (`Downloads/ChurchAnalytics/`).
  Future<ExportResult> exportFile({
    required String filename,
    required String content,
    String? forcedPath,
  }) async {
    try {
      final safeFilename = _sanitizeFilename(filename);
      _auditPath(safeFilename, forcedPath);

      final savedPath = await _fileStorage.saveFile(
        fileName: safeFilename,
        content: content,
        fullPath: forcedPath,
      );

      if (savedPath == null) {
        _activityLog.logExport(
          filename: safeFilename,
          path: forcedPath,
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
  /// the platform layer (see [exportFile] for details).
  ///
  /// Provide [forcedPath] to write to a specific absolute path;
  /// omit it to let the platform choose the default export directory.
  Future<ExportResult> exportFileBytes({
    required String filename,
    required Uint8List bytes,
    String? forcedPath,
  }) async {
    try {
      final safeFilename = _sanitizeFilename(filename);
      _auditPath(safeFilename, forcedPath);

      final savedPath = await _fileStorage.saveFileBytes(
        fileName: safeFilename,
        bytes: bytes,
        fullPath: forcedPath,
      );

      if (savedPath == null) {
        _activityLog.logExport(
          filename: safeFilename,
          path: forcedPath,
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
final fileServiceProvider = Provider<FileService>((ref) => FileService());
