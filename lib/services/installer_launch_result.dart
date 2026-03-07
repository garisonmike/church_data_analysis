/// The result of an installer-launch operation performed by
/// [InstallerLaunchService].
///
/// Carries either a [success] flag indicating the OS handoff was initiated, or
/// a human-readable [error] message describing why the launch failed.
///
/// On some platforms (e.g. Linux) a successful launch may also carry a [hint]
/// — a short user-visible instruction shown after handoff (e.g. "restart the
/// app to complete the update").
class InstallerLaunchResult {
  /// Whether the installer was handed off to the OS successfully.
  final bool isSuccess;

  /// Human-readable description of the failure.
  ///
  /// Non-null only when [isSuccess] is `false`.
  final String? error;

  /// Optional informational message shown after a successful handoff.
  ///
  /// Used on platforms where the user must take a follow-up manual action
  /// to complete the update:
  ///
  /// - **Linux**: restart the app after `tar` extraction.
  /// - **Windows**: copy the extracted files to the install folder & restart.
  ///
  /// `null` for all failure results and for silent-success platforms (Android,
  /// Web).
  final String? hint;

  // -------------------------------------------------------------------------
  // Named factories
  // -------------------------------------------------------------------------

  /// The installer launch was initiated successfully.
  ///
  /// Supply [hint] when a follow-up user action is required after handoff.
  const InstallerLaunchResult.success({this.hint})
    : isSuccess = true,
      error = null;

  /// The installer launch failed with [error] as the reason.
  const InstallerLaunchResult.failure(String this.error)
    : isSuccess = false,
      hint = null;

  // -------------------------------------------------------------------------
  // Convenience
  // -------------------------------------------------------------------------

  /// `true` when the launch failed.
  bool get isError => !isSuccess;

  @override
  String toString() {
    if (isSuccess) {
      return hint != null
          ? 'InstallerLaunchResult.success(hint: $hint)'
          : 'InstallerLaunchResult.success()';
    }
    return 'InstallerLaunchResult.failure($error)';
  }
}
