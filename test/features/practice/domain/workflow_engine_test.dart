import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice/domain/models/workflow_template.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';
import 'package:ca_app/features/practice/domain/services/workflow_engine.dart';

WorkflowTemplate _itrTemplate() {
  const task1 = WorkflowTask(
    taskId: 't1',
    name: 'Data Collection',
    description: 'Collect documents from client',
    requiredRole: StaffRole.junior,
    estimatedHours: 2,
    dependsOn: [],
    checklistItems: ['Form 16', 'Bank Statement'],
  );
  const task2 = WorkflowTask(
    taskId: 't2',
    name: 'Computation & Draft',
    description: 'Compute income and draft return',
    requiredRole: StaffRole.senior,
    estimatedHours: 3,
    dependsOn: ['t1'],
    checklistItems: ['Computation Sheet'],
  );
  const task3 = WorkflowTask(
    taskId: 't3',
    name: 'Review',
    description: 'Manager review',
    requiredRole: StaffRole.manager,
    estimatedHours: 1,
    dependsOn: ['t2'],
    checklistItems: ['Review Sign-off'],
  );
  const task4 = WorkflowTask(
    taskId: 't4',
    name: 'Filing',
    description: 'File the return',
    requiredRole: StaffRole.senior,
    estimatedHours: 1,
    dependsOn: ['t3'],
    checklistItems: ['Acknowledgement'],
  );
  return const WorkflowTemplate(
    templateId: 'tmpl-itr-individual',
    name: 'ITR Filing (Individual)',
    category: WorkflowCategory.itrFiling,
    tasks: [task1, task2, task3, task4],
    estimatedHours: 7,
    deadline: WorkflowDeadlineRule(offsetDays: 30),
  );
}

Engagement _engagementWithCompleted(List<String> completedTaskIds) {
  final template = _itrTemplate();
  final base = WorkflowEngine.instance.instantiateWorkflow(
    template,
    'client-001',
    DateTime(2025, 7, 31),
  );
  if (completedTaskIds.isEmpty) return base;
  return base.copyWith(
    assignedStaff: [
      StaffAssignment(
        staffId: 'staff-001',
        role: StaffRole.junior,
        tasks: completedTaskIds,
        hoursLogged: completedTaskIds.length * 2,
        hoursEstimated: 2,
      ),
    ],
  );
}

void main() {
  group('WorkflowEngine.instantiateWorkflow', () {
    test('creates engagement from template with correct clientId', () {
      final template = _itrTemplate();
      final engagement = WorkflowEngine.instance.instantiateWorkflow(
        template,
        'client-abc',
        DateTime(2025, 7, 31),
      );
      expect(engagement.clientId, 'client-abc');
      expect(engagement.templateId, template.templateId);
      expect(engagement.status, EngagementStatus.notStarted);
      expect(engagement.billingAmount, 0);
    });

    test('sets dueDate from provided date', () {
      final template = _itrTemplate();
      final due = DateTime(2025, 7, 31);
      final engagement = WorkflowEngine.instance.instantiateWorkflow(
        template,
        'client-001',
        due,
      );
      expect(engagement.dueDate, due);
    });

    test('generates unique engagementId per call', () {
      final template = _itrTemplate();
      final e1 = WorkflowEngine.instance.instantiateWorkflow(
        template,
        'c1',
        DateTime(2025, 7, 31),
      );
      final e2 = WorkflowEngine.instance.instantiateWorkflow(
        template,
        'c2',
        DateTime(2025, 7, 31),
      );
      expect(e1.engagementId, isNot(equals(e2.engagementId)));
    });
  });

  group('WorkflowEngine.getNextTasks', () {
    test('returns first tasks (no deps) when nothing is completed', () {
      final engagement = _engagementWithCompleted([]);
      final next = WorkflowEngine.instance.getNextTasks(engagement);
      expect(next.map((t) => t.taskId), contains('t1'));
      expect(next.map((t) => t.taskId), isNot(contains('t2')));
    });

    test('returns t2 after t1 is logged as complete', () {
      final engagement = _engagementWithCompleted(['t1']);
      final next = WorkflowEngine.instance.getNextTasks(engagement);
      expect(next.map((t) => t.taskId), contains('t2'));
      expect(next.map((t) => t.taskId), isNot(contains('t1')));
    });

    test('returns t3 only after t2 is complete', () {
      final engagement = _engagementWithCompleted(['t1', 't2']);
      final next = WorkflowEngine.instance.getNextTasks(engagement);
      expect(next.map((t) => t.taskId), contains('t3'));
      expect(next.map((t) => t.taskId), isNot(contains('t4')));
    });

    test('returns empty list when all tasks complete', () {
      final engagement = _engagementWithCompleted(['t1', 't2', 't3', 't4']);
      final next = WorkflowEngine.instance.getNextTasks(engagement);
      expect(next, isEmpty);
    });
  });

  group('WorkflowEngine.computeProgress', () {
    test('returns 0.0 when no tasks completed', () {
      final engagement = _engagementWithCompleted([]);
      final progress = WorkflowEngine.instance.computeProgress(engagement);
      expect(progress, 0.0);
    });

    test('returns 0.25 when 1 of 4 tasks completed', () {
      final engagement = _engagementWithCompleted(['t1']);
      final progress = WorkflowEngine.instance.computeProgress(engagement);
      expect(progress, closeTo(0.25, 0.01));
    });

    test('returns 1.0 when all tasks completed', () {
      final engagement = _engagementWithCompleted(['t1', 't2', 't3', 't4']);
      final progress = WorkflowEngine.instance.computeProgress(engagement);
      expect(progress, 1.0);
    });
  });

  group('WorkflowEngine.checkDeadlineRisk', () {
    test('overdue when dueDate is in the past', () {
      final template = _itrTemplate();
      final pastDue = DateTime.now().subtract(const Duration(days: 1));
      final engagement = WorkflowEngine.instance.instantiateWorkflow(
        template,
        'client-001',
        pastDue,
      );
      final risk = WorkflowEngine.instance.checkDeadlineRisk(engagement);
      expect(risk, DeadlineRisk.overdue);
    });

    test('atRisk when due within 48 hours', () {
      final template = _itrTemplate();
      final nearDue = DateTime.now().add(const Duration(hours: 24));
      final engagement = WorkflowEngine.instance.instantiateWorkflow(
        template,
        'client-001',
        nearDue,
      );
      final risk = WorkflowEngine.instance.checkDeadlineRisk(engagement);
      expect(risk, DeadlineRisk.atRisk);
    });

    test('onTrack when due far in the future', () {
      final template = _itrTemplate();
      final farDue = DateTime.now().add(const Duration(days: 30));
      final engagement = WorkflowEngine.instance.instantiateWorkflow(
        template,
        'client-001',
        farDue,
      );
      final risk = WorkflowEngine.instance.checkDeadlineRisk(engagement);
      expect(risk, DeadlineRisk.onTrack);
    });
  });
}
