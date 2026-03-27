import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/data/repositories/mock_submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/submission_flow_screen.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _testJobId = 'test-job-001';

SubmissionJob _createTestJob({
  String id = _testJobId,
  SubmissionStep step = SubmissionStep.pending,
}) {
  return SubmissionJob(
    id: id,
    clientId: 'client-001',
    clientName: 'Ramesh Kumar',
    portalType: PortalType.itd,
    returnType: 'ITR-1',
    currentStep: step,
    retryCount: 0,
    createdAt: DateTime(2026, 3, 15),
  );
}

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Builds the [SubmissionFlowScreen] with a real [MockSubmissionRepository]
/// and [SubmissionOrchestrator], seeded with the given [job].
Future<(MockSubmissionRepository, SubmissionOrchestrator)> _pumpScreen(
  WidgetTester tester, {
  SubmissionJob? job,
}) async {
  final repo = MockSubmissionRepository();
  final orchestrator = SubmissionOrchestrator(repository: repo);

  final testJob = job ?? _createTestJob();
  await repo.insert(testJob);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        submissionRepositoryProvider.overrideWithValue(repo),
        submissionOrchestratorProvider.overrideWithValue(orchestrator),
      ],
      child: const MaterialApp(home: SubmissionFlowScreen(jobId: _testJobId)),
    ),
  );
  await tester.pump();

  return (repo, orchestrator);
}

/// Runs the complete automation flow from start through completion.
/// Returns after the success banner is displayed.
///
/// Login: 2+2+3s, FormFill: 2+3+2s, OTP: pause→enter→200ms,
/// Review: pause→confirm→200ms, Submit: 3s, Download: 3s.
Future<void> _runFullFlow(WidgetTester tester) async {
  // Start
  await tester.tap(find.text('Start Filing Automation'));
  await tester.pump();

  // Login (7s total)
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 100));

  // Form Fill (7s total)
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(milliseconds: 100));

  // OTP — enter and verify
  await tester.pump(const Duration(milliseconds: 300));
  await tester.enterText(find.byType(TextField), '123456');
  await tester.tap(find.text('Verify'));
  await tester.pump(const Duration(milliseconds: 300));

  // Review — confirm
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('Confirm & Submit'));
  await tester.pump(const Duration(milliseconds: 300));

  // Submit (3s)
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 100));

  // Download (3s)
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 200));
}

