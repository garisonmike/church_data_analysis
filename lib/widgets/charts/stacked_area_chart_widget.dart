import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A stacked area chart widget backed by Syncfusion.
///
/// Renders [StackedAreaSeries] over a date-time X axis — suitable for
/// demographic composition (MEN/WOMEN/YOUTH/CHILDREN) or income composition
/// (TITHE/OFFERINGS), showing both absolute values and their combined total.
class StackedAreaChartWidget extends StatefulWidget {
  /// Series data: map of series name → data points (must share X dates).
  final Map<String, List<TimeSeriesPoint>> seriesData;

  /// Chart title displayed above the chart.
  final String title;

  /// Y-axis label.
  final String yAxisTitle;

  /// Fallback height when not inside a height-constrained parent.
  final double height;

  const StackedAreaChartWidget({
    super.key,
    required this.seriesData,
    required this.title,
    this.yAxisTitle = '',
    this.height = 300,
  });

  @override
  State<StackedAreaChartWidget> createState() => _StackedAreaChartWidgetState();
}

class _StackedAreaChartWidgetState extends State<StackedAreaChartWidget> {
  static const List<Color> _kPalette = [
    Color(0xFF1565C0), // blue  — Men / Tithe
    Color(0xFF00796B), // teal  — Women / Offerings
    Color(0xFFE65100), // orange — Youth
    Color(0xFF6A1B9A), // purple — Children
    Color(0xFFC62828), // red
    Color(0xFF2E7D32), // green
  ];

  late final ZoomPanBehavior _zoomPan;
  late final TrackballBehavior _trackball;

  @override
  void initState() {
    super.initState();
    _zoomPan = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
      enableMouseWheelZooming: true,
    );
    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(
        format: 'series.name : point.y',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.seriesData.entries.toList();
    final series = <StackedAreaSeries<TimeSeriesPoint, DateTime>>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final color = _kPalette[i % _kPalette.length];
      series.add(
        StackedAreaSeries<TimeSeriesPoint, DateTime>(
          name: entry.key,
          dataSource: entry.value,
          xValueMapper: (point, _) => point.x,
          yValueMapper: (point, _) => point.y,
          color: color,
          borderColor: color,
          borderWidth: 1.5,
          opacity: 0.8,
          selectionBehavior: SelectionBehavior(enable: true),
          animationDuration: 800,
          enableTooltip: true,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight
              ? constraints.maxHeight
              : widget.height,
          child: SfCartesianChart(
            zoomPanBehavior: _zoomPan,
            trackballBehavior: _trackball,
            palette: _kPalette,
            title: ChartTitle(
              text: widget.title,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'series.name : point.y',
              duration: 2000,
            ),
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat.MMMd(),
              intervalType: DateTimeIntervalType.auto,
              maximumLabels: 8,
              labelRotation: -45,
              labelStyle: const TextStyle(fontSize: 10),
              majorGridLines: const MajorGridLines(
                width: 0.5,
                dashArray: <double>[4, 4],
              ),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: widget.yAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            plotAreaBorderWidth: 0,
            series: series,
          ),
        );
      },
    );
  }
}
