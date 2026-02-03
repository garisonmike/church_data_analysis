import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme modes supported by the app
enum AppThemeMode {
  light('light', 'Light Theme'),
  dark('dark', 'Dark Theme'),
  system('system', 'System Default');

  const AppThemeMode(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Default theme mode
  static const AppThemeMode defaultTheme = AppThemeMode.system;

  /// Returns AppThemeMode from string value
  static AppThemeMode fromValue(String value) {
    for (AppThemeMode mode in AppThemeMode.values) {
      if (mode.value == value) {
        return mode;
      }
    }
    return defaultTheme;
  }

  /// Convert to Flutter ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Supported currencies in the app
enum Currency {
  kes('KES', 'Kenyan Shilling', 'Ksh'),
  usd('USD', 'US Dollar', '\$'),
  eur('EUR', 'Euro', '€'),
  gbp('GBP', 'British Pound', '£'),
  ugx('UGX', 'Ugandan Shilling', 'USh'),
  tzs('TZS', 'Tanzanian Shilling', 'TSh');

  const Currency(this.code, this.name, this.symbol);

  final String code;
  final String name;
  final String symbol;

  /// Default currency for the app
  static const Currency defaultCurrency = Currency.kes;

  /// Returns Currency from code, defaults to KES if not found
  static Currency fromCode(String code) {
    for (Currency currency in Currency.values) {
      if (currency.code == code) {
        return currency;
      }
    }
    return defaultCurrency;
  }
}

/// Application settings model
class AppSettings extends Equatable {
  final Currency currency;
  final String locale;
  final String timezone;
  final AppThemeMode themeMode;

  const AppSettings({
    this.currency = Currency.kes,
    this.locale = 'en_KE',
    this.timezone = 'Africa/Nairobi',
    this.themeMode = AppThemeMode.system,
  });

  /// Creates a copy of this AppSettings with updated fields
  AppSettings copyWith({
    Currency? currency,
    String? locale,
    String? timezone,
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// Convert to JSON map for persistence
  Map<String, dynamic> toJson() {
    return {
      'currency': currency.code,
      'locale': locale,
      'timezone': timezone,
      'themeMode': themeMode.value,
    };
  }

  /// Create from JSON map
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currency: Currency.fromCode(json['currency'] ?? Currency.kes.code),
      locale: json['locale'] ?? 'en_KE',
      timezone: json['timezone'] ?? 'Africa/Nairobi',
      themeMode: AppThemeMode.fromValue(
        json['themeMode'] ?? AppThemeMode.system.value,
      ),
    );
  }

  /// Default settings for Kenya
  factory AppSettings.defaultKenyan() {
    return const AppSettings(
      currency: Currency.kes,
      locale: 'en_KE',
      timezone: 'Africa/Nairobi',
      themeMode: AppThemeMode.system,
    );
  }

  @override
  List<Object?> get props => [currency, locale, timezone, themeMode];

  @override
  String toString() {
    return 'AppSettings(currency: $currency, locale: $locale, timezone: $timezone, themeMode: $themeMode)';
  }
}
