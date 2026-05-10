import 'package:church_analytics/models/charts/category_point.dart';
import 'package:church_analytics/ui/widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Histogram chart. Mouse-wheel zoom gated behind Ctrl key.
class HistogramChartWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CtrlScrollZoomWrapper(
      builder: (ctrlHeld) {
        final zoomPan = ZoomPanBehavior(
          enablePinching: true, enableDoubleTapZooming: true,
          enablePanning: true, enableMouseWheelZooming: ctrlHeld,
        );
        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.hasBoundedHeight ? constraints.maxHeight : height,
            child: SfCartesianChart(
              zoomPanBehavior: zoomPan,
              title: ChartTitle(text: title, textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y', duration: 2000),
              primaryXAxis: const CategoryAxis(
                labelRotation: -45, labelStyle: TextStyle(fontSize: 10),
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: yAxisTitle),
                numberFormat: NumberFormat.compact(),
                labelStyle: const TextStyle(fontSize: 10),
              ),
              plotAreaBorderWidth: 0,
              series: <CartesianSeries<CategoryPoint, String>>[
                ColumnSeries<CategoryPoint, String>(
                  dataSource: data,
                  xValueMapper: (point, _) => point.label,
                  yValueMapper: (point, _) => point.value,
                  color: const Color(0xFF1565C0),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  animationDuration: 600,
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
