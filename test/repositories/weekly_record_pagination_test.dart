import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyRecordRepository Pagination', () {
    late AppDatabase database;
    late WeeklyRecordRepository repository;
    late ChurchRepository churchRepository;
    late int testChurchId;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = WeeklyRecordRepository(database);
      churchRepository = ChurchRepository(database);

      // Create a test church
      final church = models.Church(
        name: 'Test Church',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      testChurchId = await churchRepository.createChurch(church);

      // Create 25 test records
      for (var i = 0; i < 25; i++) {
        final record = models.WeeklyRecord(
          churchId: testChurchId,
          weekStartDate: DateTime(2025, 1, 1).add(Duration(days: i * 7)),
          men: 50 + i,
          women: 60 + i,
          youth: 30 + i,
          children: 20 + i,
          sundayHomeChurch: 10,
          tithe: 1000.0 + (i * 100),
          offerings: 500.0 + (i * 50),
          emergencyCollection: 100.0,
          plannedCollection: 200.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.createRecord(record);
      }
    });

    tearDown(() async {
      await database.close();
    });

    group('getRecordsPaginated', () {
      test('should return first page with correct page size', () async {
        final result = await repository.getRecordsPaginated(
          testChurchId,
          page: 0,
          pageSize: 10,
        );

        expect(result.records.length, equals(10));
        expect(result.totalCount, equals(25));
      });

      test('should return second page with remaining records', () async {
        final result = await repository.getRecordsPaginated(
          testChurchId,
          page: 1,
          pageSize: 10,
        );

        expect(result.records.length, equals(10));
        expect(result.totalCount, equals(25));
      });

      test('should return last page with partial results', () async {
        final result = await repository.getRecordsPaginated(
          testChurchId,
          page: 2,
          pageSize: 10,
        );

        expect(result.records.length, equals(5));
        expect(result.totalCount, equals(25));
      });

      test('should return empty page when page exceeds total', () async {
        final result = await repository.getRecordsPaginated(
          testChurchId,
          page: 10,
          pageSize: 10,
        );

        expect(result.records.length, equals(0));
        expect(result.totalCount, equals(25));
      });

      test('should use default page size of 20', () async {
        final result = await repository.getRecordsPaginated(testChurchId);

        expect(result.records.length, equals(20));
        expect(result.totalCount, equals(25));
      });

      test('should order records by date descending', () async {
        final result = await repository.getRecordsPaginated(
          testChurchId,
          page: 0,
          pageSize: 5,
        );

        // Most recent records should come first
        for (var i = 0; i < result.records.length - 1; i++) {
          expect(
            result.records[i].weekStartDate.isAfter(
              result.records[i + 1].weekStartDate,
            ),
            isTrue,
          );
        }
      });
    });

    group('getRecordsPaginatedByAdmin', () {
      late int adminId;

      setUp(() async {
        // Create an admin user
        final adminRepo = AdminUserRepository(database);
        final admin = models.AdminUser(
          username: 'testadmin',
          fullName: 'Test Admin',
          churchId: testChurchId,
          isActive: true,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        adminId = await adminRepo.createUser(admin);

        // Create some records for this admin
        for (var i = 0; i < 15; i++) {
          final record = models.WeeklyRecord(
            churchId: testChurchId,
            createdByAdminId: adminId,
            weekStartDate: DateTime(2024, 1, 1).add(Duration(days: i * 7)),
            men: 40 + i,
            women: 50 + i,
            youth: 25 + i,
            children: 15 + i,
            sundayHomeChurch: 8,
            tithe: 800.0 + (i * 80),
            offerings: 400.0 + (i * 40),
            emergencyCollection: 80.0,
            plannedCollection: 160.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await repository.createRecord(record);
        }
      });

      test('should return paginated records for specific admin', () async {
        final result = await repository.getRecordsPaginatedByAdmin(
          testChurchId,
          adminId,
          page: 0,
          pageSize: 10,
        );

        expect(result.records.length, equals(10));
        expect(result.totalCount, equals(15));

        // All records should belong to this admin
        for (final record in result.records) {
          expect(record.createdByAdminId, equals(adminId));
        }
      });

      test('should return correct count for admin-filtered records', () async {
        final result = await repository.getRecordsPaginatedByAdmin(
          testChurchId,
          adminId,
          page: 1,
          pageSize: 10,
        );

        expect(result.records.length, equals(5));
        expect(result.totalCount, equals(15));
      });
    });
  });
}
