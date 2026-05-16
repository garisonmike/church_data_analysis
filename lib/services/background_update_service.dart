import 'package:church_analytics/services/update_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // FEAT-018
import 'package:flutter/foundation.dart'; // FEAT-018 (debugPrint)
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
// FEAT-018: Connectivity helper
// ---------------------------------------------------------------------------

/// Returns `true` when the device has at least one active network interface.
///
/// Uses `connectivity_plus` v6+ which returns a [List<ConnectivityResult>].
/// The device is considered online if any result is not [ConnectivityResult.none].
///
/// This is a best-effort check only: a race where the device goes offline
/// between this call and the subsequent HTTP call is benign — the HTTP call
/// will throw a [SocketException] that the existing error handler already
/// catches.  The check exists purely to avoid unnecessary network attempts
/// and misleading UI states when the device is known to be offline.
Future<bool> _isConnected() async {
  final results = await Connectivity().checkConnectivity();
  return results.any((r) => r != ConnectivityResult.none);
}

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
  BackgroundUpdateService(this._prefs, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

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
/// - `null`   — cooldown has not elapsed, or device is offline; no network
///              call was made.
/// - non-null — an [UpdateCheckResult] from a fresh network check.
///
/// ## FEAT-018: Connectivity guard
/// If the device is offline when this provider runs, it returns `null`
/// **without** updating the `lastChecked` timestamp.  This preserves the
/// user's daily check window: an offline launch does not consume the 24-hour
/// slot.
///
/// ## FEAT-018: Trigger points
/// This provider is consumed in two ways:
///
/// 1. **Launch trigger** — read fire-and-forget in
///    [StartupGateScreen._routeFromState] immediately after the dashboard
///    route is pushed.
///
/// 2. **Connectivity-restore trigger** — [backgroundUpdateCheckProvider] is
///    invalidated and re-read whenever [ChurchAnalyticsApp] detects that
///    connectivity has been restored (see `main.dart`).
///
/// Both callers use `ref.invalidate` + `ref.read(...future)` or a direct
/// `unawaited(ref.read(...future))` after invalidation so that the provider
/// re-runs rather than returning a cached value.
///
/// This provider is intended for fire-and-forget consumption.  It never
/// throws.
final backgroundUpdateCheckProvider = FutureProvider<UpdateCheckResult?>((
  ref,
) async {
  final bgService = ref.read(backgroundUpdateServiceProvider);

  // Cooldown gate — unchanged from original implementation.
  if (!bgService.shouldCheck()) return null;

  // FEAT-018: Connectivity pre-check.
  // Skip without consuming the cooldown so that an offline launch does not
  // push the next real check 24 hours into the future.
  if (!await _isConnected()) {
    debugPrint('[BackgroundUpdateService] Skipping update check — no connectivity');
    return null;
  }

  // Perform the network check.  Reset the in-memory session cache first so
  // that this background check always makes a real HTTP request rather than
  // returning a cached result from a prior manual or launch-triggered check.
  //
  // Without this reset, UpdateService.checkForUpdate() short-circuits at
  // line 190 (`if (_cachedResult != null) return _cachedResult!`) and returns
  // immediately without fetching.  recordCheck() then fires at the line below,
  // burning the 24-hour cooldown window against what was effectively a no-op
  // network call — violating the FEAT-018 invariant that lastChecked is only
  // updated when the HTTP call actually fires.
  ref.read(updateServiceProvider).resetCache();
  final result = await ref.read(updateServiceProvider).checkForUpdate();

  // Record the check time so the cooldown resets regardless of outcome.
  // This is only reached when the HTTP call actually fired.
  await bgService.recordCheck();

  return result;
});
