import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';
import 'package:ca_app/features/tasks/data/repositories/mock_task_repository.dart';

void main() {
  group('MockTaskRepository', () {
    late MockTaskRepository repo;
    final now = DateTime.now();

    setUp(() {
      repo = MockTaskRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    group('getAll', () {
      test('returns all seeded tasks', () async {
        final all = await repo.getAll();
        expect(all.length, greaterThanOrEqualTo(6));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAll();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });

    group('getById', () {
      test('returns task for valid ID', () async {
        final task = await repo.getById('mock-task-001');
        expect(task, isNotNull);
        expect(task!.id, 'mock-task-001');
        expect(task.clientId, 'mock-client-001');
      });

      test('returns null for unknown ID', () async {
        final task = await repo.getById('no-such-id');
        expect(task, isNull);
      });
    });

    group('create', () {
      test('creates task and returns it', () async {
        final newTask = Task(
          id: 'new-task-001',
          title: 'New Test Task',
          description: 'Test task description.',
          clientId: 'client-test',
          clientName: 'Test Client',
          taskType: TaskType.itrFiling,
          priority: TaskPriority.medium,
          status: TaskStatus.todo,
          assignedTo: 'Staff A',
          assignedBy: 'CA Test',
          dueDate: DateTime(now.year, now.month, now.day + 14),
          createdAt: now,
        );

        final created = await repo.create(newTask);
        expect(created.id, 'new-task-001');
        expect(created.title, 'New Test Task');

        final fetched = await repo.getById('new-task-001');
        expect(fetched, isNotNull);
        expect(fetched!.taskType, TaskType.itrFiling);
      });
    });

    group('update', () {
      test('updates existing task and returns updated task', () async {
        final existing = await repo.getById('mock-task-001');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(status: TaskStatus.completed);
        final result = await repo.update(updated);
        expect(result.status, TaskStatus.completed);

        final fetched = await repo.getById('mock-task-001');
        expect(fetched!.status, TaskStatus.completed);
      });

      test('throws StateError for non-existent task', () async {
        final ghost = Task(
          id: 'ghost-task',
          title: 'Ghost Task',
          description: '',
          clientId: 'c',
          clientName: 'Ghost',
          taskType: TaskType.other,
          priority: TaskPriority.low,
          status: TaskStatus.todo,
          assignedTo: 'Nobody',
          assignedBy: 'Nobody',
          dueDate: DateTime(2026, 12, 31),
          createdAt: now,
        );
        expect(() => repo.update(ghost), throwsA(isA<StateError>()));
      });
    });

    group('delete', () {
      test('deletes task so it no longer appears in getById', () async {
        final created = await repo.create(
          Task(
            id: 'task-to-delete',
            title: 'Delete Me',
            description: '',
            clientId: 'client-del',
            clientName: 'Delete Client',
            taskType: TaskType.other,
            priority: TaskPriority.low,
            status: TaskStatus.todo,
            assignedTo: 'Staff',
            assignedBy: 'CA',
            dueDate: DateTime(2026, 12, 31),
            createdAt: now,
          ),
        );

        await repo.delete(created.id);
        final fetched = await repo.getById('task-to-delete');
        expect(fetched, isNull);
      });

      test('delete on non-existent ID does not throw', () async {
        await expectLater(repo.delete('no-such-task'), completes);
      });
    });

    group('getByClientId', () {
      test('returns tasks for a known client', () async {
        final results = await repo.getByClientId('mock-client-001');
        expect(results, isNotEmpty);
        expect(results.every((t) => t.clientId == 'mock-client-001'), isTrue);
      });

      test('returns empty list for unknown client', () async {
        final results = await repo.getByClientId('unknown-client-xyz');
        expect(results, isEmpty);
      });
    });

    group('getByStatus', () {
      test(
        'returns only inProgress tasks when filtering by inProgress',
        () async {
          final results = await repo.getByStatus(TaskStatus.inProgress);
          expect(results, isNotEmpty);
          expect(
            results.every((t) => t.status == TaskStatus.inProgress),
            isTrue,
          );
        },
      );

      test('returns only overdue tasks when filtering by overdue', () async {
        final results = await repo.getByStatus(TaskStatus.overdue);
        expect(results, isNotEmpty);
        expect(results.every((t) => t.status == TaskStatus.overdue), isTrue);
      });

      test('returns empty list for status with no matching tasks', () async {
        final results = await repo.getByStatus(TaskStatus.completed);
        expect(results, isEmpty);
      });
    });

    group('search', () {
      test('finds task by title substring (case-insensitive)', () async {
        final results = await repo.search('ITR-4');
        expect(results, isNotEmpty);
        expect(
          results.any((t) => t.title.toLowerCase().contains('itr-4')),
          isTrue,
        );
      });

      test('finds task by client name substring', () async {
        final results = await repo.search('Kapoor');
        expect(results, isNotEmpty);
        expect(results.any((t) => t.clientName.contains('Kapoor')), isTrue);
      });

      test('finds task by description substring', () async {
        final results = await repo.search('44AD');
        expect(results, isNotEmpty);
        expect(results.any((t) => t.description.contains('44AD')), isTrue);
      });

      test('returns empty list for unknown query', () async {
        final results = await repo.search('xyznonexistent12345');
        expect(results, isEmpty);
      });
    });

    group('watchAll', () {
      test('emits a list after create', () async {
        final stream = repo.watchAll();
        final future = stream.first;

        await repo.create(
          Task(
            id: 'task-stream-test',
            title: 'Stream Test Task',
            description: '',
            clientId: 'client-stream',
            clientName: 'Stream Client',
            taskType: TaskType.gstReturn,
            priority: TaskPriority.low,
            status: TaskStatus.todo,
            assignedTo: 'Staff B',
            assignedBy: 'CA Stream',
            dueDate: DateTime(now.year, now.month, now.day + 5),
            createdAt: now,
          ),
        );

        final emitted = await future;
        expect(emitted.any((t) => t.id == 'task-stream-test'), isTrue);
      });
    });
  });
}
