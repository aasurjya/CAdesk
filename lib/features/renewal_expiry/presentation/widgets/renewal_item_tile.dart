import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/renewal_item.dart';

/// A card tile displaying a single renewal item with due-date badge and status.
class RenewalItemTile extends StatelessWidget {
  const RenewalItemTile({super.key, required this.item});

  final RenewalItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

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
              // Leading icon
              _ItemTypeIcon(itemType: item.itemType),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: client name and status chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Row 2: item type label
                    Text(
                      item.itemType.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Row 3: due date, days badge, fee
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: item.isOverdue
                              ? AppColors.error
                              : AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${dateFormat.format(item.dueDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: item.isOverdue
                                ? AppColors.error
                                : AppColors.neutral600,
                            fontSize: 11,
                            fontWeight: item.isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DaysBadge(item: item),
                        const Spacer(),
                        Text(
                          item.formattedFee,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Notes row (if non-empty)
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.notes_rounded,
                            size: 12,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.notes,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral400,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _ItemTypeIcon extends StatelessWidget {
  const _ItemTypeIcon({required this.itemType});

  final RenewalItemType itemType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(itemType.icon, size: 22, color: AppColors.primary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RenewalStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 10, color: status.color),
          const SizedBox(width: 3),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DaysBadge extends StatelessWidget {
  const _DaysBadge({required this.item});

  final RenewalItem item;

  @override
  Widget build(BuildContext context) {
    if (item.status == RenewalStatus.renewed ||
        item.status == RenewalStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final days = item.daysUntilDue;
    final Color badgeColor;
    final String label;

    if (item.isOverdue) {
      badgeColor = AppColors.error;
      label = '${days.abs()}d overdue';
    } else if (item.isDueSoon) {
      badgeColor = AppColors.warning;
      label = '${days}d left';
    } else {
      badgeColor = AppColors.success;
      label = '${days}d left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
