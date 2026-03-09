import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:church_analytics/widgets/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinancialChartsScreen extends ConsumerWidget {
  final int churchId;
  const FinancialChartsScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Charts'),
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
            onPressed: () => ref.invalidate(weeklyRecordsForChurchProvider(churchId)),
          ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(weeklyRecordsForChurchProvider(churchId)),
        ),
        data: (records) =>
            records.isEmpty ? const _EmptyView() : _FinancialContent(records: records),
      ),
    );
  }
}

class _FinancialContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _FinancialContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Tithe vs Offerings Trend
        ResponsiveChartContainer(
          minHeight: 220, maxHeight: 380, aspectRatio: 16 / 9,
          child: LineChartWidget(
            seriesData: {
              'Tithe': analytics.titheTrend(sorted),
              'Offerings': analytics.offeringsTrend(sorted),
            },
            title: 'Tithe vs Offerings Trend',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // 2. Income Composition (stacked area)
        ResponsiveLazyChart(
          minHeight: 220, maxHeight: 380, aspectRatio: 16 / 9,
          child: StackedAreaChartWidget(
            seriesData: analytics.titheOfferingsComposition(sorted),
            title: 'Income Composition Over Time',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // 3. Income Distribution Pie
        ResponsiveLazyChart(
          minHeight: 260, maxHeight: 420, aspectRatio: 16 / 10,
          child: PieChartWidget(
            data: analytics.incomeDistribution(sorted),
            title: 'Income Distribution',
          ),
        ),
        const SizedBox(height: 16),

        // 4. Income vs Attendance (dual axis)
        ResponsiveLazyChart(
          minHeight: 220, maxHeight: 380, aspectRatio: 16 / 9,
          child: DualAxisChartWidget(
            primarySeries: analytics.attendanceTrendSeries(sorted),
            secondarySeries: analytics.incomeTrendSeries(sorted),
            title: 'Income vs Attendance',
            primaryAxisTitle: 'Attendance',
            secondaryAxisTitle: 'Income',
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
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: onRetry,
                icon: const Icon(Icons.refresh), label: const Text('Retry')),
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
          Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Add weekly records to see financial charts.',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
