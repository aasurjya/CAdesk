import 'package:ca_app/features/xbrl/domain/models/xbrl_fact.dart';

// ---------------------------------------------------------------------------
// Input data models — Schedule III Balance Sheet (Companies Act 2013)
// ---------------------------------------------------------------------------

/// Immutable Schedule III Balance Sheet with all values in paise.
class ScheduleIIIBalanceSheet {
  const ScheduleIIIBalanceSheet({
    required this.cashAndCashEquivalents,
    required this.tradeReceivables,
    required this.propertyPlantAndEquipment,
    required this.inventories,
    required this.otherCurrentAssets,
    required this.otherNonCurrentAssets,
    required this.totalAssets,
    required this.shareCapital,
    required this.retainedEarnings,
    required this.otherReserves,
    required this.longTermBorrowings,
    required this.shortTermBorrowings,
    required this.tradePayables,
    required this.otherCurrentLiabilities,
    required this.otherNonCurrentLiabilities,
    required this.totalEquityAndLiabilities,
  });

  /// Cash and cash equivalents — instant, debit. In paise.
  final int cashAndCashEquivalents;

  /// Trade receivables (net of provisions) — instant, debit. In paise.
  final int tradeReceivables;

  /// Net property, plant and equipment — instant, debit. In paise.
  final int propertyPlantAndEquipment;

  /// Inventories — instant, debit. In paise.
  final int inventories;

  /// Other current assets — instant, debit. In paise.
  final int otherCurrentAssets;

  /// Other non-current assets — instant, debit. In paise.
  final int otherNonCurrentAssets;

  /// Total assets = total equity and liabilities. In paise.
  final int totalAssets;

  /// Paid-up share capital — instant, credit. In paise.
  final int shareCapital;

  /// Retained earnings / surplus — instant, credit. In paise.
  final int retainedEarnings;

  /// Other reserves and surplus — instant, credit. In paise.
  final int otherReserves;

  /// Long-term borrowings — instant, credit. In paise.
  final int longTermBorrowings;

  /// Short-term borrowings — instant, credit. In paise.
  final int shortTermBorrowings;

  /// Trade payables — instant, credit. In paise.
  final int tradePayables;

  /// Other current liabilities — instant, credit. In paise.
  final int otherCurrentLiabilities;

  /// Other non-current liabilities — instant, credit. In paise.
  final int otherNonCurrentLiabilities;

  /// Total equity and liabilities = total assets. In paise.
  final int totalEquityAndLiabilities;

  ScheduleIIIBalanceSheet copyWith({
    int? cashAndCashEquivalents,
    int? tradeReceivables,
    int? propertyPlantAndEquipment,
    int? inventories,
    int? otherCurrentAssets,
    int? otherNonCurrentAssets,
    int? totalAssets,
    int? shareCapital,
    int? retainedEarnings,
    int? otherReserves,
    int? longTermBorrowings,
    int? shortTermBorrowings,
    int? tradePayables,
    int? otherCurrentLiabilities,
    int? otherNonCurrentLiabilities,
    int? totalEquityAndLiabilities,
  }) {
    return ScheduleIIIBalanceSheet(
      cashAndCashEquivalents:
          cashAndCashEquivalents ?? this.cashAndCashEquivalents,
      tradeReceivables: tradeReceivables ?? this.tradeReceivables,
      propertyPlantAndEquipment:
          propertyPlantAndEquipment ?? this.propertyPlantAndEquipment,
      inventories: inventories ?? this.inventories,
      otherCurrentAssets: otherCurrentAssets ?? this.otherCurrentAssets,
      otherNonCurrentAssets:
          otherNonCurrentAssets ?? this.otherNonCurrentAssets,
      totalAssets: totalAssets ?? this.totalAssets,
      shareCapital: shareCapital ?? this.shareCapital,
      retainedEarnings: retainedEarnings ?? this.retainedEarnings,
      otherReserves: otherReserves ?? this.otherReserves,
      longTermBorrowings: longTermBorrowings ?? this.longTermBorrowings,
      shortTermBorrowings: shortTermBorrowings ?? this.shortTermBorrowings,
      tradePayables: tradePayables ?? this.tradePayables,
      otherCurrentLiabilities:
          otherCurrentLiabilities ?? this.otherCurrentLiabilities,
      otherNonCurrentLiabilities:
          otherNonCurrentLiabilities ?? this.otherNonCurrentLiabilities,
      totalEquityAndLiabilities:
          totalEquityAndLiabilities ?? this.totalEquityAndLiabilities,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleIIIBalanceSheet &&
        other.cashAndCashEquivalents == cashAndCashEquivalents &&
        other.tradeReceivables == tradeReceivables &&
        other.propertyPlantAndEquipment == propertyPlantAndEquipment &&
        other.inventories == inventories &&
        other.otherCurrentAssets == otherCurrentAssets &&
        other.otherNonCurrentAssets == otherNonCurrentAssets &&
        other.totalAssets == totalAssets &&
        other.shareCapital == shareCapital &&
        other.retainedEarnings == retainedEarnings &&
        other.otherReserves == otherReserves &&
        other.longTermBorrowings == longTermBorrowings &&
        other.shortTermBorrowings == shortTermBorrowings &&
        other.tradePayables == tradePayables &&
        other.otherCurrentLiabilities == otherCurrentLiabilities &&
        other.otherNonCurrentLiabilities == otherNonCurrentLiabilities &&
        other.totalEquityAndLiabilities == totalEquityAndLiabilities;
  }

  @override
  int get hashCode => Object.hashAll([
    cashAndCashEquivalents,
    tradeReceivables,
    propertyPlantAndEquipment,
    inventories,
    otherCurrentAssets,
    otherNonCurrentAssets,
    totalAssets,
    shareCapital,
    retainedEarnings,
    otherReserves,
    longTermBorrowings,
    shortTermBorrowings,
    tradePayables,
    otherCurrentLiabilities,
    otherNonCurrentLiabilities,
    totalEquityAndLiabilities,
  ]);
}

// ---------------------------------------------------------------------------
// P&L Statement (Schedule III)
// ---------------------------------------------------------------------------

/// Immutable Profit and Loss statement with all monetary values in paise
/// and EPS in paise per share.
class PnlStatement {
  const PnlStatement({
    required this.revenue,
    required this.costOfGoodsSold,
    required this.grossProfit,
    required this.operatingExpenses,
    required this.operatingProfit,
    required this.otherIncome,
    required this.profitBeforeTax,
    required this.taxExpense,
    required this.profitAfterTax,
    required this.basicEarningsPerShare,
    required this.dilutedEarningsPerShare,
    required this.depreciation,
    required this.financeCharges,
  });

