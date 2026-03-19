// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data models
// ---------------------------------------------------------------------------

class _TaskDetail {
  const _TaskDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.assignee,
    required this.reviewer,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.estimatedHours,
    required this.loggedHours,
    required this.subtasks,
    required this.timeEntries,
    required this.comments,
    required this.tags,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String clientName;
  final String assignee;
  final String reviewer;
  final _Priority priority;
  final _Status status;
  final DateTime dueDate;
  final double estimatedHours;
  final double loggedHours;
  final List<_Subtask> subtasks;
  final List<_TimeEntry> timeEntries;
  final List<_Comment> comments;
  final List<String> tags;
  final DateTime createdAt;
}

enum _Priority {
  critical('Critical', AppColors.error, Icons.error_rounded),
  high('High', Color(0xFFE65100), Icons.arrow_upward_rounded),
  medium('Medium', AppColors.warning, Icons.remove_rounded),
  low('Low', AppColors.success, Icons.arrow_downward_rounded);

  const _Priority(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

enum _Status {
  todo('To Do', AppColors.neutral400, Icons.circle_outlined),
  inProgress('In Progress', AppColors.primary, Icons.play_circle_rounded),
  review('In Review', AppColors.secondary, Icons.rate_review_rounded),
  completed('Completed', AppColors.success, Icons.check_circle_rounded);

  const _Status(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class _Subtask {
  const _Subtask({required this.title, required this.isCompleted});
  final String title;
  final bool isCompleted;
}

class _TimeEntry {
  const _TimeEntry({
    required this.date,
    required this.hours,
    required this.description,
  });
  final String date;
  final double hours;
  final String description;
}

class _Comment {
  const _Comment({
    required this.author,
    required this.date,
    required this.text,
  });
  final String author;
  final String date;
  final String text;
}

_TaskDetail _mockTask(String taskId) {
  return _TaskDetail(
    id: taskId,
    title: 'ITR Filing - Rajesh Sharma AY 2025-26',
    description:
        'Complete ITR-1 filing for Rajesh Sharma for Assessment Year 2025-26. '
        'Client has salary income, house property, and interest income. '
        'Form 16 and bank statements have been received.',
    clientName: 'Rajesh Sharma',
    assignee: 'Ananya Desai',
    reviewer: 'Suresh Iyer',
    priority: _Priority.high,
    status: _Status.inProgress,
    dueDate: DateTime(2026, 3, 31),
    estimatedHours: 6,
    loggedHours: 3.5,
    subtasks: const [
      _Subtask(title: 'Collect Form 16 and documents', isCompleted: true),
      _Subtask(title: 'Verify AIS/26AS reconciliation', isCompleted: true),
      _Subtask(title: 'Prepare income computation', isCompleted: false),
      _Subtask(title: 'Client review and approval', isCompleted: false),
      _Subtask(title: 'File on IT portal', isCompleted: false),
    ],
    timeEntries: const [
      _TimeEntry(
        date: '14 Mar 2026',
        hours: 1.5,
        description: 'Document collection and AIS download',
      ),
      _TimeEntry(
        date: '15 Mar 2026',
        hours: 2.0,
        description: 'Reconciliation and income computation',
      ),
    ],
    comments: const [
      _Comment(
        author: 'Ananya Desai',
        date: '15 Mar 2026',
        text:
            'Reconciliation complete. Minor mismatch in interest '
            'income from SBI — verified and adjusted.',
      ),
      _Comment(
        author: 'Suresh Iyer',
        date: '14 Mar 2026',
        text:
            'Please double-check the HRA exemption calculation. '
            'Client mentioned rent increase from Sep 2025.',
      ),
    ],
    tags: ['ITR', 'Individual', 'Priority Client'],
    createdAt: DateTime(2026, 3, 1),
  );
}

/// Full task detail/edit view with title, description, assignee, subtasks,
/// time entries, comments, and status change actions.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = _mockTask(taskId);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title and priority
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _PriorityBadge(priority: task.priority),
            ],
          ),
          const SizedBox(height: 12),

          // Status buttons
          _StatusRow(current: task.status),
          const SizedBox(height: 16),

          // Description
          Text(
            task.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Metadata
          _MetadataCard(task: task, dateFormat: dateFormat),
          const SizedBox(height: 16),

          // Progress bar
          _ProgressCard(task: task),
          const SizedBox(height: 16),

          // Subtasks
          _SubtasksSection(subtasks: task.subtasks),
          const SizedBox(height: 16),

          // Time entries
          _TimeEntriesSection(entries: task.timeEntries),
          const SizedBox(height: 16),

          // Tags
          if (task.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.primary.withAlpha(15),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Comments
          _CommentsSection(comments: task.comments),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status row
// ---------------------------------------------------------------------------

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.current});

  final _Status current;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _Status.values.map((status) {
          final isCurrent = status == current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status.icon,
                    size: 16,
                    color: isCurrent ? Colors.white : status.color,
                  ),
                  const SizedBox(width: 4),
                  Text(status.label),
                ],
              ),
              selected: isCurrent,
              selectedColor: status.color,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrent ? Colors.white : AppColors.neutral600,
              ),
              onSelected: (_) {},
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Priority badge
// ---------------------------------------------------------------------------

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final _Priority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: priority.color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 14, color: priority.color),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metadata card
// ---------------------------------------------------------------------------

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.task, required this.dateFormat});

  final _TaskDetail task;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MetaRow(
              icon: Icons.person_outline_rounded,
              label: 'Client',
              value: task.clientName,
              theme: theme,
            ),
            _MetaRow(
              icon: Icons.assignment_ind_outlined,
              label: 'Assignee',
              value: task.assignee,
              theme: theme,
            ),
            _MetaRow(
              icon: Icons.supervisor_account_outlined,
              label: 'Reviewer',
              value: task.reviewer,
              theme: theme,
            ),
            _MetaRow(
              icon: Icons.calendar_today_rounded,
              label: 'Due Date',
              value: dateFormat.format(task.dueDate),
              theme: theme,
            ),
            _MetaRow(
              icon: Icons.timer_outlined,
              label: 'Est. Hours',
              value: '${task.estimatedHours}h',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral400),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress card
// ---------------------------------------------------------------------------

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.task});

  final _TaskDetail task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = task.estimatedHours > 0
        ? (task.loggedHours / task.estimatedHours).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time Progress',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${task.loggedHours}h / ${task.estimatedHours}h',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.neutral100,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 0.9 ? AppColors.warning : AppColors.primary,
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
// Subtasks section
// ---------------------------------------------------------------------------

class _SubtasksSection extends StatelessWidget {
  const _SubtasksSection({required this.subtasks});

  final List<_Subtask> subtasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = subtasks.where((s) => s.isCompleted).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtasks',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$completedCount/${subtasks.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...subtasks.map(
              (subtask) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      subtask.isCompleted
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 20,
                      color: subtask.isCompleted
                          ? AppColors.success
                          : AppColors.neutral400,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: subtask.isCompleted
                              ? AppColors.neutral400
                              : AppColors.neutral900,
                        ),
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
// Time entries section
// ---------------------------------------------------------------------------

class _TimeEntriesSection extends StatelessWidget {
  const _TimeEntriesSection({required this.entries});

  final List<_TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Entries',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...entries.map(
              (entry) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: AppColors.neutral400,
                ),
                title: Text(
                  entry.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  entry.date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                trailing: Text(
                  '${entry.hours}h',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
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
// Comments section
// ---------------------------------------------------------------------------

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({required this.comments});

  final List<_Comment> comments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...comments.map(
              (comment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.author,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            comment.date,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        comment.text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  onPressed: () {},
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
