import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/data/repositories/mock_submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/autosubmit_queue_screen.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Tracks the last route pushed via GoRouter for test assertions.
String? _lastPushedRoute;
Object? _lastPushedExtra;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SubmissionJob _createJob({
  required String id,
  String clientName = 'Ramesh Kumar',
  SubmissionStep step = SubmissionStep.pending,
  String returnType = 'ITR-1',
  String? errorMessage,
  int retryCount = 0,
}) {
  return SubmissionJob(
    id: id,
    clientId: 'client-$id',
    clientName: clientName,
    portalType: PortalType.itd,
    returnType: returnType,
    currentStep: step,
    retryCount: retryCount,
    createdAt: DateTime(2026, 3, 15),
    errorMessage: errorMessage,
  );
}

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<MockSubmissionRepository> _pumpQueue(
  WidgetTester tester, {
  List<SubmissionJob> jobs = const [],
}) async {
  final repo = MockSubmissionRepository();
  final orchestrator = SubmissionOrchestrator(repository: repo);

  for (final job in jobs) {
    await repo.insert(job);
  }

  _lastPushedRoute = null;
  _lastPushedExtra = null;

  final router = GoRouter(
    initialLocation: '/portal-autosubmit',
    routes: [
      GoRoute(
        path: '/portal-autosubmit',
        builder: (context, state) => const AutosubmitQueueScreen(),
      ),
      GoRoute(
        path: '/portal-autosubmit/review/:jobId',
        builder: (context, state) {
          _lastPushedRoute = state.uri.toString();
          _lastPushedExtra = state.extra;
          return const Scaffold(body: Text('Review Screen'));
        },
      ),
      GoRoute(
        path: '/portal-autosubmit/flow/:jobId',
        builder: (context, state) {
          _lastPushedRoute = state.uri.toString();
          return const Scaffold(body: Text('Flow Screen'));
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        submissionRepositoryProvider.overrideWithValue(repo),
        submissionOrchestratorProvider.overrideWithValue(orchestrator),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();

  return repo;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    _lastPushedRoute = null;
    _lastPushedExtra = null;
  });

  group('AutosubmitQueueScreen', () {
    testWidgets('shows title and subtitle', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(tester);

      expect(find.text('Auto-Submit Queue'), findsOneWidget);
      expect(find.text('Pending portal submissions'), findsOneWidget);
    });

    testWidgets('shows empty state when no jobs', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(tester);

      expect(find.text('No submissions match the filter'), findsOneWidget);
    });

    testWidgets('shows stat cards with correct counts', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [
          _createJob(id: '1', step: SubmissionStep.pending),
          _createJob(
            id: '2',
            clientName: 'Suresh Patel',
            step: SubmissionStep.loggingIn,
          ),
          _createJob(
            id: '3',
            clientName: 'Priya Sharma',
            step: SubmissionStep.done,
          ),
          _createJob(
            id: '4',
            clientName: 'Amit Singh',
            step: SubmissionStep.failed,
            errorMessage: 'Login failed',
            retryCount: 1,
          ),
        ],
      );

      // The stat cards show counts as text
      // Pending: 1, In Progress: 1, Done: 1, Failed: 1
      expect(find.text('Pending'), findsWidgets); // label + chip
      expect(find.text('In Progress'), findsWidgets);
      expect(find.text('Done'), findsWidgets);
      expect(find.text('Failed'), findsWidgets);
    });

    testWidgets('displays job card with client name and return type', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [_createJob(id: '1', clientName: 'Ramesh Kumar')],
      );

      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('Income Tax Department / ITR-1'), findsOneWidget);
    });

    testWidgets('displays error message on failed job', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [
          _createJob(
            id: '1',
            step: SubmissionStep.failed,
            errorMessage: 'CAPTCHA failed',
            retryCount: 1,
          ),
        ],
      );

      expect(find.text('CAPTCHA failed'), findsOneWidget);
    });

    testWidgets('shows Retry button on failed job with retryCount < 3', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [
          _createJob(
            id: '1',
            step: SubmissionStep.failed,
            errorMessage: 'Timeout',
            retryCount: 1,
          ),
        ],
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('does not show Retry when retryCount >= 3', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [
          _createJob(
            id: '1',
            step: SubmissionStep.failed,
            errorMessage: 'Max retries',
            retryCount: 3,
          ),
        ],
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('tapping pending job navigates to review screen', (
      tester,
    ) async {
      await _setViewport(tester);

      await _pumpQueue(
        tester,
        jobs: [_createJob(id: 'job-123', clientName: 'Ramesh Kumar')],
      );

      await tester.tap(find.text('Ramesh Kumar'));
      await tester.pumpAndSettle();

      expect(_lastPushedRoute, '/portal-autosubmit/review/job-123');
      expect(_lastPushedExtra, isA<SubmissionJob>());
    });

    testWidgets('tapping non-pending job does not navigate', (tester) async {
      await _setViewport(tester);

      await _pumpQueue(
        tester,
        jobs: [
          _createJob(
            id: 'job-456',
            clientName: 'Priya Done',
            step: SubmissionStep.done,
          ),
        ],
      );

      await tester.tap(find.text('Priya Done'));
      await tester.pumpAndSettle();

      expect(_lastPushedRoute, isNull);
    });

    testWidgets('filter chips are displayed', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(tester, jobs: [_createJob(id: '1')]);

      expect(find.byType(FilterChip), findsNWidgets(4));
    });

    testWidgets('tapping filter chip filters the list', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [
          _createJob(id: '1', clientName: 'Pending Client'),
          _createJob(
            id: '2',
            clientName: 'Done Client',
            step: SubmissionStep.done,
          ),
        ],
      );

      // Both visible initially
      expect(find.text('Pending Client'), findsOneWidget);
      expect(find.text('Done Client'), findsOneWidget);

      // Tap "Done" filter
      await tester.tap(find.widgetWithText(FilterChip, 'Done'));
      await tester.pump();

      // Only done job visible
      expect(find.text('Pending Client'), findsNothing);
      expect(find.text('Done Client'), findsOneWidget);
    });

    testWidgets('tapping same filter again removes it (shows all)', (
      tester,
    ) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [
          _createJob(id: '1', clientName: 'Pending Client'),
          _createJob(
            id: '2',
            clientName: 'Done Client',
            step: SubmissionStep.done,
          ),
        ],
      );

      // Tap "Done" filter
      await tester.tap(find.widgetWithText(FilterChip, 'Done'));
      await tester.pump();
      expect(find.text('Pending Client'), findsNothing);

      // Tap "Done" again to deselect
      await tester.tap(find.widgetWithText(FilterChip, 'Done'));
      await tester.pump();

      // Both visible again
      expect(find.text('Pending Client'), findsOneWidget);
      expect(find.text('Done Client'), findsOneWidget);
    });

    testWidgets('queue updates when new job is inserted', (tester) async {
      await _setViewport(tester);
      final repo = await _pumpQueue(
        tester,
        jobs: [_createJob(id: '1', clientName: 'First Client')],
      );

      expect(find.text('First Client'), findsOneWidget);
      expect(find.text('Second Client'), findsNothing);

      // Insert a new job
      await repo.insert(_createJob(id: '2', clientName: 'Second Client'));
      await tester.pump();

      expect(find.text('First Client'), findsOneWidget);
      expect(find.text('Second Client'), findsOneWidget);
    });

    testWidgets('does not overflow at 600x1000', (tester) async {
      await _setViewport(tester);
      await _pumpQueue(
        tester,
        jobs: [
          _createJob(id: '1'),
          _createJob(id: '2', clientName: 'Second'),
        ],
      );

      expect(tester.takeException(), isNull);
    });
  });
}
