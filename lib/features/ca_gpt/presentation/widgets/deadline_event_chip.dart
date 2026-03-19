import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/domain/services/tax_calendar_service.dart';

/// A compact chip that shows a tax deadline category on a calendar day.
class DeadlineEventChip extends StatelessWidget {
  const DeadlineEventChip({super.key, required this.deadline});

  final TaxDeadline deadline;

  Color get _color {
    switch (deadline.category) {
      case 'ITR':
        return AppColors.primary;
      case 'GST':
        return AppColors.secondary;
      case 'TDS':
        return AppColors.accent;
      case 'GST Annual':
        return const Color(0xFF6B46C1);
      case 'Advance Tax':
        return AppColors.error;
      default:
        return AppColors.neutral600;
    }
  }

  String get _shortLabel {
    switch (deadline.category) {
      case 'ITR':
        return 'ITR';
      case 'GST':
        return 'GST';
      case 'TDS':
        return 'TDS';
      case 'GST Annual':
        return 'GSTR-9';
      case 'Advance Tax':
        return 'ADV';
      default:
        return deadline.category.substring(
          0,
          deadline.category.length.clamp(0, 3),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withAlpha(80)),
      ),
      child: Text(
        _shortLabel,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

/// Expanded tile for a deadline in the list below the calendar grid.
class DeadlineListTile extends StatelessWidget {
  const DeadlineListTile({super.key, required this.deadline});

  final TaxDeadline deadline;

  Color get _color {
    switch (deadline.category) {
      case 'ITR':
        return AppColors.primary;
      case 'GST':
        return AppColors.secondary;
      case 'TDS':
        return AppColors.accent;
      case 'GST Annual':
        return const Color(0xFF6B46C1);
      case 'Advance Tax':
        return AppColors.error;
      default:
        return AppColors.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = deadline.date.day.toString().padLeft(2, '0');
    const months = [
      '',
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
    final dateLabel =
        '$day ${months[deadline.date.month]} ${deadline.date.year}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _color.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              deadline.category,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
