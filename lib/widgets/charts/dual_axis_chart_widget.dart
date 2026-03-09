import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A dual Y-axis chart widget backed by Syncfusion.
///
/// Renders [primarySeries] on the left Y axis and [secondarySeries] on the
/// right (opposed) Y axis — ideal for overlaying e.g. attendance counts and
/// income amounts that live on vastly different numeric scales.
class DualAxisChartWidget extends StatefulWidget {
  /// Series rendered on the primary (left) Y axis.
  final Map<String, List<TimeSeriesPoint>> primarySeries;

  /// Series rendered on the secondary (right) Y axis.
  final Map<String, List<TimeSeriesPoint>> secondarySeries;

  /// Chart title.
  final String title;

  /// Label for the primary (left) Y axis.
  final String primaryAxisTitle;

  /// Label for the secondary (right) Y axis.
  final String secondaryAxisTitle;

  /// Fallback height when not inside a height-constrained parent.
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

  @override
  State<DualAxisChartWidget> createState() => _DualAxisChartWidgetState();
}

class _DualAxisChartWidgetState extends State<DualAxisChartWidget> {
  // Primary series colours (cool, solid lines — attendance).
  static const List<Color> _kPrimary = [
    Color(0xFF1565C0), // blue
    Color(0xFF00796B), // teal
    Color(0xFF6A1B9A), // purple
  ];

  // Secondary series colours (warm, dashed lines — income).
  static const List<Color> _kSecondary = [
    Color(0xFFE65100), // deep-orange
    Color(0xFFC62828), // red
    Color(0xFF2E7D32), // green
  ];

  static const String _kSecondaryAxisName = 'secondaryYAxis';

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

  List<CartesianSeries<TimeSeriesPoint, DateTime>> _buildSeries() {
    final allSeries = <CartesianSeries<TimeSeriesPoint, DateTime>>[];

    // Primary axis series — solid spline.
    final primaryEntries = widget.primarySeries.entries.toList();
    for (int i = 0; i < primaryEntries.length; i++) {
      final entry = primaryEntries[i];
      final color = _kPrimary[i % _kPrimary.length];
      allSeries.add(
        SplineSeries<TimeSeriesPoint, DateTime>(
          name: entry.key,
          dataSource: entry.value,
          xValueMapper: (p, _) => p.x,
          yValueMapper: (p, _) => p.y,
          color: color,
          width: 2.5,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: color,
            borderColor: color,
            width: 7,
            height: 7,
          ),
          selectionBehavior: SelectionBehavior(enable: true),
          animationDuration: 800,
          enableTooltip: true,
        ),
      );
    }

    // Secondary axis series — dashed spline on opposed axis.
    final secondaryEntries = widget.secondarySeries.entries.toList();
    for (int i = 0; i < secondaryEntries.length; i++) {
      final entry = secondaryEntries[i];
      final color = _kSecondary[i % _kSecondary.length];
      allSeries.add(
        SplineSeries<TimeSeriesPoint, DateTime>(
          name: entry.key,
          dataSource: entry.value,
          xValueMapper: (p, _) => p.x,
          yValueMapper: (p, _) => p.y,
          yAxisName: _kSecondaryAxisName,
          color: color,
          width: 2.5,
          dashArray: const <double>[6, 4],
          markerSettings: MarkerSettings(
            isVisible: true,
            color: color,
            borderColor: color,
            shape: DataMarkerType.diamond,
            width: 8,
            height: 8,
          ),
          selectionBehavior: SelectionBehavior(enable: true),
          animationDuration: 800,
          enableTooltip: true,
        ),
      );
    }

    return allSeries;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight
              ? constraints.maxHeight
              : widget.height,
          child: SfCartesianChart(
            zoomPanBehavior: _zoomPan,
            trackballBehavior: _trackball,
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
            axes: [
              NumericAxis(
                name: _kSecondaryAxisName,
                opposedPosition: true,
                title: AxisTitle(text: widget.secondaryAxisTitle),
                numberFormat: NumberFormat.compact(),
                labelStyle: const TextStyle(fontSize: 10),
                axisLine: const AxisLine(color: Color(0xFFE65100), width: 1.5),
                majorTickLines: const MajorTickLines(color: Color(0xFFE65100)),
              ),
            ],
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
              title: AxisTitle(text: widget.primaryAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
              axisLine: const AxisLine(color: Color(0xFF1565C0), width: 1.5),
              majorTickLines: const MajorTickLines(color: Color(0xFF1565C0)),
            ),
            plotAreaBorderWidth: 0,
            series: _buildSeries(),
          ),
        );
      },
    );
  }
}
