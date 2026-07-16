import 'app_settings.dart' show Currency;

/// A region choice offered at first church creation (U4).
///
/// Picking a region derives sensible defaults so the user does not have to
/// set currency, locale, and timezone by hand: [currencyCode] prefills the
/// church-level ISO 4217 currency picker, while [currency]/[locale]/[timezone]
/// seed the app-wide [AppSettings]. Every field stays overridable afterward —
/// the region is a shortcut, not a lock-in.
///
/// The set is limited to regions whose currency the app can format natively
/// (the [Currency] enum). The currency picker still offers the full ISO list
/// for churches outside these regions.
class AppRegion {
  final String name;
  final String currencyCode;
  final Currency currency;
  final String locale;
  final String timezone;

  const AppRegion({
    required this.name,
    required this.currencyCode,
    required this.currency,
    required this.locale,
    required this.timezone,
  });
}

const List<AppRegion> kRegions = <AppRegion>[
  AppRegion(
    name: 'Kenya',
    currencyCode: 'KES',
    currency: Currency.kes,
    locale: 'en_KE',
    timezone: 'Africa/Nairobi',
  ),
  AppRegion(
    name: 'Uganda',
    currencyCode: 'UGX',
    currency: Currency.ugx,
    locale: 'en_UG',
    timezone: 'Africa/Kampala',
  ),
  AppRegion(
    name: 'Tanzania',
    currencyCode: 'TZS',
    currency: Currency.tzs,
    locale: 'en_TZ',
    timezone: 'Africa/Dar_es_Salaam',
  ),
  AppRegion(
    name: 'United Kingdom',
    currencyCode: 'GBP',
    currency: Currency.gbp,
    locale: 'en_GB',
    timezone: 'Europe/London',
  ),
  AppRegion(
    name: 'Eurozone',
    currencyCode: 'EUR',
    currency: Currency.eur,
    locale: 'en_IE',
    timezone: 'Europe/Brussels',
  ),
  AppRegion(
    name: 'United States',
    currencyCode: 'USD',
    currency: Currency.usd,
    locale: 'en_US',
    timezone: 'America/New_York',
  ),
];
