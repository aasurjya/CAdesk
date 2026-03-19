import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/auto_fill_script.dart';

void main() {
  group('AutoFillAction enum', () {
    test('has fill value', () {
      expect(AutoFillAction.values, contains(AutoFillAction.fill));
    });

    test('has click value', () {
      expect(AutoFillAction.values, contains(AutoFillAction.click));
    });

    test('has select value', () {
      expect(AutoFillAction.values, contains(AutoFillAction.select));
    });

    test('has screenshot value', () {
      expect(AutoFillAction.values, contains(AutoFillAction.screenshot));
    });

    test('has wait value', () {
      expect(AutoFillAction.values, contains(AutoFillAction.wait));
    });

    test('has assert_ value', () {
      expect(AutoFillAction.values, contains(AutoFillAction.assert_));
    });

    test('has exactly 6 values', () {
      expect(AutoFillAction.values, hasLength(6));
    });
  });

  group('PortalFormType enum', () {
    test('has itdPersonalInfo', () {
      expect(PortalFormType.values, contains(PortalFormType.itdPersonalInfo));
    });

    test('has itdBankDetails', () {
      expect(PortalFormType.values, contains(PortalFormType.itdBankDetails));
    });

    test('has gstnGstr1', () {
      expect(PortalFormType.values, contains(PortalFormType.gstnGstr1));
    });

    test('has tracesAuth', () {
      expect(PortalFormType.values, contains(PortalFormType.tracesAuth));
    });

    test('has mcaCompanyForm', () {
      expect(PortalFormType.values, contains(PortalFormType.mcaCompanyForm));
    });
  });

  group('AutoFillStep', () {
    const step = AutoFillStep(
      selector: '#firstName',
      action: AutoFillAction.fill,
      value: 'Rahul',
      description: 'Fill first name',
      altSelector: '[name="firstName"]',
      timeoutMs: 5000,
    );

    test('constructor assigns all fields', () {
      expect(step.selector, equals('#firstName'));
      expect(step.action, equals(AutoFillAction.fill));
      expect(step.value, equals('Rahul'));
      expect(step.description, equals('Fill first name'));
      expect(step.altSelector, equals('[name="firstName"]'));
      expect(step.timeoutMs, equals(5000));
    });

    test('default timeoutMs is 10000', () {
      const s = AutoFillStep(selector: '#x', action: AutoFillAction.click);
      expect(s.timeoutMs, equals(10000));
    });

    test('description is optional (nullable)', () {
      const s = AutoFillStep(selector: '#x', action: AutoFillAction.click);
      expect(s.description, isNull);
    });

    test('copyWith returns new instance with changed selector', () {
      final copy = step.copyWith(selector: '#lastName');
      expect(copy.selector, equals('#lastName'));
      expect(copy.action, equals(step.action));
      expect(copy.value, equals(step.value));
    });

    test('copyWith returns new instance with changed action', () {
      final copy = step.copyWith(action: AutoFillAction.click);
      expect(copy.action, equals(AutoFillAction.click));
      expect(copy.selector, equals(step.selector));
    });

    test('copyWith returns new instance with changed value', () {
      final copy = step.copyWith(value: 'Priya');
      expect(copy.value, equals('Priya'));
    });

    test('copyWith returns new instance with changed timeoutMs', () {
      final copy = step.copyWith(timeoutMs: 20000);
      expect(copy.timeoutMs, equals(20000));
    });

    test('equality based on selector, action, and value', () {
      const a = AutoFillStep(
        selector: '#pan',
        action: AutoFillAction.fill,
        value: 'ABCDE1234F',
      );
      const b = AutoFillStep(
        selector: '#pan',
        action: AutoFillAction.fill,
        value: 'ABCDE1234F',
        description: 'Different description',
      );
      expect(a, equals(b));
    });

    test('two steps with different selectors are not equal', () {
      const a = AutoFillStep(selector: '#pan', action: AutoFillAction.fill);
      const b = AutoFillStep(selector: '#tan', action: AutoFillAction.fill);
      expect(a, isNot(equals(b)));
    });

    test('toString contains action name and selector', () {
      expect(step.toString(), contains('fill'));
      expect(step.toString(), contains('#firstName'));
    });

    test('toString includes value when present', () {
      expect(step.toString(), contains('Rahul'));
    });
  });

  group('AutoFillScript', () {
    test('constructor assigns formType', () {
      const script = AutoFillScript(
        formType: PortalFormType.itdPersonalInfo,
        steps: [],
      );

      expect(script.formType, equals(PortalFormType.itdPersonalInfo));
    });

    test('isEmpty is true for empty steps list', () {
      const script = AutoFillScript(
        formType: PortalFormType.itdBankDetails,
        steps: [],
      );

      expect(script.isEmpty, isTrue);
      expect(script.length, equals(0));
    });

    test('length reflects number of steps', () {
      const script = AutoFillScript(
        formType: PortalFormType.itdPersonalInfo,
        steps: [
          AutoFillStep(selector: '#a', action: AutoFillAction.fill),
          AutoFillStep(selector: '#b', action: AutoFillAction.click),
        ],
      );

      expect(script.length, equals(2));
      expect(script.isEmpty, isFalse);
    });

    test('steps getter returns unmodifiable list', () {
      const script = AutoFillScript(
        formType: PortalFormType.itdPersonalInfo,
        steps: [AutoFillStep(selector: '#x', action: AutoFillAction.fill)],
      );

      expect(
        () => (script.steps as dynamic).add(
          const AutoFillStep(selector: '#y', action: AutoFillAction.click),
        ),
        throwsUnsupportedError,
      );
    });

    test('equality based on formType only', () {
      const a = AutoFillScript(formType: PortalFormType.gstnGstr1, steps: []);
      const b = AutoFillScript(
        formType: PortalFormType.gstnGstr1,
        steps: [AutoFillStep(selector: '#x', action: AutoFillAction.click)],
      );
      expect(a, equals(b));
    });

    test('scripts with different formTypes are not equal', () {
      const a = AutoFillScript(
        formType: PortalFormType.itdPersonalInfo,
        steps: [],
      );
      const b = AutoFillScript(
        formType: PortalFormType.itdBankDetails,
        steps: [],
      );
      expect(a, isNot(equals(b)));
    });

    test('toString contains formType name and step count', () {
      const script = AutoFillScript(
        formType: PortalFormType.tracesAuth,
        steps: [AutoFillStep(selector: '#userId', action: AutoFillAction.fill)],
      );

      expect(script.toString(), contains('tracesAuth'));
      expect(script.toString(), contains('1'));
    });
  });

  group('AutoFillScript.forItdPersonalInfo factory', () {
    test('returns script with formType itdPersonalInfo', () {
      final script = AutoFillScript.forItdPersonalInfo({
        'firstName': 'Rahul',
        'lastName': 'Sharma',
      });

      expect(script.formType, equals(PortalFormType.itdPersonalInfo));
    });

    test('has at least 5 steps (one per mapped field + screenshot)', () {
      final script = AutoFillScript.forItdPersonalInfo({
        'firstName': 'Rahul',
        'lastName': 'Sharma',
        'dob': '01/01/1990',
        'mobile': '9876543210',
        'email': 'rahul@example.com',
      });

      expect(script.length, greaterThanOrEqualTo(5));
    });

    test('includes screenshot step as last audit step', () {
      final script = AutoFillScript.forItdPersonalInfo({});

      final hasScreenshot = script.steps.any(
        (s) => s.action == AutoFillAction.screenshot,
      );
      expect(hasScreenshot, isTrue);
    });

    test('first name step uses fill action', () {
      final script = AutoFillScript.forItdPersonalInfo({'firstName': 'Priya'});

      final firstNameStep = script.steps.firstWhere(
        (s) =>
            s.action == AutoFillAction.fill && s.selector.contains('firstName'),
      );

      expect(firstNameStep.value, equals('Priya'));
    });

    test('fill steps have non-null descriptions', () {
      final script = AutoFillScript.forItdPersonalInfo({'firstName': 'Rahul'});

      final fillSteps = script.steps.where(
        (s) => s.action == AutoFillAction.fill,
      );

      for (final s in fillSteps) {
        expect(s.description, isNotNull);
        expect(s.description, isNotEmpty);
      }
    });
  });

  group('AutoFillScript.forItdBankDetails factory', () {
    test('returns script with formType itdBankDetails', () {
      final script = AutoFillScript.forItdBankDetails({});

      expect(script.formType, equals(PortalFormType.itdBankDetails));
    });

    test('has steps for account number and IFSC', () {
      final script = AutoFillScript.forItdBankDetails({
        'accountNumber': '123456789012',
        'ifsc': 'HDFC0001234',
      });

      final hasAccountStep = script.steps.any(
        (s) => s.selector.contains('accountNumber'),
      );
      final hasIfscStep = script.steps.any((s) => s.selector.contains('ifsc'));

      expect(hasAccountStep, isTrue);
      expect(hasIfscStep, isTrue);
    });

    test('bank name step uses select action', () {
      final script = AutoFillScript.forItdBankDetails({
        'bankName': 'State Bank of India',
      });

      final selectSteps = script.steps.where(
        (s) => s.action == AutoFillAction.select,
      );

      expect(selectSteps, isNotEmpty);
    });

    test('includes screenshot for audit trail', () {
      final script = AutoFillScript.forItdBankDetails({});

      final screenshotSteps = script.steps.where(
        (s) => s.action == AutoFillAction.screenshot,
      );
      expect(screenshotSteps, isNotEmpty);
    });
  });
}
