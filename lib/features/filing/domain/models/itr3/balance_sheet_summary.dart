/// Immutable model for balance sheet summary in ITR-3.
///
/// Used in Schedule BS (Balance Sheet) for assessees carrying on
/// business or profession with books of accounts.
class BalanceSheetSummary {
  const BalanceSheetSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.cashAndBank,
    required this.sundryDebtors,
    required this.sundryCreditors,
  });

  factory BalanceSheetSummary.empty() => const BalanceSheetSummary(
    totalAssets: 0,
    totalLiabilities: 0,
    netWorth: 0,
    cashAndBank: 0,
    sundryDebtors: 0,
    sundryCreditors: 0,
  );

  /// Total assets as per books of accounts.
  final double totalAssets;

  /// Total liabilities (excluding proprietor's capital / net worth).
  final double totalLiabilities;

  /// Net worth (Total Assets – Total Liabilities).
  final double netWorth;

  /// Cash in hand and bank balances.
  final double cashAndBank;

  /// Sundry debtors (trade receivables).
  final double sundryDebtors;

  /// Sundry creditors (trade payables).
  final double sundryCreditors;

  BalanceSheetSummary copyWith({
    double? totalAssets,
    double? totalLiabilities,
    double? netWorth,
    double? cashAndBank,
    double? sundryDebtors,
    double? sundryCreditors,
  }) {
    return BalanceSheetSummary(
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      netWorth: netWorth ?? this.netWorth,
      cashAndBank: cashAndBank ?? this.cashAndBank,
      sundryDebtors: sundryDebtors ?? this.sundryDebtors,
      sundryCreditors: sundryCreditors ?? this.sundryCreditors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BalanceSheetSummary &&
        other.totalAssets == totalAssets &&
        other.totalLiabilities == totalLiabilities &&
        other.netWorth == netWorth &&
        other.cashAndBank == cashAndBank &&
        other.sundryDebtors == sundryDebtors &&
        other.sundryCreditors == sundryCreditors;
  }

  @override
  int get hashCode => Object.hash(
    totalAssets,
    totalLiabilities,
    netWorth,
    cashAndBank,
    sundryDebtors,
    sundryCreditors,
  );
}
