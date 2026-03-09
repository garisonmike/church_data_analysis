import 'package:church_analytics/models/charts/category_point.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:church_analytics/widgets/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CorrelationChartsScreen extends ConsumerWidget {
  final int churchId;
  const CorrelationChartsScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Correlation Charts'),
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
            : _CorrelationContent(records: records),
      ),
    );
  }
}

class _CorrelationContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _CorrelationContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    double avg(double Function(WeeklyRecord r) fn) => sorted.isEmpty
        ? 0
        : sorted.map(fn).reduce((a, b) => a + b) / sorted.length;

    final demographicsData = {
      'Average': [
        CategoryPoint(label: 'Men', value: avg((r) => r.men.toDouble())),
        CategoryPoint(label: 'Women', value: avg((r) => r.women.toDouble())),
        CategoryPoint(label: 'Youth', value: avg((r) => r.youth.toDouble())),
        CategoryPoint(
          label: 'Children',
          value: avg((r) => r.children.toDouble()),
        ),
        CategoryPoint(
          label: 'Home Church',
          value: avg((r) => r.sundayHomeChurch.toDouble()),
        ),
      ],
    };

    final incomeComponentsData = {
      'Average': [
        CategoryPoint(label: 'Tithe', value: avg((r) => r.tithe)),
        CategoryPoint(label: 'Offerings', value: avg((r) => r.offerings)),
        CategoryPoint(
          label: 'Emergency',
          value: avg((r) => r.emergencyCollection),
        ),
        CategoryPoint(label: 'Planned', value: avg((r) => r.plannedCollection)),
      ],
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Attendance vs Income (dual axis)
        ResponsiveChartContainer(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: DualAxisChartWidget(
            primarySeries: analytics.attendanceTrendSeries(sorted),
            secondarySeries: analytics.incomeTrendSeries(sorted),
            title: 'Attendance vs Income Over Time',
            primaryAxisTitle: 'Attendance',
            secondaryAxisTitle: 'Income',
          ),
        ),
        const SizedBox(height: 16),

        // 2. Average Demographics
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: BarChartWidget(
            seriesData: demographicsData,
            title: 'Average Attendance by Demographic',
            yAxisTitle: 'Attendance',
          ),
        ),
        const SizedBox(height: 16),

        // 3. Average Income Components
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: BarChartWidget(
            seriesData: incomeComponentsData,
            title: 'Average Income by Component',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // 4. Scatter Correlation
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 420,
          aspectRatio: 16 / 10,
          child: ScatterCorrelationChart(
            data: analytics.attendanceVsIncomeScatter(sorted),
            title: 'Attendance vs Income Correlation',
            xAxisTitle: 'Total Attendance',
            yAxisTitle: 'Total Income',
          ),
        ),
        const SizedBox(height: 16),

        // G-33: Men + Tithe Dual Axis
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: DualAxisChartWidget(
            primarySeries: {'Men': analytics.demographicTrend(sorted, 'MEN')},
            secondarySeries: {'Tithe': analytics.titheTrend(sorted)},
            title: 'Men vs Tithe Over Time',
            primaryAxisTitle: 'Men Attendance',
            secondaryAxisTitle: 'Tithe Amount',
          ),
        ),
        const SizedBox(height: 16),

        // G-34: Women + Offerings Dual Axis
        ResponsiveLazyChart(
          minHeight: 220,
          maxHeight: 380,
          aspectRatio: 16 / 9,
          child: DualAxisChartWidget(
            primarySeries: {
              'Women': analytics.demographicTrend(sorted, 'WOMEN'),
            },
            secondarySeries: {'Offerings': analytics.offeringsTrend(sorted)},
            title: 'Women vs Offerings Over Time',
            primaryAxisTitle: 'Women Attendance',
            secondaryAxisTitle: 'Offerings Amount',
          ),
        ),
        const SizedBox(height: 32),
      ],
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
          Icon(Icons.scatter_plot_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add weekly records to see correlation charts.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
