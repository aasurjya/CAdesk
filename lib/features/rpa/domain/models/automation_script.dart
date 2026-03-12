import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:flutter/foundation.dart';

/// A named, ordered sequence of [AutomationStep]s targeting a specific portal.
///
/// Immutable — use [copyWith] to produce updated instances.
@immutable
class AutomationScript {
  const AutomationScript({
    required this.scriptId,
    required this.name,
    required this.steps,
    required this.targetPortal,
    required this.estimatedDurationSeconds,
    required this.lastRunAt,
    required this.successRate,
  });

  /// Unique script identifier.
  final String scriptId;

  /// Human-readable name, e.g. "TRACES Form 16 Download".
  final String name;

  /// Ordered list of automation steps.
  final List<AutomationStep> steps;

  /// Portal this script is designed for.
  final AutomationPortal targetPortal;

  /// Expected wall-clock time in seconds for a successful run.
  final int estimatedDurationSeconds;

  /// When this script was last executed; null if never run.
  final DateTime? lastRunAt;

  /// Fraction of historical runs that completed successfully (0.0–1.0).
  final double successRate;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  AutomationScript copyWith({
    String? scriptId,
    String? name,
    List<AutomationStep>? steps,
    AutomationPortal? targetPortal,
    int? estimatedDurationSeconds,
    DateTime? lastRunAt,
    double? successRate,
  }) {
    return AutomationScript(
      scriptId: scriptId ?? this.scriptId,
      name: name ?? this.name,
      steps: steps ?? this.steps,
      targetPortal: targetPortal ?? this.targetPortal,
      estimatedDurationSeconds:
          estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      successRate: successRate ?? this.successRate,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutomationScript &&
          runtimeType == other.runtimeType &&
          scriptId == other.scriptId &&
          name == other.name &&
          listEquals(steps, other.steps) &&
          targetPortal == other.targetPortal &&
          estimatedDurationSeconds == other.estimatedDurationSeconds &&
          lastRunAt == other.lastRunAt &&
          successRate == other.successRate;

  @override
  int get hashCode => Object.hash(
    scriptId,
    name,
    Object.hashAll(steps),
    targetPortal,
    estimatedDurationSeconds,
    lastRunAt,
    successRate,
  );

  @override
  String toString() =>
      'AutomationScript(scriptId: $scriptId, name: $name, '
      'portal: $targetPortal, steps: ${steps.length}, '
      'successRate: $successRate)';
}
