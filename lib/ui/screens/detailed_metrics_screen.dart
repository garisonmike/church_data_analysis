import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:church_analytics/widgets/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen housing G-03 (individual metric bars with mean),
/// G-08 (pairwise demographic comparisons), and
/// G-10 (home church vs all variables).
class DetailedMetricsScreen extends ConsumerWidget {
  final int churchId;
  const DetailedMetricsScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Metrics'),
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
            : _DetailedContent(records: records),
      ),
    );
  }
}

class _DetailedContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _DetailedContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    // G-03: Individual Demographics Weekly Bars (8 metrics)
    const singleMetrics = [
      'MEN',
      'WOMEN',
      'YOUTH',
      'CHILDREN',
      'TITHE',
      'OFFERINGS',
      'TOTAL_INCOME',
      'SUNDAY_HOME_CHURCH',
    ];

    // G-08: Pairwise Demographic Comparisons (6 pairs)
    const demoPairs = [
      ('MEN', 'WOMEN'),
      ('MEN', 'YOUTH'),
      ('MEN', 'CHILDREN'),
      ('WOMEN', 'YOUTH'),
      ('WOMEN', 'CHILDREN'),
      ('YOUTH', 'CHILDREN'),
    ];

    // G-10: Home Church vs All Variables (8 comparisons)
    const homeChurchTargets = [
      'MEN',
      'WOMEN',
      'YOUTH',
      'CHILDREN',
      'TITHE',
      'OFFERINGS',
      'TOTAL_ATTENDANCE',
      'TOTAL_INCOME',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section: G-03 — Individual Metrics
        _SectionHeader(title: 'Individual Metrics Weekly Breakdown'),
        const SizedBox(height: 8),
        ...singleMetrics.map((field) {
          final result = analytics.singleMetricPerWeek(sorted, field);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ResponsiveLazyChart(
              minHeight: 200,
              maxHeight: 340,
              aspectRatio: 16 / 9,
              child: BarChartWidget(
                seriesData: {field: result.points},
                title:
                    '$field Per Week (Mean: ${result.mean.toStringAsFixed(1)})',
                yAxisTitle: field,
              ),
            ),
          );
        }),

        // Section: G-08 — Pairwise Comparisons
        _SectionHeader(title: 'Demographic Pairwise Comparisons'),
        const SizedBox(height: 8),
        ...demoPairs.map((pair) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ResponsiveLazyChart(
              minHeight: 200,
              maxHeight: 340,
              aspectRatio: 16 / 9,
              child: BarChartWidget(
                seriesData: analytics.demographicPairPerWeek(
                  sorted,
                  pair.$1,
                  pair.$2,
                ),
                title: '${pair.$1} vs ${pair.$2} Per Week',
              ),
            ),
          );
        }),

        // Section: G-10 — Home Church vs All Variables
        _SectionHeader(title: 'Home Church vs Other Metrics'),
        const SizedBox(height: 8),
        ...homeChurchTargets.map((target) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ResponsiveLazyChart(
              minHeight: 200,
              maxHeight: 340,
              aspectRatio: 16 / 9,
              child: BarChartWidget(
                seriesData: analytics.metricPairPerWeek(
                  sorted,
                  'SUNDAY_HOME_CHURCH',
                  target,
                ),
                title: 'Home Church vs $target',
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
      ],
    );
  }
}

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
          Icon(Icons.table_chart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add weekly records to see detailed metrics.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
