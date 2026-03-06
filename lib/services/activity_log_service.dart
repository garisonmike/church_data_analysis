import 'dart:convert';

import 'package:church_analytics/models/activity_log_entry.dart';
import 'package:church_analytics/services/settings_service.dart'
    show sharedPreferencesProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

/// Service interface for recording timestamped export, import, and
/// installer-launch operations.
///
/// The production implementation is [SharedPreferencesActivityLogService].
/// [NoOpActivityLogService] is a silent stub for use in tests or contexts
/// where persistence is not required.
abstract class ActivityLogService {
  /// Records the result of an export operation.
  void logExport({
    required String filename,
    required String? path,
    required bool success,
    String? error,
  });

  /// Records the result of an import (file-pick + read) operation.
  void logImport({
    required String filename,
    required bool success,
    String? error,
  });

  /// Records the result of an installer-launch attempt (UPDATE-011).
  ///
  /// [platform] is the current platform identifier (e.g. `'android'`).
  /// [error] is the human-readable failure reason; `null` on success.
  void logInstallerLaunch({
    required bool success,
    String? platform,
    String? error,
  });
}

// ---------------------------------------------------------------------------
// No-op stub
// ---------------------------------------------------------------------------

/// Silent implementation of [ActivityLogService]; all methods are no-ops.
///
/// Used as the default in constructors that accept [ActivityLogService] as an
/// optional parameter, keeping callers that don't need logging unaffected.
class NoOpActivityLogService implements ActivityLogService {
  const NoOpActivityLogService();

  @override
  void logExport({
    required String filename,
    required String? path,
    required bool success,
    String? error,
  }) {}

  @override
  void logImport({
    required String filename,
    required bool success,
    String? error,
  }) {}

  @override
  void logInstallerLaunch({
    required bool success,
    String? platform,
    String? error,
  }) {}
}

// ---------------------------------------------------------------------------
// SharedPreferences-backed implementation (STORAGE-004)
// ---------------------------------------------------------------------------

/// Persists activity log entries to [SharedPreferences] under the key
/// [kLogKey] as a JSON-encoded list.
///
/// ### Capacity
/// A maximum of [kMaxEntries] (50) entries are retained.  When the limit is
/// exceeded the oldest entry is dropped (FIFO).
///
/// ### Reading
/// Call [getRecentEntries] to obtain the most-recent [count] entries in
/// reverse-chronological order (newest first).
///
/// ### Thread-safety
/// All reads and writes use the synchronous in-memory [SharedPreferences]
/// cache, so there is no race condition under single-isolate Flutter execution.
class SharedPreferencesActivityLogService implements ActivityLogService {
  /// [SharedPreferences] key under which the JSON log list is stored.
  static const String kLogKey = 'activity_log';

  /// Maximum number of retained entries.  Oldest entries are removed (FIFO)
  /// once this limit is exceeded.
  static const int kMaxEntries = 50;

  final SharedPreferences _prefs;

  SharedPreferencesActivityLogService(this._prefs);

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Returns up to [count] most-recent entries, newest first.
  ///
  /// Returns an empty list when no entries have been logged yet or when the
  /// persisted JSON is corrupt.
  List<ActivityLogEntry> getRecentEntries([int count = 10]) {
    final all = _loadEntries();
    final slice = all.length > count ? all.sublist(all.length - count) : all;
    return slice.reversed.toList();
  }

  // -------------------------------------------------------------------------
  // ActivityLogService implementation
  // -------------------------------------------------------------------------

  @override
  void logExport({
    required String filename,
    required String? path,
    required bool success,
    String? error,
  }) => _append(
    ActivityLogEntry.now(
      type: ActivityLogEntryType.export,
      filename: filename,
      path: path,
      success: success,
      message: error,
    ),
  );

  @override
  void logImport({
    required String filename,
    required bool success,
    String? error,
  }) => _append(
    ActivityLogEntry.now(
      type: ActivityLogEntryType.import,
      filename: filename,
      success: success,
      message: error,
    ),
  );

  @override
  void logInstallerLaunch({
    required bool success,
    String? platform,
    String? error,
  }) => _append(
    ActivityLogEntry.now(
      type: ActivityLogEntryType.installerLaunch,
      filename: platform ?? 'installer',
      success: success,
      message: error,
    ),
  );

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  /// Loads and decodes all stored entries.  Returns an empty list on any
  /// decode error rather than propagating the exception.
  List<ActivityLogEntry> _loadEntries() {
    final raw = _prefs.getString(kLogKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(ActivityLogEntry.fromJson)
          .toList();
    } catch (_) {
      // Corrupted data — start fresh rather than crashing.
      return [];
    }
  }

  /// Appends [entry] to the stored list and trims it to [kMaxEntries].
  void _append(ActivityLogEntry entry) {
    final current = _loadEntries()..add(entry);
    final trimmed = current.length > kMaxEntries
        ? current.sublist(current.length - kMaxEntries)
        : current;
    _prefs.setString(
      kLogKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Application-wide [SharedPreferencesActivityLogService] singleton.
///
/// Inject this provider wherever file operations are logged (e.g.
/// [fileServiceProvider]) so that a single instance is shared across the app.
final activityLogServiceProvider =
    Provider<SharedPreferencesActivityLogService>((ref) {
      return SharedPreferencesActivityLogService(
        ref.read(sharedPreferencesProvider),
      );
    });
