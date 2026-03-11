import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/data/providers/crypto_vda_providers.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';

/// Full-screen TDS 194S tracking widget.
///
/// Displays:
/// - Table of transactions showing which had TDS deducted.
/// - Total TDS deducted this year.
/// - TDS credit available vs advance tax needed.
/// - Form 26AS reconciliation note.
class Tds194sWidget extends ConsumerWidget {
  const Tds194sWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<VdaTransaction> allTransactions = ref.watch(
      allVdaTransactionsProvider,
    );

    // Filter to only transactions that have a non-zero TDS value.
    final List<VdaTransaction> tdsTransactions = allTransactions
        .where((VdaTransaction t) => t.tdsUnder194S > 0)
        .toList();

    final double totalTds = tdsTransactions.fold(
      0,
      (double sum, VdaTransaction t) => sum + t.tdsUnder194S,
    );

    final VdaTaxOverview overview = ref.watch(vdaTaxOverviewProvider);
    final double advanceTaxNeeded = (overview.totalTaxLiability - totalTds)
        .clamp(0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TdsSummaryBanner(
          totalTds: totalTds,
          advanceTaxNeeded: advanceTaxNeeded,
          transactionCount: tdsTransactions.length,
        ),
        const SizedBox(height: 8),
        _Form26AsNote(),
        const SizedBox(height: 12),
        Expanded(
          child: tdsTransactions.isEmpty
              ? const _EmptyTdsState()
              : _TdsTransactionTable(transactions: tdsTransactions),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary banner
// ---------------------------------------------------------------------------

class _TdsSummaryBanner extends StatelessWidget {
  const _TdsSummaryBanner({
    required this.totalTds,
    required this.advanceTaxNeeded,
    required this.transactionCount,
  });

  final double totalTds;
  final double advanceTaxNeeded;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: AppColors.secondary.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _BannerMetric(
                icon: Icons.receipt_long_rounded,
                label: 'TDS Deducted\n(194S)',
                value: _formatCompact(totalTds),
                color: AppColors.secondary,
              ),
              const _VerticalDivider(),
              _BannerMetric(
                icon: Icons.swap_horiz_rounded,
                label: 'Transactions\nWith TDS',
                value: transactionCount.toString(),
                color: AppColors.primary,
              ),
              const _VerticalDivider(),
              _BannerMetric(
                icon: Icons.account_balance_rounded,
                label: 'Advance Tax\nNeeded',
                value: _formatCompact(advanceTaxNeeded),
                color: advanceTaxNeeded > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCompact(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    }
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

class _BannerMetric extends StatelessWidget {
  const _BannerMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: AppColors.neutral200);
  }
}

// ---------------------------------------------------------------------------
// Form 26AS note
// ---------------------------------------------------------------------------

class _Form26AsNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Form 26AS TDS credit reconciliation: Verify that all TDS '
                'amounts below are reflected in the client\'s Form 26AS / '
                'AIS before filing ITR. Discrepancies must be resolved with '
                'the exchange before the due date.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TDS transaction table
// ---------------------------------------------------------------------------

class _TdsTransactionTable extends StatelessWidget {
  const _TdsTransactionTable({required this.transactions});

  final List<VdaTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _TableHeader(theme: theme);
        }
        return _TdsTransactionRow(
          transaction: transactions[index - 1],
          isEven: index.isOdd,
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle =
        theme.textTheme.labelSmall?.copyWith(
          color: AppColors.neutral400,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Asset / Client', style: headerStyle)),
          Expanded(
            flex: 2,
            child: Text(
              'Sale Value',
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'TDS @1%',
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TdsTransactionRow extends StatelessWidget {
  const _TdsTransactionRow({required this.transaction, required this.isEven});

  final VdaTransaction transaction;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final DateFormat dateFmt = DateFormat('dd MMM yy');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isEven ? AppColors.neutral50 : AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.assetName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${transaction.clientName}  •  '
                  '${dateFmt.format(transaction.transactionDate)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              transaction.sellPrice > 0
                  ? fmt.format(transaction.sellPrice)
                  : '--',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fmt.format(transaction.tdsUnder194S),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: _TdsStatusChip(tdsDeducted: transaction.tdsUnder194S),
            ),
          ),
        ],
      ),
    );
  }
}

class _TdsStatusChip extends StatelessWidget {
  const _TdsStatusChip({required this.tdsDeducted});

  final double tdsDeducted;

  @override
  Widget build(BuildContext context) {
    final bool deducted = tdsDeducted > 0;
    final Color color = deducted ? AppColors.success : AppColors.warning;
    final String label = deducted ? 'Deducted' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyTdsState extends StatelessWidget {
  const _EmptyTdsState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 16),
          Text(
            'No TDS transactions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'TDS u/s 194S is deducted on VDA sale transactions.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
