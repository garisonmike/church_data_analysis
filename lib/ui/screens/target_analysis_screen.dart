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

/// DS2 Target constants used across target charts.
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

/// Screen housing G-49 through G-74 — DS2 Target Analysis charts.
class TargetAnalysisScreen extends ConsumerWidget {
  final int churchId;
  const TargetAnalysisScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Analysis'),
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
        data: (records) => records.isEmpty
            ? const _EmptyView()
            : _TargetContent(records: records),
      ),
    );
  }
}

class _TargetContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _TargetContent({required this.records});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    // Pre-compute shared datasets
    final attTrends = analytics.demographicAttendanceTrends(sorted);
    final pctTrends = analytics.demographicPercentageTrends(sorted);
    final attByGroup = analytics.attendanceByGroupPerWeek(sorted);
    final achievePerWeek = analytics.targetAchievementPerWeek(
      sorted,
      _kTargets,
    );
    final overallAchieve = analytics.overallTargetAchievement(
      sorted,
      _kTargets,
    );
    final ratioMW = analytics.menWomenRatioTrend(sorted);
    final ratioAY = analytics.adultYoungRatioTrend(sorted);
    final ratioTO = analytics.titheOfferingsRatioTrend(sorted);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ----- G-49: Demographic Trends (multi-line) -----
        const _SectionHeader(title: 'Demographic Trends'),
        const SizedBox(height: 8),
        ResponsiveChartContainer(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: LineChartWidget(
            seriesData: attTrends,
            title: 'Demographic Attendance Trends',
            yAxisTitle: 'Count',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-50: Total Attendance vs Target -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: sorted
                .map(
                  (r) => CategoryPoint(
                    label: _fmt(r.weekStartDate),
                    value: r.totalAttendance.toDouble(),
                  ),
                )
                .toList(),
            title: 'Total Attendance vs Target',
            yAxisTitle: 'Count',
            target: _kTargets['Total Attendance']!,
            targetLabel: 'Target',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-51: Home Church vs Target (area) -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: sorted
                .map(
                  (r) => CategoryPoint(
                    label: _fmt(r.weekStartDate),
                    value: r.sundayHomeChurch.toDouble(),
                  ),
                )
                .toList(),
            title: 'Home Church vs Target',
            yAxisTitle: 'Count',
            target: _kTargets['Home Church']!,
            targetLabel: 'Target',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-52: Men vs Women Scatter -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: ScatterCorrelationChart(
            data: analytics.fieldCorrelationScatter(sorted, 'MEN', 'WOMEN'),
            title: 'Men vs Women (Scatter)',
            xAxisTitle: 'Men',
            yAxisTitle: 'Women',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-53: Adult vs Young Scatter -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: ScatterCorrelationChart(
            data: analytics.fieldCorrelationScatter(
              sorted,
              'TOTAL_ATTENDANCE',
              'TOTAL_INCOME',
            ),
            title: 'Adult vs Young (Scatter)',
            xAxisTitle: 'Adult Attendance',
            yAxisTitle: 'Young Attendance',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-54: Attendance Composition % Stacked Area -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: StackedAreaChartWidget(
            seriesData: pctTrends,
            title: 'Attendance Composition %',
            yAxisTitle: '% of Total',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-55: Tithe vs Target -----
        const _SectionHeader(title: 'Financial vs Targets'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: sorted
                .map(
                  (r) => CategoryPoint(
                    label: _fmt(r.weekStartDate),
                    value: r.tithe,
                  ),
                )
                .toList(),
            title: 'Tithe vs Target',
            yAxisTitle: 'Amount',
            target: _kTargets['Tithe']!,
            targetLabel: 'Tithe Target',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-56: Offerings vs Target -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: sorted
                .map(
                  (r) => CategoryPoint(
                    label: _fmt(r.weekStartDate),
                    value: r.offerings,
                  ),
                )
                .toList(),
            title: 'Offerings vs Target',
            yAxisTitle: 'Amount',
            target: _kTargets['Offerings']!,
            targetLabel: 'Offerings Target',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-57: Total Income Trend (area) -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: LineChartWidget(
            seriesData: {'Total Income': analytics.totalIncomeTrend(sorted)},
            title: 'Total Income Trend',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-58: Tithe vs Offerings Scatter -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: ScatterCorrelationChart(
            data: analytics.fieldCorrelationScatter(
              sorted,
              'TITHE',
              'OFFERINGS',
            ),
            title: 'Tithe vs Offerings (Scatter)',
            xAxisTitle: 'Tithe',
            yAxisTitle: 'Offerings',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-59: Attendance vs Income Scatter -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: ScatterCorrelationChart(
            data: analytics.attendanceVsIncomeScatter(sorted),
            title: 'Attendance vs Income (Scatter)',
            xAxisTitle: 'Total Attendance',
            yAxisTitle: 'Total Income',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-60: Income Per Attendee bar with mean -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: Builder(
            builder: (ctx) {
              // Compute income per attendee per week for the bar
              final incPerAtt = sorted.map((r) {
                final att = r.totalAttendance;
                return CategoryPoint(
                  label: _fmt(r.weekStartDate),
                  value: att > 0 ? r.totalIncome / att : 0,
                );
              }).toList();
              final meanVal = incPerAtt.isEmpty
                  ? 0.0
                  : incPerAtt.fold(0.0, (s, p) => s + p.value) /
                        incPerAtt.length;
              return HistogramChartWidget(
                data: incPerAtt,
                title: 'Income Per Attendee',
                meanValue: meanVal,
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-61: Target Achievement Per Week — Grouped Bar -----
        const _SectionHeader(title: 'Target Achievement'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 280,
          maxHeight: 440,
          aspectRatio: 16 / 10,
          child: BarChartWidget(
            seriesData: achievePerWeek,
            title: 'Target Achievement Per Week (%)',
            yAxisTitle: '% of Target',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-62: Overall Average Target Achievement — Horizontal Bar -----
        ResponsiveLazyChart(
          minHeight: 280,
          maxHeight: 440,
          aspectRatio: 16 / 10,
          child: _HorizontalAchievementBar(data: overallAchieve),
        ),
        const SizedBox(height: 16),

        // ----- G-63: Pairwise Scatter Matrix (simplified grid) -----
        const _SectionHeader(title: 'Correlation Analysis'),
        const SizedBox(height: 8),
        ..._buildScatterMatrixGrid(analytics, sorted),

        // ----- G-64: Men:Women Ratio -----
        const _SectionHeader(title: 'Ratio Analysis'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: LineChartWidget(
            seriesData: {'Men:Women': ratioMW},
            title: 'Men:Women Ratio',
            yAxisTitle: 'Ratio',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-65: Adult:Young Ratio -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: LineChartWidget(
            seriesData: {'Adult:Young': ratioAY},
            title: 'Adult:Young Ratio',
            yAxisTitle: 'Ratio',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-66: Tithe:Offerings Ratio -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: LineChartWidget(
            seriesData: {'Tithe:Offerings': ratioTO},
            title: 'Tithe:Offerings Ratio',
            yAxisTitle: 'Ratio',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-67: All Ratios Grouped Bar -----
        ResponsiveLazyChart(
          minHeight: 240,
          maxHeight: 400,
          aspectRatio: 16 / 10,
          child: BarChartWidget(
            seriesData: analytics.allRatiosPerWeek(sorted),
            title: 'All Ratios Comparison',
            yAxisTitle: 'Ratio',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-68: Individual Demographic Bars vs Target (×4) -----
        const _SectionHeader(title: 'Demographics vs Targets'),
        const SizedBox(height: 8),
        ..._buildDemographicTargetBars(sorted),

        // ----- G-69: All Genders Grouped Bar with Target Lines -----
        ResponsiveLazyChart(
          minHeight: 280,
          maxHeight: 440,
          aspectRatio: 16 / 10,
          child: BarChartWidget(
            seriesData: attByGroup,
            title: 'All Demographics vs Targets',
            yAxisTitle: 'Count',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-70: Tithe Per Saturday vs Target -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: sorted
                .map(
                  (r) => CategoryPoint(
                    label: _fmt(r.weekStartDate),
                    value: r.tithe,
                  ),
                )
                .toList(),
            title: 'Tithe Per Saturday vs Target',
            yAxisTitle: 'Amount',
            target: _kTargets['Tithe']!,
            targetLabel: 'Target',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-71: Offerings Per Saturday vs Target -----
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: sorted
                .map(
                  (r) => CategoryPoint(
                    label: _fmt(r.weekStartDate),
                    value: r.offerings,
                  ),
                )
                .toList(),
            title: 'Offerings Per Saturday vs Target',
            yAxisTitle: 'Amount',
            target: _kTargets['Offerings']!,
            targetLabel: 'Target',
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-72: Total Att / Home Church / Total Income vs Target -----
        ..._buildTripleTargetBars(sorted),

        // ----- G-73: Correlation Matrix Heatmap -----
        const _SectionHeader(title: 'Correlation Heatmaps'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 300,
          maxHeight: 500,
          aspectRatio: 1,
          child: HeatmapChartWidget(
            data: analytics.correlationMatrix(sorted, [
              'MEN',
              'WOMEN',
              'YOUTH',
              'CHILDREN',
              'HOME_CHURCH',
              'TOTAL_ATTENDANCE',
              'TITHE',
              'OFFERINGS',
              'TOTAL_INCOME',
            ]),
            title: 'Correlation Matrix',
            isCorrelation: true,
          ),
        ),
        const SizedBox(height: 16),

        // ----- G-74: Target Achievement Heatmap -----
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 420,
          aspectRatio: 16 / 10,
          child: HeatmapChartWidget(
            data: analytics.targetAchievementHeatmap(sorted, _kTargets),
            title: 'Target Achievement %',
            isCorrelation: false,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// G-63: Build a simplified scatter matrix (upper-triangle pairs).
  List<Widget> _buildScatterMatrixGrid(
    AnalyticsService analytics,
    List<WeeklyRecord> records,
  ) {
    const fields = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'TITHE', 'OFFERINGS'];
    final widgets = <Widget>[];
    for (int i = 0; i < fields.length; i++) {
      for (int j = i + 1; j < fields.length; j++) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ResponsiveLazyChart(
              minHeight: 200,
              maxHeight: 340,
              aspectRatio: 16 / 9,
              child: ScatterCorrelationChart(
                data: analytics.fieldCorrelationScatter(
                  records,
                  fields[i],
                  fields[j],
                ),
                title: '${fields[i]} vs ${fields[j]}',
                xAxisTitle: fields[i],
                yAxisTitle: fields[j],
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  /// G-68: Build 4 individual demographic bar charts with target lines.
  List<Widget> _buildDemographicTargetBars(List<WeeklyRecord> sorted) {
    final fields = <String, double Function(WeeklyRecord)>{
      'Men': (r) => r.men.toDouble(),
      'Women': (r) => r.women.toDouble(),
      'Youth': (r) => r.youth.toDouble(),
      'Children': (r) => r.children.toDouble(),
    };
    return fields.entries.map((entry) {
      final data = sorted
          .map(
            (r) => CategoryPoint(
              label: _fmt(r.weekStartDate),
              value: entry.value(r),
            ),
          )
          .toList();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ResponsiveLazyChart(
          minHeight: 200,
          maxHeight: 340,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: data,
            title: '${entry.key} vs Target',
            yAxisTitle: 'Count',
            target: _kTargets[entry.key]!,
            targetLabel: 'Target',
          ),
        ),
      );
    }).toList();
  }

  /// G-72: Build 3 bar charts for Total Att, Home Church, Total Income vs target.
  List<Widget> _buildTripleTargetBars(List<WeeklyRecord> sorted) {
    final items = <String, double Function(WeeklyRecord)>{
      'Total Attendance': (r) => r.totalAttendance.toDouble(),
      'Home Church': (r) => r.sundayHomeChurch.toDouble(),
      'Total Income': (r) => r.totalIncome,
    };
    return items.entries.map((entry) {
      final data = sorted
          .map(
            (r) => CategoryPoint(
              label: _fmt(r.weekStartDate),
              value: entry.value(r),
            ),
          )
          .toList();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ResponsiveLazyChart(
          minHeight: 200,
          maxHeight: 340,
          aspectRatio: 16 / 9,
          child: _BarWithTarget(
            data: data,
            title: '${entry.key} vs Target',
            yAxisTitle: entry.key == 'Total Income' ? 'Amount' : 'Count',
            target: _kTargets[entry.key]!,
            targetLabel: 'Target',
          ),
        ),
      );
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// Reusable: Bar chart with a horizontal target line (PlotBand)
// ---------------------------------------------------------------------------
class _BarWithTarget extends StatelessWidget {
  final List<CategoryPoint> data;
  final String title;
  final String yAxisTitle;
  final double target;
  final String targetLabel;

  const _BarWithTarget({
    required this.data,
    required this.title,
    required this.yAxisTitle,
    required this.target,
    this.targetLabel = 'Target',
  });

  @override
  Widget build(BuildContext context) {
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
            tooltipBehavior: TooltipBehavior(enable: true, duration: 2000),
            primaryXAxis: const CategoryAxis(
              labelRotation: -45,
              labelStyle: TextStyle(fontSize: 10),
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: yAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
              plotBands: [
                PlotBand(
                  start: target,
                  end: target,
                  borderColor: Colors.red,
                  borderWidth: 2,
                  dashArray: const <double>[8, 4],
                  text: targetLabel,
                  textStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  horizontalTextAlignment: TextAnchor.end,
                ),
              ],
            ),
            plotAreaBorderWidth: 0,
            series: <CartesianSeries>[
              ColumnSeries<CategoryPoint, String>(
                dataSource: data,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.value,
                color: const Color(0xFF1565C0),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 9),
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
// G-62: Horizontal bar for overall target achievement
// ---------------------------------------------------------------------------
class _HorizontalAchievementBar extends StatelessWidget {
  final List<CategoryPoint> data;
  const _HorizontalAchievementBar({required this.data});

  Color _colorForPct(double pct) {
    if (pct >= 100) return const Color(0xFF2E7D32);
    if (pct >= 50) return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : 340,
          child: SfCartesianChart(
            title: const ChartTitle(
              text: 'Overall Target Achievement (%)',
              textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            tooltipBehavior: TooltipBehavior(enable: true, duration: 2000),
            isTransposed: true,
            primaryXAxis: const CategoryAxis(
              labelStyle: TextStyle(fontSize: 10),
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
              plotBands: [
                PlotBand(
                  start: 100,
                  end: 100,
                  borderColor: Colors.grey.shade700,
                  borderWidth: 2,
                  dashArray: const <double>[6, 3],
                  text: '100%',
                  textStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  horizontalTextAlignment: TextAnchor.end,
                ),
              ],
            ),
            plotAreaBorderWidth: 0,
            series: <CartesianSeries>[
              BarSeries<CategoryPoint, String>(
                dataSource: data,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.value,
                pointColorMapper: (p, _) => _colorForPct(p.value),
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
          Icon(Icons.track_changes, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add weekly records to see target analysis.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
