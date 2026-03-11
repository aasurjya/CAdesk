import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_deliverable.dart';

/// A card tile displaying the details of a single CFO retainer deliverable.
class CfoDeliverableTile extends StatelessWidget {
  const CfoDeliverableTile({super.key, required this.deliverable});

  final CfoDeliverable deliverable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final isOverdue = deliverable.isOverdue;
    final daysLeft = deliverable.daysLeft;

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
              // Row 1: type icon + title + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypeIconBadge(type: deliverable.deliverableType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deliverable.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deliverable.clientName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DeliverableStatusBadge(status: deliverable.status),
                ],
              ),

              const SizedBox(height: 10),

              // Row 2: type label + due date + overdue warning
              Row(
                children: [
                  Icon(
                    deliverable.deliverableType.icon,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deliverable.deliverableType.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),

                  // Due date with overdue highlighting
                  if (isOverdue) ...[
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                  ] else ...[
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: daysLeft <= 3
                          ? AppColors.warning
                          : AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                  ],

                  Text(
                    isOverdue
                        ? 'Overdue · ${dateFormat.format(deliverable.dueDate)}'
                        : 'Due: ${dateFormat.format(deliverable.dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: isOverdue
                          ? AppColors.error
                          : daysLeft <= 3
                          ? AppColors.warning
                          : AppColors.neutral400,
                      fontWeight: isOverdue || daysLeft <= 3
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),

              // Completion info row (if completed)
              if (deliverable.completedAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed ${deliverable.timeAgo}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type icon badge
// ---------------------------------------------------------------------------

class _TypeIconBadge extends StatelessWidget {
  const _TypeIconBadge({required this.type});

  final DeliverableType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(type.icon, size: 20, color: AppColors.primary),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _DeliverableStatusBadge extends StatelessWidget {
  const _DeliverableStatusBadge({required this.status});

  final DeliverableStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
