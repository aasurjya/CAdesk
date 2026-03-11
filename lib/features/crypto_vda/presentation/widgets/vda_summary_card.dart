import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';
import 'package:ca_app/features/crypto_vda/data/providers/crypto_vda_providers.dart';

/// Card displaying a single client's VDA tax summary with
/// tax liability highlight and loss restriction warning.
class VdaSummaryCard extends StatelessWidget {
  const VdaSummaryCard({super.key, required this.summary});

  final VdaSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    summary.clientName.isNotEmpty
                        ? summary.clientName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.clientName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'AY ${summary.assessmentYear} \u2022 '
                        '${summary.totalTransactions} transactions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tax liability badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tax',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        currencyFormat.format(summary.taxLiability),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Gains / Losses / Net
            Row(
              children: [
                _MetricChip(
                  label: 'Gains',
                  value: currencyFormat.format(summary.totalGains),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  label: 'Losses',
                  value: currencyFormat.format(summary.totalLosses),
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  label: 'Net Taxable',
                  value: currencyFormat.format(summary.netTaxableGain),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // TDS row
            Row(
              children: [
                _MetricChip(
                  label: 'TDS Collected',
                  value: currencyFormat.format(summary.tdsCollected),
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  label: 'TDS Shortfall',
                  value: currencyFormat.format(summary.tdsShortfall),
                  color: summary.tdsShortfall > 0
                      ? AppColors.warning
                      : AppColors.neutral400,
                ),
              ],
            ),
            // Loss restriction warning
            if (summary.hasLossRestrictionViolation) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gpp_bad_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Loss set-off restriction violated: Losses from one '
                        'VDA cannot be set off against gains from another '
                        '(Sec 115BBH)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small metric chip used in summary rows.
class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Overview card shown at the top of the Summaries tab with
/// aggregate tax metrics across all clients.
class VdaTaxOverviewCard extends ConsumerWidget {
  const VdaTaxOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(vdaTaxOverviewProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _OverviewMetric(
              label: 'Total Tax',
              value: '\u20B9${_formatCompact(overview.totalTaxLiability)}',
              color: AppColors.error,
              icon: Icons.receipt_long_rounded,
            ),
            const _VerticalDivider(),
            _OverviewMetric(
              label: 'TDS Collected',
              value: '\u20B9${_formatCompact(overview.totalTdsCollected)}',
              color: AppColors.success,
              icon: Icons.savings_rounded,
            ),
            const _VerticalDivider(),
            _OverviewMetric(
              label: 'TDS Gap',
              value: '\u20B9${_formatCompact(overview.totalTdsShortfall)}',
              color: AppColors.warning,
              icon: Icons.trending_down_rounded,
            ),
            const _VerticalDivider(),
            _OverviewMetric(
              label: 'Violations',
              value: overview.lossRestrictionViolations.toString(),
              color: overview.lossRestrictionViolations > 0
                  ? AppColors.error
                  : AppColors.neutral400,
              icon: Icons.gpp_bad_rounded,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCompact(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
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
    return Container(width: 1, height: 44, color: AppColors.neutral200);
  }
}
