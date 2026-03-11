import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';

/// A list tile for a compliance deadline, showing a category badge and countdown.
class DeadlineTile extends StatelessWidget {
  const DeadlineTile({super.key, required this.deadline, this.onTap});

  final ComplianceDeadline deadline;
  final VoidCallback? onTap;

  /// Returns the urgency color based on days remaining.
  Color _urgencyColor(int daysRemaining) {
    if (daysRemaining < 0) return AppColors.error;
    if (daysRemaining <= 3) return AppColors.error;
    if (daysRemaining <= 7) return AppColors.warning;
    return AppColors.success;
  }

  /// Returns a human-readable countdown label.
  String _countdownLabel(int daysRemaining) {
    if (daysRemaining < 0) {
      return '${daysRemaining.abs()}d overdue';
    }
    if (daysRemaining == 0) return 'Due today';
    if (daysRemaining == 1) return 'Tomorrow';
    return '$daysRemaining days';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final days = deadline.daysRemaining;
    final urgency = _urgencyColor(days);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Category badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: deadline.category.color.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  deadline.category.shortLabel,
                  style: TextStyle(
                    color: deadline.category.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(deadline.dueDate),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: deadline.category.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            deadline.frequency.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: deadline.category.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Countdown badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: urgency.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _countdownLabel(days),
                  style: TextStyle(
                    color: urgency,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
