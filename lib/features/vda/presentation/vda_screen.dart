import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/vda/data/providers/vda_providers.dart';
import 'package:ca_app/features/vda/presentation/widgets/vda_transaction_tile.dart';

/// VDA portfolio screen: holdings, transactions, 30% tax, TDS 194S, loss warning.
class VdaScreen extends ConsumerWidget {
  const VdaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(vdaTransactionsProvider);
    final schedule = ref.watch(scheduleVdaProvider);
    final profitCount = ref.watch(vdaProfitableCountProvider);
    final lossCount = ref.watch(vdaLossCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VDA / Crypto Tax',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Section 115BBH & 194S compliance',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => context.push('/vda/compute'),
              icon: const Icon(Icons.calculate_rounded, size: 18),
              label: const Text('Compute'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PortfolioSummary(
              totalGainPaise: schedule.totalGainPaise,
              totalLossPaise: schedule.totalLossPaise,
              taxPaise: schedule.taxAtFlatRatePaise,
              tdsPaise: schedule.tdsDeducted1PercentPaise,
              profitCount: profitCount,
              lossCount: lossCount,
            ),
            if (schedule.totalLossPaise > 0) ...[
              const SizedBox(height: 12),
              _LossWarning(lossPaise: schedule.totalLossPaise),
            ],
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'Transactions',
              icon: Icons.swap_horiz_rounded,
            ),
            const SizedBox(height: 10),
            ...transactions.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VdaTransactionTile(transaction: t),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portfolio summary
// ---------------------------------------------------------------------------

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({
    required this.totalGainPaise,
    required this.totalLossPaise,
    required this.taxPaise,
    required this.tdsPaise,
    required this.profitCount,
    required this.lossCount,
  });

  final int totalGainPaise;
  final int totalLossPaise;
  final int taxPaise;
  final int tdsPaise;
  final int profitCount;
  final int lossCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              _MetricBox(
                label: 'Total Gains',
                value: _formatPaise(totalGainPaise),
                color: AppColors.success,
                subtitle: '$profitCount txn(s)',
              ),
              const SizedBox(width: 12),
              _MetricBox(
                label: 'Total Losses',
                value: _formatPaise(totalLossPaise),
                color: AppColors.error,
                subtitle: '$lossCount txn(s)',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricBox(
                label: 'Tax @30%',
                value: _formatPaise(taxPaise),
                color: AppColors.accent,
                subtitle: 'Sec 115BBH',
              ),
              const SizedBox(width: 12),
              _MetricBox(
                label: 'TDS @1%',
                value: _formatPaise(tdsPaise),
                color: AppColors.primary,
                subtitle: 'Sec 194S credit',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
    required this.subtitle,
  });

  final String label;
  final String value;
  final Color color;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loss disallowance warning
// ---------------------------------------------------------------------------

class _LossWarning extends StatelessWidget {
  const _LossWarning({required this.lossPaise});

  final int lossPaise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Loss of ${_formatPaise(lossPaise)} cannot be set off against '
              'gains or any other income (Sec 115BBH). Losses may only be '
              'carried forward against future VDA gains.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

String _formatPaise(int paise) {
  final rupees = paise ~/ 100;
  final absRupees = rupees.abs();
  if (absRupees >= 10000000) {
    return '\u20B9${(absRupees / 10000000).toStringAsFixed(2)} Cr';
  }
  if (absRupees >= 100000) {
    return '\u20B9${(absRupees / 100000).toStringAsFixed(2)} L';
  }
  if (absRupees >= 1000) {
    return '\u20B9${(absRupees / 1000).toStringAsFixed(1)}K';
  }
  return '\u20B9$absRupees';
}
