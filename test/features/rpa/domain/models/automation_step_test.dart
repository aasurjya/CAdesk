import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutomationStep', () {
    const step = AutomationStep(
      stepNumber: 1,
      action: StepAction.navigate,
      selector: 'https://traces.gov.in/Login.html',
      value: null,
      expectedOutcome: null,
      timeoutSeconds: 30,
      isOptional: false,
    );

    test('can be constructed with const', () {
      expect(step.stepNumber, 1);
      expect(step.action, StepAction.navigate);
      expect(step.selector, 'https://traces.gov.in/Login.html');
      expect(step.value, isNull);
      expect(step.expectedOutcome, isNull);
      expect(step.timeoutSeconds, 30);
      expect(step.isOptional, false);
    });

    group('copyWith', () {
      test('returns new instance', () {
        final copy = step.copyWith(stepNumber: 2);
        expect(identical(step, copy), isFalse);
      });

      test('changes only specified fields', () {
        final copy = step.copyWith(
          action: StepAction.click,
          selector: '#loginBtn',
          isOptional: true,
        );

        expect(copy.action, StepAction.click);
        expect(copy.selector, '#loginBtn');
        expect(copy.isOptional, true);
        expect(copy.stepNumber, step.stepNumber);
        expect(copy.timeoutSeconds, step.timeoutSeconds);
      });
    });

    group('equality', () {
      test('two steps with same data are equal', () {
        const step2 = AutomationStep(
          stepNumber: 1,
          action: StepAction.navigate,
          selector: 'https://traces.gov.in/Login.html',
          value: null,
          expectedOutcome: null,
          timeoutSeconds: 30,
          isOptional: false,
        );

        expect(step, equals(step2));
      });

      test('steps with different stepNumber are not equal', () {
        final other = step.copyWith(stepNumber: 5);
        expect(step, isNot(equals(other)));
      });
    });

    group('hashCode', () {
      test('equal steps have same hashCode', () {
        const step2 = AutomationStep(
          stepNumber: 1,
          action: StepAction.navigate,
          selector: 'https://traces.gov.in/Login.html',
          value: null,
          expectedOutcome: null,
          timeoutSeconds: 30,
          isOptional: false,
        );

        expect(step.hashCode, step2.hashCode);
      });
    });

    group('toString', () {
      test('contains stepNumber and action', () {
        final str = step.toString();
        expect(str, contains('1'));
        expect(str, contains('navigate'));
      });
    });

    group('StepAction enum', () {
      test('all expected values exist', () {
        expect(
          StepAction.values,
          containsAll([
            StepAction.navigate,
            StepAction.click,
            StepAction.type,
            StepAction.select,
            StepAction.waitFor,
            StepAction.extractText,
            StepAction.download,
            StepAction.screenshot,
            StepAction.validateText,
          ]),
        );
      });
    });
  });
}
