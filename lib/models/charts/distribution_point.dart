/// A slice of a distribution, used for pie/doughnut charts.
///
/// [label] is the segment name (e.g. "Men", "Women").
/// [value] is the raw count or amount for this segment.
/// [percentage] is the pre-computed share of the total (0–100).
class DistributionPoint {
  final String label;
  final double value;
  final double percentage;

  const DistributionPoint({
    required this.label,
    required this.value,
    required this.percentage,
  });
}
