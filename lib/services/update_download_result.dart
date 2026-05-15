import 'package:church_analytics/models/update_error_type.dart';

/// The result of a file-download operation performed by [UpdateDownloadService].
///
/// Carries either the absolute path to the successfully downloaded installer
/// file, a typed [UpdateErrorType] describing the failure, or — when the user
/// paused mid-stream — the path to the partial file and the byte offset so
/// that [UpdateDownloadService.resume] can continue from where it left off
/// (FEAT-006).
///
/// Partial files are **always** deleted before a failure result is returned by
/// [UpdateDownloadService] — callers never need to clean up on error.  A
/// [paused] result, however, intentionally retains the partial file on disk;
/// the caller is responsible for either resuming or discarding it.
class UpdateDownloadResult {
  /// Whether the download completed successfully.
  final bool isSuccess;

  /// Whether the download was cancelled mid-resume but the partial file was
  /// kept on disk so the operation is resumable on the next launch (FEAT-007).
  ///
  /// When `true`, [filePath] and [bytesReceived] are non-null (same semantics
  /// as [isPaused]).  The [DownloadStateService] record is intentionally kept
  /// so that [StartupGateScreen] can detect and offer the file again.
  final bool isCancelledResumable;

  /// Whether the download was paused by the user before completion (FEAT-006).
  ///
  /// When `true`, [filePath] and [bytesReceived] are non-null.  The
  /// caller should offer a "Resume" action that passes these values to
  /// [UpdateDownloadService.resume].
  final bool isPaused;

  /// Absolute path to the downloaded installer file.
  ///
  /// Non-null when [isSuccess] is `true`.
  /// Also non-null when [isPaused] is `true` (path to the partial file).
  final String? filePath;

  /// Human-readable description of the failure.
  ///
  /// Non-null only when [isSuccess] and [isPaused] are both `false`.
  final String? error;

  /// Structured classification of the failure.
  ///
  /// Non-null only when [isSuccess] and [isPaused] are both `false`.
  final UpdateErrorType? errorType;

  /// Number of bytes written to [filePath] at the time the download was paused.
  ///
  /// Non-null only when [isPaused] is `true`.  Used to construct the
  /// Range header in [UpdateDownloadService.resume], and to display the
  /// paused progress fraction in the UI.
  final int? bytesReceived;

  const UpdateDownloadResult._({
    required this.isSuccess,
    required this.isPaused,
    required this.isCancelledResumable,
    this.filePath,
    this.error,
    this.errorType,
    this.bytesReceived,
  });

  // -------------------------------------------------------------------------
  // Named factories
  // -------------------------------------------------------------------------

  /// The installer was downloaded in full and saved to [filePath].
  factory UpdateDownloadResult.success(String filePath) =>
      UpdateDownloadResult._(
        isSuccess: true,
        isPaused: false,
        isCancelledResumable: false,
        filePath: filePath,
      );

  /// The download failed; [errorType] classifies the root cause.
  ///
  /// The partial destination file (if any) has already been deleted by
  /// [UpdateDownloadService] before this result is returned.
  factory UpdateDownloadResult.failure(
    String error, {
    UpdateErrorType errorType = UpdateErrorType.downloadError,
  }) => UpdateDownloadResult._(
    isSuccess: false,
    isPaused: false,
    isCancelledResumable: false,
    error: error,
    errorType: errorType,
  );

  /// The download was paused by the user at [bytesReceived] bytes (FEAT-006).
  ///
  /// [partialFilePath] points to the partially written file on disk.  The
  /// file is valid up to [bytesReceived] bytes and can be resumed by passing
  /// it to [UpdateDownloadService.resume].
  factory UpdateDownloadResult.paused(
    String partialFilePath, {
    required int bytesReceived,
  }) => UpdateDownloadResult._(
    isSuccess: false,
    isPaused: true,
    isCancelledResumable: false,
    filePath: partialFilePath,
    bytesReceived: bytesReceived,
  );

  /// The download was cancelled mid-resume but the partial file was kept on
  /// disk (FEAT-007).
  ///
  /// Used exclusively by [UpdateDownloadService.resumeFile] when the user
  /// cancels during a resume-from-crash flow.  The [DownloadStateService]
  /// record is intentionally kept so that [StartupGateScreen] can offer the
  /// same "Resume or Discard?" dialog on the next launch.
  ///
  /// Callers should treat this identically to [paused]: do nothing, let the
  /// record survive.
  factory UpdateDownloadResult.cancelledResumable(
    String partialFilePath, {
    required int bytesReceived,
  }) => UpdateDownloadResult._(
    isSuccess: false,
    isPaused: false,
    isCancelledResumable: true,
    filePath: partialFilePath,
    bytesReceived: bytesReceived,
  );

  // -------------------------------------------------------------------------
  // Convenience
  // -------------------------------------------------------------------------

  /// Convenience alias for [filePath] when the result is paused or
  /// cancelled-resumable.
  ///
  /// Makes call sites more readable: `result.partialFilePath` vs `result.filePath`.
  String? get partialFilePath =>
      (isPaused || isCancelledResumable) ? filePath : null;

  /// `true` when the download failed (not paused, not succeeded, not
  /// cancelled-resumable).
  bool get isError => !isSuccess && !isPaused && !isCancelledResumable;

  @override
  String toString() {
    if (isSuccess) return 'UpdateDownloadResult.success($filePath)';
    if (isPaused) {
      return 'UpdateDownloadResult.paused($filePath, bytesReceived: $bytesReceived)';
    }
    if (isCancelledResumable) {
      return 'UpdateDownloadResult.cancelledResumable($filePath, bytesReceived: $bytesReceived)';
    }
    return 'UpdateDownloadResult.failure($error, errorType: $errorType)';
  }
}
