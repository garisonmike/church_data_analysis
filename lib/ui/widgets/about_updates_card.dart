import 'dart:io' show Directory, Platform;

import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/update_error_messages.dart';
import 'package:church_analytics/models/update_error_type.dart';
import 'package:church_analytics/models/update_manifest.dart';
import 'package:church_analytics/platform/install_permission_service.dart'; // FEAT-002
import 'package:church_analytics/services/download_foreground_service.dart'; // FEAT-008
import 'package:permission_handler/permission_handler.dart'; // FEAT-008 (POST_NOTIFICATIONS)
import 'package:church_analytics/services/activity_log_service.dart';
import 'package:church_analytics/services/installer_launch_service.dart';
import 'package:church_analytics/services/update_download_result.dart';
import 'package:church_analytics/services/update_download_service.dart';
import 'package:church_analytics/services/update_service.dart';
import 'package:church_analytics/ui/widgets/installer_confirmation_dialog.dart';
import 'package:church_analytics/ui/widgets/pre_update_backup_dialog.dart'; // FEAT-003
import 'package:church_analytics/ui/widgets/release_notes_dialog.dart';
import 'package:church_analytics/ui/widgets/update_download_progress_dialog.dart';
import 'package:church_analytics/ui/widgets/update_install_failure_dialog.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// State enum
// ---------------------------------------------------------------------------

/// Internal state machine for the update-check lifecycle.
enum _CheckState {
  /// No check has been performed yet.
  idle,

  /// A check is in progress (HTTP fetch + parse).
  checking,

  /// The installed version is the latest available.
  upToDate,

  /// A newer version is available for download.
  updateAvailable,

  /// The check failed (network error, parse error, etc.).
  error,
}

// ---------------------------------------------------------------------------
// AboutUpdatesCard
// ---------------------------------------------------------------------------

/// Settings card that displays the current app version and provides an
/// interactive "Check for Updates" button.
///
/// ## State machine
/// ```
/// idle → checking → upToDate
///                 → updateAvailable
///                 → error
/// ```
///
/// The card reads the current app version from [PackageInfo.fromPlatform] and
/// delegates the remote check to [updateServiceProvider].
///
/// ### Stub actions
/// The "View Release Notes" action is a stub wired up by UPDATE-005.
/// The "Download Update" button triggers the install flow and handles
/// launcher failures via [UpdateInstallFailureDialog] (UPDATE-011).
class AboutUpdatesCard extends ConsumerStatefulWidget {
  /// Installer launch service injected for testability.
  ///
  /// Defaults to [NoOpInstallerLaunchService] for tests.  In production,
  /// [AppSettingsScreen] passes [PlatformInstallerLaunchService].
  final InstallerLaunchService launchService;

  /// Activity-log service injected for testability.
  final ActivityLogService activityLog;

  /// Download service injected for testability.
  ///
  /// When `null` (production default), a new [UpdateDownloadService] instance
  /// is created inline inside [_onDownloadUpdate].  Inject a custom subclass
  /// in tests to bypass real HTTP requests.
  final UpdateDownloadService? downloadService;

  /// Destination directory resolver for testability.
  ///
  /// Defaults to [getTemporaryDirectory].  Inject a custom resolver in tests
  /// to avoid real filesystem calls.
  final Future<Directory> Function()? destDirResolver;

  /// Confirmation dialog function injected for testability.
  ///
  /// Called at the start of [_doInstall] to show the pre-install confirmation.
  /// Defaults to [InstallerConfirmationDialog.show].  Inject
  /// `(_) async => true` in tests to bypass the dialog.
  final Future<bool?> Function(BuildContext)? confirmInstall;

  /// Church ID used by [PreUpdateBackupDialog] to load the correct records
  /// when the user chooses to back up before updating (FEAT-003).
  ///
  /// Passed in from [AppSettingsScreen], which receives it via route arguments
  /// from [DashboardScreen].  Defaults to `0` so that existing tests that do
  /// not supply a church ID continue to compile without change.
  final int churchId;

  const AboutUpdatesCard({
    super.key,
    this.launchService = const NoOpInstallerLaunchService(),
    this.activityLog = const NoOpActivityLogService(),
    this.downloadService,
    this.destDirResolver,
    this.confirmInstall,
    this.churchId = 0, // FEAT-003
  });

