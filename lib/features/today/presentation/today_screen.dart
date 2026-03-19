import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';

/// The "Today" tab screen — a daily digest of compliance obligations.
///
/// Groups deadlines into: Overdue, Due Today, This Week, and Later.
/// Provides a shortcut to the full Compliance Calendar.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDeadlines =
        ref.watch(allComplianceDeadlinesProvider).asData?.value ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));

    final overdue =
        allDeadlines
            .where(
              (d) =>
                  d.computedStatus != ComplianceStatus.completed &&
                  d.dueDate.isBefore(today),
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final dueToday =
        allDeadlines
            .where(
              (d) =>
                  d.computedStatus != ComplianceStatus.completed &&
                  d.dueDate.year == today.year &&
                  d.dueDate.month == today.month &&
                  d.dueDate.day == today.day,
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final thisWeek =
        allDeadlines
            .where(
              (d) =>
                  d.computedStatus != ComplianceStatus.completed &&
                  d.dueDate.isAfter(today) &&
                  !d.dueDate.isAfter(endOfWeek),
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final later =
        allDeadlines
            .where(
              (d) =>
                  d.computedStatus != ComplianceStatus.completed &&
                  d.dueDate.isAfter(endOfWeek),
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final dateFormatter = DateFormat('d MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(
              dateFormatter.format(now),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          if (overdue.isNotEmpty) ...[
            _SectionHeader(
              title: 'Overdue',
              color: AppColors.error,
              icon: Icons.warning_rounded,
              count: overdue.length,
            ),
            for (int i = 0; i < overdue.length; i++) ...[
              _DeadlineTile(deadline: overdue[i]),
              if (i < overdue.length - 1) const Divider(height: 1, indent: 72),
            ],
          ],
          _SectionHeader(
            title: 'Due Today',
            color: AppColors.warning,
            icon: Icons.today_rounded,
            count: dueToday.length,
          ),
          if (dueToday.isEmpty)
            const _EmptyState(message: 'Nothing due today.')
          else
            for (int i = 0; i < dueToday.length; i++) ...[
              _DeadlineTile(deadline: dueToday[i]),
              if (i < dueToday.length - 1) const Divider(height: 1, indent: 72),
            ],
          _SectionHeader(
            title: 'This Week',
            color: AppColors.primaryVariant,
            icon: Icons.date_range_rounded,
            count: thisWeek.length,
          ),
          if (thisWeek.isEmpty)
            const _EmptyState(message: 'Nothing due this week.')
          else
            for (int i = 0; i < thisWeek.length; i++) ...[
              _DeadlineTile(deadline: thisWeek[i]),
              if (i < thisWeek.length - 1) const Divider(height: 1, indent: 72),
            ],
          _SectionHeader(
            title: 'Later',
            color: AppColors.neutral600,
            icon: Icons.schedule_rounded,
            count: later.length,
          ),
          if (later.isEmpty)
            const _EmptyState(message: 'Nothing scheduled further out.')
          else
            for (int i = 0; i < later.length; i++) ...[
              _DeadlineTile(deadline: later[i]),
              if (i < later.length - 1) const Divider(height: 1, indent: 72),
            ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => context.push('/compliance'),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('View Full Calendar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.color,
    required this.icon,
    required this.count,
  });

  final String title;
  final Color color;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
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
    final dateFormatter = DateFormat('d MMM');
    final status = deadline.computedStatus;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: deadline.category.color.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          deadline.category.icon,
          color: deadline.category.color,
          size: 22,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              deadline.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _CategoryBadge(deadline: deadline),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            deadline.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: status.color,
              ),
              const SizedBox(width: 4),
              Text(
                dateFormatter.format(deadline.dueDate),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(status.icon, size: 12, color: status.color),
              const SizedBox(width: 4),
              Text(
                status.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: status.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.deadline});

  final ComplianceDeadline deadline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: deadline.category.color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        deadline.category.shortLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: deadline.category.color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.neutral400,
        ),
      ),
    );
  }
}
