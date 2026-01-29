import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminUser Model Tests', () {
    final now = DateTime.now();

    test('AdminUser model should be created with valid data', () {
      final admin = AdminUser(
        id: 1,
        username: 'admin1',
        fullName: 'Admin User',
        email: 'admin@example.com',
        churchId: 1,
        isActive: true,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin.id, 1);
      expect(admin.username, 'admin1');
      expect(admin.fullName, 'Admin User');
      expect(admin.email, 'admin@example.com');
      expect(admin.churchId, 1);
      expect(admin.isActive, true);
    });

    test('AdminUser should validate successfully with valid data', () {
      final admin = AdminUser(
        username: 'admin1',
        fullName: 'Admin User',
        email: 'admin@example.com',
        churchId: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin.isValid(), true);
      expect(admin.validate(), null);
    });

    test('AdminUser should fail validation with empty username', () {
      final admin = AdminUser(
        username: '',
        fullName: 'Admin User',
        churchId: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin.isValid(), false);
      expect(admin.validate(), 'Username cannot be empty');
    });

    test('AdminUser should fail validation with short username', () {
      final admin = AdminUser(
        username: 'ab',
        fullName: 'Admin User',
        churchId: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin.isValid(), false);
      expect(admin.validate(), 'Username must be at least 3 characters');
    });

    test('AdminUser should fail validation with empty fullName', () {
      final admin = AdminUser(
        username: 'admin1',
        fullName: '',
        churchId: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin.isValid(), false);
      expect(admin.validate(), 'Full name cannot be empty');
    });

    test('AdminUser should fail validation with invalid email', () {
      final admin = AdminUser(
        username: 'admin1',
        fullName: 'Admin User',
        email: 'invalid-email',
        churchId: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin.isValid(), false);
      expect(admin.validate(), 'Invalid email format');
    });

    test('AdminUser should fail validation with invalid church ID', () {
      final admin = AdminUser(
        username: 'admin1',
        fullName: 'Admin User',
        churchId: 0,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin.isValid(), false);
      expect(admin.validate(), 'Invalid church ID');
    });

    test('AdminUser should convert to and from JSON', () {
      final admin = AdminUser(
        id: 1,
        username: 'admin1',
        fullName: 'Admin User',
        email: 'admin@example.com',
        churchId: 1,
        isActive: true,
        createdAt: now,
        lastLoginAt: now,
      );

      final json = admin.toJson();
      final fromJson = AdminUser.fromJson(json);

      expect(fromJson.id, admin.id);
      expect(fromJson.username, admin.username);
      expect(fromJson.fullName, admin.fullName);
      expect(fromJson.email, admin.email);
      expect(fromJson.churchId, admin.churchId);
      expect(fromJson.isActive, admin.isActive);
    });

    test(
      'AdminUser copyWith should create a new instance with updated fields',
      () {
        final admin = AdminUser(
          id: 1,
          username: 'admin1',
          fullName: 'Admin User',
          churchId: 1,
          createdAt: now,
          lastLoginAt: now,
        );

        final updated = admin.copyWith(
          fullName: 'Updated Name',
          isActive: false,
        );

        expect(updated.id, admin.id);
        expect(updated.username, admin.username);
        expect(updated.fullName, 'Updated Name');
        expect(updated.isActive, false);
      },
    );

    test('AdminUser should implement Equatable correctly', () {
      final admin1 = AdminUser(
        id: 1,
        username: 'admin1',
        fullName: 'Admin User',
        churchId: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      final admin2 = AdminUser(
        id: 1,
        username: 'admin1',
        fullName: 'Admin User',
        churchId: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      expect(admin1, admin2);
    });
  });
}
