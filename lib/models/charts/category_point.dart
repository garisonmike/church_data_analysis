/// A named category data point used for bar/column charts.
///
/// [label] is the display name of the category.
/// [value] is the numeric magnitude for the category.
/// [color] is an optional ARGB hex color for the series segment.
class CategoryPoint {
  final String label;
  final double value;
  final int? color;

  const CategoryPoint({required this.label, required this.value, this.color});
}
