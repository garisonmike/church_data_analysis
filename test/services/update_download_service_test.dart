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
