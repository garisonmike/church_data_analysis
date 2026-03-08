import 'package:church_analytics/models/charts/charts.dart';
import 'package:church_analytics/models/weekly_record.dart';

/// Converts raw [WeeklyRecord] data into structured chart datasets.
///
/// All analytical logic mirrors the transformations defined in `data.py`.
/// No Python code is executed — all calculations are performed in Dart.
class AnalyticsService {
  // ---------------------------------------------------------------------------
  // Time-series: Attendance trends
  // ---------------------------------------------------------------------------

  /// Returns weekly total attendance as a time series.
  ///
  /// Mirrors: `plot_time_series_all` — "Total Attendance Trend" subplot.
  List<TimeSeriesPoint> totalAttendanceTrend(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => TimeSeriesPoint(
            x: r.weekStartDate,
            y: r.totalAttendance.toDouble(),
          ),
        )
        .toList();
  }

  /// Returns weekly attendance broken down by demographic group.
  ///
  /// Keys are: "Men", "Women", "Youth", "Children", "HomeChurch".
  /// Mirrors the multi-line series in `plot_time_series_all`.
  Map<String, List<TimeSeriesPoint>> demographicAttendanceTrends(
    List<WeeklyRecord> records,
  ) {
    return {
      'Men': records
          .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.men.toDouble()))
          .toList(),
      'Women': records
          .map(
            (r) => TimeSeriesPoint(x: r.weekStartDate, y: r.women.toDouble()),
          )
          .toList(),
      'Youth': records
          .map(
            (r) => TimeSeriesPoint(x: r.weekStartDate, y: r.youth.toDouble()),
          )
          .toList(),
      'Children': records
          .map(
            (r) =>
                TimeSeriesPoint(x: r.weekStartDate, y: r.children.toDouble()),
          )
          .toList(),
      'HomeChurch': records
          .map(
            (r) => TimeSeriesPoint(
              x: r.weekStartDate,
              y: r.sundayHomeChurch.toDouble(),
            ),
          )
          .toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Time-series: Financial trends
  // ---------------------------------------------------------------------------

  /// Returns weekly tithe as a time series.
  ///
  /// Mirrors: `plot_attendance_income_trends` — "Tithe per Week" chart.
  List<TimeSeriesPoint> titheTrend(List<WeeklyRecord> records) {
    return records
        .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.tithe))
        .toList();
  }

  /// Returns weekly offerings as a time series.
  ///
  /// Mirrors: `plot_attendance_income_trends` — "Offerings per Week" chart.
  List<TimeSeriesPoint> offeringsTrend(List<WeeklyRecord> records) {
    return records
        .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.offerings))
        .toList();
  }

  /// Returns weekly total income as a time series.
  ///
  /// Mirrors: `plot_attendance_income_trends` — "Total Income per Week" chart.
  List<TimeSeriesPoint> totalIncomeTrend(List<WeeklyRecord> records) {
    return records
        .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.totalIncome))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Time-series: Derived metrics
  // ---------------------------------------------------------------------------

  /// Returns weekly income-per-attendee over time.
  ///
  /// Derived column: `INCOME_PER_ATTENDEE = TOTAL_INCOME / TOTAL_ATTENDANCE`
  /// Mirrors: `plot_time_series_all` — "Income Per Attendee Over Time".
  List<TimeSeriesPoint> incomePerAttendeeTrend(List<WeeklyRecord> records) {
    return records.map((r) {
      final attendance = r.totalAttendance;
      final value = attendance > 0 ? r.totalIncome / attendance : 0.0;
      return TimeSeriesPoint(x: r.weekStartDate, y: value);
    }).toList();
  }

  /// Returns week-over-week attendance growth rate (%) for each record.
  ///
  /// First record has no previous value and is excluded from results.
  /// Derived column: `ATTENDANCE_GROWTH = TOTAL_ATTENDANCE.pct_change() * 100`
  /// Mirrors: `plot_time_series_all` — "Attendance Growth Rate (%)" bar chart.
  List<ChartPoint> attendanceGrowthRates(List<WeeklyRecord> records) {
    if (records.length < 2) return [];
    final result = <ChartPoint>[];
    for (int i = 1; i < records.length; i++) {
      final prev = records[i - 1].totalAttendance;
      final curr = records[i].totalAttendance;
      final growth = prev > 0 ? ((curr - prev) / prev) * 100.0 : 0.0;
      result.add(
        ChartPoint(x: _formatDate(records[i].weekStartDate), y: growth),
      );
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Grouped bar: Attendance by group per week
  // ---------------------------------------------------------------------------

  /// Returns per-week attendance grouped into [CategoryPoint] series for each
  /// demographic category.
  ///
  /// Mirrors: `plot_attendance_overview` — "Attendance by Group per Week".
  Map<String, List<CategoryPoint>> attendanceByGroupPerWeek(
    List<WeeklyRecord> records,
  ) {
    return {
      'Men': records
          .map(
            (r) => CategoryPoint(
              label: _formatDate(r.weekStartDate),
              value: r.men.toDouble(),
            ),
          )
          .toList(),
      'Women': records
          .map(
            (r) => CategoryPoint(
              label: _formatDate(r.weekStartDate),
              value: r.women.toDouble(),
            ),
          )
          .toList(),
      'Youth': records
          .map(
            (r) => CategoryPoint(
              label: _formatDate(r.weekStartDate),
              value: r.youth.toDouble(),
            ),
          )
          .toList(),
      'Children': records
          .map(
            (r) => CategoryPoint(
              label: _formatDate(r.weekStartDate),
              value: r.children.toDouble(),
            ),
          )
          .toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Stacked bar: Income by week
  // ---------------------------------------------------------------------------

  /// Returns weekly tithe grouped as [CategoryPoint] list.
  ///
  /// Mirrors: `plot_attendance_overview` — "Income by Week" stacked bar (tithe layer).
  List<CategoryPoint> tithePerWeek(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => CategoryPoint(
            label: _formatDate(r.weekStartDate),
            value: r.tithe,
          ),
        )
        .toList();
  }

  /// Returns weekly offerings grouped as [CategoryPoint] list.
  ///
  /// Mirrors: `plot_attendance_overview` — "Income by Week" stacked bar (offerings layer).
  List<CategoryPoint> offeringsPerWeek(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => CategoryPoint(
            label: _formatDate(r.weekStartDate),
            value: r.offerings,
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Distribution / pie: Demographic share
  // ---------------------------------------------------------------------------

  /// Returns the aggregate attendance share per demographic group as a list of
  /// [DistributionPoint] slices suitable for a pie/doughnut chart.
  ///
  /// Mirrors: `PERCENTAGE DISTRIBUTIONS — ATTENDANCE DISTRIBUTION` section and
  /// used in any demographic pie chart across the Python script.
  List<DistributionPoint> demographicDistribution(List<WeeklyRecord> records) {
    if (records.isEmpty) return [];

    final totalMen = records.fold<double>(0, (s, r) => s + r.men);
    final totalWomen = records.fold<double>(0, (s, r) => s + r.women);
    final totalYouth = records.fold<double>(0, (s, r) => s + r.youth);
    final totalChildren = records.fold<double>(0, (s, r) => s + r.children);
    final grandTotal = totalMen + totalWomen + totalYouth + totalChildren;

    if (grandTotal == 0) return [];

    return [
      DistributionPoint(
        label: 'Men',
        value: totalMen,
        percentage: totalMen / grandTotal * 100,
      ),
      DistributionPoint(
        label: 'Women',
        value: totalWomen,
        percentage: totalWomen / grandTotal * 100,
      ),
      DistributionPoint(
        label: 'Youth',
        value: totalYouth,
        percentage: totalYouth / grandTotal * 100,
      ),
      DistributionPoint(
        label: 'Children',
        value: totalChildren,
        percentage: totalChildren / grandTotal * 100,
      ),
    ];
  }

  /// Returns the aggregate income share between tithe and offerings as a list of
  /// [DistributionPoint] slices.
  ///
  /// Mirrors: `PERCENTAGE DISTRIBUTIONS — INCOME DISTRIBUTION` section.
  List<DistributionPoint> incomeDistribution(List<WeeklyRecord> records) {
    if (records.isEmpty) return [];

    final totalTithe = records.fold<double>(0, (s, r) => s + r.tithe);
    final totalOfferings = records.fold<double>(0, (s, r) => s + r.offerings);
    final totalEmergency = records.fold<double>(
      0,
      (s, r) => s + r.emergencyCollection,
    );
    final totalPlanned = records.fold<double>(
      0,
      (s, r) => s + r.plannedCollection,
    );
    final grandTotal =
        totalTithe + totalOfferings + totalEmergency + totalPlanned;

    if (grandTotal == 0) return [];

    final points = [
      DistributionPoint(
        label: 'Tithe',
        value: totalTithe,
        percentage: totalTithe / grandTotal * 100,
      ),
      DistributionPoint(
        label: 'Offerings',
        value: totalOfferings,
        percentage: totalOfferings / grandTotal * 100,
      ),
    ];
    if (totalEmergency > 0) {
      points.add(
        DistributionPoint(
          label: 'Emergency',
          value: totalEmergency,
          percentage: totalEmergency / grandTotal * 100,
        ),
      );
    }
    if (totalPlanned > 0) {
      points.add(
        DistributionPoint(
          label: 'Planned',
          value: totalPlanned,
          percentage: totalPlanned / grandTotal * 100,
        ),
      );
    }
    return points;
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }
}
