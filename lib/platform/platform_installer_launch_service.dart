import 'dart:io';

import 'package:church_analytics/services/installer_launch_result.dart';
import 'package:church_analytics/services/installer_launch_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

// ---------------------------------------------------------------------------
// Injectable typedefs
// ---------------------------------------------------------------------------

/// Calls the system file-open mechanism for [filePath].
///
/// Defaults to [OpenFile.open].  Injectable so the Android path can be tested
/// on any host platform.
typedef OpenFileFn = Future<OpenResult> Function(String filePath);

/// Runs an external process synchronously and returns its result.
///
/// Defaults to [Process.run].  Injectable so the Linux extraction path can be
/// tested without spawning real processes.
typedef RunProcessFn =
    Future<ProcessResult> Function(String executable, List<String> arguments);

/// Closes the host app after handing off to the OS installer.
///
/// Defaults to [SystemNavigator.pop].  Injectable so Android exit behaviour
/// can be verified in unit tests without actually terminating the test process.
typedef PopFn = void Function();

// ---------------------------------------------------------------------------
// PlatformInstallerLaunchService
// ---------------------------------------------------------------------------

/// Real platform implementation of [InstallerLaunchService].
///
/// Selects the correct OS mechanism based on the current (or injected) target
/// platform:
///
/// | Platform | Mechanism |
/// |----------|-----------|
/// | Android  | [OpenFile.open] — triggers APK install intent via `open_file` |
/// | Windows  | PowerShell `Expand-Archive` of the `.zip` release; user copies files & restarts |
/// | Linux    | `tar -xzf` extraction to the same directory; user restarts app |
/// | Web      | No-op — browser handled the download in UPDATE-006 |
/// | Other    | Returns a descriptive failure with manual-install instructions |
///
/// ## Android permissions (Android 8+)
/// `REQUEST_INSTALL_PACKAGES` must be declared in `AndroidManifest.xml`.
/// When the permission is denied at runtime, [launch] returns a
/// [InstallerLaunchResult.failure] with step-by-step instructions for the
/// user to grant the permission manually; [AboutUpdatesCard] then shows
/// [UpdateInstallFailureDialog] (UPDATE-011).
///
/// ## Linux
/// The Linux installer is a `.tar.gz` archive.  After extraction succeeds,
/// [InstallerLaunchResult.success] is returned and the user must relaunch
/// the app manually (there is no standard way to replace a running binary
/// in-place on Linux).
///
/// ## Testability
/// All platform-specific I/O operations are injectable via constructor
/// parameters so every code path can be exercised in unit tests on any host
/// platform.  Pass [overridePlatform] (one of `'android'`, `'windows'`,
/// `'linux'`, `'web'`, `'macos'`, `'ios'`, `'unknown'`) to override the
/// automatic platform detection.
class PlatformInstallerLaunchService implements InstallerLaunchService {
  /// Creates a service with injectable dependencies.
  ///
  /// All parameters are optional and default to production implementations.
  PlatformInstallerLaunchService({
    OpenFileFn? openFileFn,
    RunProcessFn? runProcessFn,
    PopFn? popFn,
    @visibleForTesting String? overridePlatform,
  }) : _openFileFn = openFileFn ?? OpenFile.open,
       _runProcessFn = runProcessFn ?? Process.run,
       _popFn = popFn ?? SystemNavigator.pop,
       _overridePlatform = overridePlatform;

  final OpenFileFn _openFileFn;
  final RunProcessFn _runProcessFn;
  final PopFn _popFn;
  final String? _overridePlatform;

  // -------------------------------------------------------------------------
  // InstallerLaunchService
  // -------------------------------------------------------------------------

