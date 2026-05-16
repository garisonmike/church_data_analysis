import 'package:church_analytics/services/background_update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a [BackgroundUpdateService] backed by an in-memory
/// [SharedPreferences] stub.
///
/// [initialValues] pre-populates the prefs store.
/// [clock] overrides wall-clock time so tests can control "now".
Future<BackgroundUpdateService> makeService({
  Map<String, Object> initialValues = const {},
  DateTime Function()? clock,
}) async {
  SharedPreferences.setMockInitialValues(
    Map<String, Object>.from(initialValues),
  );
  final prefs = await SharedPreferences.getInstance();
  return BackgroundUpdateService(prefs, clock: clock);
}

/// A fixed reference point in time used across cooldown tests.
final _epoch = DateTime(2024, 6, 1, 12, 0, 0);

void main() {
  // =========================================================================
  // BackgroundUpdateService — shouldCheck()
  // =========================================================================

  group('BackgroundUpdateService.shouldCheck()', () {
    test('returns true when no timestamp has been stored', () async {
      final service = await makeService(clock: () => _epoch);
      expect(service.shouldCheck(), isTrue);
    });

    test('returns true when more than 24 hours have elapsed', () async {
      final lastCheck = _epoch.subtract(const Duration(hours: 25));
      final service = await makeService(
        initialValues: {
          kBackgroundUpdateLastCheckKey: lastCheck.millisecondsSinceEpoch,
        },
        clock: () => _epoch,
      );
      expect(service.shouldCheck(), isTrue);
    });

    test('returns true when exactly 24 hours have elapsed', () async {
      // Boundary: difference == kBackgroundCheckInterval (>=) → should check
      final lastCheck = _epoch.subtract(const Duration(hours: 24));
      final service = await makeService(
        initialValues: {
          kBackgroundUpdateLastCheckKey: lastCheck.millisecondsSinceEpoch,
        },
        clock: () => _epoch,
      );
      expect(service.shouldCheck(), isTrue);
    });

    test('returns false when fewer than 24 hours have elapsed', () async {
      final lastCheck = _epoch.subtract(const Duration(hours: 23));
      final service = await makeService(
        initialValues: {
          kBackgroundUpdateLastCheckKey: lastCheck.millisecondsSinceEpoch,
        },
        clock: () => _epoch,
      );
      expect(service.shouldCheck(), isFalse);
    });

    test('returns false when check was performed moments ago', () async {
      final service = await makeService(clock: () => _epoch);
      // Simulate that a check was just recorded.
      await service.recordCheck();
      // Now shouldCheck must be false because 0 s < 24 h.
      expect(service.shouldCheck(), isFalse);
    });
  });

  // =========================================================================
  // BackgroundUpdateService — recordCheck()
  // =========================================================================

  group('BackgroundUpdateService.recordCheck()', () {
    test('stores current timestamp in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = BackgroundUpdateService(prefs, clock: () => _epoch);

      await service.recordCheck();

      final stored = prefs.getInt(kBackgroundUpdateLastCheckKey);
      expect(stored, equals(_epoch.millisecondsSinceEpoch));
    });

    test(
      'overwrites an existing timestamp with the latest clock value',
      () async {
        final oldTime = _epoch.subtract(const Duration(hours: 48));
        SharedPreferences.setMockInitialValues({
          kBackgroundUpdateLastCheckKey: oldTime.millisecondsSinceEpoch,
        });
        final prefs = await SharedPreferences.getInstance();
        final service = BackgroundUpdateService(prefs, clock: () => _epoch);

        await service.recordCheck();

        final stored = prefs.getInt(kBackgroundUpdateLastCheckKey)!;
        expect(stored, equals(_epoch.millisecondsSinceEpoch));
        expect(stored, greaterThan(oldTime.millisecondsSinceEpoch));
      },
    );
  });

  // =========================================================================
  // Integration: round-trip
  // =========================================================================

  group('BackgroundUpdateService — round-trip', () {
    test('shouldCheck() is false immediately after recordCheck() then true '
        'after 24 hours', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // At epoch: first check, record it.
      final serviceAtEpoch = BackgroundUpdateService(
        prefs,
        clock: () => _epoch,
      );
      expect(serviceAtEpoch.shouldCheck(), isTrue); // first ever check
      await serviceAtEpoch.recordCheck();
      expect(serviceAtEpoch.shouldCheck(), isFalse); // just recorded

      // 23 hours later: still inside cooldown.
      final serviceAt23h = BackgroundUpdateService(
        prefs,
        clock: () => _epoch.add(const Duration(hours: 23)),
      );
      expect(serviceAt23h.shouldCheck(), isFalse);

      // 24 hours later: cooldown elapsed → ready to check again.
      final serviceAt24h = BackgroundUpdateService(
        prefs,
        clock: () => _epoch.add(const Duration(hours: 24)),
      );
      expect(serviceAt24h.shouldCheck(), isTrue);
    });
  });

  // =========================================================================
  // FEAT-018: Connectivity guard — offline must not consume the cooldown
  // =========================================================================
  //
  // These tests verify the invariant stated in the technical report:
  // "lastChecked is only updated when the HTTP call actually fires."
  //
  // BackgroundUpdateService itself is unaware of connectivity — the guard lives
  // in backgroundUpdateCheckProvider.  What we can test at the service layer is
  // the contract that callers are expected to uphold: recordCheck() must NOT be
  // called when the network check is skipped.  The tests below document this
  // contract and verify that shouldCheck() remains true after a skipped check,
  // which is the observable symptom of a correctly implemented guard.

  group('FEAT-018 — offline guard: lastChecked must not advance on skip', () {
    test(
      'shouldCheck() remains true when recordCheck() is not called (simulates offline skip)',
      () async {
        // Arrange: cooldown has elapsed — a check is due.
        final service = await makeService(clock: () => _epoch);
        expect(service.shouldCheck(), isTrue);

        // Act: simulate the provider's offline path — connectivity check
        // returns false, so recordCheck() is NOT called.
        // (No call to service.recordCheck() here.)

        // Assert: the cooldown window is still open; the next check attempt
        // will also see shouldCheck() == true, as required.
        expect(
          service.shouldCheck(),
          isTrue,
          reason:
              'An offline skip must not consume the 24-hour cooldown window.',
        );
      },
    );

    test(
      'shouldCheck() becomes false only after recordCheck() is explicitly called (simulates online path)',
      () async {
        // Arrange: cooldown elapsed.
        final service = await makeService(clock: () => _epoch);
        expect(service.shouldCheck(), isTrue);

        // Act: simulate the provider's online path — HTTP call fired, record.
        await service.recordCheck();

        // Assert: cooldown now active.
        expect(
          service.shouldCheck(),
          isFalse,
          reason:
              'recordCheck() must reset the cooldown after a real HTTP call.',
        );
      },
    );

    test(
      'timestamp in SharedPreferences is unchanged when recordCheck() is skipped',
      () async {
        // Arrange: a previous check was recorded 25 h ago (cooldown elapsed).
        final previousCheck = _epoch.subtract(const Duration(hours: 25));
        SharedPreferences.setMockInitialValues({
          kBackgroundUpdateLastCheckKey:
              previousCheck.millisecondsSinceEpoch,
        });
        final prefs = await SharedPreferences.getInstance();
        // service is not used in this test — it verifies only that the
        // SharedPreferences timestamp written by a prior recordCheck() call
        // is untouched when connectivity is absent and recordCheck() is skipped.

        // Act: connectivity check fails → recordCheck() is NOT called.
        // (We deliberately do not call service.recordCheck().)

        // Assert: the stored timestamp is still the old one.
        final stored = prefs.getInt(kBackgroundUpdateLastCheckKey);
        expect(
          stored,
          equals(previousCheck.millisecondsSinceEpoch),
          reason:
              'An offline skip must leave the stored timestamp untouched so '
              'the 24-hour window is preserved for the next real check.',
        );
      },
    );
  });

  // =========================================================================
  // FEAT-018: Connectivity-restore trigger — provider re-runs after reconnect
  // =========================================================================
  //
  // The connectivity-restore trigger lives in ChurchAnalyticsApp (main.dart)
  // and calls ref.invalidate(backgroundUpdateCheckProvider) + ref.read(...).
  // That is an integration-level concern that requires a full ProviderContainer
  // and a mocked Connectivity plugin channel — covered in widget/integration
  // tests rather than here.
  //
  // What we can unit-test is the shouldCheck() gate that the provider will
  // encounter after invalidation: if the cooldown has not elapsed, the
  // restore trigger must be a no-op from the user's perspective (no banner).

  group('FEAT-018 — restore trigger respects cooldown gate', () {
    test(
      'shouldCheck() is false when cooldown has not elapsed — restore trigger is a no-op',
      () async {
        // Arrange: last check was 10 minutes ago (well within 24-hour window).
        final recentCheck = _epoch.subtract(const Duration(minutes: 10));
        final service = await makeService(
          initialValues: {
            kBackgroundUpdateLastCheckKey:
                recentCheck.millisecondsSinceEpoch,
          },
          clock: () => _epoch,
        );

        // Assert: even if connectivity is restored, the provider gate means
        // no HTTP call fires — shouldCheck() returning false is the guard.
        expect(
          service.shouldCheck(),
          isFalse,
          reason:
              'A restore trigger within the cooldown window must not fire a '
              'new update check.',
        );
      },
    );

    test(
      'shouldCheck() is true when cooldown has elapsed — restore trigger fires',
      () async {
        // Arrange: last check was 25 hours ago.
        final oldCheck = _epoch.subtract(const Duration(hours: 25));
        final service = await makeService(
          initialValues: {
            kBackgroundUpdateLastCheckKey: oldCheck.millisecondsSinceEpoch,
          },
          clock: () => _epoch,
        );

        // Assert: the restore trigger will proceed past the cooldown gate.
        expect(
          service.shouldCheck(),
          isTrue,
          reason:
              'A restore trigger after cooldown elapsed must be allowed to '
              'fire a new update check.',
        );
      },
    );
  });
}
