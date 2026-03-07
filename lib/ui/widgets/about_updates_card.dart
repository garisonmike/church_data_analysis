import 'dart:io' show Directory;

import 'package:church_analytics/models/update_error_messages.dart';
import 'package:church_analytics/models/update_error_type.dart';
import 'package:church_analytics/models/update_manifest.dart';
import 'package:church_analytics/services/activity_log_service.dart';
import 'package:church_analytics/services/installer_launch_service.dart';
import 'package:church_analytics/services/update_download_service.dart';
import 'package:church_analytics/services/update_service.dart';
import 'package:church_analytics/ui/widgets/installer_confirmation_dialog.dart';
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
  /// Defaults to [NoOpInstallerLaunchService], which always returns a failure
  /// so the recovery path (UPDATE-011) is exercised until UPDATE-007 provides
  /// real platform implementations.
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

  const AboutUpdatesCard({
    super.key,
    this.launchService = const NoOpInstallerLaunchService(),
    this.activityLog = const NoOpActivityLogService(),
    this.downloadService,
    this.destDirResolver,
    this.confirmInstall,
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

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
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
      await UpdateInstallFailureDialog.show(context, errorDetail: result.error);
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

    final cancelToken = CancelToken();
    final progressNotifier = ValueNotifier<double>(0.0);
    var dialogPopped = false;

    void popDialog() {
      if (!dialogPopped && mounted) {
        dialogPopped = true;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    // Show the progress dialog.  Fire-and-forget: the dialog is dismissed
    // imperatively via Navigator.pop rather than by awaiting this future.
    // ignore: unawaited_futures
    UpdateDownloadProgressDialog.show(
      context,
      progress: progressNotifier,
      onCancel: () {
        cancelToken.cancel();
        popDialog();
      },
    );

    try {
      final destDir = await (widget.destDirResolver ?? getTemporaryDirectory)();
      final service = widget.downloadService ?? UpdateDownloadService();
      final result = await service.download(
        manifest: manifest,
        destDir: destDir,
        onProgress: (p) => progressNotifier.value = p,
        cancelToken: cancelToken,
      );

      popDialog();
      progressNotifier.dispose();

      if (!mounted) return;

      if (result.isSuccess) {
        await _doInstall(result.filePath!);
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
      popDialog();
      progressNotifier.dispose();
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
            // Section heading
            // ----------------------------------------------------------------
            Text('About & Updates', style: theme.textTheme.titleLarge),
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
                // Initiates full download + verify + install flow (UPDATE-006).
                FilledButton.icon(
                  key: const ValueKey('download_update_button'),
                  onPressed: _onDownloadUpdate,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download Update'),
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
