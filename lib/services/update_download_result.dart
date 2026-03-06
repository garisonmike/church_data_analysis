import 'package:church_analytics/models/update_error_type.dart';

/// The result of a file-download operation performed by [UpdateDownloadService].
///
/// Carries either the absolute path to the successfully downloaded installer
/// file, or a typed [UpdateErrorType] describing the failure.
///
/// Partial files are always deleted before a failure result is returned by
/// [UpdateDownloadService] — callers never need to clean up.
class UpdateDownloadResult {
  /// Whether the download completed successfully.
  final bool isSuccess;

  /// Absolute path to the downloaded installer file.
  ///
  /// Non-null only when [isSuccess] is `true`.
  final String? filePath;

  /// Human-readable description of the failure.
  ///
  /// Non-null only when [isSuccess] is `false`.
  final String? error;

  /// Structured classification of the failure.
  ///
  /// Non-null only when [isSuccess] is `false`.
  final UpdateErrorType? errorType;

  const UpdateDownloadResult._({
    required this.isSuccess,
    this.filePath,
    this.error,
    this.errorType,
  });

  // -------------------------------------------------------------------------
  // Named factories
  // -------------------------------------------------------------------------

  /// The installer was downloaded and saved to [filePath].
  factory UpdateDownloadResult.success(String filePath) =>
      UpdateDownloadResult._(isSuccess: true, filePath: filePath);

  /// The download failed; [errorType] classifies the root cause.
  factory UpdateDownloadResult.failure(
    String error, {
    UpdateErrorType errorType = UpdateErrorType.downloadError,
  }) => UpdateDownloadResult._(
    isSuccess: false,
    error: error,
    errorType: errorType,
  );

  // -------------------------------------------------------------------------
  // Convenience
  // -------------------------------------------------------------------------

  /// `true` when the download failed.
  bool get isError => !isSuccess;

  @override
  String toString() {
    if (isSuccess) return 'UpdateDownloadResult.success($filePath)';
    return 'UpdateDownloadResult.failure($error, errorType: $errorType)';
  }
}
