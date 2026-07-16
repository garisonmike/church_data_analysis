import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late db.AppDatabase database;
  late ChurchRepository churchRepo;
  late WeeklyRecordRepository weeklyRecordRepo;

  setUp(() {
    // Create an in-memory database for testing
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    churchRepo = ChurchRepository(database);
    weeklyRecordRepo = WeeklyRecordRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Persistence Tests', () {
    test('Church CRUD operations work correctly', () async {
      // Create
      final church = Church(
        name: 'Test Church',
        address: '123 Test St',
        contactEmail: 'test@church.org',
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final churchId = await churchRepo.createChurch(church);
      expect(churchId, greaterThan(0));

      // Read
      final retrieved = await churchRepo.getChurchById(churchId);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Church');
      expect(retrieved.address, '123 Test St');

      // Update
      final updated = retrieved.copyWith(name: 'Updated Church');
      final updateSuccess = await churchRepo.updateChurch(updated);
      expect(updateSuccess, true);

      final afterUpdate = await churchRepo.getChurchById(churchId);
      expect(afterUpdate!.name, 'Updated Church');

      // Delete
      final deleteCount = await churchRepo.deleteChurch(churchId);
      expect(deleteCount, 1);

      final afterDelete = await churchRepo.getChurchById(churchId);
      expect(afterDelete, isNull);
    });

    test('deleteChurchCascade removes dependents and spares other churches',
        () async {
      final adminRepo = AdminUserRepository(database);
      final now = DateTime.now();

      // Church to delete, with an admin and a weekly record that references it.
      final targetId = await churchRepo.createChurch(
        Church(name: 'Doomed', createdAt: now, updatedAt: now),
      );
      final adminId = await adminRepo.createUser(
        AdminUser(
          username: 'doomed_admin',
          fullName: 'Doomed Admin',
          churchId: targetId,
          isActive: true,
          createdAt: now,
          lastLoginAt: now,
        ),
      );
      await weeklyRecordRepo.createRecord(
        WeeklyRecord(
          churchId: targetId,
          createdByAdminId: adminId,
          weekStartDate: DateTime(2026, 1, 4),
          men: 10,
          women: 12,
          youth: 8,
          children: 5,
          sundayHomeChurch: 3,
          tithe: 1000,
          offerings: 500,
          emergencyCollection: 0,
          plannedCollection: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // A second church whose data must survive the cascade.
      final survivorId = await churchRepo.createChurch(
        Church(name: 'Survivor', createdAt: now, updatedAt: now),
      );
      await adminRepo.createUser(
        AdminUser(
          username: 'survivor_admin',
          fullName: 'Survivor Admin',
          churchId: survivorId,
          isActive: true,
          createdAt: now,
          lastLoginAt: now,
        ),
      );

      // A bare delete must fail while dependents exist (FK constraint on).
      expect(
        () => churchRepo.deleteChurch(targetId),
        throwsA(anything),
      );

      await churchRepo.deleteChurchCascade(targetId);

      expect(await churchRepo.getChurchById(targetId), isNull);
      expect(await weeklyRecordRepo.getRecordsByChurch(targetId), isEmpty);
      expect(await adminRepo.getUsersByChurch(targetId), isEmpty);

      // The survivor and its admin are untouched.
      expect(await churchRepo.getChurchById(survivorId), isNotNull);
      expect((await adminRepo.getUsersByChurch(survivorId)).length, 1);
    });

    test('WeeklyRecord CRUD operations work correctly', () async {
      // First create a church
      final church = Church(
        name: 'Test Church',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final churchId = await churchRepo.createChurch(church);

      // Create weekly record
      final record = WeeklyRecord(
        churchId: churchId,
        weekStartDate: DateTime(2026, 1, 1),
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedRecord = await weeklyRecordRepo.createRecord(record);
      final recordId = savedRecord.id!;
      expect(recordId, greaterThan(0));

      // Read
      final retrieved = await weeklyRecordRepo.getRecordById(recordId);
      expect(retrieved, isNotNull);
      expect(retrieved!.men, 50);
      expect(retrieved.women, 60);
      expect(retrieved.totalAttendance, 170); // 50+60+30+20+10
      expect(retrieved.totalIncome, 2000.0); // 1000+500+200+300

      // Update
      final updated = retrieved.copyWith(men: 100);
      await weeklyRecordRepo.updateRecord(updated);

      final afterUpdate = await weeklyRecordRepo.getRecordById(recordId);
      expect(afterUpdate!.men, 100);

      // Delete
      await weeklyRecordRepo.deleteRecord(recordId);
    });

    test('Duplicate week prevention works', () async {
      // Create a church
      final church = Church(
        name: 'Test Church',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final churchId = await churchRepo.createChurch(church);

      final weekStart = DateTime(2026, 1, 1);

      // Create first record
      final record1 = WeeklyRecord(
        churchId: churchId,
        weekStartDate: weekStart,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await weeklyRecordRepo.createRecord(record1);

      // Check that week exists
      final exists = await weeklyRecordRepo.weekExists(churchId, weekStart);
      expect(exists, true);

      // Try to create duplicate - should fail
      final record2 = record1.copyWith(men: 100);
      expect(
        () => weeklyRecordRepo.createRecord(record2),
        throwsException,
      );
    });

    test('Query by date range works', () async {
      // Create a church
      final church = Church(
        name: 'Test Church',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final churchId = await churchRepo.createChurch(church);

      // Create multiple weekly records
      for (int i = 0; i < 5; i++) {
        final record = WeeklyRecord(
          churchId: churchId,
          weekStartDate: DateTime(2026, 1, 1 + (i * 7)),
          men: 50 + i,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 300.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await weeklyRecordRepo.createRecord(record);
      }

      // Query for records in January 2026
      final records = await weeklyRecordRepo.getRecordsByDateRange(
        churchId,
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 31),
      );

      expect(records.length, 5);
      expect(records[0].men, 50); // First record
      expect(records[4].men, 54); // Last record
    });

    test('Database indexes improve query performance', () async {
      // Create a church
      final church = Church(
        name: 'Test Church',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final churchId = await churchRepo.createChurch(church);

      // Create many records
      for (int i = 0; i < 100; i++) {
        final record = WeeklyRecord(
          churchId: churchId,
          weekStartDate: DateTime(2026, 1, 1).add(Duration(days: i * 7)),
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 200.0,
          plannedCollection: 300.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await weeklyRecordRepo.createRecord(record);
      }

      // Query should be fast due to index on (churchId, weekStartDate)
      final stopwatch = Stopwatch()..start();
      final records = await weeklyRecordRepo.getRecordsByChurch(churchId);
      stopwatch.stop();

      expect(records.length, 100);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
    });
  });
}
