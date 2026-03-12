/// Immutable model for the CMA Balance Sheet analysis (Form II).
///
/// Captures the key line items from a balance sheet in a format suitable
/// for CMA analysis — specifically for working capital gap computation,
/// MPBF calculation, and fund flow derivation.
///
/// All monetary values are stored as integers in **paise** (1/100 rupee).
///
/// The [totalCurrentAssets] and [currentLiabilitiesExclBank] aggregates can
/// be overridden directly via [copyWith] when individual sub-items are not
/// available (e.g. in unit tests that only care about the aggregate values).
class CmaBalanceSheet {
  const CmaBalanceSheet({
    required this.year,
    // Current Assets
    required this.cashAndBank,
    required this.receivables,
    required this.inventories,
    required this.advancesAndOtherCA,
    // Current Liabilities (excluding bank borrowings)
    required this.creditors,
    required this.advancesFromCustomers,
    required this.otherCurrentLiabilities,
    // Long-term items
    required this.netFixedAssets,
    required this.longTermInvestments,
    required this.otherLongTermAssets,
    required this.longTermBorrowings,
    required this.paidUpCapital,
    required this.reservesAndSurplus,
    // Supplementary fields used in fund flow
    required this.profitAfterTax,
    required this.depreciation,
    required this.dividendPaid,
    // Optional aggregate overrides
    int? totalCurrentAssetsOverride,
    int? currentLiabilitiesExclBankOverride,
  }) : _totalCurrentAssetsOverride = totalCurrentAssetsOverride,
       _currentLiabilitiesExclBankOverride = currentLiabilitiesExclBankOverride;

  /// Returns a zero-filled balance sheet instance.
  factory CmaBalanceSheet.empty() => const CmaBalanceSheet(
    year: 0,
    cashAndBank: 0,
    receivables: 0,
    inventories: 0,
    advancesAndOtherCA: 0,
    creditors: 0,
    advancesFromCustomers: 0,
    otherCurrentLiabilities: 0,
    netFixedAssets: 0,
    longTermInvestments: 0,
    otherLongTermAssets: 0,
    longTermBorrowings: 0,
    paidUpCapital: 0,
    reservesAndSurplus: 0,
    profitAfterTax: 0,
    depreciation: 0,
    dividendPaid: 0,
  );

  /// Fiscal year (e.g. 2024 represents FY 2023-24).
  final int year;

  // ── Current Assets ───────────────────────────────────────────────────────

  /// Cash, bank balances, and liquid instruments in paise.
  final int cashAndBank;

  /// Trade receivables / debtors (book debts) in paise.
  final int receivables;

  /// Inventories (raw material, WIP, finished goods) in paise.
  final int inventories;

  /// Advances paid and other current assets in paise.
  final int advancesAndOtherCA;

  // ── Current Liabilities (excluding bank borrowings) ──────────────────────

  /// Trade creditors / accounts payable in paise.
  final int creditors;

  /// Advances received from customers in paise.
  final int advancesFromCustomers;

  /// Other current liabilities and provisions in paise.
  final int otherCurrentLiabilities;

  // ── Long-term Assets ─────────────────────────────────────────────────────

  /// Net fixed assets (gross FA - accumulated depreciation) in paise.
  final int netFixedAssets;

  /// Long-term investments in paise.
  final int longTermInvestments;

  /// Other long-term / non-current assets in paise.
  final int otherLongTermAssets;

  // ── Long-term Liabilities ────────────────────────────────────────────────

  /// Term loans and long-term borrowings in paise.
  final int longTermBorrowings;

  /// Paid-up share capital in paise.
  final int paidUpCapital;

  /// Reserves and surplus (retained earnings) in paise.
  final int reservesAndSurplus;

  // ── Fund flow supplementary fields ───────────────────────────────────────

  /// Profit after tax for the year in paise (sourced from P&L).
  final int profitAfterTax;

  /// Depreciation for the year in paise (non-cash charge from P&L).
  final int depreciation;

  /// Dividend paid during the year in paise.
  final int dividendPaid;

  // Optional aggregate overrides (used in tests / when sub-items unavailable)
  final int? _totalCurrentAssetsOverride;
  final int? _currentLiabilitiesExclBankOverride;

  // ── Computed aggregates ──────────────────────────────────────────────────

