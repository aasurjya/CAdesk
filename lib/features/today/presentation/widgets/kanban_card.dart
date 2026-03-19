import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';
import 'package:ca_app/core/widgets/urgency_border_card.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';

/// A compact card for displaying a compliance deadline inside a kanban column.
///
/// Shows: category badge, title, due date, and days-remaining pill.
/// Wraps content with [UrgencyBorderCard] for a colored left border.
class KanbanCard extends StatelessWidget {
  const KanbanCard({
    super.key,
    required this.deadline,
    this.onTap,
  });

  final ComplianceDeadline deadline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('d MMM');
    final urgencyColor = urgencyColorFromDays(
      deadline.daysRemaining,
      isCompleted: deadline.computedStatus == ComplianceStatus.completed,
    );

    return UrgencyBorderCard(
      urgencyColor: urgencyColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      onTap: onTap,
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryBadgeRow(deadline: deadline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              deadline.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            _DueDateRow(
              deadline: deadline,
              dateFormatter: dateFormatter,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadgeRow extends StatelessWidget {
  const _CategoryBadgeRow({required this.deadline});

  final ComplianceDeadline deadline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: deadline.category.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          deadline.category.shortLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: deadline.category.color,
          ),
        ),
      ],
    );
  }
}

class _DueDateRow extends StatelessWidget {
  const _DueDateRow({
    required this.deadline,
    required this.dateFormatter,
  });

  final ComplianceDeadline deadline;
  final DateFormat dateFormatter;

  @override
  Widget build(BuildContext context) {
    final status = deadline.computedStatus;
    final days = deadline.daysRemaining;

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 12,
          color: status.color,
        ),
        const SizedBox(width: 4),
        Text(
          dateFormatter.format(deadline.dueDate),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: status.color,
          ),
        ),
        const Spacer(),
        _DaysRemainingPill(days: days, status: status),
      ],
    );
  }
}

class _DaysRemainingPill extends StatelessWidget {
  const _DaysRemainingPill({
    required this.days,
    required this.status,
  });

  final int days;
  final ComplianceStatus status;

  @override
  Widget build(BuildContext context) {
    final label = _formatDaysLabel(days);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }

  static String _formatDaysLabel(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    if (days > 1) return '$days days';
    if (days == -1) return '1 day ago';
    return '${days.abs()} days ago';
  }
}
