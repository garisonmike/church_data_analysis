import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/weekly_record.dart';
import '../../services/weekly_records_provider.dart';
import '../widgets/responsive_chart_container.dart';
import '../widgets/time_range_selector.dart';

// Metric definition for dropdown selections
class ChartMetric {
  final String key;
  final String displayName;
  final String Function(WeeklyRecord) valueExtractor;

  const ChartMetric({
    required this.key,
    required this.displayName,
    required this.valueExtractor,
  });

  double getValue(WeeklyRecord record) {
    final value = valueExtractor(record);
    return double.tryParse(value) ?? 0.0;
  }
}

// Available metrics from WeeklyRecord model
final List<ChartMetric> availableMetrics = [
  ChartMetric(
    key: 'men',
    displayName: 'Men',
    valueExtractor: (record) => record.men.toString(),
  ),
  ChartMetric(
    key: 'women',
    displayName: 'Women',
    valueExtractor: (record) => record.women.toString(),
  ),
  ChartMetric(
    key: 'youth',
    displayName: 'Youth',
    valueExtractor: (record) => record.youth.toString(),
  ),
  ChartMetric(
    key: 'children',
    displayName: 'Children',
    valueExtractor: (record) => record.children.toString(),
  ),
  ChartMetric(
    key: 'sundayHomeChurch',
    displayName: 'Sunday Home Church',
    valueExtractor: (record) => record.sundayHomeChurch.toString(),
  ),
  ChartMetric(
    key: 'totalAttendance',
    displayName: 'Total Attendance',
    valueExtractor: (record) => record.totalAttendance.toString(),
  ),
  ChartMetric(
    key: 'tithe',
    displayName: 'Tithe',
    valueExtractor: (record) => record.tithe.toString(),
  ),
  ChartMetric(
    key: 'offerings',
    displayName: 'Offerings',
    valueExtractor: (record) => record.offerings.toString(),
  ),
  ChartMetric(
    key: 'emergencyCollection',
    displayName: 'Emergency Collection',
    valueExtractor: (record) => record.emergencyCollection.toString(),
  ),
  ChartMetric(
    key: 'plannedCollection',
    displayName: 'Planned Collection',
    valueExtractor: (record) => record.plannedCollection.toString(),
  ),
  ChartMetric(
    key: 'totalIncome',
    displayName: 'Total Income',
    valueExtractor: (record) => record.totalIncome.toString(),
  ),
];

enum ChartType { scatter, line, bar }

// Providers for the graph builder state
final xAxisMetricProvider = StateProvider<ChartMetric?>((ref) => null);
final yAxisMetricProvider = StateProvider<ChartMetric?>((ref) => null);
final chartTypeProvider = StateProvider<ChartType>((ref) => ChartType.scatter);

class CustomGraphBuilderScreen extends ConsumerWidget {
  final int churchId;

