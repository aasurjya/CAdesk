import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/notice_resolution/data/providers/notice_resolution_providers.dart';

/// A compact row of four summary stat cards for the Notice Resolution Center.
class NoticeStatsCard extends ConsumerWidget {
  const NoticeStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(noticeSummaryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _StatTile(
            label: 'Total',
            count: summary['total'] ?? 0,
            icon: Icons.folder_open_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _StatTile(
            label: 'Critical',
            count: summary['critical'] ?? 0,
            icon: Icons.error_rounded,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          _StatTile(
            label: 'Due This Week',
            count: summary['dueThisWeek'] ?? 0,
            icon: Icons.schedule_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _StatTile(
            label: 'Closed',
            count: summary['closed'] ?? 0,
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private tile widget
// ---------------------------------------------------------------------------

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
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
