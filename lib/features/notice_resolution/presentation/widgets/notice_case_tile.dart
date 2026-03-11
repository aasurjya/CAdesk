import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/notice_resolution/domain/models/notice_case.dart';

/// A card tile displaying a single notice case with severity, status, and
/// key details at a glance.
class NoticeCaseTile extends StatelessWidget {
  const NoticeCaseTile({super.key, required this.notice});

  final NoticeCase notice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = notice.daysLeft;
    final daysLabel = _buildDaysLabel(daysLeft);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading: severity icon
              _SeverityIcon(severity: notice.severity),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: client name + status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notice.clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: notice.status),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Row 2: section + notice type
                    Text(
                      '${notice.section} • ${notice.noticeType.label}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Row 3: days left + amount
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: daysLeft <= 7
                              ? AppColors.error
                              : AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          daysLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: daysLeft <= 7
                                ? AppColors.error
                                : AppColors.neutral400,
                            fontWeight: daysLeft <= 7
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          notice.formattedAmount,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildDaysLabel(int daysLeft) {
    if (daysLeft < 0) return 'Overdue by ${daysLeft.abs()}d';
    if (daysLeft == 0) return 'Due today';
    return 'Due in ${daysLeft}d';
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SeverityIcon extends StatelessWidget {
  const _SeverityIcon({required this.severity});

  final NoticeSeverity severity;

  IconData get _icon {
    switch (severity) {
      case NoticeSeverity.critical:
        return Icons.error_rounded;
      case NoticeSeverity.high:
        return Icons.warning_amber_rounded;
      case NoticeSeverity.medium:
        return Icons.info_rounded;
      case NoticeSeverity.low:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_icon, size: 22, color: severity.color),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final NoticeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
