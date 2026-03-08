import 'package:church_analytics/models/charts/category_point.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:church_analytics/widgets/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Comprehensive analytics dashboard that renders all core graphs derived
/// from the `data.py` reference implementation using Syncfusion charts.
class AnalyticsDashboard extends ConsumerWidget {
  final int churchId;

  const AnalyticsDashboard({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTimeRange = ref.watch(chartTimeRangeProvider);
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 480;
    final isMedium = width >= 480 && width < 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isNarrow)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.date_range),
                tooltip: 'Select time range',
                onPressed: () async {
                  final RenderBox button =
                      context.findRenderObject()! as RenderBox;
                  final RenderBox overlay =
                      Navigator.of(context).overlay!.context.findRenderObject()!
                          as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(
                        button.size.bottomRight(Offset.zero),
                        ancestor: overlay,
                      ),
                    ),
                    Offset.zero & overlay.size,
                  );
                  final ChartTimeRange? selected =
                      await showMenu<ChartTimeRange>(
                        context: context,
                        position: position,
                        initialValue: currentTimeRange,
                        items: ChartTimeRange.values
                            .map(
                              (range) => PopupMenuItem<ChartTimeRange>(
                                value: range,
                                child: Text(range.displayName),
                              ),
                            )
                            .toList(),
                      );
                  if (selected != null) {
                    ref.read(chartTimeRangeProvider.notifier).state = selected;
                  }
                },
              ),
            )
          else if (isMedium)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: TimeRangeSelector(compact: true),
              ),
            )
          else
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
            onPressed: () {
              ref.invalidate(weeklyRecordsForChurchProvider(churchId));
            },
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
            : _DashboardContent(records: records),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

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
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
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

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add weekly records to see analytics charts.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard content — Tasks 3.2 & 3.3
// ---------------------------------------------------------------------------

class _DashboardContent extends StatelessWidget {
  final List<WeeklyRecord> records;

  const _DashboardContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();
    final width = MediaQuery.of(context).size.width;
    // Wide screens (≥840 px): two-column layout for distribution charts.
    final isWide = width >= 840;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------------
          // 1. Total Attendance Trend (G01)
          // ------------------------------------------------------------------
          _SectionTitle(title: 'Total Attendance Trend'),
          const SizedBox(height: 8),
          _chartCard(
            child: ResponsiveLazyChart(
              minHeight: 250,
              maxHeight: 450,
              aspectRatio: 16 / 9,
              child: LineChartWidget(
                title: '',
                yAxisTitle: 'Attendees',
                seriesData: {'Total': analytics.totalAttendanceTrend(records)},
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ------------------------------------------------------------------
          // 2. Demographic Attendance Trends (G02/G03)
          // ------------------------------------------------------------------
          _SectionTitle(title: 'Demographic Attendance Trends'),
          const SizedBox(height: 8),
          _chartCard(
            child: ResponsiveLazyChart(
              minHeight: 280,
              maxHeight: 500,
              aspectRatio: 16 / 9,
              child: LineChartWidget(
                title: '',
                yAxisTitle: 'Attendees',
                seriesData: analytics.demographicAttendanceTrends(records),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ------------------------------------------------------------------
          // 3. Income Component Trends — stacked area (G09)
          // ------------------------------------------------------------------
          _SectionTitle(title: 'Income Component Trends'),
          const SizedBox(height: 8),
          _chartCard(
            child: ResponsiveLazyChart(
              minHeight: 250,
              maxHeight: 450,
              aspectRatio: 16 / 9,
              child: AreaChartWidget(
                title: '',
                yAxisTitle: 'Amount',
                seriesData: analytics.incomeComponentTrends(records),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ------------------------------------------------------------------
          // 4. Attendance Growth Rate (G07-style)
          // ------------------------------------------------------------------
          _SectionTitle(title: 'Attendance Growth Rate (%)'),
          const SizedBox(height: 8),
          _chartCard(
            child: ResponsiveLazyChart(
              minHeight: 220,
              maxHeight: 400,
              aspectRatio: 16 / 9,
              child: BarChartWidget(
                title: '',
                yAxisTitle: '% Change',
                seriesData: {
                  'Growth %': analytics
                      .attendanceGrowthRates(records)
                      .map((p) => CategoryPoint(label: p.x, value: p.y))
                      .toList(),
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ------------------------------------------------------------------
          // 5. Distribution charts: Demographic & Income side-by-side on wide,
          //    stacked on narrow (Tasks 3.3 responsive)
          // ------------------------------------------------------------------
          _SectionTitle(title: 'Distribution Charts'),
          const SizedBox(height: 8),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _chartCard(
                        child: ResponsiveLazyChart(
                          minHeight: 280,
                          maxHeight: 400,
                          aspectRatio: 1.2,
                          child: PieChartWidget(
                            title: 'Demographic Distribution',
                            data: analytics.demographicDistribution(records),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _chartCard(
                        child: ResponsiveLazyChart(
                          minHeight: 280,
                          maxHeight: 400,
                          aspectRatio: 1.2,
                          child: PieChartWidget(
                            title: 'Income Distribution',
                            data: analytics.incomeDistribution(records),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _chartCard(
                      child: ResponsiveLazyChart(
                        minHeight: 280,
                        maxHeight: 400,
                        aspectRatio: 1.2,
                        child: PieChartWidget(
                          title: 'Demographic Distribution',
                          data: analytics.demographicDistribution(records),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _chartCard(
                      child: ResponsiveLazyChart(
                        minHeight: 280,
                        maxHeight: 400,
                        aspectRatio: 1.2,
                        child: PieChartWidget(
                          title: 'Income Distribution',
                          data: analytics.incomeDistribution(records),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 32),

          // ------------------------------------------------------------------
          // 6. Demographic Percentage Trends — area (G15)
          // ------------------------------------------------------------------
          _SectionTitle(title: 'Demographic % of Total Over Time'),
          const SizedBox(height: 8),
          _chartCard(
            child: ResponsiveLazyChart(
              minHeight: 250,
              maxHeight: 450,
              aspectRatio: 16 / 9,
              child: AreaChartWidget(
                title: '',
                yAxisTitle: '% of Total',
                seriesData: analytics.demographicPercentageTrends(records),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ------------------------------------------------------------------
          // 7. Income per Attendee Trend (G13-style)
          // ------------------------------------------------------------------
          _SectionTitle(title: 'Income per Attendee Over Time'),
          const SizedBox(height: 8),
          _chartCard(
            child: ResponsiveLazyChart(
              minHeight: 220,
              maxHeight: 400,
              aspectRatio: 16 / 9,
              child: LineChartWidget(
                title: '',
                yAxisTitle: 'Income / Attendee',
                seriesData: {
                  'Income / Attendee': analytics.incomePerAttendeeTrend(
                    records,
                  ),
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _chartCard({required Widget child}) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title widget
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
