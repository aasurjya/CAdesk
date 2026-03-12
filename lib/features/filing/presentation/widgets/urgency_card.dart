import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/domain/models/filing_hub_item.dart';

/// A card widget showing an urgent filing item (overdue or due this week).
class UrgencyCard extends StatelessWidget {
  const UrgencyCard({super.key, required this.item, this.onTap});

  final FilingHubItem item;
  final VoidCallback? onTap;

  Color get _borderColor {
    return item.status == FilingHubStatus.overdue
        ? AppColors.error
        : AppColors.warning;
  }

  Color get _dueDateColor {
    return item.status == FilingHubStatus.overdue
        ? AppColors.error
        : AppColors.warning;
  }

  String get _dueDateLabel {
    final days = item.daysRemaining;
    if (days < 0) {
      final overdueDays = days.abs();
      return '$overdueDays ${overdueDays == 1 ? 'day' : 'days'} overdue';
    }
    if (days == 0) return 'Due today';
    return 'Due in $days ${days == 1 ? 'day' : 'days'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('d MMM');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.filingType.color.withAlpha(26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.filingType.shortLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: item.filingType.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(item.status.icon, size: 16, color: _borderColor),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.subType,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.clientName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: _dueDateColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${dateFormatter.format(item.dueDate)} · $_dueDateLabel',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _dueDateColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
