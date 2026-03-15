import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/rpa/data/providers/rpa_providers.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/portal_automation_service.dart';

void main() {
  group('rpaPortalServiceProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns the PortalAutomationService singleton', () {
      final service = container.read(rpaPortalServiceProvider);
      expect(service, isA<PortalAutomationService>());
    });

    test('returns same instance on second read', () {
      final s1 = container.read(rpaPortalServiceProvider);
      final s2 = container.read(rpaPortalServiceProvider);
      expect(identical(s1, s2), isTrue);
    });
  });

  group('rpaTaskListProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 4 mock automation tasks', () {
      final tasks = container.read(rpaTaskListProvider);
      expect(tasks.length, 4);
    });

    test('all tasks have non-empty taskIds', () {
      final tasks = container.read(rpaTaskListProvider);
      expect(tasks.every((t) => t.taskId.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final tasks = container.read(rpaTaskListProvider);
      expect(() => (tasks as dynamic).add(null), throwsA(isA<Error>()));
    });

    test('addTask prepends to list', () {
      final before = container.read(rpaTaskListProvider).length;
      final newTask = AutomationTask(
        taskId: 'task-test-001',
        name: 'Test Task',
        taskType: AutomationTaskType.tracesDownload,
        portal: AutomationPortal.traces,
        parameters: const {},
        status: AutomationTaskStatus.queued,
        startedAt: null,
        completedAt: null,
        retryCount: 0,
        maxRetries: 3,
        resultData: null,
        errorMessage: null,
      );
      container.read(rpaTaskListProvider.notifier).addTask(newTask);
      expect(container.read(rpaTaskListProvider).length, before + 1);
      expect(container.read(rpaTaskListProvider).first.taskId, 'task-test-001');
    });

    test('updateTask replaces existing task', () {
      final original = container.read(rpaTaskListProvider).first;
      final updated = AutomationTask(
        taskId: original.taskId,
        name: original.name,
        taskType: original.taskType,
        portal: original.portal,
        parameters: original.parameters,
        status: AutomationTaskStatus.failed,
        startedAt: original.startedAt,
        completedAt: original.completedAt,
        retryCount: 1,
        maxRetries: original.maxRetries,
        resultData: null,
        errorMessage: 'Test error',
      );
      container.read(rpaTaskListProvider.notifier).updateTask(updated);
      final found = container
          .read(rpaTaskListProvider)
          .firstWhere((t) => t.taskId == original.taskId);
      expect(found.status, AutomationTaskStatus.failed);
      expect(found.errorMessage, 'Test error');
    });
  });

  group('rpaScriptListProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 4 mock automation scripts', () {
      final scripts = container.read(rpaScriptListProvider);
      expect(scripts.length, 4);
    });

    test('all scripts have non-empty scriptIds', () {
      final scripts = container.read(rpaScriptListProvider);
      expect(scripts.every((s) => s.scriptId.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final scripts = container.read(rpaScriptListProvider);
      expect(() => (scripts as dynamic).add(null), throwsA(isA<Error>()));
    });
  });
}
