// lib/services/pdf_chart_builder.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/models/holy_communion_event.dart';
import 'package:church_analytics/services/analytics_service.dart';

/// Builds native PDF vector charts from [WeeklyRecord] data.
///
/// All methods are static. No Flutter widget tree, no GlobalKeys, no
/// screenshots — charts are rendered directly by the `pdf` package.
class PdfChartBuilder {
  // ── Colour palette ──────────────────────────────────────────────────────────
  static const _blue   = PdfColor.fromInt(0xFF1565C0);
  static const _teal   = PdfColor.fromInt(0xFF00796B);
  static const _orange = PdfColor.fromInt(0xFFE65100);
  static const _purple = PdfColor.fromInt(0xFF6A1B9A);
  static const _red    = PdfColor.fromInt(0xFFC62828);
  static const _green  = PdfColor.fromInt(0xFF2E7D32);

  // ── Public chart methods ────────────────────────────────────────────────────

  /// Attendance: total attendance line chart.
  static pw.Widget attendanceTrend(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    return _lineChart(
      title: 'Total Attendance Trend',
      series: {
        'Attendance': (
          sorted.map((r) => r.totalAttendance.toDouble()).toList(),
          _blue,
        ),
      },
      yLabel: 'People',
    );
  }

  /// Attendance: Men / Women / Youth / Children grouped bars.
  static pw.Widget demographicBreakdown(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    return _groupedBarChart(
      title: 'Demographic Breakdown',
      groups: {
        'Men':      (sorted.map((r) => r.men.toDouble()).toList(),      _blue),
        'Women':    (sorted.map((r) => r.women.toDouble()).toList(),    _teal),
        'Youth':    (sorted.map((r) => r.youth.toDouble()).toList(),    _orange),
        'Children': (sorted.map((r) => r.children.toDouble()).toList(), _purple),
      },
    );
  }

  /// Attendance: week-over-week growth rate bar chart.
  static pw.Widget attendanceGrowthRate(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    final rates = AnalyticsService().attendanceGrowthRates(sorted);
    // ChartPoint has .y (double)
    final values = rates.map((p) => p.y).toList();
    return _groupedBarChart(
      title: 'Attendance Growth Rate (%)',
      groups: {'Growth %': (values, _teal)},
    );
  }

  /// Attendance: home church attendance line chart.
  static pw.Widget homeChurchTrend(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    return _lineChart(
      title: 'Home Church Trend',
      series: {
        'Home Church': (
          sorted.map((r) => r.sundayHomeChurch.toDouble()).toList(),
          _green,
        ),
      },
      yLabel: 'People',
    );
  }

  /// Attendance: Adults vs Young pie chart.
  static pw.Widget adultVsYoungDistribution(List<WeeklyRecord> records) {
    // adultVsYoungDistribution returns List<DistributionPoint>
    // DistributionPoint has .label (String) and .value (double, raw count)
    // PieDataSet normalises proportions from raw values internally
    final slices = AnalyticsService().adultVsYoungDistribution(records);
    return _pieChart(
      title: 'Adult vs Young Distribution',
      slices: slices.map((s) => (s.label, s.value)).toList(),
    );
  }

  /// Financial: total income line chart.
  static pw.Widget incomeTrend(
    List<WeeklyRecord> records, {
    String currencySymbol = r'$',
  }) {
    final sorted = _sortedByDate(records);
    return _lineChart(
      title: 'Total Income Trend ($currencySymbol)',
      series: {
        'Income': (sorted.map((r) => r.totalIncome).toList(), _green),
      },
      yLabel: currencySymbol,
    );
  }

  /// Financial: Tithe / Offerings / Emergency / Planned grouped bars.
  static pw.Widget incomeComposition(
    List<WeeklyRecord> records, {
    String currencySymbol = r'$',
  }) {
    final sorted = _sortedByDate(records);
    return _groupedBarChart(
      title: 'Income Composition ($currencySymbol)',
      groups: {
        'Tithe':     (sorted.map((r) => r.tithe).toList(),               _blue),
        'Offerings': (sorted.map((r) => r.offerings).toList(),           _teal),
        'Emergency': (sorted.map((r) => r.emergencyCollection).toList(), _orange),
        'Planned':   (sorted.map((r) => r.plannedCollection).toList(),   _purple),
      },
    );
  }

