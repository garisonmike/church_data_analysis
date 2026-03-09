import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/backup_service.dart';
import 'package:church_analytics/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// _RestoreState
// ---------------------------------------------------------------------------

enum _RestoreState { idle, validating, restoring, success, error }

// ---------------------------------------------------------------------------
// FirstLaunchBackupImportScreen
// ---------------------------------------------------------------------------

/// Allows a user to restore data from a `.json` backup file before creating
/// any account.
///
/// This screen is reached from [ChurchSelectionScreen] when no churches exist
/// (the first-launch path).  It satisfies:
///
/// - **Task 7.2** — backup import screen with file selection and data restore.
/// - **Task 7.3** — backup format validation; corrupted files are rejected with
///   a clear error message so no bad data ever reaches the database.
///
/// ## Restore flow
/// 1. User picks a `.json` file via the platform file picker.
/// 2. The file is validated with [BackupService.validateBackup].
/// 3. [BackupService.readBackup] parses the file into [BackupData].
/// 4. Churches are inserted; old ID → new ID mapping is built.
/// 5. Admin users are inserted with remapped `churchId`.
/// 6. Weekly records are inserted with remapped `churchId` and
///    `createdByAdminId`.
/// 7. On success the user is routed to `/` (StartupGate picks up from there).
class FirstLaunchBackupImportScreen extends ConsumerStatefulWidget {
  const FirstLaunchBackupImportScreen({super.key});

  @override
  ConsumerState<FirstLaunchBackupImportScreen> createState() =>
      _FirstLaunchBackupImportScreenState();
}

