import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/msme/data/providers/msme_providers.dart';

/// Dashboard card showing aggregated 43B(h) summary across all clients.
class MsmeSummaryCard extends ConsumerWidget {
  const MsmeSummaryCard({super.key, this.onViewDetails});

  final VoidCallback? onViewDetails;

  static final _compactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 1,
  );

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(msme43BhSummaryProvider);
    final allPayments = ref.watch(allMsmePaymentsProvider);
    final theme = Theme.of(context);

    final clientCount = allPayments.map((p) => p.clientId).toSet().length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sec 43B(h) Overview',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (summary.overdueCount > 0)
                  _AlertBadge(count: summary.overdueCount),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricTile(
                  label: 'Clients',
                  value: clientCount.toString(),
                  icon: Icons.business_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _MetricTile(
                  label: 'Disallowable',
                  value: _compactFormat.format(summary.totalDisallowable),
                  icon: Icons.block_outlined,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _MetricTile(
                  label: 'Interest',
                  value: _currencyFormat.format(summary.totalInterest),
                  icon: Icons.trending_up,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _MetricTile(
                  label: 'Overdue',
                  value: summary.overdueCount.toString(),
                  icon: Icons.schedule_outlined,
                  color: summary.overdueCount > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.chevron_right, size: 16),
                label: const Text('View Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.error, size: 12),
          const SizedBox(width: 4),
          Text(
            '$count overdue',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