  /// Financial: Tithe and Offerings as two lines on one chart.
  static pw.Widget titheVsOfferingsTrend(
    List<WeeklyRecord> records, {
    String currencySymbol = r'$',
  }) {
    final sorted = _sortedByDate(records);
    return _lineChart(
      title: 'Tithe vs Offerings ($currencySymbol)',
      series: {
        'Tithe':     (sorted.map((r) => r.tithe).toList(),     _blue),
        'Offerings': (sorted.map((r) => r.offerings).toList(), _teal),
      },
      yLabel: currencySymbol,
    );
  }

  /// Financial: income per attendee line chart.
  static pw.Widget incomePerAttendeeTrend(
    List<WeeklyRecord> records, {
    String currencySymbol = r'$',
  }) {
    final sorted = _sortedByDate(records);
    // incomePerAttendeeTrend returns List<TimeSeriesPoint>; TimeSeriesPoint has .y (double)
    final points = AnalyticsService().incomePerAttendeeTrend(sorted);
    return _lineChart(
      title: 'Income Per Attendee ($currencySymbol)',
      series: {
        'Per Capita': (points.map((p) => p.y).toList(), _green),
      },
      yLabel: currencySymbol,
    );
  }

  /// Financial: Regular vs Special income pie chart.
  static pw.Widget regularVsSpecialIncome(List<WeeklyRecord> records) {
    // regularVsSpecialIncomeDistribution returns List<DistributionPoint>
    // DistributionPoint has .label (String) and .value (double, raw count)
    // PieDataSet normalises proportions from raw values internally
    final slices =
        AnalyticsService().regularVsSpecialIncomeDistribution(records);
    return _pieChart(
      title: 'Regular vs Special Income',
      slices: slices.map((s) => (s.label, s.value)).toList(),
    );
  }

  /// Ratios: tithe per attendee per week bar chart.
  static pw.Widget perCapitaGivingTrend(
    List<WeeklyRecord> records, {
    String currencySymbol = r'$',
  }) {
    final sorted = _sortedByDate(records);
    // tithePerAttendeePerWeek returns List<CategoryPoint>; CategoryPoint has .value (double)
    final points = AnalyticsService().tithePerAttendeePerWeek(sorted);
    return _groupedBarChart(
      title: 'Per-Capita Tithe ($currencySymbol)',
      groups: {
        'Tithe/Person': (points.map((p) => p.value).toList(), _purple),
      },
    );
  }

  /// Ratios: Men:Women ratio line chart.
  static pw.Widget menWomenRatioTrend(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    // menWomenRatioTrend returns List<TimeSeriesPoint>
    final points = AnalyticsService().menWomenRatioTrend(sorted);
    return _lineChart(
      title: 'Men:Women Ratio',
      series: {
        'Ratio': (points.map((p) => p.y).toList(), _red),
      },
      yLabel: 'Ratio',
    );
  }

  /// Ratios: Adult:Young ratio line chart.
  static pw.Widget adultYoungRatioTrend(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    // adultYoungRatioTrend returns List<TimeSeriesPoint>
    final points = AnalyticsService().adultYoungRatioTrend(sorted);
    return _lineChart(
      title: 'Adult:Young Ratio',
      series: {
        'Ratio': (points.map((p) => p.y).toList(), _orange),
      },
      yLabel: 'Ratio',
    );
  }

  // ── Baptisms ────────────────────────────────────────────────────────────────

  /// Baptisms: weekly baptism counts line chart.
  static pw.Widget baptismsTrend(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    final values = sorted.map((r) => (r.baptisms ?? 0).toDouble()).toList();
    if (values.isEmpty || values.every((v) => v == 0)) return _emptyChart('Baptisms Trend');
    return _lineChart(
      title: 'Baptisms Trend',
      series: {'Baptisms': (values, _blue)},
      yLabel: 'People',
    );
  }

