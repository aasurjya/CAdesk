/// Assets section of the Schedule III Balance Sheet.
///
/// All amounts are in paise (int) to avoid floating-point rounding errors.
class ScheduleIIIAssets {
  const ScheduleIIIAssets({
    required this.fixedAssets,
    required this.investments,
    required this.inventories,
    required this.tradeReceivables,
    required this.cashAndCashEquivalents,
    required this.otherCurrentAssets,
  });

  /// Zero-value constant for initialisation.
  static const zero = ScheduleIIIAssets(
    fixedAssets: 0,
    investments: 0,
    inventories: 0,
    tradeReceivables: 0,
    cashAndCashEquivalents: 0,
    otherCurrentAssets: 0,
  );

  // ── Non-current assets ───────────────────────────────────────────────────

  /// Tangible and intangible fixed assets (net of depreciation) in paise.
  final int fixedAssets;

  /// Long-term investments (shares, debentures, etc.) in paise.
  final int investments;

  // ── Current assets ───────────────────────────────────────────────────────

  /// Inventories — raw material, WIP, finished goods (paise).
  final int inventories;

  /// Trade receivables — debtors within the operating cycle (paise).
  final int tradeReceivables;

  /// Cash and bank balances (paise).
  final int cashAndCashEquivalents;

  /// Other current assets — prepaid, advances, tax credits (paise).
  final int otherCurrentAssets;

  /// Total non-current assets.
  int get totalNonCurrentAssets => fixedAssets + investments;

  /// Total current assets.
  int get totalCurrentAssets =>
      inventories +
      tradeReceivables +
      cashAndCashEquivalents +
      otherCurrentAssets;

  /// Grand total of all assets.
  int get total => totalNonCurrentAssets + totalCurrentAssets;

  ScheduleIIIAssets copyWith({
    int? fixedAssets,
    int? investments,
    int? inventories,
    int? tradeReceivables,
    int? cashAndCashEquivalents,
    int? otherCurrentAssets,
  }) {
    return ScheduleIIIAssets(
      fixedAssets: fixedAssets ?? this.fixedAssets,
      investments: investments ?? this.investments,
      inventories: inventories ?? this.inventories,
      tradeReceivables: tradeReceivables ?? this.tradeReceivables,
      cashAndCashEquivalents:
          cashAndCashEquivalents ?? this.cashAndCashEquivalents,
      otherCurrentAssets: otherCurrentAssets ?? this.otherCurrentAssets,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleIIIAssets &&
        other.fixedAssets == fixedAssets &&
        other.investments == investments &&
        other.inventories == inventories &&
        other.tradeReceivables == tradeReceivables &&
        other.cashAndCashEquivalents == cashAndCashEquivalents &&
        other.otherCurrentAssets == otherCurrentAssets;
  }

  @override
  int get hashCode => Object.hash(
    fixedAssets,
    investments,
    inventories,
    tradeReceivables,
    cashAndCashEquivalents,
    otherCurrentAssets,
  );
}
