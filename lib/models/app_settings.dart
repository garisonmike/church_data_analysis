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

  static const AppThemeMode defaultTheme = AppThemeMode.system;

  static AppThemeMode fromValue(String value) {
    for (AppThemeMode mode in AppThemeMode.values) {
      if (mode.value == value) return mode;
    }
    return defaultTheme;
  }

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

  static const Currency defaultCurrency = Currency.kes;

  static Currency fromCode(String code) {
    for (Currency currency in Currency.values) {
      if (currency.code == code) return currency;
    }
    return defaultCurrency;
  }
}

/// Application settings model: currency, locale, timezone, and theme.
///
/// The current church selection is NOT stored here — it lives in
/// SharedPreferences under ChurchService, exposed to widgets via
/// `currentChurchIdProvider`. (An unwired `selectedChurchId` field here was
/// the root cause of U9's "No church selected" bug; a stale value from an
/// old settings JSON is deliberately ignored by [fromJson].)
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

  Map<String, dynamic> toJson() {
    return {
      'currency': currency.code,
      'locale': locale,
      'timezone': timezone,
      'themeMode': themeMode.value,
    };
  }

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
    return 'AppSettings(currency: $currency, locale: $locale, '
        'timezone: $timezone, themeMode: $themeMode)';
  }
}
