import 'package:ca_app/features/rpa/domain/models/automation_result.dart';
import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/automation_script_builder.dart';

/// Executes, validates, and provides templates for portal automation scripts.
///
/// All execution is mocked — no real browser automation occurs in this layer.
/// The service acts as the domain facade for the RPA sub-system.
class PortalAutomationService {
  PortalAutomationService._();

  static final PortalAutomationService instance = PortalAutomationService._();

  // ---------------------------------------------------------------------------
  // Script execution (mocked)
  // ---------------------------------------------------------------------------

  /// Simulates executing [script] against a live portal.
  ///
  /// Mock behaviour:
  /// - All steps are reported as completed.
  /// - [AutomationResult.success] is `true`.
  /// - Execution time is derived from [AutomationScript.estimatedDurationSeconds].
  /// - `extractText` steps contribute placeholder entries to [AutomationResult.extractedData].
  /// - [sessionTokens] is accepted but not used in the mock.
  Future<AutomationResult> executeScript(
    AutomationScript script,
    Map<String, String> sessionTokens,
  ) async {
    final extractedData = <String, String>{};

    for (final step in script.steps) {
      if (step.action == StepAction.extractText) {
        final key = _selectorToKey(step.selector);
        extractedData[key] = 'mock_value_step_${step.stepNumber}';
      }
    }

    return AutomationResult(
      taskId: script.scriptId,
      success: true,
      executionTimeMs: script.estimatedDurationSeconds * 1000,
      stepsCompleted: script.steps.length,
      stepsFailed: 0,
      extractedData: extractedData,
      screenshots: const [],
      errorStep: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Script validation
  // ---------------------------------------------------------------------------

  /// Validates [script] and returns a list of human-readable error messages.
  ///
  /// An empty list means the script is valid.
  ///
  /// Checks performed:
  /// 1. Script must have at least one step.
  /// 2. Step numbers must be in strictly ascending order.
  /// 3. Step numbers must be unique (no duplicates).
  /// 4. Required (non-optional) steps must have a non-empty selector.
  List<String> validateScript(AutomationScript script) {
    final errors = <String>[];

    if (script.steps.isEmpty) {
      errors.add('Script must contain at least one step.');
      return errors;
    }

    // Check ordering and uniqueness together.
    final seenNumbers = <int>{};
    for (var i = 0; i < script.steps.length; i++) {
      final step = script.steps[i];

      if (seenNumbers.contains(step.stepNumber)) {
        errors.add(
          'Duplicate stepNumber ${step.stepNumber} found at index $i.',
        );
      }
      seenNumbers.add(step.stepNumber);

      if (i > 0) {
        final previous = script.steps[i - 1];
        if (step.stepNumber <= previous.stepNumber) {
          errors.add(
            'Steps are not in ascending order: '
            'step[$i].stepNumber (${step.stepNumber}) '
            'is not greater than step[${i - 1}].stepNumber '
            '(${previous.stepNumber}).',
          );
        }
      }

      if (!step.isOptional && step.selector.isEmpty) {
        errors.add(
          'Required step ${step.stepNumber} has an empty selector.',
        );
      }
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Script templates
  // ---------------------------------------------------------------------------

  /// Returns a pre-built script template for [portalName] and [taskName].
  ///
  /// | portalName | taskName        | Portal                      |
  /// |------------|-----------------|------------------------------|
  /// | traces     | form16          | [AutomationPortal.traces]   |
  /// | traces     | challanStatus   | [AutomationPortal.traces]   |
  /// | gstn       | filingStatus    | [AutomationPortal.gstn]     |
  /// | mca        | formPrefill     | [AutomationPortal.mca]      |
  ///
  /// Returns a fallback script with an empty steps list for unknown combinations.
  AutomationScript getScriptTemplate(String portalName, String taskName) {
    final key = '${portalName.toLowerCase()}:${taskName.toLowerCase()}';

    switch (key) {
      case 'traces:form16':
        return AutomationScriptBuilder.buildTracesForm16Script(
          '{tan}',
          DateTime.now().year - 1,
          ['{pan}'],
        );

      case 'traces:challanstatus':
        return AutomationScriptBuilder.buildChallanStatusScript(
          '{tan}',
          '{bsrCode}',
          '{challanDate}',
        );

      case 'gstn:filingstatus':
        return AutomationScriptBuilder.buildGstFilingStatusScript(
          '{gstin}',
          '{period}',
        );

      case 'mca:formprefill':
        return AutomationScriptBuilder.buildMcaFormPrefillScript(
          '{cin}',
          '{formType}',
          {},
        );

      default:
        return const AutomationScript(
          scriptId: 'fallback',
          name: 'Unknown template',
          steps: [],
          targetPortal: AutomationPortal.itd,
          estimatedDurationSeconds: 0,
          lastRunAt: null,
          successRate: 0.0,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Converts a CSS selector like `.requestId` or `#requestId` to a plain key.
  String _selectorToKey(String selector) {
    if (selector.startsWith('.') || selector.startsWith('#')) {
      return selector.substring(1);
    }
    return selector;
  }
}
