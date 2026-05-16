import 'dart:convert';
import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/update_download_result.dart';
import 'package:church_analytics/services/update_download_service.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Dummy SHA-256 (valid 64-char hex) used only in tests where the download
  /// never reaches checksum verification (failure tests).
  final kValidSha = 'a' * 64;

  /// Returns the real SHA-256 hex string of [content] encoded as UTF-8.
  ///
  /// Use this to build manifests for success-path tests so that the new
  /// checksum verification step passes.
  String sha256Of(String content) =>
      crypto.sha256.convert(utf8.encode(content)).toString();

  UpdateManifest makeManifest({
    String downloadUrl = 'https://example.com/app-1.0.0.tar.gz',
    String? sha256,
  }) {
    final effectiveSha256 = sha256 ?? kValidSha;
    return UpdateManifest(
      version: '1.0.0',
      releaseDate: '2024-01-01',
      minSupportedVersion: '1.0.0',
      releaseNotes: 'Test release',
      platforms: {
        'linux': PlatformAsset(
          downloadUrl: downloadUrl,
          sha256: effectiveSha256,
        ),
        'windows': PlatformAsset(
          downloadUrl: downloadUrl,
          sha256: effectiveSha256,
        ),
        'macos': PlatformAsset(
          downloadUrl: downloadUrl,
          sha256: effectiveSha256,
        ),
        'android': PlatformAsset(
          downloadUrl: downloadUrl,
          sha256: effectiveSha256,
        ),
      },
    );
  }

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
            manifest: makeManifest(sha256: sha256Of(fakeContent)),
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

  // -------------------------------------------------------------------------
  // UpdateDownloadService — disk space validation (UPDATE-010)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — disk space validation', () {
    test(
      'aborts with insufficientDiskSpace when free space is less than content-length',
      () async {
        const installerSize = 50 * 1024 * 1024; // 50 MB
        const freeSpace = 10 * 1024 * 1024; // 10 MB — insufficient

        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response(
                '',
                200,
                headers: {'content-length': '$installerSize'},
              );
            }
            // GET must never be reached when space is insufficient.
            throw StateError(
              'GET should not be called when space is insufficient',
            );
          }),
          freeSpaceResolver: (_) async => freeSpace,
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(),
            destDir: destDir,
          );
          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.insufficientDiskSpace);
          expect(result.error, isNotNull);
          // Message must include both required and available sizes.
          expect(result.error, contains('50.0 MB'));
          expect(result.error, contains('10.0 MB'));
          // No partial file should have been written.
          expect(destDir.listSync(), isEmpty);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'proceeds when free space equals content-length (boundary: equal is sufficient)',
      () async {
        const size = 20 * 1024 * 1024; // 20 MB — exactly equal

        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response(
                '',
                200,
                headers: {'content-length': '$size'},
              );
            }
            return http.Response('data', 200);
          }),
          freeSpaceResolver: (_) async => size,
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of('data')),
            destDir: destDir,
          );
          expect(result.isSuccess, isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test('proceeds when free space exceeds content-length', () async {
      const installerSize = 10 * 1024 * 1024; // 10 MB
      const freeSpace = 500 * 1024 * 1024; // 500 MB — plenty

      final service = UpdateDownloadService(
        client: MockClient((request) async {
          if (request.method == 'HEAD') {
            return http.Response(
              '',
              200,
              headers: {'content-length': '$installerSize'},
            );
          }
          return http.Response('data', 200);
        }),
        freeSpaceResolver: (_) async => freeSpace,
      );

      final destDir = await Directory.systemTemp.createTemp('uds_test_');
      try {
        final result = await service.download(
          manifest: makeManifest(sha256: sha256Of('data')),
          destDir: destDir,
        );
        expect(result.isSuccess, isTrue);
      } finally {
        await destDir.delete(recursive: true);
      }
    });

    test(
      'skips check and proceeds when HEAD returns no content-length header',
      () async {
        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response('', 200); // no content-length header
            }
            return http.Response('installer', 200);
          }),
          freeSpaceResolver: (_) async => 1024, // tiny — would fail if checked
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of('installer')),
            destDir: destDir,
          );
          expect(result.isSuccess, isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test('skips check and proceeds when HEAD request throws', () async {
      final service = UpdateDownloadService(
        client: MockClient((request) async {
          if (request.method == 'HEAD') {
            throw Exception('HEAD not supported');
          }
          return http.Response('installer', 200);
        }),
        freeSpaceResolver: (_) async => 1024, // tiny — would fail if checked
      );

      final destDir = await Directory.systemTemp.createTemp('uds_test_');
      try {
        final result = await service.download(
          manifest: makeManifest(sha256: sha256Of('installer')),
          destDir: destDir,
        );
        expect(result.isSuccess, isTrue);
      } finally {
        await destDir.delete(recursive: true);
      }
    });

    test(
      'skips check and proceeds when freeSpaceResolver returns null',
      () async {
        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response(
                '',
                200,
                headers: {'content-length': '${50 * 1024 * 1024}'},
              );
            }
            return http.Response('installer', 200);
          }),
          freeSpaceResolver: (_) async => null, // unavailable
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of('installer')),
            destDir: destDir,
          );
          expect(result.isSuccess, isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'error message contains remediation hint to free up disk space',
      () async {
        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response(
                '',
                200,
                headers: {'content-length': '${100 * 1024 * 1024}'},
              );
            }
            throw StateError('GET must not be called');
          }),
          freeSpaceResolver: (_) async => 1024,
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(),
            destDir: destDir,
          );
          expect(result.isError, isTrue);
          expect(result.error!.toLowerCase(), contains('free up disk space'));
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'skips check and proceeds when HEAD returns a redirect (302) — CDN fail-open',
      () async {
        // GitHub Releases CDN issues 302 redirects for asset downloads.
        // A 302 from HEAD must not block the download (fail-open).
        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response(
                '',
                302,
                headers: {'location': 'https://cdn.example.com/app.tar.gz'},
              );
            }
            return http.Response('installer-bytes', 200);
          }),
          freeSpaceResolver: (_) async =>
              1024, // tiny free space — would abort if check ran
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of('installer-bytes')),
            destDir: destDir,
          );
          // Check skipped → download proceeds → success.
          expect(result.isSuccess, isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'skips check and proceeds when HEAD returns content-length of zero',
      () async {
        // A zero Content-Length is a malformed response; treat as unavailable.
        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response('', 200, headers: {'content-length': '0'});
            }
            return http.Response('installer-bytes', 200);
          }),
          freeSpaceResolver: (_) async => 512, // tiny — would abort if checked
        );

        final destDir = await Directory.systemTemp.createTemp('uds_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of('installer-bytes')),
            destDir: destDir,
          );
          // Zero content-length → skip check → download proceeds → success.
          expect(result.isSuccess, isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService.formatBytes
  // -------------------------------------------------------------------------

  group('UpdateDownloadService.formatBytes', () {
    test('formats bytes below 1 KB', () {
      expect(UpdateDownloadService.formatBytes(500), '500 B');
    });

    test('formats kilobytes', () {
      expect(UpdateDownloadService.formatBytes(2048), '2.0 KB');
    });

    test('formats megabytes', () {
      expect(UpdateDownloadService.formatBytes(50 * 1024 * 1024), '50.0 MB');
    });

    test('formats gigabytes', () {
      expect(
        UpdateDownloadService.formatBytes(2 * 1024 * 1024 * 1024),
        '2.0 GB',
      );
    });
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — SHA-256 checksum verification (UPDATE-006)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — SHA-256 checksum verification', () {
    test('succeeds when computed SHA-256 matches manifest sha256', () async {
      const content = 'verified-installer-payload';
      final correctSha256 = sha256Of(content);

      final service = UpdateDownloadService(
        client: MockClient((_) async => http.Response(content, 200)),
      );

      final destDir = await Directory.systemTemp.createTemp('uds_sha_test_');
      try {
        final result = await service.download(
          manifest: makeManifest(sha256: correctSha256),
          destDir: destDir,
        );
        expect(result.isSuccess, isTrue);
        expect(result.filePath, isNotNull);
        // File must contain the downloaded content.
        expect(await File(result.filePath!).readAsString(), content);
      } finally {
        await destDir.delete(recursive: true);
      }
    });

    test(
      'returns checksumMismatch when SHA-256 does not match manifest sha256',
      () async {
        const content = 'tampered-installer-payload';
        final wrongSha256 = 'b' * 64; // valid hex but does not match content

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_sha_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: wrongSha256),
            destDir: destDir,
          );
          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.checksumMismatch);
          expect(result.error, isNotNull);
          expect(result.error, contains('Checksum mismatch'));
          // Partial file must have been deleted.
          expect(destDir.listSync(), isEmpty);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'SHA-256 comparison is case-insensitive (manifest uppercase vs computed lowercase)',
      () async {
        const content = 'case-test-payload';
        // sha256Of returns lowercase; produce the uppercase equivalent.
        final upperSha256 = sha256Of(content).toUpperCase();

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_sha_test_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: upperSha256),
            destDir: destDir,
          );
          // Should succeed: comparison must normalise to lowercase.
          expect(result.isSuccess, isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — cancellation (UPDATE-006)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — cancellation', () {
    test(
      'returns downloadCancelled and deletes partial file when token cancelled',
      () async {
        final cancelToken = CancelToken();
        const content = 'installer-chunk';

        // A client that cancels the token before the first chunk is consumed
        // by using a multi-chunk stream.  We cancel before the loop processes any
        // chunk by setting the token before download is called.
        cancelToken.cancel(); // pre-cancelled

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_cancel_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
            cancelToken: cancelToken,
          );
          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.downloadCancelled);
          // Partial file must be cleaned up.
          expect(destDir.listSync(), isEmpty);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'downloadCancelled error message is non-null and descriptive',
      () async {
        final cancelToken = CancelToken()..cancel();

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response('bytes', 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_cancel_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of('bytes')),
            destDir: destDir,
            cancelToken: cancelToken,
          );
          expect(result.errorType, UpdateErrorType.downloadCancelled);
          expect(result.error, isNotNull);
          expect(result.error!.isNotEmpty, isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — cached-file reuse (FEAT-005)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — cached-file reuse (FEAT-005)', () {
    test(
      'returns success immediately when existing file matches manifest sha256',
      () async {
        const content = 'cached-installer-bytes';
        final correctSha = sha256Of(content);

        // Service with a client that MUST NOT be called on a GET request.
        // If a GET is issued we fail the test loudly.
        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'GET') {
              throw StateError(
                'GET must not be issued when a valid cached file exists',
              );
            }
            // HEAD requests are allowed (they happen during disk-space check
            // for fresh downloads — but the cache check short-circuits before
            // that block is reached, so HEAD should also not be called here).
            throw StateError('No HTTP request expected for a cache hit');
          }),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_cache_');
        try {
          // Pre-populate the destination file with the correct content.
          final filename = 'app-1.0.0.tar.gz'; // derived from makeManifest URL
          final cachedFile = File('${destDir.path}/$filename');
          await cachedFile.writeAsString(content);

          final result = await service.download(
            manifest: makeManifest(sha256: correctSha),
            destDir: destDir,
          );

          expect(result.isSuccess, isTrue);
          expect(result.filePath, cachedFile.path);
          // The original file must still be present (not deleted).
          expect(await cachedFile.exists(), isTrue);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'calls onProgress(1.0) immediately on a cache hit',
      () async {
        const content = 'cached-bytes-for-progress';
        final correctSha = sha256Of(content);

        final service = UpdateDownloadService(
          client: MockClient((_) async {
            throw StateError('No network call expected on a cache hit');
          }),
        );

        final progressValues = <double>[];

        final destDir = await Directory.systemTemp.createTemp('uds_cache_');
        try {
          final filename = 'app-1.0.0.tar.gz';
          await File('${destDir.path}/$filename').writeAsString(content);

          final result = await service.download(
            manifest: makeManifest(sha256: correctSha),
            destDir: destDir,
            onProgress: progressValues.add,
          );

          expect(result.isSuccess, isTrue);
          expect(progressValues, [1.0]);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'deletes stale file and re-downloads when sha256 does not match',
      () async {
        const staleContent = 'old-corrupt-bytes';
        const freshContent = 'fresh-installer-bytes';
        final correctSha = sha256Of(freshContent);

        int getCallCount = 0;
        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'GET') {
              getCallCount++;
              return http.Response(freshContent, 200);
            }
            // HEAD for disk-space check: no content-length to keep it simple.
            return http.Response('', 200);
          }),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_cache_');
        try {
          // Write a stale file whose hash does NOT match the manifest.
          final filename = 'app-1.0.0.tar.gz';
          final staleFile = File('${destDir.path}/$filename');
          await staleFile.writeAsString(staleContent);

          final result = await service.download(
            manifest: makeManifest(sha256: correctSha),
            destDir: destDir,
          );

          expect(result.isSuccess, isTrue);
          expect(getCallCount, 1, reason: 'One fresh GET should have been issued');
          // The file should contain the freshly downloaded content.
          expect(await File(result.filePath!).readAsString(), freshContent);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'proceeds with fresh download when no cached file exists',
      () async {
        const content = 'brand-new-download';
        int getCallCount = 0;

        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'GET') {
              getCallCount++;
              return http.Response(content, 200);
            }
            return http.Response('', 200);
          }),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_cache_');
        try {
          // destDir is empty — no cached file present.
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
          );

          expect(result.isSuccess, isTrue);
          expect(getCallCount, 1);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'cache hit is case-insensitive: uppercase manifest sha256 matches computed lowercase',
      () async {
        const content = 'case-sensitive-check';
        final upperSha = sha256Of(content).toUpperCase();

        final service = UpdateDownloadService(
          client: MockClient((_) async {
            throw StateError('No network call expected on a cache hit');
          }),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_cache_');
        try {
          final filename = 'app-1.0.0.tar.gz';
          await File('${destDir.path}/$filename').writeAsString(content);

          final result = await service.download(
            manifest: makeManifest(sha256: upperSha),
            destDir: destDir,
          );

          expect(result.isSuccess, isTrue,
              reason: 'uppercase manifest sha256 should match computed lowercase');
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });


  // -------------------------------------------------------------------------
  // UpdateDownloadService — progress callback (UPDATE-006)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — progress callback', () {
    test(
      'onProgress is invoked with increasing values when Content-Length is known',
      () async {
        const content = 'progress-test-payload';
        final contentBytes = utf8.encode(content);
        final correctSha256 = sha256Of(content);

        final progressValues = <double>[];

        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') {
              return http.Response(
                '',
                200,
                headers: {'content-length': '${contentBytes.length}'},
              );
            }
            return http.Response(content, 200);
          }),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_progress_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: correctSha256),
            destDir: destDir,
            onProgress: progressValues.add,
          );
          expect(result.isSuccess, isTrue);
          // At least one progress event should have been emitted.
          expect(progressValues, isNotEmpty);
          // All values must be in [0.0, 1.0].
          for (final v in progressValues) {
            expect(v, inInclusiveRange(0.0, 1.0));
          }
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'onProgress is NOT called when Content-Length is unavailable',
      () async {
        const content = 'no-length-payload';
        final progressValues = <double>[];

        // Use a custom client that explicitly returns a StreamedResponse
        // with contentLength: null — MockClient auto-populates content length
        // from body bytes, which doesn't simulate a server that omits the
        // header.
        final service = UpdateDownloadService(
          client: _NullContentLengthClient(content: content),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_progress_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
            onProgress: progressValues.add,
          );
          expect(result.isSuccess, isTrue);
          // Without Content-Length the service cannot compute progress.
          expect(progressValues, isEmpty);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — pause and resume (FEAT-006)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — pause mid-download (FEAT-006)', () {
    test(
      'returns paused result when PauseToken is signalled before first chunk',
      () async {
        const content = 'chunk-one-data';
        final pauseToken = PauseToken()..pause(); // pre-paused

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_pause_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
            pauseToken: pauseToken,
          );
          expect(result.isPaused, isTrue,
              reason: 'A pre-paused token must produce a paused result');
          expect(result.isSuccess, isFalse);
          expect(result.isError, isFalse);
          expect(result.filePath, isNotNull);
          expect(result.bytesReceived, isNotNull);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'partial file is kept on disk when download is paused',
      () async {
        const content = 'kept-on-disk-bytes';
        final pauseToken = PauseToken()..pause();

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_pause_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
            pauseToken: pauseToken,
          );

          expect(result.isPaused, isTrue);
          // The partial file must still exist — the service must NOT delete it.
          final partialFile = File(result.filePath!);
          expect(await partialFile.exists(), isTrue,
              reason: 'Partial file must be kept on disk for resume');
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'partialFilePath is a convenience alias for filePath when paused',
      () async {
        const content = 'alias-test';
        final pauseToken = PauseToken()..pause();

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_pause_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
            pauseToken: pauseToken,
          );

          expect(result.isPaused, isTrue);
          expect(result.partialFilePath, equals(result.filePath),
              reason: 'partialFilePath must be the same path as filePath when paused');
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'bytesReceived is non-negative when download is paused',
      () async {
        const content = 'bytes-received-test';
        final pauseToken = PauseToken()..pause();

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_pause_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
            pauseToken: pauseToken,
          );

          expect(result.isPaused, isTrue);
          expect(result.bytesReceived, isNotNull);
          expect(result.bytesReceived, greaterThanOrEqualTo(0));
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'PauseToken.isPaused reflects pause/resume state correctly',
      () {
        final token = PauseToken();
        expect(token.isPaused, isFalse);
        token.pause();
        expect(token.isPaused, isTrue);
        token.resume();
        expect(token.isPaused, isFalse);
      },
    );

    test(
      'paused result toString contains paused and path',
      () async {
        const content = 'tostring-check';
        final pauseToken = PauseToken()..pause();
        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );
        final destDir = await Directory.systemTemp.createTemp('uds_pause_');
        try {
          final result = await service.download(
            manifest: makeManifest(sha256: sha256Of(content)),
            destDir: destDir,
            pauseToken: pauseToken,
          );
          expect(result.isPaused, isTrue);
          expect(result.toString(), contains('paused'));
          expect(result.toString(), contains(result.filePath!));
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — resume (FEAT-006)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — resume paused download (FEAT-006)', () {
    test(
      'resume() completes the download and returns success',
      () async {
        // Simulate a mid-stream pause by writing the first half to disk
        // manually — this is what the service does when PauseToken fires mid-
        // stream.  The pre-pause approach produces an empty file because the
        // implementation checks pause *before* calling sink.add(), so
        // nothing is written.  Writing the partial file directly is the only
        // way to give resume() something real to resume from.
        const firstHalf = 'first-half-';
        const secondHalf = 'second-half';
        const fullContent = '$firstHalf$secondHalf';
        final correctSha = sha256Of(fullContent);
        final firstHalfBytes = utf8.encode(firstHalf);
        final secondHalfBytes = utf8.encode(secondHalf);
        final totalLength = firstHalfBytes.length + secondHalfBytes.length;

        final destDir = await Directory.systemTemp.createTemp('uds_resume_');
        try {
          // Write the "paused" partial file (first half already on disk).
          final partialFile = File('${destDir.path}/app-1.0.0.tar.gz');
          await partialFile.writeAsBytes(firstHalfBytes);
          expect(await partialFile.length(), firstHalfBytes.length);

          // Service only needs to handle the 206 range request for the
          // second half — no initial 200 GET is issued by resume().
          final service = UpdateDownloadService(
            client: _StreamedResponseClient(
              onRequest: (request) {
                // resume() issues a Range request for the second half.
                expect(request.headers['range'],
                    'bytes=${firstHalfBytes.length}-',
                    reason: 'Range header must start from existing file length');
                return http.StreamedResponse(
                  Stream.fromIterable([secondHalfBytes]),
                  206,
                  contentLength: secondHalfBytes.length,
                );
              },
            ),
          );

          final resumeResult = await service.resume(
            manifest: makeManifest(sha256: correctSha),
            partialFilePath: partialFile.path,
          );

          expect(resumeResult.isSuccess, isTrue,
              reason: 'Resume must complete successfully');
          expect(resumeResult.filePath, isNotNull);

          // The completed file must be the concatenation of both halves.
          final completedFile = File(resumeResult.filePath!);
          expect(await completedFile.exists(), isTrue);
          final bytes = await completedFile.readAsBytes();
          expect(bytes.length, totalLength,
              reason: 'Completed file must be exactly first-half + second-half');
          expect(utf8.decode(bytes), fullContent);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resume() falls back to full download when partial file is missing',
      () async {
        const content = 'full-fallback-content';
        final correctSha = sha256Of(content);
        int getCount = 0;

        final service = UpdateDownloadService(
          client: MockClient((request) async {
            if (request.method == 'HEAD') return http.Response('', 200);
            getCount++;
            return http.Response(content, 200);
          }),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_resume_');
        try {
          // Provide a path that does not exist on disk.
          final missingPath = '${destDir.path}/does_not_exist.apk';
          final result = await service.resume(
            manifest: makeManifest(sha256: correctSha),
            partialFilePath: missingPath,
          );

          expect(result.isSuccess, isTrue,
              reason: 'Should fall back to a full fresh download');
          expect(getCount, 1, reason: 'Exactly one fresh GET should be issued');
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resume() returns downloadError when server responds 200 instead of 206 (no range support)',
      () async {
        const content = 'no-range-content';
        final correctSha = sha256Of(content);

        // Write a partial file to give resume() something to work with.
        final destDir = await Directory.systemTemp.createTemp('uds_resume_');
        final partialFile = File('${destDir.path}/app-1.0.0.tar.gz');
        await partialFile.writeAsString('partial');

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response(content, 200)),
        );

        try {
          final result = await service.resume(
            manifest: makeManifest(sha256: correctSha),
            partialFilePath: partialFile.path,
          );

          expect(result.isError, isTrue,
              reason: 'A 200 response to a range request means no range support');
          expect(result.errorType, UpdateErrorType.downloadError);
          expect(result.error, contains('does not support resumable downloads'));
          // Partial file must be deleted when resume fails.
          expect(await partialFile.exists(), isFalse);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resume() returns success on 416 when partial file checksum already matches',
      () async {
        // 416 Range Not Satisfiable means the server thinks the range is past
        // the end — the file may already be complete.  If the checksum passes
        // the service should declare success without re-downloading.
        const content = 'already-complete';
        final correctSha = sha256Of(content);

        final destDir = await Directory.systemTemp.createTemp('uds_resume_');
        final completeFile = File('${destDir.path}/app-1.0.0.tar.gz');
        await completeFile.writeAsString(content);

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response('', 416)),
        );

        try {
          final result = await service.resume(
            manifest: makeManifest(sha256: correctSha),
            partialFilePath: completeFile.path,
          );

          expect(result.isSuccess, isTrue,
              reason: '416 + passing checksum = file already complete');
          expect(result.filePath, completeFile.path);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resume() is cancellable via CancelToken',
      () async {
        final cancelToken = CancelToken()..cancel(); // pre-cancelled

        // The SHA of what a complete file would look like.  The download is
        // cancelled before the checksum is ever evaluated, so any valid-format
        // string suffices; we use the natural concatenation of the partial
        // content and the remaining chunk so the value is at least plausible.
        final correctSha = sha256Of('partial-bytesremaining');

        // Write a small partial file.
        final destDir = await Directory.systemTemp.createTemp('uds_resume_');
        final partialFile = File('${destDir.path}/app-1.0.0.tar.gz');
        await partialFile.writeAsString('partial-bytes');

        final service = UpdateDownloadService(
          client: _StreamedResponseClient(
            onRequest: (_) => http.StreamedResponse(
              Stream.fromIterable([utf8.encode('remaining')]),
              206,
              contentLength: utf8.encode('remaining').length,
            ),
          ),
        );
        try {
          final result = await service.resume(
            manifest: makeManifest(sha256: correctSha),
            partialFilePath: partialFile.path,
            cancelToken: cancelToken,
          );

          // A pre-cancelled token must stop the download on the first chunk.
          // The result is either a failure(downloadCancelled) or a paused
          // result — either way it must not be success.
          expect(result.isSuccess, isFalse,
              reason: 'Pre-cancelled token must prevent a successful resume');
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resume() progress accounts for already-downloaded bytes',
      () async {
        // The progress fraction must never start from 0% when resuming.
        // With existingLength bytes already on disk and the 206 Content-Length
        // reporting the remainder, the very first chunk must produce a
        // progress value > 0.
        const existingContent = 'existing-'; // 9 bytes on disk
        const remainingContent = 'remaining'; // 9 bytes from server
        const fullContent = '$existingContent$remainingContent';
        final correctSha = sha256Of(fullContent);
        // totalLength is the expected denominator for progress calculations.
        // The final progress value must equal 1.0 once the full file is on disk.
        final totalLength = utf8.encode(fullContent).length;

        final progressValues = <double>[];
        final destDir = await Directory.systemTemp.createTemp('uds_resume_');
        final partialFile = File('${destDir.path}/app-1.0.0.tar.gz');
        await partialFile.writeAsString(existingContent);

        final service = UpdateDownloadService(
          client: _StreamedResponseClient(
            onRequest: (_) => http.StreamedResponse(
              Stream.fromIterable([utf8.encode(remainingContent)]),
              206,
              contentLength: utf8.encode(remainingContent).length,
            ),
          ),
        );

        try {
          final result = await service.resume(
            manifest: makeManifest(sha256: correctSha),
            partialFilePath: partialFile.path,
            onProgress: progressValues.add,
          );

          expect(result.isSuccess, isTrue);
          expect(progressValues, isNotEmpty,
              reason: 'At least one progress event must be emitted');

          // The final progress value must be 1.0 — the full file is on disk.
          expect(
            progressValues.last,
            closeTo(1.0, 0.001),
            reason:
                'Final progress must be 1.0 once all $totalLength bytes are received',
          );

          // Every progress value must be > 0 because existingLength > 0.
          for (final v in progressValues) {
            expect(
              v,
              greaterThan(0.0),
              reason:
                  'Progress must account for already-downloaded bytes; '
                  'starting from 0 would mislead the user',
            );
            expect(v, inInclusiveRange(0.0, 1.0));
          }
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadService — resumeFile (FEAT-007)
  // -------------------------------------------------------------------------

  group('UpdateDownloadService — resumeFile crash-recovery (FEAT-007)', () {
    test(
      'resumeFile() succeeds when partial file is valid and server supports 206',
      () async {
        const existing = 'crash-recovery-part1-';
        const remaining = 'part2-complete';
        const full = '$existing$remaining';
        final correctSha = sha256Of(full);

        final destDir = await Directory.systemTemp.createTemp('uds_resumefile_');
        final partialFile = File('${destDir.path}/crash_partial.apk');
        await partialFile.writeAsString(existing);

        final service = UpdateDownloadService(
          client: _StreamedResponseClient(
            onRequest: (_) => http.StreamedResponse(
              Stream.fromIterable([utf8.encode(remaining)]),
              206,
              contentLength: utf8.encode(remaining).length,
            ),
          ),
        );

        try {
          final result = await service.resumeFile(
            downloadUrl: 'https://example.com/app.apk',
            partialFilePath: partialFile.path,
            expectedSha256: correctSha,
          );

          expect(result.isSuccess, isTrue,
              reason: 'resumeFile must complete successfully from the partial file');
          expect(result.filePath, isNotNull);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resumeFile() returns error (not crash) when partial file does not exist',
      () async {
        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response('data', 200)),
        );

        final destDir = await Directory.systemTemp.createTemp('uds_resumefile_');
        try {
          final result = await service.resumeFile(
            downloadUrl: 'https://example.com/app.apk',
            partialFilePath: '${destDir.path}/nonexistent.apk',
            expectedSha256: 'a' * 64,
          );

          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.downloadError);
          expect(result.error, contains('no longer exists'));
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resumeFile() returns success immediately when partial file is already complete',
      () async {
        const fullContent = 'already-fully-downloaded';
        final correctSha = sha256Of(fullContent);

        final destDir = await Directory.systemTemp.createTemp('uds_resumefile_');
        final completeFile = File('${destDir.path}/complete.apk');
        await completeFile.writeAsString(fullContent);

        // Client should never be called if checksum passes before range request.
        int callCount = 0;
        final service = UpdateDownloadService(
          client: MockClient((_) async {
            callCount++;
            return http.Response('should not reach here', 200);
          }),
        );

        try {
          final result = await service.resumeFile(
            downloadUrl: 'https://example.com/app.apk',
            partialFilePath: completeFile.path,
            expectedSha256: correctSha,
          );

          expect(result.isSuccess, isTrue,
              reason: 'Should fast-path to success if file is already complete');
          expect(callCount, 0,
              reason: 'No HTTP call should be made when the file is already verified');
          expect(result.filePath, completeFile.path);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resumeFile() returns downloadError when server responds 200 instead of 206',
      () async {
        final destDir = await Directory.systemTemp.createTemp('uds_resumefile_');
        final partialFile = File('${destDir.path}/partial.apk');
        await partialFile.writeAsString('partial');

        final service = UpdateDownloadService(
          client: MockClient((_) async => http.Response('full body', 200)),
        );

        try {
          final result = await service.resumeFile(
            downloadUrl: 'https://example.com/app.apk',
            partialFilePath: partialFile.path,
            expectedSha256: 'a' * 64,
          );

          expect(result.isError, isTrue);
          expect(result.errorType, UpdateErrorType.downloadError);
          expect(result.error, contains('does not support resumable downloads'));
          // Partial file and state record must be cleaned up.
          expect(await partialFile.exists(), isFalse);
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );

    test(
      'resumeFile() keeps partial file on isCancelledResumable result',
      () async {
        const existing = 'kept-partial-';
        const remaining = 'more';
        final destDir = await Directory.systemTemp.createTemp('uds_resumefile_');
        final partialFile = File('${destDir.path}/kept.apk');
        await partialFile.writeAsString(existing);

        final cancelToken = CancelToken()..cancel(); // pre-cancel

        final service = UpdateDownloadService(
          client: _StreamedResponseClient(
            onRequest: (_) => http.StreamedResponse(
              Stream.fromIterable([utf8.encode(remaining)]),
              206,
              contentLength: utf8.encode(remaining).length,
            ),
          ),
        );

        try {
          final result = await service.resumeFile(
            downloadUrl: 'https://example.com/app.apk',
            partialFilePath: partialFile.path,
            expectedSha256: sha256Of('$existing$remaining'),
            cancelToken: cancelToken,
          );

          // With keepOnCancel=true in resumeFile, a cancelled mid-resume
          // returns isCancelledResumable and keeps the partial file.
          expect(result.isCancelledResumable, isTrue,
              reason:
                  'Cancelling a resumeFile call must return isCancelledResumable '
                  'so StartupGateScreen can re-offer the dialog on next launch');
          expect(await partialFile.exists(), isTrue,
              reason:
                  'Partial file must be kept when cancel is resumable '
                  'so the user can retry on next launch');
        } finally {
          await destDir.delete(recursive: true);
        }
      },
    );
  });

  // -------------------------------------------------------------------------
  // UpdateDownloadResult — paused and cancelledResumable factories (FEAT-006/007)
  // -------------------------------------------------------------------------

  group('UpdateDownloadResult — FEAT-006/007 factories', () {
    test('paused() sets isPaused=true, filePath, bytesReceived', () {
      final result = UpdateDownloadResult.paused('/tmp/app.apk', bytesReceived: 1024);
      expect(result.isPaused, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isError, isFalse);
      expect(result.isCancelledResumable, isFalse);
      expect(result.filePath, '/tmp/app.apk');
      expect(result.partialFilePath, '/tmp/app.apk');
      expect(result.bytesReceived, 1024);
    });

    test('cancelledResumable() sets isCancelledResumable=true', () {
      final result = UpdateDownloadResult.cancelledResumable('/tmp/app.apk', bytesReceived: 512);
      expect(result.isCancelledResumable, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isError, isFalse);
      expect(result.isPaused, isFalse);
      expect(result.filePath, '/tmp/app.apk');
      expect(result.partialFilePath, '/tmp/app.apk');
      expect(result.bytesReceived, 512);
    });

    test('partialFilePath is null when result is success', () {
      final result = UpdateDownloadResult.success('/tmp/app.apk');
      expect(result.partialFilePath, isNull);
    });

    test('partialFilePath is null when result is failure', () {
      final result = UpdateDownloadResult.failure('oops');
      expect(result.partialFilePath, isNull);
    });

    test('cancelledResumable toString includes correct labels', () {
      final result = UpdateDownloadResult.cancelledResumable('/path/to/file', bytesReceived: 256);
      expect(result.toString(), contains('cancelledResumable'));
      expect(result.toString(), contains('/path/to/file'));
    });
  });
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// A fake [http.Client] that returns a [http.StreamedResponse] with
/// [contentLength] explicitly set to `null` for all non-HEAD requests.
///
/// This simulates real-world servers that omit the `Content-Length` header,
/// which [MockClient] cannot replicate because it auto-computes content-length
/// from the response body bytes.
class _NullContentLengthClient extends http.BaseClient {
  _NullContentLengthClient({required this.content});

  final String content;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method == 'HEAD') {
      // HEAD: return 200 with no content-length so the disk-space check
      // is skipped (fail-open).
      return http.StreamedResponse(
        const Stream.empty(),
        200,
        contentLength: null,
      );
    }
    // GET: return the body as a stream with contentLength explicitly null.
    return http.StreamedResponse(
      Stream.fromIterable([utf8.encode(content)]),
      200,
      contentLength: null, // ← key: forces progress to be indeterminate
    );
  }
}

// ---------------------------------------------------------------------------
// _StreamedResponseClient
// ---------------------------------------------------------------------------

/// A fake [http.Client] that returns whatever [http.StreamedResponse] the
/// [onRequest] callback produces.
///
/// [MockClient] only accepts callbacks that return [Future<http.Response>], so
/// it cannot produce a [http.StreamedResponse] directly.  Tests that need to
/// simulate 206 Partial Content responses (which carry a content-range header
/// and a streamed body) must use this client instead.
class _StreamedResponseClient extends http.BaseClient {
  _StreamedResponseClient({required this.onRequest});

  /// Called for every request.  Return the [http.StreamedResponse] to send
  /// back to the caller.  The callback is synchronous so that test bodies
  /// can use simple closures without async overhead.
  final http.StreamedResponse Function(http.BaseRequest request) onRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      onRequest(request);
}
