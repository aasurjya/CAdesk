import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../domain/models/compliance_deadline.dart';
import '../data/providers/compliance_providers.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

/// Compliance deadline detail screen with timeline view,
/// category-colored header, and action buttons.
///
/// Route: `/compliance/detail/:deadlineId`
class ComplianceDetailScreen extends ConsumerWidget {
  const ComplianceDetailScreen({required this.deadlineId, super.key});

  final String deadlineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(allComplianceDeadlinesProvider);
    final deadlines = deadlinesAsync.asData?.value ?? [];
    final deadline = deadlines.where((d) => d.id == deadlineId).firstOrNull;

    if (deadline == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compliance Detail')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: 16),
              const Text('Deadline not found'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final status = deadline.computedStatus;
    final catColor = deadline.category.color;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: catColor,
        foregroundColor: Colors.white,
        title: Text(
          deadline.category.label,
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            _HeaderCard(deadline: deadline, status: status),
            const SizedBox(height: 16),

            // Date & frequency details
            _DateInfoCard(deadline: deadline),
            const SizedBox(height: 16),

            // Applicable entities
            _ApplicableEntitiesCard(deadline: deadline),
            const SizedBox(height: 16),

            // Compliance timeline
            _ComplianceTimeline(deadline: deadline, status: status),
            const SizedBox(height: 16),

            // Related deadlines
            _RelatedDeadlinesCard(
              category: deadline.category,
              currentId: deadline.id,
              deadlines: deadlines,
            ),
            const SizedBox(height: 24),

            // Action buttons
            _ActionButtons(
              deadline: deadline,
              status: status,
              onMarkComplete: () {
                ref
                    .read(allComplianceDeadlinesProvider.notifier)
                    .markCompleted(deadline);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${deadline.title}" marked as completed'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.deadline, required this.status});

  final ComplianceDeadline deadline;
  final ComplianceStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = deadline.category.color;
    final daysLeft = deadline.daysRemaining;

    return Card(
      elevation: 0,
      color: catColor.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: catColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(deadline.category.icon, color: catColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    deadline.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusBadge(status: status),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _daysColor(daysLeft).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysLeft >= 0
                        ? '$daysLeft days left'
                        : '${daysLeft.abs()} days overdue',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _daysColor(daysLeft),
                    ),
                  ),
                ),
              ],
            ),
            if (deadline.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                deadline.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _daysColor(int days) {
    if (days < 0) return AppColors.error;
    if (days == 0) return AppColors.warning;
    if (days <= 7) return AppColors.warning;
    return AppColors.success;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ComplianceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date info card
// ---------------------------------------------------------------------------

class _DateInfoCard extends StatelessWidget {
  const _DateInfoCard({required this.deadline});

  final ComplianceDeadline deadline;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Due Date',
              value: _dateFmt.format(deadline.dueDate),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.repeat_rounded,
              label: 'Frequency',
              value: deadline.frequency.label,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.category_rounded,
              label: 'Category',
              value: deadline.category.label,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.loop_rounded,
              label: 'Recurring',
              value: deadline.isRecurring ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.neutral400),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.neutral400),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Applicable entities
// ---------------------------------------------------------------------------

class _ApplicableEntitiesCard extends StatelessWidget {
  const _ApplicableEntitiesCard({required this.deadline});

  final ComplianceDeadline deadline;

  @override
  Widget build(BuildContext context) {
    final entities = deadline.applicableTo.isEmpty
        ? ['All registered entities']
        : deadline.applicableTo;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applicable To',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entities
                  .map(
                    (e) => Chip(
                      label: Text(e, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.neutral100,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compliance timeline
// ---------------------------------------------------------------------------

class _ComplianceTimeline extends StatelessWidget {
  const _ComplianceTimeline({required this.deadline, required this.status});

  final ComplianceDeadline deadline;
  final ComplianceStatus status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == ComplianceStatus.completed;
    final steps = [
      _TimelineEntry(
        title: 'Deadline Created',
        subtitle: 'Added to compliance calendar',
        isComplete: true,
      ),
      _TimelineEntry(
        title: 'Reminder Sent',
        subtitle: '7 days before due date',
        isComplete: deadline.daysRemaining < 7 || isCompleted,
      ),
      _TimelineEntry(
        title: 'Due Date',
        subtitle: _dateFmt.format(deadline.dueDate),
        isComplete: deadline.daysRemaining <= 0 || isCompleted,
      ),
      _TimelineEntry(
        title: 'Completed',
        subtitle: isCompleted ? 'Marked as done' : 'Pending completion',
        isComplete: isCompleted,
      ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              final color = step.isComplete
                  ? AppColors.success
                  : AppColors.neutral300;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: step.isComplete
                                  ? color
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 2),
                            ),
                            child: step.isComplete
                                ? const Icon(
                                    Icons.check,
                                    size: 8,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: step.isComplete
                                    ? AppColors.success
                                    : AppColors.neutral200,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: step.isComplete
                                    ? AppColors.neutral900
                                    : AppColors.neutral400,
                              ),
                            ),
                            Text(
                              step.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.isComplete,
  });

  final String title;
  final String subtitle;
  final bool isComplete;
}

// ---------------------------------------------------------------------------
// Related deadlines
// ---------------------------------------------------------------------------

class _RelatedDeadlinesCard extends StatelessWidget {
  const _RelatedDeadlinesCard({
    required this.category,
    required this.currentId,
    required this.deadlines,
  });

  final ComplianceCategory category;
  final String currentId;
  final List<ComplianceDeadline> deadlines;

  @override
  Widget build(BuildContext context) {
    final related = deadlines
        .where((d) => d.category == category && d.id != currentId)
        .take(3)
        .toList();

    if (related.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related ${category.label} Deadlines',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...related.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      d.computedStatus.icon,
                      size: 16,
                      color: d.computedStatus.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _dateFmt.format(d.dueDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.deadline,
    required this.status,
    required this.onMarkComplete,
  });

  final ComplianceDeadline deadline;
  final ComplianceStatus status;
  final VoidCallback onMarkComplete;

  @override
  Widget build(BuildContext context) {
    if (status == ComplianceStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text(
              'This deadline has been completed',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onMarkComplete,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Mark as Completed'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reminder set for this deadline'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.notifications_active_rounded, size: 18),
          label: const Text('Set Reminder'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryVariant,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
