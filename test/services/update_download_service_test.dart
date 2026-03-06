import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/update_download_result.dart';
import 'package:church_analytics/services/update_download_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  final kValidSha = 'a' * 64;

  UpdateManifest makeManifest({
    String downloadUrl = 'https://example.com/app-1.0.0.tar.gz',
  }) => UpdateManifest(
    version: '1.0.0',
    releaseDate: '2024-01-01',
    minSupportedVersion: '1.0.0',
    releaseNotes: 'Test release',
    platforms: {
      'linux': PlatformAsset(downloadUrl: downloadUrl, sha256: kValidSha),
      'windows': PlatformAsset(downloadUrl: downloadUrl, sha256: kValidSha),
      'macos': PlatformAsset(downloadUrl: downloadUrl, sha256: kValidSha),
      'android': PlatformAsset(downloadUrl: downloadUrl, sha256: kValidSha),
    },
  );

  // -------------------------------------------------------------------------
  // UpdateDownloadResult factory tests
  // -------------------------------------------------------------------------

  group('UpdateDownloadResult', () {
    test('success() sets isSuccess=true and filePath', () {
      final result = UpdateDownloadResult.success('/tmp/app.exe');
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.filePath, '/tmp/app.exe');
      expect(result.error, isNull);
      expect(result.errorType, isNull);
    });

    test('failure() sets isError=true and errorType', () {
      final result = UpdateDownloadResult.failure(
        'network failed',
        errorType: UpdateErrorType.networkError,
      );
      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
      expect(result.error, 'network failed');
      expect(result.errorType, UpdateErrorType.networkError);
    });

    test('failure() defaults to downloadError when no errorType given', () {
      final result = UpdateDownloadResult.failure('boom');
      expect(result.errorType, UpdateErrorType.downloadError);
    });

    test('failure() accepts explicit errorType override', () {
      final result = UpdateDownloadResult.failure(
        'mismatch',
        errorType: UpdateErrorType.checksumMismatch,
      );
      expect(result.errorType, UpdateErrorType.checksumMismatch);
    });

    test('toString() includes filePath for success', () {
      final result = UpdateDownloadResult.success('/tmp/app');
      expect(result.toString(), contains('/tmp/app'));
      expect(result.toString(), contains('success'));
    });

    test('toString() includes error info for failure', () {
      final result = UpdateDownloadResult.failure('oops');
      expect(result.toString(), contains('oops'));
      expect(result.toString(), contains('failure'));
    });
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — unsupported platform
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — no matching platform asset', () {
    test(
      'returns unsupportedPlatform failure when manifest has no matching platform',
      () async {
        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response('data', 200)),
        );
        // Manifest with no platforms matching the current platform
        final emptyManifest = UpdateManifest(
          version: '1.0.0',
          releaseDate: '2024-01-01',
          minSupportedVersion: '1.0.0',
          releaseNotes: 'Test',
          platforms: {},
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: emptyManifest,
            destDir: destDir,
          );
          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.unsupportedPlatform);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — HTTP error
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — HTTP error', () {
    test('HTTP 404 returns downloadError failure', () async {
      final service = UpdateDownloadService(
        client: MockClient((_) async => http.Response('Not Found', 404)),
      );

      final destDir = await Directory.systemTemp.createTemp('uds_test_');
      try {
        final result = await service.download(
          manifest: makeManifest(),
          destDir: destDir,
        );
        expect(result.isError, isTrue);
        expect(result.errorType, UpdateErrorType.downloadError);
        expect(result.error, contains('404'));
        // No partial file left behind
        expect(destDir.listSync(), isEmpty);
      } finally {
        await destDir.delete(recursive: true);
      }
    });

    test(
      'HTTP 500 returns downloadError failure and cleans up no partial file',
      () async {
        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response('Server Error', 500)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(),
            destDir: destDir,
          );
          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.downloadError);
          expect(destDir.listSync(), isEmpty);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — network exception
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — network exception cleanup', () {
    test(
      'deletes pre-existing partial file when network request throws',
      () async {
        final service = UpdateDownloadService(
          client: MockClient(
            (_) async => throw Exception('connection refused'),
          ),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        // Pre-create a partial file with the expected filename.
        final partialFile = File('${destDir.path}/app-1.0.0.tar.gz');
        await partialFile.writeAsString('partial content');
        expect(await partialFile.exists(), isTrue);

        try {
          final result = await service.download(
            manifest: makeManifest(),
            destDir: destDir,
          );
          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.downloadError);
          // The partial file should have been cleaned up.
          expect(await partialFile.exists(), isFalse);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test('returns downloadError failure on network exception', () async {
      final service = UpdateDownloadService(
        client: MockClient((_) async => throw Exception('timeout')),
      );

      final destDir = await Directory.systemTemp.createTemp('uds_test_');
      try {
        final result = await service.download(
          manifest: makeManifest(),
          destDir: destDir,
        );
        expect(result.isError, isTrue);
        expect(result.errorType, UpdateErrorType.downloadError);
        expect(result.error, isNotNull);
      } finally {
        await destDir.delete(recursive: true);
      }
    });
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — successful download
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — successful download', () {
    test(
      'writes file to destDir and returns success with correct path',
      () async {
        const fakeContent = 'fake-installer-bytes';
        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(fakeContent, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(),
            destDir: destDir,
          );
          expect(result.isSuccess, isTrue);
          expect(result.filePath, isNotNull);
          final file = File(result.filePath!);
          expect(await file.exists(), isTrue);
          expect(await file.readAsString(), fakeContent);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });
}
