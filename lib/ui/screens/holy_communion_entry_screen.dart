import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../services/log_service.dart';
import '../../services/settings_service.dart';
import '../../services/weekly_records_provider.dart';

/// Entry screen for Holy Communion quarterly event.
/// Auto-loads all active home churches as rows for attendance entry.
class HolyCommunionEntryScreen extends ConsumerStatefulWidget {
  final HolyCommunionEvent? existing;
  const HolyCommunionEntryScreen({super.key, this.existing});

  @override
  ConsumerState<HolyCommunionEntryScreen> createState() =>
      _HolyCommunionEntryScreenState();
}

class _HolyCommunionEntryScreenState
    extends ConsumerState<HolyCommunionEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _eventDate;
  late int _year;
  late int _quarter;
  late TextEditingController _expectedKcc;
  late TextEditingController _notes;
  final Map<int, TextEditingController> _actualControllers = {};
  final Map<int, TextEditingController> _expectedHcControllers = {};
  List<HomeChurch> _homeChurches = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _eventDate = e?.eventDate ?? DateTime.now();
    _year = e?.year ?? DateTime.now().year;
    _quarter = e?.quarter ?? ((DateTime.now().month / 3).ceil());
    _expectedKcc = TextEditingController(
        text: e?.totalExpectedAtKcc.toString() ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _expectedKcc.dispose(); _notes.dispose();
    for (final c in _actualControllers.values) c.dispose();
    for (final c in _expectedHcControllers.values) c.dispose();
    super.dispose();
  }

  void _initRowControllers(List<HomeChurch> homeChurches) {
    if (_homeChurches.length == homeChurches.length) return;
    _homeChurches = homeChurches;
    for (final hc in homeChurches) {
      final existingRow = widget.existing?.attendance
          .firstWhere((r) => r.homeChurchId == hc.id, orElse: () =>
              HolyCommunionAttendanceRow(
                eventId: 0, homeChurchId: hc.id!, homeChurchName: hc.name,
                actualAttendance: 0, expectedAtHc: hc.expectedMembership));
      _actualControllers[hc.id!] = TextEditingController(
          text: existingRow?.actualAttendance.toString() ?? '0');
      _expectedHcControllers[hc.id!] = TextEditingController(
          text: existingRow?.expectedAtHc.toString() ??
              hc.expectedMembership.toString());
    }
    // Auto-fill KCC total from sum of HC expected if empty
    if (_expectedKcc.text.isEmpty) {
      final total = homeChurches.fold(0, (sum, hc) => sum + hc.expectedMembership);
      _expectedKcc.text = total.toString();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final settings = ref.read(appSettingsProvider);
      final churchId = settings.selectedChurchId;
      if (churchId == null) throw Exception('No church selected');

      final attendanceRows = _homeChurches.map((hc) =>
          HolyCommunionAttendanceRow(
            eventId: widget.existing?.id ?? 0,
            homeChurchId: hc.id!,
            homeChurchName: hc.name,
            actualAttendance:
                int.tryParse(_actualControllers[hc.id!]?.text ?? '0') ?? 0,
            expectedAtHc:
                int.tryParse(_expectedHcControllers[hc.id!]?.text ?? '0') ?? 0,
          )).toList();

      final event = HolyCommunionEvent(
        id: widget.existing?.id,
        churchId: churchId,
        eventDate: _eventDate,
        year: _year,
        quarter: _quarter,
        totalExpectedAtKcc: int.tryParse(_expectedKcc.text) ?? 0,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        attendance: attendanceRows,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final error = event.validate();
      if (error != null) throw Exception(error);

      final repo = ref.read(holyCommunionRepositoryProvider);
      int eventId;
      if (widget.existing == null) {
        eventId = await repo.createEvent(event);
      } else {
        await repo.updateEvent(event);
        eventId = event.id!;
      }
      await repo.upsertAttendanceRows(eventId, attendanceRows);
      ref.invalidate(holyCommunionEventsProvider(churchId));

      LogService.info('HolyCommunionEntry',
          'Saved HC event: Q$_quarter $_year, ${attendanceRows.length} HC rows');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      LogService.error('HolyCommunionEntry', 'Save failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final churchId = settings.selectedChurchId;
    final hcAsync = churchId != null
        ? ref.watch(homeChurchesProvider(churchId))
        : null;
    final dateFmt = DateFormat('d MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null
            ? 'Edit Holy Communion'
            : 'New Holy Communion Event'),
        actions: [
          if (_saving)
            const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Event header
            Text('Event Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _quarter,
                  decoration: const InputDecoration(
                      labelText: 'Quarter', border: OutlineInputBorder()),
                  items: [1, 2, 3, 4].map((q) =>
                      DropdownMenuItem(value: q, child: Text('Q$q'))).toList(),
                  onChanged: (v) => setState(() => _quarter = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _year,
                  decoration: const InputDecoration(
                      labelText: 'Year', border: OutlineInputBorder()),
                  items: List.generate(10, (i) => DateTime.now().year - 2 + i)
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) => setState(() => _year = v!),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Event Date'),
                subtitle: Text(dateFmt.format(_eventDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expectedKcc,
              decoration: const InputDecoration(
                  labelText: 'Total Expected at KCC',
                  helperText: 'Overall expected count for the whole church',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Per-HC attendance table
            Text('Attendance by Home Church',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (hcAsync == null)
              const Text('No church selected.')
            else
              hcAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading home churches: $e'),
                data: (hcs) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _initRowControllers(hcs));
                  if (hcs.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No home churches found. Add them in Church Settings → Home Churches.',
                          style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: hcs.map((hc) => _HcAttendanceRow(
                      homeChurch: hc,
                      actualController: _actualControllers[hc.id!] ??
                          TextEditingController(text: '0'),
                      expectedController: _expectedHcControllers[hc.id!] ??
                          TextEditingController(
                              text: hc.expectedMembership.toString()),
                    )).toList(),
                  );
                },
              ),

            const SizedBox(height: 16),
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
                child: Text(widget.existing != null
                    ? 'Update Event' : 'Save Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HcAttendanceRow extends StatelessWidget {
  final HomeChurch homeChurch;
  final TextEditingController actualController;
  final TextEditingController expectedController;

  const _HcAttendanceRow({
    required this.homeChurch,
    required this.actualController,
    required this.expectedController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Text(homeChurch.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: actualController,
            decoration: const InputDecoration(
                labelText: 'Actual',
                isDense: true,
                border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n < 0) return '!';
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: expectedController,
            decoration: const InputDecoration(
                labelText: 'Expected',
                isDense: true,
                border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n < 0) return '!';
              return null;
            },
          ),
        ),
      ]),
    );
  }
}
