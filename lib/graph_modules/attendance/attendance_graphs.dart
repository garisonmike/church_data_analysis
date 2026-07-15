import 'package:church_analytics/graph_modules/graph_definition.dart';
import 'package:church_analytics/models/charts/category_point.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/ui/widgets/charts/charts.dart';

/// Assembles the attendance graphs shown on the Attendance Charts screen:
/// weekly Sabbath attendance by category (men, women, youth, children,
/// Sunday home church), trends, growth, and demographic composition.
class AttendanceGraphsModule {
  const AttendanceGraphsModule._();

  static List<GraphDefinition> build(List<WeeklyRecord> records) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    double avg(double Function(WeeklyRecord r) fn) => sorted.isEmpty
        ? 0
        : sorted.map(fn).reduce((a, b) => a + b) / sorted.length;

    final categoryData = {
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

    final growthData = {
      'Growth %': analytics
          .attendanceGrowthRates(sorted)
          .map((p) => CategoryPoint(label: p.x, value: p.y))
          .toList(),
    };

    return [
      GraphDefinition(
        id: 'average_attendance_by_category',
        title: 'Average Attendance by Category',
        builder: (context) => BarChartWidget(
          seriesData: categoryData,
          title: 'Average Attendance by Category',
          yAxisTitle: 'Attendance',
        ),
      ),
      GraphDefinition(
        id: 'total_attendance_trend',
        title: 'Total Attendance Trend',
        builder: (context) => LineChartWidget(
          seriesData: {
            'Total Attendance': analytics.totalAttendanceTrend(sorted),
          },
          title: 'Total Attendance Trend',
          yAxisTitle: 'Attendance',
        ),
      ),
      GraphDefinition(
        id: 'attendance_distribution',
        title: 'Attendance Distribution',
        minHeight: 260,
        maxHeight: 420,
        aspectRatio: 16 / 10,
        builder: (context) => PieChartWidget(
          data: analytics.demographicDistribution(sorted),
          title: 'Attendance Distribution',
        ),
      ),
      GraphDefinition(
        id: 'attendance_growth',
        title: 'Attendance Growth Rate (%)',
        builder: (context) => BarChartWidget(
          seriesData: growthData,
          title: 'Attendance Growth Rate (%)',
          yAxisTitle: 'Growth %',
        ),
      ),
      GraphDefinition(
        id: 'adult_vs_young',
        title: 'Adult vs Young Attendance Per Week',
        builder: (context) => BarChartWidget(
          seriesData: {
            'Adults': analytics.adultAttendancePerWeek(sorted),
            'Young': analytics.youngAttendancePerWeek(sorted),
          },
          title: 'Adult vs Young Attendance Per Week',
          yAxisTitle: 'Attendance',
        ),
      ),
      GraphDefinition(
        id: 'demographic_percentage_trends',
        title: 'Demographic % Trends',
        builder: (context) => LineChartWidget(
          seriesData: analytics.demographicPercentageTrends(sorted),
          title: 'Demographic % Trends',
          yAxisTitle: 'Percentage (%)',
        ),
      ),
      GraphDefinition(
        id: 'average_demographic_percentage',
        title: 'Average Demographic Percentage',
        builder: (context) => BarChartWidget(
          seriesData: {
            'Average %': analytics.averageDemographicPercentages(sorted),
          },
          title: 'Average Demographic Percentage',
          yAxisTitle: 'Percentage (%)',
        ),
      ),
    ];
  }
}
