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
  // Pie: Adult vs Young / Regular vs Special
  // ---------------------------------------------------------------------------

  /// Returns an Adults (Men+Women) vs Young (Youth+Children) distribution.
  ///
  /// Mirrors: `plot_pie_charts` — "Adult vs Young Attendance" pie.
  List<DistributionPoint> adultVsYoungDistribution(List<WeeklyRecord> records) {
    if (records.isEmpty) return [];
    final adults = records.fold<double>(0, (s, r) => s + r.men + r.women);
    final young = records.fold<double>(0, (s, r) => s + r.youth + r.children);
    final total = adults + young;
    if (total == 0) return [];
    return [
      DistributionPoint(
        label: 'Adults',
        value: adults,
        percentage: adults / total * 100,
      ),
      DistributionPoint(
        label: 'Young',
        value: young,
        percentage: young / total * 100,
      ),
    ];
  }

  /// Returns Regular income (Tithe+Offerings) vs Special Collections distribution.
  ///
  /// Mirrors: `plot_pie_charts` — "Regular vs Special Income" pie.
  List<DistributionPoint> regularVsSpecialIncomeDistribution(
    List<WeeklyRecord> records,
  ) {
    if (records.isEmpty) return [];
    final regular = records.fold<double>(
      0,
      (s, r) => s + r.tithe + r.offerings,
    );
    final special = records.fold<double>(
      0,
      (s, r) => s + r.emergencyCollection + r.plannedCollection,
    );
    final total = regular + special;
    if (total == 0) return [];
    return [
      DistributionPoint(
        label: 'Regular',
        value: regular,
        percentage: regular / total * 100,
      ),
      DistributionPoint(
        label: 'Special',
        value: special,
        percentage: special / total * 100,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Time-series: Home church & regular income
  // ---------------------------------------------------------------------------

  /// Returns weekly home church attendance as a time series.
  ///
  /// Mirrors: `plot_home_church_comparison`, `ds2_plot_attendance_trends`.
  List<TimeSeriesPoint> homeChurchTrend(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => TimeSeriesPoint(
            x: r.weekStartDate,
            y: r.sundayHomeChurch.toDouble(),
          ),
        )
        .toList();
  }

  /// Returns weekly regular income (Tithe + Offerings) as a time series.
  ///
  /// Derived column: `REGULAR_INCOME = TITHE + OFFERINGS`
  /// Mirrors: `plot_dual_axis_trends` — "Home Church vs Regular Income".
  List<TimeSeriesPoint> regularIncomeTrend(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => TimeSeriesPoint(x: r.weekStartDate, y: r.tithe + r.offerings),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Grouped bar: Adult / Young / Regular income per week
  // ---------------------------------------------------------------------------

  /// Returns weekly adult attendance (Men + Women) as [CategoryPoint] list.
  ///
  /// Derived column: `ADULT_ATTENDANCE = MEN + WOMEN`
  /// Mirrors: `plot_grouped_bar_comparison` — "Adult vs Young Attendance".
  List<CategoryPoint> adultAttendancePerWeek(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => CategoryPoint(
            label: _formatDate(r.weekStartDate),
            value: (r.men + r.women).toDouble(),
          ),
        )
        .toList();
  }

  /// Returns weekly young attendance (Youth + Children) as [CategoryPoint] list.
  ///
  /// Derived column: `YOUNG_ATTENDANCE = YOUTH + CHILDREN`
  List<CategoryPoint> youngAttendancePerWeek(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => CategoryPoint(
            label: _formatDate(r.weekStartDate),
            value: (r.youth + r.children).toDouble(),
          ),
        )
        .toList();
  }

  /// Returns weekly regular income (Tithe + Offerings) as [CategoryPoint] list.
  ///
  /// Mirrors: `plot_grouped_bar_comparison` — "Regular vs Total Income".
  List<CategoryPoint> regularIncomePerWeek(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => CategoryPoint(
            label: _formatDate(r.weekStartDate),
            value: r.tithe + r.offerings,
          ),
        )
        .toList();
  }

  /// Returns weekly home church attendance as [CategoryPoint] list.
  ///
  /// Mirrors: `plot_home_church_comparison` bar charts.
  List<CategoryPoint> homeChurchPerWeek(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => CategoryPoint(
            label: _formatDate(r.weekStartDate),
            value: r.sundayHomeChurch.toDouble(),
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Per-capita metrics per week
  // ---------------------------------------------------------------------------

  /// Returns weekly tithe-per-attendee as [CategoryPoint] list.
  ///
  /// Derived column: `TITHE_PER_ATTENDEE = TITHE / TOTAL_ATTENDANCE`
  /// Mirrors: `plot_per_capita_analysis` — "Tithe Per Attendee".
  List<CategoryPoint> tithePerAttendeePerWeek(List<WeeklyRecord> records) {
    return records.map((r) {
      final att = r.totalAttendance;
      return CategoryPoint(
        label: _formatDate(r.weekStartDate),
        value: att > 0 ? r.tithe / att : 0.0,
      );
    }).toList();
  }

  /// Returns weekly offerings-per-attendee as [CategoryPoint] list.
  ///
  /// Derived column: `OFFERINGS_PER_ATTENDEE = OFFERINGS / TOTAL_ATTENDANCE`
  List<CategoryPoint> offeringsPerAttendeePerWeek(List<WeeklyRecord> records) {
    return records.map((r) {
      final att = r.totalAttendance;
      return CategoryPoint(
        label: _formatDate(r.weekStartDate),
        value: att > 0 ? r.offerings / att : 0.0,
      );
    }).toList();
  }

  /// Returns weekly regular-income-per-adult as [CategoryPoint] list.
  ///
  /// Derived column: `REGULAR_INCOME_PER_ADULT = REGULAR_INCOME / ADULT_ATTENDANCE`
  /// Mirrors: `plot_per_capita_analysis` — "Regular Income Per Adult".
  List<CategoryPoint> regularIncomePerAdultPerWeek(List<WeeklyRecord> records) {
    return records.map((r) {
      final adults = r.men + r.women;
      return CategoryPoint(
        label: _formatDate(r.weekStartDate),
        value: adults > 0 ? (r.tithe + r.offerings) / adults : 0.0,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Ratio trends
  // ---------------------------------------------------------------------------

  /// Returns weekly Men:Women attendance ratio as a time series.
  ///
  /// Derived column: `MEN_WOMEN_RATIO = MEN / WOMEN`
  /// Mirrors: `plot_ratio_analysis`, `ds2_plot_ratios`.
  List<TimeSeriesPoint> menWomenRatioTrend(List<WeeklyRecord> records) {
    return records.map((r) {
      final ratio = r.women > 0 ? r.men / r.women : 0.0;
      return TimeSeriesPoint(x: r.weekStartDate, y: ratio);
    }).toList();
  }

  /// Returns weekly Adult:Young attendance ratio as a time series.
  ///
  /// Derived column: `ADULT_YOUNG_RATIO = ADULT_ATTENDANCE / YOUNG_ATTENDANCE`
  List<TimeSeriesPoint> adultYoungRatioTrend(List<WeeklyRecord> records) {
    return records.map((r) {
      final young = r.youth + r.children;
      final adult = r.men + r.women;
      final ratio = young > 0 ? adult / young : 0.0;
      return TimeSeriesPoint(x: r.weekStartDate, y: ratio);
    }).toList();
  }

  /// Returns weekly Tithe:Offerings ratio as a time series.
  ///
  /// Derived column: `TITHE_OFFERINGS_RATIO = TITHE / OFFERINGS`
  List<TimeSeriesPoint> titheOfferingsRatioTrend(List<WeeklyRecord> records) {
    return records.map((r) {
      final ratio = r.offerings > 0 ? r.tithe / r.offerings : 0.0;
      return TimeSeriesPoint(x: r.weekStartDate, y: ratio);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Percentage composition trends
  // ---------------------------------------------------------------------------

  /// Returns weekly demographic percentage trends (0–100 scale).
  ///
  /// Keys: "Men%", "Women%", "Youth%", "Children%".
  /// Derived columns: `MEN_PCT`, `WOMEN_PCT`, `YOUTH_PCT`, `CHILDREN_PCT`.
  /// Mirrors: `plot_percentage_analysis` — "Individual Percentage Trends".
  Map<String, List<TimeSeriesPoint>> demographicPercentageTrends(
    List<WeeklyRecord> records,
  ) {
    final menPct = <TimeSeriesPoint>[];
    final womenPct = <TimeSeriesPoint>[];
    final youthPct = <TimeSeriesPoint>[];
    final childrenPct = <TimeSeriesPoint>[];

    for (final r in records) {
      final total = r.men + r.women + r.youth + r.children;
      if (total == 0) continue;
      menPct.add(TimeSeriesPoint(x: r.weekStartDate, y: r.men / total * 100));
      womenPct.add(
        TimeSeriesPoint(x: r.weekStartDate, y: r.women / total * 100),
      );
      youthPct.add(
        TimeSeriesPoint(x: r.weekStartDate, y: r.youth / total * 100),
      );
      childrenPct.add(
        TimeSeriesPoint(x: r.weekStartDate, y: r.children / total * 100),
      );
    }

    return {
      'Men%': menPct,
      'Women%': womenPct,
      'Youth%': youthPct,
      'Children%': childrenPct,
    };
  }

  /// Returns the average percentage share for each demographic group.
  ///
  /// Mirrors: `plot_percentage_analysis` — "Average Percentage by Category" bar.
  List<CategoryPoint> averageDemographicPercentages(
    List<WeeklyRecord> records,
  ) {
    if (records.isEmpty) return [];

    double sumMen = 0, sumWomen = 0, sumYouth = 0, sumChildren = 0;
    int count = 0;

    for (final r in records) {
      final total = r.men + r.women + r.youth + r.children;
      if (total == 0) continue;
      sumMen += r.men / total * 100;
      sumWomen += r.women / total * 100;
      sumYouth += r.youth / total * 100;
      sumChildren += r.children / total * 100;
      count++;
    }

    if (count == 0) return [];

    return [
      CategoryPoint(label: 'Men', value: sumMen / count),
      CategoryPoint(label: 'Women', value: sumWomen / count),
      CategoryPoint(label: 'Youth', value: sumYouth / count),
      CategoryPoint(label: 'Children', value: sumChildren / count),
    ];
  }

  // ---------------------------------------------------------------------------
  // Income growth rate
  // ---------------------------------------------------------------------------

  /// Returns week-over-week total income growth rate (%) for each record.
  ///
  /// First record is excluded (no previous value).
  /// Derived column: `INCOME_GROWTH = TOTAL_INCOME.pct_change() × 100`
  List<ChartPoint> incomeGrowthRates(List<WeeklyRecord> records) {
    if (records.length < 2) return [];
    final result = <ChartPoint>[];
    for (int i = 1; i < records.length; i++) {
      final prev = records[i - 1].totalIncome;
      final curr = records[i].totalIncome;
      final growth = prev > 0 ? ((curr - prev) / prev) * 100.0 : 0.0;
      result.add(
        ChartPoint(x: _formatDate(records[i].weekStartDate), y: growth),
      );
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Stacked area: Income components
  // ---------------------------------------------------------------------------

  /// Returns each income component as a time series for stacked area rendering.
  ///
  /// Keys: "Tithe", "Offerings", "Emergency", "Planned".
  /// Mirrors: `plot_stacked_area` — "Income Composition Over Time".
  Map<String, List<TimeSeriesPoint>> incomeComponentTrends(
    List<WeeklyRecord> records,
  ) {
    return {
      'Tithe': records
          .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.tithe))
          .toList(),
      'Offerings': records
          .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.offerings))
          .toList(),
      'Emergency': records
          .map(
            (r) =>
                TimeSeriesPoint(x: r.weekStartDate, y: r.emergencyCollection),
          )
          .toList(),
      'Planned': records
          .map(
            (r) => TimeSeriesPoint(x: r.weekStartDate, y: r.plannedCollection),
          )
          .toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Target achievement (Dataset 2 style)
  // ---------------------------------------------------------------------------

  /// Returns per-metric target achievement percentage averaged across all records.
  ///
  /// [targets] maps metric name → target value (e.g. `{'Men': 900, 'Tithe': 1050000}`).
  /// Returns a [CategoryPoint] per metric where value = average achievement %.
  ///
  /// Mirrors: `ds2_plot_target_gauge` — "Overall Average Target Achievement".
  List<CategoryPoint> overallTargetAchievement(
    List<WeeklyRecord> records,
    Map<String, double> targets,
  ) {
    if (records.isEmpty || targets.isEmpty) return [];

    final sums = <String, double>{};
    for (final r in records) {
      final actuals = {
        'Men': r.men.toDouble(),
        'Women': r.women.toDouble(),
        'Youth': r.youth.toDouble(),
        'Children': r.children.toDouble(),
        'Total Attendance': r.totalAttendance.toDouble(),
        'Home Church': r.sundayHomeChurch.toDouble(),
        'Tithe': r.tithe,
        'Offerings': r.offerings,
      };
      actuals.forEach((key, value) {
        if (targets.containsKey(key)) {
          sums[key] = (sums[key] ?? 0) + value;
        }
      });
    }

    return targets.entries.map((e) {
      final total = sums[e.key] ?? 0;
      final avg = total / records.length;
      final pct = e.value > 0 ? avg / e.value * 100 : 0.0;
      return CategoryPoint(label: e.key, value: pct);
    }).toList();
  }

  /// Returns per-week target achievement % for each metric as a map.
  ///
  /// Keys are metric names; values are one [CategoryPoint] per week
  /// (label = formatted date, value = achievement %).
  ///
  /// Mirrors: `ds2_plot_target_gauge` — left panel (grouped bar per week).
  Map<String, List<CategoryPoint>> targetAchievementPerWeek(
    List<WeeklyRecord> records,
    Map<String, double> targets,
  ) {
    if (records.isEmpty || targets.isEmpty) return {};

    final result = <String, List<CategoryPoint>>{};

    for (final r in records) {
      final label = _formatDate(r.weekStartDate);
      final actuals = {
        'Men': r.men.toDouble(),
        'Women': r.women.toDouble(),
        'Youth': r.youth.toDouble(),
        'Children': r.children.toDouble(),
        'Total Attendance': r.totalAttendance.toDouble(),
        'Home Church': r.sundayHomeChurch.toDouble(),
        'Tithe': r.tithe,
        'Offerings': r.offerings,
      };
      actuals.forEach((key, value) {
        if (targets.containsKey(key)) {
          final target = targets[key]!;
          final pct = target > 0 ? value / target * 100 : 0.0;
          result
              .putIfAbsent(key, () => [])
              .add(CategoryPoint(label: label, value: pct));
        }
      });
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Distribution histogram data
  // ---------------------------------------------------------------------------

  /// Returns value-frequency pairs for a histogram of a specific metric.
  ///
  /// Values are bucketed into [bucketCount] equal-width bins.
  /// Returns a list of [CategoryPoint] where label = bin range, value = count.
  ///
  /// Mirrors: `plot_distribution_analysis`.
  List<CategoryPoint> distributionHistogram(
    List<double> values, {
    int bucketCount = 6,
  }) {
    if (values.isEmpty || bucketCount <= 0) return [];

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    if (range == 0) {
      return [
        CategoryPoint(
          label: minVal.toStringAsFixed(0),
          value: values.length.toDouble(),
        ),
      ];
    }

    final bucketWidth = range / bucketCount;
    final counts = List<double>.filled(bucketCount, 0);

    for (final v in values) {
      int idx = ((v - minVal) / bucketWidth).floor();
      if (idx >= bucketCount) idx = bucketCount - 1;
      counts[idx]++;
    }

    return List.generate(bucketCount, (i) {
      final low = minVal + i * bucketWidth;
      final high = low + bucketWidth;
      final label = '${low.toStringAsFixed(0)}–${high.toStringAsFixed(0)}';
      return CategoryPoint(label: label, value: counts[i]);
    });
  }

  // ---------------------------------------------------------------------------
  // Scatter: Attendance vs Income correlation
  // ---------------------------------------------------------------------------

  /// Returns scatter data for the attendance-vs-income correlation chart.
  ///
  /// Each [ScatterPoint] has x = TOTAL_ATTENDANCE, y = TOTAL_INCOME so that
  /// every weekly record is plotted as a dot on the correlation plane.
  /// The [label] holds the formatted date for use in tooltips.
  ///
  /// Mirrors: `combined_plot_attendance_vs_income_both` scatter sub-plot.
  List<ScatterPoint> attendanceVsIncomeScatter(List<WeeklyRecord> records) {
    return records
        .map(
          (r) => ScatterPoint(
            x: r.totalAttendance.toDouble(),
            y: r.totalIncome,
            label: _formatDate(r.weekStartDate),
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Income composition (Tithe + Offerings only, for stacked-area chart 5)
  // ---------------------------------------------------------------------------

  /// Returns Tithe and Offerings as parallel time series for a stacked area.
  ///
  /// Mirrors: `plot_stacked_area` — simplified to the two primary income types.
  Map<String, List<TimeSeriesPoint>> titheOfferingsComposition(
    List<WeeklyRecord> records,
  ) {
    return {
      'Tithe': records
          .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.tithe))
          .toList(),
      'Offerings': records
          .map((r) => TimeSeriesPoint(x: r.weekStartDate, y: r.offerings))
          .toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Dual-axis: Attendance & Income on separate Y scales
  // ---------------------------------------------------------------------------

  /// Returns total attendance time series for the primary (left) Y axis.
  ///
  /// Pair with [totalIncomeTrend] on the secondary axis to form a dual-axis view.
  /// Mirrors: `plot_dual_axis_trends` — "Attendance vs Income Dual-Axis".
  Map<String, List<TimeSeriesPoint>> attendanceTrendSeries(
    List<WeeklyRecord> records,
  ) {
    return {'Total Attendance': totalAttendanceTrend(records)};
  }

  /// Returns total income time series for the secondary (right) Y axis.
  ///
  /// Pair with [attendanceTrendSeries] on the primary axis.
  Map<String, List<TimeSeriesPoint>> incomeTrendSeries(
    List<WeeklyRecord> records,
  ) {
    return {'Total Income': totalIncomeTrend(records)};
  }

  // ---------------------------------------------------------------------------
  // Advanced Chart Methods
  // ---------------------------------------------------------------------------

  /// Simple linear-regression forecast of total attendance.
  /// Returns 'Historical' and 'Forecast' series.
  Map<String, List<TimeSeriesPoint>> attendanceForecast(
    List<WeeklyRecord> records, {
    int weeksAhead = 4,
  }) {
    if (records.length < 2) return {};
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));
    final n = sorted.length.toDouble();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < sorted.length; i++) {
      final x = i.toDouble();
      final y = sorted[i].totalAttendance.toDouble();
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    final denom = n * sumX2 - sumX * sumX;
    final slope = denom == 0 ? 0.0 : (n * sumXY - sumX * sumY) / denom;
    final intercept = (sumY - slope * sumX) / n;

    final historical = sorted
        .map(
          (r) => TimeSeriesPoint(
            x: r.weekStartDate,
            y: r.totalAttendance.toDouble(),
          ),
        )
        .toList();

    final lastDate = sorted.last.weekStartDate;
    final forecast = <TimeSeriesPoint>[historical.last];
    for (int i = 1; i <= weeksAhead; i++) {
      final forecastDate = lastDate.add(Duration(days: 7 * i));
      final x = (sorted.length - 1 + i).toDouble();
      final y = (slope * x + intercept).clamp(0.0, double.infinity).toDouble();
      forecast.add(TimeSeriesPoint(x: forecastDate, y: y));
    }
    return {'Historical': historical, 'Forecast': forecast};
  }

  /// N-week moving average of total attendance.
  /// Returns 'Actual' and a labelled moving-average series.
  Map<String, List<TimeSeriesPoint>> attendanceMovingAverage(
    List<WeeklyRecord> records, {
    int window = 3,
  }) {
    if (records.isEmpty) return {};
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));
    final actual = sorted
        .map(
          (r) => TimeSeriesPoint(
            x: r.weekStartDate,
            y: r.totalAttendance.toDouble(),
          ),
        )
        .toList();
    final ma = <TimeSeriesPoint>[];
    for (int i = window - 1; i < sorted.length; i++) {
      final sum = sorted
          .sublist(i - window + 1, i + 1)
          .fold(0.0, (acc, r) => acc + r.totalAttendance);
      ma.add(TimeSeriesPoint(x: sorted[i].weekStartDate, y: sum / window));
    }
    return {'Actual': actual, '$window-Week Moving Avg': ma};
  }

  /// IQR-based outlier detection on total attendance.
  /// Returns 'Normal' and 'Outliers' series.
  Map<String, List<TimeSeriesPoint>> attendanceWithOutliers(
    List<WeeklyRecord> records,
  ) {
    if (records.isEmpty) return {};
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));
    final values = sorted.map((r) => r.totalAttendance.toDouble()).toList()
      ..sort();
    if (values.length < 4) {
      final normal = sorted
          .map(
            (r) => TimeSeriesPoint(
              x: r.weekStartDate,
              y: r.totalAttendance.toDouble(),
            ),
          )
          .toList();
      return {'Normal': normal, 'Outliers': []};
    }
    final q1 = values[(values.length * 0.25).floor()];
    final q3 = values[(values.length * 0.75).floor()];
    final iqr = q3 - q1;
    final lower = q1 - 1.5 * iqr;
    final upper = q3 + 1.5 * iqr;
    final normal = <TimeSeriesPoint>[];
    final outliers = <TimeSeriesPoint>[];
    for (final r in sorted) {
      final val = r.totalAttendance.toDouble();
      final pt = TimeSeriesPoint(x: r.weekStartDate, y: val);
      if (val < lower || val > upper) {
        outliers.add(pt);
      } else {
        normal.add(pt);
      }
    }
    return {'Normal': normal, 'Outliers': outliers};
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
