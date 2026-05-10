import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/models.dart';
import '../../services/analytics_service.dart';
import '../../services/settings_service.dart';
import '../../services/weekly_records_provider.dart';
import '../widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'holy_communion_entry_screen.dart';
import 'business_meeting_entry_screen.dart';

/// Tabbed screen: Holy Communion | Business Meeting
class SpecialEventsScreen extends ConsumerWidget {
  const SpecialEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Special Events'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.church), text: 'Holy Communion'),
            Tab(icon: Icon(Icons.groups), text: 'Business Meeting'),
          ]),
        ),
        body: const TabBarView(children: [
          _HolyCommunionTab(),
          _BusinessMeetingTab(),
        ]),
      ),
    );
  }
}

// ── Holy Communion Tab ────────────────────────────────────────────────────────

class _HolyCommunionTab extends ConsumerWidget {
  const _HolyCommunionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final churchId = settings.selectedChurchId;
    if (churchId == null) return const Center(child: Text('No church selected.'));

    final eventsAsync = ref.watch(holyCommunionEventsProvider(churchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (events) {
        final analytics = AnalyticsService();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Holy Communion', style: Theme.of(context).textTheme.titleMedium),
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Event'),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const HolyCommunionEntryScreen()));
                  if (context.mounted) ref.invalidate(holyCommunionEventsProvider(churchId));
                },
              ),
            ]),
            const SizedBox(height: 16),
            if (events.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No Holy Communion events recorded yet.'),
              ))
            else ...[
              // KPI row
              if (events.isNotEmpty) ...[
                Row(children: [
                  Expanded(child: _EventKpiCard(
                    label: 'Latest Rate',
                    value: '${events.first.overallRate.toStringAsFixed(1)}%',
                    sub: events.first.quarterLabel,
                    color: Colors.purple,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _EventKpiCard(
                    label: 'Latest Actual',
                    value: '${events.first.totalActual}',
                    sub: 'of ${events.first.totalExpectedAtKcc} expected',
                    color: Colors.deepPurple,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _EventKpiCard(
                    label: 'Avg Rate',
                    value: '${analytics.averageHolyCommunionRate(events).toStringAsFixed(1)}%',
                    sub: '${events.length} events',
                    color: Colors.indigo,
                  )),
                ]),
                const SizedBox(height: 20),
              ],
              // Trend chart
              if (events.length > 1) ...[
                Text('Attendance Rate Trend', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _EventRateChart(
                  points: analytics.holyCommunionRateTrend(events),
                  color: Colors.purple,
                ),
                const SizedBox(height: 20),
              ],
              // Per-event cards
              Text('All Events', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...events.map((e) => _EventCard(
                title: e.quarterLabel,
                rate: e.overallRate,
                actual: e.totalActual,
                expected: e.totalExpectedAtKcc,
                attendanceRows: e.attendance.map((r) =>
                    _AttRow(name: r.homeChurchName, actual: r.actualAttendance,
                        expected: r.expectedAtHc)).toList(),
                onEdit: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => HolyCommunionEntryScreen(existing: e)));
                  if (context.mounted) ref.invalidate(holyCommunionEventsProvider(churchId));
                },
              )),
            ],
          ],
        );
      },
    );
  }
}

// ── Business Meeting Tab ──────────────────────────────────────────────────────

class _BusinessMeetingTab extends ConsumerWidget {
  const _BusinessMeetingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final churchId = settings.selectedChurchId;
    if (churchId == null) return const Center(child: Text('No church selected.'));

