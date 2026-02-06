import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/weekly_record.dart';
import '../../services/settings_service.dart';
import '../../services/weekly_records_provider.dart';
import '../widgets/responsive_chart_container.dart';
import '../widgets/time_range_selector.dart';

// Metric definition for dropdown selections
class ChartMetric {
  final String key;
  final String displayName;
  final String Function(WeeklyRecord) valueExtractor;
  final bool isCurrency;

  const ChartMetric({
    required this.key,
    required this.displayName,
    required this.valueExtractor,
    this.isCurrency = false,
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
    isCurrency: true,
  ),
  ChartMetric(
    key: 'offerings',
    displayName: 'Offerings',
    valueExtractor: (record) => record.offerings.toString(),
    isCurrency: true,
  ),
  ChartMetric(
    key: 'emergencyCollection',
    displayName: 'Emergency Collection',
    valueExtractor: (record) => record.emergencyCollection.toString(),
    isCurrency: true,
  ),
  ChartMetric(
    key: 'plannedCollection',
    displayName: 'Planned Collection',
    valueExtractor: (record) => record.plannedCollection.toString(),
    isCurrency: true,
  ),
  ChartMetric(
    key: 'totalIncome',
    displayName: 'Total Income',
    valueExtractor: (record) => record.totalIncome.toString(),
    isCurrency: true,
  ),
];

enum ChartType { scatter, line, bar }

// StateNotifier for persisting metric selections
class MetricSelectionNotifier extends StateNotifier<ChartMetric?> {
  final String _key;

  MetricSelectionNotifier(this._key, ChartMetric? initial) : super(initial) {
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final metricKey = prefs.getString(_key);
    if (metricKey != null) {
      final metric = availableMetrics.firstWhere(
        (m) => m.key == metricKey,
        orElse: () => availableMetrics.first,
      );
      state = metric;
    }
  }

  Future<void> setMetric(ChartMetric? metric) async {
    state = metric;
    if (metric != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, metric.key);
    }
  }
}

// StateNotifier for persisting chart type
class ChartTypeNotifier extends StateNotifier<ChartType> {
  static const String _key = 'custom_chart_type';

  ChartTypeNotifier() : super(ChartType.scatter) {
    _loadChartType();
  }

  Future<void> _loadChartType() async {
    final prefs = await SharedPreferences.getInstance();
    final typeIndex = prefs.getInt(_key);
    if (typeIndex != null && typeIndex < ChartType.values.length) {
      state = ChartType.values[typeIndex];
    }
  }

  Future<void> setChartType(ChartType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, type.index);
  }
}

// Providers for the graph builder state with persistence
final xAxisMetricProvider =
    StateNotifierProvider<MetricSelectionNotifier, ChartMetric?>(
      (ref) => MetricSelectionNotifier('custom_chart_x_axis', null),
    );

final yAxisMetricProvider =
    StateNotifierProvider<MetricSelectionNotifier, ChartMetric?>(
      (ref) => MetricSelectionNotifier('custom_chart_y_axis', null),
    );

final chartTypeProvider = StateNotifierProvider<ChartTypeNotifier, ChartType>(
  (ref) => ChartTypeNotifier(),
);

class CustomGraphBuilderScreen extends ConsumerWidget {
  final int churchId;

  const CustomGraphBuilderScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final xMetric = ref.watch(xAxisMetricProvider);
    final yMetric = ref.watch(yAxisMetricProvider);

    // Check for validation issues
    final bool hasInvalidSelection =
        xMetric != null && yMetric != null && xMetric.key == yMetric.key;

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

                // Validation warning
                if (hasInvalidSelection) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Please select different metrics for X and Y axes',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Chart area
          Expanded(child: _buildChart(ref, theme, hasInvalidSelection)),
        ],
      ),
    );
  }

  Widget _buildMetricSelector(
    String label,
    StateNotifierProvider<MetricSelectionNotifier, ChartMetric?> provider,
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
            ref.read(provider.notifier).setMetric(metric);
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
            ref
                .read(chartTypeProvider.notifier)
                .setChartType(newSelection.first);
          },
        ),
      ],
    );
  }

  Widget _buildChart(WidgetRef ref, ThemeData theme, bool hasInvalidSelection) {
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

          // Show validation message if same metric selected
          if (hasInvalidSelection) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cannot plot the same metric on both axes',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please select different metrics',
                    style: TextStyle(fontSize: 14),
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
            ref,
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
    WidgetRef ref,
  ) {
    final data = records
        .map(
          (record) =>
              FlSpot(xMetric.getValue(record), yMetric.getValue(record)),
        )
        .toList();

    switch (chartType) {
      case ChartType.scatter:
        return _buildScatterChart(data, xMetric, yMetric, theme, ref);
      case ChartType.line:
        return _buildLineChart(data, xMetric, yMetric, theme, ref);
      case ChartType.bar:
        return _buildBarChart(records, xMetric, yMetric, theme, ref);
    }
  }

  String _formatAxisValue(double value, ChartMetric metric, WidgetRef ref) {
    if (metric.isCurrency) {
      final settings = ref.watch(appSettingsProvider);
      return '${settings.currency.symbol}${value.toInt()}';
    }
    return value.toInt().toString();
  }

  String _getAxisLabel(ChartMetric metric, WidgetRef ref) {
    if (metric.isCurrency) {
      final settings = ref.watch(appSettingsProvider);
      return '${metric.displayName} (${settings.currency.symbol})';
    }
    return metric.displayName;
  }

  Widget _buildScatterChart(
    List<FlSpot> data,
    ChartMetric xMetric,
    ChartMetric yMetric,
    ThemeData theme,
    WidgetRef ref,
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
                _getAxisLabel(xMetric, ref),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatAxisValue(value, xMetric, ref),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                _getAxisLabel(yMetric, ref),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatAxisValue(value, yMetric, ref),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
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
    WidgetRef ref,
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
                _getAxisLabel(xMetric, ref),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatAxisValue(value, xMetric, ref),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                _getAxisLabel(yMetric, ref),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatAxisValue(value, yMetric, ref),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
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
    WidgetRef ref,
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
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < records.length) {
                    final xValue = xMetric.getValue(records[index]);
                    return Text(
                      _formatAxisValue(xValue, xMetric, ref),
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
                _getAxisLabel(yMetric, ref),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatAxisValue(value, yMetric, ref),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
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
