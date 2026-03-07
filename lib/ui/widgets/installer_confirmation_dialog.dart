import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// InstallerConfirmationDialog
// ---------------------------------------------------------------------------

/// Non-dismissable confirmation dialog shown before the app hands off to the
/// OS installer (UPDATE-007).
///
/// Informs the user that the app will close to complete the update and
/// prompts them to save unsaved work.  Returns `true` when the user confirms
/// and `false` (or `null`) when they cancel.
///
/// ## Usage
/// ```dart
/// final confirmed = await InstallerConfirmationDialog.show(context);
/// if (confirmed != true) return; // User cancelled
/// // Proceed with install…
/// ```
///
/// ## Dismissal
/// `barrierDismissible` is `false` — the dialog can only be closed via the
/// **Cancel** or **Install Now** buttons.
class InstallerConfirmationDialog extends StatelessWidget {
  // -------------------------------------------------------------------------
  // Static helper
  // -------------------------------------------------------------------------

  /// Shows the dialog and returns `true` when the user taps **Install Now**,
  /// or `false` / `null` when they tap **Cancel** or the dialog is otherwise
  /// dismissed.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const InstallerConfirmationDialog._(),
    );
  }

  const InstallerConfirmationDialog._();

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      key: const ValueKey('installer_confirmation_dialog'),
      title: const Text('Install Update'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('The app will close to complete the update.'),
          const SizedBox(height: 12),
          Text(
            'Save any unsaved work before continuing.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const ValueKey('installer_confirm_cancel_button'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('installer_confirm_proceed_button'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Install Now'),
        ),
      ],
    );
  }
}
