import 'package:flutter/material.dart';

import '../../database/app_database.dart' as db;
import '../../models/models.dart';
import '../../repositories/admin_user_repository.dart';
import '../../repositories/church_repository.dart';
import '../../repositories/weekly_record_repository.dart';
import '../../services/backup_service.dart';

// ---------------------------------------------------------------------------
// _DialogState
// ---------------------------------------------------------------------------

enum _DialogState { initial, backing, success, error }

// ---------------------------------------------------------------------------
// PreUpdateBackupDialog
// ---------------------------------------------------------------------------

/// Dialog shown before an update download starts (FEAT-003).
///
/// Gives the user three options:
/// - **Back Up Now** — runs [BackupService.createBackup] synchronously in the
///   dialog, shows progress, then on success shows the saved path and returns
///   `true`.
/// - **Skip & Update** — returns `true` immediately without creating a backup.
/// - **Cancel** — returns `false`; the caller should abort the update flow.
///
/// The dialog is non-dismissable (tapping outside does nothing) so the user
/// must make an explicit choice.
///
/// ## Usage
/// ```dart
/// final proceed = await PreUpdateBackupDialog.show(
///   context,
///   churchId: widget.churchId,
///   database: ref.read(db.databaseProvider),
/// );
/// if (proceed != true) return; // user cancelled — abort update
/// ```
class PreUpdateBackupDialog extends StatefulWidget {
  final int churchId;
  final db.AppDatabase database;

  const PreUpdateBackupDialog({
    super.key,
    required this.churchId,
    required this.database,
  });

  /// Convenience helper: shows the dialog and returns the user's choice.
  ///
  /// Returns `true` when the user chose to proceed (with or without backup),
  /// `false` when they cancelled.  Returns `null` if the dialog is dismissed
  /// unexpectedly.
  static Future<bool?> show(
    BuildContext context, {
    required int churchId,
    required db.AppDatabase database,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PreUpdateBackupDialog(
        churchId: churchId,
        database: database,
      ),
    );
  }

  @override
  State<PreUpdateBackupDialog> createState() => _PreUpdateBackupDialogState();
}

class _PreUpdateBackupDialogState extends State<PreUpdateBackupDialog> {
  _DialogState _dialogState = _DialogState.initial;
  String? _savedPath;
  String? _errorMessage;

  // -------------------------------------------------------------------------
  // Backup logic
  // -------------------------------------------------------------------------

  Future<void> _runBackup() async {
    setState(() {
      _dialogState = _DialogState.backing;
      _savedPath = null;
      _errorMessage = null;
    });

    try {
      final churchRepo = ChurchRepository(widget.database);
      final adminRepo = AdminUserRepository(widget.database);
      final recordRepo = WeeklyRecordRepository(widget.database);

      final church = await churchRepo.getChurchById(widget.churchId);
      final churches = church != null ? [church] : <Church>[];
      final admins = await adminRepo.getUsersByChurch(widget.churchId);
      final records = await recordRepo.getRecordsByChurch(widget.churchId);

      final service = BackupService();
      final result = await service.createBackup(
        churches: churches,
        admins: admins,
        records: records,
      );

      if (!mounted) return;

      if (result.success && result.filePath != null) {
        setState(() {
          _dialogState = _DialogState.success;
          _savedPath = result.filePath;
        });
      } else {
        setState(() {
          _dialogState = _DialogState.error;
          _errorMessage = result.error ?? 'Backup failed.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dialogState = _DialogState.error;
        _errorMessage = 'Backup failed: $e';
      });
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      key: const ValueKey('pre_update_backup_dialog'),
      title: const Text('Back Up Before Updating?'),
      content: _buildContent(theme),
      actions: _buildActions(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    switch (_dialogState) {
      case _DialogState.initial:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'It is recommended to back up your data before installing an update.',
            ),
            SizedBox(height: 8),
            Text(
              'If anything goes wrong during the update, you can restore from the backup.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        );

      case _DialogState.backing:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating backup…'),
            SizedBox(height: 8),
          ],
        );

      case _DialogState.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Backup saved successfully.'),
              ],
            ),
            if (_savedPath != null) ...[
              const SizedBox(height: 8),
              Text(
                _savedPath!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        );

      case _DialogState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage ?? 'Backup failed.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'You can skip the backup and proceed with the update, '
              'or cancel to back up manually first.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        );
    }
  }

  List<Widget> _buildActions(ThemeData theme) {
    switch (_dialogState) {
      case _DialogState.initial:
        return [
          TextButton(
            key: const ValueKey('backup_dialog_cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const ValueKey('backup_dialog_skip'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Skip & Update'),
          ),
          FilledButton.icon(
            key: const ValueKey('backup_dialog_back_up_now'),
            onPressed: _runBackup,
            icon: const Icon(Icons.backup_outlined, size: 16),
            label: const Text('Back Up Now'),
          ),
        ];

      case _DialogState.backing:
        // Disable all actions while backup is in progress.
        return [
          TextButton(
            onPressed: null,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: null,
            child: const Text('Skip & Update'),
          ),
          FilledButton(
            onPressed: null,
            child: const Text('Back Up Now'),
          ),
        ];

      case _DialogState.success:
        return [
          FilledButton(
            key: const ValueKey('backup_dialog_continue'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue with Update'),
          ),
        ];

      case _DialogState.error:
        return [
          TextButton(
            key: const ValueKey('backup_dialog_cancel_after_error'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const ValueKey('backup_dialog_retry'),
            onPressed: _runBackup,
            child: const Text('Try Again'),
          ),
          FilledButton(
            key: const ValueKey('backup_dialog_skip_after_error'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Skip & Update'),
          ),
        ];
    }
  }
}
