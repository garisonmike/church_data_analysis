/// Describes a single file export or import operation logged by [FileService].
///
/// This is a forward-compatibility stub for STORAGE-004 (`ActivityLogService`).
/// The full implementation — including persistence, FIFO capping,
/// and Settings UI — will be added in that issue.
///
/// Until STORAGE-004 lands, [FileService] uses [NoOpActivityLogService].
abstract class ActivityLogService {
  /// Records the result of an export operation.
  void logExport({
    required String filename,
    required String? path,
    required bool success,
    String? error,
  });

  /// Records the result of an import (file-pick + read) operation.
  void logImport({
    required String filename,
    required bool success,
    String? error,
  });

  /// Records the result of an installer-launch attempt (UPDATE-011).
  ///
  /// [platform] is the current platform identifier (e.g. `'android'`).
  /// [error] is the human-readable failure reason; `null` on success.
  void logInstallerLaunch({
    required bool success,
    String? platform,
    String? error,
  });
}

/// No-operation implementation used until STORAGE-004 is complete.
class NoOpActivityLogService implements ActivityLogService {
  const NoOpActivityLogService();

  @override
  void logExport({
    required String filename,
    required String? path,
    required bool success,
    String? error,
  }) {
    // Intentional no-op — STORAGE-004 will provide the real implementation.
  }

  @override
  void logImport({
    required String filename,
    required bool success,
    String? error,
  }) {
    // Intentional no-op — STORAGE-004 will provide the real implementation.
  }

  @override
  void logInstallerLaunch({
    required bool success,
    String? platform,
    String? error,
  }) {
    // Intentional no-op — STORAGE-004 will provide the real implementation.
  }
}
