import 'package:church_analytics/graph_modules/graph_definition.dart';
import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/ui/widgets/charts/charts.dart';
import 'package:church_analytics/ui/widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Assembles the forecast and advanced-analysis graphs shown on the
/// Advanced Charts screen: attendance projection, moving average, the
/// attendance-versus-funds heatmap, IQR outlier detection, and ratio
/// comparisons.
class ForecastGraphsModule {
  const ForecastGraphsModule._();

  static List<GraphDefinition> build(List<WeeklyRecord> records) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    return [
      GraphDefinition(
        id: 'attendance_forecast',
        title: 'Attendance Forecast (4-Week Projection)',
        builder: (context) => LineChartWidget(
          seriesData: analytics.attendanceForecast(sorted),
          title: 'Attendance Forecast (4-Week Projection)',
          yAxisTitle: 'Attendance',
        ),
      ),
      GraphDefinition(
        id: 'attendance_moving_average',
        title: 'Attendance Moving Average (3-Week)',
        builder: (context) => LineChartWidget(
          seriesData: analytics.attendanceMovingAverage(sorted),
          title: 'Attendance Moving Average (3-Week)',
          yAxisTitle: 'Attendance',
        ),
      ),
      GraphDefinition(
        id: 'attendance_income_heatmap',
        title: 'Attendance vs Funds Heatmap',
        minHeight: 240,
        maxHeight: 440,
        aspectRatio: 16 / 10,
        builder: (context) => _HeatmapChart(records: sorted),
      ),
      GraphDefinition(
        id: 'attendance_outliers',
        title: 'Attendance with Outlier Detection',
        builder: (context) => _OutliersChart(records: sorted),
      ),
      GraphDefinition(
        id: 'all_ratios_comparison',
        title: 'All Ratios Comparison Per Week',
        builder: (context) => BarChartWidget(
          seriesData: analytics.allRatiosPerWeek(sorted),
          title: 'All Ratios Comparison Per Week',
          yAxisTitle: 'Ratio',
        ),
      ),
    ];
  }
}

// ─── Heatmap (custom Flutter widget) ─────────────────────────────────────────

class _HeatmapChart extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _HeatmapChart({required this.records});

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0) return Colors.grey.shade100;
    return Color.lerp(Colors.blue.shade100, Colors.blue.shade900, intensity)!;
  }

  @override
  Widget build(BuildContext context) {
    final maxAttendance = records.fold(
      0,
      (max, r) => r.totalAttendance > max ? r.totalAttendance : max,
    );
    final maxIncome = records.fold(
      0.0,
      (max, r) => r.totalIncome > max ? r.totalIncome : max,
    );

    const gridSize = 5;
    final attendanceBucket = maxAttendance == 0
        ? 1.0
        : maxAttendance / gridSize;
    final incomeBucket = maxIncome == 0 ? 1.0 : maxIncome / gridSize;

    final grid = List.generate(gridSize, (_) => List<int>.filled(gridSize, 0));
    for (final record in records) {
      final ai = ((record.totalAttendance / attendanceBucket).floor()).clamp(
        0,
        gridSize - 1,
      );
      final ii = ((record.totalIncome / incomeBucket).floor()).clamp(
        0,
        gridSize - 1,
      );
      grid[gridSize - 1 - ii][ai]++;
    }
    final maxCount = grid.fold(
      0,
      (max, row) => row.fold(max, (m, v) => v > m ? v : m),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance vs Funds Heatmap',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Color intensity shows the relationship between attendance and income',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'Income Range',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Attendance Range',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Column(
                            children: List.generate(gridSize, (row) {
                              return Expanded(
                                child: Row(
                                  children: List.generate(gridSize, (col) {
                                    final count = grid[row][col];
                                    final intensity = maxCount > 0
                                        ? count / maxCount
                                        : 0.0;
                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: _getHeatmapColor(intensity),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: count > 0
                                              ? Text(
                                                  count.toString(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: intensity > 0.5
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(Colors.grey.shade100, 'Low'),
                const SizedBox(width: 16),
                _legendItem(Colors.blue.shade400, 'Medium'),
                const SizedBox(width: 16),
                _legendItem(Colors.blue.shade900, 'High'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ─── Outliers Chart ──────────────────────────────────────────────────────────

class _OutliersChart extends StatefulWidget {
  final List<WeeklyRecord> records;
  const _OutliersChart({required this.records});

  @override
  State<_OutliersChart> createState() => _OutliersChartState();
}

class _OutliersChartState extends State<_OutliersChart> {
  late final TrackballBehavior _trackball;
  late final Map<String, List<TimeSeriesPoint>> _seriesData;
  int _outlierCount = 0;

  @override
  void initState() {
    super.initState();
    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        color: Color(0xFF1565C0),
      ),
    );
    final analytics = AnalyticsService();
    _seriesData = analytics.attendanceWithOutliers(widget.records);
    _outlierCount = _seriesData['Outliers']?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final normalPts = _seriesData['Normal'] ?? [];
    final outlierPts = _seriesData['Outliers'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance with Outlier Detection',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Outliers detected using IQR method (values beyond 1.5 × IQR)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CtrlScrollZoomWrapper(
                builder: (ctrlHeld) => SfCartesianChart(
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true,
                    enableDoubleTapZooming: true,
                    enablePanning: true,
                    zoomMode: ZoomMode.x,
                    enableMouseWheelZooming: ctrlHeld,
                  ),
                  trackballBehavior: _trackball,
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                  ),
                  primaryXAxis: const DateTimeAxis(
                    intervalType: DateTimeIntervalType.days,
                    interval: 7,
                  ),
                  primaryYAxis: const NumericAxis(
                    title: AxisTitle(text: 'Attendance'),
                  ),
                  series: [
                    SplineSeries<TimeSeriesPoint, DateTime>(
                      name: 'Normal',
                      dataSource: normalPts,
                      xValueMapper: (p, _) => p.x,
                      yValueMapper: (p, _) => p.y,
                      color: const Color(0xFF1565C0),
                      width: 2,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        shape: DataMarkerType.circle,
                      ),
                    ),
                    ScatterSeries<TimeSeriesPoint, DateTime>(
                      name: 'Outliers',
                      dataSource: outlierPts,
                      xValueMapper: (p, _) => p.x,
                      yValueMapper: (p, _) => p.y,
                      color: const Color(0xFFC62828),
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        height: 12,
                        width: 12,
                        shape: DataMarkerType.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_outlierCount > 0) ...[
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
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$_outlierCount outlier${_outlierCount > 1 ? "s" : ""} detected. These weeks had unusually high or low attendance.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
