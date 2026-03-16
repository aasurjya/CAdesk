import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/tasks/data/providers/task_repository_providers.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';
import 'package:ca_app/features/tasks/domain/repositories/task_repository.dart';

/// All tasks available in the system, backed by [TaskRepository].
final allTasksProvider = AsyncNotifierProvider<AllTasksNotifier, List<Task>>(
  AllTasksNotifier.new,
);

class AllTasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return _fetchAndWatch(repo);
  }

  Future<List<Task>> _fetchAndWatch(TaskRepository repo) async {
    final stream = repo.watchAll();

    // Subscribe to local stream for live updates.
    final sub = stream.listen((tasks) {
      if (state.hasValue) {
        state = AsyncData(List.unmodifiable(tasks));
      }
    });
    ref.onDispose(sub.cancel);

    // Fetch from remote to populate local cache; fall back to stream on error.
    try {
      return List.unmodifiable(await repo.getAll());
    } catch (_) {
      return stream.first;
    }
  }

  /// Replaces the task with [updated.id] in the state list immutably.
  void updateTask(Task updated) {
    final current = state.asData?.value ?? [];
    final idx = current.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    final next = List<Task>.of(current)..[idx] = updated;
    state = AsyncData(List.unmodifiable(next));
  }

  /// Creates a new task via the repository and prepends it to the list.
  Future<void> addTask(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    final created = await repo.create(task);
    final current = state.asData?.value ?? [];
    final next = [created, ...current];
    state = AsyncData(List.unmodifiable(next));
  }

  /// Persists a status change via the repository and updates the local list.
  Future<void> changeStatus(Task task, TaskStatus newStatus) async {
    final repo = ref.read(taskRepositoryProvider);
    final updated = task.copyWith(
      status: newStatus,
      completedDate: newStatus == TaskStatus.completed ? DateTime.now() : null,
    );
    await repo.update(updated);
    updateTask(updated);
  }

  /// Deletes a task via the repository and removes it from the list.
  Future<void> deleteTask(String id) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.delete(id);
    final current = state.asData?.value ?? [];
    final next = current.where((t) => t.id != id).toList();
    state = AsyncData(List.unmodifiable(next));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(taskRepositoryProvider).getAll(),
    );
  }
}

/// Currently selected status filter chip index (0 = All).
final taskStatusFilterProvider =
    NotifierProvider<TaskStatusFilterNotifier, int>(
      TaskStatusFilterNotifier.new,
    );

class TaskStatusFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Currently selected task type filter (null = all types).
final taskTypeFilterProvider =
    NotifierProvider<TaskTypeFilterNotifier, TaskType?>(
      TaskTypeFilterNotifier.new,
    );

class TaskTypeFilterNotifier extends Notifier<TaskType?> {
  @override
  TaskType? build() => null;

  void update(TaskType? value) => state = value;
}

/// Currently selected priority filter (null = all priorities).
final taskPriorityFilterProvider =
    NotifierProvider<TaskPriorityFilterNotifier, TaskPriority?>(
      TaskPriorityFilterNotifier.new,
    );

class TaskPriorityFilterNotifier extends Notifier<TaskPriority?> {
  @override
  TaskPriority? build() => null;

  void update(TaskPriority? value) => state = value;
}

/// Currently selected assignee filter (null = all assignees).
final taskAssigneeFilterProvider =
    NotifierProvider<TaskAssigneeFilterNotifier, String?>(
      TaskAssigneeFilterNotifier.new,
    );

class TaskAssigneeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Sort option for the task list.
enum TaskSortOption { dueDate, priority, clientName }

final taskSortOptionProvider =
    NotifierProvider<TaskSortOptionNotifier, TaskSortOption>(
      TaskSortOptionNotifier.new,
    );

class TaskSortOptionNotifier extends Notifier<TaskSortOption> {
  @override
  TaskSortOption build() => TaskSortOption.dueDate;

  void update(TaskSortOption value) => state = value;
}

/// Unique assignee names extracted from all tasks.
final taskAssigneesProvider = Provider<List<String>>((ref) {
  final tasks = ref.watch(allTasksProvider).asData?.value ?? [];
  final names = tasks.map((t) => t.assignedTo).toSet().toList()..sort();
  return names;
});

/// Summary counts for the status filter chips.
final taskCountsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(allTasksProvider).asData?.value ?? [];
  final all = tasks.length;
  final pending = tasks.where((t) => t.status == TaskStatus.todo).length;
  final inProgress = tasks
      .where((t) => t.status == TaskStatus.inProgress)
      .length;
  final overdue = tasks.where((t) => t.isOverdue).length;
  return {
    'all': all,
    'pending': pending,
    'inProgress': inProgress,
    'overdue': overdue,
  };
});

/// Filtered and sorted tasks list used by the UI.
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(allTasksProvider).asData?.value ?? [];
  final statusFilter = ref.watch(taskStatusFilterProvider);
  final typeFilter = ref.watch(taskTypeFilterProvider);
  final priorityFilter = ref.watch(taskPriorityFilterProvider);
  final assigneeFilter = ref.watch(taskAssigneeFilterProvider);
  final sortOption = ref.watch(taskSortOptionProvider);

  var filtered = List<Task>.from(tasks);

  // Status chip filter: 0=All, 1=Pending, 2=InProgress, 3=Overdue
  switch (statusFilter) {
    case 1:
      filtered = filtered.where((t) => t.status == TaskStatus.todo).toList();
    case 2:
      filtered = filtered
          .where((t) => t.status == TaskStatus.inProgress)
          .toList();
    case 3:
      filtered = filtered.where((t) => t.isOverdue).toList();
    default:
      break;
  }

  if (typeFilter != null) {
    filtered = filtered.where((t) => t.taskType == typeFilter).toList();
  }

  if (priorityFilter != null) {
    filtered = filtered.where((t) => t.priority == priorityFilter).toList();
  }

  if (assigneeFilter != null) {
    filtered = filtered.where((t) => t.assignedTo == assigneeFilter).toList();
  }

  // Sort
  switch (sortOption) {
    case TaskSortOption.dueDate:
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    case TaskSortOption.priority:
      filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    case TaskSortOption.clientName:
      filtered.sort(
        (a, b) =>
            a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase()),
      );
  }

  return filtered;
});
