import 'package:flutter/foundation.dart';

/// The outcome of executing an [AutomationScript].
///
/// Immutable — use [copyWith] to produce updated instances.
@immutable
class AutomationResult {
  const AutomationResult({
    required this.taskId,
    required this.success,
    required this.executionTimeMs,
    required this.stepsCompleted,
    required this.stepsFailed,
    required this.extractedData,
    required this.screenshots,
    required this.errorStep,
  });

  /// ID of the [AutomationTask] that produced this result.
  final String taskId;

  /// Whether all required steps completed without error.
  final bool success;

  /// Total wall-clock time in milliseconds.
  final int executionTimeMs;

  /// Number of steps that ran to successful completion.
  final int stepsCompleted;

  /// Number of steps that encountered an error.
  final int stepsFailed;

  /// Key/value pairs harvested by `extractText` steps.
  final Map<String, String> extractedData;

  /// File-system paths to any screenshots captured during execution.
  final List<String> screenshots;

  /// Step number that caused the first failure; null if the run succeeded.
  final int? errorStep;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  AutomationResult copyWith({
    String? taskId,
    bool? success,
    int? executionTimeMs,
    int? stepsCompleted,
    int? stepsFailed,
    Map<String, String>? extractedData,
    List<String>? screenshots,
    int? errorStep,
  }) {
    return AutomationResult(
      taskId: taskId ?? this.taskId,
      success: success ?? this.success,
      executionTimeMs: executionTimeMs ?? this.executionTimeMs,
      stepsCompleted: stepsCompleted ?? this.stepsCompleted,
      stepsFailed: stepsFailed ?? this.stepsFailed,
      extractedData: extractedData ?? this.extractedData,
      screenshots: screenshots ?? this.screenshots,
      errorStep: errorStep ?? this.errorStep,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutomationResult &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          success == other.success &&
          executionTimeMs == other.executionTimeMs &&
          stepsCompleted == other.stepsCompleted &&
          stepsFailed == other.stepsFailed &&
          mapEquals(extractedData, other.extractedData) &&
          listEquals(screenshots, other.screenshots) &&
          errorStep == other.errorStep;

  @override
  int get hashCode => Object.hash(
    taskId,
    success,
    executionTimeMs,
    stepsCompleted,
    stepsFailed,
    Object.hashAll(
      extractedData.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAll(screenshots),
    errorStep,
  );

  @override
  String toString() =>
      'AutomationResult(taskId: $taskId, success: $success, '
      'stepsCompleted: $stepsCompleted, stepsFailed: $stepsFailed, '
      'executionTimeMs: ${executionTimeMs}ms)';
}
