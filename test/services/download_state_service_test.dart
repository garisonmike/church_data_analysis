import 'package:church_analytics/services/download_state_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Ensure a clean SharedPreferences store for every test so that one test's
  // state cannot bleed into the next.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // =========================================================================
  // DownloadStateRecord — JSON round-trip
  // =========================================================================

  group('DownloadStateRecord — JSON serialisation', () {
    test('toJson / fromJson round-trips all fields correctly', () {
      final original = DownloadStateRecord(
        url: 'https://example.com/app-release.apk',
        destPath: '/data/user/0/com.example/cache/app-release.apk',
        sha256: 'a' * 64,
        startedAt: DateTime.utc(2026, 5, 12, 13, 0, 0),
      );

      final json = original.toJson();
      final restored = DownloadStateRecord.fromJson(json);

      expect(restored.url, original.url);
      expect(restored.destPath, original.destPath);
      expect(restored.sha256, original.sha256);
      expect(
        restored.startedAt.toUtc().toIso8601String(),
        original.startedAt.toUtc().toIso8601String(),
      );
    });

    test('fromJson parses ISO 8601 UTC timestamp without loss', () {
      final json = {
        'url': 'https://example.com/app.apk',
        'dest_path': '/tmp/app.apk',
        'sha256': 'b' * 64,
        'started_at': '2026-01-15T08:30:00.000Z',
      };

      final record = DownloadStateRecord.fromJson(json);

      expect(record.startedAt.year, 2026);
      expect(record.startedAt.month, 1);
      expect(record.startedAt.day, 15);
      expect(record.startedAt.hour, 8);
      expect(record.startedAt.minute, 30);
      expect(record.startedAt.isUtc, isTrue);
    });
  });

  // =========================================================================
  // DownloadStateService — persist
  // =========================================================================

  group('DownloadStateService.persist()', () {
    test('stores a record that read() can subsequently retrieve', () async {
      await DownloadStateService.persist(
        url: 'https://example.com/app.apk',
        destPath: '/tmp/app.apk',
        sha256: 'c' * 64,
      );

      final record = await DownloadStateService.read();

      expect(record, isNotNull);
      expect(record!.url, 'https://example.com/app.apk');
      expect(record.destPath, '/tmp/app.apk');
      expect(record.sha256, 'c' * 64);
    });

    test('startedAt is set to a recent UTC time', () async {
      final before = DateTime.now().toUtc();

      await DownloadStateService.persist(
        url: 'https://example.com/app.apk',
        destPath: '/tmp/app.apk',
        sha256: 'd' * 64,
      );

      final after = DateTime.now().toUtc();
      final record = await DownloadStateService.read();

      expect(record, isNotNull);
      final startedAt = record!.startedAt;
      expect(
        startedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        startedAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('overwrites a previous record when called a second time', () async {
      await DownloadStateService.persist(
        url: 'https://example.com/first.apk',
        destPath: '/tmp/first.apk',
        sha256: 'e' * 64,
      );

      await DownloadStateService.persist(
        url: 'https://example.com/second.apk',
        destPath: '/tmp/second.apk',
        sha256: 'f' * 64,
      );

      final record = await DownloadStateService.read();

      expect(record, isNotNull);
      expect(record!.url, contains('second'),
          reason: 'Second persist must overwrite the first');
    });
  });

  // =========================================================================
  // DownloadStateService — read
  // =========================================================================

  group('DownloadStateService.read()', () {
    test('returns null when no record has been persisted', () async {
      final record = await DownloadStateService.read();
      expect(record, isNull);
    });

    test('returns null (not throw) when SharedPreferences contains corrupt JSON',
        () async {
      // Manually inject invalid JSON to simulate a corrupt store.
      SharedPreferences.setMockInitialValues({
        'active_download_state': '{not valid json!!!',
      });

      final record = await DownloadStateService.read();
      // Must fail-open: return null, never throw.
      expect(record, isNull);
    });

    test('returns null (not throw) when stored value has missing fields',
        () async {
      SharedPreferences.setMockInitialValues({
        'active_download_state': '{"url": "https://example.com/app.apk"}',
      });

      final record = await DownloadStateService.read();
      expect(record, isNull,
          reason: 'A record with missing required fields must be treated as absent');
    });
  });

  // =========================================================================
  // DownloadStateService — clear
  // =========================================================================

  group('DownloadStateService.clear()', () {
    test('removes the record so that subsequent read() returns null', () async {
      await DownloadStateService.persist(
        url: 'https://example.com/app.apk',
        destPath: '/tmp/app.apk',
        sha256: 'g' * 64,
      );

      // Confirm it was stored.
      expect(await DownloadStateService.read(), isNotNull);

      await DownloadStateService.clear();

      expect(await DownloadStateService.read(), isNull,
          reason: 'clear() must remove the record');
    });

    test('clear() on an empty store does not throw', () async {
      // No prior persist — calling clear() must be a safe no-op.
      await expectLater(DownloadStateService.clear(), completes);
    });

    test('clear() followed by a new persist leaves the new record readable',
        () async {
      await DownloadStateService.persist(
        url: 'https://example.com/old.apk',
        destPath: '/tmp/old.apk',
        sha256: 'h' * 64,
      );

      await DownloadStateService.clear();

      await DownloadStateService.persist(
        url: 'https://example.com/new.apk',
        destPath: '/tmp/new.apk',
        sha256: 'i' * 64,
      );

      final record = await DownloadStateService.read();

      expect(record, isNotNull);
      expect(record!.url, contains('new'));
    });
  });

  // =========================================================================
  // FEAT-007: Lifecycle contract — the invariant that matters for crash recovery
  // =========================================================================
  //
  // The crash-recovery guarantee depends on a strict ordering:
  //   1. persist() is called BEFORE any bytes are written to disk.
  //   2. clear() is called ONLY on terminal outcomes (success, error, cancel).
  //   3. A voluntary pause (FEAT-006) does NOT call clear() — the record
  //      survives so StartupGateScreen can detect the partial file on next launch.
  //
  // These tests document and verify the observable contract at the service level.

  group('FEAT-007 — crash-recovery lifecycle contract', () {
    test(
      'read() returns non-null after persist() and before clear() — simulates in-flight download',
      () async {
        // Persist signals "download in progress".
        await DownloadStateService.persist(
          url: 'https://example.com/in-flight.apk',
          destPath: '/tmp/in-flight.apk',
          sha256: 'j' * 64,
        );

        // Without clear() the record is still present (the crash-recovery path).
        final record = await DownloadStateService.read();

        expect(record, isNotNull,
            reason:
                'A record persisted before streaming must survive until clear() '
                'is called — if the app crashes between persist() and clear(), '
                'the next launch can detect the partial file');
      },
    );

    test(
      'read() returns null after persist() + clear() — simulates successful completion',
      () async {
        await DownloadStateService.persist(
          url: 'https://example.com/complete.apk',
          destPath: '/tmp/complete.apk',
          sha256: 'k' * 64,
        );

        // clear() is called on success — next launch sees no interrupted download.
        await DownloadStateService.clear();

        expect(await DownloadStateService.read(), isNull,
            reason:
                'clear() after a successful download must leave no record, '
                'so the next launch does not show a spurious resume dialog');
      },
    );

    test(
      'read() returns non-null after persist() without clear() — simulates paused download surviving to next launch',
      () async {
        await DownloadStateService.persist(
          url: 'https://example.com/paused.apk',
          destPath: '/tmp/paused.apk',
          sha256: 'l' * 64,
        );

        // Intentionally do NOT call clear() — a paused download keeps the record
        // so that StartupGateScreen offers "Resume or Discard?" on next launch.

        // Simulate the app being relaunched by reading from a fresh instance.
        final record = await DownloadStateService.read();

        expect(record, isNotNull,
            reason:
                'A paused download must keep the record so that the next '
                'app launch can detect it and offer resume to the user');
        expect(record!.destPath, '/tmp/paused.apk');
      },
    );

    test(
      'record fields are fully preserved across a persist/read cycle',
      () async {
        const testUrl = 'https://github.com/org/repo/releases/download/v1.2.3/app.apk';
        const testPath = '/data/user/0/com.church/cache/app.apk';
        const testSha = 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';

        await DownloadStateService.persist(
          url: testUrl,
          destPath: testPath,
          sha256: testSha,
        );

        final record = await DownloadStateService.read();

        expect(record, isNotNull);
        expect(record!.url, testUrl);
        expect(record.destPath, testPath);
        expect(record.sha256, testSha);
        // startedAt must be a recent UTC time (set by persist).
        expect(
          record.startedAt.difference(DateTime.now().toUtc()).abs(),
          lessThan(const Duration(seconds: 5)),
        );
      },
    );
  });
}
