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

  static String _newId() {
    _counter += 1;
    return 'task-${DateTime.now().microsecondsSinceEpoch}-$_counter';
  }

  static const Map<AutomationTaskType, int> _baseDurationSeconds = {
    AutomationTaskType.tracesDownload: 180,
    AutomationTaskType.mcaPrefill: 90,
    AutomationTaskType.challanFetch: 120,
    AutomationTaskType.gstFilingStatus: 90,
    AutomationTaskType.itrStatus: 60,
    AutomationTaskType.bulkPanVerify: 300,
    AutomationTaskType.aisDownload: 150,
  };

  static const Map<AutomationTaskType, String> _taskNames = {
    AutomationTaskType.tracesDownload: 'TRACES Download',
    AutomationTaskType.mcaPrefill: 'MCA Form Prefill',
    AutomationTaskType.challanFetch: 'Challan Fetch',
    AutomationTaskType.gstFilingStatus: 'GST Filing Status',
    AutomationTaskType.itrStatus: 'ITR Status',
    AutomationTaskType.bulkPanVerify: 'Bulk PAN Verify',
    AutomationTaskType.aisDownload: 'AIS Download',
  };

  static const Map<AutomationTaskType, AutomationPortal> _portalByType = {
    AutomationTaskType.tracesDownload: AutomationPortal.traces,
    AutomationTaskType.mcaPrefill: AutomationPortal.mca,
    AutomationTaskType.challanFetch: AutomationPortal.traces,
    AutomationTaskType.gstFilingStatus: AutomationPortal.gstn,
    AutomationTaskType.itrStatus: AutomationPortal.itd,
    AutomationTaskType.bulkPanVerify: AutomationPortal.itd,
    AutomationTaskType.aisDownload: AutomationPortal.itd,
  };

  static AutomationTask createTask(
    AutomationTaskType type,
    Map<String, String> parameters,
  ) {
    return AutomationTask(
      taskId: _newId(),
      name: _taskNames[type] ?? type.name,
      taskType: type,
      portal: _portalByType[type] ?? AutomationPortal.itd,
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

  static AutomationTask queueTask(AutomationTask task) {
    return task.copyWith(status: AutomationTaskStatus.queued);
  }

  static AutomationTask startTask(AutomationTask task) {
    return task.copyWith(
      status: AutomationTaskStatus.running,
      startedAt: DateTime.now(),
    );
  }

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

  static AutomationTask failTask(AutomationTask task, String error) {
    return task.copyWith(
      status: AutomationTaskStatus.failed,
      errorMessage: error,
      retryCount: task.retryCount + 1,
    );
  }

  static bool shouldRetry(AutomationTask task) {
    return task.retryCount < task.maxRetries;
  }

  static Duration estimateBatchDuration(List<AutomationTask> tasks) {
    if (tasks.isEmpty) return Duration.zero;

    int totalSeconds = 0;
    AutomationPortal? previousPortal;

    for (final task in tasks) {
      totalSeconds += _baseDurationSeconds[task.taskType] ?? 60;

      if (previousPortal == task.portal) {
        totalSeconds += 3;
      }

      previousPortal = task.portal;
    }

    return Duration(seconds: totalSeconds);
  }
}
