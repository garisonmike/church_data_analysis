import 'package:equatable/equatable.dart';

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

  const AppSettings({
    this.currency = Currency.kes,
    this.locale = 'en_KE',
    this.timezone = 'Africa/Nairobi',
  });

  /// Creates a copy of this AppSettings with updated fields
  AppSettings copyWith({Currency? currency, String? locale, String? timezone}) {
    return AppSettings(
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
    );
  }

  /// Convert to JSON map for persistence
  Map<String, dynamic> toJson() {
    return {'currency': currency.code, 'locale': locale, 'timezone': timezone};
  }

  /// Create from JSON map
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currency: Currency.fromCode(json['currency'] ?? Currency.kes.code),
      locale: json['locale'] ?? 'en_KE',
      timezone: json['timezone'] ?? 'Africa/Nairobi',
    );
  }

  /// Default settings for Kenya
  factory AppSettings.defaultKenyan() {
    return const AppSettings(
      currency: Currency.kes,
      locale: 'en_KE',
      timezone: 'Africa/Nairobi',
    );
  }

  @override
  List<Object?> get props => [currency, locale, timezone];

  @override
  String toString() {
    return 'AppSettings(currency: $currency, locale: $locale, timezone: $timezone)';
  }
}
