import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/weekly_record.dart';
import '../../services/settings_service.dart';
import '../../services/weekly_records_provider.dart';
import '../widgets/responsive_chart_container.dart';
import '../widgets/time_range_selector.dart';

// Metric definition for dropdown selections
class ChartMetric {
  final String key;
  final String displayName;
  final double Function(WeeklyRecord) getValue;
  final bool isCurrency;

  const ChartMetric({
    required this.key,
    required this.displayName,
    required this.getValue,
    this.isCurrency = false,
  });
}

// Available metrics from WeeklyRecord model
final List<ChartMetric> availableMetrics = [
  ChartMetric(
    key: 'men',
    displayName: 'Men',
    getValue: (r) => r.men.toDouble(),
  ),
  ChartMetric(
    key: 'women',
    displayName: 'Women',
    getValue: (r) => r.women.toDouble(),
  ),
  ChartMetric(
    key: 'youth',
    displayName: 'Youth',
    getValue: (r) => r.youth.toDouble(),
  ),
  ChartMetric(
    key: 'children',
    displayName: 'Children',
    getValue: (r) => r.children.toDouble(),
  ),
  ChartMetric(
    key: 'sundayHomeChurch',
    displayName: 'Sunday Home Church',
    getValue: (r) => r.sundayHomeChurch.toDouble(),
  ),
  ChartMetric(
    key: 'totalAttendance',
    displayName: 'Total Attendance',
    getValue: (r) => r.totalAttendance.toDouble(),
  ),
  ChartMetric(
    key: 'tithe',
    displayName: 'Tithe',
    getValue: (r) => r.tithe.toDouble(),
    isCurrency: true,
  ),
  ChartMetric(
    key: 'offerings',
    displayName: 'Offerings',
    getValue: (r) => r.offerings.toDouble(),
    isCurrency: true,
  ),
  ChartMetric(
    key: 'emergencyCollection',
    displayName: 'Emergency Collection',
    getValue: (r) => r.emergencyCollection.toDouble(),
    isCurrency: true,
  ),
  ChartMetric(
    key: 'plannedCollection',
    displayName: 'Planned Collection',
    getValue: (r) => r.plannedCollection.toDouble(),
    isCurrency: true,
  ),
  ChartMetric(
    key: 'totalIncome',
    displayName: 'Total Income',
    getValue: (r) => r.totalIncome.toDouble(),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 840) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMetricSelector(
                            'X-Axis Metric',
                            xAxisMetricProvider,
                            ref,
                          ),
                          const SizedBox(height: 12),
                          _buildMetricSelector(
                            'Y-Axis Metric',
                            yAxisMetricProvider,
                            ref,
                          ),
                        ],
                      );
                    }
                    return Row(
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
                    );
                  },
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
    final currencySymbol = (xMetric.isCurrency || yMetric.isCurrency)
        ? ref.watch(appSettingsProvider).currency.symbol
        : '';
    return _DynamicChart(
      records: records,
      xMetric: xMetric,
      yMetric: yMetric,
      chartType: chartType,
      theme: theme,
      currencySymbol: currencySymbol,
    );
  }
}

// ─── Syncfusion dynamic chart widget ─────────────────────────────────────────

class _DynamicChart extends StatefulWidget {
  final List<WeeklyRecord> records;
  final ChartMetric xMetric;
  final ChartMetric yMetric;
  final ChartType chartType;
  final ThemeData theme;
  final String currencySymbol;

  const _DynamicChart({
    required this.records,
    required this.xMetric,
    required this.yMetric,
    required this.chartType,
    required this.theme,
    required this.currencySymbol,
  });

  @override
  State<_DynamicChart> createState() => _DynamicChartState();
}

class _DynamicChartState extends State<_DynamicChart> {
  late final ZoomPanBehavior _zoomPan;
  late final TrackballBehavior _trackball;

  @override
  void initState() {
    super.initState();
    _zoomPan = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enablePanning: true,
      enableMouseWheelZooming: true,
    );
    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(enable: true),
    );
  }

  String _axisTitle(ChartMetric metric) {
    if (metric.isCurrency && widget.currencySymbol.isNotEmpty) {
      return '${metric.displayName} (${widget.currencySymbol})';
    }
    return metric.displayName;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.chartType) {
      case ChartType.scatter:
        return _buildScatter();
      case ChartType.line:
        return _buildLine();
      case ChartType.bar:
        return _buildBar();
    }
  }

  Widget _buildScatter() {
    return SfCartesianChart(
      zoomPanBehavior: _zoomPan,
      trackballBehavior: _trackball,
      primaryXAxis: NumericAxis(
        title: AxisTitle(text: _axisTitle(widget.xMetric)),
        decimalPlaces: 0,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: _axisTitle(widget.yMetric)),
        decimalPlaces: 0,
      ),
      series: [
        ScatterSeries<WeeklyRecord, double>(
          dataSource: widget.records,
          xValueMapper: (r, _) => widget.xMetric.getValue(r),
          yValueMapper: (r, _) => widget.yMetric.getValue(r),
          color: widget.theme.colorScheme.primary,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 10,
            width: 10,
            shape: DataMarkerType.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildLine() {
    final sorted = List<WeeklyRecord>.from(widget.records)
      ..sort(
        (a, b) =>
            widget.xMetric.getValue(a).compareTo(widget.xMetric.getValue(b)),
      );
    return SfCartesianChart(
      zoomPanBehavior: _zoomPan,
      trackballBehavior: _trackball,
      primaryXAxis: NumericAxis(
        title: AxisTitle(text: _axisTitle(widget.xMetric)),
        decimalPlaces: 0,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: _axisTitle(widget.yMetric)),
        decimalPlaces: 0,
      ),
      series: [
        SplineSeries<WeeklyRecord, double>(
          dataSource: sorted,
          xValueMapper: (r, _) => widget.xMetric.getValue(r),
          yValueMapper: (r, _) => widget.yMetric.getValue(r),
          color: widget.theme.colorScheme.primary,
          width: 2,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildBar() {
    final fmt = DateFormat.MMMd();
    return SfCartesianChart(
      zoomPanBehavior: _zoomPan,
      trackballBehavior: _trackball,
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: widget.xMetric.displayName),
        labelStyle: const TextStyle(fontSize: 10),
        labelRotation: -45,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: _axisTitle(widget.yMetric)),
        decimalPlaces: 0,
      ),
      series: [
        ColumnSeries<WeeklyRecord, String>(
          dataSource: widget.records,
          xValueMapper: (r, _) => fmt.format(r.weekStartDate),
          yValueMapper: (r, _) => widget.yMetric.getValue(r),
          color: widget.theme.colorScheme.primary,
        ),
      ],
    );
  }
}
