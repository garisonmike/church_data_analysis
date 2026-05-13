import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../services/log_service.dart';
import '../../services/settings_service.dart';
import '../../services/weekly_records_provider.dart';

/// Screen for entering or editing a monthly board meeting attendance record.
class BoardMeetingEntryScreen extends ConsumerStatefulWidget {
  final BoardMeetingRecord? existing;
  const BoardMeetingEntryScreen({super.key, this.existing});

  @override
  ConsumerState<BoardMeetingEntryScreen> createState() =>
      _BoardMeetingEntryScreenState();
}

class _BoardMeetingEntryScreenState
    extends ConsumerState<BoardMeetingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _meetingDate;
  late TextEditingController _actual;
  late TextEditingController _expected;
  late TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _meetingDate = e?.meetingDate ?? DateTime.now();
    _actual = TextEditingController(
        text: e?.actualAttendance.toString() ?? '');
    _expected = TextEditingController(
        text: e?.expectedAttendance.toString() ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _actual.dispose(); _expected.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _meetingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _meetingDate = picked);
  }

  Future<void> _prefillExpected() async {
    // Auto-fill expected from church settings boardMemberCount
    final settings = ref.read(appSettingsProvider);
    final cid = settings.selectedChurchId;
    if (cid == null) return;
    final repo = ref.read(churchRepositoryProvider);
    final church = await repo.getChurchById(cid);
    if (church != null && _expected.text.isEmpty) {
      setState(() => _expected.text = church.boardMemberCount.toString());
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final settings = ref.read(appSettingsProvider);
      final churchId = settings.selectedChurchId;
      if (churchId == null) throw Exception('No church selected');

      final record = BoardMeetingRecord(
        id: widget.existing?.id,
        churchId: churchId,
        meetingDate: _meetingDate,
        year: _meetingDate.year,
        month: _meetingDate.month,
        actualAttendance: int.parse(_actual.text),
        expectedAttendance: int.parse(_expected.text),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final error = record.validate();
      if (error != null) throw Exception(error);

      final repo = ref.read(boardMeetingRepositoryProvider);
      if (widget.existing == null) {
        await repo.create(record);
      } else {
        await repo.update(record);
      }

      ref.invalidate(boardMeetingRecordsProvider(churchId));
      LogService.info('BoardMeetingEntry',
          'Saved board meeting record: ${record.displayLabel}');

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      LogService.error('BoardMeetingEntry', 'Save failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // FEAT-015 fix: delete this record from the edit screen.
  Future<void> _delete() async {
    if (widget.existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
            'Permanently delete this board meeting record? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      final settings = ref.read(appSettingsProvider);
      final churchId = settings.selectedChurchId;
      final repo = ref.read(boardMeetingRepositoryProvider);
      await repo.deleteRecord(widget.existing!.id!);
      if (churchId != null) ref.invalidate(boardMeetingRecordsProvider(churchId));
      LogService.info('BoardMeetingEntry',
          'Deleted board meeting record id=${widget.existing!.id}');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      LogService.error('BoardMeetingEntry', 'Delete failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final dateFmt = DateFormat('MMMM yyyy');

    // Auto-fill expected on first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillExpected());

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Board Meeting' : 'New Board Meeting'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            // FEAT-015 fix: delete only shown when editing an existing record
            if (widget.existing != null)
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                tooltip: 'Delete record',
                onPressed: _delete,
              ),
            TextButton(onPressed: _save, child: const Text('Save')),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting date
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Meeting Date'),
                  subtitle: Text(dateFmt.format(_meetingDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 16),

              // Attendance section
              Text('Attendance', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _actual,
                    decoration: const InputDecoration(
                        labelText: 'Actual Attendance *',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 0) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _expected,
                    decoration: const InputDecoration(
                        labelText: 'Expected (Board Size) *',
                        helperText: 'From church settings',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Live rate display
              ValueListenableBuilder(
                valueListenable: _actual,
                builder: (_, __, ___) => ValueListenableBuilder(
                  valueListenable: _expected,
                  builder: (_, __, ___) {
                    final actual = int.tryParse(_actual.text) ?? 0;
                    final expected = int.tryParse(_expected.text) ?? 0;
                    final rate = expected > 0
                        ? (actual / expected * 100).toStringAsFixed(1)
                        : '—';
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        const Icon(Icons.percent, size: 18),
                        const SizedBox(width: 8),
                        Text('Attendance rate: $rate%',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder()),
                maxLines: 3,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(isEdit ? 'Update Record' : 'Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
