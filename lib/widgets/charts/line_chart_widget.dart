import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable line chart widget backed by Syncfusion.
///
/// Renders smooth spline series over a date-time X axis with professional
/// styling, interactive tooltips, and selection highlight.
class LineChartWidget extends StatelessWidget {
  /// Series data: map of series name → data points.
  final Map<String, List<TimeSeriesPoint>> seriesData;

  /// Chart title displayed above the chart.
  final String title;

  /// Y-axis label.
  final String yAxisTitle;

  /// Fallback height when the widget is not inside a height-constrained parent.
  final double height;

  // Professional colour palette — cycles when there are more series than colours.
  static const List<Color> _kPalette = [
    Color(0xFF1565C0), // blue
    Color(0xFF00796B), // teal
    Color(0xFFE65100), // deep-orange
    Color(0xFF6A1B9A), // purple
    Color(0xFFC62828), // red
    Color(0xFF2E7D32), // green
    Color(0xFF00838F), // cyan
    Color(0xFF4527A0), // deep-purple
  ];

  const LineChartWidget({
    super.key,
    required this.seriesData,
    required this.title,
    this.yAxisTitle = '',
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final entries = seriesData.entries.toList();
    final series = <SplineSeries<TimeSeriesPoint, DateTime>>[];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final color = _kPalette[i % _kPalette.length];
      // Suppress markers for large datasets to keep rendering fast.
      final showMarkers = entry.value.length <= 52;
      series.add(
        SplineSeries<TimeSeriesPoint, DateTime>(
          name: entry.key,
          dataSource: entry.value,
          xValueMapper: (point, _) => point.x,
          yValueMapper: (point, _) => point.y,
          color: color,
          width: 2,
          markerSettings: MarkerSettings(
            isVisible: showMarkers,
            color: color,
            borderColor: color,
            width: 6,
            height: 6,
          ),
          selectionBehavior: SelectionBehavior(enable: true),
          animationDuration: 800,
          enableTooltip: true,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : height,
          child: SfCartesianChart(
            palette: _kPalette,
            title: ChartTitle(
              text: title,
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
              title: AxisTitle(text: yAxisTitle),
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
