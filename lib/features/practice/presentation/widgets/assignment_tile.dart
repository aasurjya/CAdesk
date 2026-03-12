import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/data/providers/practice_providers.dart';

/// Tile showing a client-staff assignment with deadline and status.
class AssignmentTile extends StatelessWidget {
  const AssignmentTile({super.key, required this.assignment});

  final ClientAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  backgroundColor: AppColors.primary.withAlpha(18),
                  child: Text(
                    _initials(assignment.staffName),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
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
                        assignment.clientName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        assignment.staffName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: assignment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment.taskDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: _deadlineColor(assignment),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(assignment.deadline),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _deadlineColor(assignment),
                    fontWeight: FontWeight.w600,
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

  static String _formatDate(DateTime date) {
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

  static Color _deadlineColor(ClientAssignment a) {
    if (a.status == AssignmentStatus.overdue) return AppColors.error;
    final daysLeft = a.deadline.difference(DateTime.now()).inDays;
    if (daysLeft <= 3) return AppColors.warning;
    return AppColors.neutral400;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AssignmentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _chipColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color _chipColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return AppColors.success;
      case AssignmentStatus.overdue:
        return AppColors.error;
      case AssignmentStatus.inProgress:
        return AppColors.secondary;
      case AssignmentStatus.pending:
        return AppColors.accent;
    }
  }
}
