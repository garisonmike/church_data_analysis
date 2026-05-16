import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/models.dart';
import '../../services/analytics_service.dart';
import '../../services/weekly_records_provider.dart';
import '../widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'home_church_screen.dart';

class HomeChurchAnalyticsScreen extends ConsumerWidget {
  final int churchId;

  const HomeChurchAnalyticsScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hcAsync = ref.watch(homeChurchesProvider(churchId));
    final hcEventsAsync = ref.watch(holyCommunionEventsProvider(churchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Church Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Manage Home Churches',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HomeChurchScreen())),
          ),
        ],
      ),
      body: hcAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (homeChurches) {
          if (homeChurches.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No home churches configured.'),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HomeChurchScreen())),
                  child: const Text('Set Up Home Churches'),
                ),
              ],
            ));
          }

          final analytics = AnalyticsService();
          final byCategory = analytics.homeChurchMembershipByCategory(homeChurches);
          final sorted = List<HomeChurch>.from(homeChurches)
            ..sort((a, b) => b.expectedMembership.compareTo(a.expectedMembership));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary KPIs
              Row(children: [
                Expanded(child: _SummaryCard(
                  label: 'Total Home Churches',
                  value: '${homeChurches.length}',
                  color: Colors.teal,
                )),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(
                  label: 'Total Membership',
                  value: '${homeChurches.fold(0, (s, h) => s + h.expectedMembership)}',
                  color: Colors.blue,
                )),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(
                  label: 'Active',
                  value: '${homeChurches.where((h) => h.isActive).length}',
                  color: Colors.green,
                )),
              ]),
              const SizedBox(height: 20),

              // Membership by category pie
              Text('Membership by Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: SfCircularChart(
                  legend: const Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: [
                    DoughnutSeries<MapEntry<String, double>, String>(
                      dataSource: byCategory.entries.toList(),
                      xValueMapper: (e, _) => e.key,
                      yValueMapper: (e, _) => e.value,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      enableTooltip: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Membership bar chart
              Text('Membership per Home Church',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: CtrlScrollZoomWrapper(
                  builder: (ctrlHeld) => SfCartesianChart(
                    zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true, enablePanning: true,
                        enableMouseWheelZooming: ctrlHeld),
                    primaryXAxis: const CategoryAxis(
                        labelRotation: -45,
                        labelStyle: TextStyle(fontSize: 9),
                        majorGridLines: MajorGridLines(width: 0)),
                    primaryYAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 10)),
                    plotAreaBorderWidth: 0,
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: [
                      BarSeries<HomeChurch, String>(
                        dataSource: sorted,
                        xValueMapper: (h, _) => h.name,
                        yValueMapper: (h, _) => h.expectedMembership.toDouble(),
                        color: Colors.teal,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                        enableTooltip: true,
                        dataLabelSettings: const DataLabelSettings(
                            isVisible: true, labelAlignment: ChartDataLabelAlignment.outer,
                            textStyle: TextStyle(fontSize: 9)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // HC attendance rates from latest communion event
              hcEventsAsync.when(
                data: (events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  final latest = events.first;
                  final rates = analytics.homeChurchAttendanceRates(latest.attendance);
                  if (rates.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HC Attendance Rate — ${latest.quarterLabel}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: CtrlScrollZoomWrapper(
                          builder: (ctrlHeld) => SfCartesianChart(
                            zoomPanBehavior: ZoomPanBehavior(
                                enablePinching: true, enablePanning: true,
                                enableMouseWheelZooming: ctrlHeld),
                            primaryXAxis: const CategoryAxis(
                                labelRotation: -45,
                                labelStyle: TextStyle(fontSize: 9),
                                majorGridLines: MajorGridLines(width: 0)),
                            primaryYAxis: NumericAxis(
                                minimum: 0, maximum: 100,
                                title: const AxisTitle(text: 'Rate %'),
                                labelStyle: const TextStyle(fontSize: 10)),
                            plotAreaBorderWidth: 0,
                            tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x: point.y%'),
                            series: [
                              BarSeries<CategoryPoint, String>(
                                dataSource: rates,
                                xValueMapper: (p, _) => p.label,
                                yValueMapper: (p, _) => p.value,
                                color: Colors.purple,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                                enableTooltip: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

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
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
