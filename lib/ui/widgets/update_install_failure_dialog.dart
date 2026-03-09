import 'package:church_analytics/models/update_error_messages.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays a non-dismissable recovery dialog when an installer launch fails.
///
/// The dialog informs the user that automatic installation did not succeed,
/// provides a manual-install instruction, and offers a direct link to the
/// GitHub Releases page as the fallback download source.
///
/// ## Usage
/// ```dart
/// final result = await launchService.launch(installerPath);
/// if (result.isError && mounted) {
///   await UpdateInstallFailureDialog.show(context, errorDetail: result.error);
///   activityLog.logInstallerLaunch(success: false, error: result.error);
/// }
/// ```
///
/// The dialog is dismissed only by an explicit user action ("Dismiss" or
/// "Open GitHub Releases"), never by tapping outside — matching the
/// UPDATE-007 requirement for a non-dismissable confirmation dialog.
class UpdateInstallFailureDialog extends StatelessWidget {
  /// Optional detail describing why the launch failed.
  ///
  /// When non-null this is shown as a secondary line below the main message.
  final String? errorDetail;

  /// Local filesystem path to the downloaded APK.
  ///
  /// When non-null, the dialog displays the exact path so the user can
  /// manually locate and install the file from a file manager or ADB.
  final String? apkPath;

  const UpdateInstallFailureDialog({super.key, this.errorDetail, this.apkPath});

  // -------------------------------------------------------------------------
  // Static helpers
  // -------------------------------------------------------------------------

  /// Shows the dialog as a modal and awaits user dismissal.
  static Future<void> show(
    BuildContext context, {
    String? errorDetail,
    String? apkPath,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateInstallFailureDialog(
        errorDetail: errorDetail,
        apkPath: apkPath,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.error_outline,
        color: theme.colorScheme.error,
        size: 36,
        key: const ValueKey('install_failure_icon'),
      ),
      title: const Text(
        'Installation Failed',
        key: ValueKey('install_failure_title'),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main error message from UpdateErrorMessages
            Text(
              key: const ValueKey('install_failure_message'),
              // Uses the centralised installError string so messaging is
              // consistent with all other update-flow error surfaces.
              'The automatic installer could not be launched on this device.',
              style: theme.textTheme.bodyMedium,
            ),

            // Optional technical detail (e.g. the raw exception message)
            if (errorDetail != null) ...[
              const SizedBox(height: 8),
              Text(
                key: const ValueKey('install_failure_detail'),
                errorDetail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // APK file path — shown when the download succeeded but the
            // automatic installer could not be launched.  Lets the user
            // find the file manually via a file manager or ADB.
            if (apkPath != null) ...[
              const SizedBox(height: 12),
              Container(
                key: const ValueKey('install_failure_apk_path'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APK downloaded to:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      key: const ValueKey('install_failure_apk_path_text'),
                      apkPath!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can install it manually from a file manager.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Manual install instructions
            Container(
              key: const ValueKey('manual_install_instructions'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To install manually:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._manualSteps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: theme.textTheme.bodySmall),
                          Expanded(
                            child: Text(step, style: theme.textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Dismiss without further action
        TextButton(
          key: const ValueKey('install_failure_dismiss_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),

        // Open GitHub Releases page
        FilledButton.icon(
          key: const ValueKey('install_failure_github_button'),
          onPressed: () async {
            final launched = await launchUrl(
              Uri.parse(UpdateErrorMessages.fallbackUrl),
              mode: LaunchMode.externalApplication,
            );
            if (context.mounted) {
              Navigator.of(context).pop();
              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Could not open browser. '
                      'Visit: ${UpdateErrorMessages.fallbackUrl}',
                    ),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text(UpdateErrorMessages.fallbackLabel),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Constants
  // -------------------------------------------------------------------------

  static const List<String> _manualSteps = [
    'Open GitHub Releases using the button below.',
    'Download the installer for your platform.',
    'Run the downloaded installer to complete the update.',
    'Restart the app after installation.',
  ];
}
