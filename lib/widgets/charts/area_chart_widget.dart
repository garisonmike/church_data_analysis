import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable area chart widget backed by Syncfusion.
///
/// Accepts one or more named [TimeSeriesPoint] series and renders them as
/// spline area series — matching the filled trend lines in `data.py`.
class AreaChartWidget extends StatelessWidget {
  /// Series data: map of series name → data points.
  final Map<String, List<TimeSeriesPoint>> seriesData;

  /// Chart title displayed above the chart.
  final String title;

  /// Y-axis label.
  final String yAxisTitle;

  /// Height of the chart. Defaults to 300.
  final double height;

  const AreaChartWidget({
    super.key,
    required this.seriesData,
    required this.title,
    this.yAxisTitle = '',
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final series = seriesData.entries.map((entry) {
      return SplineAreaSeries<TimeSeriesPoint, DateTime>(
        name: entry.key,
        dataSource: entry.value,
        xValueMapper: (point, _) => point.x,
        yValueMapper: (point, _) => point.y,
        opacity: 0.4,
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
