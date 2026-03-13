import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/vda/data/providers/vda_providers.dart';
import 'package:ca_app/features/vda/domain/models/schedule_vda.dart';

/// VDA tax computation screen: income, 30% tax, no deductions, no set-off, TDS.
class VdaComputationScreen extends ConsumerWidget {
  const VdaComputationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleVdaProvider);
    final theme = Theme.of(context);

    final netBalance =
        schedule.taxAtFlatRatePaise - schedule.tdsDeducted1PercentPaise;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VDA Tax Computation',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RulesCard(),
            const SizedBox(height: 16),
            _ComputationCard(
              totalGainPaise: schedule.totalGainPaise,
              totalLossPaise: schedule.totalLossPaise,
              taxPaise: schedule.taxAtFlatRatePaise,
              tdsPaise: schedule.tdsDeducted1PercentPaise,
              netBalancePaise: netBalance,
              transactionCount: schedule.transactions.length,
            ),
            const SizedBox(height: 16),
            _TransactionBreakdown(schedule: schedule),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rules card
// ---------------------------------------------------------------------------

class _RulesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Section 115BBH Rules',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RuleItem(text: 'Flat 30% tax on gains (no slab benefit)'),
            _RuleItem(text: 'No deductions allowed except cost of acquisition'),
            _RuleItem(text: 'VDA losses cannot be set off against any income'),
            _RuleItem(text: 'No indexation benefit on cost'),
            _RuleItem(text: '1% TDS under Sec 194S by buyer'),
            _RuleItem(text: 'Cess @4% and surcharge applicable additionally'),
          ],
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 6, color: AppColors.neutral400),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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
// Computation card
// ---------------------------------------------------------------------------

class _ComputationCard extends StatelessWidget {
  const _ComputationCard({
    required this.totalGainPaise,
    required this.totalLossPaise,
    required this.taxPaise,
    required this.tdsPaise,
    required this.netBalancePaise,
    required this.transactionCount,
  });

  final int totalGainPaise;
  final int totalLossPaise;
  final int taxPaise;
  final int tdsPaise;
  final int netBalancePaise;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tax Computation — FY 2025-26',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$transactionCount transactions processed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: 16),
            _ComputeRow(
              label: 'A. Income from VDA (gains only)',
              value: _formatPaise(totalGainPaise),
              isTotal: false,
            ),
            _ComputeRow(
              label: 'B. Losses (disallowed for set-off)',
              value: '(${_formatPaise(totalLossPaise)})',
              isTotal: false,
              valueColor: AppColors.error,
            ),
            _ComputeRow(
              label: 'C. Tax @30% on (A)',
              value: _formatPaise(taxPaise),
              isTotal: false,
            ),
            _ComputeRow(
              label: 'D. TDS @1% credit (Sec 194S)',
              value: '(${_formatPaise(tdsPaise)})',
              isTotal: false,
              valueColor: AppColors.success,
            ),
            const Divider(height: 24),
            _ComputeRow(
              label: 'Net Tax Payable (C - D)',
              value: netBalancePaise > 0
                  ? _formatPaise(netBalancePaise)
                  : 'Nil (TDS sufficient)',
              isTotal: true,
              valueColor: netBalancePaise > 0 ? AppColors.error : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComputeRow extends StatelessWidget {
  const _ComputeRow({
    required this.label,
    required this.value,
    required this.isTotal,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal
                  ? theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    )
                  : theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
            ),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.neutral900,
                  )
                : theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.neutral900,
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction breakdown
// ---------------------------------------------------------------------------

class _TransactionBreakdown extends StatelessWidget {
  const _TransactionBreakdown({required this.schedule});

  final ScheduleVDA schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction-wise Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            ...schedule.transactions.map((t) {
              final gain = t.gainPaise;
              final isProfit = gain >= 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        t.assetName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatPaise(gain.abs()),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isProfit ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isProfit
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color: isProfit ? AppColors.success : AppColors.error,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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