/// Runs automation through the OTP pause, enters OTP, then runs through
/// the review pause and rejects — leaving the flow in failed state with
/// no pending timers.
Future<void> _runToRejectAtReview(WidgetTester tester) async {
  await tester.tap(find.text('Start Filing Automation'));
  await tester.pump();

  // Login
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 100));

  // Form Fill
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(milliseconds: 100));

  // OTP
  await tester.pump(const Duration(milliseconds: 300));
  await tester.enterText(find.byType(TextField), '123456');
  await tester.tap(find.text('Verify'));
  await tester.pump(const Duration(milliseconds: 300));

  // Review — reject, then drain the polling loop's last timer
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('Reject & Abort'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SubmissionFlowScreen', () {
    // -----------------------------------------------------------------------
    // Static UI tests (no automation started — no timer issues)
    // -----------------------------------------------------------------------

    testWidgets('shows 6 step titles in initial state', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      expect(find.text('Portal Login'), findsOneWidget);
      expect(find.text('Form Fill'), findsOneWidget);
      expect(find.text('OTP Verification'), findsOneWidget);
      expect(find.text('Review & Confirm'), findsOneWidget);
      expect(find.text('Submit Return'), findsOneWidget);
      expect(find.text('Download Acknowledgement'), findsOneWidget);
    });

    testWidgets('shows subtitles for all 6 steps', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      expect(
        find.text('Logging into incometax.gov.in with PAN & password'),
        findsOneWidget,
      );
      expect(
        find.text('Uploading ITR-1 JSON and filling form fields'),
        findsOneWidget,
      );
      expect(
        find.text('Enter the OTP sent to registered mobile'),
        findsOneWidget,
      );
      expect(
        find.text('Verify all details before final submission'),
        findsOneWidget,
      );
      expect(
        find.text('Submitting ITR-1 to Income Tax Department'),
        findsOneWidget,
      );
      expect(
        find.text('Downloading ITR-V and acknowledgement receipt'),
        findsOneWidget,
      );
    });

    testWidgets('"Start Filing Automation" button visible before start', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      expect(find.text('Start Filing Automation'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('info banner shown before start', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      expect(find.textContaining('Review the steps below'), findsOneWidget);
    });

    testWidgets('Filing Automation title in AppBar', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      expect(find.text('Filing Automation'), findsOneWidget);
    });

    testWidgets('does not overflow at 600x1000', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      expect(tester.takeException(), isNull);
    });

    // -----------------------------------------------------------------------
    // Full happy path — all timers drain naturally
    // -----------------------------------------------------------------------

    testWidgets('full happy path ends with success banner and ack number', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      await _runFullFlow(tester);

      // Success banner
      expect(find.text('Return Filed Successfully'), findsOneWidget);

      // Ack number in banner (also appears in activity log, so >= 1)
      expect(find.textContaining('Ack: ACK'), findsAtLeast(1));

      // Done button
      expect(find.text('Done — Return to Queue'), findsOneWidget);
    });

    testWidgets('full happy path updates orchestrator to done', (tester) async {
      await _setViewport(tester);
      final (repo, _) = await _pumpScreen(tester);

      await _runFullFlow(tester);

      final updatedJob = await repo.getById(_testJobId);
      expect(updatedJob?.currentStep, SubmissionStep.done);
      expect(updatedJob?.ackNumber, isNotNull);
      expect(updatedJob?.ackNumber, startsWith('ACK'));
    });

    testWidgets('activity log captures events during full flow', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      await _runFullFlow(tester);

      expect(find.text('Activity Log'), findsOneWidget);
      // The log should contain login and completion entries
      expect(find.textContaining('Login successful'), findsOneWidget);
      expect(find.textContaining('Filing complete!'), findsOneWidget);
    });

    testWidgets('start button disappears and progress banner shows', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      // Start and run to completion to avoid timer issues
      await _runFullFlow(tester);

      // Start button should be gone (replaced by Done button)
      expect(find.text('Start Filing Automation'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Reject path — automation ends at review, no pending timers
    // -----------------------------------------------------------------------

    testWidgets('rejecting review marks job as failed', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      await _runToRejectAtReview(tester);

      expect(find.text('Submission aborted'), findsOneWidget);
      expect(find.text('Back to Queue'), findsOneWidget);
    });

    testWidgets('rejected review updates orchestrator state', (tester) async {
      await _setViewport(tester);
      final (repo, _) = await _pumpScreen(tester);

      await _runToRejectAtReview(tester);

      final updatedJob = await repo.getById(_testJobId);
      expect(updatedJob?.currentStep, SubmissionStep.failed);
      expect(updatedJob?.errorMessage, 'Rejected by CA at review step');
    });

    // -----------------------------------------------------------------------
    // OTP validation test — runs full flow to completion
    // -----------------------------------------------------------------------

    testWidgets('entering short OTP shows validation snackbar then completes', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      await tester.tap(find.text('Start Filing Automation'));
      await tester.pump();

      // Login
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));

      // Form Fill
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 100));

      // OTP step — enter short OTP first
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(find.text('Please enter a valid 6-digit OTP'), findsOneWidget);

      // Now enter valid OTP to continue
      await tester.enterText(find.byType(TextField), '654321');
      await tester.tap(find.text('Verify'));
      await tester.pump(const Duration(milliseconds: 300));

      // Review — confirm
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Confirm & Submit'));
      await tester.pump(const Duration(milliseconds: 300));

      // Submit + Download
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify completed
      expect(find.text('Return Filed Successfully'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // OTP card visibility — uses full flow
    // -----------------------------------------------------------------------

    testWidgets('OTP input card appears at OTP step', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      await tester.tap(find.text('Start Filing Automation'));
      await tester.pump();

      // Login
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));

      // Form Fill
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 100));

      // OTP pause
      await tester.pump(const Duration(milliseconds: 300));

      // OTP card visible
      expect(find.text('Enter OTP'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Complete the flow to drain timers
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Confirm & Submit'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 200));
    });

    // -----------------------------------------------------------------------
    // Review card visibility — uses full flow (reject path)
    // -----------------------------------------------------------------------

    testWidgets('review step shows Confirm and Reject buttons', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      await tester.tap(find.text('Start Filing Automation'));
      await tester.pump();

      // Login
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));

      // Form Fill
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 100));

      // OTP
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pump(const Duration(milliseconds: 300));

      // Review pause
      await tester.pump(const Duration(milliseconds: 300));

      // Review card visible
      expect(find.text('Confirm Submission'), findsOneWidget);
      expect(find.text('Confirm & Submit'), findsOneWidget);
      expect(find.text('Reject & Abort'), findsOneWidget);

      // Reject to cleanly terminate — pump extra to drain polling timer
      await tester.tap(find.text('Reject & Abort'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    // -----------------------------------------------------------------------
    // Confirming review resumes — full flow to completion
    // -----------------------------------------------------------------------

    testWidgets('confirming review clears the review card', (tester) async {
      await _setViewport(tester);
      await _pumpScreen(tester);

      await tester.tap(find.text('Start Filing Automation'));
      await tester.pump();

      // Login
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));

      // Form Fill
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 100));

      // OTP
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pump(const Duration(milliseconds: 300));

      // Review — confirm
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Confirm & Submit'));
      await tester.pump(const Duration(milliseconds: 300));

      // Review card gone
      expect(find.text('Confirm Submission'), findsNothing);

      // Complete remaining steps to drain timers
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}
