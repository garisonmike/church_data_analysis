import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/models.dart';
import '../../services/analytics_service.dart';
import '../../services/weekly_records_provider.dart';
import '../widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'board_meeting_entry_screen.dart';

class BoardMeetingAnalyticsScreen extends ConsumerWidget {
  final int churchId;

  const BoardMeetingAnalyticsScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(boardMeetingRecordsProvider(churchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Meeting Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Board Meeting',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const BoardMeetingEntryScreen()));
              ref.invalidate(boardMeetingRecordsProvider(churchId));
            },
          ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No board meeting records yet.'),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BoardMeetingEntryScreen()));
                    if (context.mounted) ref.invalidate(boardMeetingRecordsProvider(churchId));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Record'),
                ),
              ]),
            );
          }
          return _BoardMeetingBody(records: records, churchId: churchId);
        },
      ),
    );
  }
}

class _BoardMeetingBody extends ConsumerWidget {
  final List<BoardMeetingRecord> records;
  final int churchId;
  const _BoardMeetingBody({required this.records, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = AnalyticsService();
    final avgRate = analytics.averageBoardMeetingRate(records);
    final latest = records.first;
    final seriesData = analytics.boardMeetingActualVsExpected(records);
    final numFmt = NumberFormat('#,##0');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // KPI row
        Row(children: [
          Expanded(child: _KpiCard(
            label: 'Latest Attendance',
            value: numFmt.format(latest.actualAttendance),
            sub: latest.displayLabel,
            color: Colors.blue,
          )),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(
            label: 'Latest Rate',
            value: '${latest.attendanceRate.toStringAsFixed(1)}%',
            sub: '${latest.actualAttendance}/${latest.expectedAttendance}',
            color: latest.attendanceRate >= 75 ? Colors.green : Colors.orange,
          )),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(
            label: 'Avg Rate',
            value: '${avgRate.toStringAsFixed(1)}%',
            sub: '${records.length} months',
            color: Colors.teal,
          )),
        ]),
        const SizedBox(height: 20),

        // Actual vs Expected bar chart
        Text('Actual vs Expected', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: CtrlScrollZoomWrapper(
            builder: (ctrlHeld) => SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(
                enablePinching: true, enableDoubleTapZooming: true,
                enablePanning: true, enableMouseWheelZooming: ctrlHeld,
              ),
              legend: const Legend(isVisible: true, position: LegendPosition.bottom),
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: const CategoryAxis(
                  labelRotation: -45, labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 10)),
              plotAreaBorderWidth: 0,
              series: [
                ColumnSeries<CategoryPoint, String>(
                  name: 'Actual',
                  dataSource: seriesData['Actual'] ?? [],
                  xValueMapper: (p, _) => p.label,
                  yValueMapper: (p, _) => p.value,
                  color: Colors.blue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  enableTooltip: true,
                ),
                ColumnSeries<CategoryPoint, String>(
                  name: 'Expected',
                  dataSource: seriesData['Expected'] ?? [],
                  xValueMapper: (p, _) => p.label,
                  yValueMapper: (p, _) => p.value,
                  color: Colors.blue.withAlpha(80),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Records list
        Text('All Records', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...records.map((r) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: r.attendanceRate >= 75
                  ? Colors.green.withAlpha(30)
                  : Colors.orange.withAlpha(30),
              child: Text('${r.attendanceRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold,
                      color: r.attendanceRate >= 75 ? Colors.green : Colors.orange)),
            ),
            title: Text(r.displayLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${r.actualAttendance} / ${r.expectedAttendance} members'),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BoardMeetingEntryScreen(existing: r)));
                ref.invalidate(boardMeetingRecordsProvider(churchId));
              },
            ),
          ),
        )),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }
}
