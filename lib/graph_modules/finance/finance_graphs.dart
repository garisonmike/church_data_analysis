import 'package:church_analytics/graph_modules/graph_definition.dart';
import 'package:church_analytics/models/charts/time_series_point.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/ui/widgets/charts/charts.dart';

/// Assembles the financial graphs shown on the Financial Charts screen:
/// tithe and offerings trends, income composition and distribution,
/// pairwise comparisons, and per-capita giving metrics.
class FinanceGraphsModule {
  const FinanceGraphsModule._();

  static List<GraphDefinition> build(List<WeeklyRecord> records) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    return [
      GraphDefinition(
        id: 'tithe_offerings_trend',
        title: 'Tithe vs Offerings Trend',
        builder: (context) => LineChartWidget(
          seriesData: {
            'Tithe': analytics.titheTrend(sorted),
            'Offerings': analytics.offeringsTrend(sorted),
          },
          title: 'Tithe vs Offerings Trend',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'income_composition',
        title: 'Income Composition Over Time',
        builder: (context) => StackedAreaChartWidget(
          seriesData: analytics.titheOfferingsComposition(sorted),
          title: 'Income Composition Over Time',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'income_distribution',
        title: 'Income Distribution',
        minHeight: 260,
        maxHeight: 420,
        aspectRatio: 16 / 10,
        builder: (context) => PieChartWidget(
          data: analytics.incomeDistribution(sorted),
          title: 'Income Distribution',
        ),
      ),
      GraphDefinition(
        id: 'income_vs_attendance_dual',
        title: 'Income vs Attendance',
        builder: (context) => DualAxisChartWidget(
          primarySeries: analytics.attendanceTrendSeries(sorted),
          secondarySeries: analytics.incomeTrendSeries(sorted),
          title: 'Income vs Attendance',
          primaryAxisTitle: 'Attendance',
          secondaryAxisTitle: 'Income',
        ),
      ),
      GraphDefinition(
        id: 'tithe_vs_offerings_pairwise',
        title: 'Tithe vs Offerings Per Week',
        builder: (context) => BarChartWidget(
          seriesData: analytics.demographicPairPerWeek(
            sorted,
            'TITHE',
            'OFFERINGS',
          ),
          title: 'Tithe vs Offerings Per Week',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'tithe_vs_total_income_pairwise',
        title: 'Tithe vs Total Income Per Week',
        builder: (context) => BarChartWidget(
          seriesData: analytics.demographicPairPerWeek(
            sorted,
            'TITHE',
            'TOTAL_INCOME',
          ),
          title: 'Tithe vs Total Income Per Week',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'offerings_vs_total_income_pairwise',
        title: 'Offerings vs Total Income Per Week',
        builder: (context) => BarChartWidget(
          seriesData: analytics.demographicPairPerWeek(
            sorted,
            'OFFERINGS',
            'TOTAL_INCOME',
          ),
          title: 'Offerings vs Total Income Per Week',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'regular_vs_total_income',
        title: 'Regular vs Total Income Per Week',
        builder: (context) => BarChartWidget(
          seriesData: {
            'Regular Income': analytics.regularIncomePerWeek(sorted),
            'Total Income': analytics.totalIncomePerWeek(sorted),
          },
          title: 'Regular vs Total Income Per Week',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'tithe_per_attendee',
        title: 'Tithe Per Attendee Per Week',
        builder: (context) => BarChartWidget(
          seriesData: {
            'Tithe/Attendee': analytics.tithePerAttendeePerWeek(sorted),
          },
          title: 'Tithe Per Attendee Per Week',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'regular_income_per_adult',
        title: 'Regular Income Per Adult Per Week',
        builder: (context) => BarChartWidget(
          seriesData: {
            'Income/Adult': analytics.regularIncomePerAdultPerWeek(sorted),
          },
          title: 'Regular Income Per Adult Per Week',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'per_capita_metrics',
        title: 'All Per-Capita Metrics',
        builder: (context) => LineChartWidget(
          seriesData: {
            'Income/Att': analytics.incomePerAttendeeTrend(sorted),
            'Tithe/Att': sorted.map((r) {
              final att = r.totalAttendance;
              return TimeSeriesPoint(
                x: r.weekStartDate,
                y: att > 0 ? r.tithe / att : 0.0,
              );
            }).toList(),
            'Offerings/Att': sorted.map((r) {
              final att = r.totalAttendance;
              return TimeSeriesPoint(
                x: r.weekStartDate,
                y: att > 0 ? r.offerings / att : 0.0,
              );
            }).toList(),
          },
          title: 'All Per-Capita Metrics',
          yAxisTitle: 'Amount',
        ),
      ),
    ];
  }
}
