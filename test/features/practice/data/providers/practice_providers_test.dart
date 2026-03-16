import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice/data/providers/practice_providers.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

void main() {
  group('workflowListProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 6 mock workflow templates', () {
      final workflows = container.read(workflowListProvider);
      expect(workflows.length, 6);
    });

    test('all workflows have non-empty templateIds', () {
      final workflows = container.read(workflowListProvider);
      expect(workflows.every((w) => w.templateId.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final workflows = container.read(workflowListProvider);
      expect(() => (workflows as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('AssignmentListNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 8 mock assignments', () {
      final assignments = container.read(assignmentListProvider);
      expect(assignments.length, 8);
    });

    test('all assignments have non-empty assignmentIds', () {
      final assignments = container.read(assignmentListProvider);
      expect(assignments.every((a) => a.assignmentId.isNotEmpty), isTrue);
    });

    test('addAssignment prepends to list', () {
      final before = container.read(assignmentListProvider).length;
      final newAssignment = ClientAssignment(
        assignmentId: 'test-001',
        clientName: 'Test Client',
        staffName: 'Test Staff',
        taskDescription: 'Test Task',
        deadline: DateTime(2026, 6, 30),
        status: AssignmentStatus.pending,
        staffRole: StaffRole.junior,
      );
      container
          .read(assignmentListProvider.notifier)
          .addAssignment(newAssignment);
      expect(container.read(assignmentListProvider).length, before + 1);
      expect(
        container.read(assignmentListProvider).first.assignmentId,
        'test-001',
      );
    });

    test('list is unmodifiable', () {
      final assignments = container.read(assignmentListProvider);
      expect(() => (assignments as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('AssignmentFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is all', () {
      expect(container.read(assignmentFilterProvider), AssignmentFilter.all);
    });

    test('can be updated to inProgress', () {
      container
          .read(assignmentFilterProvider.notifier)
          .update(AssignmentFilter.inProgress);
      expect(
        container.read(assignmentFilterProvider),
        AssignmentFilter.inProgress,
      );
    });

    test('can be reset to all', () {
      container
          .read(assignmentFilterProvider.notifier)
          .update(AssignmentFilter.overdue);
      container
          .read(assignmentFilterProvider.notifier)
          .update(AssignmentFilter.all);
      expect(container.read(assignmentFilterProvider), AssignmentFilter.all);
    });
  });

  group('filteredAssignmentsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all assignments when filter is all', () {
      final all = container.read(assignmentListProvider);
      final filtered = container.read(filteredAssignmentsProvider);
      expect(filtered.length, all.length);
    });

    test('inProgress filter returns only inProgress assignments', () {
      container
          .read(assignmentFilterProvider.notifier)
          .update(AssignmentFilter.inProgress);
      final filtered = container.read(filteredAssignmentsProvider);
      expect(
        filtered.every((a) => a.status == AssignmentStatus.inProgress),
        isTrue,
      );
    });

    test('filtered list is subset of all assignments', () {
      container
          .read(assignmentFilterProvider.notifier)
          .update(AssignmentFilter.completed);
      final all = container.read(assignmentListProvider);
      final filtered = container.read(filteredAssignmentsProvider);
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });
  });

  group('teamCapacityProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-empty team list', () {
      final team = container.read(teamCapacityProvider);
      expect(team, isNotEmpty);
    });

    test('all members have positive capacity hours', () {
      final team = container.read(teamCapacityProvider);
      expect(team.every((m) => m.capacityHours > 0), isTrue);
    });
  });

  group('practiceStatsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalClients is positive', () {
      final stats = container.read(practiceStatsProvider);
      expect(stats.totalClients, greaterThan(0));
    });

    test('teamUtilization is non-negative', () {
      final stats = container.read(practiceStatsProvider);
      expect(stats.teamUtilization, greaterThanOrEqualTo(0));
    });
  });
}
