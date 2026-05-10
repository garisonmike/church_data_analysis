import 'package:church_analytics/models/charts/heatmap_point.dart';
import 'package:flutter/material.dart';

/// A heatmap chart widget using a custom grid rendering.
///
/// Renders a colored grid where cell color intensity represents the
/// magnitude of each [HeatmapPoint.value]. Supports both correlation
/// matrices (−1 to +1) and percentage grids (0–100+).
class HeatmapChartWidget extends StatelessWidget {
  final List<HeatmapPoint> data;
  final String title;
  final double height;
  final bool isCorrelation;

  const HeatmapChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.height = 400,
    this.isCorrelation = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final xLabels = data.map((p) => p.xLabel).toSet().toList();
    final yLabels = data.map((p) => p.yLabel).toSet().toList();

    final lookup = <String, double>{};
    for (final p in data) {
      lookup['${p.xLabel}|${p.yLabel}'] = p.value;
    }

    return SizedBox(
      height: height,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellW = (constraints.maxWidth - 60) / xLabels.length;
                    final cellH = (constraints.maxHeight - 30) / yLabels.length;
                    final cellSize = cellW < cellH ? cellW : cellH;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // X-axis labels
                          Row(
                            children: [
                              SizedBox(width: 60),
                              ...xLabels.map(
                                (label) => SizedBox(
                                  width: cellSize,
                                  child: Text(
                                    _abbreviate(label),
                                    style: const TextStyle(fontSize: 9),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Grid rows
                          ...yLabels.map(
                            (yLabel) => Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    _abbreviate(yLabel),
                                    style: const TextStyle(fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ...xLabels.map((xLabel) {
                                  final val = lookup['$xLabel|$yLabel'] ?? 0;
                                  return Tooltip(
                                    message:
                                        '$xLabel × $yLabel: ${val.toStringAsFixed(2)}',
                                    child: Container(
                                      width: cellSize,
                                      height: cellSize,
                                      decoration: BoxDecoration(
                                        color: _cellColor(val),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 0.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: cellSize > 28
                                          ? Text(
                                              val.toStringAsFixed(
                                                isCorrelation ? 2 : 0,
                                              ),
                                              style: TextStyle(
                                                fontSize: 8,
                                                color:
                                                    val.abs() > 0.5 ||
                                                        (!isCorrelation &&
                                                            val > 80)
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            )
                                          : null,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _cellColor(double value) {
    if (isCorrelation) {
      // Diverging: blue (−1) → white (0) → red (+1)
      final clamped = value.clamp(-1.0, 1.0);
      if (clamped >= 0) {
        return Color.lerp(Colors.white, Colors.red.shade700, clamped)!;
      } else {
        return Color.lerp(Colors.white, Colors.blue.shade700, -clamped)!;
      }
    } else {
      // Sequential: red (<50) → amber (50-99) → green (≥100)
      if (value >= 100) {
        return Colors.green.shade600;
      } else if (value >= 50) {
        final t = (value - 50) / 50;
        return Color.lerp(Colors.amber.shade600, Colors.green.shade400, t)!;
      } else {
        final t = value / 50;
        return Color.lerp(Colors.red.shade700, Colors.amber.shade600, t)!;
      }
    }
  }

  String _abbreviate(String label) {
    if (label.length <= 8) return label;
    return '${label.substring(0, 7)}…';
  }
}
