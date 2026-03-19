import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/pre_fill_review_screen.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

SubmissionJob _makeJob({
  String id = 'job-1',
  String clientId = 'client-1',
  String clientName = 'Rajesh Kumar',
  PortalType portalType = PortalType.itd,
  String returnType = 'ITR-1',
  SubmissionStep step = SubmissionStep.pending,
}) {
  return SubmissionJob(
    id: id,
    clientId: clientId,
    clientName: clientName,
    portalType: portalType,
    returnType: returnType,
    currentStep: step,
    retryCount: 0,
    createdAt: DateTime(2026, 3, 17),
  );
}

PortalCredential _makeCredential({
  PortalType portalType = PortalType.itd,
  String username = 'itd_user@example.com',
}) {
  return PortalCredential(
    id: 'cred-1',
    portalType: portalType,
    username: username,
    status: 'connected',
  );
}

Widget _buildScreen({
  required SubmissionJob job,
  PortalCredential? credential,
  bool credentialError = false,
}) {
  return ProviderScope(
    overrides: [
      credentialForPortalProvider(job.portalType).overrideWith((ref) {
        if (credentialError) throw Exception('DB error');
        return Future.value(credential);
      }),
    ],
    child: MaterialApp(home: PreFillReviewScreen(job: job)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PreFillReviewScreen', () {
    testWidgets('renders client name from job', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(clientName: 'Priya Sharma');
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Priya Sharma'), findsOneWidget);
    });

    testWidgets('renders client ID from job', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(clientId: 'CL-42');
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('CL-42'), findsOneWidget);
    });

    testWidgets('renders correct portal type', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(portalType: PortalType.gstn);
      final credential = _makeCredential(portalType: PortalType.gstn);

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('GST Network'), findsOneWidget);
    });

    testWidgets('renders return type from job', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(returnType: 'GSTR-3B');
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('GSTR-3B'), findsOneWidget);
    });

    testWidgets('renders "Review Before Filing" title', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Review Before Filing'), findsOneWidget);
    });

    testWidgets('shows Start Filing button', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Start Filing'), findsOneWidget);
    });

    testWidgets('shows credential found when credential exists', (
      tester,
    ) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential(username: 'test@itd.gov.in');

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.textContaining('Credentials found'), findsOneWidget);
      expect(find.textContaining('test@itd.gov.in'), findsOneWidget);
    });

    testWidgets('shows no credentials when credential is null', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();

      await tester.pumpWidget(_buildScreen(job: job, credential: null));
      await tester.pumpAndSettle();

      expect(find.textContaining('No credentials stored'), findsOneWidget);
    });

    testWidgets('Start Filing button is disabled when no credential', (
      tester,
    ) async {
      await _setViewport(tester);
      final job = _makeJob();

      await tester.pumpWidget(_buildScreen(job: job, credential: null));
      await tester.pumpAndSettle();

      // The "Start Filing" text should be visible
      expect(find.text('Start Filing'), findsOneWidget);

      // Find the ElevatedButton/FilledButton — FilledButton.icon creates
      // a ButtonStyleButton subtree. Use the specific subtype.
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is ButtonStyleButton && widget.onPressed == null,
      );
      expect(
        buttonFinder,
        findsOneWidget,
        reason: 'Button should be disabled when no credential',
      );
    });

    testWidgets('Start Filing button is enabled when credential exists', (
      tester,
    ) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      // The "Start Filing" text should be visible
      expect(find.text('Start Filing'), findsOneWidget);

      // Find the enabled button
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is ButtonStyleButton && widget.onPressed != null,
      );
      expect(
        buttonFinder,
        findsOneWidget,
        reason: 'Button should be enabled when credential exists',
      );
    });

    testWidgets('renders Client Details section header', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Client Details'), findsOneWidget);
    });

    testWidgets('renders Portal Information section header', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Portal Information'), findsOneWidget);
    });

    testWidgets('renders Credential Check section header', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Credential Check'), findsOneWidget);
    });

    testWidgets('renders current step label', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(step: SubmissionStep.pending);
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows check_circle icon when credential found', (
      tester,
    ) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows cancel icon when no credential', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();

      await tester.pumpWidget(_buildScreen(job: job, credential: null));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });

    testWidgets('renders ITD portal type', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(portalType: PortalType.itd);
      final credential = _makeCredential(portalType: PortalType.itd);

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Income Tax Department'), findsOneWidget);
    });

    testWidgets('renders GSTN portal type', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(portalType: PortalType.gstn);
      final credential = _makeCredential(portalType: PortalType.gstn);

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('GST Network'), findsOneWidget);
    });

    testWidgets('renders TRACES portal type', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(portalType: PortalType.traces);
      final credential = _makeCredential(portalType: PortalType.traces);

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('TRACES'), findsOneWidget);
    });

    testWidgets('renders MCA portal type', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(portalType: PortalType.mca);
      final credential = _makeCredential(portalType: PortalType.mca);

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('Ministry of Corporate Affairs'), findsOneWidget);
    });

    testWidgets('renders EPFO portal type', (tester) async {
      await _setViewport(tester);
      final job = _makeJob(portalType: PortalType.epfo);
      final credential = _makeCredential(portalType: PortalType.epfo);

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.text('EPFO'), findsOneWidget);
    });

    testWidgets('screen does not overflow at 600x1000', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Scaffold and AppBar', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();
      final credential = _makeCredential();

      await tester.pumpWidget(_buildScreen(job: job, credential: credential));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('handles credential loading error gracefully', (tester) async {
      await _setViewport(tester);
      final job = _makeJob();

      await tester.pumpWidget(_buildScreen(job: job, credentialError: true));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error loading credentials'), findsOneWidget);
    });
  });
}
