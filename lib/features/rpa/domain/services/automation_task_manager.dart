import 'dart:convert';

import 'package:ca_app/features/rpa/domain/models/automation_result.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';

/// Pure static utility class for managing [AutomationTask] lifecycle.
///
/// All methods are pure functions that return new [AutomationTask] instances
/// — no mutation, no state, no side effects.
abstract final class AutomationTaskManager {
  // ---------------------------------------------------------------------------
  // Task creation
  // ---------------------------------------------------------------------------

  /// Creates a new [AutomationTask] with [taskType] and [parameters].
  ///
  /// The task starts in [AutomationTaskStatus.queued] with a unique [taskId],
  /// [retryCount] of 0, and [maxRetries] of 3.
  static AutomationTask createTask(
    AutomationTaskType taskType,
    Map<String, String> parameters,
  ) {
    final taskId =
        '${taskType.name}-${DateTime.now().microsecondsSinceEpoch}';
    final name = _nameForType(taskType);
    final portal = _portalForType(taskType);

    return AutomationTask(
      taskId: taskId,
      name: name,
      taskType: taskType,
      portal: portal,
      parameters: Map.unmodifiable(parameters),
      status: AutomationTaskStatus.queued,
      startedAt: null,
      completedAt: null,
      retryCount: 0,
      maxRetries: 3,
      resultData: null,
      errorMessage: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle transitions  (all return new instances — immutable)
  // ---------------------------------------------------------------------------

  /// Returns a copy of [task] with [status] set to [AutomationTaskStatus.queued].
  static AutomationTask queueTask(AutomationTask task) {
    return task.copyWith(status: AutomationTaskStatus.queued);
  }

  /// Returns a copy of [task] with [status] set to [AutomationTaskStatus.running]
  /// and [startedAt] set to the current time.
  static AutomationTask startTask(AutomationTask task) {
    return task.copyWith(
      status: AutomationTaskStatus.running,
      startedAt: DateTime.now(),
    );
  }

  /// Returns a copy of [task] with [status] set to
  /// [AutomationTaskStatus.completed], [completedAt] set to the current time,
  /// and [resultData] set to the JSON-serialised [result].
  static AutomationTask completeTask(
    AutomationTask task,
    AutomationResult result,
  ) {
    final resultJson = jsonEncode({
      'taskId': result.taskId,
      'success': result.success,
      'executionTimeMs': result.executionTimeMs,
      'stepsCompleted': result.stepsCompleted,
      'stepsFailed': result.stepsFailed,
      'extractedData': result.extractedData,
      'screenshots': result.screenshots,
      'errorStep': result.errorStep,
    });

    return task.copyWith(
      status: AutomationTaskStatus.completed,
      completedAt: DateTime.now(),
      resultData: resultJson,
    );
  }

  /// Returns a copy of [task] with [status] set to
  /// [AutomationTaskStatus.failed], [errorMessage] set to [error], and
  /// [retryCount] incremented by 1.
  static AutomationTask failTask(AutomationTask task, String error) {
    return task.copyWith(
      status: AutomationTaskStatus.failed,
      errorMessage: error,
      retryCount: task.retryCount + 1,
    );
  }

  // ---------------------------------------------------------------------------
  // Retry logic
  // ---------------------------------------------------------------------------

  /// Returns `true` when [task] is eligible for another retry attempt
  /// (i.e. [AutomationTask.retryCount] < [AutomationTask.maxRetries]).
  static bool shouldRetry(AutomationTask task) {
    return task.retryCount < task.maxRetries;
  }

  // ---------------------------------------------------------------------------
  // Batch duration estimation
  // ---------------------------------------------------------------------------

  /// Estimates the total wall-clock [Duration] required to execute all [tasks]
  /// in sequence.
  ///
  /// Returns [Duration.zero] for an empty list.
  static Duration estimateBatchDuration(List<AutomationTask> tasks) {
    if (tasks.isEmpty) return Duration.zero;

    var totalSeconds = 0;
    for (final task in tasks) {
      totalSeconds += _estimatedSecondsForType(task.taskType);
    }

    return Duration(seconds: totalSeconds);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static AutomationPortal _portalForType(AutomationTaskType type) {
    switch (type) {
      case AutomationTaskType.tracesDownload:
      case AutomationTaskType.challanFetch:
        return AutomationPortal.traces;
      case AutomationTaskType.gstFilingStatus:
        return AutomationPortal.gstn;
      case AutomationTaskType.mcaPrefill:
        return AutomationPortal.mca;
      case AutomationTaskType.itrStatus:
      case AutomationTaskType.bulkPanVerify:
      case AutomationTaskType.aisDownload:
        return AutomationPortal.itd;
    }
  }

  static String _nameForType(AutomationTaskType type) {
    switch (type) {
      case AutomationTaskType.tracesDownload:
        return 'TRACES Download';
      case AutomationTaskType.challanFetch:
        return 'Challan Fetch';
      case AutomationTaskType.gstFilingStatus:
        return 'GST Filing Status';
      case AutomationTaskType.mcaPrefill:
        return 'MCA Form Prefill';
      case AutomationTaskType.itrStatus:
        return 'ITR Status';
      case AutomationTaskType.bulkPanVerify:
        return 'Bulk PAN Verify';
      case AutomationTaskType.aisDownload:
        return 'AIS Download';
    }
  }

  static int _estimatedSecondsForType(AutomationTaskType type) {
    switch (type) {
      case AutomationTaskType.tracesDownload:
        return 120;
      case AutomationTaskType.challanFetch:
        return 90;
      case AutomationTaskType.gstFilingStatus:
        return 60;
      case AutomationTaskType.mcaPrefill:
        return 60;
      case AutomationTaskType.itrStatus:
        return 45;
      case AutomationTaskType.bulkPanVerify:
        return 180;
      case AutomationTaskType.aisDownload:
        return 90;
    }
  }
}
