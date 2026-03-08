import 'package:church_analytics/models/charts/distribution_point.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable pie chart widget backed by Syncfusion.
///
/// Accepts a list of [DistributionPoint] slices and renders them as a
/// pie series with percentage labels.
class PieChartWidget extends StatelessWidget {
  /// Data slices for the pie chart.
  final List<DistributionPoint> data;

  /// Chart title displayed above the chart.
  final String title;

  /// Height of the chart. Defaults to 300.
  final double height;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SfCircularChart(
        title: ChartTitle(text: title),
        legend: const Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: [
          PieSeries<DistributionPoint, String>(
            dataSource: data,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.value,
            dataLabelMapper: (point, _) =>
                '${point.label}\n${point.percentage.toStringAsFixed(1)}%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}
