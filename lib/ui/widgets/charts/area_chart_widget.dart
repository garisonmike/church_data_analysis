import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:church_analytics/ui/widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable area chart widget backed by Syncfusion.
/// Mouse-wheel zooming is gated behind Ctrl to avoid conflict with page scroll.
class AreaChartWidget extends StatelessWidget {
  final Map<String, List<TimeSeriesPoint>> seriesData;
  final String title;
  final String yAxisTitle;
  final double height;

  const AreaChartWidget({
    super.key,
    required this.seriesData,
    required this.title,
    this.yAxisTitle = '',
    this.height = 300,
  });

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

  @override
  Widget build(BuildContext context) {
    final entries = seriesData.entries.toList();
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

    return CtrlScrollZoomWrapper(
      builder: (ctrlHeld) {
        final zoomPan = ZoomPanBehavior(
          enablePinching: true,
          enableDoubleTapZooming: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
          enableMouseWheelZooming: ctrlHeld,
        );
        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.hasBoundedHeight ? constraints.maxHeight : height,
            child: SfCartesianChart(
              zoomPanBehavior: zoomPan,
              palette: _kPalette,
              title: ChartTitle(
                text: title,
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                title: AxisTitle(text: yAxisTitle),
                numberFormat: NumberFormat.compact(),
                labelStyle: const TextStyle(fontSize: 10),
              ),
              plotAreaBorderWidth: 0,
              series: series,
            ),
          ),
        );
      },
    );
  }
}
