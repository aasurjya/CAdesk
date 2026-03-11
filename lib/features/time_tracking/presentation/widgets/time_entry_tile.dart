import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

/// A list tile representing a single time entry with billable indicator.
class TimeEntryTile extends StatelessWidget {
  const TimeEntryTile({super.key, required this.entry, this.onTap});

  final TimeEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Billable stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color:
                      entry.isBillable ? AppColors.success : AppColors.neutral400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task + status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.taskDescription,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: entry.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Client + staff
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            entry.clientName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.primary.withAlpha(26),
                            child: Text(
                              entry.staffInitials,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.staffName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Bottom row: time range, duration, billed
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _timeRange(timeFormat),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.formattedDuration,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (entry.isBillable && entry.billedAmount > 0)
                            Text(
                              '₹${entry.billedAmount.toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          if (!entry.isBillable)
                            Text(
                              'Non-billable',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.neutral400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeRange(DateFormat fmt) {
    final start = fmt.format(entry.startTime);
    if (entry.endTime != null) {
      return '$start — ${fmt.format(entry.endTime!)}';
    }
    return '$start — ongoing';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TimeEntryStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      TimeEntryStatus.running => (AppColors.success, Icons.play_arrow_rounded),
      TimeEntryStatus.paused => (AppColors.warning, Icons.pause_rounded),
      TimeEntryStatus.completed => (AppColors.primary, Icons.check_rounded),
      TimeEntryStatus.billed => (AppColors.secondary, Icons.receipt_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
