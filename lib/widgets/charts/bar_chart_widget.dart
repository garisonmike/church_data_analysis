import 'package:church_analytics/models/charts/category_point.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable bar (column) chart widget backed by Syncfusion.
///
/// Accepts one or more named [CategoryPoint] series and renders them as
/// grouped or stacked column series over a category X axis.
class BarChartWidget extends StatelessWidget {
  /// Series data: map of series name → data points.
  final Map<String, List<CategoryPoint>> seriesData;

  /// Chart title displayed above the chart.
  final String title;

  /// Y-axis label.
  final String yAxisTitle;

  /// When true, series are stacked on top of each other.
  final bool stacked;

  /// Height of the chart. Defaults to 300.
  final double height;

  const BarChartWidget({
    super.key,
    required this.seriesData,
    required this.title,
    this.yAxisTitle = '',
    this.stacked = false,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final List<CartesianSeries<CategoryPoint, String>> series = seriesData
        .entries
        .map((entry) {
          if (stacked) {
            return StackedColumnSeries<CategoryPoint, String>(
              name: entry.key,
              dataSource: entry.value,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.value,
              enableTooltip: true,
            );
          }
          return ColumnSeries<CategoryPoint, String>(
            name: entry.key,
            dataSource: entry.value,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.value,
            enableTooltip: true,
          );
        })
        .toList();

    return SizedBox(
      height: height,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        legend: const Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: const CategoryAxis(),
        primaryYAxis: NumericAxis(title: AxisTitle(text: yAxisTitle)),
        series: series,
      ),
    );
  }
}