class _FirstLaunchBackupImportScreenState
    extends ConsumerState<FirstLaunchBackupImportScreen> {
  _RestoreState _state = _RestoreState.idle;
  PlatformFileResult? _selectedFile;
  BackupMetadata? _previewMetadata;
  String? _errorMessage;

  final BackupService _backupService = BackupService();
  final FileService _fileService = FileService();

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _pickBackupFile() async {
    setState(() {
      _state = _RestoreState.idle;
      _selectedFile = null;
      _previewMetadata = null;
      _errorMessage = null;
    });

    final file = await _fileService.pickFile(allowedExtensions: ['json']);
    if (file == null) return;

    setState(() {
      _state = _RestoreState.validating;
      _selectedFile = file;
    });

    // Validate the file format before showing the "Restore" button.
    final isValid = await _backupService.validateBackup(file);
    if (!isValid) {
      if (!mounted) return;
      setState(() {
        _state = _RestoreState.error;
        _errorMessage =
            'The selected file is not a valid Church Analytics backup.\n\n'
            'Please choose a .json file that was exported from Church '
            'Analytics → Reports → Backup.';
        _selectedFile = null;
      });
      return;
    }

    // Parse preview metadata to show the user what they are about to restore.
    final backupData = await _backupService.readBackup(file);
    if (backupData == null) {
      if (!mounted) return;
      setState(() {
        _state = _RestoreState.error;
        _errorMessage = 'Could not read the backup file. It may be corrupt.';
        _selectedFile = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _state = _RestoreState.idle;
      _previewMetadata = backupData.metadata;
    });
  }

  Future<void> _restoreBackup() async {
    final file = _selectedFile;
    if (file == null) return;

    setState(() {
      _state = _RestoreState.restoring;
      _errorMessage = null;
    });

    try {
      // Re-validate before touching the database.
      final isValid = await _backupService.validateBackup(file);
      if (!isValid) {
        setState(() {
          _state = _RestoreState.error;
          _errorMessage =
              'Backup validation failed. The file may have been modified or '
              'is corrupt.';
        });
        return;
      }

      final backupData = await _backupService.readBackup(file);
      if (backupData == null) {
        setState(() {
          _state = _RestoreState.error;
          _errorMessage = 'Could not read the backup file. It may be corrupt.';
        });
        return;
      }

      final database = ref.read(db.databaseProvider);
      final churchRepo = ChurchRepository(database);
      final adminRepo = AdminUserRepository(database);
      final recordRepo = WeeklyRecordRepository(database);

      // ------------------------------------------------------------------
      // 1. Restore churches. Track old-ID → new-ID for FK remapping.
      // ------------------------------------------------------------------
      final Map<int, int> churchIdMap = {};
      for (final churchJson in backupData.churches) {
        final church = _backupService.churchFromJson(churchJson);
        final oldId = church.id;
        final newId = await churchRepo.createChurch(church);
        if (oldId != null) churchIdMap[oldId] = newId;
      }

      // ------------------------------------------------------------------
      // 2. Restore admin users. Remap churchId; track old-ID → new-ID.
      // ------------------------------------------------------------------
      final Map<int, int> adminIdMap = {};
      for (final adminJson in backupData.adminUsers) {
        final admin = _backupService.adminUserFromJson(adminJson);
        final oldId = admin.id;
        final remappedChurchId = churchIdMap[admin.churchId] ?? admin.churchId;
        final remappedAdmin = AdminUser(
          username: admin.username,
          fullName: admin.fullName,
          email: admin.email,
          churchId: remappedChurchId,
          isActive: admin.isActive,
          createdAt: admin.createdAt,
          lastLoginAt: admin.lastLoginAt,
        );
        final newId = await adminRepo.createUser(remappedAdmin);
        if (oldId != null) adminIdMap[oldId] = newId;
      }

      // ------------------------------------------------------------------
      // 3. Restore weekly records. Remap churchId and createdByAdminId.
      // ------------------------------------------------------------------
      for (final recordJson in backupData.weeklyRecords) {
        final record = _backupService.weeklyRecordFromJson(recordJson);
        final remappedChurchId =
            churchIdMap[record.churchId] ?? record.churchId;
        final remappedAdminId = record.createdByAdminId != null
            ? (adminIdMap[record.createdByAdminId!] ?? record.createdByAdminId)
            : null;
        final remappedRecord = WeeklyRecord(
          churchId: remappedChurchId,
          createdByAdminId: remappedAdminId,
          weekStartDate: record.weekStartDate,
          men: record.men,
          women: record.women,
          youth: record.youth,
          children: record.children,
          sundayHomeChurch: record.sundayHomeChurch,
          tithe: record.tithe,
          offerings: record.offerings,
          emergencyCollection: record.emergencyCollection,
          plannedCollection: record.plannedCollection,
          createdAt: record.createdAt,
          updatedAt: record.updatedAt,
        );
        await recordRepo.createRecord(remappedRecord);
      }

      if (!mounted) return;
      setState(() => _state = _RestoreState.success);

      // Brief pause so the user can see the success message, then continue.
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _RestoreState.error;
        _errorMessage = 'Restore failed: $e\n\nNo data was changed.';
      });
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Backup'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header icon + description
              Icon(
                Icons.restore_page_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Restore from Backup',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a .json backup file previously exported from '
                'Church Analytics to restore your churches, admin accounts, '
                'and weekly records.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // File picker button
              OutlinedButton.icon(
                key: const ValueKey('pick_backup_file_button'),
                onPressed: _state == _RestoreState.restoring
                    ? null
                    : _pickBackupFile,
                icon: const Icon(Icons.file_open_outlined),
                label: Text(
                  _selectedFile == null
                      ? 'Choose Backup File'
                      : 'Choose a Different File',
                ),
              ),

              // File validation state indicator
              if (_state == _RestoreState.validating) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Validating backup file…'),
                  ],
                ),
              ],

              // Backup preview card (shown after a valid file is selected)
              if (_previewMetadata != null && _selectedFile != null) ...[
                const SizedBox(height: 16),
                _BackupPreviewCard(
                  filename: _selectedFile!.name,
                  metadata: _previewMetadata!,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const ValueKey('restore_backup_button'),
                  onPressed: _state == _RestoreState.restoring
                      ? null
                      : _restoreBackup,
                  icon: _state == _RestoreState.restoring
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.restore),
                  label: Text(
                    _state == _RestoreState.restoring
                        ? 'Restoring…'
                        : 'Restore This Backup',
                  ),
                ),
              ],

              // Success banner
              if (_state == _RestoreState.success) ...[
                const SizedBox(height: 24),
                _StatusCard(
                  key: const ValueKey('restore_success_card'),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  title: 'Restore Complete',
                  body:
                      'Your data has been restored successfully. '
                      'Continuing to the app…',
                ),
              ],

              // Error banner
              if (_state == _RestoreState.error && _errorMessage != null) ...[
                const SizedBox(height: 24),
                _StatusCard(
                  key: const ValueKey('restore_error_card'),
                  icon: Icons.error_outline,
                  color: theme.colorScheme.error,
                  title: 'Restore Failed',
                  body: _errorMessage!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BackupPreviewCard
// ---------------------------------------------------------------------------

/// Displays metadata from the selected backup so the user can confirm they
/// are restoring the correct file before committing.
class _BackupPreviewCard extends StatelessWidget {
  const _BackupPreviewCard({required this.filename, required this.metadata});

  final String filename;
  final BackupMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey('backup_preview_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    filename,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _MetaRow(
              label: 'Backup date',
              value: _formatDate(metadata.createdAt),
            ),
            const SizedBox(height: 4),
            _MetaRow(label: 'App version', value: metadata.appVersion),
            const SizedBox(height: 4),
            _MetaRow(label: 'Churches', value: metadata.churchCount.toString()),
            const SizedBox(height: 4),
            _MetaRow(
              label: 'Admin accounts',
              value: metadata.adminCount.toString(),
            ),
            const SizedBox(height: 4),
            _MetaRow(
              label: 'Weekly records',
              value: metadata.recordCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _StatusCard
// ---------------------------------------------------------------------------

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
