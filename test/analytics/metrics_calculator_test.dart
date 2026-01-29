import 'package:church_analytics/analytics/metrics_calculator.dart';
import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MetricsCalculator calculator;

  setUp(() {
    calculator = MetricsCalculator();
  });

  group('Total Attendance Calculator', () {
    test('calculates total attendance for a single record', () {
      final record = _createRecord(
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
      );

      expect(calculator.calculateTotalAttendance(record), 170);
    });

    test('calculates total attendance for multiple records', () {
      final records = [
        _createRecord(
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
        ),
        _createRecord(
          men: 55,
          women: 65,
          youth: 35,
          children: 25,
          sundayHomeChurch: 15,
        ),
        _createRecord(
          men: 60,
          women: 70,
          youth: 40,
          children: 30,
          sundayHomeChurch: 20,
        ),
      ];

      expect(
        calculator.calculateTotalAttendanceForRecords(records),
        170 + 195 + 220,
      );
    });
  });

  group('Total Income Calculator', () {
    test('calculates total income for a single record', () {
      final record = _createRecord(
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
      );

      expect(calculator.calculateTotalIncome(record), 2000.0);
    });

    test('calculates total income for multiple records', () {
      final records = [
        _createRecord(
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 300.0,
        ),
        _createRecord(
          tithe: 1100.0,
          offerings: 550.0,
          emergencyCollection: 220.0,
          plannedCollection: 330.0,
        ),
        _createRecord(
          tithe: 1200.0,
          offerings: 600.0,
          emergencyCollection: 240.0,
          plannedCollection: 360.0,
        ),
      ];

      expect(
        calculator.calculateTotalIncomeForRecords(records),
        2000.0 + 2200.0 + 2400.0,
      );
    });
  });

  group('Averages Calculator', () {
    test('calculates average attendance', () {
      final records = [
        _createRecord(
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
        ), // 170
        _createRecord(
          men: 60,
          women: 70,
          youth: 40,
          children: 30,
          sundayHomeChurch: 20,
        ), // 220
        _createRecord(
          men: 40,
          women: 50,
          youth: 20,
          children: 10,
          sundayHomeChurch: 0,
        ), // 120
      ];

      expect(
        calculator.calculateAverageAttendance(records),
        closeTo(170.0, 0.01),
      );
    });

    test('calculates average income', () {
      final records = [
        _createRecord(
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 300.0,
        ), // 2000
        _createRecord(
          tithe: 1500.0,
          offerings: 750.0,
          emergencyCollection: 300.0,
          plannedCollection: 450.0,
        ), // 3000
        _createRecord(
          tithe: 500.0,
          offerings: 250.0,
          emergencyCollection: 100.0,
          plannedCollection: 150.0,
        ), // 1000
      ];

      expect(calculator.calculateAverageIncome(records), closeTo(2000.0, 0.01));
    });

    test('returns 0 for empty list', () {
      expect(calculator.calculateAverageAttendance([]), 0.0);
      expect(calculator.calculateAverageIncome([]), 0.0);
    });
  });

  group('Growth Percentage Calculator', () {
    test('calculates attendance growth percentage', () {
      final previousWeek = _createRecord(
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
      ); // 170
      final currentWeek = _createRecord(
        men: 60,
        women: 70,
        youth: 35,
        children: 25,
        sundayHomeChurch: 15,
      ); // 205

      final growth = calculator.calculateAttendanceGrowthPercentage(
        currentWeek,
        previousWeek,
      );

      // Growth = (205 - 170) / 170 * 100 = 20.588%
      expect(growth, closeTo(20.588, 0.01));
    });

    test('calculates income growth percentage', () {
      final previousWeek = _createRecord(
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
      ); // 2000
      final currentWeek = _createRecord(
        tithe: 1200.0,
        offerings: 600.0,
        emergencyCollection: 240.0,
        plannedCollection: 360.0,
      ); // 2400

      final growth = calculator.calculateIncomeGrowthPercentage(
        currentWeek,
        previousWeek,
      );

      // Growth = (2400 - 2000) / 2000 * 100 = 20%
      expect(growth, 20.0);
    });

    test('returns null when no previous week', () {
      final currentWeek = _createRecord(
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
      );

      expect(
        calculator.calculateAttendanceGrowthPercentage(currentWeek, null),
        isNull,
      );
      expect(
        calculator.calculateIncomeGrowthPercentage(currentWeek, null),
        isNull,
      );
    });

    test('calculates period growth percentage', () {
      final records = [
        _createRecord(
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
        ), // 170
        _createRecord(
          men: 55,
          women: 65,
          youth: 32,
          children: 22,
          sundayHomeChurch: 12,
        ), // 186
        _createRecord(
          men: 60,
          women: 70,
          youth: 35,
          children: 25,
          sundayHomeChurch: 15,
        ), // 205
      ];

      final growth = calculator.calculatePeriodGrowthPercentage(records);

      // Growth = (205 - 170) / 170 * 100 = 20.588%
      expect(growth, closeTo(20.588, 0.01));
    });

    test('returns null for period growth with less than 2 records', () {
      expect(calculator.calculatePeriodGrowthPercentage([]), isNull);
      expect(
        calculator.calculatePeriodGrowthPercentage([_createRecord()]),
        isNull,
      );
    });
  });

  group('Attendance-to-Income Ratio Calculator', () {
    test('calculates ratio for a single record', () {
      final record = _createRecord(
        men: 50,
        women: 50,
        youth: 0,
        children: 0,
        sundayHomeChurch: 0, // 100
        tithe: 5000.0,
        offerings: 0,
        emergencyCollection: 0,
        plannedCollection: 0, // 5000
      );

      // 5000 / 100 = 50
      expect(calculator.calculateAttendanceToIncomeRatio(record), 50.0);
    });

    test('returns 0 when attendance is 0', () {
      final record = _createRecord(
        men: 0,
        women: 0,
        youth: 0,
        children: 0,
        sundayHomeChurch: 0,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
      );

      expect(calculator.calculateAttendanceToIncomeRatio(record), 0.0);
    });

    test('calculates average ratio for multiple records', () {
      final records = [
        _createRecord(
          men: 100,
          women: 0,
          youth: 0,
          children: 0,
          sundayHomeChurch: 0,
          tithe: 5000.0,
        ), // 50
        _createRecord(
          men: 200,
          women: 0,
          youth: 0,
          children: 0,
          sundayHomeChurch: 0,
          tithe: 6000.0,
        ), // 30
      ];

      // Total: 300 attendance, 11000 income = 36.67
      expect(
        calculator.calculateAverageAttendanceToIncomeRatio(records),
        closeTo(36.67, 0.01),
      );
    });
  });

  group('Per-Capita Giving Calculator', () {
    test('calculates per-capita giving', () {
      final record = _createRecord(
        men: 50,
        women: 50,
        youth: 0,
        children: 0,
        sundayHomeChurch: 0, // 100
        tithe: 3000.0,
        offerings: 2000.0,
        emergencyCollection: 0,
        plannedCollection: 0, // 5000
      );

      // 5000 / 100 = 50
      expect(calculator.calculatePerCapitaGiving(record), 50.0);
    });

    test('calculates average per-capita giving', () {
      final records = [
        _createRecord(
          men: 100,
          women: 0,
          youth: 0,
          children: 0,
          sundayHomeChurch: 0,
          tithe: 5000.0,
        ), // 50
        _createRecord(
          men: 50,
          women: 0,
          youth: 0,
          children: 0,
          sundayHomeChurch: 0,
          tithe: 1500.0,
        ), // 30
      ];

      // Total: 150 attendance, 6500 income = 43.33
      expect(
        calculator.calculateAveragePerCapitaGiving(records),
        closeTo(43.33, 0.01),
      );
    });
  });

  group('Category Percentage Calculator', () {
    test('calculates attendance category percentages', () {
      final record = _createRecord(
        men: 50,
        women: 30,
        youth: 10,
        children: 5,
        sundayHomeChurch: 5,
      ); // Total: 100

      final percentages = calculator.calculateAttendanceCategoryPercentages(
        record,
      );

      expect(percentages['men'], 50.0);
      expect(percentages['women'], 30.0);
      expect(percentages['youth'], 10.0);
      expect(percentages['children'], 5.0);
      expect(percentages['sundayHomeChurch'], 5.0);
    });

    test('returns 0 for all categories when total is 0', () {
      final record = _createRecord(
        men: 0,
        women: 0,
        youth: 0,
        children: 0,
        sundayHomeChurch: 0,
      );

      final percentages = calculator.calculateAttendanceCategoryPercentages(
        record,
      );

      expect(percentages['men'], 0.0);
      expect(percentages['women'], 0.0);
      expect(percentages['youth'], 0.0);
    });

    test('calculates average attendance category percentages', () {
      final records = [
        _createRecord(
          men: 50,
          women: 30,
          youth: 10,
          children: 5,
          sundayHomeChurch: 5,
        ), // 100
        _createRecord(
          men: 100,
          women: 60,
          youth: 20,
          children: 10,
          sundayHomeChurch: 10,
        ), // 200
      ];
      // Total: 150 men, 90 women, 30 youth, 15 children, 15 sunday = 300
      // Percentages: 50%, 30%, 10%, 5%, 5%

      final percentages = calculator
          .calculateAverageAttendanceCategoryPercentages(records);

      expect(percentages['men'], 50.0);
      expect(percentages['women'], 30.0);
      expect(percentages['youth'], 10.0);
      expect(percentages['children'], 5.0);
      expect(percentages['sundayHomeChurch'], 5.0);
    });

    test('calculates income category percentages', () {
      final record = _createRecord(
        tithe: 5000.0,
        offerings: 3000.0,
        emergencyCollection: 1000.0,
        plannedCollection: 1000.0,
      ); // Total: 10000

      final percentages = calculator.calculateIncomeCategoryPercentages(record);

      expect(percentages['tithe'], 50.0);
      expect(percentages['offerings'], 30.0);
      expect(percentages['emergencyCollection'], 10.0);
      expect(percentages['plannedCollection'], 10.0);
    });

    test('calculates average income category percentages', () {
      final records = [
        _createRecord(
          tithe: 5000.0,
          offerings: 3000.0,
          emergencyCollection: 1000.0,
          plannedCollection: 1000.0,
        ), // 10000
        _createRecord(
          tithe: 5000.0,
          offerings: 3000.0,
          emergencyCollection: 1000.0,
          plannedCollection: 1000.0,
        ), // 10000
      ];
      // Total: 10000 tithe, 6000 offerings, 2000 emergency, 2000 planned = 20000
      // Percentages: 50%, 30%, 10%, 10%

      final percentages = calculator.calculateAverageIncomeCategoryPercentages(
        records,
      );

      expect(percentages['tithe'], 50.0);
      expect(percentages['offerings'], 30.0);
      expect(percentages['emergencyCollection'], 10.0);
      expect(percentages['plannedCollection'], 10.0);
    });
  });

  group('All Metrics Calculator', () {
    test('calculates all metrics for a single record', () {
      final record = _createRecord(
        men: 50,
        women: 30,
        youth: 10,
        children: 5,
        sundayHomeChurch: 5,
        tithe: 5000.0,
        offerings: 3000.0,
        emergencyCollection: 1000.0,
        plannedCollection: 1000.0,
      );

      final metrics = calculator.calculateAllMetrics(record);

      expect(metrics['totalAttendance'], 100);
      expect(metrics['totalIncome'], 10000.0);
      expect(metrics['perCapitaGiving'], 100.0);
      expect(metrics['attendanceToIncomeRatio'], 100.0);
      expect(
        metrics['attendanceCategoryPercentages'],
        isA<Map<String, double>>(),
      );
      expect(metrics['incomeCategoryPercentages'], isA<Map<String, double>>());
    });

    test('calculates summary metrics for multiple records', () {
      final records = [
        _createRecord(
          men: 50,
          women: 30,
          youth: 10,
          children: 5,
          sundayHomeChurch: 5,
          tithe: 5000.0,
        ),
        _createRecord(
          men: 60,
          women: 40,
          youth: 20,
          children: 10,
          sundayHomeChurch: 10,
          tithe: 7000.0,
        ),
      ];

      final summary = calculator.calculateSummaryMetrics(records);

      expect(summary['totalAttendance'], 100 + 140);
      expect(summary['totalIncome'], 5000.0 + 7000.0);
      expect(summary['averageAttendance'], 120.0);
      expect(summary['averageIncome'], 6000.0);
      expect(summary['recordCount'], 2);
      expect(summary['averagePerCapitaGiving'], isA<double>());
    });
  });
}

// Helper function to create test records
WeeklyRecord _createRecord({
  int men = 0,
  int women = 0,
  int youth = 0,
  int children = 0,
  int sundayHomeChurch = 0,
  double tithe = 0.0,
  double offerings = 0.0,
  double emergencyCollection = 0.0,
  double plannedCollection = 0.0,
}) {
  return WeeklyRecord(
    churchId: 1,
    weekStartDate: DateTime(2026, 1, 1),
    men: men,
    women: women,
    youth: youth,
    children: children,
    sundayHomeChurch: sundayHomeChurch,
    tithe: tithe,
    offerings: offerings,
    emergencyCollection: emergencyCollection,
    plannedCollection: plannedCollection,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
