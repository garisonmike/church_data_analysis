import 'package:church_analytics/models/charts/box_plot_point.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A reusable box-and-whisker chart widget backed by Syncfusion.
///
/// Renders box plots showing min, Q1, median, Q3, max for each category.
/// Also supports violin-like rendering via [BoxPlotMode.normal] or
/// [BoxPlotMode.exclusive].
class BoxPlotWidget extends StatefulWidget {
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

  @override
  State<BoxPlotWidget> createState() => _BoxPlotWidgetState();
}

class _BoxPlotWidgetState extends State<BoxPlotWidget> {
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
            tooltipBehavior: TooltipBehavior(enable: true, duration: 2000),
            primaryXAxis: const CategoryAxis(
              labelRotation: -45,
              labelStyle: TextStyle(fontSize: 10),
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: widget.yAxisTitle),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            plotAreaBorderWidth: 0,
            series: <BoxAndWhiskerSeries<BoxPlotPoint, String>>[
              BoxAndWhiskerSeries<BoxPlotPoint, String>(
                dataSource: widget.data,
                xValueMapper: (point, _) => point.label,
                yValueMapper: (point, _) => point.values,
                boxPlotMode: BoxPlotMode.exclusive,
                showMean: true,
                borderColor: _kPalette[0],
                color: _kPalette[0].withAlpha(77),
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
