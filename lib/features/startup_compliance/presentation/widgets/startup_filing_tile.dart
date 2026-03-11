import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';

/// Tile displaying a startup filing with type icon,
/// deadline countdown, and status badge.
class StartupFilingTile extends StatelessWidget {
  const StartupFilingTile({super.key, required this.filing});

  final StartupFiling filing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final daysLeft = filing.daysUntilDue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Filing type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBackgroundColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                filing.filingType.icon,
                size: 20,
                color: _iconBackgroundColor,
              ),
            ),
            const SizedBox(width: 12),
            // Filing details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filing.filingType.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    filing.entityName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${dateFormat.format(filing.dueDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                      if (filing.filedDate != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Filed: ${dateFormat.format(filing.filedDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (filing.remarks != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      filing.remarks!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status + countdown column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: filing.status),
                const SizedBox(height: 6),
                if (filing.status == StartupFilingStatus.pending ||
                    filing.status == StartupFilingStatus.overdue)
                  _DeadlineCountdown(daysLeft: daysLeft),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _iconBackgroundColor {
    switch (filing.filingType) {
      case StartupFilingType.annualReturn:
        return AppColors.primary;
      case StartupFilingType.boardMeetingMinutes:
        return AppColors.secondary;
      case StartupFilingType.dpiitUpdate:
        return AppColors.accent;
      case StartupFilingType.form56:
        return const Color(0xFF6A1B9A);
      case StartupFilingType.itr:
        return AppColors.success;
      case StartupFilingType.gst:
        return const Color(0xFF1565C0);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StartupFilingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineCountdown extends StatelessWidget {
  const _DeadlineCountdown({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final isOverdue = daysLeft < 0;
    final color = isOverdue
        ? AppColors.error
        : daysLeft <= 7
            ? AppColors.warning
            : AppColors.neutral600;
    final label = isOverdue
        ? '${daysLeft.abs()}d overdue'
        : daysLeft == 0
            ? 'Due today'
            : '${daysLeft}d left';

    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
