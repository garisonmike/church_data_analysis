import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateUrlValidator', () {
    group('validateHttpsUrl', () {
      test('accepts valid HTTPS URLs', () {
        final validUrls = [
          'https://github.com/user/repo/releases/latest/download/update.json',
          'https://example.com/update.json',
          'https://api.example.com:8443/v1/update.json',
          'https://github.com/GarisonMike/church_data_analysis/releases/download/v1.2.0/app-release.apk',
        ];

        for (final url in validUrls) {
          expect(
            () => UpdateUrlValidator.validateHttpsUrl(url),
            returnsNormally,
            reason: 'Should accept valid HTTPS URL: $url',
          );
          expect(
            UpdateUrlValidator.validateHttpsUrl(url),
            equals(url),
            reason: 'Should return the same URL',
          );
        }
      });

      test('rejects HTTP URLs', () {
        final invalidUrls = [
          'http://github.com/user/repo/update.json',
          'http://example.com/update.json',
          'http://localhost:8080/update.json',
        ];

        for (final url in invalidUrls) {
          expect(
            () => UpdateUrlValidator.validateHttpsUrl(url),
            throwsA(
              isA<UpdateSecurityException>().having(
                (e) => e.message,
                'message',
                contains('must use HTTPS'),
              ),
            ),
            reason: 'Should reject HTTP URL: $url',
          );
        }
      });

      test('rejects non-HTTP(S) schemes', () {
        final invalidUrls = [
          'ftp://example.com/update.json',
          'file:///tmp/update.json',
          'data:text/plain,hello',
          'javascript:alert(1)',
          'ws://example.com/update',
          'wss://example.com/update',
        ];

        for (final url in invalidUrls) {
          expect(
            () => UpdateUrlValidator.validateHttpsUrl(url),
            throwsA(isA<UpdateSecurityException>()),
            reason: 'Should reject non-HTTPS scheme: $url',
          );
        }
      });

      test('rejects protocol-relative URLs', () {
        expect(
          () =>
              UpdateUrlValidator.validateHttpsUrl('//example.com/update.json'),
          throwsA(isA<UpdateSecurityException>()),
          reason: 'Should reject protocol-relative URLs',
        );
      });

      test('rejects malformed URLs', () {
        final malformedUrls = [
          '',
          '   ',
          'not a url',
          'https://',
          'https:///',
          'ht tps://example.com',
          'https//example.com',
        ];

        for (final url in malformedUrls) {
          expect(
            () => UpdateUrlValidator.validateHttpsUrl(url),
            throwsA(
              isA<UpdateSecurityException>().having(
                (e) => e.message,
                'message',
                anyOf(contains('Invalid URL'), contains('must use HTTPS')),
              ),
            ),
            reason: 'Should reject malformed URL: "$url"',
          );
        }
      });

      test('exception includes URL in details', () {
        const testUrl = 'http://example.com/update.json';

        try {
          UpdateUrlValidator.validateHttpsUrl(testUrl);
          fail('Should have thrown UpdateSecurityException');
        } on UpdateSecurityException catch (e) {
          expect(e.url, equals(testUrl));
          expect(e.message, isNotEmpty);
          expect(e.details, isNotNull);
          expect(e.toString(), contains(testUrl));
        }
      });

      test('handles URLs with query parameters', () {
        const url = 'https://example.com/update.json?v=123&cache=bust';
        expect(UpdateUrlValidator.validateHttpsUrl(url), equals(url));
      });

      test('handles URLs with fragments', () {
        const url = 'https://example.com/update.json#section';
        expect(UpdateUrlValidator.validateHttpsUrl(url), equals(url));
      });

      test('handles URLs with authentication (discouraged but valid)', () {
        const url = 'https://user:pass@example.com/update.json';
        expect(UpdateUrlValidator.validateHttpsUrl(url), equals(url));
      });

      test('handles non-standard ports', () {
        const url = 'https://example.com:8443/update.json';
        expect(UpdateUrlValidator.validateHttpsUrl(url), equals(url));
      });

      test('handles punycode/international domains', () {
        const url = 'https://münchen.de/update.json';
        expect(UpdateUrlValidator.validateHttpsUrl(url), equals(url));
      });
    });

    group('validateHttpsUrls', () {
      test('accepts list of valid HTTPS URLs', () {
        final urls = [
          'https://example.com/update.json',
          'https://github.com/user/repo/releases/app.apk',
          'https://cdn.example.com/installer.exe',
        ];

        expect(UpdateUrlValidator.validateHttpsUrls(urls), equals(urls));
      });

      test('rejects list if any URL is invalid', () {
        final urls = [
          'https://example.com/update.json',
          'http://bad.com/file.apk', // Invalid
          'https://good.com/installer.exe',
        ];

        expect(
          () => UpdateUrlValidator.validateHttpsUrls(urls),
          throwsA(
            isA<UpdateSecurityException>().having(
              (e) => e.url,
              'url',
              contains('bad.com'),
            ),
          ),
        );
      });

      test('handles empty list', () {
        expect(UpdateUrlValidator.validateHttpsUrls([]), equals([]));
      });

      test('stops at first invalid URL', () {
        final urls = [
          'https://good1.com/update.json',
          'http://bad1.com/file.apk', // First invalid
          'http://bad2.com/file.apk', // Second invalid (not reached)
        ];

        try {
          UpdateUrlValidator.validateHttpsUrls(urls);
          fail('Should have thrown');
        } on UpdateSecurityException catch (e) {
          // Should fail on first invalid URL
          expect(e.url, contains('bad1.com'));
          expect(e.url, isNot(contains('bad2.com')));
        }
      });
    });

    group('isHttpsUrl', () {
      test('returns true for valid HTTPS URLs', () {
        expect(
          UpdateUrlValidator.isHttpsUrl('https://example.com/update.json'),
          isTrue,
        );
        expect(
          UpdateUrlValidator.isHttpsUrl('https://github.com/repo/file.apk'),
          isTrue,
        );
      });

      test('returns false for HTTP URLs', () {
        expect(
          UpdateUrlValidator.isHttpsUrl('http://example.com/update.json'),
          isFalse,
        );
      });

      test('returns false for non-HTTP schemes', () {
        expect(
          UpdateUrlValidator.isHttpsUrl('ftp://example.com/file'),
          isFalse,
        );
        expect(
          UpdateUrlValidator.isHttpsUrl('file:///tmp/update.json'),
          isFalse,
        );
      });

      test('returns false for malformed URLs', () {
        expect(UpdateUrlValidator.isHttpsUrl('not a url'), isFalse);
        expect(UpdateUrlValidator.isHttpsUrl(''), isFalse);
        expect(UpdateUrlValidator.isHttpsUrl('https://'), isFalse);
      });

      test('does not throw exceptions', () {
        final problematicInputs = [
          'http://evil.com',
          'not-a-url',
          '',
          'ftp://server.com',
          'javascript:alert(1)',
        ];

        for (final input in problematicInputs) {
          expect(
            () => UpdateUrlValidator.isHttpsUrl(input),
            returnsNormally,
            reason: 'Should not throw for: $input',
          );
          expect(
            UpdateUrlValidator.isHttpsUrl(input),
            isFalse,
            reason: 'Should return false for: $input',
          );
        }
      });
    });

    group('UpdateSecurityException', () {
      test('formats toString with all fields', () {
        final exception = UpdateSecurityException(
          'Test message',
          url: 'https://example.com',
          details: 'Additional context',
        );

        final string = exception.toString();
        expect(string, contains('UpdateSecurityException'));
        expect(string, contains('Test message'));
        expect(string, contains('https://example.com'));
        expect(string, contains('Additional context'));
      });

      test('formats toString without optional fields', () {
        final exception = UpdateSecurityException('Test message');

        final string = exception.toString();
        expect(string, contains('UpdateSecurityException'));
        expect(string, contains('Test message'));
        expect(string, isNot(contains('URL:')));
        expect(string, isNot(contains('Details:')));
      });

      test('can be caught as Exception', () {
        expect(
          () => throw UpdateSecurityException('test'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
