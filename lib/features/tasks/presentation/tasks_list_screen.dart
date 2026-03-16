import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';
import 'package:ca_app/features/tasks/data/providers/task_providers.dart';
import 'package:ca_app/features/tasks/presentation/widgets/create_task_sheet.dart';
import 'package:ca_app/features/tasks/presentation/widgets/task_card.dart';

/// Full-featured task list screen with filtering, sorting, and swipe-to-complete.
class TasksListScreen extends ConsumerWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(allTasksProvider);
    final tasks = ref.watch(filteredTasksProvider);
    final counts = ref.watch(taskCountsProvider);
    final selectedFilter = ref.watch(taskStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            onPressed: () => _showSortMenu(context, ref),
          ),
        ],
      ),
      body: allTasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load tasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(allTasksProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (_) => Column(
          children: [
            // Summary filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  _SummaryChip(
                    label: 'All',
                    count: counts['all'] ?? 0,
                    isSelected: selectedFilter == 0,
                    onTap: () =>
                        ref.read(taskStatusFilterProvider.notifier).update(0),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Pending',
                    count: counts['pending'] ?? 0,
                    isSelected: selectedFilter == 1,
                    onTap: () =>
                        ref.read(taskStatusFilterProvider.notifier).update(1),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'In Progress',
                    count: counts['inProgress'] ?? 0,
                    isSelected: selectedFilter == 2,
                    onTap: () =>
                        ref.read(taskStatusFilterProvider.notifier).update(2),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Overdue',
                    count: counts['overdue'] ?? 0,
                    isSelected: selectedFilter == 3,
                    isUrgent: true,
                    onTap: () =>
                        ref.read(taskStatusFilterProvider.notifier).update(3),
                  ),
                ],
              ),
            ),
            // Task list
            Expanded(
              child: tasks.isEmpty
                  ? _EmptyState(hasFilters: selectedFilter != 0)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return GestureDetector(
                          onLongPressStart: (details) => _showTaskContextMenu(
                            context,
                            ref,
                            task,
                            details.globalPosition,
                          ),
                          child: TaskCard(
                            task: task,
                            onTap: () => _showTaskDetail(context, task),
                            onSwipeComplete: () =>
                                _completeTask(context, ref, task),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tasks_list_fab',
        onPressed: () => _showCreateTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _completeTask(BuildContext context, WidgetRef ref, Task task) {
    final originalTask = task;
    final completedTask = task.copyWith(
      status: TaskStatus.completed,
      completedDate: DateTime.now(),
    );
    ref.read(allTasksProvider.notifier).updateTask(completedTask);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" marked as completed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(allTasksProvider.notifier).updateTask(originalTask);
          },
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    task.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    label: 'Client',
                    value: task.clientName,
                    icon: Icons.person_outline_rounded,
                  ),
                  _DetailRow(
                    label: 'Type',
                    value: task.taskType.label,
                    icon: Icons.category_outlined,
                  ),
                  _DetailRow(
                    label: 'Due Date',
                    value: dateFormat.format(task.dueDate),
                    icon: Icons.calendar_today_rounded,
                  ),
                  _DetailRow(
                    label: 'Assigned To',
                    value: task.assignedTo,
                    icon: Icons.assignment_ind_outlined,
                  ),
                  _DetailRow(
                    label: 'Assigned By',
                    value: task.assignedBy,
                    icon: Icons.supervisor_account_outlined,
                  ),
                  if (task.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: task.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _FilterSheet(ref: ref);
      },
    );
  }

  void _showSortMenu(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(taskSortOptionProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sort By',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Due Date'),
                trailing: currentSort == TaskSortOption.dueDate
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref
                      .read(taskSortOptionProvider.notifier)
                      .update(TaskSortOption.dueDate);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Priority'),
                trailing: currentSort == TaskSortOption.priority
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref
                      .read(taskSortOptionProvider.notifier)
                      .update(TaskSortOption.priority);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Client Name'),
                trailing: currentSort == TaskSortOption.clientName
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref
                      .read(taskSortOptionProvider.notifier)
                      .update(TaskSortOption.clientName);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateTaskSheet(),
    );
  }

  void _showTaskContextMenu(
    BuildContext context,
    WidgetRef ref,
    Task task,
    Offset position,
  ) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: const [
        PopupMenuItem(value: 'status', child: Text('Change Status')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == null || !context.mounted) return;
      switch (value) {
        case 'status':
          _showChangeStatusDialog(context, ref, task);
        case 'delete':
          _showDeleteConfirmation(context, ref, task);
      }
    });
  }

  void _showChangeStatusDialog(BuildContext context, WidgetRef ref, Task task) {
    // Only allow transition to statuses that make sense (exclude overdue,
    // since that is derived from dates, not user-selected).
    const transitionStatuses = [
      TaskStatus.todo,
      TaskStatus.inProgress,
      TaskStatus.review,
      TaskStatus.completed,
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: transitionStatuses.map((status) {
              final isCurrentStatus = task.status == status;
              return ListTile(
                leading: Icon(
                  status.icon,
                  color: isCurrentStatus ? status.color : AppColors.neutral400,
                ),
                title: Text(
                  status.label,
                  style: TextStyle(
                    fontWeight: isCurrentStatus
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isCurrentStatus ? status.color : null,
                  ),
                ),
                trailing: isCurrentStatus
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: isCurrentStatus
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                        _changeTaskStatus(context, ref, task, status);
                      },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeTaskStatus(
    BuildContext context,
    WidgetRef ref,
    Task task,
    TaskStatus newStatus,
  ) async {
    try {
      await ref.read(allTasksProvider.notifier).changeStatus(task, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" moved to ${newStatus.label}'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text(
            'Are you sure you want to delete "${task.title}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteTask(context, ref, task);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    try {
      await ref.read(allTasksProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${task.title}" deleted')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.isUrgent = false,
  });

  final String label;
  final int count;
  final bool isSelected;
  final bool isUrgent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withAlpha(77)
                  : (isUrgent
                        ? AppColors.error.withAlpha(26)
                        : AppColors.neutral200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : (isUrgent ? AppColors.error : AppColors.neutral600),
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: isUrgent
          ? AppColors.error.withAlpha(40)
          : colorScheme.primaryContainer,
      checkmarkColor: isUrgent
          ? AppColors.error
          : colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? (isUrgent ? AppColors.error : colorScheme.onPrimaryContainer)
            : AppColors.neutral600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: isUrgent && !isSelected
          ? const BorderSide(color: AppColors.error, width: 0.5)
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.filter_list_off_rounded
                  : Icons.task_alt_outlined,
              size: 80,
              color: AppColors.neutral200,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching tasks' : 'No tasks yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters'
                  : 'Create a task to track your work',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentType = ref.watch(taskTypeFilterProvider);
    final currentPriority = ref.watch(taskPriorityFilterProvider);
    final currentAssignee = ref.watch(taskAssigneeFilterProvider);
    final assignees = ref.watch(taskAssigneesProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(taskTypeFilterProvider.notifier).update(null);
                    ref.read(taskPriorityFilterProvider.notifier).update(null);
                    ref.read(taskAssigneeFilterProvider.notifier).update(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Task type filter
            Text(
              'Task Type',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskType.values.map((type) {
                final selected = currentType == type;
                return FilterChip(
                  label: Text(type.label),
                  selected: selected,
                  onSelected: (val) {
                    ref
                        .read(taskTypeFilterProvider.notifier)
                        .update(val ? type : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Priority filter
            Text(
              'Priority',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((p) {
                final selected = currentPriority == p;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(p.icon, size: 14, color: p.color),
                      const SizedBox(width: 4),
                      Text(p.label),
                    ],
                  ),
                  selected: selected,
                  onSelected: (val) {
                    ref
                        .read(taskPriorityFilterProvider.notifier)
                        .update(val ? p : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Assignee filter
            Text(
              'Assignee',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: assignees.map((name) {
                final selected = currentAssignee == name;
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (val) {
                    ref
                        .read(taskAssigneeFilterProvider.notifier)
                        .update(val ? name : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
