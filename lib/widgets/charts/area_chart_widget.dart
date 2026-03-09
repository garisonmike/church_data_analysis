import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable area chart widget backed by Syncfusion.
///
/// Renders spline-area series with professional styling, interactive
/// tooltips, selection highlight, and responsive height.
class AreaChartWidget extends StatefulWidget {
  /// Series data: map of series name → data points.
  final Map<String, List<TimeSeriesPoint>> seriesData;

  /// Chart title displayed above the chart.
  final String title;

  /// Y-axis label.
  final String yAxisTitle;

  /// Fallback height when not inside a height-constrained parent.
  final double height;

  const AreaChartWidget({
    super.key,
    required this.seriesData,
    required this.title,
    this.yAxisTitle = '',
    this.height = 300,
  });

  @override
  State<AreaChartWidget> createState() => _AreaChartWidgetState();
}

class _AreaChartWidgetState extends State<AreaChartWidget> {
  static const List<Color> _kPalette = [
    Color(0xFF1565C0),
    Color(0xFF00796B),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
    Color(0xFF00838F),
    Color(0xFF4527A0),
  ];

  late final ZoomPanBehavior _zoomPan;

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
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.seriesData.entries.toList();
    final series = <SplineAreaSeries<TimeSeriesPoint, DateTime>>[];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final color = _kPalette[i % _kPalette.length];
      series.add(
        SplineAreaSeries<TimeSeriesPoint, DateTime>(
          name: entry.key,
          dataSource: entry.value,
          xValueMapper: (point, _) => point.x,
          yValueMapper: (point, _) => point.y,
          color: color,
          borderColor: color,
          borderWidth: 2,
          opacity: 0.35,
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
