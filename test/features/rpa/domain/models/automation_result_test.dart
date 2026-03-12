import 'package:ca_app/features/rpa/domain/models/automation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutomationResult', () {
    const result = AutomationResult(
      taskId: 'task-001',
      success: true,
      executionTimeMs: 4200,
      stepsCompleted: 11,
      stepsFailed: 0,
      extractedData: {'requestId': 'REQ2024001'},
      screenshots: ['/tmp/step5.png'],
      errorStep: null,
    );

    test('can be constructed with const', () {
      expect(result.taskId, 'task-001');
      expect(result.success, isTrue);
      expect(result.executionTimeMs, 4200);
      expect(result.stepsCompleted, 11);
      expect(result.stepsFailed, 0);
      expect(result.extractedData['requestId'], 'REQ2024001');
      expect(result.screenshots, hasLength(1));
      expect(result.errorStep, isNull);
    });

    group('copyWith', () {
      test('returns new instance', () {
        final copy = result.copyWith(success: false);
        expect(identical(result, copy), isFalse);
      });

      test('changes only specified fields', () {
        final copy = result.copyWith(
          success: false,
          stepsFailed: 1,
          errorStep: 5,
        );

        expect(copy.success, isFalse);
        expect(copy.stepsFailed, 1);
        expect(copy.errorStep, 5);
        expect(copy.taskId, result.taskId);
        expect(copy.executionTimeMs, result.executionTimeMs);
        expect(copy.stepsCompleted, result.stepsCompleted);
        expect(copy.extractedData, result.extractedData);
      });
    });

    group('equality', () {
      test('two results with same data are equal', () {
        const result2 = AutomationResult(
          taskId: 'task-001',
          success: true,
          executionTimeMs: 4200,
          stepsCompleted: 11,
          stepsFailed: 0,
          extractedData: {'requestId': 'REQ2024001'},
          screenshots: ['/tmp/step5.png'],
          errorStep: null,
        );

        expect(result, equals(result2));
      });

      test('results with different taskId are not equal', () {
        final other = result.copyWith(taskId: 'task-002');
        expect(result, isNot(equals(other)));
      });

      test('results with different success are not equal', () {
        final other = result.copyWith(success: false);
        expect(result, isNot(equals(other)));
      });
    });

    group('hashCode', () {
      test('equal results have same hashCode', () {
        const result2 = AutomationResult(
          taskId: 'task-001',
          success: true,
          executionTimeMs: 4200,
          stepsCompleted: 11,
          stepsFailed: 0,
          extractedData: {'requestId': 'REQ2024001'},
          screenshots: ['/tmp/step5.png'],
          errorStep: null,
        );

        expect(result.hashCode, result2.hashCode);
      });
    });

    group('toString', () {
      test('contains taskId and success', () {
        final str = result.toString();
        expect(str, contains('task-001'));
        expect(str, contains('true'));
      });
    });

    group('failed result', () {
      const failed = AutomationResult(
        taskId: 'task-002',
        success: false,
        executionTimeMs: 1200,
        stepsCompleted: 4,
        stepsFailed: 1,
        extractedData: {},
        screenshots: [],
        errorStep: 5,
      );

      test('errorStep is set for failed result', () {
        expect(failed.errorStep, 5);
        expect(failed.success, isFalse);
        expect(failed.stepsFailed, 1);
      });
    });
  });
}