  /// Baptisms: monthly aggregated bar chart.
  static pw.Widget baptismsMonthly(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    // Aggregate by year-month key
    final monthly = <String, double>{};
    for (final r in sorted) {
      final key =
          '${r.weekStartDate.year}-${r.weekStartDate.month.toString().padLeft(2, '0')}';
      monthly[key] = (monthly[key] ?? 0) + (r.baptisms ?? 0);
    }
    if (monthly.isEmpty) return _emptyChart('Monthly Baptisms');
    final values = monthly.values.toList();
    return _groupedBarChart(
      title: 'Monthly Baptisms',
      groups: {'Baptisms': (values, _teal)},
    );
  }

  /// Baptisms: cumulative running total line chart.
  static pw.Widget baptismsCumulative(List<WeeklyRecord> records) {
    final sorted = _sortedByDate(records);
    double running = 0;
    final values = sorted.map((r) {
      running += (r.baptisms ?? 0);
      return running;
    }).toList();
    if (values.isEmpty || running == 0) return _emptyChart('Cumulative Baptisms');
    return _lineChart(
      title: 'Cumulative Baptisms',
      series: {'Total': (values, _green)},
      yLabel: 'People',
    );
  }

  // ── Holy Communion ──────────────────────────────────────────────────────────

  /// Communion: overall attendance rate (%) trend line chart.
  static pw.Widget communionAttendanceRateTrend(List<HolyCommunionEvent> events) {
    if (events.isEmpty) return _emptyChart('Communion Rate Trend');
    final points = AnalyticsService().holyCommunionRateTrend(events);
    return _lineChart(
      title: 'Communion Attendance Rate (%)',
      series: {'Rate %': (points.map((p) => p.y).toList(), _blue)},
      yLabel: '%',
    );
  }

  /// Communion: actual vs expected grouped bar chart per event.
  static pw.Widget communionActualVsExpected(List<HolyCommunionEvent> events) {
    if (events.isEmpty) return _emptyChart('Communion Actual vs Expected');
    final data = AnalyticsService().holyCommunionActualVsExpected(events);
    return _groupedBarChart(
      title: 'Communion Actual vs Expected',
      groups: {
        'Actual':   (data['Actual']!.map((p) => p.value).toList(),   _blue),
        'Expected': (data['Expected']!.map((p) => p.value).toList(), _orange),
      },
    );
  }

  /// Communion: per-home-church actual vs expected for the most recent event.
  static pw.Widget communionByHomeChurch(List<HolyCommunionEvent> events) {
    if (events.isEmpty) return _emptyChart('Communion by Home Church');
    final sorted = List<HolyCommunionEvent>.from(events)
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    final latest = sorted.first;
    if (latest.attendance.isEmpty) return _emptyChart('Communion by Home Church');
    final data = AnalyticsService().holyCommunionByHomeChurch(latest);
    return _groupedBarChart(
      title: 'Communion by Home Church (${latest.quarterLabel})',
      groups: {
        'Actual':   (data['Actual']!.map((p) => p.value).toList(),   _teal),
        'Expected': (data['Expected']!.map((p) => p.value).toList(), _orange),
      },
    );
  }

  /// Communion: total actual attendance per quarter label bar chart.
  static pw.Widget communionQuarterlyComparison(List<HolyCommunionEvent> events) {
    if (events.isEmpty) return _emptyChart('Quarterly Communion Comparison');
    final sorted = List<HolyCommunionEvent>.from(events)
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    final values = sorted.map((e) => e.totalActual.toDouble()).toList();
    return _groupedBarChart(
      title: 'Quarterly Communion Comparison',
      groups: {'Actual': (values, _purple)},
    );
  }

  // ── Private rendering helpers ───────────────────────────────────────────────
  static List<WeeklyRecord> _sortedByDate(List<WeeklyRecord> records) =>
      List<WeeklyRecord>.from(records)
        ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

