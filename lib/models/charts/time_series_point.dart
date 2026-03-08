/// A data point for time-series charts where x is a [DateTime].
///
/// Used for trend lines, area charts, and line charts over time.
class TimeSeriesPoint {
  final DateTime x;
  final double y;

  const TimeSeriesPoint({required this.x, required this.y});
}
