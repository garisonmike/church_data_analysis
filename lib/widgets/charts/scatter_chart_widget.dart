import 'dart:math' as math;

import 'package:church_analytics/models/charts/scatter_point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// A scatter chart widget with an overlaid linear-regression trend line,
/// backed by Syncfusion.
///
/// Accepts a flat list of [ScatterPoint] values. Computes the least-squares
/// regression line internally and renders it as a dashed [SplineSeries].
class ScatterCorrelationChart extends StatefulWidget {
  /// The scatter data points.
  final List<ScatterPoint> data;

  /// Chart title.
  final String title;

  /// X-axis label.
  final String xAxisTitle;

  /// Y-axis label.
  final String yAxisTitle;

  /// Fallback height when not inside a height-constrained parent.
  final double height;

  const ScatterCorrelationChart({
    super.key,
    required this.data,
    required this.title,
    this.xAxisTitle = '',
    this.yAxisTitle = '',
    this.height = 300,
  });

  @override
  State<ScatterCorrelationChart> createState() =>
      _ScatterCorrelationChartState();
}

class _ScatterCorrelationChartState extends State<ScatterCorrelationChart> {
  static const Color _kScatterColor = Color(0xFF1565C0);
  static const Color _kRegressionColor = Color(0xFFE65100);

  late final ZoomPanBehavior _zoomPan;
  late final TrackballBehavior _trackball;

  /// Two-point regression line [min, max].
  List<ScatterPoint> _regressionLine = [];
  double _pearsonR = 0;

  @override
  void initState() {
    super.initState();
    _zoomPan = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enablePanning: true,
      enableMouseWheelZooming: true,
    );
    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
    );
    _computeRegression();
  }

  @override
  void didUpdateWidget(ScatterCorrelationChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _computeRegression();
  }

  void _computeRegression() {
    final pts = widget.data;
    if (pts.length < 2) {
      _regressionLine = [];
      _pearsonR = 0;
      return;
    }

    final n = pts.length.toDouble();
    final sumX = pts.fold(0.0, (s, p) => s + p.x);
    final sumY = pts.fold(0.0, (s, p) => s + p.y);
    final sumXY = pts.fold(0.0, (s, p) => s + p.x * p.y);
    final sumX2 = pts.fold(0.0, (s, p) => s + p.x * p.x);
    final sumY2 = pts.fold(0.0, (s, p) => s + p.y * p.y);

    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) {
      _regressionLine = [];
      _pearsonR = 0;
      return;
    }

    final slope = (n * sumXY - sumX * sumY) / denom;
    final intercept = (sumY - slope * sumX) / n;

    final xMin = pts.map((p) => p.x).reduce(math.min);
    final xMax = pts.map((p) => p.x).reduce(math.max);

    _regressionLine = [
      ScatterPoint(x: xMin, y: slope * xMin + intercept, label: ''),
      ScatterPoint(x: xMax, y: slope * xMax + intercept, label: ''),
    ];

    // Pearson correlation coefficient.
    final rNum = n * sumXY - sumX * sumY;
    final rDen = math.sqrt(
      (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY),
    );
    _pearsonR = rDen == 0 ? 0 : rNum / rDen;
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.compact();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight
              ? constraints.maxHeight
              : widget.height,
          child: SfCartesianChart(
            zoomPanBehavior: _zoomPan,
            trackballBehavior: _trackball,
            title: ChartTitle(
              text: widget.title,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              // Inject Pearson r into the subtitle area via a custom legend item.
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              duration: 2000,
              builder:
                  (
                    dynamic data,
                    dynamic point,
                    dynamic series,
                    int pointIndex,
                    int seriesIndex,
                  ) {
                    if (data is ScatterPoint && data.label.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${widget.xAxisTitle}: ${nf.format(data.x)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${widget.yAxisTitle}: ${nf.format(data.y)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
            ),
            annotations: _pearsonR != 0
                ? <CartesianChartAnnotation>[
                    CartesianChartAnnotation(
                      widget: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'r = ${_pearsonR.toStringAsFixed(3)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      coordinateUnit: CoordinateUnit.percentage,
                      x: 94,
                      y: 8,
                    ),
                  ]
                : null,
            primaryXAxis: NumericAxis(
              title: AxisTitle(text: widget.xAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
              majorGridLines: const MajorGridLines(
                width: 0.5,
                dashArray: <double>[4, 4],
              ),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: widget.yAxisTitle),
              numberFormat: NumberFormat.compact(),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            plotAreaBorderWidth: 0,
            series: [
              // Scatter data points.
              ScatterSeries<ScatterPoint, double>(
                name: 'Weekly data',
                dataSource: widget.data,
                xValueMapper: (p, _) => p.x,
                yValueMapper: (p, _) => p.y,
                color: _kScatterColor,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                  width: 10,
                  height: 10,
                ),
                selectionBehavior: SelectionBehavior(enable: true),
                animationDuration: 600,
                enableTooltip: true,
              ),
              // Regression trend line.
              if (_regressionLine.isNotEmpty)
                SplineSeries<ScatterPoint, double>(
                  name: 'Trend line',
                  dataSource: _regressionLine,
                  xValueMapper: (p, _) => p.x,
                  yValueMapper: (p, _) => p.y,
                  color: _kRegressionColor,
                  width: 2,
                  dashArray: const <double>[8, 4],
                  markerSettings: const MarkerSettings(isVisible: false),
                  animationDuration: 600,
                  enableTooltip: false,
                ),
            ],
          ),
        );
      },
    );
  }
}