  /// Total current assets (sum of sub-items, or override if set).
  int get totalCurrentAssets =>
      _totalCurrentAssetsOverride ??
      (cashAndBank + receivables + inventories + advancesAndOtherCA);

  /// Current liabilities excluding bank borrowings (used in MPBF calc).
  int get currentLiabilitiesExclBank =>
      _currentLiabilitiesExclBankOverride ??
      (creditors + advancesFromCustomers + otherCurrentLiabilities);

  /// Net working capital = CA - CL excl bank.
  int get workingCapital => totalCurrentAssets - currentLiabilitiesExclBank;

  /// Net worth = paid-up capital + reserves and surplus.
  int get netWorth => paidUpCapital + reservesAndSurplus;

  CmaBalanceSheet copyWith({
    int? year,
    int? cashAndBank,
    int? receivables,
    int? inventories,
    int? advancesAndOtherCA,
    int? creditors,
    int? advancesFromCustomers,
    int? otherCurrentLiabilities,
    int? netFixedAssets,
    int? longTermInvestments,
    int? otherLongTermAssets,
    int? longTermBorrowings,
    int? paidUpCapital,
    int? reservesAndSurplus,
    int? profitAfterTax,
    int? depreciation,
    int? dividendPaid,
    // Allow overriding aggregate totals directly without individual sub-items
    int? totalCurrentAssets,
    int? currentLiabilitiesExclBank,
  }) {
    return CmaBalanceSheet(
      year: year ?? this.year,
      cashAndBank: cashAndBank ?? this.cashAndBank,
      receivables: receivables ?? this.receivables,
      inventories: inventories ?? this.inventories,
      advancesAndOtherCA: advancesAndOtherCA ?? this.advancesAndOtherCA,
      creditors: creditors ?? this.creditors,
      advancesFromCustomers:
          advancesFromCustomers ?? this.advancesFromCustomers,
      otherCurrentLiabilities:
          otherCurrentLiabilities ?? this.otherCurrentLiabilities,
      netFixedAssets: netFixedAssets ?? this.netFixedAssets,
      longTermInvestments: longTermInvestments ?? this.longTermInvestments,
      otherLongTermAssets: otherLongTermAssets ?? this.otherLongTermAssets,
      longTermBorrowings: longTermBorrowings ?? this.longTermBorrowings,
      paidUpCapital: paidUpCapital ?? this.paidUpCapital,
      reservesAndSurplus: reservesAndSurplus ?? this.reservesAndSurplus,
      profitAfterTax: profitAfterTax ?? this.profitAfterTax,
      depreciation: depreciation ?? this.depreciation,
      dividendPaid: dividendPaid ?? this.dividendPaid,
      totalCurrentAssetsOverride:
          totalCurrentAssets ?? _totalCurrentAssetsOverride,
      currentLiabilitiesExclBankOverride:
          currentLiabilitiesExclBank ?? _currentLiabilitiesExclBankOverride,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CmaBalanceSheet &&
        other.year == year &&
        other.cashAndBank == cashAndBank &&
        other.receivables == receivables &&
        other.inventories == inventories &&
        other.advancesAndOtherCA == advancesAndOtherCA &&
        other.creditors == creditors &&
        other.advancesFromCustomers == advancesFromCustomers &&
        other.otherCurrentLiabilities == otherCurrentLiabilities &&
        other.netFixedAssets == netFixedAssets &&
        other.longTermInvestments == longTermInvestments &&
        other.otherLongTermAssets == otherLongTermAssets &&
        other.longTermBorrowings == longTermBorrowings &&
        other.paidUpCapital == paidUpCapital &&
        other.reservesAndSurplus == reservesAndSurplus &&
        other.profitAfterTax == profitAfterTax &&
        other.depreciation == depreciation &&
        other.dividendPaid == dividendPaid &&
        other._totalCurrentAssetsOverride == _totalCurrentAssetsOverride &&
        other._currentLiabilitiesExclBankOverride ==
            _currentLiabilitiesExclBankOverride;
  }

  @override
  int get hashCode => Object.hash(
    year,
    cashAndBank,
    receivables,
    inventories,
    advancesAndOtherCA,
    creditors,
    advancesFromCustomers,
    otherCurrentLiabilities,
    netFixedAssets,
    longTermInvestments,
    otherLongTermAssets,
    longTermBorrowings,
    paidUpCapital,
    reservesAndSurplus,
    profitAfterTax,
    depreciation,
    dividendPaid,
  );
}
