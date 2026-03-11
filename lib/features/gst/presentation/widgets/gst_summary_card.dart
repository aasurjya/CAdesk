import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A compact summary card showing a numeric count, label, and optional trend.
class GstSummaryCard extends StatelessWidget {
  const GstSummaryCard({
    super.key,
    required this.label,
    required this.count,
    this.trendUp,
    this.color,
    this.icon,
  });

  final String label;
  final int count;

  /// `true` = up arrow, `false` = down arrow, `null` = no trend.
  final bool? trendUp;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: cardColor),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: cardColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (trendUp != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    trendUp! ? Icons.trending_up : Icons.trending_down,
                    size: 18,
                    color: trendUp! ? AppColors.success : AppColors.error,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
