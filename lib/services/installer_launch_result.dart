/// The result of an installer-launch operation performed by
/// [InstallerLaunchService].
///
/// Carries either a [success] flag indicating the OS handoff was initiated, or
/// a human-readable [error] message describing why the launch failed.
class InstallerLaunchResult {
  /// Whether the installer was handed off to the OS successfully.
  final bool isSuccess;

  /// Human-readable description of the failure.
  ///
  /// Non-null only when [isSuccess] is `false`.
  final String? error;

  const InstallerLaunchResult._({required this.isSuccess, this.error});

  // -------------------------------------------------------------------------
  // Named factories
  // -------------------------------------------------------------------------

  /// The installer launch was initiated successfully.
  const InstallerLaunchResult.success() : isSuccess = true, error = null;

  /// The installer launch failed with [error] as the reason.
  const InstallerLaunchResult.failure(String error)
    : isSuccess = false,
      error = error;

  // -------------------------------------------------------------------------
  // Convenience
  // -------------------------------------------------------------------------

  /// `true` when the launch failed.
  bool get isError => !isSuccess;

  @override
  String toString() {
    if (isSuccess) return 'InstallerLaunchResult.success()';
    return 'InstallerLaunchResult.failure($error)';
  }
}
