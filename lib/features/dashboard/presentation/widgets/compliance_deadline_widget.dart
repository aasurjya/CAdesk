import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';

/// A compact card listing upcoming compliance deadlines.
///
/// Deadlines are sourced from [upcomingDeadlinesProvider] (compliance module)
/// instead of a hardcoded list. Each row shows a type badge, description,
/// due date, and a days-remaining pill coloured red (overdue), orange
/// (<=3 days), or green (safe). Tapping a deadline navigates to /compliance.
class ComplianceDeadlineWidget extends ConsumerWidget {
  const ComplianceDeadlineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlines = ref.watch(upcomingDeadlinesProvider);

    // Show at most 6 deadlines to keep the dashboard compact.
    final displayedDeadlines = deadlines.length > 6
        ? deadlines.sublist(0, 6)
        : deadlines;

    if (displayedDeadlines.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No upcoming deadlines',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral400),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedDeadlines.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _DeadlineTile(deadline: displayedDeadlines[index]);
          },
        ),
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({required this.deadline});

  final ComplianceDeadline deadline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = deadline.category.color;
    final days = deadline.daysRemaining;
    final pillColor = _pillColor(days);
    final pillText = _pillText(days);
    final dateLabel = DateFormat('MMM dd').format(deadline.dueDate);
    final periodDescription = deadline.description;

    return InkWell(
      onTap: () => context.go('/compliance'),
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: badgeColor.withAlpha(20),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            deadline.category.shortLabel,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        title: Text(
          deadline.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '$periodDescription · Due $dateLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: pillColor.withAlpha(20),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            pillText,
            style: TextStyle(
              color: pillColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Color _pillColor(int days) {
    if (days < 0) return AppColors.error;
    if (days <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String _pillText(int days) {
    if (days < 0) return '${days.abs()} days overdue';
    if (days == 0) return 'Today';
    return '$days days left';
  }
}
