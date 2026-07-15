import 'package:church_analytics/services/installer_launch_result.dart';

/// Launches a downloaded installer file on the current platform.
///
/// ## Platform behaviour
/// | Platform | Mechanism |
/// |----------|-----------|
/// | Android  | `ACTION_VIEW` intent with APK MIME type |
/// | Windows  | `Process.start` with the `.exe` installer |
/// | Linux    | Tarball extraction + manual-restart prompt |
/// | Web      | No-op — the browser already handled the download |
///
/// Failure is always surfaced as an [InstallerLaunchResult.failure] with a
/// human-readable [error] string so callers can show recovery UI without
/// crashing.
///
/// ## Usage
/// ```dart
/// final result = await launchService.launch(installerPath);
/// if (result.isError) {
///   // Show UpdateInstallFailureDialog
///   activityLog.logInstallerLaunch(success: false, error: result.error);
/// }
/// ```
abstract class InstallerLaunchService {
  /// Attempts to hand the installer at [installerPath] off to the OS.
  ///
  /// Returns [InstallerLaunchResult.success] if the OS accepted the handoff,
  /// or [InstallerLaunchResult.failure] with the reason if it did not.
  ///
  /// This method must **never** throw — all errors must be caught internally
  /// and returned as [InstallerLaunchResult.failure].
  Future<InstallerLaunchResult> launch(String installerPath);
}

/// No-operation implementation used until platform-aware subclasses are
/// provided.
///
/// Always returns a [InstallerLaunchResult.failure] indicating that the launch
/// has not been implemented yet for the current platform.  This ensures the
/// failure-recovery path is exercised end-to-end before the real
/// launch logic lands.
class NoOpInstallerLaunchService implements InstallerLaunchService {
  const NoOpInstallerLaunchService();

  @override
  Future<InstallerLaunchResult> launch(String installerPath) async {
    return const InstallerLaunchResult.failure(
      'Automatic installer launch has not been implemented for this platform '
      'yet. Please install manually by downloading the latest release from '
      'GitHub Releases.',
    );
  }
}
