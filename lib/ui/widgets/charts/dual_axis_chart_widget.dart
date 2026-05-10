import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:church_analytics/ui/widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Dual Y-axis chart. Mouse-wheel zoom gated behind Ctrl key.
class DualAxisChartWidget extends StatelessWidget {
  final Map<String, List<TimeSeriesPoint>> primarySeries;
  final Map<String, List<TimeSeriesPoint>> secondarySeries;
  final String title;
  final String primaryAxisTitle;
  final String secondaryAxisTitle;
  final double height;

  const DualAxisChartWidget({
    super.key,
    required this.primarySeries,
    required this.secondarySeries,
    required this.title,
    this.primaryAxisTitle = '',
    this.secondaryAxisTitle = '',
    this.height = 300,
  });

  static const List<Color> _kPrimary = [
    Color(0xFF1565C0), Color(0xFF00796B), Color(0xFF6A1B9A),
  ];
  static const List<Color> _kSecondary = [
    Color(0xFFE65100), Color(0xFFC62828), Color(0xFF2E7D32),
  ];
  static const String _kSecondaryAxisName = 'secondaryYAxis';

  List<CartesianSeries<TimeSeriesPoint, DateTime>> _buildSeries() {
    final all = <CartesianSeries<TimeSeriesPoint, DateTime>>[];
    final pEntries = primarySeries.entries.toList();
    for (int i = 0; i < pEntries.length; i++) {
      final e = pEntries[i];
      final c = _kPrimary[i % _kPrimary.length];
      all.add(SplineSeries<TimeSeriesPoint, DateTime>(
        name: e.key,
        dataSource: e.value,
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
        color: c, width: 2.5,
        markerSettings: MarkerSettings(isVisible: true, color: c, borderColor: c, width: 7, height: 7),
        selectionBehavior: SelectionBehavior(enable: true),
        animationDuration: 800, enableTooltip: true,
      ));
    }
    final sEntries = secondarySeries.entries.toList();
    for (int i = 0; i < sEntries.length; i++) {
      final e = sEntries[i];
      final c = _kSecondary[i % _kSecondary.length];
      all.add(SplineSeries<TimeSeriesPoint, DateTime>(
        name: e.key,
        dataSource: e.value,
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
        yAxisName: _kSecondaryAxisName,
        color: c, width: 2.5,
        dashArray: const <double>[6, 4],
        markerSettings: MarkerSettings(isVisible: true, color: c, borderColor: c, shape: DataMarkerType.diamond, width: 8, height: 8),
        selectionBehavior: SelectionBehavior(enable: true),
        animationDuration: 800, enableTooltip: true,
      ));
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(format: 'series.name : point.y'),
    );
    return CtrlScrollZoomWrapper(
      builder: (ctrlHeld) {
        final zoomPan = ZoomPanBehavior(
          enablePinching: true, enableDoubleTapZooming: true,
          enablePanning: true, zoomMode: ZoomMode.x,
          enableMouseWheelZooming: ctrlHeld,
        );
        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.hasBoundedHeight ? constraints.maxHeight : height,
            child: SfCartesianChart(
              zoomPanBehavior: zoomPan,
              trackballBehavior: trackball,
              title: ChartTitle(text: title, textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              legend: const Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
              tooltipBehavior: TooltipBehavior(enable: true, format: 'series.name : point.y', duration: 2000),
              axes: [
                NumericAxis(
                  name: _kSecondaryAxisName, opposedPosition: true,
                  title: AxisTitle(text: secondaryAxisTitle),
                  numberFormat: NumberFormat.compact(),
                  labelStyle: const TextStyle(fontSize: 10),
                  axisLine: const AxisLine(color: Color(0xFFE65100), width: 1.5),
                  majorTickLines: const MajorTickLines(color: Color(0xFFE65100)),
                ),
              ],
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.MMMd(), intervalType: DateTimeIntervalType.auto,
                maximumLabels: 8, labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 10),
                majorGridLines: const MajorGridLines(width: 0.5, dashArray: <double>[4, 4]),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: primaryAxisTitle),
                numberFormat: NumberFormat.compact(),
                labelStyle: const TextStyle(fontSize: 10),
                axisLine: const AxisLine(color: Color(0xFF1565C0), width: 1.5),
                majorTickLines: const MajorTickLines(color: Color(0xFF1565C0)),
              ),
              plotAreaBorderWidth: 0,
              series: _buildSeries(),
            ),
          ),
        );
      },
    );
  }
}
