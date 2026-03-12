import 'package:flutter/foundation.dart';

/// Action that a single automation step performs.
enum StepAction {
  navigate,
  click,
  type,
  select,
  waitFor,
  extractText,
  download,
  screenshot,
  validateText,
}

/// A single instruction within an [AutomationScript].
///
/// Immutable — use [copyWith] to produce updated instances.
@immutable
class AutomationStep {
  const AutomationStep({
    required this.stepNumber,
    required this.action,
    required this.selector,
    required this.value,
    required this.expectedOutcome,
    this.timeoutSeconds = 30,
    this.isOptional = false,
  });

  /// Execution order position (must be unique within a script).
  final int stepNumber;

  /// The automation action to perform.
  final StepAction action;

  /// CSS selector, URL, or element description used to target the UI element.
  final String selector;

  /// Text to type or option to select; null for actions that do not require input.
  final String? value;

  /// Description of the expected state after this step completes.
  final String? expectedOutcome;

  /// How many seconds to wait before treating the step as timed out.
  final int timeoutSeconds;

  /// When true, a failure on this step does not abort the script.
  final bool isOptional;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  AutomationStep copyWith({
    int? stepNumber,
    StepAction? action,
    String? selector,
    String? value,
    String? expectedOutcome,
    int? timeoutSeconds,
    bool? isOptional,
  }) {
    return AutomationStep(
      stepNumber: stepNumber ?? this.stepNumber,
      action: action ?? this.action,
      selector: selector ?? this.selector,
      value: value ?? this.value,
      expectedOutcome: expectedOutcome ?? this.expectedOutcome,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutomationStep &&
          runtimeType == other.runtimeType &&
          stepNumber == other.stepNumber &&
          action == other.action &&
          selector == other.selector &&
          value == other.value &&
          expectedOutcome == other.expectedOutcome &&
          timeoutSeconds == other.timeoutSeconds &&
          isOptional == other.isOptional;

  @override
  int get hashCode => Object.hash(
    stepNumber,
    action,
    selector,
    value,
    expectedOutcome,
    timeoutSeconds,
    isOptional,
  );

  @override
  String toString() =>
      'AutomationStep(stepNumber: $stepNumber, action: $action, '
      'selector: $selector, isOptional: $isOptional)';
}
