import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Key used to store app settings in SharedPreferences
const String _settingsKey = 'app_settings';

/// Settings service for managing app configuration
class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Load settings from SharedPreferences
  AppSettings loadSettings() {
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(settingsJson);
        return AppSettings.fromJson(jsonMap);
      } catch (e) {
        // If there's an error parsing, return default settings
        return AppSettings.defaultKenyan();
      }
    }
    // Return default Kenyan settings for new installations
    return AppSettings.defaultKenyan();
  }

  /// Save settings to SharedPreferences
  Future<void> saveSettings(AppSettings settings) async {
    final settingsJson = json.encode(settings.toJson());
    await _prefs.setString(_settingsKey, settingsJson);
  }

  /// Reset settings to default
  Future<void> resetSettings() async {
    await _prefs.remove(_settingsKey);
  }
}

/// Mock SharedPreferences for safe default (non-persisting)
class _InMemorySharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  Object? get(String key) => _data[key];

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) =>
      (_data[key] as List?)?.cast<String>();

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  Future<void> reload() async {}

  @override
  bool containsKey(String key) => _data.containsKey(key);
}

/// Provider for SharedPreferences instance
/// Safe default: Uses in-memory implementation (non-persisting)
/// Should be overridden in main() with real SharedPreferences for persistence
/// In tests: Override with SharedPreferences.getInstance() after setMockInitialValues()
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Safe default: return non-persisting in-memory implementation
  // This prevents crashes and allows app/tests to run without overrides
  // For persistence, override in main() with await SharedPreferences.getInstance()
  return _InMemorySharedPreferences();
});

/// Provider for SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SettingsService(prefs);
});

/// StateNotifier for managing app settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _settingsService;

  SettingsNotifier(this._settingsService)
    : super(_settingsService.loadSettings());

  /// Update currency setting
  Future<void> updateCurrency(Currency currency) async {
    final newSettings = state.copyWith(currency: currency);
    await _settingsService.saveSettings(newSettings);
    state = newSettings;
  }

  /// Update locale setting
  Future<void> updateLocale(String locale) async {
    final newSettings = state.copyWith(locale: locale);
    await _settingsService.saveSettings(newSettings);
    state = newSettings;
  }

  /// Update timezone setting
  Future<void> updateTimezone(String timezone) async {
    final newSettings = state.copyWith(timezone: timezone);
    await _settingsService.saveSettings(newSettings);
    state = newSettings;
  }

  /// Update theme mode setting
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final newSettings = state.copyWith(themeMode: themeMode);
    await _settingsService.saveSettings(newSettings);
    state = newSettings;
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    await _settingsService.resetSettings();
    state = AppSettings.defaultKenyan();
  }

  /// Format currency amount with current currency symbol
  String formatCurrency(double amount) {
    final currency = state.currency;

    // Format with appropriate decimal places and thousand separators
    String formattedAmount;
    if (amount >= 1000000) {
      formattedAmount = '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      formattedAmount = '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      formattedAmount = amount.toStringAsFixed(0);
    }

    // Add currency symbol
    return '${currency.symbol} $formattedAmount';
  }

  /// Format currency amount with full precision
  String formatCurrencyPrecise(double amount) {
    final currency = state.currency;
    final formatted = amount.toStringAsFixed(2);
    return '${currency.symbol} $formatted';
  }
}

/// Provider for app settings state
final appSettingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
      final settingsService = ref.read(settingsServiceProvider);
      return SettingsNotifier(settingsService);
    });

/// Convenience provider for currency formatting
final currencyFormatterProvider = Provider<String Function(double)>((ref) {
  final settingsNotifier = ref.read(appSettingsProvider.notifier);
  return settingsNotifier.formatCurrency;
});

/// Convenience provider for precise currency formatting
final currencyFormatterPreciseProvider = Provider<String Function(double)>((
  ref,
) {
  final settingsNotifier = ref.read(appSettingsProvider.notifier);
  return settingsNotifier.formatCurrencyPrecise;
});
