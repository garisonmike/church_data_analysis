import 'package:church_analytics/services/update_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// SharedPreferences key for the last background check timestamp (epoch ms).
const String kBackgroundUpdateLastCheckKey = 'background_update_last_check_ms';

/// Minimum gap between background update checks.
const Duration kBackgroundCheckInterval = Duration(hours: 24);

// ---------------------------------------------------------------------------
// BackgroundUpdateService
// ---------------------------------------------------------------------------

/// Manages the 24-hour cooldown for the background update check (UPDATE-013).
///
/// Uses [SharedPreferences] to persist the timestamp of the last check so that
/// the cooldown survives hot-restarts and cold starts.
///
/// ## Usage
/// ```dart
/// final service = ref.read(backgroundUpdateServiceProvider);
/// if (service.shouldCheck()) {
///   final result = await ref.read(updateServiceProvider).checkForUpdate();
///   await service.recordCheck();
///   // Use result…
/// }
/// ```
///
/// ## Testability
/// Inject a custom [clock] function to control time in unit tests without
/// waiting for real wall-clock time to elapse.
class BackgroundUpdateService {
  BackgroundUpdateService(
    this._prefs, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Returns `true` when a background check should be performed.
  ///
  /// This is the case when:
  /// - No check has ever been recorded, **or**
  /// - At least [kBackgroundCheckInterval] (24 hours) has elapsed since
  ///   the last recorded check.
  bool shouldCheck() {
    final lastMs = _prefs.getInt(kBackgroundUpdateLastCheckKey);
    if (lastMs == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    return _clock().difference(last) >= kBackgroundCheckInterval;
  }

  /// Records the current time as the timestamp of the most recent background
  /// check.  Call this after a successful check has been performed to reset
  /// the 24-hour cooldown.
  Future<void> recordCheck() async {
    await _prefs.setInt(
      kBackgroundUpdateLastCheckKey,
      _clock().millisecondsSinceEpoch,
    );
  }
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

/// Provides the [BackgroundUpdateService] singleton, wired to the
/// application-wide [sharedPreferencesProvider].
final backgroundUpdateServiceProvider = Provider<BackgroundUpdateService>((
  ref,
) {
  final prefs = ref.read(sharedPreferencesProvider);
  return BackgroundUpdateService(prefs);
});

/// Silently checks for an available update at most once per 24 hours
/// (AC1 — UPDATE-013).
///
/// Returns:
/// - `null`   — cooldown has not elapsed; no network call was made.
/// - non-null — an [UpdateCheckResult] from a fresh network check.
///
/// This provider is intended for fire-and-forget consumption in
/// [initState] / `WidgetsBinding.addPostFrameCallback`.  It never throws.
final backgroundUpdateCheckProvider = FutureProvider<UpdateCheckResult?>((
  ref,
) async {
  final bgService = ref.read(backgroundUpdateServiceProvider);
  if (!bgService.shouldCheck()) return null;

  // Perform the network check.  UpdateService already handles all error paths
  // and never throws, so the result is always a valid UpdateCheckResult.
  final result = await ref.read(updateServiceProvider).checkForUpdate();

  // Record the check time so the cooldown resets regardless of outcome.
  await bgService.recordCheck();

  return result;
});
