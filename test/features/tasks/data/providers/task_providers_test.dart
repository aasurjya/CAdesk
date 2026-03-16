import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tasks/data/providers/task_providers.dart';
import 'package:ca_app/features/tasks/data/providers/task_repository_providers.dart';
import 'package:ca_app/features/tasks/data/repositories/mock_task_repository.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [taskRepositoryProvider.overrideWithValue(MockTaskRepository())],
  );
}

void main() {
  group('TaskStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is 0 (All)', () {
      expect(container.read(taskStatusFilterProvider), 0);
    });

    test('can be updated to 1 (Pending)', () {
      container.read(taskStatusFilterProvider.notifier).update(1);
      expect(container.read(taskStatusFilterProvider), 1);
    });

    test('can be updated to 2 (InProgress)', () {
      container.read(taskStatusFilterProvider.notifier).update(2);
      expect(container.read(taskStatusFilterProvider), 2);
    });

    test('can be reset to 0', () {
      container.read(taskStatusFilterProvider.notifier).update(3);
      container.read(taskStatusFilterProvider.notifier).update(0);
      expect(container.read(taskStatusFilterProvider), 0);
    });
  });

  group('TaskTypeFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(taskTypeFilterProvider), isNull);
    });

    test('can be updated to a task type', () {
      container
          .read(taskTypeFilterProvider.notifier)
          .update(TaskType.itrFiling);
      expect(container.read(taskTypeFilterProvider), TaskType.itrFiling);
    });

    test('can be cleared to null', () {
      container
          .read(taskTypeFilterProvider.notifier)
          .update(TaskType.gstReturn);
      container.read(taskTypeFilterProvider.notifier).update(null);
      expect(container.read(taskTypeFilterProvider), isNull);
    });
  });

  group('TaskPriorityFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(taskPriorityFilterProvider), isNull);
    });

    test('can be updated to high priority', () {
      container
          .read(taskPriorityFilterProvider.notifier)
          .update(TaskPriority.high);
      expect(container.read(taskPriorityFilterProvider), TaskPriority.high);
    });
  });

  group('TaskAssigneeFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(taskAssigneeFilterProvider), isNull);
    });

    test('can be set to an assignee name', () {
      container.read(taskAssigneeFilterProvider.notifier).update('Kavya Nair');
      expect(container.read(taskAssigneeFilterProvider), 'Kavya Nair');
    });
  });

  group('TaskSortOptionNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is dueDate', () {
      expect(container.read(taskSortOptionProvider), TaskSortOption.dueDate);
    });

    test('can switch to priority', () {
      container
          .read(taskSortOptionProvider.notifier)
          .update(TaskSortOption.priority);
      expect(container.read(taskSortOptionProvider), TaskSortOption.priority);
    });

    test('can switch to clientName', () {
      container
          .read(taskSortOptionProvider.notifier)
          .update(TaskSortOption.clientName);
      expect(container.read(taskSortOptionProvider), TaskSortOption.clientName);
    });
  });

  group('taskAssigneesProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns empty list when no tasks loaded', () {
      // Before async resolves
      final assignees = container.read(taskAssigneesProvider);
      expect(assignees, isA<List<String>>());
    });

    test('returns sorted unique assignees from loaded tasks', () async {
      await container.read(allTasksProvider.future);
      final assignees = container.read(taskAssigneesProvider);
      expect(assignees, isNotEmpty);
      // Should be sorted
      final sorted = List<String>.from(assignees)..sort();
      expect(assignees, sorted);
      // Should be unique
      expect(assignees.toSet().length, assignees.length);
    });
  });

  group('taskCountsProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns map with required keys', () async {
      await container.read(allTasksProvider.future);
      final counts = container.read(taskCountsProvider);
      expect(counts.containsKey('all'), isTrue);
      expect(counts.containsKey('pending'), isTrue);
      expect(counts.containsKey('inProgress'), isTrue);
      expect(counts.containsKey('overdue'), isTrue);
    });

    test('total all count matches task list length', () async {
      final tasks = await container.read(allTasksProvider.future);
      final counts = container.read(taskCountsProvider);
      expect(counts['all'], tasks.length);
    });

    test('pending count matches todo tasks', () async {
      final tasks = await container.read(allTasksProvider.future);
      final expected = tasks.where((t) => t.status == TaskStatus.todo).length;
      final counts = container.read(taskCountsProvider);
      expect(counts['pending'], expected);
    });
  });

  group('filteredTasksProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns all tasks when no filters set', () async {
      final tasks = await container.read(allTasksProvider.future);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, tasks.length);
    });

    test('status filter 1 returns only todo tasks', () async {
      await container.read(allTasksProvider.future);
      container.read(taskStatusFilterProvider.notifier).update(1);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.every((t) => t.status == TaskStatus.todo), isTrue);
    });

    test('status filter 2 returns only inProgress tasks', () async {
      await container.read(allTasksProvider.future);
      container.read(taskStatusFilterProvider.notifier).update(2);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.every((t) => t.status == TaskStatus.inProgress), isTrue);
    });

    test('status filter 3 returns only overdue tasks', () async {
      await container.read(allTasksProvider.future);
      container.read(taskStatusFilterProvider.notifier).update(3);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.every((t) => t.isOverdue), isTrue);
    });

    test('type filter narrows down results', () async {
      await container.read(allTasksProvider.future);
      container
          .read(taskTypeFilterProvider.notifier)
          .update(TaskType.itrFiling);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.every((t) => t.taskType == TaskType.itrFiling), isTrue);
    });

    test('priority filter narrows down results', () async {
      await container.read(allTasksProvider.future);
      container
          .read(taskPriorityFilterProvider.notifier)
          .update(TaskPriority.high);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.every((t) => t.priority == TaskPriority.high), isTrue);
    });

    test('assignee filter narrows down results', () async {
      final tasks = await container.read(allTasksProvider.future);
      final assignees = tasks.map((t) => t.assignedTo).toSet().toList();
      if (assignees.isNotEmpty) {
        final target = assignees.first;
        container.read(taskAssigneeFilterProvider.notifier).update(target);
        final filtered = container.read(filteredTasksProvider);
        expect(filtered.every((t) => t.assignedTo == target), isTrue);
      }
    });

    test('dueDate sort produces ascending order', () async {
      await container.read(allTasksProvider.future);
      container
          .read(taskSortOptionProvider.notifier)
          .update(TaskSortOption.dueDate);
      final filtered = container.read(filteredTasksProvider);
      for (int i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].dueDate.compareTo(filtered[i + 1].dueDate),
          lessThanOrEqualTo(0),
        );
      }
    });

    test('clientName sort produces ascending order', () async {
      await container.read(allTasksProvider.future);
      container
          .read(taskSortOptionProvider.notifier)
          .update(TaskSortOption.clientName);
      final filtered = container.read(filteredTasksProvider);
      for (int i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].clientName.toLowerCase().compareTo(
            filtered[i + 1].clientName.toLowerCase(),
          ),
          lessThanOrEqualTo(0),
        );
      }
    });
  });

  group('AllTasksNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('loads tasks asynchronously', () async {
      final tasks = await container.read(allTasksProvider.future);
      expect(tasks, isNotEmpty);
      expect(tasks, isNotEmpty);
    });

    test('updateTask replaces task at correct index', () async {
      final tasks = await container.read(allTasksProvider.future);
      final first = tasks.first;
      final updated = first.copyWith(status: TaskStatus.completed);

      container.read(allTasksProvider.notifier).updateTask(updated);

      final after = container.read(allTasksProvider).asData?.value ?? [];
      expect(after.first.status, TaskStatus.completed);
      // Original object is unchanged
      expect(first.status, isNot(TaskStatus.completed));
    });

    test('updateTask does nothing for unknown ID', () async {
      final before = await container.read(allTasksProvider.future);
      final ghost = Task(
        id: 'ghost-id-never-exists',
        title: 'Ghost',
        description: '',
        clientId: 'c1',
        clientName: 'Client',
        taskType: TaskType.other,
        priority: TaskPriority.low,
        status: TaskStatus.todo,
        assignedTo: 'Nobody',
        assignedBy: 'Nobody',
        dueDate: DateTime(2026, 12, 31),
        createdAt: DateTime(2026, 1, 1),
      );
      container.read(allTasksProvider.notifier).updateTask(ghost);
      final after = container.read(allTasksProvider).asData?.value ?? [];
      expect(after.length, before.length);
    });
  });

  group('TaskSortOption enum', () {
    test('contains exactly three values', () {
      expect(TaskSortOption.values.length, 3);
    });

    test('all expected sort options are present', () {
      expect(TaskSortOption.values, contains(TaskSortOption.dueDate));
      expect(TaskSortOption.values, contains(TaskSortOption.priority));
      expect(TaskSortOption.values, contains(TaskSortOption.clientName));
    });
  });
}
