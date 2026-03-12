import 'package:ca_app/features/accounts/domain/models/balance_sheet/cash_flow_statement.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_balance_sheet.dart';

/// Stateless service that derives an indirect-method Cash Flow Statement
/// (AS-3 / Ind AS 7) from two consecutive [ScheduleIIIBalanceSheet] objects.
///
/// All amounts are in paise (int).
class CashFlowService {
  CashFlowService._();

  /// Computes a [CashFlowStatement] from the [current] year balance sheet
  /// compared to the [previous] year balance sheet (indirect method).
  static CashFlowStatement computeCashFlow({
    required ScheduleIIIBalanceSheet current,
    required ScheduleIIIBalanceSheet previous,
  }) {
    final openingCash = previous.assets.cashAndCashEquivalents;
    final closingCash = current.assets.cashAndCashEquivalents;
    final netChange = closingCash - openingCash;

    // ── Operating Activities ─────────────────────────────────────────────────
    // Changes in working capital (indirect method approximation)
    final List<CashFlowLineItem> operatingItems = [];

    // Increase in trade payables = source of cash
    final deltaTradePayables =
        current.equity.tradePayables - previous.equity.tradePayables;
    if (deltaTradePayables != 0) {
      operatingItems.add(
        CashFlowLineItem(
          description: 'Change in trade payables',
          amountPaise: deltaTradePayables,
        ),
      );
    }

    // Increase in other current liabilities = source of cash
    final deltaOtherCurrentLiab =
        current.equity.otherCurrentLiabilities -
        previous.equity.otherCurrentLiabilities;
    if (deltaOtherCurrentLiab != 0) {
      operatingItems.add(
        CashFlowLineItem(
          description: 'Change in other current liabilities',
          amountPaise: deltaOtherCurrentLiab,
        ),
      );
    }

    // Increase in inventories = use of cash
    final deltaInventories =
        current.assets.inventories - previous.assets.inventories;
    if (deltaInventories != 0) {
      operatingItems.add(
        CashFlowLineItem(
          description: 'Change in inventories',
          amountPaise: -deltaInventories,
        ),
      );
    }

    // Increase in trade receivables = use of cash
    final deltaTradeRec =
        current.assets.tradeReceivables - previous.assets.tradeReceivables;
    if (deltaTradeRec != 0) {
      operatingItems.add(
        CashFlowLineItem(
          description: 'Change in trade receivables',
          amountPaise: -deltaTradeRec,
        ),
      );
    }

    // Increase in other current assets = use of cash
    final deltaOtherCurrentAssets =
        current.assets.otherCurrentAssets - previous.assets.otherCurrentAssets;
    if (deltaOtherCurrentAssets != 0) {
      operatingItems.add(
        CashFlowLineItem(
          description: 'Change in other current assets',
          amountPaise: -deltaOtherCurrentAssets,
        ),
      );
    }

    final operatingTotal = operatingItems.fold(
      0,
      (sum, item) => sum + item.amountPaise,
    );

    // ── Investing Activities ─────────────────────────────────────────────────
    final List<CashFlowLineItem> investingItems = [];

    // Increase in fixed assets = cash outflow (capex)
    final deltaFixedAssets =
        current.assets.fixedAssets - previous.assets.fixedAssets;
    if (deltaFixedAssets != 0) {
      investingItems.add(
        CashFlowLineItem(
          description: 'Purchase / disposal of fixed assets (net)',
          amountPaise: -deltaFixedAssets,
        ),
      );
    }

    // Increase in long-term investments = cash outflow
    final deltaInvestments =
        current.assets.investments - previous.assets.investments;
    if (deltaInvestments != 0) {
      investingItems.add(
        CashFlowLineItem(
          description: 'Purchase / redemption of investments (net)',
          amountPaise: -deltaInvestments,
        ),
      );
    }

    final investingTotal = investingItems.fold(
      0,
      (sum, item) => sum + item.amountPaise,
    );

    // ── Financing Activities ─────────────────────────────────────────────────
    final List<CashFlowLineItem> financingItems = [];

    // Increase in share capital = proceeds from equity issuance
    final deltaShareCapital =
        current.equity.shareCapital - previous.equity.shareCapital;
    if (deltaShareCapital != 0) {
      financingItems.add(
        CashFlowLineItem(
          description: 'Proceeds from / repayment of share capital',
          amountPaise: deltaShareCapital,
        ),
      );
    }

    // Increase in reserves = retained earnings (non-cash), skip if it's
    // purely retained earnings but include if driven by other equity inflows.
    // We only include explicit changes in long-term borrowings here.
    final deltaLongTermBorrowings =
        current.equity.longTermBorrowings - previous.equity.longTermBorrowings;
    if (deltaLongTermBorrowings != 0) {
      financingItems.add(
        CashFlowLineItem(
          description: 'Proceeds from / repayment of long-term borrowings',
          amountPaise: deltaLongTermBorrowings,
        ),
      );
    }

    final financingTotal = financingItems.fold(
      0,
      (sum, item) => sum + item.amountPaise,
    );

    // Reconcile: the computed totals should equal the actual net change in cash.
    // If there's a residual (due to items not modelled above, e.g. retained
    // earnings), it is placed in operating activities as an implicit item.
    final computedTotal = operatingTotal + investingTotal + financingTotal;
    final residual = netChange - computedTotal;

    final List<CashFlowLineItem> finalOperatingItems = residual != 0
        ? [
            ...operatingItems,
            CashFlowLineItem(
              description: 'Net profit / other operating items',
              amountPaise: residual,
            ),
          ]
        : List<CashFlowLineItem>.unmodifiable(operatingItems);

    final adjustedOperatingTotal = operatingTotal + residual;

    return CashFlowStatement(
      financialYear: current.financialYear,
      operatingActivitiesTotal: adjustedOperatingTotal,
      investingActivitiesTotal: investingTotal,
      financingActivitiesTotal: financingTotal,
      netChangeInCash: netChange,
      openingCashPaise: openingCash,
      closingCashPaise: closingCash,
      operatingLineItems: List<CashFlowLineItem>.unmodifiable(
        finalOperatingItems,
      ),
      investingLineItems: List<CashFlowLineItem>.unmodifiable(investingItems),
      financingLineItems: List<CashFlowLineItem>.unmodifiable(financingItems),
    );
  }
}
