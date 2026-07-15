import 'package:church_analytics/graph_modules/graph_modules.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WeeklyRecord _record(int week) => WeeklyRecord(
  id: week,
  churchId: 1,
  weekStartDate: DateTime(2026, 1, 3).add(Duration(days: 7 * week)),
  men: 50 + week,
  women: 65 + week,
  youth: 30 + week,
  children: 25 + week,
  sundayHomeChurch: 20 + week,
  baptisms: week % 3,
  holyCommunion: 100 + week,
  tithe: 50000.0 + week * 1000,
  offerings: 20000.0 + week * 500,
  emergencyCollection: 2000.0,
  plannedCollection: 6000.0,
  sabbathSchoolAttendance: 80 + week,
  visitorsCount: week % 4,
  missionOffering: 3000.0 + week * 100,
  createdAt: DateTime(2026, 1, 3),
  updatedAt: DateTime(2026, 1, 3),
);

void main() {
  final records = List.generate(8, _record);

  final modules = <String, List<GraphDefinition> Function(List<WeeklyRecord>)>{
    'AttendanceGraphsModule': AttendanceGraphsModule.build,
    'FinanceGraphsModule': FinanceGraphsModule.build,
    'CorrelationGraphsModule': CorrelationGraphsModule.build,
    'ForecastGraphsModule': ForecastGraphsModule.build,
    'SpiritualLifeGraphsModule': SpiritualLifeGraphsModule.build,
  };

  final expectedCounts = <String, int>{
    'AttendanceGraphsModule': 7,
    'FinanceGraphsModule': 11,
    'CorrelationGraphsModule': 6,
    'ForecastGraphsModule': 5,
    'SpiritualLifeGraphsModule': 5,
  };

  for (final entry in modules.entries) {
    group(entry.key, () {
      test('produces the expected graph catalogue', () {
        final graphs = entry.value(records);
        expect(graphs.length, expectedCounts[entry.key]);

        final ids = graphs.map((g) => g.id).toSet();
        expect(ids.length, graphs.length, reason: 'graph ids must be unique');
        for (final g in graphs) {
          expect(g.title, isNotEmpty);
        }
      });

      test('graph builders construct without records being pre-sorted', () {
        // Modules must sort defensively; reversed input must not throw.
        final graphs = entry.value(records.reversed.toList());
        expect(graphs, isNotEmpty);
      });
    });
  }

  testWidgets('GraphListView renders every attendance graph lazily', (
    tester,
  ) async {
    final graphs = AttendanceGraphsModule.build(records);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GraphListView(graphs: graphs, captureKey: GlobalKey()),
        ),
      ),
    );
    await tester.pump();
    // First graph is eager and must be visible immediately.
    expect(find.text('Average Attendance by Category'), findsOneWidget);
    // Flush the lazy charts' fade-in timers before the tree is disposed.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('ForecastGraphsModule heatmap builder renders', (tester) async {
    final graphs = ForecastGraphsModule.build(records);
    final heatmap = graphs.firstWhere(
      (g) => g.id == 'attendance_income_heatmap',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 440,
            child: Builder(builder: heatmap.builder),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Attendance vs Funds Heatmap'), findsOneWidget);
  });

  group('SpiritualLifeGraphsModule', () {
    test('covers every SDA metric recorded weekly', () {
      final ids = SpiritualLifeGraphsModule.build(records).map((g) => g.id);
      expect(ids, containsAll(<String>[
        'baptisms_trend',
        'holy_communion_trend',
        'sabbath_school_trend',
        'mission_offering_trend',
        'visitors_trend',
      ]));
    });

    testWidgets('renders the first spiritual-life graph', (tester) async {
      final graphs = SpiritualLifeGraphsModule.build(records);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GraphListView(graphs: graphs, captureKey: GlobalKey()),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Baptisms Per Week'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
