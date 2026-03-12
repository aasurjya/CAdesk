import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutomationScript', () {
    const step1 = AutomationStep(
      stepNumber: 1,
      action: StepAction.navigate,
      selector: 'https://traces.gov.in/Login.html',
      value: null,
      expectedOutcome: null,
      timeoutSeconds: 30,
      isOptional: false,
    );

    const step2 = AutomationStep(
      stepNumber: 2,
      action: StepAction.click,
      selector: '#loginBtn',
      value: null,
      expectedOutcome: null,
      timeoutSeconds: 30,
      isOptional: false,
    );

    const script = AutomationScript(
      scriptId: 'script-001',
      name: 'TRACES Form 16',
      steps: [step1, step2],
      targetPortal: AutomationPortal.traces,
      estimatedDurationSeconds: 120,
      lastRunAt: null,
      successRate: 0.95,
    );

    test('can be constructed with const', () {
      expect(script.scriptId, 'script-001');
      expect(script.name, 'TRACES Form 16');
      expect(script.steps.length, 2);
      expect(script.targetPortal, AutomationPortal.traces);
      expect(script.estimatedDurationSeconds, 120);
      expect(script.lastRunAt, isNull);
      expect(script.successRate, 0.95);
    });

    group('copyWith', () {
      test('returns new instance', () {
        final copy = script.copyWith(name: 'Updated');
        expect(identical(script, copy), isFalse);
      });

      test('changes only specified fields', () {
        final ran = DateTime(2026, 3, 12);
        final copy = script.copyWith(
          successRate: 0.88,
          lastRunAt: ran,
        );

        expect(copy.successRate, 0.88);
        expect(copy.lastRunAt, ran);
        expect(copy.scriptId, script.scriptId);
        expect(copy.name, script.name);
        expect(copy.steps, script.steps);
        expect(copy.targetPortal, script.targetPortal);
      });
    });

    group('equality', () {
      test('two scripts with same data are equal', () {
        const script2 = AutomationScript(
          scriptId: 'script-001',
          name: 'TRACES Form 16',
          steps: [step1, step2],
          targetPortal: AutomationPortal.traces,
          estimatedDurationSeconds: 120,
          lastRunAt: null,
          successRate: 0.95,
        );

        expect(script, equals(script2));
      });

      test('scripts with different scriptId are not equal', () {
        final other = script.copyWith(scriptId: 'script-002');
        expect(script, isNot(equals(other)));
      });
    });

    group('hashCode', () {
      test('equal scripts have same hashCode', () {
        const script2 = AutomationScript(
          scriptId: 'script-001',
          name: 'TRACES Form 16',
          steps: [step1, step2],
          targetPortal: AutomationPortal.traces,
          estimatedDurationSeconds: 120,
          lastRunAt: null,
          successRate: 0.95,
        );

        expect(script.hashCode, script2.hashCode);
      });
    });

    group('toString', () {
      test('contains scriptId and name', () {
        final str = script.toString();
        expect(str, contains('script-001'));
        expect(str, contains('TRACES Form 16'));
      });
    });
  });
}
