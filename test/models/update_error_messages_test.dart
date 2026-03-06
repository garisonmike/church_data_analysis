import 'package:church_analytics/models/update_error_messages.dart';
import 'package:church_analytics/models/update_error_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // UpdateErrorMessages.messageFor
  // -------------------------------------------------------------------------

  group('UpdateErrorMessages.messageFor', () {
    test('each UpdateErrorType has a non-empty message', () {
      for (final type in UpdateErrorType.values) {
        final message = UpdateErrorMessages.messageFor(type);
        expect(
          message,
          isNotEmpty,
          reason: 'messageFor($type) must not be empty',
        );
      }
    });

    test('all messages are distinct', () {
      final messages = UpdateErrorType.values
          .map(UpdateErrorMessages.messageFor)
          .toList();
      final unique = messages.toSet();
      expect(
        unique.length,
        equals(messages.length),
        reason: 'every UpdateErrorType must have a unique message',
      );
    });

    test('networkError message mentions connection', () {
      final msg = UpdateErrorMessages.messageFor(UpdateErrorType.networkError);
      expect(msg.toLowerCase(), contains('internet connection'));
    });

    test('securityError message mentions HTTPS and not internet connection', () {
      final msg = UpdateErrorMessages.messageFor(UpdateErrorType.securityError);
      expect(msg.toLowerCase(), contains('https'));
      // Must NOT tell the user to check their internet connection.
      // securityError is a configuration/tamper issue, not a connectivity issue.
      expect(msg.toLowerCase(), isNot(contains('internet connection')));
    });

    test('parseError message mentions corrupt or unrecognised format', () {
      final msg = UpdateErrorMessages.messageFor(UpdateErrorType.parseError);
      expect(
        msg.toLowerCase(),
        anyOf(
          contains('corrupt'),
          contains('unrecognised'),
          contains('format'),
        ),
      );
    });

    test('downloadError message mentions download', () {
      final msg = UpdateErrorMessages.messageFor(UpdateErrorType.downloadError);
      expect(msg.toLowerCase(), contains('download'));
    });

    test('checksumMismatch message contains security warning', () {
      final msg = UpdateErrorMessages.messageFor(
        UpdateErrorType.checksumMismatch,
      );
      expect(msg.toLowerCase(), contains('security warning'));
    });

    test('checksumMismatch message specifically warns against installing', () {
      final msg = UpdateErrorMessages.messageFor(
        UpdateErrorType.checksumMismatch,
      );
      expect(msg.toLowerCase(), contains('do not install'));
    });

    test('installError message mentions installer', () {
      final msg = UpdateErrorMessages.messageFor(UpdateErrorType.installError);
      expect(msg.toLowerCase(), contains('installer'));
    });

    test('unsupportedPlatform message mentions platform', () {
      final msg = UpdateErrorMessages.messageFor(
        UpdateErrorType.unsupportedPlatform,
      );
      expect(msg.toLowerCase(), contains('platform'));
    });
  });

  // -------------------------------------------------------------------------
  // UpdateErrorMessages.actionFor
  // -------------------------------------------------------------------------

  group('UpdateErrorMessages.actionFor', () {
    test('each UpdateErrorType has a non-empty action', () {
      for (final type in UpdateErrorType.values) {
        final action = UpdateErrorMessages.actionFor(type);
        expect(
          action,
          isNotEmpty,
          reason: 'actionFor($type) must not be empty',
        );
      }
    });

    test('all actions are distinct', () {
      final actions = UpdateErrorType.values
          .map(UpdateErrorMessages.actionFor)
          .toList();
      final unique = actions.toSet();
      expect(
        unique.length,
        equals(actions.length),
        reason: 'every UpdateErrorType must have a unique action',
      );
    });

    test('networkError action mentions retry', () {
      final action = UpdateErrorMessages.actionFor(
        UpdateErrorType.networkError,
      );
      expect(action.toLowerCase(), contains('retry'));
    });

    test('securityError action mentions support or reinstall', () {
      final action = UpdateErrorMessages.actionFor(
        UpdateErrorType.securityError,
      );
      expect(
        action.toLowerCase(),
        anyOf(contains('support'), contains('reinstall')),
      );
    });
  });

  // -------------------------------------------------------------------------
  // UpdateErrorMessages constants
  // -------------------------------------------------------------------------

  group('UpdateErrorMessages constants', () {
    test('fallbackUrl is a valid HTTPS GitHub Releases URL', () {
      final uri = Uri.parse(UpdateErrorMessages.fallbackUrl);
      expect(uri.scheme, 'https');
      expect(uri.host, contains('github.com'));
      expect(uri.path.toLowerCase(), contains('releases'));
    });

    test('fallbackLabel is non-empty', () {
      expect(UpdateErrorMessages.fallbackLabel, isNotEmpty);
    });
  });
}
