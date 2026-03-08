import 'package:church_analytics/models/charts/distribution_point.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable pie chart widget backed by Syncfusion.
///
/// Renders distribution slices with percentage labels, selection highlight,
/// curved connector lines, and a professional colour palette.
class PieChartWidget extends StatelessWidget {
  /// Data slices for the pie chart.
  final List<DistributionPoint> data;

  /// Chart title displayed above the chart.
  final String title;

  /// Fallback height when not inside a height-constrained parent.
  final double height;

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

  const PieChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : height,
          child: SfCircularChart(
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
              format: 'point.x : point.y',
              duration: 2000,
            ),
            series: [
              PieSeries<DistributionPoint, String>(
                dataSource: data,
                xValueMapper: (point, _) => point.label,
                yValueMapper: (point, _) => point.value,
                dataLabelMapper: (point, _) =>
                    '${point.percentage.toStringAsFixed(1)}%',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                    length: '15%',
                  ),
                  textStyle: TextStyle(fontSize: 11),
                ),
                explode: true,
                explodeGesture: ActivationMode.singleTap,
                radius: '80%',
                selectionBehavior: SelectionBehavior(enable: true),
                animationDuration: 800,
                enableTooltip: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
