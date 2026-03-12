/// Immutable model for foreign income reported in ITR-2.
///
/// Used in Schedule FSI (Foreign Source Income) for residents
/// claiming relief under Section 90/91.
class ForeignIncome {
  const ForeignIncome({
    required this.countryCode,
    required this.countryName,
    required this.incomeType,
    required this.amountInForeignCurrency,
    required this.exchangeRate,
    required this.taxPaidAbroad,
  });

  /// ISO 3166-1 alpha-2 country code (e.g. 'US', 'GB').
  final String countryCode;

  /// Full name of the country (e.g. 'United States').
  final String countryName;

  /// Nature of income (e.g. 'Salary', 'Dividend', 'Interest').
  final String incomeType;

  /// Amount of income in the foreign currency.
  final double amountInForeignCurrency;

  /// RBI reference exchange rate used for conversion to INR.
  final double exchangeRate;

  /// Tax already paid in the foreign country (in INR).
  final double taxPaidAbroad;

  /// Income converted to Indian Rupees.
  double get incomeInINR => amountInForeignCurrency * exchangeRate;

  ForeignIncome copyWith({
    String? countryCode,
    String? countryName,
    String? incomeType,
    double? amountInForeignCurrency,
    double? exchangeRate,
    double? taxPaidAbroad,
  }) {
    return ForeignIncome(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      incomeType: incomeType ?? this.incomeType,
      amountInForeignCurrency:
          amountInForeignCurrency ?? this.amountInForeignCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      taxPaidAbroad: taxPaidAbroad ?? this.taxPaidAbroad,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForeignIncome &&
        other.countryCode == countryCode &&
        other.countryName == countryName &&
        other.incomeType == incomeType &&
        other.amountInForeignCurrency == amountInForeignCurrency &&
        other.exchangeRate == exchangeRate &&
        other.taxPaidAbroad == taxPaidAbroad;
  }

  @override
  int get hashCode => Object.hash(
    countryCode,
    countryName,
    incomeType,
    amountInForeignCurrency,
    exchangeRate,
    taxPaidAbroad,
  );
}
