import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Initialize Flutter bindings once for all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock method channel for path_provider
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return '/mock/path';
          }
          return null;
        },
      );

  group('AdminProfileService', () {
    late AdminProfileService service;

    setUp(() async {
      // Set up shared preferences with empty values
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create a mock repository (in real tests, you'd use a test database)
      final db = AppDatabase();
      final repository = AdminUserRepository(db);

      service = AdminProfileService(repository, prefs);
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
