import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DerivedMetrics Model Tests', () {
    final now = DateTime.now();

    DerivedMetrics createValidMetrics({
      int? id,
      int churchId = 1,
      DateTime? periodStart,
      DateTime? periodEnd,
      double averageAttendance = 150.0,
      double averageIncome = 2500.0,
      double growthPercentage = 5.5,
      double attendanceToIncomeRatio = 16.67,
      double perCapitaGiving = 16.67,
      double menPercentage = 30.0,
      double womenPercentage = 35.0,
      double youthPercentage = 20.0,
      double childrenPercentage = 15.0,
      double tithePercentage = 50.0,
      double offeringsPercentage = 25.0,
    }) {
      return DerivedMetrics(
        id: id,
        churchId: churchId,
        periodStart: periodStart ?? DateTime(2026, 1, 1),
        periodEnd: periodEnd ?? DateTime(2026, 1, 31),
        averageAttendance: averageAttendance,
        averageIncome: averageIncome,
        growthPercentage: growthPercentage,
        attendanceToIncomeRatio: attendanceToIncomeRatio,
        perCapitaGiving: perCapitaGiving,
        menPercentage: menPercentage,
        womenPercentage: womenPercentage,
        youthPercentage: youthPercentage,
        childrenPercentage: childrenPercentage,
        tithePercentage: tithePercentage,
        offeringsPercentage: offeringsPercentage,
        calculatedAt: now,
      );
    }

    test('DerivedMetrics model should be created with valid data', () {
      final metrics = createValidMetrics(id: 1);

      expect(metrics.id, 1);
      expect(metrics.churchId, 1);
      expect(metrics.averageAttendance, 150.0);
      expect(metrics.averageIncome, 2500.0);
      expect(metrics.growthPercentage, 5.5);
      expect(metrics.menPercentage, 30.0);
    });

    test('DerivedMetrics should validate successfully with valid data', () {
      final metrics = createValidMetrics();

      expect(metrics.isValid(), true);
      expect(metrics.validate(), null);
    });

    test('DerivedMetrics should fail validation with invalid church ID', () {
      final metrics = createValidMetrics(churchId: 0);

      expect(metrics.isValid(), false);
      expect(metrics.validate(), 'Invalid church ID');
    });

    test(
      'DerivedMetrics should fail validation when periodEnd before periodStart',
      () {
        final metrics = DerivedMetrics(
          churchId: 1,
          periodStart: DateTime(2026, 2, 1),
          periodEnd: DateTime(2026, 1, 1), // Before periodStart
          averageAttendance: 150.0,
          averageIncome: 2500.0,
          growthPercentage: 5.5,
          attendanceToIncomeRatio: 16.67,
          perCapitaGiving: 16.67,
          menPercentage: 30.0,
          womenPercentage: 35.0,
          youthPercentage: 20.0,
          childrenPercentage: 15.0,
          tithePercentage: 50.0,
          offeringsPercentage: 25.0,
          calculatedAt: now,
        );

        expect(metrics.isValid(), false);
        expect(metrics.validate(), 'Period end must be after period start');
      },
    );

    test('DerivedMetrics should fail validation with negative attendance', () {
      final metrics = createValidMetrics(averageAttendance: -10.0);

      expect(metrics.isValid(), false);
      expect(metrics.validate(), 'Average attendance cannot be negative');
    });

    test('DerivedMetrics should fail validation with negative income', () {
      final metrics = createValidMetrics(averageIncome: -100.0);

      expect(metrics.isValid(), false);
      expect(metrics.validate(), 'Average income cannot be negative');
    });

    test('DerivedMetrics should convert to and from JSON', () {
      final metrics = createValidMetrics(id: 1);

      final json = metrics.toJson();
      final fromJson = DerivedMetrics.fromJson(json);

      expect(fromJson.id, metrics.id);
      expect(fromJson.churchId, metrics.churchId);
      expect(fromJson.averageAttendance, metrics.averageAttendance);
      expect(fromJson.averageIncome, metrics.averageIncome);
      expect(fromJson.growthPercentage, metrics.growthPercentage);
      expect(fromJson.menPercentage, metrics.menPercentage);
      expect(fromJson.tithePercentage, metrics.tithePercentage);
    });

    test(
      'DerivedMetrics copyWith should create a new instance with updated fields',
      () {
        final metrics = createValidMetrics(id: 1);
        final updated = metrics.copyWith(
          averageAttendance: 200.0,
          growthPercentage: 10.0,
        );

        expect(updated.id, metrics.id);
        expect(updated.churchId, metrics.churchId);
        expect(updated.averageAttendance, 200.0);
        expect(updated.growthPercentage, 10.0);
        expect(updated.averageIncome, metrics.averageIncome);
      },
    );

    test('DerivedMetrics should implement Equatable correctly', () {
      final metrics1 = createValidMetrics(id: 1);
      final metrics2 = createValidMetrics(id: 1);

      expect(metrics1, metrics2);
    });
  });
}
