/// Equity and liabilities section of the Schedule III Balance Sheet.
///
/// All amounts are in paise (int) to avoid floating-point rounding errors.
class ScheduleIIIEquity {
  const ScheduleIIIEquity({
    required this.shareCapital,
    required this.reservesAndSurplus,
    required this.longTermBorrowings,
    required this.tradePayables,
    required this.otherCurrentLiabilities,
  });

  /// Zero-value constant for initialisation.
  static const zero = ScheduleIIIEquity(
    shareCapital: 0,
    reservesAndSurplus: 0,
    longTermBorrowings: 0,
    tradePayables: 0,
    otherCurrentLiabilities: 0,
  );

  // ── Non-current section ──────────────────────────────────────────────────

  /// Paid-up share capital (paise).
  final int shareCapital;

  /// Reserves and surplus including retained earnings (paise).
  final int reservesAndSurplus;

  /// Long-term borrowings — repayable beyond 12 months (paise).
  final int longTermBorrowings;

  // ── Current liabilities section ──────────────────────────────────────────

  /// Trade payables — amounts owed to suppliers (paise).
  final int tradePayables;

  /// Other current liabilities — accruals, advances received, etc. (paise).
  final int otherCurrentLiabilities;

  /// Total shareholders' equity (share capital + reserves).
  int get totalEquity => shareCapital + reservesAndSurplus;

  /// Total non-current liabilities.
  int get totalNonCurrentLiabilities => longTermBorrowings;

  /// Total current liabilities.
  int get totalCurrentLiabilities => tradePayables + otherCurrentLiabilities;

  /// Grand total of equity and all liabilities.
  int get total =>
      totalEquity + totalNonCurrentLiabilities + totalCurrentLiabilities;

  ScheduleIIIEquity copyWith({
    int? shareCapital,
    int? reservesAndSurplus,
    int? longTermBorrowings,
    int? tradePayables,
    int? otherCurrentLiabilities,
  }) {
    return ScheduleIIIEquity(
      shareCapital: shareCapital ?? this.shareCapital,
      reservesAndSurplus: reservesAndSurplus ?? this.reservesAndSurplus,
      longTermBorrowings: longTermBorrowings ?? this.longTermBorrowings,
      tradePayables: tradePayables ?? this.tradePayables,
      otherCurrentLiabilities:
          otherCurrentLiabilities ?? this.otherCurrentLiabilities,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleIIIEquity &&
        other.shareCapital == shareCapital &&
        other.reservesAndSurplus == reservesAndSurplus &&
        other.longTermBorrowings == longTermBorrowings &&
        other.tradePayables == tradePayables &&
        other.otherCurrentLiabilities == otherCurrentLiabilities;
  }

  @override
  int get hashCode => Object.hash(
    shareCapital,
    reservesAndSurplus,
    longTermBorrowings,
    tradePayables,
    otherCurrentLiabilities,
  );
}
