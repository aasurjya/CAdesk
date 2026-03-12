import 'dart:convert';

import 'package:ca_app/features/rpa/domain/models/automation_result.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';

/// Manages the lifecycle of [AutomationTask] objects.
///
/// All methods are static and return new (immutable) task instances.
/// No task is ever mutated in place.
class AutomationTaskManager {
  AutomationTaskManager._();

  static int _counter = 0;

  /// Generates a simple unique task ID from timestamp + counter.
  static String _newId() {
    _counter += 1;
    return 'task-${DateTime.now().microsecondsSinceEpoch}-$_counter';
  }

  /// Per-task-type base duration estimates in seconds.
  static const Map<AutomationTaskType, int> _baseDurationSeconds = {
    AutomationTaskType.tracesDownload: 180,
    AutomationTaskType.mcaPrefill: 90,
    AutomationTaskType.challanFetch: 120,
    AutomationTaskType.gstFilingStatus: 90,
    AutomationTaskType.itrStatus: 60,
    AutomationTaskType.bulkPanVerify: 300,
    AutomationTaskType.aisDownload: 150,
  };

  /// Human-readable task names per type.
  static const Map<AutomationTaskType, String> _taskNames = {
    AutomationTaskType.tracesDownload: 'TRACES Download',
    AutomationTaskType.mcaPrefill: 'MCA Form Prefill',
    AutomationTaskType.challanFetch: 'Challan Fetch',
    AutomationTaskType.gstFilingStatus: 'GST Filing Status',
    AutomationTaskType.itrStatus: 'ITR Status',
    AutomationTaskType.bulkPanVerify: 'Bulk PAN Verify',
    AutomationTaskType.aisDownload: 'AIS Download',
  };

  /// Portal assignments per task type.
  static const Map<AutomationTaskType, AutomationPortal> _portalForType = {
    AutomationTaskType.tracesDownload: AutomationPortal.traces,
    AutomationTaskType.mcaPrefill: AutomationPortal.mca,
    AutomationTaskType.challanFetch: AutomationPortal.traces,
    AutomationTaskType.gstFilingStatus: AutomationPortal.gstn,
    AutomationTaskType.itrStatus: AutomationPortal.itd,
    AutomationTaskType.bulkPanVerify: AutomationPortal.itd,
    AutomationTaskType.aisDownload: AutomationPortal.itd,
  };

  // ---------------------------------------------------------------------------
  // Task lifecycle
  // ---------------------------------------------------------------------------

  /// Creates a new [AutomationTask] with status [AutomationTaskStatus.queued].
  static AutomationTask createTask(
    AutomationTaskType type,
    Map<String, String> parameters,
  ) {
    return AutomationTask(
      taskId: _newId(),
      name: _taskNames[type] ?? type.name,
      taskType: type,
      portal: _portalForType[type] ?? AutomationPortal.itd,
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

  /// Returns a copy of [task] with status set to [AutomationTaskStatus.queued].
  static AutomationTask queueTask(AutomationTask task) {
    return task.copyWith(status: AutomationTaskStatus.queued);
  }

  /// Returns a copy of [task] with status [AutomationTaskStatus.running]
  /// and [AutomationTask.startedAt] set to now.
  static AutomationTask startTask(AutomationTask task) {
    return task.copyWith(
      status: AutomationTaskStatus.running,
      startedAt: DateTime.now(),
    );
  }

  /// Returns a copy of [task] with status [AutomationTaskStatus.completed],
  /// [AutomationTask.completedAt] set to now, and [AutomationTask.resultData]
  /// populated from [result].
  static AutomationTask completeTask(
    AutomationTask task,
    AutomationResult result,
  ) {
    final resultJson = json.encode({
      'taskId': result.taskId,
      'success': result.success,
      'executionTimeMs': result.executionTimeMs,
      'stepsCompleted': result.stepsCompleted,
      'stepsFailed': result.stepsFailed,
      'extractedData': result.extractedData,
    });

    return task.copyWith(
      status: AutomationTaskStatus.completed,
      completedAt: DateTime.now(),
      resultData: resultJson,
      errorMessage: null,
    );
  }

  /// Returns a copy of [task] with status [AutomationTaskStatus.failed],
  /// [AutomationTask.errorMessage] set to [error], and
  /// [AutomationTask.retryCount] incremented by one.
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

  /// Returns `true` when [task] is eligible for another attempt.
  static bool shouldRetry(AutomationTask task) {
    return task.retryCount < task.maxRetries;
  }

  // ---------------------------------------------------------------------------
  // Batch estimation
  // ---------------------------------------------------------------------------

  /// Estimates total wall-clock time for executing [tasks] sequentially.
  ///
  /// Adds a 3-second rate-limit buffer between consecutive tasks on the same
  /// portal, as required by portals such as TRACES.
  static Duration estimateBatchDuration(List<AutomationTask> tasks) {
    if (tasks.isEmpty) return Duration.zero;

    int totalSeconds = 0;
    AutomationPortal? previousPortal;

    for (final task in tasks) {
      totalSeconds += _baseDurationSeconds[task.taskType] ?? 60;

      // Add inter-request rate-limit gap on the same portal.
      if (previousPortal == task.portal) {
        totalSeconds += 3;
      }

      previousPortal = task.portal;
    }

    return Duration(seconds: totalSeconds);
  }
}