  const CustomGraphBuilderScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Graph Builder'),
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Control panel
          Container(
            padding: const EdgeInsets.all(16.0),
            color: colorScheme.surfaceContainer,
            child: Column(
              children: [
                // Time range selector
                const TimeRangeSelector(),
                const SizedBox(height: 16),

                // Metric selectors row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricSelector(
                        'X-Axis Metric',
                        xAxisMetricProvider,
                        ref,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricSelector(
                        'Y-Axis Metric',
                        yAxisMetricProvider,
                        ref,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Chart type selector
                _buildChartTypeSelector(ref),
              ],
            ),
          ),

          // Chart area
          Expanded(child: _buildChart(ref, theme)),
        ],
      ),
    );
  }

  Widget _buildMetricSelector(
    String label,
    StateProvider<ChartMetric?> provider,
    WidgetRef ref,
  ) {
    final selectedMetric = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(ref.context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ChartMetric>(
          initialValue: selectedMetric,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text('Select metric'),
          items: availableMetrics.map((metric) {
            return DropdownMenuItem(
              value: metric,
              child: Text(metric.displayName),
            );
          }).toList(),
          onChanged: (metric) {
            ref.read(provider.notifier).state = metric;
          },
        ),
      ],
    );
  }

  Widget _buildChartTypeSelector(WidgetRef ref) {
    final selectedType = ref.watch(chartTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chart Type',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(ref.context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ChartType>(
          segments: const [
            ButtonSegment(
              value: ChartType.scatter,
              label: Text('Scatter'),
              icon: Icon(Icons.scatter_plot),
            ),
            ButtonSegment(
              value: ChartType.line,
              label: Text('Line'),
              icon: Icon(Icons.show_chart),
            ),
            ButtonSegment(
              value: ChartType.bar,
              label: Text('Bar'),
              icon: Icon(Icons.bar_chart),
            ),
          ],
          selected: {selectedType},
          onSelectionChanged: (Set<ChartType> newSelection) {
            ref.read(chartTypeProvider.notifier).state = newSelection.first;
          },
        ),
      ],
    );
  }

  Widget _buildChart(WidgetRef ref, ThemeData theme) {
    final xMetric = ref.watch(xAxisMetricProvider);
    final yMetric = ref.watch(yAxisMetricProvider);
    final chartType = ref.watch(chartTypeProvider);
    final recordsAsync = ref.watch(weeklyRecordsForChurchProvider(churchId));

    return ResponsiveChartContainer(
      child: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (records) {
          if (xMetric == null || yMetric == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timeline,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select metrics to generate chart',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (records.isEmpty) {
            return Center(
              child: Text(
                'No data available for selected time range',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            );
          }

          return _buildDynamicChart(
            records,
            xMetric,
            yMetric,
            chartType,
            theme,
          );
        },
      ),
    );
  }

  Widget _buildDynamicChart(
    List<WeeklyRecord> records,
    ChartMetric xMetric,
    ChartMetric yMetric,
    ChartType chartType,
    ThemeData theme,
  ) {
    final data = records
        .map(
          (record) =>
              FlSpot(xMetric.getValue(record), yMetric.getValue(record)),
        )
        .toList();

    switch (chartType) {
      case ChartType.scatter:
        return _buildScatterChart(data, xMetric, yMetric, theme);
      case ChartType.line:
        return _buildLineChart(data, xMetric, yMetric, theme);
      case ChartType.bar:
        return _buildBarChart(records, xMetric, yMetric, theme);
    }
  }

  Widget _buildScatterChart(
    List<FlSpot> data,
    ChartMetric xMetric,
    ChartMetric yMetric,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: data.asMap().entries.map((entry) {
            return ScatterSpot(
              entry.value.x,
              entry.value.y,
              dotPainter: FlDotCirclePainter(
                color: theme.colorScheme.primary,
                radius: 6,
              ),
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                xMetric.displayName,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              sideTitles: const SideTitles(showTitles: true),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                yMetric.displayName,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              sideTitles: const SideTitles(showTitles: true),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingVerticalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
    List<FlSpot> data,
    ChartMetric xMetric,
    ChartMetric yMetric,
    ThemeData theme,
  ) {
    // Sort data by x-axis for proper line connection
    data.sort((a, b) => a.x.compareTo(b.x));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: data,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                xMetric.displayName,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              sideTitles: const SideTitles(showTitles: true),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                yMetric.displayName,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              sideTitles: const SideTitles(showTitles: true),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingVerticalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(
    List<WeeklyRecord> records,
    ChartMetric xMetric,
    ChartMetric yMetric,
    ThemeData theme,
  ) {
    final barGroups = records.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: yMetric.getValue(record),
            color: theme.colorScheme.primary,
            width: 16,
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                '${xMetric.displayName} (Record Index)',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < records.length) {
                    final xValue = xMetric.getValue(records[index]);
                    return Text(
                      xValue.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                yMetric.displayName,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              sideTitles: const SideTitles(showTitles: true),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
