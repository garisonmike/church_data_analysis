import 'package:church_analytics/graph_modules/graph_definition.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/analytics_service.dart';
import 'package:church_analytics/ui/widgets/charts/charts.dart';

/// Assembles the spiritual-life and outreach graphs: the SDA-specific
/// discipleship and mission metrics that are entered on every weekly record
/// (baptisms, Holy Communion participation, Sabbath School attendance,
/// mission offering, and visitors) but were not surfaced on any chart screen.
///
/// Sabbath School, mission offering, and visitor counts are optional per
/// week, so their series only include the weeks where a value was recorded;
/// baptisms and Holy Communion default absent weeks to zero.
class SpiritualLifeGraphsModule {
  const SpiritualLifeGraphsModule._();

  static List<GraphDefinition> build(List<WeeklyRecord> records) {
    final analytics = AnalyticsService();
    final sorted = List<WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    return [
      GraphDefinition(
        id: 'baptisms_trend',
        title: 'Baptisms Per Week',
        builder: (context) => LineChartWidget(
          seriesData: {'Baptisms': analytics.baptismsTrend(sorted)},
          title: 'Baptisms Per Week',
          yAxisTitle: 'Baptisms',
        ),
      ),
      GraphDefinition(
        id: 'holy_communion_trend',
        title: 'Holy Communion Participation',
        builder: (context) => LineChartWidget(
          seriesData: {
            'Holy Communion': analytics.holyCommunionTrend(sorted),
          },
          title: 'Holy Communion Participation',
          yAxisTitle: 'Participants',
        ),
      ),
      GraphDefinition(
        id: 'sabbath_school_trend',
        title: 'Sabbath School Attendance',
        builder: (context) => LineChartWidget(
          seriesData: {
            'Sabbath School': analytics.sabbathSchoolTrend(sorted),
          },
          title: 'Sabbath School Attendance',
          yAxisTitle: 'Attendance',
        ),
      ),
      GraphDefinition(
        id: 'mission_offering_trend',
        title: 'Mission Offering Over Time',
        builder: (context) => LineChartWidget(
          seriesData: {
            'Mission Offering': analytics.missionOfferingTrend(sorted),
          },
          title: 'Mission Offering Over Time',
          yAxisTitle: 'Amount',
        ),
      ),
      GraphDefinition(
        id: 'visitors_trend',
        title: 'Visitors Per Week',
        builder: (context) => LineChartWidget(
          seriesData: {'Visitors': analytics.visitorsTrend(sorted)},
          title: 'Visitors Per Week',
          yAxisTitle: 'Visitors',
        ),
      ),
    ];
  }
}
