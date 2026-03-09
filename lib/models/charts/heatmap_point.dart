/// A data point for heatmap / grid chart rendering.
///
/// Represents a single cell in a matrix where [xLabel] and [yLabel]
/// identify the row/column and [value] holds the magnitude (e.g.
/// correlation coefficient or achievement percentage).
class HeatmapPoint {
  final String xLabel;
  final String yLabel;
  final double value;

  const HeatmapPoint({
    required this.xLabel,
    required this.yLabel,
    required this.value,
  });
}
