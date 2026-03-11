import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/sebi/domain/models/material_event.dart';

/// A card displaying a material event with urgency indicator.
class MaterialEventTile extends StatelessWidget {
  const MaterialEventTile({super.key, required this.event});

  final MaterialEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final now = DateTime(2026, 3, 10);
    final hoursLeft = event.hoursUntilDeadline(now);
    final isOverdue = event.isOverdue(now);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: company name and urgency indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.companyName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _UrgencyIndicator(
                    isDisclosed: event.isDisclosed,
                    isOverdue: isOverdue,
                    hoursLeft: hoursLeft,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Event type badge row
              Row(
                children: [
                  _EventTypeBadge(eventType: event.eventType),
                  const Spacer(),
                  if (event.isDisclosed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Disclosed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isOverdue ? AppColors.error : AppColors.warning)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.error_rounded
                                : Icons.schedule_rounded,
                            size: 12,
                            color: isOverdue
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue ? 'Not Disclosed' : 'Pending',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isOverdue
                                  ? AppColors.error
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                event.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Dates row
              Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Event: ${DateFormat('dd MMM yyyy').format(event.eventDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.timer_rounded,
                    size: 12,
                    color: isOverdue ? AppColors.error : AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${dateFormat.format(event.disclosureDeadline)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isOverdue ? AppColors.error : AppColors.neutral400,
                      fontWeight: isOverdue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),

              // Filing reference if present
              if (event.filingReference != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ref: ${event.filingReference}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Urgency indicator showing time-based urgency level.
class _UrgencyIndicator extends StatelessWidget {
  const _UrgencyIndicator({
    required this.isDisclosed,
    required this.isOverdue,
    required this.hoursLeft,
  });

  final bool isDisclosed;
  final bool isOverdue;
  final int hoursLeft;

  @override
  Widget build(BuildContext context) {
    if (isDisclosed) {
      return const SizedBox.shrink();
    }

    final Color color;
    final IconData icon;
    final String label;

    if (isOverdue) {
      color = AppColors.error;
      icon = Icons.error_rounded;
      label = 'OVERDUE';
    } else if (hoursLeft <= 24) {
      color = AppColors.error;
      icon = Icons.notification_important_rounded;
      label = '${hoursLeft}h left';
    } else if (hoursLeft <= 48) {
      color = AppColors.warning;
      icon = Icons.schedule_rounded;
      label = '${hoursLeft}h left';
    } else {
      color = AppColors.neutral400;
      icon = Icons.schedule_rounded;
      label = '${(hoursLeft / 24).ceil()}d left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge for material event type with icon.
class _EventTypeBadge extends StatelessWidget {
  const _EventTypeBadge({required this.eventType});

  final MaterialEventType eventType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: eventType.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(eventType.icon, size: 13, color: eventType.color),
          const SizedBox(width: 4),
          Text(
            eventType.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: eventType.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
