import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/settings_service.dart' show sharedPreferencesProvider;

// ---------------------------------------------------------------------------
// Key
// ---------------------------------------------------------------------------

/// SharedPreferences key for the user-overridden export directory path.
const String _defaultExportPathKey = 'default_export_path';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Persists and retrieves the user-override export directory path.
///
/// A `null` result from [getDefaultExportPath] means no override is set and
/// the app should use the platform default (`Downloads/ChurchAnalytics/`).
class SettingsRepository {
  final SharedPreferences _prefs;

  const SettingsRepository(this._prefs);

  /// Returns the persisted custom export directory path, or `null` when no
  /// override has been set.
  ///
  /// The read is synchronous because [SharedPreferences] loads all values
  /// eagerly when its instance is first obtained.
  String? getDefaultExportPath() => _prefs.getString(_defaultExportPathKey);

  /// Persists [path] as the user-override export directory.
  ///
  /// [path] must be an absolute directory path.  The caller is responsible
  /// for validating that the path is writable (e.g. via the OS folder picker)
  /// before calling this method.
  Future<void> setDefaultExportPath(String path) =>
      _prefs.setString(_defaultExportPathKey, path);

  /// Removes the user-override export path, restoring the platform default.
  Future<void> clearDefaultExportPath() =>
      _prefs.remove(_defaultExportPathKey);
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

/// Provides the application-wide [SettingsRepository] singleton.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

/// [StateNotifier] for the current user-override export directory path.
///
/// State is `null` when the platform default is in use and a non-null
/// absolute path string when the user has set a custom folder.
class DefaultExportPathNotifier extends StateNotifier<String?> {
  final SettingsRepository _repo;

  DefaultExportPathNotifier(this._repo) : super(_repo.getDefaultExportPath());

  /// Persists [path] as the custom export directory and updates the state.
  Future<void> setCustomPath(String path) async {
    await _repo.setDefaultExportPath(path);
    state = path;
  }

  /// Clears the custom export directory override and resets the state to
  /// `null` (platform default).
  Future<void> clearCustomPath() async {
    await _repo.clearDefaultExportPath();
    state = null;
  }
}

/// Provides the reactive custom export path state.
///
/// Watch this provider in the Settings UI to reflect the current value.
/// Use [defaultExportPathProvider.notifier] to call [setCustomPath] or
/// [clearCustomPath].
final defaultExportPathProvider =
    StateNotifierProvider<DefaultExportPathNotifier, String?>((ref) {
  return DefaultExportPathNotifier(ref.read(settingsRepositoryProvider));
});
