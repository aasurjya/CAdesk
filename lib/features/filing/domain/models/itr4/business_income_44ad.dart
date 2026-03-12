/// Immutable model for presumptive business income under Section 44AD.
///
/// Section 44AD applies to resident individuals, HUFs, and partnership firms
/// (not LLPs) engaged in any business (except transport, agency, commission,
/// brokerage) with turnover up to ₹3 crore (FY 2025-26).
///
/// Presumptive rates:
/// - 6% of turnover received through digital means (non-cash)
/// - 8% of turnover received in cash
class BusinessIncome44AD {
  const BusinessIncome44AD({
    required this.natureOfBusiness,
    required this.tradeName,
    required this.cashTurnover,
    required this.nonCashTurnover,
  });

  factory BusinessIncome44AD.empty() => const BusinessIncome44AD(
    natureOfBusiness: '',
    tradeName: '',
    cashTurnover: 0,
    nonCashTurnover: 0,
  );

  /// Nature / type of business activity (e.g. 'Retail Trade', 'Manufacturing').
  final String natureOfBusiness;

  /// Trade name under which the business is conducted.
  final String tradeName;

  /// Turnover received in cash / non-digital modes.
  /// Presumptive rate: 8%.
  final double cashTurnover;

  /// Turnover received through digital means (bank transfer, UPI, etc.).
  /// Presumptive rate: 6%.
  final double nonCashTurnover;

  /// Maximum turnover allowed for Section 44AD eligibility.
  static const double maxTurnover = 30000000; // ₹3 crore

  /// Total turnover (cash + non-cash).
  double get turnover => cashTurnover + nonCashTurnover;

  /// Presumptive income computed as per Section 44AD rates.
  ///
  /// 6% of digital (non-cash) turnover + 8% of cash turnover.
  double get presumptiveIncome => nonCashTurnover * 0.06 + cashTurnover * 0.08;

  BusinessIncome44AD copyWith({
    String? natureOfBusiness,
    String? tradeName,
    double? cashTurnover,
    double? nonCashTurnover,
  }) {
    return BusinessIncome44AD(
      natureOfBusiness: natureOfBusiness ?? this.natureOfBusiness,
      tradeName: tradeName ?? this.tradeName,
      cashTurnover: cashTurnover ?? this.cashTurnover,
      nonCashTurnover: nonCashTurnover ?? this.nonCashTurnover,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessIncome44AD &&
        other.natureOfBusiness == natureOfBusiness &&
        other.tradeName == tradeName &&
        other.cashTurnover == cashTurnover &&
        other.nonCashTurnover == nonCashTurnover;
  }

  @override
  int get hashCode =>
      Object.hash(natureOfBusiness, tradeName, cashTurnover, nonCashTurnover);
}
