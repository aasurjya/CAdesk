import 'package:ca_app/features/cma/domain/models/cma_balance_sheet.dart';
import 'package:ca_app/features/cma/domain/models/fund_flow_statement.dart';

/// Stateless singleton service that derives a Fund Flow Statement (CMA Form V)
/// from two consecutive year balance sheets.
///
/// Fund flow analysis explains how long-term funds moved during the year and
/// their impact on working capital. Banks use it to assess whether the
/// borrower is funding long-term assets with short-term bank finance.
///
/// All monetary values are in **paise** (1/100 rupee).
class FundFlowService {
  FundFlowService._();

  /// Singleton access point.
  static final FundFlowService instance = FundFlowService._();

  /// Derives a [FundFlowStatement] from [current] and [previous] year
  /// balance sheets.
  ///
  /// Sources of funds (long-term funds introduced):
  /// - Increase in long-term liabilities (new term debt raised)
  /// - Decrease in long-term assets (asset disposal proceeds)
  /// - Profit after tax + depreciation (internal accrual / non-cash)
  ///
  /// Uses of funds (long-term funds deployed):
  /// - Decrease in long-term liabilities (repayment of term debt)
  /// - Increase in long-term assets (capital expenditure)
  /// - Dividend paid (cash out to shareholders)
  FundFlowStatement computeFundFlow(
    CmaBalanceSheet current,
    CmaBalanceSheet previous,
  ) {
    final sources = <FundFlowItem>[];
    final uses = <FundFlowItem>[];

    // ── Long-term liabilities movement ──────────────────────────────────────
    final ltlDiff = current.longTermBorrowings - previous.longTermBorrowings;
    if (ltlDiff > 0) {
      sources.add(
        FundFlowItem(
          label: FundFlowLabel.increaseInLongTermLiabilities,
          amountPaise: ltlDiff,
        ),
      );
    } else if (ltlDiff < 0) {
      uses.add(
        FundFlowItem(
          label: FundFlowLabel.decreaseInLongTermLiabilities,
          amountPaise: -ltlDiff,
        ),
      );
    }

    // ── Long-term assets movement ────────────────────────────────────────────
    // Total long-term assets = netFixedAssets + longTermInvestments + other
    final prevLtAssets = _totalLongTermAssets(previous);
    final currLtAssets = _totalLongTermAssets(current);
    final ltaDiff = currLtAssets - prevLtAssets;

    if (ltaDiff > 0) {
      uses.add(
        FundFlowItem(
          label: FundFlowLabel.increaseInLongTermAssets,
          amountPaise: ltaDiff,
        ),
      );
    } else if (ltaDiff < 0) {
      sources.add(
        FundFlowItem(
          label: FundFlowLabel.decreaseInLongTermAssets,
          amountPaise: -ltaDiff,
        ),
      );
    }

    // ── Internal accrual (PAT + Depreciation) ───────────────────────────────
    final internalAccrual = current.profitAfterTax + current.depreciation;
    if (internalAccrual != 0) {
      sources.add(
        FundFlowItem(
          label: FundFlowLabel.profitAfterTaxPlusDepreciation,
          amountPaise: internalAccrual,
        ),
      );
    }

    // ── Dividend paid ────────────────────────────────────────────────────────
    if (current.dividendPaid > 0) {
      uses.add(
        FundFlowItem(
          label: FundFlowLabel.dividendPaid,
          amountPaise: current.dividendPaid,
        ),
      );
    }

    final totalSources = sources.fold<int>(0, (s, i) => s + i.amountPaise);
    final totalUses = uses.fold<int>(0, (s, i) => s + i.amountPaise);

    return FundFlowStatement(
      year: current.year,
      sourcesOfFunds: List.unmodifiable(sources),
      usesOfFunds: List.unmodifiable(uses),
      netChange: totalSources - totalUses,
      openingWorkingCapital: previous.workingCapital,
      closingWorkingCapital: current.workingCapital,
    );
  }

  int _totalLongTermAssets(CmaBalanceSheet bs) =>
      bs.netFixedAssets + bs.longTermInvestments + bs.otherLongTermAssets;
}