    final eventsAsync = ref.watch(businessMeetingEventsProvider(churchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (events) {
        final analytics = AnalyticsService();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Business Meetings', style: Theme.of(context).textTheme.titleMedium),
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Meeting'),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const BusinessMeetingEntryScreen()));
                  if (context.mounted) ref.invalidate(businessMeetingEventsProvider(churchId));
                },
              ),
            ]),
            const SizedBox(height: 16),
            if (events.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No business meeting events recorded yet.'),
              ))
            else ...[
              Row(children: [
                Expanded(child: _EventKpiCard(
                  label: 'Latest Rate',
                  value: '${events.first.overallRate.toStringAsFixed(1)}%',
                  sub: events.first.meetingLabel,
                  color: Colors.orange,
                )),
                const SizedBox(width: 12),
                Expanded(child: _EventKpiCard(
                  label: 'Latest Actual',
                  value: '${events.first.totalActual}',
                  sub: 'of ${events.first.totalExpectedAtKcc} expected',
                  color: Colors.deepOrange,
                )),
                const SizedBox(width: 12),
                Expanded(child: _EventKpiCard(
                  label: 'Avg Rate',
                  value: '${analytics.averageBusinessMeetingRate(events).toStringAsFixed(1)}%',
                  sub: '${events.length} meetings',
                  color: Colors.amber.shade800,
                )),
              ]),
              const SizedBox(height: 20),
              if (events.length > 1) ...[
                Text('Attendance Rate Trend', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _EventRateChart(
                  points: analytics.businessMeetingRateTrend(events),
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
              ],
              Text('All Meetings', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...events.map((e) => _EventCard(
                title: e.meetingLabel,
                rate: e.overallRate,
                actual: e.totalActual,
                expected: e.totalExpectedAtKcc,
                attendanceRows: e.attendance.map((r) =>
                    _AttRow(name: r.homeChurchName, actual: r.actualAttendance,
                        expected: r.expectedAtHc)).toList(),
                onEdit: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BusinessMeetingEntryScreen(existing: e)));
                  if (context.mounted) ref.invalidate(businessMeetingEventsProvider(churchId));
                },
              )),
            ],
          ],
        );
      },
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AttRow {
  final String name;
  final int actual, expected;
  const _AttRow({required this.name, required this.actual, required this.expected});
}

class _EventKpiCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _EventKpiCard({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    );
  }
}

class _EventRateChart extends StatelessWidget {
  final List<TimeSeriesPoint> points;
  final Color color;
  const _EventRateChart({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CtrlScrollZoomWrapper(
        builder: (ctrlHeld) => SfCartesianChart(
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true, enablePanning: true,
            enableMouseWheelZooming: ctrlHeld,
          ),
          primaryXAxis: DateTimeAxis(labelStyle: const TextStyle(fontSize: 10)),
          primaryYAxis: NumericAxis(
            minimum: 0, maximum: 100,
            title: const AxisTitle(text: 'Rate %'),
            labelStyle: const TextStyle(fontSize: 10),
          ),
          plotAreaBorderWidth: 0,
          series: [
            SplineSeries<TimeSeriesPoint, DateTime>(
              dataSource: points,
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
              color: color, width: 2.5,
              markerSettings: MarkerSettings(isVisible: true, color: color, borderColor: color),
              enableTooltip: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final String title;
  final double rate;
  final int actual, expected;
  final List<_AttRow> attendanceRows;
  final VoidCallback onEdit;
  const _EventCard({required this.title, required this.rate, required this.actual,
      required this.expected, required this.attendanceRows, required this.onEdit});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final rateColor = widget.rate >= 50 ? Colors.green : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: rateColor.withAlpha(30),
            child: Text('${widget.rate.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: rateColor)),
          ),
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${widget.actual} / ${widget.expected} attended'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: widget.onEdit),
            IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ]),
        ),
        if (_expanded && widget.attendanceRows.isNotEmpty) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: [
              Row(children: const [
                Expanded(flex: 3, child: Text('Home Church', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Actual', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(child: Text('Expected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(child: Text('Rate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
              ]),
              const Divider(),
              ...widget.attendanceRows.map((r) {
                final rate = r.expected > 0 ? (r.actual / r.expected * 100) : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text(r.name, style: const TextStyle(fontSize: 12))),
                    Expanded(child: Text('${r.actual}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                    Expanded(child: Text('${r.expected}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                    Expanded(child: Text('${rate.toStringAsFixed(0)}%', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            color: rate >= 50 ? Colors.green : Colors.orange))),
                  ]),
                );
              }),
            ]),
          ),
        ],
      ]),
    );
  }
}
