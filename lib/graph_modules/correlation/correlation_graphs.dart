import 'package:church_analytics/graph_modules/graph_definition.dart';
import 'package:church_analytics/models/charts/category_point.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/ui/widgets/charts/charts.dart';

/// Assembles the correlation graphs shown on the Correlation Charts screen:
/// attendance-versus-income relationships, demographic and income-component
/// averages, and paired dual-axis trends.
class CorrelationGraphsModule {
  const CorrelationGraphsModule._();

  static List<GraphDefinition> build(List<WeeklyRecord> records) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    double avg(double Function(WeeklyRecord r) fn) => sorted.isEmpty
        ? 0
        : sorted.map(fn).reduce((a, b) => a + b) / sorted.length;

    final demographicsData = {
      'Average': [
        CategoryPoint(label: 'Men', value: avg((r) => r.men.toDouble())),
        CategoryPoint(label: 'Women', value: avg((r) => r.women.toDouble())),
        CategoryPoint(label: 'Youth', value: avg((r) => r.youth.toDouble())),
        CategoryPoint(
          label: 'Children',
          value: avg((r) => r.children.toDouble()),
        ),
        CategoryPoint(
          label: 'Home Church',
          value: avg((r) => r.sundayHomeChurch.toDouble()),
        ),
      ],
    };

    final incomeComponentsData = {
      'Average': [
        CategoryPoint(label: 'Tithe', value: avg((r) => r.tithe)),
        CategoryPoint(label: 'Offerings', value: avg((r) => r.offerings)),
        CategoryPoint(
          label: 'Emergency',
          value: avg((r) => r.emergencyCollection),
        ),
        CategoryPoint(label: 'Planned', value: avg((r) => r.plannedCollection)),
      ],
    };

    return [
      GraphDefinition(
        id: 'attendance_income_dual',
        title: 'Attendance vs Income Over Time',
        builder: (context) => DualAxisChartWidget(
          primarySeries: analytics.attendanceTrendSeries(sorted),
          secondarySeries: analytics.incomeTrendSeries(sorted),
          title: 'Attendance vs Income Over Time',
          primaryAxisTitle: 'Attendance',
          secondaryAxisTitle: 'Income',
        ),
      ),
      GraphDefinition(
        id: 'average_demographics',
        title: 'Average Attendance by Demographic',
        builder: (context) => BarChartWidget(
          seriesData: demographicsData,
          title: 'Average Attendance by Demographic',
          yAxisTitle: 'Attendance',
        ),
      ),
      GraphDefinition(
        id: 'average_income_components',
        title: 'Average Income by Component',
        builder: (context) => BarChartWidget(
          seriesData: incomeComponentsData,
          title: 'Average Income by Component',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'attendance_income_scatter',
        title: 'Attendance vs Income Correlation',
        minHeight: 260,
        maxHeight: 420,
        aspectRatio: 16 / 10,
        builder: (context) => ScatterCorrelationChart(
          data: analytics.attendanceVsIncomeScatter(sorted),
          title: 'Attendance vs Income Correlation',
          xAxisTitle: 'Total Attendance',
          yAxisTitle: 'Total Income',
        ),
      ),
      GraphDefinition(
        id: 'men_vs_tithe_dual',
        title: 'Men vs Tithe Over Time',
        builder: (context) => DualAxisChartWidget(
          primarySeries: {'Men': analytics.demographicTrend(sorted, 'MEN')},
          secondarySeries: {'Tithe': analytics.titheTrend(sorted)},
          title: 'Men vs Tithe Over Time',
          primaryAxisTitle: 'Men Attendance',
          secondaryAxisTitle: 'Tithe Amount',
        ),
      ),
      GraphDefinition(
        id: 'women_vs_offerings_dual',
        title: 'Women vs Offerings Over Time',
        builder: (context) => DualAxisChartWidget(
          primarySeries: {
            'Women': analytics.demographicTrend(sorted, 'WOMEN'),
          },
          secondarySeries: {'Offerings': analytics.offeringsTrend(sorted)},
          title: 'Women vs Offerings Over Time',
          primaryAxisTitle: 'Women Attendance',
          secondaryAxisTitle: 'Offerings Amount',
        ),
      ),
    ];
  }
}
