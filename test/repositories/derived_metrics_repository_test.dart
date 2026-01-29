import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DerivedMetricsRepository', () {
    late AppDatabase database;
    late DerivedMetricsRepository repository;
    late ChurchRepository churchRepository;
    late int testChurchId;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = DerivedMetricsRepository(database);
      churchRepository = ChurchRepository(database);

      // Create a test church
      final church = Church(
        name: 'Test Church',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      testChurchId = await churchRepository.createChurch(church);
    });

    tearDown(() async {
      await database.close();
    });

    DerivedMetrics createTestMetrics({
      int? churchId,
      DateTime? periodStart,
      DateTime? periodEnd,
      DateTime? calculatedAt,
    }) {
      final now = DateTime.now();
      return DerivedMetrics(
        churchId: churchId ?? testChurchId,
        periodStart: periodStart ?? now.subtract(const Duration(days: 84)),
        periodEnd: periodEnd ?? now,
        averageAttendance: 150.5,
        averageIncome: 5000.0,
        growthPercentage: 5.2,
        attendanceToIncomeRatio: 33.22,
        perCapitaGiving: 33.22,
        menPercentage: 30.0,
        womenPercentage: 35.0,
        youthPercentage: 20.0,
        childrenPercentage: 15.0,
        tithePercentage: 60.0,
        offeringsPercentage: 40.0,
        calculatedAt: calculatedAt ?? now,
      );
    }

    group('saveCachedMetrics', () {
      test('should save new cached metrics and return ID', () async {
        final metrics = createTestMetrics();

        final id = await repository.saveCachedMetrics(metrics);

        expect(id, greaterThan(0));
      });

      test(
        'should update existing cached metrics for same church and period',
        () async {
          final metrics = createTestMetrics();
          final id1 = await repository.saveCachedMetrics(metrics);

          // Save again with updated values
          final updatedMetrics = metrics.copyWith(
            averageAttendance: 200.0,
            averageIncome: 7500.0,
          );
          final id2 = await repository.saveCachedMetrics(updatedMetrics);

          // Should return the same ID (update, not insert)
          expect(id2, equals(id1));

          // Verify values were updated
          final retrieved = await repository.getCachedMetrics(
            testChurchId,
            metrics.periodStart,
            metrics.periodEnd,
          );
          expect(retrieved?.averageAttendance, equals(200.0));
          expect(retrieved?.averageIncome, equals(7500.0));
        },
      );
    });

    group('getCachedMetrics', () {
      test('should return cached metrics for church and period', () async {
        final metrics = createTestMetrics();
        await repository.saveCachedMetrics(metrics);

        final retrieved = await repository.getCachedMetrics(
          testChurchId,
          metrics.periodStart,
          metrics.periodEnd,
        );

        expect(retrieved, isNotNull);
        expect(retrieved!.churchId, equals(testChurchId));
        expect(retrieved.averageAttendance, equals(150.5));
        expect(retrieved.averageIncome, equals(5000.0));
        expect(retrieved.growthPercentage, equals(5.2));
      });

      test('should return null when no cached metrics exist', () async {
        final retrieved = await repository.getCachedMetrics(
          testChurchId,
          DateTime(2020, 1, 1),
          DateTime(2020, 3, 31),
        );

        expect(retrieved, isNull);
      });
    });

    group('getAllCachedMetricsByChurch', () {
      test('should return all cached metrics for a church', () async {
        final now = DateTime.now();
        final metrics1 = createTestMetrics(
          periodStart: now.subtract(const Duration(days: 84)),
          periodEnd: now.subtract(const Duration(days: 1)),
        );
        final metrics2 = createTestMetrics(
          periodStart: now.subtract(const Duration(days: 168)),
          periodEnd: now.subtract(const Duration(days: 85)),
        );

        await repository.saveCachedMetrics(metrics1);
        await repository.saveCachedMetrics(metrics2);

        final allMetrics = await repository.getAllCachedMetricsByChurch(
          testChurchId,
        );

        expect(allMetrics.length, equals(2));
      });

      test('should return empty list when no metrics exist', () async {
        final allMetrics = await repository.getAllCachedMetricsByChurch(
          testChurchId,
        );

        expect(allMetrics, isEmpty);
      });
    });

    group('getMostRecentCachedMetrics', () {
      test('should return most recently calculated metrics', () async {
        final now = DateTime.now();
        final olderMetrics = createTestMetrics(
          calculatedAt: now.subtract(const Duration(hours: 2)),
        );
        final newerMetrics = createTestMetrics(
          periodStart: now.subtract(const Duration(days: 30)),
          periodEnd: now.subtract(const Duration(days: 1)),
          calculatedAt: now,
        );

        await repository.saveCachedMetrics(olderMetrics);
        await repository.saveCachedMetrics(newerMetrics);

        final mostRecent = await repository.getMostRecentCachedMetrics(
          testChurchId,
        );

        expect(mostRecent, isNotNull);
        // Compare dates without millisecond precision (SQLite truncates milliseconds)
        expect(
          mostRecent!.periodEnd
              .difference(newerMetrics.periodEnd)
              .inSeconds
              .abs(),
          lessThan(2),
        );
      });

      test('should return null when no metrics exist', () async {
        final mostRecent = await repository.getMostRecentCachedMetrics(
          testChurchId,
        );

        expect(mostRecent, isNull);
      });
    });

    group('isCacheValid', () {
      test('should return false for null metrics', () {
        final isValid = repository.isCacheValid(null);

        expect(isValid, isFalse);
      });

      test('should return true for recently calculated metrics', () {
        final metrics = createTestMetrics(
          calculatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        final isValid = repository.isCacheValid(metrics);

        expect(isValid, isTrue);
      });

      test('should return false for expired metrics', () {
        final metrics = createTestMetrics(
          calculatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        final isValid = repository.isCacheValid(metrics);

        expect(isValid, isFalse);
      });

      test('should respect custom cache validity duration', () {
        final metrics = createTestMetrics(
          calculatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        // With default 1 hour validity, should be invalid
        expect(repository.isCacheValid(metrics), isFalse);

        // With 3 hour validity, should be valid
        expect(
          repository.isCacheValid(
            metrics,
            cacheValidity: const Duration(hours: 3),
          ),
          isTrue,
        );
      });
    });

    group('getValidCachedMetrics', () {
      test('should return cached metrics when valid', () async {
        final metrics = createTestMetrics(calculatedAt: DateTime.now());
        await repository.saveCachedMetrics(metrics);

        final cached = await repository.getValidCachedMetrics(
          testChurchId,
          metrics.periodStart,
          metrics.periodEnd,
        );

        expect(cached, isNotNull);
      });

      test('should return null when cache is expired', () async {
        final metrics = createTestMetrics(
          calculatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );
        await repository.saveCachedMetrics(metrics);

        final cached = await repository.getValidCachedMetrics(
          testChurchId,
          metrics.periodStart,
          metrics.periodEnd,
        );

        expect(cached, isNull);
      });
    });

    group('invalidateCache', () {
      test('should delete all cached metrics for a church', () async {
        final metrics1 = createTestMetrics();
        final metrics2 = createTestMetrics(
          periodStart: DateTime(2020, 1, 1),
          periodEnd: DateTime(2020, 3, 31),
        );

        await repository.saveCachedMetrics(metrics1);
        await repository.saveCachedMetrics(metrics2);

        final deletedCount = await repository.invalidateCache(testChurchId);

        expect(deletedCount, equals(2));

        final allMetrics = await repository.getAllCachedMetricsByChurch(
          testChurchId,
        );
        expect(allMetrics, isEmpty);
      });
    });

    group('invalidateCacheForPeriod', () {
      test('should delete cached metrics for specific period only', () async {
        final now = DateTime.now();
        final metrics1 = createTestMetrics(
          periodStart: now.subtract(const Duration(days: 84)),
          periodEnd: now,
        );
        final metrics2 = createTestMetrics(
          periodStart: DateTime(2020, 1, 1),
          periodEnd: DateTime(2020, 3, 31),
        );

        await repository.saveCachedMetrics(metrics1);
        await repository.saveCachedMetrics(metrics2);

        final deletedCount = await repository.invalidateCacheForPeriod(
          testChurchId,
          metrics1.periodStart,
          metrics1.periodEnd,
        );

        expect(deletedCount, equals(1));

        final allMetrics = await repository.getAllCachedMetricsByChurch(
          testChurchId,
        );
        expect(allMetrics.length, equals(1));
        expect(allMetrics.first.periodStart, equals(metrics2.periodStart));
      });
    });

    group('cleanupOldCache', () {
      test('should delete cached metrics older than max age', () async {
        final now = DateTime.now();
        final recentMetrics = createTestMetrics(
          calculatedAt: now.subtract(const Duration(days: 1)),
        );
        final oldMetrics = createTestMetrics(
          periodStart: DateTime(2020, 1, 1),
          periodEnd: DateTime(2020, 3, 31),
          calculatedAt: now.subtract(const Duration(days: 10)),
        );

        await repository.saveCachedMetrics(recentMetrics);
        await repository.saveCachedMetrics(oldMetrics);

        final deletedCount = await repository.cleanupOldCache(
          maxAge: const Duration(days: 7),
        );

        expect(deletedCount, equals(1));

        final allMetrics = await repository.getAllCachedMetricsByChurch(
          testChurchId,
        );
        expect(allMetrics.length, equals(1));
      });
    });

    group('deleteCachedMetrics', () {
      test('should delete cached metrics by ID', () async {
        final metrics = createTestMetrics();
        final id = await repository.saveCachedMetrics(metrics);

        final deletedCount = await repository.deleteCachedMetrics(id);

        expect(deletedCount, equals(1));

        final retrieved = await repository.getCachedMetrics(
          testChurchId,
          metrics.periodStart,
          metrics.periodEnd,
        );
        expect(retrieved, isNull);
      });
    });
  });
}
