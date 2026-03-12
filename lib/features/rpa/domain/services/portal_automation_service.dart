import 'package:ca_app/features/rpa/domain/models/automation_result.dart';
import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/automation_script_builder.dart';

/// Stateless singleton that executes [AutomationScript]s against government
/// portals and provides script validation and template retrieval.
///
/// In the current implementation all execution is simulated (mock). A real
/// implementation would integrate a headless-browser driver.
class PortalAutomationService {
  PortalAutomationService._();

  static final PortalAutomationService instance = PortalAutomationService._();

  // ---------------------------------------------------------------------------
  // executeScript
  // ---------------------------------------------------------------------------

  /// Executes [script] with the given [credentials] and returns an
  /// [AutomationResult].
  ///
  /// This is a mock implementation: it simulates step execution and always
  /// succeeds, recording execution time and step counts.
  Future<AutomationResult> executeScript(
    AutomationScript script,
    Map<String, String> credentials,
  ) async {
    final startMs = DateTime.now().millisecondsSinceEpoch;

    // Simulate per-step execution delay (10 ms per step for tests).
    await Future.delayed(Duration(milliseconds: script.steps.length * 10));

    final endMs = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = endMs - startMs;

    return AutomationResult(
      taskId: script.scriptId,
      success: true,
      executionTimeMs: elapsedMs > 0 ? elapsedMs : 1,
      stepsCompleted: script.steps.length,
      stepsFailed: 0,
      extractedData: const {},
      screenshots: const [],
      errorStep: null,
    );
  }

  // ---------------------------------------------------------------------------
  // validateScript
  // ---------------------------------------------------------------------------

  /// Validates [script] and returns a list of human-readable error messages.
  ///
  /// Returns an empty list when the script is valid.
  List<String> validateScript(AutomationScript script) {
    final errors = <String>[];

    if (script.steps.isEmpty) {
      errors.add('Script "${script.name}" has no steps.');
      return errors;
    }

    // Check for duplicate step numbers.
    final stepNumbers = script.steps.map((s) => s.stepNumber).toList();
    final unique = <int>{};
    final duplicates = <int>{};
    for (final n in stepNumbers) {
      if (!unique.add(n)) {
        duplicates.add(n);
      }
    }
    if (duplicates.isNotEmpty) {
      errors.add(
        'Duplicate step numbers found: ${duplicates.join(', ')}.',
      );
    }

    // Check that steps are in ascending order.
    for (var i = 1; i < script.steps.length; i++) {
      if (script.steps[i].stepNumber <= script.steps[i - 1].stepNumber) {
        errors.add(
          'Steps are not in ascending order at position $i '
          '(step ${script.steps[i].stepNumber} follows '
          '${script.steps[i - 1].stepNumber}).',
        );
        break;
      }
    }

    // Validate individual steps.
    for (final step in script.steps) {
      final stepErrors = _validateStep(step);
      errors.addAll(stepErrors);
    }

    return errors;
  }

  List<String> _validateStep(AutomationStep step) {
    final errors = <String>[];

    // Navigate steps use selector as URL — allow empty for optional.
    if (!step.isOptional && step.selector.isEmpty) {
      errors.add(
        'Step ${step.stepNumber} (${step.action.name}): '
        'selector must not be empty for required steps.',
      );
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // getScriptTemplate
  // ---------------------------------------------------------------------------

  /// Returns a pre-built [AutomationScript] template for [portal] and [task].
  ///
  /// Supported combinations:
  /// - `('traces', 'form16')` — TRACES Form 16 download
  /// - `('traces', 'challanStatus')` — TRACES challan status check
  /// - `('gstn', 'filingStatus')` — GST filing status
  /// - `('mca', 'formPrefill')` — MCA form prefill
  ///
  /// Unknown combinations return a fallback [AutomationScript] with an empty
  /// step list.
  AutomationScript getScriptTemplate(String portal, String task) {
    final key = '${portal.toLowerCase()}:${task.toLowerCase()}';

    switch (key) {
      case 'traces:form16':
        return AutomationScriptBuilder.buildTracesForm16Script(
          'PLACEHOLDER',
          DateTime.now().year,
          const ['PLACEHOLDER'],
        );

      case 'traces:challanstatus':
        return AutomationScriptBuilder.buildChallanStatusScript(
          'PLACEHOLDER',
          '0000000',
          '01/01/2024',
        );

      case 'gstn:filingstatus':
        return AutomationScriptBuilder.buildGstFilingStatusScript(
          'PLACEHOLDER',
          '032024',
        );

      case 'mca:formprefill':
        return AutomationScriptBuilder.buildMcaFormPrefillScript(
          'PLACEHOLDER',
          'AOC-4',
          const {'field1': 'value1'},
        );

      default:
        return AutomationScript(
          scriptId: 'unknown-$portal-$task',
          name: 'Unknown: $portal / $task',
          steps: const [],
          targetPortal: AutomationPortal.itd,
          estimatedDurationSeconds: 0,
          lastRunAt: null,
          successRate: 0.0,
        );
    }
  }
}