  @override
  ConsumerState<AboutUpdatesCard> createState() => _AboutUpdatesCardState();
}

class _AboutUpdatesCardState extends ConsumerState<AboutUpdatesCard> {
  _CheckState _state = _CheckState.idle;
  String _currentVersion = '';
  String? _latestVersion;
  String? _errorMessage;
  UpdateErrorType? _errorType;
  DateTime? _lastChecked;

  /// The most-recently fetched manifest; non-null only in the
  /// [_CheckState.updateAvailable] state.
  UpdateManifest? _manifest;

  /// The paused download result (FEAT-006).
  ///
  /// Non-null when the user paused a download mid-stream.  Holds the path to
  /// the partial file on disk and the number of bytes received so far.  The
  /// "Resume Download" button is shown in the UI whenever this is non-null.
  /// Set back to `null` when the resumed download succeeds or is cancelled.
  UpdateDownloadResult? _pausedResult;

  /// Whether the download server supports HTTP range requests (FEAT-006).
  ///
  /// Set after a HEAD request to the manifest download URL when an update is
  /// found.  `true` → Pause button is shown in the progress dialog.  `false`
  /// (default) → Pause button is hidden, since offering a feature that
  /// silently degrades would mislead the user.  The 416 fallback inside
  /// [UpdateDownloadService] remains as a safety net but the user should never
  /// be offered Pause if the server cannot honour range requests.
  bool _supportsResume = false;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
    // FEAT-008: initialise foreground service config once per widget lifecycle.
    // No-op on non-Android platforms. Safe to call multiple times.
    DownloadForegroundService.init();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _currentVersion = info.version);
    } catch (_) {
      // Version unavailable on some platforms in test / desktop environments.
      // The label shows '…' until the value is set.
    }
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  // -------------------------------------------------------------------------
  // Install flow (UPDATE-011 failure recovery)
  // -------------------------------------------------------------------------

  /// Passes [installerPath] to the platform installer-launch service.
  ///
  /// First shows [InstallerConfirmationDialog] (non-dismissable) to inform
  /// the user that the app will close.  If the user cancels, the method
  /// returns without launching the installer.
  ///
  /// On confirmation, delegates to the launch service, logs the outcome,
  /// and shows [UpdateInstallFailureDialog] on failure.
  Future<void> _doInstall(String installerPath) async {
    // FEAT-003: Offer the user a chance to back up before the update installs.
    // PreUpdateBackupDialog returns true whether they backed up or skipped,
    // and false if they explicitly cancelled the update.
    if (widget.churchId != 0) {
      final database = ref.read(db.databaseProvider);
      final proceed = await PreUpdateBackupDialog.show(
        context,
        churchId: widget.churchId,
        database: database,
      );
      if (!mounted || proceed != true) return;
    }

    // Show pre-install confirmation (AC5 — UPDATE-007).
    final confirmed =
        await (widget.confirmInstall ?? InstallerConfirmationDialog.show)(
          context,
        );
    if (!mounted || confirmed != true) return;

    final result = await widget.launchService.launch(installerPath);

    // Log the outcome regardless of success or failure.
    widget.activityLog.logInstallerLaunch(
      success: result.isSuccess,
      error: result.error,
    );

    if (result.isError && mounted) {
      await UpdateInstallFailureDialog.show(
        context,
        errorDetail: result.error,
        apkPath: installerPath,
      );
    } else if (result.hint != null && mounted) {
      // Linux (and any future platform) where the user must take a follow-up
      // action after extraction (AC3 / AC6 — UPDATE-007).
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Update Extracted'),
          content: Text(result.hint!),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Download + install flow (UPDATE-006)
  // -------------------------------------------------------------------------

  /// Orchestrates the full download-and-install flow.
  ///
  /// On **Web**: opens [UpdateErrorMessages.fallbackUrl] in a browser tab
  /// (browsers handle downloads natively; no installer streaming is needed).
  ///
  /// On **native platforms**:
  /// 1. Shows [UpdateDownloadProgressDialog] with a cancel option.
  /// 2. Streams the installer from the manifest URL via
  ///    [UpdateDownloadService.download], reporting progress.
  /// 3. Verifies the SHA-256 checksum.
  /// 4. On success, dismisses the dialog and calls [_doInstall] with the
  ///    downloaded file path.
  /// 5. On cancellation, dismisses the dialog silently.
  /// 6. On any other error, dismisses the dialog and shows a [SnackBar] with
  ///    a "Try Again" action.
  Future<void> _onDownloadUpdate() async {
    final manifest = _manifest;
    if (manifest == null) return;

    // FEAT-002: Proactively check install-unknown-apps permission on Android
    // before starting the download.  This prevents the user waiting for a large
    // download to complete only to discover at install time that the permission
    // is missing.  The check is a no-op on all non-Android platforms.
    if (!kIsWeb && Platform.isAndroid) {
      final hasPermission = await ensureInstallPermissionGranted(context);
      if (!mounted || !hasPermission) return;
    }

    // Web: no streaming installer — open GitHub Releases in browser tab.
    if (kIsWeb) {
      final launched = await launchUrl(
        Uri.parse(UpdateErrorMessages.fallbackUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open browser. '
              'Visit: ${UpdateErrorMessages.fallbackUrl}',
            ),
          ),
        );
      }
      return;
    }

    // FEAT-008: Request POST_NOTIFICATIONS permission on Android 13+ before
    // starting the foreground service.  The download proceeds even if denied —
    // the notification is just suppressed.  Never block the download on this.
    if (!kIsWeb && Platform.isAndroid) {
      final notifStatus = await Permission.notification.status;
      if (!notifStatus.isGranted) {
        await Permission.notification.request();
      }
    }

    // FEAT-006: clear any previous paused result — this is a fresh download.
    setState(() => _pausedResult = null);

    final cancelToken = CancelToken();
    final pauseToken = PauseToken(); // FEAT-006
    final progressNotifier = ValueNotifier<double>(0.0);
    var dialogShown = false;
    var dialogPopped = false;

    void popDialog() {
      if (dialogShown && !dialogPopped && mounted) {
        dialogPopped = true;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    try {
      // FEAT-008: start the Android Foreground Service to anchor the process
      // against backgrounding.  The download itself stays in the main isolate.
      // This is a no-op on Windows, Linux, and all other non-Android platforms.
      // start() is inside the try block so that ForegroundServiceStartException
      // is caught below and surfaced as a snackbar rather than escaping as an
      // unhandled async exception with no user-facing feedback.
      await DownloadForegroundService.start(cancelToken: cancelToken);
      // start() is async — guard against widget disposal before using context.
      if (!mounted) return;

      // Show the progress dialog.  Fire-and-forget: the dialog is dismissed
      // imperatively via Navigator.pop rather than by awaiting this future.
      dialogShown = true;
      // ignore: unawaited_futures
      UpdateDownloadProgressDialog.show(
        context,
        progress: progressNotifier,
        onCancel: () {
          cancelToken.cancel();
          popDialog();
        },
        // FEAT-006: Pause button — only shown when the server confirmed it
        // supports range requests (Accept-Ranges: bytes).  Never offer a
        // feature that silently degrades on the user.
        onPause: _supportsResume ? () => pauseToken.pause() : null,
      );

      final destDir =
          await (widget.destDirResolver ?? _resolveDownloadDirectory)();
      final service = widget.downloadService ?? UpdateDownloadService();
      final result = await service.download(
        manifest: manifest,
        destDir: destDir,
        onProgress: (p) {
          progressNotifier.value = p;
          // FEAT-008: update the foreground service notification.
          // DownloadForegroundService throttles internally (2 s or 5% delta)
          // so this is safe to call on every chunk.
          DownloadForegroundService.updateProgress(p);
        },
        cancelToken: cancelToken,
        pauseToken: pauseToken, // FEAT-006
      );

      popDialog();

      if (!mounted) return;

      if (result.isSuccess) {
        await _doInstall(result.filePath!);
      } else if (result.isPaused) {
        // FEAT-006: download was paused — store the partial result so the
        // "Resume Download" button appears in the card UI.
        setState(() => _pausedResult = result);
      } else if (result.errorType != UpdateErrorType.downloadCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              UpdateErrorMessages.messageFor(
                result.errorType ?? UpdateErrorType.downloadError,
              ),
            ),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _onDownloadUpdate,
            ),
          ),
        );
      }
    } catch (e) {
      // popDialog() is safe even if the dialog was never shown (it checks
      // dialogShown, dialogPopped, and mounted before acting).
      popDialog();
      // Surface foreground-service start failures as a visible snackbar.
      // Other exceptions (e.g. from download or destDir resolution) are
      // swallowed here; they will already have been logged by the service.
      if (e is ForegroundServiceStartException && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not start the background download service. '
              'Try again or restart the app.',
            ),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _onDownloadUpdate,
            ),
          ),
        );
      }
    } finally {
      // FEAT-008: always stop the foreground service, whatever the outcome
      // (success, cancel, pause, error, or unmount after start()).
      // No-op on non-Android platforms.
      await DownloadForegroundService.stop();
      // Dispose the notifier here — in finally — so it is always released
      // regardless of exit path: normal completion, exception, or the
      // if (!mounted) return inside the try block.  Deferring to the next
      // frame keeps the dispose after any in-flight dialog rebuild.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => progressNotifier.dispose(),
      );
    }
  }

  /// Returns the best writable directory for the downloaded APK.
  ///
  /// On Android the app's external-storage directory (e.g.
  /// `/storage/emulated/0/Android/data/com.church.church_analytics/files`)
  /// is used when available. Unlike the internal cache directory, this path
  /// is accessible to the user via the Files app, so they can manually
  /// install the APK if automatic installation fails (Issue 6 — 6.3).
  ///
  /// On every other platform, or when external storage is not available, the
  /// system temporary directory is used as the fallback.
  static Future<Directory> _resolveDownloadDirectory() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final external = await getExternalStorageDirectory();
        if (external != null) return external;
      } catch (_) {
        // Ignore — fall through to temp.
      }
    }
    return getTemporaryDirectory();
  }

  // -------------------------------------------------------------------------
  // Resume download flow (FEAT-006)
  // -------------------------------------------------------------------------

  /// Resumes a previously paused download.
  ///
  /// Issues a `Range: bytes=N-` HTTP request for the remaining bytes and
  /// appends them to the partial file left by the paused download.  Progress
  /// is initialised from [_pausedResult.bytesReceived] so the progress bar
  /// starts from the correct offset rather than zero.
  ///
  /// On success, clears [_pausedResult] and calls [_doInstall].
  /// On a new pause, updates [_pausedResult] with the latest offset.
  /// On cancel or error, behaves identically to [_onDownloadUpdate].
  Future<void> _onResumeDownload() async {
    final paused = _pausedResult;
    final manifest = _manifest;
    if (paused == null || manifest == null) return;

    // FEAT-002: Re-check install permission before resuming — the permission
    // may have been revoked while the download was paused (e.g. app restart,
    // OS settings change).  Mirrors the check in _onDownloadUpdate so the
    // user is never surprised by a permission failure at install time.
    if (!kIsWeb && Platform.isAndroid) {
      final hasPermission = await ensureInstallPermissionGranted(context);
      if (!mounted || !hasPermission) return;
    }

    final cancelToken = CancelToken();
    final pauseToken = PauseToken(); // fresh token for this segment

    // Seed the progress bar with the already-downloaded fraction so it does
    // not jump from 0% to the current offset on the first chunk.
    // paused.bytesReceived is the bytes on disk; we don't know the total here
    // so use a conservative 5% floor to show the bar isn't empty.  The
    // download service will report accurate fractions once the 206
    // Content-Length is known.
    final seedFraction = () {
      final bytes = paused.bytesReceived;
      if (bytes != null && bytes > 0) return 0.05;
      return 0.0;
    }();
    final progressNotifier = ValueNotifier<double>(seedFraction);
    var dialogShown = false;
    var dialogPopped = false;

    void popDialog() {
      if (dialogShown && !dialogPopped && mounted) {
        dialogPopped = true;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    try {
      // FEAT-008: start the foreground service INSIDE the try block so that
      // ForegroundServiceStartException is caught below and surfaced as a
      // snackbar.  Mirrors the pattern in _onDownloadUpdate.
      await DownloadForegroundService.start(cancelToken: cancelToken);
      // start() is async — guard against widget disposal before using context.
      if (!mounted) return;

      // Show the progress dialog only after the service has started
      // successfully.  Fire-and-forget: dismissed imperatively via popDialog().
      dialogShown = true;
      // ignore: unawaited_futures
      UpdateDownloadProgressDialog.show(
        context,
        progress: progressNotifier,
        onCancel: () {
          cancelToken.cancel();
          popDialog();
        },
        // Gate Pause on server capability, same as the initial download.
        onPause: _supportsResume ? () => pauseToken.pause() : null,
      );

      final service = widget.downloadService ?? UpdateDownloadService();
      final result = await service.resume(
        manifest: manifest,
        partialFilePath: paused.partialFilePath!,
        onProgress: (p) {
          progressNotifier.value = p;
          // FEAT-008: mirror progress to the foreground notification.
          DownloadForegroundService.updateProgress(p);
        },
        cancelToken: cancelToken,
        pauseToken: pauseToken,
      );

      popDialog();

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() => _pausedResult = null);
        await _doInstall(result.filePath!);
      } else if (result.isPaused) {
        setState(() => _pausedResult = result);
      } else if (result.errorType == UpdateErrorType.downloadCancelled) {
        // FEAT-006 fix: cancelling a resumed download leaves the service in a
        // terminal state — the partial file has been deleted.  Clear
        // _pausedResult so the "Resume Download" button disappears and does not
        // point at a dead file path.  See field comment at line 139 and
        // about_updates_card.dart#L139 in the original report.
        setState(() => _pausedResult = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              UpdateErrorMessages.messageFor(
                result.errorType ?? UpdateErrorType.downloadError,
              ),
            ),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _onResumeDownload,
            ),
          ),
        );
      }
    } catch (e) {
      // popDialog() is safe even if the dialog was never shown (it checks
      // dialogShown, dialogPopped, and mounted before acting).
      popDialog();
      // Surface foreground-service start failures as a visible snackbar.
      if (e is ForegroundServiceStartException && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not start the background download service. '
              'Try again or restart the app.',
            ),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _onResumeDownload,
            ),
          ),
        );
      }
    } finally {
      // FEAT-008: always stop the foreground service on completion/error/cancel.
      await DownloadForegroundService.stop();
      // Dispose the notifier here — in finally — so it is always released
      // regardless of exit path: normal completion, exception, or the
      // if (!mounted) return inside the try block.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => progressNotifier.dispose(),
      );
    }
  }

  Future<void> _checkForUpdates() async {
    if (_state == _CheckState.checking) return;

    // Force a fresh network fetch even if a previous result is cached.
    ref.read(updateServiceProvider).resetCache();

    setState(() => _state = _CheckState.checking);

    final result = await ref.read(updateServiceProvider).checkForUpdate();

    if (!mounted) return;

    setState(() {
      _lastChecked = DateTime.now();
      if (result.isError) {
        _state = _CheckState.error;
        _errorMessage = result.error;
        _errorType = result.errorType;
      } else if (result.isUpdateAvailable) {
        _state = _CheckState.updateAvailable;
        _latestVersion = result.latestVersion;
        _manifest = result.manifest;
      } else {
        _state = _CheckState.upToDate;
        _latestVersion = result.latestVersion;
      }
    });

    // Accept-Ranges pre-validation (FEAT-006): issue a HEAD request to the
    // download URL and check for `Accept-Ranges: bytes` in the response
    // headers.  Only show the Pause button when the server confirms it
    // supports range requests — never offer a feature that silently degrades.
    //
    // Uses service.checkAcceptRanges() which routes through the injected HTTP
    // client.  This means widget tests that inject a mock downloadService also
    // control the HEAD response — no real network call is made in tests.
    if (result.isUpdateAvailable && result.manifest != null) {
      _supportsResume = false; // reset before check
      try {
        final manifest = result.manifest!;
        final service = widget.downloadService ?? UpdateDownloadService();
        final assetUrl = service.resolveDownloadUrl(manifest);
        if (assetUrl != null && !kIsWeb) {
          final supportsRanges = await service.checkAcceptRanges(assetUrl);
          if (mounted) {
            setState(() => _supportsResume = supportsRanges);
          }
        }
      } catch (_) {
        // Fail-open: if the HEAD request fails, don't offer Pause.
        if (mounted) setState(() => _supportsResume = false);
      }
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChecking = _state == _CheckState.checking;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------------
            // Section heading with app icon
            // ----------------------------------------------------------------
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/icon.jpeg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Text('About & Updates', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),

            // ----------------------------------------------------------------
            // Current version row
            // ----------------------------------------------------------------
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Text('Current version:', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 8),
                Text(
                  _currentVersion.isEmpty ? '…' : _currentVersion,
                  key: const ValueKey('version_text'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ----------------------------------------------------------------
            // Inline result (hidden in idle state)
            // ----------------------------------------------------------------
            if (_state != _CheckState.idle) ...[
              _buildResultWidget(theme),
              const SizedBox(height: 12),
            ],

            // ----------------------------------------------------------------
            // Check for Updates button
            // ----------------------------------------------------------------
            FilledButton.icon(
              key: const ValueKey('check_updates_button'),
              onPressed: isChecking ? null : _checkForUpdates,
              icon: isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                        key: ValueKey('loading_spinner'),
                      ),
                    )
                  : const Icon(Icons.system_update),
              label: Text(isChecking ? 'Checking…' : 'Check for Updates'),
            ),

            // ----------------------------------------------------------------
            // Last-checked timestamp
            // ----------------------------------------------------------------
            if (_lastChecked != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last checked: ${_formatRelative(_lastChecked!)}',
                key: const ValueKey('last_checked_text'),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Result widget per state
  // -------------------------------------------------------------------------

  Widget _buildResultWidget(ThemeData theme) {
    switch (_state) {
      case _CheckState.checking:
        // Inline progress indicator (supplementary to the button spinner).
        return Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('Checking for updates…', style: theme.textTheme.bodyMedium),
          ],
        );

      case _CheckState.upToDate:
        return Row(
          key: const ValueKey('up_to_date_result'),
          children: [
            Icon(
              Icons.check_circle_outline,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _latestVersion != null
                  ? 'You are up to date (v$_latestVersion)'
                  : 'You are up to date',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );

      case _CheckState.updateAvailable:
        return Column(
          key: const ValueKey('update_available_result'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.new_releases_outlined,
                  color: theme.colorScheme.tertiary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Update available: v$_latestVersion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                // Release notes dialog (UPDATE-005).
                OutlinedButton.icon(
                  key: const ValueKey('view_release_notes_button'),
                  onPressed: () => ReleaseNotesDialog.show(
                    context,
                    version: _latestVersion ?? '',
                    releaseNotes: _manifest?.releaseNotes ?? '',
                    onDownloadUpdate: _onDownloadUpdate,
                  ),
                  icon: const Icon(Icons.article_outlined, size: 16),
                  label: const Text('View Release Notes'),
                ),
                // FEAT-006: Resume button — only shown after a paused download.
                if (_pausedResult != null)
                  FilledButton.icon(
                    key: const ValueKey('resume_download_button'),
                    onPressed: _onResumeDownload,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Resume Download'),
                  ),
                // Full download (or restart after discarding a paused download).
                OutlinedButton.icon(
                  key: const ValueKey('download_update_button'),
                  // When a paused result exists, label as "Download Again" to
                  // make it clear this will start from scratch.
                  onPressed: _onDownloadUpdate,
                  icon: const Icon(Icons.download, size: 16),
                  label: Text(
                    _pausedResult != null
                        ? 'Download Again'
                        : 'Download Update',
                  ),
                ),
              ],
            ),
          ],
        );

      case _CheckState.error:
        return Column(
          key: const ValueKey('error_result'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _errorType != null
                            ? UpdateErrorMessages.messageFor(_errorType!)
                            : (_errorMessage ?? 'An unknown error occurred.'),
                        key: const ValueKey('error_message_text'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      if (kDebugMode && _errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Debug: $_errorMessage',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.7,
                            ),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  key: const ValueKey('retry_button'),
                  onPressed: _checkForUpdates,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
                TextButton.icon(
                  key: const ValueKey('open_github_releases_button'),
                  onPressed: () async {
                    final launched = await launchUrl(
                      Uri.parse(UpdateErrorMessages.fallbackUrl),
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not open browser. '
                            'Visit: ${UpdateErrorMessages.fallbackUrl}',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text(UpdateErrorMessages.fallbackLabel),
                ),
              ],
            ),
          ],
        );

      case _CheckState.idle:
        return const SizedBox.shrink();
    }
  }

  // -------------------------------------------------------------------------
  // Relative time formatter
  // -------------------------------------------------------------------------

  /// Formats [time] as a human-readable relative label.
  ///
  /// Examples: `"Just now"`, `"3 min ago"`, `"2 hr ago"`, `"1 day ago"`.
  String _formatRelative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    final days = diff.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }
}
