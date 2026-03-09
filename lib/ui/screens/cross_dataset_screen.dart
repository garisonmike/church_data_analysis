import 'package:church_analytics/models/charts/charts.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:church_analytics/widgets/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// DS2 Target constants shared with TargetAnalysisScreen.
const Map<String, double> _kTargets = {
  'Men': 900,
  'Women': 1200,
  'Youth': 800,
  'Children': 1000,
  'Total Attendance': 3900,
  'Home Church': 2000,
  'Tithe': 1050000,
  'Offerings': 450000,
};

/// Screen housing G-75 through G-83 — Cross-Dataset Comparison charts.
///
/// Uses all available records, treating them as a single dataset.
/// For true cross-dataset comparisons the user would need two separate
/// datasets; here we split the data by halves to demonstrate the feature.
class CrossDatasetScreen extends ConsumerWidget {
  final int churchId;
  const CrossDatasetScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cross-Dataset Comparison'),
        actions: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: TimeRangeSelector(compact: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.invalidate(weeklyRecordsForChurchProvider(churchId)),
          ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(weeklyRecordsForChurchProvider(churchId)),
        ),
        data: (records) {
          if (records.length < 2) return const _EmptyView();
          return _CrossContent(records: records);
        },
      ),
    );
  }
}

class _CrossContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _CrossContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    // Split into two halves for cross-dataset comparison
    final mid = sorted.length ~/ 2;
    final ds1 = sorted.sublist(0, mid);
    final ds2 = sorted.sublist(mid);

    final avg1 = analytics.datasetAverages(ds1);
    final avg2 = analytics.datasetAverages(ds2);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Dataset 1: first ${ds1.length} weeks  •  '
              'Dataset 2: last ${ds2.length} weeks',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-75: Cross-Dataset Demographic Averages -----
        const _SectionHeader(title: 'Average Comparisons'),
        const SizedBox(height: 8),
        ..._buildAverageComparisonBars(avg1, avg2),

        // ----- G-76: Change % DS1→DS2 -----
        const _SectionHeader(title: 'Change % (DS1 → DS2)'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 300,
          maxHeight: 460,
          aspectRatio: 16 / 12,
          child: _HorizontalChangeBar(
            data: analytics.crossDatasetChangePercent(ds1, ds2),
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-77: Correlation Matrices Side-by-Side -----
        const _SectionHeader(title: 'Correlation Matrices'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 300,
          maxHeight: 500,
          aspectRatio: 1,
          child: HeatmapChartWidget(
            data: analytics.correlationMatrix(ds1, [
              'MEN',
              'WOMEN',
              'YOUTH',
              'CHILDREN',
              'TOTAL_ATTENDANCE',
              'TITHE',
              'OFFERINGS',
            ]),
            title: 'DS1 Correlation',
            isCorrelation: true,
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveLazyChart(
          minHeight: 300,
          maxHeight: 500,
          aspectRatio: 1,
          child: HeatmapChartWidget(
            data: analytics.correlationMatrix(ds2, [
              'MEN',
              'WOMEN',
              'YOUTH',
              'CHILDREN',
              'TOTAL_ATTENDANCE',
              'TITHE',
              'OFFERINGS',
            ]),
            title: 'DS2 Correlation',
            isCorrelation: true,
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-78: Attendance vs Income Scatter Overlay -----
        const _SectionHeader(title: 'Scatter Overlays'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 240,
          maxHeight: 400,
          aspectRatio: 16 / 10,
          child: _DualScatter(
            seriesMap: analytics.attendanceVsIncomeScatterBoth(ds1, ds2),
            title: 'Attendance vs Income (Both Datasets)',
            xAxisTitle: 'Total Attendance',
            yAxisTitle: 'Total Income',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-79: Tithe vs Offerings Scatter Overlay -----
        ResponsiveLazyChart(
          minHeight: 240,
          maxHeight: 400,
          aspectRatio: 16 / 10,
          child: _DualScatter(
            seriesMap: analytics.titheVsOfferingsScatterBoth(ds1, ds2),
            title: 'Tithe vs Offerings (Both Datasets)',
            xAxisTitle: 'Tithe',
            yAxisTitle: 'Offerings',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-80: Per Capita Comparison DS1 vs DS2 -----
        const _SectionHeader(title: 'Per-Capita Comparison'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 240,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: BarChartWidget(
            seriesData: _perCapitaBars(avg1, avg2),
            title: 'Per-Capita Metrics (DS1 vs DS2)',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-81: Attendance Three-Way Comparison -----
        const _SectionHeader(title: 'Three-Way Comparison'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 440,
          aspectRatio: 16 / 10,
          child: BarChartWidget(
            seriesData: analytics.threeWayComparisonAttendance(
              ds1,
              ds2,
              _kTargets,
            ),
            title: 'Attendance: DS1 vs DS2 vs Target',
            yAxisTitle: 'Count',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-82: Financial Three-Way Comparison -----
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 440,
          aspectRatio: 16 / 10,
          child: BarChartWidget(
            seriesData: analytics.threeWayComparisonFinancial(
              ds1,
              ds2,
              _kTargets,
            ),
            title: 'Financial: DS1 vs DS2 vs Target',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-83: Master Summary Dashboard -----
        const _SectionHeader(title: 'Summary Dashboard'),
        const SizedBox(height: 8),
        _SummaryStatsTable(stats: analytics.crossDatasetSummaryStats(ds1, ds2)),
        const SizedBox(height: 32),
      ],
    );
  }

  /// G-75: Build 4 grouped bar charts comparing DS1 vs DS2 averages.
  List<Widget> _buildAverageComparisonBars(
    Map<String, double> avg1,
    Map<String, double> avg2,
  ) {
    final groups = <String, List<String>>{
      'Demographics': ['Men', 'Women', 'Youth', 'Children'],
      'Totals': ['Total Attendance', 'Home Church'],
      'Financial': ['Tithe', 'Offerings', 'Total Income'],
      'Per-Capita': ['Income/Att', 'Tithe/Att', 'Offerings/Att'],
    };
    return groups.entries.map((entry) {
      final ds1Series = entry.value
          .map((f) => CategoryPoint(label: f, value: avg1[f] ?? 0))
          .toList();
      final ds2Series = entry.value
          .map((f) => CategoryPoint(label: f, value: avg2[f] ?? 0))
          .toList();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: BarChartWidget(
            seriesData: {'DS1 Avg': ds1Series, 'DS2 Avg': ds2Series},
            title: '${entry.key} — DS1 vs DS2',
            yAxisTitle: entry.key == 'Financial' ? 'Amount' : 'Count',
          ),
        ),
      );
    }).toList();
  }

  /// G-80: Build per-capita grouped bars.
  Map<String, List<CategoryPoint>> _perCapitaBars(
    Map<String, double> avg1,
    Map<String, double> avg2,
  ) {
    const fields = ['Income/Att', 'Tithe/Att', 'Offerings/Att'];
    return {
      'DS1': fields
          .map((f) => CategoryPoint(label: f, value: avg1[f] ?? 0))
          .toList(),
      'DS2': fields
          .map((f) => CategoryPoint(label: f, value: avg2[f] ?? 0))
          .toList(),
    };
  }
}

// ---------------------------------------------------------------------------
// G-76: Horizontal bar showing % change (green/red)
// ---------------------------------------------------------------------------
class _HorizontalChangeBar extends StatelessWidget {
  final List<CategoryPoint> data;
  const _HorizontalChangeBar({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : 340,
          child: SfCartesianChart(
            title: const ChartTitle(
              text: '% Change DS1 → DS2',
              textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            tooltipBehavior: TooltipBehavior(enable: true, duration: 2000),
            isTransposed: true,
            primaryXAxis: const CategoryAxis(
              labelStyle: TextStyle(fontSize: 10),
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.decimalPercentPattern(
                decimalDigits: 1,
              ),
              labelStyle: const TextStyle(fontSize: 10),
              plotBands: [
                PlotBand(
                  start: 0,
                  end: 0,
                  borderColor: Colors.grey.shade700,
                  borderWidth: 1,
                ),
              ],
            ),
            plotAreaBorderWidth: 0,
            series: <CartesianSeries>[
              BarSeries<CategoryPoint, String>(
                dataSource: data,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.value,
                pointColorMapper: (p, _) => p.value >= 0
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 9),
                  labelAlignment: ChartDataLabelAlignment.outer,
                ),
                enableTooltip: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// G-78/G-79: Dual scatter (two datasets on one chart)
// ---------------------------------------------------------------------------
class _DualScatter extends StatelessWidget {
  final Map<String, List<ScatterPoint>> seriesMap;
  final String title;
  final String xAxisTitle;
  final String yAxisTitle;
  const _DualScatter({
    required this.seriesMap,
    required this.title,
    this.xAxisTitle = '',
    this.yAxisTitle = '',
  });

  static const _colors = [Color(0xFF1565C0), Color(0xFFE65100)];

  @override
  Widget build(BuildContext context) {
    final entries = seriesMap.entries.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : 300,
          child: SfCartesianChart(
            title: ChartTitle(
              text: title,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
            ),
            tooltipBehavior: TooltipBehavior(enable: true, duration: 2000),
            primaryXAxis: NumericAxis(
              title: AxisTitle(text: xAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: yAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            plotAreaBorderWidth: 0,
            series: <CartesianSeries>[
              for (int i = 0; i < entries.length; i++)
                ScatterSeries<ScatterPoint, num>(
                  name: entries[i].key,
                  dataSource: entries[i].value,
                  xValueMapper: (p, _) => p.x,
                  yValueMapper: (p, _) => p.y,
                  color: _colors[i % _colors.length],
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: i == 0
                        ? DataMarkerType.circle
                        : DataMarkerType.rectangle,
                    height: 10,
                    width: 10,
                  ),
                  enableTooltip: true,
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// G-83: Summary statistics table
// ---------------------------------------------------------------------------
class _SummaryStatsTable extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _SummaryStatsTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    final ds1Avg = stats['ds1Averages'] as Map<String, double>? ?? {};
    final ds2Avg = stats['ds2Averages'] as Map<String, double>? ?? {};
    final changes = stats['changePercent'] as Map<String, double>? ?? {};
    final nf = NumberFormat.compact();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cross-Dataset Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'DS1: ${stats['ds1Count'] ?? 0} weeks  •  '
              'DS2: ${stats['ds2Count'] ?? 0} weeks',
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 40,
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Metric')),
                  DataColumn(label: Text('DS1 Avg'), numeric: true),
                  DataColumn(label: Text('DS2 Avg'), numeric: true),
                  DataColumn(label: Text('Change %'), numeric: true),
                ],
                rows: ds1Avg.keys.map((key) {
                  final change = changes[key] ?? 0;
                  return DataRow(
                    cells: [
                      DataCell(Text(key, style: const TextStyle(fontSize: 12))),
                      DataCell(
                        Text(
                          nf.format(ds1Avg[key] ?? 0),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          nf.format(ds2Avg[key] ?? 0),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: change >= 0
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Common utility widgets
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Not enough data', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Need at least 2 weeks of records for cross-dataset analysis.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
