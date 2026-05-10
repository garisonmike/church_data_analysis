import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyRecord Model Tests', () {
    final now = DateTime.now();
    final weekStart = DateTime(2026, 1, 1);

    test('WeeklyRecord model should be created with valid data', () {
      final record = WeeklyRecord(
        id: 1,
        churchId: 1,
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
        createdAt: now,
        updatedAt: now,
      );

      expect(record.id, 1);
      expect(record.churchId, 1);
      expect(record.men, 50);
      expect(record.women, 60);
      expect(record.tithe, 1000.0);
      expect(record.offerings, 500.0);
    });

    test('WeeklyRecord should calculate total attendance correctly', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: 0,
        offerings: 0,
        emergencyCollection: 0,
        plannedCollection: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.totalAttendance, 170); // 50+60+30+20+10
    });

    test('WeeklyRecord should calculate total income correctly', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: 0,
        women: 0,
        youth: 0,
        children: 0,
        sundayHomeChurch: 0,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.totalIncome, 2000.0); // 1000+500+200+300
    });

    test('WeeklyRecord should validate successfully with valid data', () {
      final record = WeeklyRecord(
        churchId: 1,
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
        createdAt: now,
        updatedAt: now,
      );

      expect(record.isValid(), true);
      expect(record.validate(), null);
    });

    test('WeeklyRecord should fail validation with negative attendance', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: -10,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.isValid(), false);
      expect(record.validate(), 'Men count cannot be negative');
    });

    test('WeeklyRecord should fail validation with negative finance', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: -100.0,
        offerings: 500.0,
        emergencyCollection: 200.0,
        plannedCollection: 300.0,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.isValid(), false);
      expect(record.validate(), 'Tithe cannot be negative');
    });

    test('WeeklyRecord should convert to and from JSON', () {
      final record = WeeklyRecord(
        id: 1,
        churchId: 1,
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
        createdAt: now,
        updatedAt: now,
      );

      final json = record.toJson();
      final recordFromJson = WeeklyRecord.fromJson(json);

      expect(recordFromJson.id, record.id);
      expect(recordFromJson.men, record.men);
      expect(recordFromJson.women, record.women);
      expect(recordFromJson.tithe, record.tithe);
      expect(recordFromJson.totalAttendance, record.totalAttendance);
      expect(recordFromJson.totalIncome, record.totalIncome);
    });

    test('WeeklyRecord copyWith should update only specified fields', () {
      final record = WeeklyRecord(
        churchId: 1,
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
        createdAt: now,
        updatedAt: now,
      );

      final updated = record.copyWith(men: 100, tithe: 2000.0);

      expect(updated.men, 100);
      expect(updated.tithe, 2000.0);
      expect(updated.women, record.women);
      expect(updated.offerings, record.offerings);
    });

    // ── Change 1k: baptisms / holyCommunion tests ─────────────────────────

    test('WeeklyRecord accepts null baptisms and holyCommunion', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 0,
        plannedCollection: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(record.baptisms, isNull);
      expect(record.holyCommunion, isNull);
    });

    test('WeeklyRecord validate() rejects negative baptisms', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        baptisms: -1,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 0,
        plannedCollection: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(record.validate(), isNotNull);
    });

    test('WeeklyRecord validate() rejects negative holyCommunion', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        holyCommunion: -1,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 0,
        plannedCollection: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(record.validate(), isNotNull);
    });

    test('WeeklyRecord accepts non-null baptisms and holyCommunion', () {
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: weekStart,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        baptisms: 5,
        holyCommunion: 120,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 0,
        plannedCollection: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(record.baptisms, 5);
      expect(record.holyCommunion, 120);
      expect(record.validate(), isNull);
    });

    // ── Change 5a: date validation grace window tests ─────────────────────

    test('WeeklyRecord validate() allows dates up to 2 days in the future', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: tomorrow,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 0,
        plannedCollection: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(record.validate(), isNull);
    });

    test('WeeklyRecord validate() rejects dates more than 2 days in the future',
        () {
      final farFuture = DateTime.now().add(const Duration(days: 3));
      final record = WeeklyRecord(
        churchId: 1,
        weekStartDate: farFuture,
        men: 50,
        women: 60,
        youth: 30,
        children: 20,
        sundayHomeChurch: 10,
        tithe: 1000.0,
        offerings: 500.0,
        emergencyCollection: 0,
        plannedCollection: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(record.validate(), isNotNull);
    });
  });
}