  /// Renders a line chart. [series] maps label → (values, colour).
  /// Supports multiple series on the same axes (e.g. Tithe vs Offerings).
  static pw.Widget _lineChart({
    required String title,
    required Map<String, (List<double>, PdfColor)> series,
    String yLabel = '',
  }) {
    final allValues = series.values.expand((e) => e.$1);
    if (allValues.isEmpty) return _emptyChart(title);

    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final count = series.values.first.$1.length;

    return _chartContainer(
      title: title,
      legend: series.map((k, v) => MapEntry(k, v.$2)),
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            List.generate(count, (i) => 'W${i + 1}'),
            marginStart: 10,
            marginEnd: 10,
          ),
          yAxis: pw.FixedAxis(
            _yTicks(maxY),
            format: _shortNumber,
            divisions: true,
          ),
        ),
        datasets: series.entries
            .map(
              (entry) => pw.LineDataSet(
                legend: entry.key,
                color: entry.value.$2,
                drawPoints: count <= 20,
                pointColor: entry.value.$2,
                isCurved: true,
                data: List.generate(
                  entry.value.$1.length,
                  (i) => pw.PointChartValue(
                    i.toDouble(),
                    entry.value.$1[i],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Renders a grouped bar chart. [groups] maps label → (values, colour).
  static pw.Widget _groupedBarChart({
    required String title,
    required Map<String, (List<double>, PdfColor)> groups,
  }) {
    final allValues = groups.values.expand((e) => e.$1);
    if (allValues.isEmpty) return _emptyChart(title);

    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final count = groups.values.first.$1.length;

    return _chartContainer(
      title: title,
      legend: groups.length > 1 ? groups.map((k, v) => MapEntry(k, v.$2)) : null,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            List.generate(count, (i) => 'W${i + 1}'),
            marginStart: 10,
            marginEnd: 10,
          ),
          yAxis: pw.FixedAxis(
            _yTicks(maxY),
            format: _shortNumber,
            divisions: true,
          ),
        ),
        datasets: groups.entries
            .map(
              (entry) => pw.BarDataSet(
                legend: entry.key,
                color: entry.value.$2,
                data: List.generate(
                  entry.value.$1.length,
                  (i) => pw.PointChartValue(
                    i.toDouble(),
                    entry.value.$1[i],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Renders a pie chart from (label, percentage) pairs.
  /// Each pair is a Dart record: (String label, double percentageValue).
  static pw.Widget _pieChart({
    required String title,
    required List<(String, double)> slices,
  }) {
    if (slices.isEmpty) return _emptyChart(title);

    final palette = [_blue, _teal, _orange, _purple, _red, _green];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _chartTitle(title),
        pw.SizedBox(height: 6),
        pw.Container(
          height: 160,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.all(12),
          child: pw.Chart(
            grid: pw.PieGrid(),
            datasets: List.generate(
              slices.length,
              (i) => pw.PieDataSet(
                legend:
                    '${slices[i].$1} (${slices[i].$2.toStringAsFixed(1)}%)',
                value: slices[i].$2,
                color: palette[i % palette.length],
                legendStyle: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  /// Shared container for line and bar charts.
  static pw.Widget _chartContainer({
    required String title,
    required pw.Widget child,
    Map<String, PdfColor>? legend,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _chartTitle(title),
        pw.SizedBox(height: 6),
        pw.Container(
          height: 180,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.all(12),
          child: child,
        ),
        if (legend != null && legend.length > 1) ...[
          pw.SizedBox(height: 4),
          _buildLegend(legend),
        ],
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _chartTitle(String title) => pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      );

  /// Returns a placeholder widget (no crash) when there is no data.
  static pw.Widget _emptyChart(String title) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _chartTitle(title),
          pw.SizedBox(height: 4),
          pw.Text(
            'Not enough data to render this chart.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 20),
        ],
      );

  static pw.Widget _buildLegend(Map<String, PdfColor> items) => pw.Wrap(
        spacing: 12,
        runSpacing: 4,
        children: items.entries
            .map(
              (e) => pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    width: 10,
                    height: 10,
                    decoration: pw.BoxDecoration(color: e.value),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    e.key,
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      );

  /// Generates 5 evenly-spaced y-axis tick values from 0 to above maxY.
  static List<double> _yTicks(double maxY) {
    if (maxY <= 0) return [0, 1, 2, 3, 4];
    final step = (maxY / 4).ceilToDouble();
    return [0, step, step * 2, step * 3, step * 4];
  }

  /// Formats a number as a short string: 1500 → "1K", 2500000 → "2.5M".
  static String _shortNumber(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}
