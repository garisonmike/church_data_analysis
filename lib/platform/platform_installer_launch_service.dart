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
/// | Windows  | [Process.start] with the `.exe` installer, then `exit(0)` |
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
    void Function(int)? exitFn,
    PopFn? popFn,
    @visibleForTesting String? overridePlatform,
  }) : _openFileFn = openFileFn ?? OpenFile.open,
       _runProcessFn = runProcessFn ?? Process.run,
       _exitFn = exitFn ?? exit,
       _popFn = popFn ?? SystemNavigator.pop,
       _overridePlatform = overridePlatform;

  final OpenFileFn _openFileFn;
  final RunProcessFn _runProcessFn;
  final void Function(int) _exitFn;
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

  /// Windows: start the `.exe` installer as a detached process, then call
  /// [exit] to let Windows complete the installation uninterrupted.
  ///
  /// The `exit(0)` call means this method does not return in production.
  /// The injected [_exitFn] (defaulting to `dart:io exit`) is called instead
  /// so that tests can override it with a no-op.
  Future<InstallerLaunchResult> _launchWindows(String installerPath) async {
    await Process.start(
      installerPath,
      [],
      mode: ProcessStartMode.detached,
      runInShell: false,
    );
    _exitFn(0);
    // Unreachable in production; satisfies the Dart type checker.
    return const InstallerLaunchResult.success();
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
    // AC3/AC6 (UPDATE-007): extraction succeeded; the user must relaunch
    // manually since there is no standard in-place binary replacement on Linux.
    return const InstallerLaunchResult.success(
      hint:
          'Update extracted successfully.\n\n'
          'Please close and restart Church Analytics to complete the update.',
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
