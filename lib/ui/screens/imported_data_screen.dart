import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ImportedDataScreen
//
// FEAT-014 — surfaces a full, filterable list of every imported record for
//             the current church, grouped into four tabs.
// FEAT-015 — adds per-tab multi-select with a confirmation-guarded delete
//             action and immediate provider invalidation.
// ─────────────────────────────────────────────────────────────────────────────

class ImportedDataScreen extends ConsumerStatefulWidget {
  final int churchId;

  const ImportedDataScreen({super.key, required this.churchId});

  @override
  ConsumerState<ImportedDataScreen> createState() => _ImportedDataScreenState();
}

class _ImportedDataScreenState extends ConsumerState<ImportedDataScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ── per-tab search query ──────────────────────────────────────────────────
  final _searchControllers = List.generate(4, (_) => TextEditingController());

  // ── per-tab selected IDs (multi-select) ───────────────────────────────────
  final _selected = List.generate(4, (_) => <int>{});

  // ── per-tab date-range filter ─────────────────────────────────────────────
  final _dateFrom = List<DateTime?>.filled(4, null, growable: false);
  final _dateTo   = List<DateTime?>.filled(4, null, growable: false);

  bool get _isSelecting => _selected[_tabController.index].isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _searchControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  int get _tab => _tabController.index;

  void _toggleSelect(int id) {
    setState(() {
      if (_selected[_tab].contains(id)) {
        _selected[_tab].remove(id);
      } else {
        _selected[_tab].add(id);
      }
    });
  }

  void _clearSelection() => setState(() => _selected[_tab].clear());

  // ── delete flow ───────────────────────────────────────────────────────────

  Future<void> _confirmAndDelete() async {
    final ids = List<int>.from(_selected[_tab]);
    if (ids.isEmpty) return;

    final tabNames = [
      'weekly record',
      'board meeting record',
      'Holy Communion event',
      'Business Meeting event',
    ];
    final noun = ids.length == 1
        ? '1 ${tabNames[_tab]}'
        : '${ids.length} ${tabNames[_tab]}s';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Permanently delete $noun? This cannot be undone.',
        ),
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

    try {
      switch (_tab) {
        case 0: // Weekly Records
          final repo = ref.read(weeklyRecordRepositoryProvider);
          for (final id in ids) {
            await repo.deleteRecord(id);
          }
          ref.invalidate(weeklyRecordsProvider(widget.churchId));

        case 1: // Board Meeting Records
          final repo = ref.read(boardMeetingRepositoryProvider);
          for (final id in ids) {
            await repo.deleteRecord(id);
          }
          ref.invalidate(boardMeetingRecordsProvider(widget.churchId));

        case 2: // Holy Communion Events
          final repo = ref.read(holyCommunionRepositoryProvider);
          for (final id in ids) {
            await repo.deleteEvent(id);
          }
          ref.invalidate(holyCommunionEventsProvider(widget.churchId));

        case 3: // Business Meeting Events
          final repo = ref.read(businessMeetingRepositoryProvider);
          for (final id in ids) {
            await repo.deleteEvent(id);
          }
          ref.invalidate(businessMeetingEventsProvider(widget.churchId));
      }

      if (!mounted) return;
      _clearSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $noun.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // ── date-range picker ─────────────────────────────────────────────────────

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: (_dateFrom[_tab] != null && _dateTo[_tab] != null)
          ? DateTimeRange(start: _dateFrom[_tab]!, end: _dateTo[_tab]!)
          : null,
    );
    if (range != null) {
      setState(() {
        _dateFrom[_tab] = range.start;
        _dateTo[_tab]   = range.end;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _dateFrom[_tab] = null;
      _dateTo[_tab]   = null;
    });
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    if (_isSelecting) {
      final count = _selected[_tab].length;
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel selection',
          onPressed: _clearSelection,
        ),
        title: Text('$count selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete selected',
            onPressed: _confirmAndDelete,
          ),
        ],
      );
    }

    final hasDateFilter = _dateFrom[_tab] != null || _dateTo[_tab] != null;

    return AppBar(
      title: const Text('Imported Data'),
      actions: [
        IconButton(
          icon: Icon(
            Icons.date_range,
            color: hasDateFilter
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          tooltip: hasDateFilter ? 'Clear date filter' : 'Filter by date range',
          onPressed: hasDateFilter ? _clearDateFilter : _pickDateRange,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Weekly'),
          Tab(text: 'Board Mtg'),
          Tab(text: 'Communion'),
          Tab(text: 'Business Mtg'),
        ],
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchControllers[_tab],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchControllers[_tab].text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchControllers[_tab].clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Active date-range chip
          if (_dateFrom[_tab] != null || _dateTo[_tab] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(_dateRangeLabel()),
                    selected: true,
                    onSelected: (_) => _clearDateFilter(),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: _clearDateFilter,
                  ),
                ],
              ),
            ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _WeeklyRecordsTab(
                  churchId: widget.churchId,
                  search: _searchControllers[0].text,
                  dateFrom: _dateFrom[0],
                  dateTo: _dateTo[0],
                  selected: _selected[0],
                  onTap: _handleWeeklyTap,
                  onLongPress: _toggleSelect,
                  onCheckboxToggle: _toggleSelect,
                ),
                _BoardMeetingTab(
                  churchId: widget.churchId,
                  search: _searchControllers[1].text,
                  dateFrom: _dateFrom[1],
                  dateTo: _dateTo[1],
                  selected: _selected[1],
                  onTap: _handleBoardTap,
                  onLongPress: _toggleSelect,
                  onCheckboxToggle: _toggleSelect,
                ),
                _HolyCommunionTab(
                  churchId: widget.churchId,
                  search: _searchControllers[2].text,
                  dateFrom: _dateFrom[2],
                  dateTo: _dateTo[2],
                  selected: _selected[2],
                  onTap: _handleCommunionTap,
                  onLongPress: _toggleSelect,
                  onCheckboxToggle: _toggleSelect,
                ),
                _BusinessMeetingTab(
                  churchId: widget.churchId,
                  search: _searchControllers[3].text,
                  dateFrom: _dateFrom[3],
                  dateTo: _dateTo[3],
                  selected: _selected[3],
                  onTap: _handleBusinessTap,
                  onLongPress: _toggleSelect,
                  onCheckboxToggle: _toggleSelect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── navigation to existing detail screens ────────────────────────────────

  void _handleWeeklyTap(int id) {
    if (_isSelecting) {
      _toggleSelect(id);
    } else {
      Navigator.of(context).pushNamed('/entry', arguments: widget.churchId);
    }
  }

  void _handleBoardTap(int id) {
    if (_isSelecting) {
      _toggleSelect(id);
    } else {
      Navigator.of(context).pushNamed('/board-meeting/entry');
    }
  }

  void _handleCommunionTap(int id) {
    if (_isSelecting) {
      _toggleSelect(id);
    } else {
      Navigator.of(context).pushNamed('/holy-communion/entry');
    }
  }

  void _handleBusinessTap(int id) {
    if (_isSelecting) {
      _toggleSelect(id);
    } else {
      Navigator.of(context).pushNamed('/business-meeting/entry');
    }
  }

  String _dateRangeLabel() {
    final fmt = DateFormat('dd MMM yyyy');
    final from = _dateFrom[_tab];
    final to   = _dateTo[_tab];
    if (from != null && to != null) return '${fmt.format(from)} – ${fmt.format(to)}';
    if (from != null) return 'From ${fmt.format(from)}';
    if (to != null)   return 'Until ${fmt.format(to)}';
    return '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RecordListScaffold — shared loading / error / empty scaffold for each tab
// ─────────────────────────────────────────────────────────────────────────────

class _RecordListScaffold<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final List<T> Function(List<T>) filter;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final String emptyMessage;

  const _RecordListScaffold({
    super.key,
    required this.asyncValue,
    required this.filter,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load data: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ),
      data: (all) {
        final items = filter(all);
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
          itemBuilder: (ctx, i) {
            // isSelected is resolved by the parent tab widget
            return itemBuilder(items[i], false);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 0 — Weekly Records
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyRecordsTab extends ConsumerWidget {
  final int churchId;
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Set<int> selected;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final void Function(int) onCheckboxToggle;

  const _WeeklyRecordsTab({
    required this.churchId,
    required this.search,
    required this.dateFrom,
    required this.dateTo,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(weeklyRecordsProvider(churchId));
    final dateFmt = DateFormat('EEE, d MMM yyyy');
    final currencyFmt = NumberFormat.compact();

    return asyncRecords.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Failed to load: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      data: (all) {
        final q = search.toLowerCase();
        final items = all.where((r) {
          final dateMatch = q.isEmpty ||
              dateFmt.format(r.weekStartDate).toLowerCase().contains(q);
          final fromMatch = dateFrom == null ||
              r.weekStartDate.isAfter(dateFrom!.subtract(const Duration(days: 1)));
          final toMatch = dateTo == null ||
              r.weekStartDate.isBefore(dateTo!.add(const Duration(days: 1)));
          return dateMatch && fromMatch && toMatch;
        }).toList();

        if (items.isEmpty) {
          return _emptyState(context, all.isEmpty
              ? 'No weekly records imported yet.'
              : 'No records match your filter.');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (ctx, i) {
            final r = items[i];
            final id = r.id!;
            final isSelected = selected.contains(id);

            return ListTile(
              leading: selected.isNotEmpty
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => onCheckboxToggle(id),
                    )
                  : CircleAvatar(
                      child: Text(
                        dateFmt.format(r.weekStartDate).substring(0, 2),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
              title: Text(dateFmt.format(r.weekStartDate)),
              subtitle: Text(
                'Total: ${r.totalAttendance} · '
                'Tithe: ${currencyFmt.format(r.tithe)}',
              ),
              selected: isSelected,
              onTap: () => onTap(id),
              onLongPress: () => onLongPress(id),
              trailing: selected.isEmpty
                  ? Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.outline)
                  : null,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Board Meeting Records
// ─────────────────────────────────────────────────────────────────────────────

class _BoardMeetingTab extends ConsumerWidget {
  final int churchId;
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Set<int> selected;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final void Function(int) onCheckboxToggle;

  const _BoardMeetingTab({
    required this.churchId,
    required this.search,
    required this.dateFrom,
    required this.dateTo,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(boardMeetingRecordsProvider(churchId));
    final dateFmt = DateFormat('MMMM yyyy');
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return asyncRecords.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Failed to load: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      data: (all) {
        final q = search.toLowerCase();
        final items = all.where((r) {
          final label =
              '${monthNames[r.month]} ${r.year}'.toLowerCase();
          final labelMatch = q.isEmpty || label.contains(q);
          final fromMatch = dateFrom == null ||
              r.meetingDate.isAfter(dateFrom!.subtract(const Duration(days: 1)));
          final toMatch = dateTo == null ||
              r.meetingDate.isBefore(dateTo!.add(const Duration(days: 1)));
          return labelMatch && fromMatch && toMatch;
        }).toList();

        if (items.isEmpty) {
          return _emptyState(context, all.isEmpty
              ? 'No board meeting records imported yet.'
              : 'No records match your filter.');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (ctx, i) {
            final r = items[i];
            final id = r.id!;
            final isSelected = selected.contains(id);
            final attendancePct = r.expectedAttendance > 0
                ? (r.actualAttendance / r.expectedAttendance * 100)
                    .toStringAsFixed(0)
                : '—';

            return ListTile(
              leading: selected.isNotEmpty
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => onCheckboxToggle(id),
                    )
                  : const CircleAvatar(child: Icon(Icons.people_outline)),
              title: Text('${monthNames[r.month]} ${r.year}'),
              subtitle: Text(
                'Attendance: ${r.actualAttendance} / ${r.expectedAttendance} ($attendancePct%)',
              ),
              selected: isSelected,
              onTap: () => onTap(id),
              onLongPress: () => onLongPress(id),
              trailing: selected.isEmpty
                  ? Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.outline)
                  : null,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Holy Communion Events
// ─────────────────────────────────────────────────────────────────────────────

class _HolyCommunionTab extends ConsumerWidget {
  final int churchId;
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Set<int> selected;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final void Function(int) onCheckboxToggle;

  const _HolyCommunionTab({
    required this.churchId,
    required this.search,
    required this.dateFrom,
    required this.dateTo,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(holyCommunionEventsProvider(churchId));
    final dateFmt = DateFormat('d MMM yyyy');

    return asyncEvents.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Failed to load: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      data: (all) {
        final q = search.toLowerCase();
        final items = all.where((e) {
          final label = 'Q${e.quarter} ${e.year}'.toLowerCase();
          final labelMatch = q.isEmpty || label.contains(q);
          final fromMatch = dateFrom == null ||
              e.eventDate.isAfter(dateFrom!.subtract(const Duration(days: 1)));
          final toMatch = dateTo == null ||
              e.eventDate.isBefore(dateTo!.add(const Duration(days: 1)));
          return labelMatch && fromMatch && toMatch;
        }).toList();

        if (items.isEmpty) {
          return _emptyState(context, all.isEmpty
              ? 'No Holy Communion events imported yet.'
              : 'No events match your filter.');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (ctx, i) {
            final e = items[i];
            final id = e.id!;
            final isSelected = selected.contains(id);

            return ListTile(
              leading: selected.isNotEmpty
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => onCheckboxToggle(id),
                    )
                  : CircleAvatar(child: Text('Q${e.quarter}')),
              title: Text('Q${e.quarter} ${e.year}'),
              subtitle: Text(
                '${dateFmt.format(e.eventDate)} · Expected: ${e.totalExpectedAtKcc}',
              ),
              selected: isSelected,
              onTap: () => onTap(id),
              onLongPress: () => onLongPress(id),
              trailing: selected.isEmpty
                  ? Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.outline)
                  : null,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Business Meeting Events
// ─────────────────────────────────────────────────────────────────────────────

class _BusinessMeetingTab extends ConsumerWidget {
  final int churchId;
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Set<int> selected;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final void Function(int) onCheckboxToggle;

  const _BusinessMeetingTab({
    required this.churchId,
    required this.search,
    required this.dateFrom,
    required this.dateTo,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(businessMeetingEventsProvider(churchId));
    final dateFmt = DateFormat('d MMM yyyy');

    return asyncEvents.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Failed to load: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      data: (all) {
        final q = search.toLowerCase();
        final items = all.where((e) {
          final label =
              'Q${e.quarter} ${e.year} Meeting ${e.meetingNumber}'.toLowerCase();
          final labelMatch = q.isEmpty || label.contains(q);
          final fromMatch = dateFrom == null ||
              e.eventDate.isAfter(dateFrom!.subtract(const Duration(days: 1)));
          final toMatch = dateTo == null ||
              e.eventDate.isBefore(dateTo!.add(const Duration(days: 1)));
          return labelMatch && fromMatch && toMatch;
        }).toList();

        if (items.isEmpty) {
          return _emptyState(context, all.isEmpty
              ? 'No Business Meeting events imported yet.'
              : 'No events match your filter.');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (ctx, i) {
            final e = items[i];
            final id = e.id!;
            final isSelected = selected.contains(id);

            return ListTile(
              leading: selected.isNotEmpty
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => onCheckboxToggle(id),
                    )
                  : CircleAvatar(child: Text('M${e.meetingNumber}')),
              title: Text('Q${e.quarter} ${e.year} — Meeting ${e.meetingNumber}'),
              subtitle: Text(
                '${dateFmt.format(e.eventDate)} · Expected: ${e.totalExpectedAtKcc}',
              ),
              selected: isSelected,
              onTap: () => onTap(id),
              onLongPress: () => onLongPress(id),
              trailing: selected.isEmpty
                  ? Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.outline)
                  : null,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared empty state widget
// ─────────────────────────────────────────────────────────────────────────────

Widget _emptyState(BuildContext context, String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    ),
  );
}
