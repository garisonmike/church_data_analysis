import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Church Model Tests', () {
    final now = DateTime.now();

    test('Church model should be created with valid data', () {
      final church = Church(
        id: 1,
        name: 'Test Church',
        address: '123 Main St',
        contactEmail: 'test@church.com',
        contactPhone: '555-1234',
        currency: 'USD',
        createdAt: now,
        updatedAt: now,
      );

      expect(church.id, 1);
      expect(church.name, 'Test Church');
      expect(church.address, '123 Main St');
      expect(church.contactEmail, 'test@church.com');
      expect(church.contactPhone, '555-1234');
      expect(church.currency, 'USD');
    });

    test('Church model should validate successfully with valid data', () {
      final church = Church(
        name: 'Valid Church',
        contactEmail: 'valid@church.com',
        createdAt: now,
        updatedAt: now,
      );

      expect(church.isValid(), true);
      expect(church.validate(), null);
    });

    test('Church model should fail validation with empty name', () {
      final church = Church(name: '', createdAt: now, updatedAt: now);

      expect(church.isValid(), false);
      expect(church.validate(), 'Church name cannot be empty');
    });

    test('Church model should fail validation with invalid email', () {
      final church = Church(
        name: 'Test Church',
        contactEmail: 'invalid-email',
        createdAt: now,
        updatedAt: now,
      );

      expect(church.isValid(), false);
      expect(church.validate(), 'Invalid email format');
    });

    test('Church model should convert to and from JSON', () {
      final church = Church(
        id: 1,
        name: 'Test Church',
        address: '123 Main St',
        contactEmail: 'test@church.com',
        currency: 'USD',
        createdAt: now,
        updatedAt: now,
      );

      final json = church.toJson();
      final churchFromJson = Church.fromJson(json);

      expect(churchFromJson.id, church.id);
      expect(churchFromJson.name, church.name);
      expect(churchFromJson.address, church.address);
      expect(churchFromJson.contactEmail, church.contactEmail);
      expect(churchFromJson.currency, church.currency);
    });

    test('Church model copyWith should update only specified fields', () {
      final church = Church(
        id: 1,
        name: 'Test Church',
        createdAt: now,
        updatedAt: now,
      );

      final updated = church.copyWith(name: 'Updated Church');

      expect(updated.id, church.id);
      expect(updated.name, 'Updated Church');
      expect(updated.createdAt, church.createdAt);
    });

    test('Church model equality should work correctly', () {
      final church1 = Church(
        id: 1,
        name: 'Test Church',
        createdAt: now,
        updatedAt: now,
      );

      final church2 = Church(
        id: 1,
        name: 'Test Church',
        createdAt: now,
        updatedAt: now,
      );

      expect(church1, equals(church2));
    });
  });
}
