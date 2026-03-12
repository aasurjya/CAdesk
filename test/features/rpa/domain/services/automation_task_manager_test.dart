import 'package:ca_app/features/rpa/domain/models/automation_result.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/automation_task_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutomationTaskManager', () {
    // -------------------------------------------------------------------------
    // createTask
    // -------------------------------------------------------------------------
    group('createTask', () {
      test('returns an AutomationTask with given type and parameters', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {'tan': 'AAATA1234X', 'fy': '2024-25'},
        );

        expect(task.taskType, AutomationTaskType.tracesDownload);
        expect(task.parameters['tan'], 'AAATA1234X');
        expect(task.parameters['fy'], '2024-25');
      });

      test('taskId is non-empty', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.mcaPrefill,
          {},
        );

        expect(task.taskId, isNotEmpty);
      });

      test('initial status is queued', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.challanFetch,
          {},
        );

        expect(task.status, AutomationTaskStatus.queued);
      });

      test('retryCount starts at 0', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {},
        );

        expect(task.retryCount, 0);
      });

      test('maxRetries defaults to 3', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {},
        );

        expect(task.maxRetries, 3);
      });

      test('startedAt and completedAt are null on creation', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.gstFilingStatus,
          {},
        );

        expect(task.startedAt, isNull);
        expect(task.completedAt, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // queueTask
    // -------------------------------------------------------------------------
    group('queueTask', () {
      test('returns a new task with status queued', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {'tan': 'AAATA1234X'},
        );

        final queued = AutomationTaskManager.queueTask(task);

        expect(queued.status, AutomationTaskStatus.queued);
        // Must be a new object (immutable)
        expect(identical(task, queued), isFalse);
      });

      test('preserves all other fields', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.bulkPanVerify,
          {'count': '50'},
        );

        final queued = AutomationTaskManager.queueTask(task);

        expect(queued.taskId, task.taskId);
        expect(queued.taskType, task.taskType);
        expect(queued.parameters, task.parameters);
      });
    });

    // -------------------------------------------------------------------------
    // startTask
    // -------------------------------------------------------------------------
    group('startTask', () {
      test('returns a new task with status running', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {},
        );

        final running = AutomationTaskManager.startTask(task);

        expect(running.status, AutomationTaskStatus.running);
        expect(identical(task, running), isFalse);
      });

      test('sets startedAt to a non-null DateTime', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {},
        );

        final running = AutomationTaskManager.startTask(task);

        expect(running.startedAt, isNotNull);
      });

      test('completedAt remains null when started', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {},
        );

        final running = AutomationTaskManager.startTask(task);

        expect(running.completedAt, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // completeTask
    // -------------------------------------------------------------------------
    group('completeTask', () {
      test('returns a new task with status completed', () {
        final task = AutomationTaskManager.startTask(
          AutomationTaskManager.createTask(
            AutomationTaskType.tracesDownload,
            {},
          ),
        );

        final result = const AutomationResult(
          taskId: 'test-id',
          success: true,
          executionTimeMs: 3500,
          stepsCompleted: 11,
          stepsFailed: 0,
          extractedData: {'requestId': 'REQ123'},
          screenshots: [],
          errorStep: null,
        );

        final completed = AutomationTaskManager.completeTask(task, result);

        expect(completed.status, AutomationTaskStatus.completed);
        expect(identical(task, completed), isFalse);
      });

      test('sets completedAt to a non-null DateTime', () {
        final task = AutomationTaskManager.startTask(
          AutomationTaskManager.createTask(
            AutomationTaskType.tracesDownload,
            {},
          ),
        );

        final result = const AutomationResult(
          taskId: 'test-id',
          success: true,
          executionTimeMs: 1000,
          stepsCompleted: 5,
          stepsFailed: 0,
          extractedData: {},
          screenshots: [],
          errorStep: null,
        );

        final completed = AutomationTaskManager.completeTask(task, result);

        expect(completed.completedAt, isNotNull);
      });

      test('stores JSON-serialised result in resultData', () {
        final task = AutomationTaskManager.startTask(
          AutomationTaskManager.createTask(
            AutomationTaskType.challanFetch,
            {},
          ),
        );

        final result = const AutomationResult(
          taskId: 'test-id',
          success: true,
          executionTimeMs: 2000,
          stepsCompleted: 8,
          stepsFailed: 0,
          extractedData: {'status': 'Matched'},
          screenshots: [],
          errorStep: null,
        );

        final completed = AutomationTaskManager.completeTask(task, result);

        expect(completed.resultData, isNotNull);
        expect(completed.resultData, isNotEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // failTask
    // -------------------------------------------------------------------------
    group('failTask', () {
      test('returns a new task with status failed', () {
        final task = AutomationTaskManager.startTask(
          AutomationTaskManager.createTask(
            AutomationTaskType.tracesDownload,
            {},
          ),
        );

        final failed = AutomationTaskManager.failTask(
          task,
          'Timeout on step 5',
        );

        expect(failed.status, AutomationTaskStatus.failed);
        expect(identical(task, failed), isFalse);
      });

      test('stores error message', () {
        final task = AutomationTaskManager.startTask(
          AutomationTaskManager.createTask(
            AutomationTaskType.tracesDownload,
            {},
          ),
        );

        final failed = AutomationTaskManager.failTask(
          task,
          'Network error during login',
        );

        expect(failed.errorMessage, 'Network error during login');
      });

      test('increments retryCount', () {
        final task = AutomationTaskManager.startTask(
          AutomationTaskManager.createTask(
            AutomationTaskType.tracesDownload,
            {},
          ),
        );

        final failed = AutomationTaskManager.failTask(task, 'error');

        expect(failed.retryCount, task.retryCount + 1);
      });
    });

    // -------------------------------------------------------------------------
    // shouldRetry
    // -------------------------------------------------------------------------
    group('shouldRetry', () {
      test('returns true when retryCount < maxRetries', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {},
        );
        // retryCount = 0, maxRetries = 3

        expect(AutomationTaskManager.shouldRetry(task), isTrue);
      });

      test('returns false when retryCount == maxRetries', () {
        final base = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {},
        );
        // Simulate 3 failures
        var t = AutomationTaskManager.startTask(base);
        t = AutomationTaskManager.failTask(t, 'err');
        t = AutomationTaskManager.startTask(t);
        t = AutomationTaskManager.failTask(t, 'err');
        t = AutomationTaskManager.startTask(t);
        t = AutomationTaskManager.failTask(t, 'err');

        expect(t.retryCount, 3);
        expect(AutomationTaskManager.shouldRetry(t), isFalse);
      });

      test('returns false when retryCount > maxRetries', () {
        final task = const AutomationTask(
          taskId: 'x',
          name: 'test',
          taskType: AutomationTaskType.tracesDownload,
          portal: AutomationPortal.traces,
          parameters: {},
          status: AutomationTaskStatus.failed,
          startedAt: null,
          completedAt: null,
          retryCount: 5,
          maxRetries: 3,
          resultData: null,
          errorMessage: null,
        );

        expect(AutomationTaskManager.shouldRetry(task), isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // estimateBatchDuration
    // -------------------------------------------------------------------------
    group('estimateBatchDuration', () {
      test('empty list → zero duration', () {
        final duration = AutomationTaskManager.estimateBatchDuration([]);
        expect(duration, Duration.zero);
      });

      test('single task → returns non-zero duration', () {
        final task = AutomationTaskManager.createTask(
          AutomationTaskType.tracesDownload,
          {'pans': '10'},
        );

        final duration = AutomationTaskManager.estimateBatchDuration([task]);
        expect(duration.inSeconds, greaterThan(0));
      });

      test('multiple tasks → duration is at least sum of individual estimates',
          () {
        final tasks = [
          AutomationTaskManager.createTask(
            AutomationTaskType.tracesDownload,
            {},
          ),
          AutomationTaskManager.createTask(AutomationTaskType.challanFetch, {}),
          AutomationTaskManager.createTask(
            AutomationTaskType.gstFilingStatus,
            {},
          ),
        ];

        final total = AutomationTaskManager.estimateBatchDuration(tasks);
        final individual = tasks
            .map(
              (t) => AutomationTaskManager.estimateBatchDuration([t]),
            )
            .fold(Duration.zero, (a, b) => a + b);

        expect(total.inSeconds, greaterThanOrEqualTo(individual.inSeconds));
      });
    });
  });
}
