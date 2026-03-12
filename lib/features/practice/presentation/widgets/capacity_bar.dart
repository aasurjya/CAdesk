import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/data/providers/practice_providers.dart';

/// Bar showing a team member's utilization with color coding.
///
/// Red if >100%, amber if >80%, green otherwise.
class CapacityBar extends StatelessWidget {
  const CapacityBar({
    super.key,
    required this.member,
    required this.onReassign,
  });

  final TeamMember member;
  final VoidCallback onReassign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final utilization = member.utilization;
    final barColor = _utilizationColor(utilization);
    final isOverloaded = utilization > 100;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: barColor.withAlpha(24),
                  child: Text(
                    _initials(member.name),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: barColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        member.role.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${utilization.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: barColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (utilization / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.neutral100,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${member.assignedHours}h / ${member.capacityHours}h',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                if (isOverloaded)
                  TextButton.icon(
                    onPressed: onReassign,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: const Text('Reassign'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      textStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  static Color _utilizationColor(double utilization) {
    if (utilization > 100) return AppColors.error;
    if (utilization > 80) return AppColors.warning;
    return AppColors.success;
  }
}
