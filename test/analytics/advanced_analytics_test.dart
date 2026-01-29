import 'package:church_analytics/analytics/advanced_analytics.dart';
import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AdvancedAnalytics analytics;

  setUp(() {
    analytics = AdvancedAnalytics();
  });

  group('Moving Averages', () {
    test('calculates moving average for attendance', () {
      final records = [
        _createRecord(men: 100, women: 0), // 100
        _createRecord(men: 110, women: 0), // 110
        _createRecord(men: 120, women: 0), // 120
        _createRecord(men: 130, women: 0), // 130
        _createRecord(men: 140, women: 0), // 140
      ];

      final ma = analytics.calculateMovingAverageAttendance(records, 3);

      expect(ma.length, 3); // 5 records - 3 window + 1
      expect(ma[0], closeTo(110.0, 0.01)); // (100+110+120)/3
      expect(ma[1], closeTo(120.0, 0.01)); // (110+120+130)/3
      expect(ma[2], closeTo(130.0, 0.01)); // (120+130+140)/3
    });

    test('calculates moving average for income', () {
      final records = [
        _createRecord(tithe: 1000.0), // 1000
        _createRecord(tithe: 2000.0), // 2000
        _createRecord(tithe: 3000.0), // 3000
        _createRecord(tithe: 4000.0), // 4000
      ];

      final ma = analytics.calculateMovingAverageIncome(records, 2);

      expect(ma.length, 3); // 4 records - 2 window + 1
      expect(ma[0], 1500.0); // (1000+2000)/2
      expect(ma[1], 2500.0); // (2000+3000)/2
      expect(ma[2], 3500.0); // (3000+4000)/2
    });

    test('returns empty list for invalid window size', () {
      final records = [
        _createRecord(men: 100, women: 0),
        _createRecord(men: 110, women: 0),
      ];

      expect(analytics.calculateMovingAverageAttendance(records, 0), isEmpty);
      expect(analytics.calculateMovingAverageAttendance(records, 3), isEmpty);
      expect(analytics.calculateMovingAverageAttendance([], 2), isEmpty);
    });
  });

  group('Linear Trend Line', () {
    test('calculates trend line for attendance with positive slope', () {
      final records = [
        _createRecord(men: 100, women: 0), // 100
        _createRecord(men: 110, women: 0), // 110
        _createRecord(men: 120, women: 0), // 120
        _createRecord(men: 130, women: 0), // 130
      ];

      final trendLine = analytics.calculateAttendanceTrendLine(records);

      expect(trendLine, isNotNull);
      expect(trendLine!['slope'], closeTo(10.0, 0.01)); // Linear increase of 10
      expect(trendLine['intercept'], closeTo(100.0, 0.01));
    });

    test('calculates trend line for income', () {
      final records = [
        _createRecord(tithe: 1000.0), // 1000
        _createRecord(tithe: 1500.0), // 1500
        _createRecord(tithe: 2000.0), // 2000
        _createRecord(tithe: 2500.0), // 2500
      ];

      final trendLine = analytics.calculateIncomeTrendLine(records);

      expect(trendLine, isNotNull);
      expect(
        trendLine!['slope'],
        closeTo(500.0, 0.01),
      ); // Linear increase of 500
      expect(trendLine['intercept'], closeTo(1000.0, 0.01));
    });

    test('returns null for insufficient data', () {
      expect(analytics.calculateAttendanceTrendLine([]), isNull);
      expect(analytics.calculateAttendanceTrendLine([_createRecord()]), isNull);
    });
  });

  group('Correlation Coefficient', () {
    test('calculates perfect positive correlation', () {
      final records = [
        _createRecord(men: 100, women: 0, tithe: 1000.0), // 100, 1000
        _createRecord(men: 200, women: 0, tithe: 2000.0), // 200, 2000
        _createRecord(men: 300, women: 0, tithe: 3000.0), // 300, 3000
        _createRecord(men: 400, women: 0, tithe: 4000.0), // 400, 4000
      ];

      final correlation = analytics.calculateAttendanceIncomeCorrelation(
        records,
      );

      expect(correlation, isNotNull);
      expect(correlation!, closeTo(1.0, 0.01)); // Perfect positive correlation
    });

    test('calculates no correlation', () {
      final records = [
        _createRecord(men: 100, women: 0, tithe: 2000.0),
        _createRecord(men: 200, women: 0, tithe: 2000.0),
        _createRecord(men: 300, women: 0, tithe: 2000.0),
        _createRecord(men: 400, women: 0, tithe: 2000.0),
      ];

      final correlation = analytics.calculateAttendanceIncomeCorrelation(
        records,
      );

      // Income is constant (std dev = 0), so correlation is undefined (null)
      expect(correlation, isNull);
    });

    test('calculates negative correlation', () {
      final records = [
        _createRecord(men: 400, women: 0, tithe: 1000.0), // 400, 1000
        _createRecord(men: 300, women: 0, tithe: 2000.0), // 300, 2000
        _createRecord(men: 200, women: 0, tithe: 3000.0), // 200, 3000
        _createRecord(men: 100, women: 0, tithe: 4000.0), // 100, 4000
      ];

      final correlation = analytics.calculateAttendanceIncomeCorrelation(
        records,
      );

      expect(correlation, isNotNull);
      expect(correlation!, closeTo(-1.0, 0.01)); // Perfect negative correlation
    });

    test('returns null for insufficient data', () {
      expect(analytics.calculateAttendanceIncomeCorrelation([]), isNull);
      expect(
        analytics.calculateAttendanceIncomeCorrelation([_createRecord()]),
        isNull,
      );
    });
  });

  group('Forecast Projection', () {
    test('forecasts attendance with positive trend', () {
      final records = [
        _createRecord(men: 100, women: 0), // 100
        _createRecord(men: 110, women: 0), // 110
        _createRecord(men: 120, women: 0), // 120
        _createRecord(men: 130, women: 0), // 130
      ];

      final forecast = analytics.forecastAttendance(records, 3);

      expect(forecast.length, 3);
      expect(forecast[0], closeTo(140.0, 1.0)); // Next prediction
      expect(forecast[1], closeTo(150.0, 1.0)); // Following prediction
      expect(forecast[2], closeTo(160.0, 1.0)); // Third prediction
    });

    test('forecasts income', () {
      final records = [
        _createRecord(tithe: 1000.0),
        _createRecord(tithe: 1500.0),
        _createRecord(tithe: 2000.0),
        _createRecord(tithe: 2500.0),
      ];

      final forecast = analytics.forecastIncome(records, 2);

      expect(forecast.length, 2);
      expect(forecast[0], closeTo(3000.0, 10.0));
      expect(forecast[1], closeTo(3500.0, 10.0));
    });

    test('does not predict negative values', () {
      final records = [
        _createRecord(men: 100, women: 0),
        _createRecord(men: 90, women: 0),
        _createRecord(men: 80, women: 0),
        _createRecord(men: 70, women: 0),
      ];

      final forecast = analytics.forecastAttendance(records, 10);

      // All forecasts should be >= 0
      for (final value in forecast) {
        expect(value, greaterThanOrEqualTo(0.0));
      }
    });

    test('returns empty list for invalid inputs', () {
      expect(analytics.forecastAttendance([], 3), isEmpty);
      expect(analytics.forecastAttendance([_createRecord()], 3), isEmpty);
      expect(
        analytics.forecastAttendance([_createRecord(), _createRecord()], 0),
        isEmpty,
      );
    });
  });

  group('Outlier Detection', () {
    test('detects attendance outliers using IQR method', () {
      final records = [
        _createRecord(men: 100, women: 0), // 100
        _createRecord(men: 105, women: 0), // 105
        _createRecord(men: 110, women: 0), // 110
        _createRecord(men: 115, women: 0), // 115
        _createRecord(men: 300, women: 0), // 300 - outlier
      ];

      final outliers = analytics.detectAttendanceOutliers(records);

      expect(outliers.length, greaterThan(0));
      expect(outliers.any((r) => r.totalAttendance == 300), isTrue);
    });

    test('detects income outliers', () {
      final records = [
        _createRecord(tithe: 1000.0), // 1000
        _createRecord(tithe: 1100.0), // 1100
        _createRecord(tithe: 1200.0), // 1200
        _createRecord(tithe: 1300.0), // 1300
        _createRecord(tithe: 5000.0), // 5000 - outlier
      ];

      final outliers = analytics.detectIncomeOutliers(records);

      expect(outliers.length, greaterThan(0));
      expect(outliers.any((r) => r.totalIncome == 5000.0), isTrue);
    });

    test('returns empty list for insufficient data', () {
      expect(analytics.detectAttendanceOutliers([]), isEmpty);
      expect(analytics.detectAttendanceOutliers([_createRecord()]), isEmpty);
      expect(
        analytics.detectAttendanceOutliers([_createRecord(), _createRecord()]),
        isEmpty,
      );
    });

    test('returns empty list when no outliers exist', () {
      final records = [
        _createRecord(men: 100, women: 0),
        _createRecord(men: 105, women: 0),
        _createRecord(men: 110, women: 0),
        _createRecord(men: 115, women: 0),
        _createRecord(men: 120, women: 0),
      ];

      final outliers = analytics.detectAttendanceOutliers(records);

      expect(outliers, isEmpty);
    });
  });

  group('Rolling Metrics', () {
    test('calculates rolling 4-week metrics', () {
      final records = [
        _createRecord(
          men: 100,
          women: 0,
          tithe: 1000.0,
          weekDate: DateTime(2026, 1, 1),
        ),
        _createRecord(
          men: 110,
          women: 0,
          tithe: 1100.0,
          weekDate: DateTime(2026, 1, 8),
        ),
        _createRecord(
          men: 120,
          women: 0,
          tithe: 1200.0,
          weekDate: DateTime(2026, 1, 15),
        ),
        _createRecord(
          men: 130,
          women: 0,
          tithe: 1300.0,
          weekDate: DateTime(2026, 1, 22),
        ),
        _createRecord(
          men: 140,
          women: 0,
          tithe: 1400.0,
          weekDate: DateTime(2026, 1, 29),
        ),
      ];

      final metrics = analytics.calculateRolling4WeekMetrics(records);

      expect(metrics['recordCount'], 4);
      expect(
        metrics['averageAttendance'],
        closeTo(125.0, 0.1), // Last 4 records: (110+120+130+140)/4 = 125
      ); // (110+120+130+140)/4
      expect(
        metrics['averageIncome'],
        closeTo(1250.0, 0.1), // (1100+1200+1300+1400)/4 = 1250
      );
      expect(metrics['totalAttendance'], 500); // 110+120+130+140 = 500
      expect(metrics['totalIncome'], 5000.0); // 1100+1200+1300+1400 = 5000
      expect(metrics['growthRate'], isNotNull);
    });

    test('calculates rolling metrics for custom window', () {
      final records = [
        _createRecord(men: 100, women: 0),
        _createRecord(men: 110, women: 0),
        _createRecord(men: 120, women: 0),
      ];

      final metrics = analytics.calculateRollingMetrics(records, 2);

      expect(metrics['recordCount'], 2);
      expect(metrics['averageAttendance'], 115.0); // (110+120)/2
      expect(metrics['totalAttendance'], 230); // 110+120
    });

    test('handles insufficient data gracefully', () {
      final records = [
        _createRecord(men: 100, women: 0),
        _createRecord(men: 110, women: 0),
      ];

      final metrics = analytics.calculateRolling4WeekMetrics(records);

      expect(metrics['recordCount'], 2);
      expect(metrics['averageAttendance'], 0.0);
      expect(metrics['growthRate'], isNull);
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
  DateTime? weekDate,
}) {
  return WeeklyRecord(
    churchId: 1,
    weekStartDate: weekDate ?? DateTime(2026, 1, 1),
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
