import 'package:church_analytics/models/charts/box_plot_point.dart';
import 'package:church_analytics/ui/widgets/charts/ctrl_scroll_zoom_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Box-and-whisker chart. Mouse-wheel zoom gated behind Ctrl key.
class BoxPlotWidget extends StatelessWidget {
  final List<BoxPlotPoint> data;
  final String title;
  final String yAxisTitle;
  final double height;

  const BoxPlotWidget({
    super.key,
    required this.data,
    required this.title,
    this.yAxisTitle = '',
    this.height = 300,
  });

  static const Color _kColor = Color(0xFF1565C0);

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
              tooltipBehavior: TooltipBehavior(enable: true, duration: 2000),
              primaryXAxis: const CategoryAxis(
                labelRotation: -45, labelStyle: TextStyle(fontSize: 10),
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(title: AxisTitle(text: yAxisTitle), labelStyle: const TextStyle(fontSize: 10)),
              plotAreaBorderWidth: 0,
              series: <BoxAndWhiskerSeries<BoxPlotPoint, String>>[
                BoxAndWhiskerSeries<BoxPlotPoint, String>(
                  dataSource: data,
                  xValueMapper: (point, _) => point.label,
                  yValueMapper: (point, _) => point.values,
                  boxPlotMode: BoxPlotMode.exclusive,
                  showMean: true,
                  borderColor: _kColor,
                  color: _kColor.withAlpha(77),
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
