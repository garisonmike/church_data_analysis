import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationService', () {
    late ValidationService service;

    setUp(() {
      service = ValidationService();
    });

    group('validateNonNegativeInt', () {
      test('returns null for positive values', () {
        expect(service.validateNonNegativeInt(0, 'Test'), isNull);
        expect(service.validateNonNegativeInt(1, 'Test'), isNull);
        expect(service.validateNonNegativeInt(100, 'Test'), isNull);
      });

      test('returns error for negative values', () {
        expect(
          service.validateNonNegativeInt(-1, 'Test'),
          'Test cannot be negative',
        );
        expect(
          service.validateNonNegativeInt(-100, 'Count'),
          'Count cannot be negative',
        );
      });
    });

    group('validateNonNegativeDouble', () {
      test('returns null for positive values', () {
        expect(service.validateNonNegativeDouble(0.0, 'Test'), isNull);
        expect(service.validateNonNegativeDouble(1.5, 'Test'), isNull);
        expect(service.validateNonNegativeDouble(100.99, 'Test'), isNull);
      });

      test('returns error for negative values', () {
        expect(
          service.validateNonNegativeDouble(-0.01, 'Test'),
          'Test cannot be negative',
        );
        expect(
          service.validateNonNegativeDouble(-100.50, 'Amount'),
          'Amount cannot be negative',
        );
      });
    });

    group('validateRequiredFields', () {
      test('returns empty list for valid record', () {
        final record = WeeklyRecord(
          churchId: 1,
          weekStartDate: DateTime.now(),
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(service.validateRequiredFields(record), isEmpty);
      });

      test('returns errors for invalid church ID', () {
        final record = WeeklyRecord(
          churchId: 0,
          weekStartDate: DateTime.now(),
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final errors = service.validateRequiredFields(record);
        expect(errors, contains('Church ID is required'));
      });

      test('returns errors for negative attendance', () {
        final record = WeeklyRecord(
          churchId: 1,
          weekStartDate: DateTime.now(),
          men: -5,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final errors = service.validateRequiredFields(record);
        expect(errors, contains('Men count cannot be negative'));
      });

      test('returns errors for negative financial values', () {
        final record = WeeklyRecord(
          churchId: 1,
          weekStartDate: DateTime.now(),
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: -100.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final errors = service.validateRequiredFields(record);
        expect(errors, contains('Tithe cannot be negative'));
      });
    });

    group('checkForAttendanceOutlier', () {
      List<WeeklyRecord> createHistoricalRecords(List<int> attendances) {
        return attendances
            .map(
              (a) => WeeklyRecord(
                churchId: 1,
                weekStartDate: DateTime.now(),
                men: a ~/ 5,
                women: a ~/ 5,
                youth: a ~/ 5,
                children: a ~/ 5,
                sundayHomeChurch: a ~/ 5,
                tithe: 1000.0,
                offerings: 500.0,
                emergencyCollection: 200.0,
                plannedCollection: 100.0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList();
      }

      test('returns null when insufficient historical data', () {
        final records = createHistoricalRecords([100, 110, 105]);
        expect(service.checkForAttendanceOutlier(200, records), isNull);
      });

      test('returns null for normal values', () {
        final records = createHistoricalRecords([100, 110, 105, 115, 108, 112]);
        expect(service.checkForAttendanceOutlier(110, records), isNull);
      });

      test('returns warning for unusually high value', () {
        final records = createHistoricalRecords([100, 110, 105, 115, 108, 112]);
        final warning = service.checkForAttendanceOutlier(500, records);

        expect(warning, isNotNull);
        expect(warning!.type, OutlierType.high);
        expect(warning.message, contains('unusually high'));
      });

      test('returns warning for unusually low value', () {
        final records = createHistoricalRecords([100, 110, 105, 115, 108, 112]);
        final warning = service.checkForAttendanceOutlier(10, records);

        expect(warning, isNotNull);
        expect(warning!.type, OutlierType.low);
        expect(warning.message, contains('unusually low'));
      });
    });

    group('checkForIncomeOutlier', () {
      List<WeeklyRecord> createIncomeRecords(List<double> incomes) {
        return incomes
            .map(
              (i) => WeeklyRecord(
                churchId: 1,
                weekStartDate: DateTime.now(),
                men: 50,
                women: 60,
                youth: 30,
                children: 20,
                sundayHomeChurch: 10,
                tithe: i * 0.5,
                offerings: i * 0.3,
                emergencyCollection: i * 0.1,
                plannedCollection: i * 0.1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList();
      }

      test('returns null when insufficient historical data', () {
        final records = createIncomeRecords([1000, 1100, 1050]);
        expect(service.checkForIncomeOutlier(2000, records), isNull);
      });

      test('returns null for normal values', () {
        final records = createIncomeRecords([
          1000,
          1100,
          1050,
          1150,
          1080,
          1120,
        ]);
        expect(service.checkForIncomeOutlier(1100, records), isNull);
      });

      test('returns warning for unusually high value', () {
        final records = createIncomeRecords([
          1000,
          1100,
          1050,
          1150,
          1080,
          1120,
        ]);
        final warning = service.checkForIncomeOutlier(5000, records);

        expect(warning, isNotNull);
        expect(warning!.type, OutlierType.high);
        expect(warning.message, contains('unusually high'));
      });

      test('returns warning for unusually low value', () {
        final records = createIncomeRecords([
          1000,
          1100,
          1050,
          1150,
          1080,
          1120,
        ]);
        final warning = service.checkForIncomeOutlier(100, records);

        expect(warning, isNotNull);
        expect(warning!.type, OutlierType.low);
        expect(warning.message, contains('unusually low'));
      });
    });

    group('validateCsvSchema', () {
      test('returns valid for complete mapping', () {
        final headers = [
          'Date',
          'Men',
          'Women',
          'Youth',
          'Children',
          'SHC',
          'Tithe',
          'Offerings',
          'Emergency',
          'Planned',
        ];
        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
        };

        final result = service.validateCsvSchema(headers, mapping);

        expect(result.isValid, true);
        expect(result.missingFields, isEmpty);
        expect(result.errorMessage, isNull);
      });

      test('returns invalid for missing required columns', () {
        final headers = ['Date', 'Men', 'Women'];
        final mapping = {'weekStartDate': 0, 'men': 1, 'women': 2};

        final result = service.validateCsvSchema(headers, mapping);

        expect(result.isValid, false);
        expect(result.missingFields, isNotEmpty);
        expect(result.missingFields, contains('youth'));
        expect(result.missingFields, contains('tithe'));
        expect(result.errorMessage, contains('Missing required columns'));
      });

      test('returns invalid for duplicate column indices', () {
        final headers = ['Date', 'Value'];
        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 1, // Same index as men
          'youth': 2,
          'children': 3,
          'sundayHomeChurch': 4,
          'tithe': 5,
          'offerings': 6,
          'emergencyCollection': 7,
          'plannedCollection': 8,
        };

        final result = service.validateCsvSchema(headers, mapping);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('same column'));
      });
    });

    group('Validation messages display correctly', () {
      test('error messages are user-friendly', () {
        final record = WeeklyRecord(
          churchId: 0,
          weekStartDate: DateTime.now(),
          men: -5,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: -100.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final errors = service.validateRequiredFields(record);

        // Verify messages are clear and descriptive
        for (final error in errors) {
          expect(error, isNotEmpty);
          expect(error.length, greaterThan(10)); // Not too short
          expect(
            error,
            isNot(contains('null')),
          ); // No technical null references
        }
      });

      test('outlier warnings include expected range', () {
        final records = List.generate(
          10,
          (i) => WeeklyRecord(
            churchId: 1,
            weekStartDate: DateTime.now(),
            men: 20,
            women: 20,
            youth: 20,
            children: 20,
            sundayHomeChurch: 20, // Total: 100
            tithe: 1000.0,
            offerings: 500.0,
            emergencyCollection: 200.0,
            plannedCollection: 100.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final warning = service.checkForAttendanceOutlier(500, records);

        expect(warning, isNotNull);
        expect(warning!.expectedRange, isNotEmpty);
        expect(warning.expectedRange, contains('-')); // Range format
      });
    });
  });
}
