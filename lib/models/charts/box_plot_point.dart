/// A data point for box-and-whisker charts.
///
/// Stores the five-number summary (min, q1, median, q3, max) for a
/// named category, suitable for Syncfusion [BoxAndWhiskerSeries].
class BoxPlotPoint {
  final String label;
  final List<double> values;

  const BoxPlotPoint({required this.label, required this.values});
}
