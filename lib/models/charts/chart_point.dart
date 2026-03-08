/// A simple (x, y) data point used for basic chart series.
///
/// Suitable for bar charts, scatter plots, or any chart where
/// x is a label/category and y is a numeric value.
class ChartPoint {
  final String x;
  final double y;

  const ChartPoint({required this.x, required this.y});
}