  /// Revenue from operations — duration, credit. In paise.
  final int revenue;

  /// Cost of goods sold — duration, debit. In paise.
  final int costOfGoodsSold;

  /// Gross profit = revenue - COGS. In paise.
  final int grossProfit;

  /// Operating expenses (excluding COGS and depreciation). In paise.
  final int operatingExpenses;

  /// Operating profit (EBIT). In paise.
  final int operatingProfit;

  /// Other income (non-operating). In paise.
  final int otherIncome;

  /// Profit before tax. In paise.
  final int profitBeforeTax;

  /// Tax expense (current + deferred). In paise.
  final int taxExpense;

  /// Profit after tax (PAT). In paise.
  final int profitAfterTax;

  /// Basic EPS — in paise per share.
  final int basicEarningsPerShare;

  /// Diluted EPS — in paise per share.
  final int dilutedEarningsPerShare;

  /// Depreciation and amortisation. In paise.
  final int depreciation;

  /// Finance charges (interest expense). In paise.
  final int financeCharges;

  PnlStatement copyWith({
    int? revenue,
    int? costOfGoodsSold,
    int? grossProfit,
    int? operatingExpenses,
    int? operatingProfit,
    int? otherIncome,
    int? profitBeforeTax,
    int? taxExpense,
    int? profitAfterTax,
    int? basicEarningsPerShare,
    int? dilutedEarningsPerShare,
    int? depreciation,
    int? financeCharges,
  }) {
    return PnlStatement(
      revenue: revenue ?? this.revenue,
      costOfGoodsSold: costOfGoodsSold ?? this.costOfGoodsSold,
      grossProfit: grossProfit ?? this.grossProfit,
      operatingExpenses: operatingExpenses ?? this.operatingExpenses,
      operatingProfit: operatingProfit ?? this.operatingProfit,
      otherIncome: otherIncome ?? this.otherIncome,
      profitBeforeTax: profitBeforeTax ?? this.profitBeforeTax,
      taxExpense: taxExpense ?? this.taxExpense,
      profitAfterTax: profitAfterTax ?? this.profitAfterTax,
      basicEarningsPerShare:
          basicEarningsPerShare ?? this.basicEarningsPerShare,
      dilutedEarningsPerShare:
          dilutedEarningsPerShare ?? this.dilutedEarningsPerShare,
      depreciation: depreciation ?? this.depreciation,
      financeCharges: financeCharges ?? this.financeCharges,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PnlStatement &&
        other.revenue == revenue &&
        other.costOfGoodsSold == costOfGoodsSold &&
        other.grossProfit == grossProfit &&
        other.operatingExpenses == operatingExpenses &&
        other.operatingProfit == operatingProfit &&
        other.otherIncome == otherIncome &&
        other.profitBeforeTax == profitBeforeTax &&
        other.taxExpense == taxExpense &&
        other.profitAfterTax == profitAfterTax &&
        other.basicEarningsPerShare == basicEarningsPerShare &&
        other.dilutedEarningsPerShare == dilutedEarningsPerShare &&
        other.depreciation == depreciation &&
        other.financeCharges == financeCharges;
  }

  @override
  int get hashCode => Object.hashAll([
    revenue,
    costOfGoodsSold,
    grossProfit,
    operatingExpenses,
    operatingProfit,
    otherIncome,
    profitBeforeTax,
    taxExpense,
    profitAfterTax,
    basicEarningsPerShare,
    dilutedEarningsPerShare,
    depreciation,
    financeCharges,
  ]);
}

// ---------------------------------------------------------------------------
// Cash Flow Statement (indirect method)
// ---------------------------------------------------------------------------

/// Immutable indirect-method Cash Flow Statement with all values in paise.
class CashFlowStatement {
  const CashFlowStatement({
    required this.operatingActivities,
    required this.investingActivities,
    required this.financingActivities,
    required this.netCashChange,
    required this.openingCash,
    required this.closingCash,
  });

