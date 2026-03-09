import 'package:church_analytics/models/charts/charts.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:church_analytics/widgets/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen housing G-17 (histograms), G-18/G-19 (box plots),
/// G-20/G-21 (violin/box plots), and G-47 (demographic % box plot).
class DistributionScreen extends ConsumerWidget {
  final int churchId;
  const DistributionScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distributions'),
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
            : _DistributionContent(records: records),
      ),
    );
  }
}

class _DistributionContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _DistributionContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    // G-17: Distribution Histograms (9 metrics)
    final histogramFields = <String, List<double>>{
      'Men': sorted.map((r) => r.men.toDouble()).toList(),
      'Women': sorted.map((r) => r.women.toDouble()).toList(),
      'Youth': sorted.map((r) => r.youth.toDouble()).toList(),
      'Children': sorted.map((r) => r.children.toDouble()).toList(),
      'Total Attendance': sorted
          .map((r) => r.totalAttendance.toDouble())
          .toList(),
      'Tithe': sorted.map((r) => r.tithe).toList(),
      'Offerings': sorted.map((r) => r.offerings).toList(),
      'Total Income': sorted.map((r) => r.totalIncome).toList(),
      'Home Church': sorted.map((r) => r.sundayHomeChurch.toDouble()).toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section: G-17 — Histograms
        _SectionHeader(title: 'Distribution Histograms'),
        const SizedBox(height: 8),
        ...histogramFields.entries.map((entry) {
          final data = analytics.distributionHistogram(entry.value);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ResponsiveLazyChart(
              minHeight: 200,
              maxHeight: 340,
              aspectRatio: 16 / 9,
              child: HistogramChartWidget(
                data: data,
                title: '${entry.key} Distribution',
              ),
            ),
          );
        }),

        // Section: G-18 — Box Plots: Attendance Groups
        _SectionHeader(title: 'Attendance Box Plots'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 420,
          aspectRatio: 16 / 10,
          child: BoxPlotWidget(
            data: analytics.boxPlotStats(sorted, [
              'MEN',
              'WOMEN',
              'YOUTH',
              'CHILDREN',
              'TOTAL_ATTENDANCE',
            ]),
            title: 'Attendance Distribution (Box Plot)',
            yAxisTitle: 'Count',
          ),
        ),
        const SizedBox(height: 16),

        // Section: G-19 — Box Plots: Financial Groups
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 420,
          aspectRatio: 16 / 10,
          child: BoxPlotWidget(
            data: analytics.boxPlotStats(sorted, [
              'TITHE',
              'OFFERINGS',
              'TOTAL_INCOME',
            ]),
            title: 'Financial Distribution (Box Plot)',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // Section: G-20 — Violin-like: Attendance (approximated with box plot)
        _SectionHeader(title: 'Attendance Distributions (Violin Approx.)'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 420,
          aspectRatio: 16 / 10,
          child: BoxPlotWidget(
            data: analytics.boxPlotStats(sorted, [
              'MEN',
              'WOMEN',
              'YOUTH',
              'CHILDREN',
            ]),
            title: 'Attendance Violin (Box Plot Approximation)',
            yAxisTitle: 'Count',
          ),
        ),
        const SizedBox(height: 16),

        // Section: G-21 — Violin-like: Financial
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 420,
          aspectRatio: 16 / 10,
          child: BoxPlotWidget(
            data: analytics.boxPlotStats(sorted, [
              'TITHE',
              'OFFERINGS',
              'TOTAL_INCOME',
            ]),
            title: 'Financial Violin (Box Plot Approximation)',
            yAxisTitle: 'Amount',
          ),
        ),
        const SizedBox(height: 16),

        // Section: G-47 — Demographic % Variability
        _SectionHeader(title: 'Demographic % Variability'),
        const SizedBox(height: 8),
        ResponsiveLazyChart(
          minHeight: 260,
          maxHeight: 420,
          aspectRatio: 16 / 10,
          child: BoxPlotWidget(
            data: _demographicPercentBoxPlot(sorted),
            title: 'Weekly Demographic % Variability',
            yAxisTitle: 'Percentage (%)',
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  List<BoxPlotPoint> _demographicPercentBoxPlot(List<WeeklyRecord> records) {
    final menPcts = <double>[];
    final womenPcts = <double>[];
    final youthPcts = <double>[];
    final childrenPcts = <double>[];
    for (final r in records) {
      final total = r.men + r.women + r.youth + r.children;
      if (total == 0) continue;
      menPcts.add(r.men / total * 100);
      womenPcts.add(r.women / total * 100);
      youthPcts.add(r.youth / total * 100);
      childrenPcts.add(r.children / total * 100);
    }
    return [
      BoxPlotPoint(label: 'Men%', values: menPcts),
      BoxPlotPoint(label: 'Women%', values: womenPcts),
      BoxPlotPoint(label: 'Youth%', values: youthPcts),
      BoxPlotPoint(label: 'Children%', values: childrenPcts),
    ];
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
          Icon(Icons.equalizer, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add weekly records to see distribution charts.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
