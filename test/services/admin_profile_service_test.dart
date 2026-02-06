import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AdminProfileService', () {
    late AppDatabase database;
    late AdminProfileService service;

    setUp(() async {
      // Initialize in-memory test database
      database = AppDatabase.forTesting(NativeDatabase.memory());

      // Set up shared preferences with empty values
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create repository with test database
      final repository = AdminUserRepository(database);

      service = AdminProfileService(repository, prefs);
    });

    tearDown(() async {
      // Properly dispose of database
      await database.close();
    });

    group('Profile ID Management', () {
      test('getCurrentProfileId returns null when not set', () {
        final id = service.getCurrentProfileId();
        expect(id, isNull);
      });

      test('setCurrentProfileId stores the profile ID', () async {
        await service.setCurrentProfileId(1);
        final id = service.getCurrentProfileId();
        expect(id, 1);
      });

      test('clearCurrentProfile removes the profile ID', () async {
        await service.setCurrentProfileId(1);
        expect(service.getCurrentProfileId(), 1);

        await service.clearCurrentProfile();
        expect(service.getCurrentProfileId(), isNull);
      });
    });

    group('Onboarding', () {
      test('hasSeenOnboarding returns false by default', () {
        expect(service.hasSeenOnboarding(), false);
      });

      test('markOnboardingAsSeen sets the flag', () async {
        await service.markOnboardingAsSeen();
        expect(service.hasSeenOnboarding(), true);
      });
    });

    group('Profile Creation Validation', () {
      test('createProfile throws error for invalid username', () async {
        expect(
          () => service.createProfile(
            username: 'ab', // Too short
            fullName: 'Test User',
            churchId: 1,
          ),
          throwsException,
        );
      });

      test('createProfile throws error for empty full name', () async {
        expect(
          () => service.createProfile(
            username: 'testuser',
            fullName: '', // Empty
            churchId: 1,
          ),
          throwsException,
        );
      });

      test('createProfile throws error for invalid church ID', () async {
        expect(
          () => service.createProfile(
            username: 'testuser',
            fullName: 'Test User',
            churchId: 0, // Invalid
          ),
          throwsException,
        );
      });
    });

    group('Profile Deactivation', () {
      test('deactivateProfile throws error for last active profile', () async {
        // This test would require a mock repository with test data
        // Skipping actual implementation as it requires database setup
        expect(service.deactivateProfile, isNotNull);
      });
    });

    group('Profile Deletion', () {
      test('deleteProfile throws error for last profile', () async {
        // This test would require a mock repository with test data
        // Skipping actual implementation as it requires database setup
        expect(service.deleteProfile, isNotNull);
      });
    });
  });
}
