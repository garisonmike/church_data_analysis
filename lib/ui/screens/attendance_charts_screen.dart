import 'package:church_analytics/models/charts/category_point.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:church_analytics/widgets/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceChartsScreen extends ConsumerWidget {
  final int churchId;
  const AttendanceChartsScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Charts'),
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
            records.isEmpty ? const _EmptyView() : _AttendanceContent(records: records),
      ),
    );
  }
}

class _AttendanceContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _AttendanceContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    double avg(double Function(WeeklyRecord r) fn) =>
        sorted.isEmpty ? 0 : sorted.map(fn).reduce((a, b) => a + b) / sorted.length;

    final categoryData = {
      'Average': [
        CategoryPoint(label: 'Men', value: avg((r) => r.men.toDouble())),
        CategoryPoint(label: 'Women', value: avg((r) => r.women.toDouble())),
        CategoryPoint(label: 'Youth', value: avg((r) => r.youth.toDouble())),
        CategoryPoint(label: 'Children', value: avg((r) => r.children.toDouble())),
        CategoryPoint(label: 'Home Church', value: avg((r) => r.sundayHomeChurch.toDouble())),
      ],
    };

    final growthData = {
      'Growth %': analytics
          .attendanceGrowthRates(sorted)
          .map((p) => CategoryPoint(label: p.x, value: p.y))
          .toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ResponsiveChartContainer(
          minHeight: 220, maxHeight: 380, aspectRatio: 16 / 9,
          child: BarChartWidget(
            seriesData: categoryData,
            title: 'Average Attendance by Category',
            yAxisTitle: 'Attendance',
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveLazyChart(
          minHeight: 220, maxHeight: 380, aspectRatio: 16 / 9,
          child: LineChartWidget(
            seriesData: {'Total Attendance': analytics.totalAttendanceTrend(sorted)},
            title: 'Total Attendance Trend',
            yAxisTitle: 'Attendance',
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveLazyChart(
          minHeight: 260, maxHeight: 420, aspectRatio: 16 / 10,
          child: PieChartWidget(
            data: analytics.demographicDistribution(sorted),
            title: 'Attendance Distribution',
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveLazyChart(
          minHeight: 220, maxHeight: 380, aspectRatio: 16 / 9,
          child: BarChartWidget(
            seriesData: growthData,
            title: 'Attendance Growth Rate (%)',
            yAxisTitle: 'Growth %',
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
          Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Add weekly records to see attendance charts.',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
