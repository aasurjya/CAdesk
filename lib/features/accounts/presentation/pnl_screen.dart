import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/accounts_providers.dart';
import '../data/providers/balance_sheet_providers.dart';
import 'widgets/financial_line_item.dart';
import 'widgets/pnl_widgets.dart';

/// Profit & Loss statement screen with previous year comparison
/// and percentage analysis.
class PnlScreen extends ConsumerWidget {
  const PnlScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pnl = ref.watch(pnlStatementProvider(clientId));
    final clients = ref.watch(accountClientsProvider);
    final client = clients.where((c) => c.id == clientId).firstOrNull;

    if (pnl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profit & Loss')),
        body: const Center(
          child: Text('No P&L data available for this client'),
        ),
      );
    }

    final hasPrev = pnl.previousRevenueFromOperations != null;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Profit & Loss Statement',
          style: TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
            onPressed: () => _exportAction(context, 'PDF'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PnlHeader(
              companyName: client?.name ?? pnl.clientName,
              financialYear: pnl.financialYear,
            ),
            const SizedBox(height: 12),

            PnlProfitHighlight(pnl: pnl),
            const SizedBox(height: 14),

            PnlColumnHeaders(hasPreviousYear: hasPrev),
            const Divider(height: 1),

            // Income
            const PnlSectionLabel(title: 'INCOME', color: AppColors.success),
            FinancialLineItem(
              label: 'Revenue from Operations',
              currentYear: pnl.revenueFromOperations,
              previousYear: pnl.previousRevenueFromOperations,
              noteRef: 12,
            ),
            FinancialLineItem(
              label: 'Other Income',
              currentYear: pnl.otherIncome,
              previousYear: pnl.previousOtherIncome,
              noteRef: 13,
            ),
            const Divider(height: 1),
            FinancialLineItem(
              label: 'Total Income',
              currentYear: pnl.totalIncome,
              previousYear: pnl.previousTotalIncome,
              isBold: true,
              isSubtotal: true,
            ),
            const SizedBox(height: 8),

            // Expenses
            const PnlSectionLabel(title: 'EXPENSES', color: AppColors.error),
            FinancialLineItem(
              label: 'Cost of Materials Consumed',
              currentYear: pnl.costOfGoodsSold,
              previousYear: pnl.previousCostOfGoodsSold,
              noteRef: 14,
            ),
            FinancialLineItem(
              label: 'Employee Benefits Expense',
              currentYear: pnl.employeeBenefits,
              previousYear: pnl.previousEmployeeBenefits,
              noteRef: 15,
            ),
            FinancialLineItem(
              label: 'Depreciation & Amortisation',
              currentYear: pnl.depreciation,
              previousYear: pnl.previousDepreciation,
              noteRef: 16,
            ),
            FinancialLineItem(
              label: 'Other Expenses',
              currentYear: pnl.otherExpenses,
              previousYear: pnl.previousOtherExpenses,
              noteRef: 17,
            ),
            const Divider(height: 1),
            FinancialLineItem(
              label: 'Total Expenses',
              currentYear: pnl.totalExpenses,
              previousYear: _prevTotalExpenses(pnl),
              isBold: true,
              isSubtotal: true,
            ),
            const SizedBox(height: 8),

            // Profit
            const PnlSectionLabel(title: 'PROFIT', color: AppColors.primary),
            FinancialLineItem(
              label: 'Profit Before Tax',
              currentYear: pnl.profitBeforeTax,
              previousYear: _prevProfitBeforeTax(pnl),
              isBold: true,
            ),
            const Divider(height: 1),
            FinancialLineItem(
              label: 'Current Tax',
              currentYear: pnl.currentTax,
              previousYear: pnl.previousCurrentTax,
              indent: 1,
            ),
            FinancialLineItem(
              label: 'Deferred Tax',
              currentYear: pnl.deferredTax,
              previousYear: pnl.previousDeferredTax,
              indent: 1,
            ),
            FinancialLineItem(
              label: 'Tax Expense',
              currentYear: pnl.taxExpense,
              previousYear: _prevTaxExpense(pnl),
              isBold: true,
              isSubtotal: true,
            ),
            const Divider(height: 1),
            FinancialLineItem(
              label: 'Profit After Tax',
              currentYear: pnl.profitAfterTax,
              previousYear: _prevProfitAfterTax(pnl),
              isBold: true,
              isSubtotal: true,
            ),
            const SizedBox(height: 12),

            PnlEpsRow(epsBasic: pnl.epsBasic),
            const SizedBox(height: 14),

            PnlPercentageAnalysis(pnl: pnl),
            const SizedBox(height: 14),

            // Export buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportAction(context, 'PDF'),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('Export PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportAction(context, 'Excel'),
                    icon: const Icon(Icons.table_chart_rounded, size: 16),
                    label: const Text('Export Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  int? _prevTotalExpenses(PnlStatement pnl) {
    if (pnl.previousCostOfGoodsSold == null) return null;
    return (pnl.previousCostOfGoodsSold ?? 0) +
        (pnl.previousEmployeeBenefits ?? 0) +
        (pnl.previousDepreciation ?? 0) +
        (pnl.previousOtherExpenses ?? 0);
  }

  int? _prevProfitBeforeTax(PnlStatement pnl) {
    final prevIncome = pnl.previousTotalIncome;
    final prevExpenses = _prevTotalExpenses(pnl);
    if (prevIncome == null || prevExpenses == null) return null;
    return prevIncome - prevExpenses;
  }

  int? _prevTaxExpense(PnlStatement pnl) {
    if (pnl.previousCurrentTax == null) return null;
    return (pnl.previousCurrentTax ?? 0) + (pnl.previousDeferredTax ?? 0);
  }

  int? _prevProfitAfterTax(PnlStatement pnl) {
    final prevPbt = _prevProfitBeforeTax(pnl);
    final prevTax = _prevTaxExpense(pnl);
    if (prevPbt == null || prevTax == null) return null;
    return prevPbt - prevTax;
  }

  void _exportAction(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting P&L as $format...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
