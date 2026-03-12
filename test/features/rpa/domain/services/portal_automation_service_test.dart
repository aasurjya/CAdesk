import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:ca_app/features/rpa/domain/services/automation_script_builder.dart';
import 'package:ca_app/features/rpa/domain/services/portal_automation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PortalAutomationService', () {
    final service = PortalAutomationService.instance;

    // -------------------------------------------------------------------------
    // executeScript
    // -------------------------------------------------------------------------
    group('executeScript', () {
      test('returns an AutomationResult for a valid script', () async {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final result = await service.executeScript(script, {'token': 'abc123'});

        expect(result.taskId, script.scriptId);
      });

      test('success result has stepsCompleted equal to script step count',
          () async {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final result = await service.executeScript(script, {});

        expect(result.stepsCompleted, script.steps.length);
        expect(result.stepsFailed, 0);
      });

      test('success is true for mock execution', () async {
        final script = AutomationScriptBuilder.buildChallanStatusScript(
          'AAATA1234X',
          '0002390',
          '07/03/2026',
        );

        final result = await service.executeScript(script, {});

        expect(result.success, isTrue);
      });

      test('executionTimeMs is positive', () async {
        final script = AutomationScriptBuilder.buildGstFilingStatusScript(
          '27AABCU9603R1ZX',
          '032026',
        );

        final result = await service.executeScript(script, {});

        expect(result.executionTimeMs, greaterThan(0));
      });

      test('extractedData is a map', () async {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final result = await service.executeScript(script, {});

        expect(result.extractedData, isA<Map<String, String>>());
      });

      test('errorStep is null on success', () async {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final result = await service.executeScript(script, {});

        expect(result.errorStep, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // validateScript
    // -------------------------------------------------------------------------
    group('validateScript', () {
      test('valid script returns empty error list', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final errors = service.validateScript(script);

        expect(errors, isEmpty);
      });

      test('script with no steps returns an error', () {
        const script = AutomationScript(
          scriptId: 'empty-script',
          name: 'Empty',
          steps: [],
          targetPortal: AutomationPortal.traces,
          estimatedDurationSeconds: 30,
          lastRunAt: null,
          successRate: 0.0,
        );

        final errors = service.validateScript(script);

        expect(errors, isNotEmpty);
      });

      test('duplicate stepNumbers returns an error', () {
        const step1 = AutomationStep(
          stepNumber: 1,
          action: StepAction.navigate,
          selector: 'https://example.com',
          value: null,
          expectedOutcome: null,
          timeoutSeconds: 30,
          isOptional: false,
        );

        const step2 = AutomationStep(
          stepNumber: 1, // duplicate!
          action: StepAction.click,
          selector: '#btn',
          value: null,
          expectedOutcome: null,
          timeoutSeconds: 30,
          isOptional: false,
        );

        const script = AutomationScript(
          scriptId: 'dup-script',
          name: 'Dup',
          steps: [step1, step2],
          targetPortal: AutomationPortal.traces,
          estimatedDurationSeconds: 30,
          lastRunAt: null,
          successRate: 0.0,
        );

        final errors = service.validateScript(script);

        expect(errors, isNotEmpty);
        expect(
          errors.any((e) => e.toLowerCase().contains('duplicate')),
          isTrue,
        );
      });

      test('steps out of order returns an error', () {
        const step1 = AutomationStep(
          stepNumber: 2,
          action: StepAction.navigate,
          selector: 'https://example.com',
          value: null,
          expectedOutcome: null,
          timeoutSeconds: 30,
          isOptional: false,
        );

        const step2 = AutomationStep(
          stepNumber: 1, // wrong order
          action: StepAction.click,
          selector: '#btn',
          value: null,
          expectedOutcome: null,
          timeoutSeconds: 30,
          isOptional: false,
        );

        const script = AutomationScript(
          scriptId: 'oor-script',
          name: 'OutOfOrder',
          steps: [step1, step2],
          targetPortal: AutomationPortal.traces,
          estimatedDurationSeconds: 30,
          lastRunAt: null,
          successRate: 0.0,
        );

        final errors = service.validateScript(script);

        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('order')), isTrue);
      });

      test('empty selector on a required step returns an error', () {
        const step = AutomationStep(
          stepNumber: 1,
          action: StepAction.click,
          selector: '', // empty selector
          value: null,
          expectedOutcome: null,
          timeoutSeconds: 30,
          isOptional: false,
        );

        const script = AutomationScript(
          scriptId: 'bad-selector',
          name: 'BadSelector',
          steps: [step],
          targetPortal: AutomationPortal.traces,
          estimatedDurationSeconds: 30,
          lastRunAt: null,
          successRate: 0.0,
        );

        final errors = service.validateScript(script);

        expect(errors, isNotEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // getScriptTemplate
    // -------------------------------------------------------------------------
    group('getScriptTemplate', () {
      test('returns TRACES Form 16 template', () {
        final script = service.getScriptTemplate('traces', 'form16');

        expect(script.targetPortal, AutomationPortal.traces);
        expect(script.steps, isNotEmpty);
      });

      test('returns TRACES challan template', () {
        final script = service.getScriptTemplate('traces', 'challanStatus');

        expect(script.targetPortal, AutomationPortal.traces);
        expect(script.steps, isNotEmpty);
      });

      test('returns GST filing status template', () {
        final script = service.getScriptTemplate('gstn', 'filingStatus');

        expect(script.targetPortal, AutomationPortal.gstn);
        expect(script.steps, isNotEmpty);
      });

      test('returns MCA prefill template', () {
        final script = service.getScriptTemplate('mca', 'formPrefill');

        expect(script.targetPortal, AutomationPortal.mca);
        expect(script.steps, isNotEmpty);
      });

      test('unknown portal+task returns a fallback script with empty steps',
          () {
        final script = service.getScriptTemplate('unknown', 'nonexistent');

        expect(script, isA<AutomationScript>());
      });
    });

    // -------------------------------------------------------------------------
    // Singleton
    // -------------------------------------------------------------------------
    group('singleton', () {
      test('instance returns same object each time', () {
        final a = PortalAutomationService.instance;
        final b = PortalAutomationService.instance;

        expect(identical(a, b), isTrue);
      });
    });
  });
}
