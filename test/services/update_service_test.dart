import 'dart:convert';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  const kManifestUrl = 'https://example.com/update.json';

  /// Builds a minimal valid manifest JSON payload with the given [version].
  Map<String, dynamic> makeManifestJson(String version) => {
    'version': version,
    'release_date': '2024-01-15',
    'min_supported_version': '1.0.0',
    'release_notes': 'Release $version',
    'platforms': {
      'android': {
        'download_url':
            'https://github.com/example/releases/download/$version/app.apk',
        'sha256': 'a' * 64,
      },
    },
  };

  /// Returns a [PackageInfo] stub with the given [version].
  PackageInfo makePackageInfo(String version) => PackageInfo(
    appName: 'church_analytics',
    packageName: 'com.example.church_analytics',
    version: version,
    buildNumber: '1',
  );

  /// Returns an [UpdateService] that will always receive the given [json] as a
  /// 200 response and report [currentVersion] as the installed version.
  UpdateService makeService({
    required Map<String, dynamic> json,
    required String currentVersion,
    String? manifestUrl,
  }) => UpdateService(
    client: MockClient((_) async => http.Response(jsonEncode(json), 200)),
    manifestUrl: manifestUrl ?? kManifestUrl,
    getPackageInfo: () async => makePackageInfo(currentVersion),
  );

  // ---------------------------------------------------------------------------
  // UpdateCheckResult value-class tests
  // ---------------------------------------------------------------------------

  group('UpdateCheckResult', () {
    test('available() sets correct fields', () {
      final manifest = UpdateManifest.fromJson(makeManifestJson('1.1.0'));
      final result = UpdateCheckResult.available(
        latestVersion: '1.1.0',
        currentVersion: '1.0.0',
        manifest: manifest,
      );

      expect(result.isUpdateAvailable, isTrue);
      expect(result.latestVersion, '1.1.0');
      expect(result.currentVersion, '1.0.0');
      expect(result.manifest, isNotNull);
      expect(result.error, isNull);
      expect(result.isError, isFalse);
    });

    test('upToDate() sets correct fields', () {
      final manifest = UpdateManifest.fromJson(makeManifestJson('1.0.0'));
      final result = UpdateCheckResult.upToDate(
        latestVersion: '1.0.0',
        currentVersion: '1.0.0',
        manifest: manifest,
      );

      expect(result.isUpdateAvailable, isFalse);
      expect(result.latestVersion, '1.0.0');
      expect(result.currentVersion, '1.0.0');
      expect(result.manifest, isNotNull);
      expect(result.error, isNull);
      expect(result.isError, isFalse);
    });

    test('failure() sets error and isError', () {
      final result = UpdateCheckResult.failure('network error');

      expect(result.isUpdateAvailable, isFalse);
      expect(result.error, 'network error');
      expect(result.isError, isTrue);
      expect(result.manifest, isNull);
      expect(result.latestVersion, isNull);
      expect(result.currentVersion, isNull);
      // Default error type is networkError
      expect(result.errorType, UpdateErrorType.networkError);
    });

    test('failure() accepts explicit parseError type', () {
      final result = UpdateCheckResult.failure(
        'bad json',
        errorType: UpdateErrorType.parseError,
      );
      expect(result.errorType, UpdateErrorType.parseError);
    });

    test('available() and upToDate() have no errorType', () {
      final manifest = UpdateManifest.fromJson(makeManifestJson('1.1.0'));
      final available = UpdateCheckResult.available(
        latestVersion: '1.1.0',
        currentVersion: '1.0.0',
        manifest: manifest,
      );
      final upToDate = UpdateCheckResult.upToDate(
        latestVersion: '1.0.0',
        currentVersion: '1.0.0',
        manifest: manifest,
      );
      expect(available.errorType, isNull);
      expect(upToDate.errorType, isNull);
    });

    test('toString() describes an error result', () {
      final result = UpdateCheckResult.failure('boom');
      expect(result.toString(), contains('boom'));
    });

    test('toString() describes a success result', () {
      final manifest = UpdateManifest.fromJson(makeManifestJson('1.1.0'));
      final result = UpdateCheckResult.available(
        latestVersion: '1.1.0',
        currentVersion: '1.0.0',
        manifest: manifest,
      );
      expect(result.toString(), contains('1.1.0'));
      expect(result.toString(), contains('1.0.0'));
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateService.checkForUpdate() — version comparison scenarios
  // ---------------------------------------------------------------------------

  group('UpdateService.checkForUpdate() — version comparison', () {
    test('isUpdateAvailable=true when remote minor is greater', () async {
      final service = makeService(
        json: makeManifestJson('1.1.0'),
        currentVersion: '1.0.0',
      );
      final result = await service.checkForUpdate();

      expect(result.isUpdateAvailable, isTrue);
      expect(result.latestVersion, '1.1.0');
      expect(result.currentVersion, '1.0.0');
      expect(result.error, isNull);
    });

    test('isUpdateAvailable=false when versions are equal', () async {
      final result = await makeService(
        json: makeManifestJson('1.0.0'),
        currentVersion: '1.0.0',
      ).checkForUpdate();

      expect(result.isUpdateAvailable, isFalse);
      expect(result.error, isNull);
    });

    test('isUpdateAvailable=false when remote is older', () async {
      final result = await makeService(
        json: makeManifestJson('0.9.0'),
        currentVersion: '1.0.0',
      ).checkForUpdate();

      expect(result.isUpdateAvailable, isFalse);
    });

    test('detects update on minor bump (1.9.0 → 1.10.0)', () async {
      final result = await makeService(
        json: makeManifestJson('1.10.0'),
        currentVersion: '1.9.0',
      ).checkForUpdate();

      expect(result.isUpdateAvailable, isTrue);
    });

    test(
      'does not treat "1.10.0" as older than "1.9.0" lexicographically',
      () async {
        final result = await makeService(
          json: makeManifestJson('1.10.0'),
          currentVersion: '1.9.0',
        ).checkForUpdate();

        // Lexicographic "1.10.0" < "1.9.0" — but integer comparison is correct.
        expect(result.isUpdateAvailable, isTrue);
      },
    );

    test('detects update on patch bump (1.0.4 → 1.0.5)', () async {
      final result = await makeService(
        json: makeManifestJson('1.0.5'),
        currentVersion: '1.0.4',
      ).checkForUpdate();

      expect(result.isUpdateAvailable, isTrue);
    });

    test('detects update on major bump (1.9.9 → 2.0.0)', () async {
      final result = await makeService(
        json: makeManifestJson('2.0.0'),
        currentVersion: '1.9.9',
      ).checkForUpdate();

      expect(result.isUpdateAvailable, isTrue);
    });

    test('handles pre-release suffix on current version', () async {
      // current = 1.0.0-beta (pre-release), remote = 1.0.0 (stable release).
      // By semver rules, the stable release is newer than its pre-release.
      final result = await makeService(
        json: makeManifestJson('1.0.0'),
        currentVersion: '1.0.0-beta',
      ).checkForUpdate();

      // 1.0.0 > 1.0.0-beta per semver §9 — update is available.
      expect(result.isUpdateAvailable, isTrue);
    });

    test('manifest version and latestVersion match', () async {
      final result = await makeService(
        json: makeManifestJson('2.3.1'),
        currentVersion: '1.0.0',
      ).checkForUpdate();

      expect(result.latestVersion, '2.3.1');
      expect(result.manifest?.version, '2.3.1');
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateService.checkForUpdate() — error scenarios
  // ---------------------------------------------------------------------------

  group('UpdateService.checkForUpdate() — error scenarios', () {
    test('network error returns failure result without throwing', () async {
      final service = UpdateService(
        client: MockClient((_) async => throw Exception('connection refused')),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();

      expect(result.isError, isTrue);
      expect(result.isUpdateAvailable, isFalse);
    });

    test('HTTP 404 returns failure result', () async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('Not Found', 404)),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();

      expect(result.isError, isTrue);
      expect(result.error, contains('404'));
    });

    test('HTTP 500 returns failure result', () async {
      final service = UpdateService(
        client: MockClient(
          (_) async => http.Response('Internal Server Error', 500),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();

      expect(result.isError, isTrue);
      expect(result.error, contains('500'));
    });

    test(
      'malformed JSON body returns typed failure, not unhandled exception',
      () async {
        final service = UpdateService(
          client: MockClient(
            (_) async => http.Response('{invalid json!!!}', 200),
          ),
          manifestUrl: kManifestUrl,
          getPackageInfo: () async => makePackageInfo('1.0.0'),
        );
        final result = await service.checkForUpdate();

        expect(result.isError, isTrue);
      },
    );

    test('JSON missing required field returns typed parse failure', () async {
      // Only contains 'version'; all other required fields are absent.
      final service = UpdateService(
        client: MockClient(
          (_) async => http.Response(jsonEncode({'version': '1.1.0'}), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();

      expect(result.isError, isTrue);
    });

    test('non-HTTPS manifest URL returns security failure', () async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('{}', 200)),
        manifestUrl: 'http://example.com/update.json', // http, not https
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();

      expect(result.isError, isTrue);
      expect(result.error, isNotNull);
    });

    test('network timeout returns failure with "timed out" message', () async {
      // Inject a 100 ms timeout and a handler that delays 300 ms.
      final service = UpdateService(
        client: MockClient((_) async {
          await Future.delayed(const Duration(milliseconds: 300));
          return http.Response('{}', 200);
        }),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
        networkTimeout: const Duration(milliseconds: 100),
      );
      final result = await service.checkForUpdate();

      expect(result.isError, isTrue);
      expect(result.error, contains('timed out'));
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateCheckResult — errorType classification
  // ---------------------------------------------------------------------------

  group('UpdateService.checkForUpdate() — errorType classification', () {
    test('network exception yields networkError errorType', () async {
      final service = UpdateService(
        client: MockClient((_) async => throw Exception('connection refused')),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();
      expect(result.errorType, UpdateErrorType.networkError);
    });

    test('HTTP error yields networkError errorType', () async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('Not Found', 404)),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();
      expect(result.errorType, UpdateErrorType.networkError);
    });

    test(
      'malformed JSON yields networkError errorType (generic catch)',
      () async {
        final service = UpdateService(
          client: MockClient(
            (_) async => http.Response('{invalid json!!!}', 200),
          ),
          manifestUrl: kManifestUrl,
          getPackageInfo: () async => makePackageInfo('1.0.0'),
        );
        final result = await service.checkForUpdate();
        // FormatException is caught by the generic catch → networkError
        expect(result.errorType, UpdateErrorType.networkError);
      },
    );

    test(
      'manifest with missing required field yields parseError errorType',
      () async {
        final service = UpdateService(
          client: MockClient(
            (_) async => http.Response(jsonEncode({'version': '1.1.0'}), 200),
          ),
          manifestUrl: kManifestUrl,
          getPackageInfo: () async => makePackageInfo('1.0.0'),
        );
        final result = await service.checkForUpdate();
        expect(result.errorType, UpdateErrorType.parseError);
      },
    );

    test('non-HTTPS URL yields securityError errorType', () async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('{}', 200)),
        manifestUrl: 'http://example.com/update.json',
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );
      final result = await service.checkForUpdate();
      expect(result.errorType, UpdateErrorType.securityError);
    });

    test('timeout yields networkError errorType', () async {
      final service = UpdateService(
        client: MockClient((_) async {
          await Future.delayed(const Duration(milliseconds: 300));
          return http.Response('{}', 200);
        }),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
        networkTimeout: const Duration(milliseconds: 100),
      );
      final result = await service.checkForUpdate();
      expect(result.errorType, UpdateErrorType.networkError);
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateService — caching behaviour
  // ---------------------------------------------------------------------------

  group('UpdateService — caching', () {
    test(
      'second call returns cached result without an additional HTTP request',
      () async {
        var callCount = 0;
        final service = UpdateService(
          client: MockClient((_) async {
            callCount++;
            return http.Response(jsonEncode(makeManifestJson('1.1.0')), 200);
          }),
          manifestUrl: kManifestUrl,
          getPackageInfo: () async => makePackageInfo('1.0.0'),
        );

        final r1 = await service.checkForUpdate();
        final r2 = await service.checkForUpdate();

        expect(callCount, 1, reason: 'HTTP client should only be called once');
        expect(
          identical(r1, r2),
          isTrue,
          reason: 'Both calls must return the exact same object',
        );
      },
    );

    test('error result is also cached', () async {
      var callCount = 0;
      final service = UpdateService(
        client: MockClient((_) async {
          callCount++;
          throw Exception('network failure');
        }),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      final r1 = await service.checkForUpdate();
      final r2 = await service.checkForUpdate();

      expect(callCount, 1);
      expect(r1.isError, isTrue);
      expect(identical(r1, r2), isTrue);
    });

    test('resetCache() triggers a fresh HTTP request on next call', () async {
      var callCount = 0;
      final service = UpdateService(
        client: MockClient((_) async {
          callCount++;
          return http.Response(jsonEncode(makeManifestJson('1.1.0')), 200);
        }),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await service.checkForUpdate();
      service.resetCache();
      await service.checkForUpdate();

      expect(
        callCount,
        2,
        reason: 'resetCache() must allow a re-fetch on the next call',
      );
    });

    test('resetCache() after error allows re-check', () async {
      var callCount = 0;
      var shouldFail = true;

      final service = UpdateService(
        client: MockClient((_) async {
          callCount++;
          if (shouldFail) throw Exception('temporary network error');
          return http.Response(jsonEncode(makeManifestJson('1.1.0')), 200);
        }),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      final fail = await service.checkForUpdate();
      expect(fail.isError, isTrue);

      // Simulate recovery: reset the cache and allow the next request to succeed.
      shouldFail = false;
      service.resetCache();
      final ok = await service.checkForUpdate();

      expect(callCount, 2);
      expect(ok.isError, isFalse);
      expect(ok.isUpdateAvailable, isTrue);
    });
  });
}
