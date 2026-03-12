import 'package:flutter/foundation.dart';

/// Portal that a task targets.
enum AutomationPortal { itd, traces, gstn, mca, epfo }

/// Type of automation task.
enum AutomationTaskType {
  tracesDownload,
  mcaPrefill,
  challanFetch,
  gstFilingStatus,
  itrStatus,
  bulkPanVerify,
  aisDownload,
}

/// Lifecycle status of an automation task.
enum AutomationTaskStatus {
  queued,
  running,
  completed,
  failed,
  retrying,
  cancelled,
}

/// Represents a single portal automation job with all its lifecycle metadata.
///
/// Immutable — use [copyWith] to produce updated instances.
@immutable
class AutomationTask {
  const AutomationTask({
    required this.taskId,
    required this.name,
    required this.taskType,
    required this.portal,
    required this.parameters,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    required this.retryCount,
    required this.maxRetries,
    required this.resultData,
    required this.errorMessage,
  });

  /// Unique task identifier.
  final String taskId;

  /// Human-readable task name.
  final String name;

  /// The type of automation work this task performs.
  final AutomationTaskType taskType;

  /// Portal this task executes against.
  final AutomationPortal portal;

  /// Runtime parameters, e.g. `{'tan': 'AAATA1234X', 'fy': '2024-25'}`.
  final Map<String, String> parameters;

  /// Current lifecycle status.
  final AutomationTaskStatus status;

  /// When execution started; null if not yet started.
  final DateTime? startedAt;

  /// When execution completed (success or failure); null if not done.
  final DateTime? completedAt;

  /// Number of times this task has been retried.
  final int retryCount;

  /// Maximum allowed retries before giving up.
  final int maxRetries;

  /// JSON-encoded result payload when [status] is [AutomationTaskStatus.completed].
  final String? resultData;

  /// Human-readable error description when [status] is [AutomationTaskStatus.failed].
  final String? errorMessage;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  AutomationTask copyWith({
    String? taskId,
    String? name,
    AutomationTaskType? taskType,
    AutomationPortal? portal,
    Map<String, String>? parameters,
    AutomationTaskStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? retryCount,
    int? maxRetries,
    String? resultData,
    String? errorMessage,
  }) {
    return AutomationTask(
      taskId: taskId ?? this.taskId,
      name: name ?? this.name,
      taskType: taskType ?? this.taskType,
      portal: portal ?? this.portal,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      resultData: resultData ?? this.resultData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutomationTask &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          name == other.name &&
          taskType == other.taskType &&
          portal == other.portal &&
          mapEquals(parameters, other.parameters) &&
          status == other.status &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          retryCount == other.retryCount &&
          maxRetries == other.maxRetries &&
          resultData == other.resultData &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
    taskId,
    name,
    taskType,
    portal,
    Object.hashAll(parameters.entries.map((e) => Object.hash(e.key, e.value))),
    status,
    startedAt,
    completedAt,
    retryCount,
    maxRetries,
    resultData,
    errorMessage,
  );

  @override
  String toString() =>
      'AutomationTask(taskId: $taskId, name: $name, '
      'taskType: $taskType, portal: $portal, status: $status, '
      'retryCount: $retryCount/$maxRetries)';
}