  /// Net cash from operating activities. In paise (may be negative).
  final int operatingActivities;

  /// Net cash from investing activities. In paise (typically negative).
  final int investingActivities;

  /// Net cash from financing activities. In paise.
  final int financingActivities;

  /// Net change in cash (operating + investing + financing). In paise.
  final int netCashChange;

  /// Opening cash balance. In paise.
  final int openingCash;

  /// Closing cash balance = opening + net change. In paise.
  final int closingCash;

  CashFlowStatement copyWith({
    int? operatingActivities,
    int? investingActivities,
    int? financingActivities,
    int? netCashChange,
    int? openingCash,
    int? closingCash,
  }) {
    return CashFlowStatement(
      operatingActivities: operatingActivities ?? this.operatingActivities,
      investingActivities: investingActivities ?? this.investingActivities,
      financingActivities: financingActivities ?? this.financingActivities,
      netCashChange: netCashChange ?? this.netCashChange,
      openingCash: openingCash ?? this.openingCash,
      closingCash: closingCash ?? this.closingCash,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashFlowStatement &&
        other.operatingActivities == operatingActivities &&
        other.investingActivities == investingActivities &&
        other.financingActivities == financingActivities &&
        other.netCashChange == netCashChange &&
        other.openingCash == openingCash &&
        other.closingCash == closingCash;
  }

  @override
  int get hashCode => Object.hash(
    operatingActivities,
    investingActivities,
    financingActivities,
    netCashChange,
    openingCash,
    closingCash,
  );
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Stateless singleton that maps Schedule III financial statements to
/// XBRL facts using the MCA in-gaap taxonomy.
///
/// All monetary inputs are in **paise** (integer).
/// All monetary fact values are in **INR** (paise ÷ 100), formatted as
/// `"NNN.NN"` with two decimal places.
///
/// EPS inputs are in paise-per-share; output is formatted as `"NN.NN"`.
class XbrlTagMappingService {
  XbrlTagMappingService._();

  static final XbrlTagMappingService instance = XbrlTagMappingService._();

  static const String _inrUnitRef = 'INR';

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Converts a paise integer to an INR string with two decimal places.
  static String _paiseToInr(int paise) {
    final inr = paise / 100.0;
    return inr.toStringAsFixed(2);
  }

  /// Converts a paise-per-share EPS integer to an INR-per-share string.
  static String _paiseToRupeeEps(int paisePerShare) {
    final inr = paisePerShare / 100.0;
    return inr.toStringAsFixed(2);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Maps [ScheduleIIIBalanceSheet] fields to XBRL facts using instant context
  /// [contextId] and the in-gaap taxonomy.
  List<XbrlFact> mapBalanceSheetToXbrl(
    ScheduleIIIBalanceSheet bs, {
    required String contextId,
  }) {
    return [
      XbrlFact(
        elementName: 'in-gaap:CashAndCashEquivalents',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.cashAndCashEquivalents),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:TradeReceivables',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.tradeReceivables),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:PropertyPlantAndEquipment',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.propertyPlantAndEquipment),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:Inventories',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.inventories),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:OtherCurrentAssets',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.otherCurrentAssets),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:Assets',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.totalAssets),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:ShareCapital',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.shareCapital),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:RetainedEarnings',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.retainedEarnings),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:ShortTermBorrowings',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.shortTermBorrowings),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:TradePayables',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.tradePayables),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:LongTermBorrowings',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.longTermBorrowings),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:EquityAndLiabilities',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(bs.totalEquityAndLiabilities),
        decimals: 0,
      ),
    ];
  }

  /// Maps [PnlStatement] fields to XBRL facts using duration context [contextId].
  List<XbrlFact> mapPnlToXbrl(
    PnlStatement pnl, {
    required String contextId,
  }) {
    return [
      XbrlFact(
        elementName: 'in-gaap:Revenue',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.revenue),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:CostOfGoodsSold',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.costOfGoodsSold),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:GrossProfit',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.grossProfit),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:OtherIncome',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.otherIncome),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:ProfitBeforeTax',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.profitBeforeTax),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:TaxExpense',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.taxExpense),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:ProfitAfterTax',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.profitAfterTax),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:Depreciation',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(pnl.depreciation),
        decimals: 0,
      ),
      // EPS — decimal type, no unit
      XbrlFact(
        elementName: 'in-gaap:BasicEarningsPerShare',
        contextRef: contextId,
        value: _paiseToRupeeEps(pnl.basicEarningsPerShare),
        decimals: 2,
      ),
      XbrlFact(
        elementName: 'in-gaap:DilutedEarningsPerShare',
        contextRef: contextId,
        value: _paiseToRupeeEps(pnl.dilutedEarningsPerShare),
        decimals: 2,
      ),
    ];
  }

  /// Maps [CashFlowStatement] fields to XBRL facts using duration context
  /// [contextId].
  List<XbrlFact> mapCashFlowToXbrl(
    CashFlowStatement cf, {
    required String contextId,
  }) {
    return [
      XbrlFact(
        elementName: 'in-gaap:CashFlowFromOperatingActivities',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(cf.operatingActivities),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:CashFlowFromInvestingActivities',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(cf.investingActivities),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:CashFlowFromFinancingActivities',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(cf.financingActivities),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:NetIncreaseDecreaseInCash',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(cf.netCashChange),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:CashAndCashEquivalentsAtBeginningOfPeriod',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(cf.openingCash),
        decimals: 0,
      ),
      XbrlFact(
        elementName: 'in-gaap:CashAndCashEquivalentsAtEndOfPeriod',
        contextRef: contextId,
        unitRef: _inrUnitRef,
        value: _paiseToInr(cf.closingCash),
        decimals: 0,
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Composite input for the document generator
// ---------------------------------------------------------------------------

/// Immutable composite input to [XbrlDocumentGenerator.generate].
class XbrlTagMappingInput {
  XbrlTagMappingInput({
    required this.instanceDocumentId,
    required this.companyName,
    required this.cin,
    required this.reportingPeriodStart,
    required this.reportingPeriodEnd,
    required this.balanceSheet,
    required this.pnl,
    required this.cashFlow,
  });

  final String instanceDocumentId;
  final String companyName;
  final String cin;
  final DateTime reportingPeriodStart;
  final DateTime reportingPeriodEnd;
  final ScheduleIIIBalanceSheet balanceSheet;
  final PnlStatement pnl;
  final CashFlowStatement cashFlow;

  XbrlTagMappingInput copyWith({
    String? instanceDocumentId,
    String? companyName,
    String? cin,
    DateTime? reportingPeriodStart,
    DateTime? reportingPeriodEnd,
    ScheduleIIIBalanceSheet? balanceSheet,
    PnlStatement? pnl,
    CashFlowStatement? cashFlow,
  }) {
    return XbrlTagMappingInput(
      instanceDocumentId: instanceDocumentId ?? this.instanceDocumentId,
      companyName: companyName ?? this.companyName,
      cin: cin ?? this.cin,
      reportingPeriodStart: reportingPeriodStart ?? this.reportingPeriodStart,
      reportingPeriodEnd: reportingPeriodEnd ?? this.reportingPeriodEnd,
      balanceSheet: balanceSheet ?? this.balanceSheet,
      pnl: pnl ?? this.pnl,
      cashFlow: cashFlow ?? this.cashFlow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XbrlTagMappingInput &&
        other.instanceDocumentId == instanceDocumentId &&
        other.companyName == companyName &&
        other.cin == cin &&
        other.reportingPeriodStart == reportingPeriodStart &&
        other.reportingPeriodEnd == reportingPeriodEnd &&
        other.balanceSheet == balanceSheet &&
        other.pnl == pnl &&
        other.cashFlow == cashFlow;
  }

  @override
  int get hashCode => Object.hash(
    instanceDocumentId,
    companyName,
    cin,
    reportingPeriodStart,
    reportingPeriodEnd,
    balanceSheet,
    pnl,
    cashFlow,
  );
}
