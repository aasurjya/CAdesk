/// A single line item in the cash flow statement.
///
/// Amount is in paise (int). Positive = inflow, negative = outflow.
class CashFlowLineItem {
  const CashFlowLineItem({
    required this.description,
    required this.amountPaise,
  });

  final String description;
  final int amountPaise;

  CashFlowLineItem copyWith({String? description, int? amountPaise}) {
    return CashFlowLineItem(
      description: description ?? this.description,
      amountPaise: amountPaise ?? this.amountPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashFlowLineItem &&
        other.description == description &&
        other.amountPaise == amountPaise;
  }

  @override
  int get hashCode => Object.hash(description, amountPaise);
}

/// Immutable Cash Flow Statement (Indirect Method) per AS-3 / Ind AS 7.
///
/// Covers three activities: Operating, Investing, and Financing.
/// All amounts are in paise (int).
class CashFlowStatement {
  const CashFlowStatement({
    required this.financialYear,
    required this.operatingActivitiesTotal,
    required this.investingActivitiesTotal,
    required this.financingActivitiesTotal,
    required this.netChangeInCash,
    required this.openingCashPaise,
    required this.closingCashPaise,
    required this.operatingLineItems,
    required this.investingLineItems,
    required this.financingLineItems,
  });

  /// Financial year (e.g. 2025 = FY 2024-25).
  final int financialYear;

  /// Net cash from operating activities (paise).
  final int operatingActivitiesTotal;

  /// Net cash from investing activities (paise).
  final int investingActivitiesTotal;

  /// Net cash from financing activities (paise).
  final int financingActivitiesTotal;

  /// Total net change in cash = operating + investing + financing (paise).
  final int netChangeInCash;

  /// Opening cash and cash equivalents at the start of the period (paise).
  final int openingCashPaise;

  /// Closing cash and cash equivalents at the end of the period (paise).
  final int closingCashPaise;

  final List<CashFlowLineItem> operatingLineItems;
  final List<CashFlowLineItem> investingLineItems;
  final List<CashFlowLineItem> financingLineItems;

  CashFlowStatement copyWith({
    int? financialYear,
    int? operatingActivitiesTotal,
    int? investingActivitiesTotal,
    int? financingActivitiesTotal,
    int? netChangeInCash,
    int? openingCashPaise,
    int? closingCashPaise,
    List<CashFlowLineItem>? operatingLineItems,
    List<CashFlowLineItem>? investingLineItems,
    List<CashFlowLineItem>? financingLineItems,
  }) {
    return CashFlowStatement(
      financialYear: financialYear ?? this.financialYear,
      operatingActivitiesTotal:
          operatingActivitiesTotal ?? this.operatingActivitiesTotal,
      investingActivitiesTotal:
          investingActivitiesTotal ?? this.investingActivitiesTotal,
      financingActivitiesTotal:
          financingActivitiesTotal ?? this.financingActivitiesTotal,
      netChangeInCash: netChangeInCash ?? this.netChangeInCash,
      openingCashPaise: openingCashPaise ?? this.openingCashPaise,
      closingCashPaise: closingCashPaise ?? this.closingCashPaise,
      operatingLineItems: operatingLineItems ?? this.operatingLineItems,
      investingLineItems: investingLineItems ?? this.investingLineItems,
      financingLineItems: financingLineItems ?? this.financingLineItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CashFlowStatement) return false;
    return other.financialYear == financialYear &&
        other.operatingActivitiesTotal == operatingActivitiesTotal &&
        other.investingActivitiesTotal == investingActivitiesTotal &&
        other.financingActivitiesTotal == financingActivitiesTotal &&
        other.netChangeInCash == netChangeInCash &&
        other.openingCashPaise == openingCashPaise &&
        other.closingCashPaise == closingCashPaise;
  }

  @override
  int get hashCode => Object.hash(
    financialYear,
    operatingActivitiesTotal,
    investingActivitiesTotal,
    financingActivitiesTotal,
    netChangeInCash,
    openingCashPaise,
    closingCashPaise,
  );
}
