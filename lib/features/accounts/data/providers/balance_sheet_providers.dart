import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/balance_sheet/schedule_iii_assets.dart';
import '../../domain/models/balance_sheet/schedule_iii_balance_sheet.dart';
import '../../domain/models/balance_sheet/schedule_iii_equity.dart';

// ---------------------------------------------------------------------------
// P&L statement model
// ---------------------------------------------------------------------------

/// Immutable Profit & Loss statement data for a client.
class PnlStatement {
  const PnlStatement({
    required this.clientId,
    required this.clientName,
    required this.financialYear,
    required this.revenueFromOperations,
    required this.otherIncome,
    required this.costOfGoodsSold,
    required this.employeeBenefits,
    required this.depreciation,
    required this.otherExpenses,
    required this.currentTax,
    required this.deferredTax,
    this.previousRevenueFromOperations,
    this.previousOtherIncome,
    this.previousCostOfGoodsSold,
    this.previousEmployeeBenefits,
    this.previousDepreciation,
    this.previousOtherExpenses,
    this.previousCurrentTax,
    this.previousDeferredTax,
    this.sharesOutstanding = 100000,
  });

  final String clientId;
  final String clientName;
  final String financialYear;

  // Current year (paise)
  final int revenueFromOperations;
  final int otherIncome;
  final int costOfGoodsSold;
  final int employeeBenefits;
  final int depreciation;
  final int otherExpenses;
  final int currentTax;
  final int deferredTax;

  // Previous year (paise, nullable)
  final int? previousRevenueFromOperations;
  final int? previousOtherIncome;
  final int? previousCostOfGoodsSold;
  final int? previousEmployeeBenefits;
  final int? previousDepreciation;
  final int? previousOtherExpenses;
  final int? previousCurrentTax;
  final int? previousDeferredTax;

  final int sharesOutstanding;

  int get totalIncome => revenueFromOperations + otherIncome;
  int get totalExpenses =>
      costOfGoodsSold + employeeBenefits + depreciation + otherExpenses;
  int get profitBeforeTax => totalIncome - totalExpenses;
  int get taxExpense => currentTax + deferredTax;
  int get profitAfterTax => profitBeforeTax - taxExpense;
  double get epsBasic =>
      sharesOutstanding > 0 ? profitAfterTax / sharesOutstanding / 100 : 0;

  int? get previousTotalIncome =>
      previousRevenueFromOperations != null && previousOtherIncome != null
      ? previousRevenueFromOperations! + previousOtherIncome!
      : null;
}

// ---------------------------------------------------------------------------
// Balance sheet comparison model
// ---------------------------------------------------------------------------

/// Current vs previous year balance sheet comparison.
class BalanceSheetComparison {
  const BalanceSheetComparison({required this.current, this.previous});

  final ScheduleIIIBalanceSheet current;
  final ScheduleIIIBalanceSheet? previous;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockBalanceSheets = <String, BalanceSheetComparison>{
  'acc-001': BalanceSheetComparison(
    current: ScheduleIIIBalanceSheet(
      financialYear: 2025,
      equity: const ScheduleIIIEquity(
        shareCapital: 500000000,
        reservesAndSurplus: 350000000,
        longTermBorrowings: 220000000,
        tradePayables: 180000000,
        otherCurrentLiabilities: 62000000,
      ),
      assets: const ScheduleIIIAssets(
        fixedAssets: 450000000,
        investments: 120000000,
        inventories: 280000000,
        tradeReceivables: 310000000,
        cashAndCashEquivalents: 95000000,
        otherCurrentAssets: 57000000,
      ),
      notes: const [],
    ),
    previous: ScheduleIIIBalanceSheet(
      financialYear: 2024,
      equity: const ScheduleIIIEquity(
        shareCapital: 500000000,
        reservesAndSurplus: 280000000,
        longTermBorrowings: 250000000,
        tradePayables: 160000000,
        otherCurrentLiabilities: 55000000,
      ),
      assets: const ScheduleIIIAssets(
        fixedAssets: 420000000,
        investments: 100000000,
        inventories: 260000000,
        tradeReceivables: 290000000,
        cashAndCashEquivalents: 80000000,
        otherCurrentAssets: 95000000,
      ),
      notes: const [],
    ),
  ),
  'acc-006': BalanceSheetComparison(
    current: ScheduleIIIBalanceSheet(
      financialYear: 2025,
      equity: const ScheduleIIIEquity(
        shareCapital: 1000000000,
        reservesAndSurplus: 560000000,
        longTermBorrowings: 450000000,
        tradePayables: 890000000,
        otherCurrentLiabilities: 150000000,
      ),
      assets: const ScheduleIIIAssets(
        fixedAssets: 980000000,
        investments: 340000000,
        inventories: 620000000,
        tradeReceivables: 780000000,
        cashAndCashEquivalents: 180000000,
        otherCurrentAssets: 150000000,
      ),
      notes: const [],
    ),
  ),
};

final _mockPnlStatements = <String, PnlStatement>{
  'acc-001': const PnlStatement(
    clientId: 'acc-001',
    clientName: 'Mehta Textiles Pvt Ltd',
    financialYear: 'FY 2024-25',
    revenueFromOperations: 4250000000,
    otherIncome: 35000000,
    costOfGoodsSold: 3570000000,
    employeeBenefits: 180000000,
    depreciation: 117950000,
    otherExpenses: 97050000,
    currentTax: 80000000,
    deferredTax: 8000000,
    previousRevenueFromOperations: 3800000000,
    previousOtherIncome: 28000000,
    previousCostOfGoodsSold: 3200000000,
    previousEmployeeBenefits: 165000000,
    previousDepreciation: 105000000,
    previousOtherExpenses: 88000000,
    previousCurrentTax: 68000000,
    previousDeferredTax: 6000000,
    sharesOutstanding: 500000,
  ),
  'acc-006': const PnlStatement(
    clientId: 'acc-006',
    clientName: 'Joshi Electronics Pvt Ltd',
    financialYear: 'FY 2024-25',
    revenueFromOperations: 7800000000,
    otherIncome: 45000000,
    costOfGoodsSold: 6600000000,
    employeeBenefits: 320000000,
    depreciation: 118750000,
    otherExpenses: 246250000,
    currentTax: 148000000,
    deferredTax: 12000000,
    previousRevenueFromOperations: 7100000000,
    previousOtherIncome: 38000000,
    previousCostOfGoodsSold: 6100000000,
    previousEmployeeBenefits: 290000000,
    previousDepreciation: 110000000,
    previousOtherExpenses: 228000000,
    previousCurrentTax: 120000000,
    previousDeferredTax: 10000000,
    sharesOutstanding: 1000000,
  ),
};

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Selected client's balance sheet (current + previous year).
final selectedBalanceSheetProvider =
    Provider.family<BalanceSheetComparison?, String>((ref, clientId) {
      return _mockBalanceSheets[clientId];
    });

/// Balance sheet comparison for a specific client.
final balanceSheetComparisonProvider =
    Provider.family<BalanceSheetComparison?, String>((ref, clientId) {
      return _mockBalanceSheets[clientId];
    });

/// P&L statement for a specific client.
final pnlStatementProvider = Provider.family<PnlStatement?, String>((
  ref,
  clientId,
) {
  return _mockPnlStatements[clientId];
});
