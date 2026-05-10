import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../services/log_service.dart';
import '../../services/settings_service.dart';
import '../../services/weekly_records_provider.dart';

class BusinessMeetingEntryScreen extends ConsumerStatefulWidget {
  final BusinessMeetingEvent? existing;
  const BusinessMeetingEntryScreen({super.key, this.existing});

  @override
  ConsumerState<BusinessMeetingEntryScreen> createState() =>
      _BusinessMeetingEntryScreenState();
}

class _BusinessMeetingEntryScreenState
    extends ConsumerState<BusinessMeetingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _eventDate;
  late int _year, _quarter, _meetingNumber;
  late TextEditingController _expectedKcc, _notes;
  final Map<int, TextEditingController> _actual = {};
  final Map<int, TextEditingController> _expectedHc = {};
  List<HomeChurch> _homeChurches = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _eventDate = e?.eventDate ?? DateTime.now();
    _year = e?.year ?? DateTime.now().year;
    _quarter = e?.quarter ?? ((DateTime.now().month / 3).ceil()).clamp(1, 4);
    _meetingNumber = e?.meetingNumber ?? 1;
    _expectedKcc = TextEditingController(text: e?.totalExpectedAtKcc.toString() ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _expectedKcc.dispose(); _notes.dispose();
    for (final c in _actual.values) c.dispose();
    for (final c in _expectedHc.values) c.dispose();
    super.dispose();
  }

  void _initRows(List<HomeChurch> hcs) {
    if (_homeChurches.length == hcs.length) return;
    _homeChurches = hcs;
    for (final hc in hcs) {
      final ex = widget.existing?.attendance.firstWhere(
        (r) => r.homeChurchId == hc.id,
        orElse: () => BusinessMeetingAttendanceRow(
          eventId: 0, homeChurchId: hc.id!, homeChurchName: hc.name,
          actualAttendance: 0, expectedAtHc: hc.expectedMembership),
      );
      _actual[hc.id!] = TextEditingController(text: ex?.actualAttendance.toString() ?? '0');
      _expectedHc[hc.id!] = TextEditingController(text: ex?.expectedAtHc.toString() ?? hc.expectedMembership.toString());
    }
    if (_expectedKcc.text.isEmpty) {
      _expectedKcc.text = '${hcs.fold(0, (s, h) => s + h.expectedMembership)}';
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (d != null) setState(() => _eventDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final settings = ref.read(appSettingsProvider);
      final churchId = settings.selectedChurchId;
      if (churchId == null) throw Exception('No church selected');

      final rows = _homeChurches.map((hc) => BusinessMeetingAttendanceRow(
        eventId: widget.existing?.id ?? 0,
        homeChurchId: hc.id!, homeChurchName: hc.name,
        actualAttendance: int.tryParse(_actual[hc.id!]?.text ?? '0') ?? 0,
        expectedAtHc: int.tryParse(_expectedHc[hc.id!]?.text ?? '0') ?? 0,
      )).toList();

      final event = BusinessMeetingEvent(
        id: widget.existing?.id, churchId: churchId,
        eventDate: _eventDate, year: _year, quarter: _quarter,
        meetingNumber: _meetingNumber,
        totalExpectedAtKcc: int.tryParse(_expectedKcc.text) ?? 0,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        attendance: rows,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final error = event.validate();
      if (error != null) throw Exception(error);

      final repo = ref.read(businessMeetingRepositoryProvider);
      int eventId;
      if (widget.existing == null) {
        eventId = await repo.createEvent(event);
      } else {
        await repo.updateEvent(event);
        eventId = event.id!;
      }
      await repo.upsertAttendanceRows(eventId, rows);
      ref.invalidate(businessMeetingEventsProvider(churchId));
      LogService.info('BusinessMeetingEntry', 'Saved BM event: Q$_quarter $_year #$_meetingNumber');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      LogService.error('BusinessMeetingEntry', 'Save failed', error: e);
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
    final hcAsync = churchId != null ? ref.watch(homeChurchesProvider(churchId)) : null;
    final dateFmt = DateFormat('d MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Business Meeting' : 'New Business Meeting'),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Event Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: DropdownButtonFormField<int>(
                value: _quarter,
                decoration: const InputDecoration(labelText: 'Quarter', border: OutlineInputBorder()),
                items: [1, 2, 3, 4].map((q) => DropdownMenuItem(value: q, child: Text('Q$q'))).toList(),
                onChanged: (v) => setState(() => _quarter = v!),
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<int>(
                value: _meetingNumber,
                decoration: const InputDecoration(labelText: 'Meeting #', helperText: '1st, 2nd or 3rd', border: OutlineInputBorder()),
                items: [1, 2, 3].map((n) {
                  final suffix = n == 1 ? 'st' : n == 2 ? 'nd' : 'rd';
                  return DropdownMenuItem(value: n, child: Text('$n$suffix'));
                }).toList(),
                onChanged: (v) => setState(() => _meetingNumber = v!),
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<int>(
                value: _year,
                decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                items: List.generate(10, (i) => DateTime.now().year - 2 + i)
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                onChanged: (v) => setState(() => _year = v!),
              )),
            ]),
            const SizedBox(height: 12),
            Card(child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Event Date'),
              subtitle: Text(dateFmt.format(_eventDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            )),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expectedKcc,
              decoration: const InputDecoration(
                  labelText: 'Total Expected at KCC', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Attendance by Home Church', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (hcAsync == null)
              const Text('No church selected.')
            else
              hcAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (hcs) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _initRows(hcs));
                  if (hcs.isEmpty) {
                    return Card(child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No home churches. Add them in Church Settings.',
                          style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                    ));
                  }
                  return Column(children: hcs.map((hc) {
                    final actualCtrl = _actual[hc.id!] ?? TextEditingController(text: '0');
                    final expCtrl = _expectedHc[hc.id!] ?? TextEditingController(text: '${hc.expectedMembership}');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Expanded(flex: 3, child: Text(hc.name,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: TextFormField(
                          controller: actualCtrl,
                          decoration: const InputDecoration(labelText: 'Actual', isDense: true, border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? '!' : null,
                        )),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: TextFormField(
                          controller: expCtrl,
                          decoration: const InputDecoration(labelText: 'Expected', isDense: true, border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? '!' : null,
                        )),
                      ]),
                    );
                  }).toList());
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(widget.existing != null ? 'Update Event' : 'Save Event'),
            )),
          ],
        ),
      ),
    );
  }
}
