import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/reconciliation/data/providers/reconciliation_providers.dart';
import 'package:ca_app/features/reconciliation/domain/models/bank_recon_item.dart';
import 'package:ca_app/features/reconciliation/domain/models/bank_reconciliation.dart';

/// Bank statement vs books reconciliation view.
///
/// Shows balance comparison, unmatched transactions, and auto-match
/// suggestions for the selected bank account and period.
class BankReconScreen extends ConsumerWidget {
  const BankReconScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recon = ref.watch(bankReconciliationProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Reconciliation',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              '${recon.bankName} - ${recon.accountNumber}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isWide ? _WideLayout(recon: recon) : _NarrowLayout(recon: recon),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow layout
// ---------------------------------------------------------------------------

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.recon});

  final BankReconciliation recon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BalanceCards(recon: recon),
        const SizedBox(height: 14),
        _DifferenceCard(recon: recon),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Unmatched Transactions'),
        const SizedBox(height: 8),
        ...recon.unreconciledItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _BankTxTile(item: item),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Auto-Match Suggestions'),
        const SizedBox(height: 8),
        _AutoMatchSuggestions(recon: recon),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Matched Transactions'),
        const SizedBox(height: 8),
        ...recon.reconciledItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _BankTxTile(item: item),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Wide layout — side-by-side panels
// ---------------------------------------------------------------------------

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.recon});

  final BankReconciliation recon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 340,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceCards(recon: recon),
              const SizedBox(height: 14),
              _DifferenceCard(recon: recon),
              const SizedBox(height: 18),
              const _SectionLabel(title: 'Auto-Match Suggestions'),
              const SizedBox(height: 8),
              _AutoMatchSuggestions(recon: recon),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionLabel(title: 'Unmatched Transactions'),
              const SizedBox(height: 8),
              ...recon.unreconciledItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BankTxTile(item: item),
                ),
              ),
              const SizedBox(height: 18),
              const _SectionLabel(title: 'Matched Transactions'),
              const SizedBox(height: 8),
              ...recon.reconciledItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BankTxTile(item: item),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _BalanceCards extends StatelessWidget {
  const _BalanceCards({required this.recon});

  final BankReconciliation recon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BalanceChip(
            label: 'Bank Balance',
            amountPaise: recon.bankBalance,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BalanceChip(
            label: 'Book Balance',
            amountPaise: recon.bookBalance,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.amountPaise,
    required this.color,
  });

  final String label;
  final int amountPaise;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withAlpha(180),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatInr(amountPaise),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifferenceCard extends StatelessWidget {
  const _DifferenceCard({required this.recon});

  final BankReconciliation recon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = recon.bankBalance - recon.bookBalance;
    final isBalanced = recon.isBalanced;
    final color = isBalanced ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(
            isBalanced
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBalanced ? 'Balanced' : 'Difference',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (!isBalanced) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${diff > 0 ? "Bank higher by" : "Books higher by"} '
                    '${_formatInr(diff.abs())}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            'Period: ${recon.period}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.neutral900,
      ),
    );
  }
}

class _BankTxTile extends StatelessWidget {
  const _BankTxTile({required this.item});

  final BankReconItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = _statusStyle(item.status);
    final isDebit = item.type == TxType.debit;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (isDebit ? AppColors.error : AppColors.success)
                    .withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDebit
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
                color: isDebit ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.date.day}/${item.date.month}/${item.date.year}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isDebit ? "-" : "+"}${_formatInr(item.amount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDebit ? AppColors.error : AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static (String, Color) _statusStyle(ReconItemStatus status) {
    return switch (status) {
      ReconItemStatus.matched => ('Matched', AppColors.success),
      ReconItemStatus.unmatchedInBank => ('Bank Only', AppColors.error),
      ReconItemStatus.unmatchedInBooks => ('Books Only', AppColors.error),
      ReconItemStatus.timing => ('Timing', AppColors.accent),
    };
  }
}

class _AutoMatchSuggestions extends StatelessWidget {
  const _AutoMatchSuggestions({required this.recon});

  final BankReconciliation recon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Suggest matching timing items automatically
    final timingItems = recon.unreconciledItems
        .where((i) => i.status == ReconItemStatus.timing)
        .toList();

    if (timingItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            'No auto-match suggestions available.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${timingItems.length} timing difference(s) can be auto-matched '
              'once settlement clears.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 10),
            ...timingItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatInr(item.amount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auto-matching timing differences...'),
                  ),
                );
              },
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
              label: const Text('Auto-Match All'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
// Helpers
// ---------------------------------------------------------------------------

String _formatInr(int paise) {
  final rupees = paise ~/ 100;
  if (rupees >= 10000000) {
    return '${(rupees / 10000000).toStringAsFixed(2)} Cr';
  }
  if (rupees >= 100000) {
    return '${(rupees / 100000).toStringAsFixed(2)} L';
  }
  if (rupees >= 1000) {
    return '${(rupees / 1000).toStringAsFixed(1)}K';
  }
  return '$rupees';
}
