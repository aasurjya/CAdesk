import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutomationTask', () {
    const task = AutomationTask(
      taskId: 'task-001',
      name: 'TRACES Form 16 Download',
      taskType: AutomationTaskType.tracesDownload,
      portal: AutomationPortal.traces,
      parameters: {'tan': 'AAATA1234X', 'fy': '2024-25'},
      status: AutomationTaskStatus.queued,
      startedAt: null,
      completedAt: null,
      retryCount: 0,
      maxRetries: 3,
      resultData: null,
      errorMessage: null,
    );

    test('can be constructed with const', () {
      expect(task.taskId, 'task-001');
      expect(task.name, 'TRACES Form 16 Download');
      expect(task.taskType, AutomationTaskType.tracesDownload);
      expect(task.portal, AutomationPortal.traces);
      expect(task.parameters['tan'], 'AAATA1234X');
      expect(task.status, AutomationTaskStatus.queued);
      expect(task.retryCount, 0);
      expect(task.maxRetries, 3);
      expect(task.startedAt, isNull);
      expect(task.completedAt, isNull);
      expect(task.resultData, isNull);
      expect(task.errorMessage, isNull);
    });

    group('copyWith', () {
      test('returns a new instance', () {
        final copy = task.copyWith(status: AutomationTaskStatus.running);
        expect(identical(task, copy), isFalse);
      });

      test('changes only specified fields', () {
        final started = DateTime(2026, 3, 12, 10, 0);
        final copy = task.copyWith(
          status: AutomationTaskStatus.running,
          startedAt: started,
        );

        expect(copy.status, AutomationTaskStatus.running);
        expect(copy.startedAt, started);
        expect(copy.taskId, task.taskId);
        expect(copy.taskType, task.taskType);
        expect(copy.portal, task.portal);
        expect(copy.parameters, task.parameters);
        expect(copy.retryCount, task.retryCount);
        expect(copy.maxRetries, task.maxRetries);
      });

      test('preserves nullable fields when not overridden', () {
        final copy = task.copyWith(retryCount: 1);
        expect(copy.resultData, isNull);
        expect(copy.errorMessage, isNull);
      });
    });

    group('equality', () {
      test('two tasks with same data are equal', () {
        const task2 = AutomationTask(
          taskId: 'task-001',
          name: 'TRACES Form 16 Download',
          taskType: AutomationTaskType.tracesDownload,
          portal: AutomationPortal.traces,
          parameters: {'tan': 'AAATA1234X', 'fy': '2024-25'},
          status: AutomationTaskStatus.queued,
          startedAt: null,
          completedAt: null,
          retryCount: 0,
          maxRetries: 3,
          resultData: null,
          errorMessage: null,
        );

        expect(task, equals(task2));
      });

      test('tasks with different taskId are not equal', () {
        final other = task.copyWith(taskId: 'task-002');
        expect(task, isNot(equals(other)));
      });

      test('tasks with different status are not equal', () {
        final other = task.copyWith(status: AutomationTaskStatus.running);
        expect(task, isNot(equals(other)));
      });
    });

    group('hashCode', () {
      test('equal tasks have same hashCode', () {
        const task2 = AutomationTask(
          taskId: 'task-001',
          name: 'TRACES Form 16 Download',
          taskType: AutomationTaskType.tracesDownload,
          portal: AutomationPortal.traces,
          parameters: {'tan': 'AAATA1234X', 'fy': '2024-25'},
          status: AutomationTaskStatus.queued,
          startedAt: null,
          completedAt: null,
          retryCount: 0,
          maxRetries: 3,
          resultData: null,
          errorMessage: null,
        );

        expect(task.hashCode, task2.hashCode);
      });
    });

    group('toString', () {
      test('contains taskId and status', () {
        final str = task.toString();
        expect(str, contains('task-001'));
        expect(str, contains('queued'));
      });
    });

    group('AutomationTaskType enum', () {
      test('all expected values exist', () {
        expect(
          AutomationTaskType.values,
          containsAll([
            AutomationTaskType.tracesDownload,
            AutomationTaskType.mcaPrefill,
            AutomationTaskType.challanFetch,
            AutomationTaskType.gstFilingStatus,
            AutomationTaskType.itrStatus,
            AutomationTaskType.bulkPanVerify,
            AutomationTaskType.aisDownload,
          ]),
        );
      });
    });

    group('AutomationTaskStatus enum', () {
      test('all expected values exist', () {
        expect(
          AutomationTaskStatus.values,
          containsAll([
            AutomationTaskStatus.queued,
            AutomationTaskStatus.running,
            AutomationTaskStatus.completed,
            AutomationTaskStatus.failed,
            AutomationTaskStatus.retrying,
            AutomationTaskStatus.cancelled,
          ]),
        );
      });
    });

    group('AutomationPortal enum', () {
      test('all expected values exist', () {
        expect(
          AutomationPortal.values,
          containsAll([
            AutomationPortal.itd,
            AutomationPortal.traces,
            AutomationPortal.gstn,
            AutomationPortal.mca,
            AutomationPortal.epfo,
          ]),
        );
      });
    });
  });
}
