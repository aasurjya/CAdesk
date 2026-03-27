import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/accounts_providers.dart';
import '../data/providers/balance_sheet_providers.dart';
import 'widgets/balance_sheet_widgets.dart';
import 'widgets/financial_line_item.dart';

/// Full Schedule III Balance Sheet view with expandable sections,
/// previous year comparison, and export options.
class BalanceSheetScreen extends ConsumerWidget {
  const BalanceSheetScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison = ref.watch(balanceSheetComparisonProvider(clientId));
    final clients = ref.watch(accountClientsProvider);
    final client = clients.where((c) => c.id == clientId).firstOrNull;

    if (comparison == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Balance Sheet')),
        body: const Center(
          child: Text('No balance sheet data available for this client'),
        ),
      );
    }

    final bs = comparison.current;
    final prev = comparison.previous;
    final hasPrev = prev != null;
    final fy = 'FY ${bs.financialYear - 1}-${bs.financialYear % 100}';

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Balance Sheet', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
            onPressed: () => _exportAction(context, 'PDF'),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_rounded, size: 20),
            onPressed: () => _exportAction(context, 'Excel'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceSheetCompanyHeader(
              companyName: client?.name ?? 'Client',
              pan: client?.pan ?? '',
              financialYear: fy,
            ),
            const SizedBox(height: 12),

            BalanceCheckBanner(isBalanced: bs.isBalanced),
            const SizedBox(height: 14),

            BalanceSheetColumnHeaders(hasPreviousYear: hasPrev),
            const Divider(height: 1),

            // ========== ASSETS ==========
            const BalanceSheetSectionTitle(
              title: 'ASSETS',
              color: AppColors.primary,
            ),
            ..._buildAssetsSection(bs, prev),

            const SizedBox(height: 16),

            // ========== EQUITY & LIABILITIES ==========
            const BalanceSheetSectionTitle(
              title: 'EQUITY & LIABILITIES',
              color: AppColors.secondary,
            ),
            ..._buildEquitySection(bs, prev),

            const SizedBox(height: 16),

            BalanceSheetExportButtons(
              onPdf: () => _exportAction(context, 'PDF'),
              onExcel: () => _exportAction(context, 'Excel'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAssetsSection(dynamic bs, dynamic prev) {
    return [
      FinancialLineItem(
        label: 'Non-Current Assets',
        currentYear: bs.assets.totalNonCurrentAssets as int,
        previousYear: prev?.assets.totalNonCurrentAssets as int?,
        isBold: true,
        subItems: [
          FinancialLineItem(
            label: 'Property, Plant & Equipment',
            currentYear: bs.assets.fixedAssets as int,
            previousYear: prev?.assets.fixedAssets as int?,
            noteRef: 1,
            indent: 1,
          ),
          FinancialLineItem(
            label: 'Investments',
            currentYear: bs.assets.investments as int,
            previousYear: prev?.assets.investments as int?,
            noteRef: 2,
            indent: 1,
          ),
        ],
      ),
      const Divider(height: 1),
      FinancialLineItem(
        label: 'Current Assets',
        currentYear: bs.assets.totalCurrentAssets as int,
        previousYear: prev?.assets.totalCurrentAssets as int?,
        isBold: true,
        subItems: [
          FinancialLineItem(
            label: 'Inventories',
            currentYear: bs.assets.inventories as int,
            previousYear: prev?.assets.inventories as int?,
            noteRef: 3,
            indent: 1,
          ),
          FinancialLineItem(
            label: 'Trade Receivables',
            currentYear: bs.assets.tradeReceivables as int,
            previousYear: prev?.assets.tradeReceivables as int?,
            noteRef: 4,
            indent: 1,
          ),
          FinancialLineItem(
            label: 'Cash & Cash Equivalents',
            currentYear: bs.assets.cashAndCashEquivalents as int,
            previousYear: prev?.assets.cashAndCashEquivalents as int?,
            noteRef: 5,
            indent: 1,
          ),
          FinancialLineItem(
            label: 'Other Current Assets',
            currentYear: bs.assets.otherCurrentAssets as int,
            previousYear: prev?.assets.otherCurrentAssets as int?,
            noteRef: 6,
            indent: 1,
          ),
        ],
      ),
      const Divider(height: 1),
      FinancialLineItem(
        label: 'TOTAL ASSETS',
        currentYear: bs.totalAssets as int,
        previousYear: prev?.totalAssets as int?,
        isBold: true,
        isSubtotal: true,
      ),
    ];
  }

  List<Widget> _buildEquitySection(dynamic bs, dynamic prev) {
    return [
      FinancialLineItem(
        label: "Shareholders' Equity",
        currentYear: bs.equity.totalEquity as int,
        previousYear: prev?.equity.totalEquity as int?,
        isBold: true,
        subItems: [
          FinancialLineItem(
            label: 'Share Capital',
            currentYear: bs.equity.shareCapital as int,
            previousYear: prev?.equity.shareCapital as int?,
            noteRef: 7,
            indent: 1,
          ),
          FinancialLineItem(
            label: 'Reserves & Surplus',
            currentYear: bs.equity.reservesAndSurplus as int,
            previousYear: prev?.equity.reservesAndSurplus as int?,
            noteRef: 8,
            indent: 1,
          ),
        ],
      ),
      const Divider(height: 1),
      FinancialLineItem(
        label: 'Non-Current Liabilities',
        currentYear: bs.equity.totalNonCurrentLiabilities as int,
        previousYear: prev?.equity.totalNonCurrentLiabilities as int?,
        isBold: true,
        subItems: [
          FinancialLineItem(
            label: 'Long-Term Borrowings',
            currentYear: bs.equity.longTermBorrowings as int,
            previousYear: prev?.equity.longTermBorrowings as int?,
            noteRef: 9,
            indent: 1,
          ),
        ],
      ),
      const Divider(height: 1),
      FinancialLineItem(
        label: 'Current Liabilities',
        currentYear: bs.equity.totalCurrentLiabilities as int,
        previousYear: prev?.equity.totalCurrentLiabilities as int?,
        isBold: true,
        subItems: [
          FinancialLineItem(
            label: 'Trade Payables',
            currentYear: bs.equity.tradePayables as int,
            previousYear: prev?.equity.tradePayables as int?,
            noteRef: 10,
            indent: 1,
          ),
          FinancialLineItem(
            label: 'Other Current Liabilities',
            currentYear: bs.equity.otherCurrentLiabilities as int,
            previousYear: prev?.equity.otherCurrentLiabilities as int?,
            noteRef: 11,
            indent: 1,
          ),
        ],
      ),
      const Divider(height: 1),
      FinancialLineItem(
        label: 'TOTAL EQUITY & LIABILITIES',
        currentYear: bs.totalEquityAndLiabilities as int,
        previousYear: prev?.totalEquityAndLiabilities as int?,
        isBold: true,
        isSubtotal: true,
      ),
    ];
  }

  void _exportAction(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting Balance Sheet as $format...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
