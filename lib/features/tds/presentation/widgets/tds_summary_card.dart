import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';

/// Displays four summary metrics: Total Deductors, Returns Due, Filed, Overdue.
class TdsSummaryCard extends ConsumerWidget {
  const TdsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(tdsSummaryProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _MetricTile(
              label: 'Deductors',
              value: summary.totalDeductors.toString(),
              color: AppColors.primary,
              icon: Icons.business_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Due',
              value: summary.returnsDue.toString(),
              color: AppColors.warning,
              icon: Icons.schedule_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Filed',
              value: summary.returnsFiled.toString(),
              color: AppColors.success,
              icon: Icons.check_circle_outline_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Overdue',
              value: summary.returnsOverdue.toString(),
              color: AppColors.error,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
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
    return Container(width: 1, height: 48, color: AppColors.neutral200);
  }
}
