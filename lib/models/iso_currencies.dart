/// ISO 4217 currency reference data.
///
/// [church.currency] stores a 3-letter ISO 4217 code as a string. This is the
/// list the church-level currency picker (creation + Church Settings) offers,
/// so the field is no longer free text. It is deliberately broad — covering
/// every continent, with full coverage of East/Central Africa where the app is
/// used — but not the entire ISO register; [isoCurrencyByCode] tolerates codes
/// outside the list (e.g. from an imported backup) by returning null.
library;

/// A single ISO 4217 currency: its 3-letter code and English name.
class IsoCurrency {
  final String code;
  final String name;
  const IsoCurrency(this.code, this.name);
}

/// Curated ISO 4217 currencies, sorted by code.
const List<IsoCurrency> kIsoCurrencies = <IsoCurrency>[
  IsoCurrency('AED', 'UAE Dirham'),
  IsoCurrency('AOA', 'Angolan Kwanza'),
  IsoCurrency('ARS', 'Argentine Peso'),
  IsoCurrency('AUD', 'Australian Dollar'),
  IsoCurrency('BDT', 'Bangladeshi Taka'),
  IsoCurrency('BIF', 'Burundian Franc'),
  IsoCurrency('BRL', 'Brazilian Real'),
  IsoCurrency('BWP', 'Botswana Pula'),
  IsoCurrency('CAD', 'Canadian Dollar'),
  IsoCurrency('CDF', 'Congolese Franc'),
  IsoCurrency('CHF', 'Swiss Franc'),
  IsoCurrency('CNY', 'Chinese Yuan'),
  IsoCurrency('COP', 'Colombian Peso'),
  IsoCurrency('CVE', 'Cape Verdean Escudo'),
  IsoCurrency('CZK', 'Czech Koruna'),
  IsoCurrency('DKK', 'Danish Krone'),
  IsoCurrency('DZD', 'Algerian Dinar'),
  IsoCurrency('EGP', 'Egyptian Pound'),
  IsoCurrency('ERN', 'Eritrean Nakfa'),
  IsoCurrency('ETB', 'Ethiopian Birr'),
  IsoCurrency('EUR', 'Euro'),
  IsoCurrency('GBP', 'British Pound'),
  IsoCurrency('GHS', 'Ghanaian Cedi'),
  IsoCurrency('GMD', 'Gambian Dalasi'),
  IsoCurrency('GNF', 'Guinean Franc'),
  IsoCurrency('HKD', 'Hong Kong Dollar'),
  IsoCurrency('IDR', 'Indonesian Rupiah'),
  IsoCurrency('ILS', 'Israeli New Shekel'),
  IsoCurrency('INR', 'Indian Rupee'),
  IsoCurrency('JPY', 'Japanese Yen'),
  IsoCurrency('KES', 'Kenyan Shilling'),
  IsoCurrency('KRW', 'South Korean Won'),
  IsoCurrency('LRD', 'Liberian Dollar'),
  IsoCurrency('LSL', 'Lesotho Loti'),
  IsoCurrency('MAD', 'Moroccan Dirham'),
  IsoCurrency('MGA', 'Malagasy Ariary'),
  IsoCurrency('MUR', 'Mauritian Rupee'),
  IsoCurrency('MWK', 'Malawian Kwacha'),
  IsoCurrency('MXN', 'Mexican Peso'),
  IsoCurrency('MYR', 'Malaysian Ringgit'),
  IsoCurrency('MZN', 'Mozambican Metical'),
  IsoCurrency('NAD', 'Namibian Dollar'),
  IsoCurrency('NGN', 'Nigerian Naira'),
  IsoCurrency('NOK', 'Norwegian Krone'),
  IsoCurrency('NZD', 'New Zealand Dollar'),
  IsoCurrency('PHP', 'Philippine Peso'),
  IsoCurrency('PKR', 'Pakistani Rupee'),
  IsoCurrency('PLN', 'Polish Zloty'),
  IsoCurrency('RWF', 'Rwandan Franc'),
  IsoCurrency('SAR', 'Saudi Riyal'),
  IsoCurrency('SCR', 'Seychellois Rupee'),
  IsoCurrency('SDG', 'Sudanese Pound'),
  IsoCurrency('SEK', 'Swedish Krona'),
  IsoCurrency('SGD', 'Singapore Dollar'),
  IsoCurrency('SLL', 'Sierra Leonean Leone'),
  IsoCurrency('SOS', 'Somali Shilling'),
  IsoCurrency('SSP', 'South Sudanese Pound'),
  IsoCurrency('SZL', 'Eswatini Lilangeni'),
  IsoCurrency('THB', 'Thai Baht'),
  IsoCurrency('TND', 'Tunisian Dinar'),
  IsoCurrency('TRY', 'Turkish Lira'),
  IsoCurrency('TZS', 'Tanzanian Shilling'),
  IsoCurrency('UGX', 'Ugandan Shilling'),
  IsoCurrency('USD', 'US Dollar'),
  IsoCurrency('XAF', 'Central African CFA Franc'),
  IsoCurrency('XOF', 'West African CFA Franc'),
  IsoCurrency('ZAR', 'South African Rand'),
  IsoCurrency('ZMW', 'Zambian Kwacha'),
  IsoCurrency('ZWL', 'Zimbabwean Dollar'),
];

/// Returns the [IsoCurrency] for [code] (case-insensitive), or null if the
/// code is not in [kIsoCurrencies].
IsoCurrency? isoCurrencyByCode(String? code) {
  if (code == null) return null;
  final upper = code.toUpperCase();
  for (final c in kIsoCurrencies) {
    if (c.code == upper) return c;
  }
  return null;
}
