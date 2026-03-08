import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable line chart widget backed by Syncfusion.
///
/// Accepts one or more named [TimeSeriesPoint] series and renders them as
/// smooth line series over a date-time X axis.
class LineChartWidget extends StatelessWidget {
  /// Series data: map of series name → data points.
  final Map<String, List<TimeSeriesPoint>> seriesData;

  /// Chart title displayed above the chart.
  final String title;

  /// Y-axis label.
  final String yAxisTitle;

  /// Height of the chart. Defaults to 300.
  final double height;

  const LineChartWidget({
    super.key,
    required this.seriesData,
    required this.title,
    this.yAxisTitle = '',
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final series = seriesData.entries.map((entry) {
      return LineSeries<TimeSeriesPoint, DateTime>(
        name: entry.key,
        dataSource: entry.value,
        xValueMapper: (point, _) => point.x,
        yValueMapper: (point, _) => point.y,
        markerSettings: const MarkerSettings(isVisible: true),
        enableTooltip: true,
      );
    }).toList();

    return SizedBox(
      height: height,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        legend: const Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: const DateTimeAxis(),
        primaryYAxis: NumericAxis(title: AxisTitle(text: yAxisTitle)),
        series: series,
      ),
    );
  }
}
