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

/// Application settings model — includes the active church selection so every
/// screen can read it from a single, persisted source of truth.
class AppSettings extends Equatable {
  final Currency currency;
  final String locale;
  final String timezone;
  final AppThemeMode themeMode;

  /// The ID of the currently selected church. Null when no church has been
  /// selected yet (first-launch state).
  final int? selectedChurchId;

  const AppSettings({
    this.currency = Currency.kes,
    this.locale = 'en_KE',
    this.timezone = 'Africa/Nairobi',
    this.themeMode = AppThemeMode.system,
    this.selectedChurchId,
  });

  AppSettings copyWith({
    Currency? currency,
    String? locale,
    String? timezone,
    AppThemeMode? themeMode,
    // Use a sentinel so callers can explicitly set selectedChurchId to null.
    Object? selectedChurchId = _unset,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      themeMode: themeMode ?? this.themeMode,
      selectedChurchId: identical(selectedChurchId, _unset)
          ? this.selectedChurchId
          : selectedChurchId as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency.code,
      'locale': locale,
      'timezone': timezone,
      'themeMode': themeMode.value,
      if (selectedChurchId != null) 'selectedChurchId': selectedChurchId,
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
      selectedChurchId: json['selectedChurchId'] as int?,
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
  List<Object?> get props =>
      [currency, locale, timezone, themeMode, selectedChurchId];

  @override
  String toString() {
    return 'AppSettings(currency: $currency, locale: $locale, '
        'timezone: $timezone, themeMode: $themeMode, '
        'selectedChurchId: $selectedChurchId)';
  }
}

/// Private sentinel value used by [AppSettings.copyWith] so that
/// `selectedChurchId: null` can be distinguished from "not provided".
const _unset = Object();
