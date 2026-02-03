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

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// Provider for SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SettingsService(prefs);
});

/// StateNotifier for managing app settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _settingsService;

  SettingsNotifier(this._settingsService) : super(_settingsService.loadSettings());

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
final appSettingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final settingsService = ref.read(settingsServiceProvider);
  return SettingsNotifier(settingsService);
});

/// Convenience provider for currency formatting
final currencyFormatterProvider = Provider<String Function(double)>((ref) {
  final settingsNotifier = ref.read(appSettingsProvider.notifier);
  return settingsNotifier.formatCurrency;
});

/// Convenience provider for precise currency formatting
final currencyFormatterPreciseProvider = Provider<String Function(double)>((ref) {
  final settingsNotifier = ref.read(appSettingsProvider.notifier);
  return settingsNotifier.formatCurrencyPrecise;
});