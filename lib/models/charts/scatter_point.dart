/// A data point for scatter chart rendering.
///
/// Holds a numeric [x] / [y] pair plus a human-readable [label]
/// (e.g. the formatted week date) shown in tooltips.
class ScatterPoint {
  final double x;
  final double y;
  final String label;

  const ScatterPoint({required this.x, required this.y, required this.label});
}
