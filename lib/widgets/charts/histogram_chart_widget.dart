import 'package:church_analytics/models/charts/category_point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable histogram chart widget backed by Syncfusion.
///
/// Renders binned frequency data as column bars with optional mean and
/// median reference lines via strip lines.
class HistogramChartWidget extends StatefulWidget {
  final List<CategoryPoint> data;
  final String title;
  final String yAxisTitle;
  final double? meanValue;
  final double? medianValue;
  final double height;

  const HistogramChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.yAxisTitle = 'Frequency',
    this.meanValue,
    this.medianValue,
    this.height = 300,
  });

  @override
  State<HistogramChartWidget> createState() => _HistogramChartWidgetState();
}

class _HistogramChartWidgetState extends State<HistogramChartWidget> {
  late final ZoomPanBehavior _zoomPan;

  @override
  void initState() {
    super.initState();
    _zoomPan = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enablePanning: true,
      enableMouseWheelZooming: true,
    );
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
            title: ChartTitle(
              text: widget.title,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : point.y',
              duration: 2000,
            ),
            primaryXAxis: const CategoryAxis(
              labelRotation: -45,
              labelStyle: TextStyle(fontSize: 10),
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: widget.yAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            plotAreaBorderWidth: 0,
            series: <CartesianSeries<CategoryPoint, String>>[
              ColumnSeries<CategoryPoint, String>(
                dataSource: widget.data,
                xValueMapper: (point, _) => point.label,
                yValueMapper: (point, _) => point.value,
                color: const Color(0xFF1565C0),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                animationDuration: 600,
                enableTooltip: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
