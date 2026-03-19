import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/rpa_script_executor.dart';

// ---------------------------------------------------------------------------
// Mock jsExecutor helpers
// ---------------------------------------------------------------------------

/// Always returns the supplied [returnValue].
Future<String> Function(String js) _alwaysReturn(String returnValue) =>
    (_) async => returnValue;

/// Throws [exception] on every call.
Future<String> Function(String js) _alwaysThrow(Object exception) =>
    (_) async => throw exception;

void main() {
  group('RpaScriptExecutor', () {
    const executor = RpaScriptExecutor();

    // -------------------------------------------------------------------------
    // Empty script
    // -------------------------------------------------------------------------

    group('empty script', () {
      test('stream completes immediately without emitting results', () async {
        const script = AutomationScript(
          id: 'empty',
          name: 'Empty Script',
          portal: RpaPortal.itd,
          steps: [],
        );

        final results = await executor
            .execute(script, _alwaysReturn('ok'))
            .toList();

        expect(results, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // Single step — navigate
    // -------------------------------------------------------------------------

    group('navigate step', () {
      test('emits one result for a navigate step', () async {
        const script = AutomationScript(
          id: 'nav-test',
          name: 'Navigate Test',
          portal: RpaPortal.itd,
          steps: [
            RpaStep(
              description: 'Navigate to ITD',
              action: RpaAction.navigate,
              value: 'https://incometax.gov.in',
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn(''))
            .toList();

        expect(results, hasLength(1));
        expect(results.first.step.action, equals(RpaAction.navigate));
        expect(results.first.success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Fill step
    // -------------------------------------------------------------------------

    group('fill step', () {
      test(
        'emits success result when jsExecutor returns without error',
        () async {
          const script = AutomationScript(
            id: 'fill-test',
            name: 'Fill Test',
            portal: RpaPortal.itd,
            steps: [
              RpaStep(
                description: 'Fill PAN field',
                action: RpaAction.fill,
                selector: '#pan',
                value: 'ABCDE1234F',
              ),
            ],
          );

          final results = await executor
              .execute(script, _alwaysReturn(''))
              .toList();

          expect(results.first.success, isTrue);
          expect(results.first.step.action, equals(RpaAction.fill));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Click step
    // -------------------------------------------------------------------------

    group('click step', () {
      test('emits success result for click action', () async {
        const script = AutomationScript(
          id: 'click-test',
          name: 'Click Test',
          portal: RpaPortal.gstn,
          steps: [
            RpaStep(
              description: 'Click submit button',
              action: RpaAction.click,
              selector: '#submitBtn',
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn(''))
            .toList();

        expect(results.first.success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Extract step
    // -------------------------------------------------------------------------

    group('extract step', () {
      test('result has extractedValue populated', () async {
        const script = AutomationScript(
          id: 'extract-test',
          name: 'Extract Test',
          portal: RpaPortal.gstn,
          steps: [
            RpaStep(
              description: 'Extract GSTIN status',
              action: RpaAction.extract,
              selector: '#status',
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn('Active'))
            .toList();

        expect(results.first.success, isTrue);
        expect(results.first.extractedValue, equals('Active'));
      });
    });

    // -------------------------------------------------------------------------
    // Upload step
    // -------------------------------------------------------------------------

    group('upload step', () {
      test('emits success result for upload action', () async {
        const script = AutomationScript(
          id: 'upload-test',
          name: 'Upload Test',
          portal: RpaPortal.epfo,
          steps: [
            RpaStep(
              description: 'Upload ECR file',
              action: RpaAction.upload,
              selector: 'input[type="file"]',
              value: '/tmp/ecr.txt',
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn(''))
            .toList();

        expect(results.first.success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Download step
    // -------------------------------------------------------------------------

    group('download step', () {
      test('emits success result for download action', () async {
        const script = AutomationScript(
          id: 'download-test',
          name: 'Download Test',
          portal: RpaPortal.traces,
          steps: [
            RpaStep(
              description: 'Download Form 16',
              action: RpaAction.download,
              value: 'https://tdscpc.gov.in/form16.zip',
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn(''))
            .toList();

        expect(results.first.success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Assert step
    // -------------------------------------------------------------------------

    group('assert step', () {
      test('success true when element text contains expected value', () async {
        const script = AutomationScript(
          id: 'assert-pass',
          name: 'Assert Pass',
          portal: RpaPortal.gstn,
          steps: [
            RpaStep(
              description: 'Assert success message',
              action: RpaAction.assert_,
              selector: '#statusMsg',
              value: 'Success',
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn('Request submitted Successfully'))
            .toList();

        expect(results.first.success, isTrue);
      });

      test(
        'success false when element text does not contain expected value',
        () async {
          const script = AutomationScript(
            id: 'assert-fail',
            name: 'Assert Fail',
            portal: RpaPortal.gstn,
            steps: [
              RpaStep(
                description: 'Assert success message',
                action: RpaAction.assert_,
                selector: '#statusMsg',
                value: 'Success',
              ),
            ],
          );

          final results = await executor
              .execute(script, _alwaysReturn('Error occurred'))
              .toList();

          expect(results.first.success, isFalse);
          expect(results.first.errorMessage, isNotNull);
          expect(results.first.extractedValue, equals('Error occurred'));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Wait step
    // -------------------------------------------------------------------------

    group('wait step', () {
      test(
        'wait step completes and emits success without calling jsExecutor',
        () async {
          var jsCallCount = 0;
          const script = AutomationScript(
            id: 'wait-test',
            name: 'Wait Test',
            portal: RpaPortal.mca,
            steps: [
              RpaStep(
                description: 'Wait for page load',
                action: RpaAction.wait,
                waitDuration: Duration(milliseconds: 1),
              ),
            ],
          );

          final results = await executor.execute(script, (js) async {
            jsCallCount++;
            return '';
          }).toList();

          expect(results.first.success, isTrue);
          expect(jsCallCount, equals(0));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Screenshot step
    // -------------------------------------------------------------------------

    group('screenshot step', () {
      test(
        'screenshot step emits success without calling jsExecutor',
        () async {
          var jsCallCount = 0;
          const script = AutomationScript(
            id: 'screenshot-test',
            name: 'Screenshot Test',
            portal: RpaPortal.traces,
            steps: [
              RpaStep(
                description: 'Capture audit screenshot',
                action: RpaAction.screenshot,
              ),
            ],
          );

          final results = await executor.execute(script, (js) async {
            jsCallCount++;
            return '';
          }).toList();

          expect(results.first.success, isTrue);
          expect(results.first.extractedValue, equals('screenshot_recorded'));
          expect(jsCallCount, equals(0));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Error handling — halt on failure
    // -------------------------------------------------------------------------

    group('error handling', () {
      test(
        'failed step halts execution when continueOnError is false',
        () async {
          const script = AutomationScript(
            id: 'halt-test',
            name: 'Halt On Error Test',
            portal: RpaPortal.itd,
            steps: [
              RpaStep(
                description: 'Step 1 — will throw',
                action: RpaAction.fill,
                selector: '#pan',
                value: 'ABCDE1234F',
                continueOnError: false,
              ),
              RpaStep(
                description: 'Step 2 — should not be reached',
                action: RpaAction.click,
                selector: '#submit',
                continueOnError: false,
              ),
            ],
          );

          final results = await executor
              .execute(script, _alwaysThrow(Exception('DOM error')))
              .toList();

          // Only the first step result should be emitted; execution halted.
          expect(results, hasLength(1));
          expect(results.first.success, isFalse);
          expect(results.first.errorMessage, isNotNull);
        },
      );

      test('execution continues when continueOnError is true', () async {
        const script = AutomationScript(
          id: 'continue-test',
          name: 'Continue On Error Test',
          portal: RpaPortal.gstn,
          steps: [
            RpaStep(
              description: 'Step 1 — will throw, but continue',
              action: RpaAction.fill,
              selector: '#gstin',
              value: 'invalid',
              continueOnError: true,
            ),
            RpaStep(
              description: 'Step 2 — should be reached',
              action: RpaAction.screenshot,
              continueOnError: false,
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysThrow(Exception('fill error')))
            .toList();

        expect(results, hasLength(2));
        expect(results[0].success, isFalse);
        expect(results[1].success, isTrue);
      });

      test(
        'exception thrown by jsExecutor is captured in errorMessage',
        () async {
          const script = AutomationScript(
            id: 'exception-test',
            name: 'Exception Test',
            portal: RpaPortal.mca,
            steps: [
              RpaStep(
                description: 'Step that throws',
                action: RpaAction.navigate,
                value: 'https://mca.gov.in',
                continueOnError: true,
              ),
            ],
          );

          final results = await executor
              .execute(script, _alwaysThrow(Exception('network timeout')))
              .toList();

          expect(results.first.success, isFalse);
          expect(results.first.errorMessage, contains('network timeout'));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Stream semantics
    // -------------------------------------------------------------------------

    group('stream semantics', () {
      test('emits one result per step for multi-step script', () async {
        const script = AutomationScript(
          id: 'multi-step',
          name: 'Multi Step',
          portal: RpaPortal.traces,
          steps: [
            RpaStep(
              description: 'Navigate',
              action: RpaAction.navigate,
              value: 'https://tdscpc.gov.in',
            ),
            RpaStep(
              description: 'Wait',
              action: RpaAction.wait,
              waitDuration: Duration(milliseconds: 1),
            ),
            RpaStep(description: 'Screenshot', action: RpaAction.screenshot),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn(''))
            .toList();

        expect(results, hasLength(3));
      });

      test('each result has a non-null timestamp', () async {
        const script = AutomationScript(
          id: 'timestamp-test',
          name: 'Timestamp Test',
          portal: RpaPortal.itd,
          steps: [
            RpaStep(
              description: 'Fill field',
              action: RpaAction.fill,
              selector: '#x',
              value: 'v',
            ),
          ],
        );

        final results = await executor
            .execute(script, _alwaysReturn(''))
            .toList();

        expect(results.first.timestamp, isNotNull);
      });

      test('each result references the corresponding step', () async {
        const step = RpaStep(
          description: 'Navigate to page',
          action: RpaAction.navigate,
          value: 'https://example.com',
        );
        const script = AutomationScript(
          id: 'ref-test',
          name: 'Ref Test',
          portal: RpaPortal.itd,
          steps: [step],
        );

        final results = await executor
            .execute(script, _alwaysReturn(''))
            .toList();

        expect(results.first.step, equals(step));
      });

      test('can use expectLater with emitsInOrder for stream assertions', () {
        const script = AutomationScript(
          id: 'stream-order',
          name: 'Stream Order',
          portal: RpaPortal.gstn,
          steps: [
            RpaStep(description: 'Screenshot', action: RpaAction.screenshot),
          ],
        );

        final stream = executor.execute(script, _alwaysReturn(''));

        expectLater(
          stream,
          emits(
            predicate<RpaStepResult>(
              (r) => r.success && r.step.action == RpaAction.screenshot,
              'success screenshot result',
            ),
          ),
        );
      });
    });

    // -------------------------------------------------------------------------
    // RpaStepResult model
    // -------------------------------------------------------------------------

    group('RpaStepResult', () {
      const step = RpaStep(
        description: 'test step',
        action: RpaAction.fill,
        selector: '#x',
        value: 'v',
      );

      test('equality based on step, success, and timestamp', () {
        final ts = DateTime(2025, 1, 15);
        final a = RpaStepResult(step: step, success: true, timestamp: ts);
        final b = RpaStepResult(step: step, success: true, timestamp: ts);
        expect(a, equals(b));
      });

      test('results with different success values are not equal', () {
        final ts = DateTime(2025, 1, 15);
        final a = RpaStepResult(step: step, success: true, timestamp: ts);
        final b = RpaStepResult(step: step, success: false, timestamp: ts);
        expect(a, isNot(equals(b)));
      });

      test('toString contains action name and success', () {
        final result = RpaStepResult(
          step: step,
          success: true,
          timestamp: DateTime.now(),
        );
        expect(result.toString(), contains('fill'));
        expect(result.toString(), contains('true'));
      });
    });

    // -------------------------------------------------------------------------
    // RpaStep model
    // -------------------------------------------------------------------------

    group('RpaStep', () {
      test('description field is required and non-empty', () {
        const s = RpaStep(
          description: 'Navigate to portal',
          action: RpaAction.navigate,
          value: 'https://incometax.gov.in',
        );

        expect(s.description, isNotEmpty);
      });

      test('continueOnError defaults to false', () {
        const s = RpaStep(
          description: 'Click submit',
          action: RpaAction.click,
          selector: '#btn',
        );

        expect(s.continueOnError, isFalse);
      });

      test('equality based on description, action, selector, value', () {
        const a = RpaStep(
          description: 'Fill PAN',
          action: RpaAction.fill,
          selector: '#pan',
          value: 'ABCDE1234F',
        );
        const b = RpaStep(
          description: 'Fill PAN',
          action: RpaAction.fill,
          selector: '#pan',
          value: 'ABCDE1234F',
          continueOnError: true,
        );
        expect(a, equals(b));
      });

      test('toString contains action name and description', () {
        const s = RpaStep(
          description: 'Fill GSTIN',
          action: RpaAction.fill,
          selector: '#gstin',
        );
        expect(s.toString(), contains('fill'));
        expect(s.toString(), contains('Fill GSTIN'));
      });
    });

    // -------------------------------------------------------------------------
    // AutomationScript model
    // -------------------------------------------------------------------------

    group('AutomationScript', () {
      test('equality based on id only', () {
        const a = AutomationScript(
          id: 'script-001',
          name: 'Script A',
          portal: RpaPortal.itd,
          steps: [],
        );
        const b = AutomationScript(
          id: 'script-001',
          name: 'Script B',
          portal: RpaPortal.gstn,
          steps: [RpaStep(description: 'step', action: RpaAction.screenshot)],
        );
        expect(a, equals(b));
      });

      test('scripts with different IDs are not equal', () {
        const a = AutomationScript(
          id: 'id-a',
          name: 'Script',
          portal: RpaPortal.mca,
          steps: [],
        );
        const b = AutomationScript(
          id: 'id-b',
          name: 'Script',
          portal: RpaPortal.mca,
          steps: [],
        );
        expect(a, isNot(equals(b)));
      });

      test('toString contains id, portal label, and step count', () {
        const script = AutomationScript(
          id: 'my-script',
          name: 'My Script',
          portal: RpaPortal.traces,
          steps: [RpaStep(description: 'step', action: RpaAction.screenshot)],
        );
        expect(script.toString(), contains('my-script'));
        expect(script.toString(), contains('TRACES'));
        expect(script.toString(), contains('1'));
      });
    });
  });
}
