import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/onboarding/domain/models/onboarding_checklist.dart';

/// Displays an onboarding checklist card with progress bar and item list.
class ChecklistProgress extends StatelessWidget {
  const ChecklistProgress({super.key, required this.checklist});

  final OnboardingChecklist checklist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = (checklist.overallProgress * 100).round();
    final progressColor = checklist.overallProgress >= 1.0
        ? AppColors.success
        : checklist.overallProgress >= 0.5
        ? AppColors.accent
        : AppColors.warning;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checklist.clientName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        checklist.serviceType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: checklist.overallProgress,
                        strokeWidth: 4,
                        backgroundColor: AppColors.neutral200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: checklist.overallProgress,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 12),
            // Checklist items
            ...checklist.items.map((item) => _ChecklistItemRow(item: item)),
            // Footer
            if (checklist.completedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed on ${_formatDate(checklist.completedAt!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// A single checklist item row with icon and label.
class _ChecklistItemRow extends StatelessWidget {
  const _ChecklistItemRow({required this.item});

  final ChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            item.isCompleted
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            size: 18,
            color: item.isCompleted ? AppColors.success : AppColors.neutral400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: item.isCompleted
                    ? AppColors.neutral400
                    : AppColors.neutral900,
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (item.isRequired)
            Text(
              'Required',
              style: theme.textTheme.labelSmall?.copyWith(
                color: item.isCompleted
                    ? AppColors.neutral400
                    : AppColors.error,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}
