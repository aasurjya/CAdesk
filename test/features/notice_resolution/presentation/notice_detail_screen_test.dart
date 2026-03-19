import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/notice_resolution/data/providers/notice_resolution_providers.dart';
import 'package:ca_app/features/notice_resolution/domain/models/notice_case.dart';
import 'package:ca_app/features/notice_resolution/presentation/notice_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

final _pendingNotice = NoticeCase(
  id: 'nc-test-001',
  clientId: 'cl-001',
  clientName: 'Tata Consultancy Services',
  noticeType: NoticeType.scrutiny143_3,
  section: '143(3)',
  receivedDate: DateTime(2026, 1, 15),
  dueDate: DateTime(2026, 4, 20),
  status: NoticeStatus.pendingReview,
  severity: NoticeSeverity.critical,
  amountInDispute: 45000000,
  description: 'Scrutiny assessment for AY 2023-24.',
);

final _closedNotice = NoticeCase(
  id: 'nc-test-002',
  clientId: 'cl-002',
  clientName: 'Infosys BPM Ltd',
  noticeType: NoticeType.intimation143_1,
  section: '143(1)',
  receivedDate: DateTime(2025, 11, 5),
  dueDate: DateTime(2026, 2, 28),
  status: NoticeStatus.closed,
  severity: NoticeSeverity.medium,
  amountInDispute: 1800000,
  description: 'Intimation with demand for AY 2023-24.',
);

final _draftReadyNotice = NoticeCase(
  id: 'nc-test-003',
  clientId: 'cl-003',
  clientName: 'Wipro Technologies',
  noticeType: NoticeType.tdsDefault,
  section: '201(1A)',
  receivedDate: DateTime(2026, 2, 3),
  dueDate: DateTime(2026, 5, 15),
  status: NoticeStatus.draftReady,
  severity: NoticeSeverity.high,
  amountInDispute: 8500000,
  description: 'TDS short deduction demand.',
);

List<dynamic> _overrideWith(List<NoticeCase> notices) {
  return [
    allNoticeCasesProvider.overrideWith(
      () => _FakeNoticeCasesNotifier(notices),
    ),
  ];
}

class _FakeNoticeCasesNotifier extends Notifier<List<NoticeCase>>
    implements AllNoticeCasesNotifier {
  _FakeNoticeCasesNotifier(this._notices);
  final List<NoticeCase> _notices;

  @override
  List<NoticeCase> build() => _notices;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NoticeDetailScreen', () {
    testWidgets('renders without crash for a known notice', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.byType(NoticeDetailScreen), findsOneWidget);
    });

    testWidgets('shows client name in app bar title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.textContaining('Tata Consultancy Services'), findsWidgets);
    });

    testWidgets('shows notice type label in header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Scrutiny u/s 143(3)'), findsWidgets);
    });

    testWidgets('shows Resolution Timeline section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Resolution Timeline'), findsOneWidget);
    });

    testWidgets('shows Response Preparation section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Response Preparation'), findsOneWidget);
    });

    testWidgets('shows AI Response Suggestion card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('AI Response Suggestion'), findsOneWidget);
    });

    testWidgets('shows Generate AI Draft button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Generate AI Draft'), findsOneWidget);
    });

    testWidgets('shows Submit Response and Escalate buttons for open notice', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Submit Response'), findsOneWidget);
      expect(find.text('Escalate'), findsOneWidget);
    });

    testWidgets('shows resolved banner for closed notice', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-002'),
        overrides: _overrideWith([_closedNotice]),
      );
      expect(find.text('This notice has been resolved'), findsOneWidget);
    });

    testWidgets('does not show Submit Response button for closed notice', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-002'),
        overrides: _overrideWith([_closedNotice]),
      );
      expect(find.text('Submit Response'), findsNothing);
    });

    testWidgets('shows not-found state when notice id does not exist', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'non-existent'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Notice not found'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('shows not-found state when provider returns empty list', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([]),
      );
      expect(find.text('Notice not found'), findsOneWidget);
    });

    testWidgets('shows severity badge in header card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Critical'), findsWidgets);
    });

    testWidgets('shows notice info section with client and section fields', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NoticeDetailScreen(noticeId: 'nc-test-001'),
        overrides: _overrideWith([_pendingNotice]),
      );
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Section'), findsOneWidget);
    });
  });
}