  @override
  Future<InstallerLaunchResult> launch(String installerPath) async {
    final platform = _effectivePlatform();
    try {
      switch (platform) {
        case 'android':
          return await _launchAndroid(installerPath);
        case 'windows':
          return await _launchWindows(installerPath);
        case 'linux':
          return await _launchLinux(installerPath);
        case 'web':
          // Web: the browser handled the download in UPDATE-006; no-op here.
          return const InstallerLaunchResult.success();
        default:
          return InstallerLaunchResult.failure(
            'Automatic installation is not supported on this platform '
            '($platform). Please download and install the latest version '
            'manually from GitHub Releases.',
          );
      }
    } catch (e) {
      return InstallerLaunchResult.failure('Installer launch failed: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Platform-specific launch implementations
  // -------------------------------------------------------------------------

  /// Android: delegate to [OpenFile.open], which triggers the system APK
  /// install intent.  Maps [OpenResult.type] to a typed
  /// [InstallerLaunchResult].
  Future<InstallerLaunchResult> _launchAndroid(String installerPath) async {
    final result = await _openFileFn(installerPath);
    switch (result.type) {
      case ResultType.done:
        // AC6 (UPDATE-007): exit the host app so the APK installer can run
        // without the app remaining in the foreground.
        _popFn();
        return const InstallerLaunchResult.success();
      case ResultType.permissionDenied:
        return InstallerLaunchResult.failure(
          'Installation permission was denied. '
          'To fix this on Android 8 and above:\n\n'
          '1. Open Settings → Apps\n'
          '2. Tap Special app access\n'
          '3. Tap Install unknown apps\n'
          '4. Select Church Analytics and enable the permission\n'
          '5. Return here and tap Download Update again.',
        );
      case ResultType.fileNotFound:
        return InstallerLaunchResult.failure(
          'The installer file could not be found at the expected path. '
          'Please tap Download Update to download a fresh copy.',
        );
      case ResultType.noAppToOpen:
        return InstallerLaunchResult.failure(
          'No app on this device can install this file type. '
          'Please download the APK directly from GitHub Releases and '
          'install it manually.',
        );
      case ResultType.error:
        return InstallerLaunchResult.failure(
          result.message.isNotEmpty
              ? result.message
              : 'The installer could not be opened on this device. '
                    'Please try again or install manually from GitHub Releases.',
        );
    }
  }

  /// Windows: the release is a ZIP archive, not an EXE installer.
  ///
  /// Extracts the archive to a staging folder next to the downloaded file
  /// using PowerShell's built-in `Expand-Archive` cmdlet (available on all
  /// Windows 10+ systems), then returns a success result with a [hint]
  /// instructing the user to replace the current installation manually.
  ///
  /// In-place binary replacement is not attempted here because the running
  /// `church_analytics.exe` is locked by Windows while the app is open.
  /// A future version could automate the swap via a small helper launcher.
  Future<InstallerLaunchResult> _launchWindows(String installerPath) async {
    final downloadDir = File(installerPath).parent.path;
    final stagingDir = '$downloadDir\\ChurchAnalytics-Update';

    // Escape single-quotes inside the paths so they are safe inside
    // PowerShell's single-quoted (literal) string syntax.
    final safeInstaller = installerPath.replaceAll("'", "''");
    final safeStaging = stagingDir.replaceAll("'", "''");

    final result = await _runProcessFn('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "Expand-Archive -LiteralPath '$safeInstaller' -DestinationPath '$safeStaging' -Force",
    ]);

    if (result.exitCode != 0) {
      final stderr = result.stderr as String? ?? '';
      return InstallerLaunchResult.failure(
        'Failed to extract the update archive.'
        '${stderr.isNotEmpty ? '\n\nDetails: $stderr' : ''}\n\n'
        'You can extract it manually:\n$installerPath',
      );
    }

    // The CI ZIP contains a "windows" subfolder at its root.
    final extractedDir = '$stagingDir\\windows';
    return InstallerLaunchResult.success(
      hint:
          'Update extracted to:\n$extractedDir\n\n'
          'To complete the update:\n'
          '1. Close Church Analytics\n'
          '2. Copy all files from the above folder to your existing '
          'Church Analytics installation folder\n'
          '3. Relaunch Church Analytics',
    );
  }

  /// Linux: extract the `.tar.gz` installer archive to the same directory,
  /// then return success.  The user must relaunch the app manually — there is
  /// no standard in-place binary replacement mechanism on Linux.
  Future<InstallerLaunchResult> _launchLinux(String installerPath) async {
    final destDir = File(installerPath).parent.path;
    final result = await _runProcessFn('tar', [
      '-xzf',
      installerPath,
      '-C',
      destDir,
    ]);
    if (result.exitCode != 0) {
      final stderr = result.stderr as String? ?? '';
      return InstallerLaunchResult.failure(
        'Failed to extract the installer archive. '
        '${stderr.isNotEmpty ? 'Details: $stderr. ' : ''}'
        'Please extract $installerPath manually and restart the app to '
        'complete the update.',
      );
    }
    // Extraction succeeded.  Because the archive is downloaded to the system
    // temp directory, the extracted files are also in temp — NOT over the
    // running binaries.  Simply restarting the app would relaunch the old
    // version.  Inform the user of the exact extraction path and instruct
    // them to copy the files over their existing installation manually before
    // relaunching (same approach as Windows).
    return InstallerLaunchResult.success(
      hint:
          'Update extracted to:\n$destDir\n\n'
          'To complete the update:\n'
          '1. Close Church Analytics\n'
          '2. Copy all files from the above folder to your existing '
          'Church Analytics installation folder\n'
          '3. Relaunch Church Analytics',
    );
  }

  // -------------------------------------------------------------------------
  // Platform detection
  // -------------------------------------------------------------------------

  /// Returns the effective target platform key used to select the launch
  /// strategy.
  ///
  /// When [_overridePlatform] is set (test use only), that value is returned
  /// unconditionally.  Otherwise the current runtime platform is detected
  /// using [Platform] and [kIsWeb].
  String _effectivePlatform() {
    if (_overridePlatform != null) return _overridePlatform;
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isWindows) return 'windows';
      if (Platform.isLinux) return 'linux';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isIOS) return 'ios';
    } catch (_) {
      // Fallthrough to 'unknown' in restricted environments.
    }
    return 'unknown';
  }
}
