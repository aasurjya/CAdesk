/// Labels for each line item in a Fund Flow Statement.
///
/// These correspond to the standard CMA Form V categories as required
/// by Indian banks for CMA analysis.
enum FundFlowLabel {
  // Sources
  increaseInLongTermLiabilities,
  decreaseInLongTermAssets,
  profitAfterTaxPlusDepreciation,
  // Uses
  decreaseInLongTermLiabilities,
  increaseInLongTermAssets,
  dividendPaid,
}

/// A single line item in a fund flow statement.
///
/// All amounts are in **paise** (1/100 rupee).
class FundFlowItem {
  const FundFlowItem({
    required this.label,
    required this.amountPaise,
  });

  /// Descriptive label identifying this line item.
  final FundFlowLabel label;

  /// Amount in paise. Always non-negative; sign is conveyed by placement
  /// in [FundFlowStatement.sourcesOfFunds] or [FundFlowStatement.usesOfFunds].
  final int amountPaise;

  FundFlowItem copyWith({
    FundFlowLabel? label,
    int? amountPaise,
  }) {
    return FundFlowItem(
      label: label ?? this.label,
      amountPaise: amountPaise ?? this.amountPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FundFlowItem &&
        other.label == label &&
        other.amountPaise == amountPaise;
  }

  @override
  int get hashCode => Object.hash(label, amountPaise);
}

/// Immutable Fund Flow Statement for a single year (CMA Form V).
///
/// Sources represent inflows of long-term funds into working capital;
/// uses represent outflows. The [netChange] should reconcile with the
/// change in working capital between two balance sheet dates.
///
/// All monetary values are in **paise** (1/100 rupee).
class FundFlowStatement {
  const FundFlowStatement({
    required this.year,
    required this.sourcesOfFunds,
    required this.usesOfFunds,
    required this.netChange,
    required this.openingWorkingCapital,
    required this.closingWorkingCapital,
  });

  /// Fiscal year this statement covers.
  final int year;

  /// Long-term fund inflows (increase in LT liabilities, decrease in LT
  /// assets, PAT + depreciation).
  final List<FundFlowItem> sourcesOfFunds;

  /// Long-term fund outflows (decrease in LT liabilities, increase in LT
  /// assets, dividends paid).
  final List<FundFlowItem> usesOfFunds;

  /// Net change in working capital = total sources - total uses.
  final int netChange;

  /// Working capital at the start of the year (from previous balance sheet).
  final int openingWorkingCapital;

  /// Working capital at the end of the year (from current balance sheet).
  final int closingWorkingCapital;

  FundFlowStatement copyWith({
    int? year,
    List<FundFlowItem>? sourcesOfFunds,
    List<FundFlowItem>? usesOfFunds,
    int? netChange,
    int? openingWorkingCapital,
    int? closingWorkingCapital,
  }) {
    return FundFlowStatement(
      year: year ?? this.year,
      sourcesOfFunds: sourcesOfFunds ?? this.sourcesOfFunds,
      usesOfFunds: usesOfFunds ?? this.usesOfFunds,
      netChange: netChange ?? this.netChange,
      openingWorkingCapital:
          openingWorkingCapital ?? this.openingWorkingCapital,
      closingWorkingCapital:
          closingWorkingCapital ?? this.closingWorkingCapital,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FundFlowStatement) return false;
    if (other.year != year) return false;
    if (other.netChange != netChange) return false;
    if (other.openingWorkingCapital != openingWorkingCapital) return false;
    if (other.closingWorkingCapital != closingWorkingCapital) return false;
    if (other.sourcesOfFunds.length != sourcesOfFunds.length) return false;
    if (other.usesOfFunds.length != usesOfFunds.length) return false;
    for (var i = 0; i < sourcesOfFunds.length; i++) {
      if (other.sourcesOfFunds[i] != sourcesOfFunds[i]) return false;
    }
    for (var i = 0; i < usesOfFunds.length; i++) {
      if (other.usesOfFunds[i] != usesOfFunds[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    year,
    netChange,
    openingWorkingCapital,
    closingWorkingCapital,
    Object.hashAll(sourcesOfFunds),
    Object.hashAll(usesOfFunds),
  );
}
