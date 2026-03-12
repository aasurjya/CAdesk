import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/automation_script_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutomationScriptBuilder', () {
    // -------------------------------------------------------------------------
    // buildTracesForm16Script
    // -------------------------------------------------------------------------
    group('buildTracesForm16Script', () {
      test('returns an AutomationScript targeting TRACES portal', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F', 'XYZAB5678G'],
        );

        expect(script, isA<AutomationScript>());
        expect(script.targetPortal, AutomationPortal.traces);
      });

      test('name contains Form 16', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        expect(script.name.toLowerCase(), contains('form 16'));
      });

      test('steps are in strictly ascending order', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        for (var i = 0; i < script.steps.length - 1; i++) {
          expect(
            script.steps[i].stepNumber,
            lessThan(script.steps[i + 1].stepNumber),
          );
        }
      });

      test('first step navigates to TRACES login URL', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final first = script.steps.first;
        expect(first.action, StepAction.navigate);
        expect(first.selector, contains('traces.gov.in'));
      });

      test('contains a type step targeting #userid selector', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final userIdStep = script.steps.firstWhere(
          (s) => s.action == StepAction.type && s.selector == '#userid',
        );
        expect(userIdStep, isNotNull);
      });

      test('contains a select step for financial year', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final fyStep = script.steps.firstWhere(
          (s) =>
              s.action == StepAction.select &&
              s.selector == '#financialYear',
        );
        expect(fyStep, isNotNull);
        expect(fyStep.value, contains('2024'));
      });

      test('contains a type step for pan list', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F', 'XYZAB5678G'],
        );

        final panStep = script.steps.firstWhere(
          (s) => s.action == StepAction.type && s.selector == '#panList',
        );
        expect(panStep, isNotNull);
        expect(panStep.value, contains('ABCDE1234F'));
        expect(panStep.value, contains('XYZAB5678G'));
      });

      test('contains an extractText step for requestId', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        final extractStep = script.steps.firstWhere(
          (s) => s.action == StepAction.extractText,
        );
        expect(extractStep.selector, contains('requestId'));
      });

      test('has a positive estimatedDurationSeconds', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        expect(script.estimatedDurationSeconds, greaterThan(0));
      });

      test('successRate starts at 0', () {
        final script = AutomationScriptBuilder.buildTracesForm16Script(
          'AAATA1234X',
          2024,
          ['ABCDE1234F'],
        );

        expect(script.successRate, 0.0);
      });
    });

    // -------------------------------------------------------------------------
    // buildChallanStatusScript
    // -------------------------------------------------------------------------
    group('buildChallanStatusScript', () {
      test('returns AutomationScript targeting TRACES portal', () {
        final script = AutomationScriptBuilder.buildChallanStatusScript(
          'AAATA1234X',
          '0002390',
          '07/03/2026',
        );

        expect(script.targetPortal, AutomationPortal.traces);
      });

      test('name contains Challan', () {
        final script = AutomationScriptBuilder.buildChallanStatusScript(
          'AAATA1234X',
          '0002390',
          '07/03/2026',
        );

        expect(script.name.toLowerCase(), contains('challan'));
      });

      test('steps in ascending order', () {
        final script = AutomationScriptBuilder.buildChallanStatusScript(
          'AAATA1234X',
          '0002390',
          '07/03/2026',
        );

        for (var i = 0; i < script.steps.length - 1; i++) {
          expect(
            script.steps[i].stepNumber,
            lessThan(script.steps[i + 1].stepNumber),
          );
        }
      });

      test('contains extractText step for status', () {
        final script = AutomationScriptBuilder.buildChallanStatusScript(
          'AAATA1234X',
          '0002390',
          '07/03/2026',
        );

        final hasExtract = script.steps.any(
          (s) => s.action == StepAction.extractText,
        );
        expect(hasExtract, isTrue);
      });

      test('BSR code appears in a type step value', () {
        final script = AutomationScriptBuilder.buildChallanStatusScript(
          'AAATA1234X',
          '0002390',
          '07/03/2026',
        );

        final hasBsr = script.steps.any(
          (s) =>
              s.action == StepAction.type &&
              (s.value ?? '').contains('0002390'),
        );
        expect(hasBsr, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // buildGstFilingStatusScript
    // -------------------------------------------------------------------------
    group('buildGstFilingStatusScript', () {
      test('returns AutomationScript targeting GSTN portal', () {
        final script = AutomationScriptBuilder.buildGstFilingStatusScript(
          '27AABCU9603R1ZX',
          '032026',
        );

        expect(script.targetPortal, AutomationPortal.gstn);
      });

      test('name contains GST', () {
        final script = AutomationScriptBuilder.buildGstFilingStatusScript(
          '27AABCU9603R1ZX',
          '032026',
        );

        expect(script.name.toUpperCase(), contains('GST'));
      });

      test('steps in ascending order', () {
        final script = AutomationScriptBuilder.buildGstFilingStatusScript(
          '27AABCU9603R1ZX',
          '032026',
        );

        for (var i = 0; i < script.steps.length - 1; i++) {
          expect(
            script.steps[i].stepNumber,
            lessThan(script.steps[i + 1].stepNumber),
          );
        }
      });

      test('contains at least two extractText steps (GSTR-1 and GSTR-3B)', () {
        final script = AutomationScriptBuilder.buildGstFilingStatusScript(
          '27AABCU9603R1ZX',
          '032026',
        );

        final extractCount = script.steps
            .where((s) => s.action == StepAction.extractText)
            .length;
        expect(extractCount, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // buildMcaFormPrefillScript
    // -------------------------------------------------------------------------
    group('buildMcaFormPrefillScript', () {
      test('returns AutomationScript targeting MCA portal', () {
        final script = AutomationScriptBuilder.buildMcaFormPrefillScript(
          'U74999DL2020PTC123456',
          'AOC-4',
          {'authorisedCapital': '100000', 'paidUpCapital': '100000'},
        );

        expect(script.targetPortal, AutomationPortal.mca);
      });

      test('name contains form type', () {
        final script = AutomationScriptBuilder.buildMcaFormPrefillScript(
          'U74999DL2020PTC123456',
          'AOC-4',
          {'authorisedCapital': '100000'},
        );

        expect(script.name, contains('AOC-4'));
      });

      test('steps in ascending order', () {
        final script = AutomationScriptBuilder.buildMcaFormPrefillScript(
          'U74999DL2020PTC123456',
          'AOC-4',
          {'authorisedCapital': '100000'},
        );

        for (var i = 0; i < script.steps.length - 1; i++) {
          expect(
            script.steps[i].stepNumber,
            lessThan(script.steps[i + 1].stepNumber),
          );
        }
      });

      test('data fields generate type steps', () {
        final script = AutomationScriptBuilder.buildMcaFormPrefillScript(
          'U74999DL2020PTC123456',
          'AOC-4',
          {'authorisedCapital': '500000', 'paidUpCapital': '200000'},
        );

        final typeSteps = script.steps
            .where((s) => s.action == StepAction.type)
            .toList();
        // At minimum: CIN step + each data field
        expect(typeSteps.length, greaterThanOrEqualTo(3));
      });
    });
  });
}
