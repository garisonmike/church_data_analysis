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
}
