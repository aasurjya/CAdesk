import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/compliance/presentation/compliance_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Shared test fixtures
// ---------------------------------------------------------------------------

final _upcomingDeadline = ComplianceDeadline(
  id: 'test-cd-001',
  title: 'TDS/TCS Payment',
  description: 'Payment of TDS/TCS deducted in the previous month.',
  category: ComplianceCategory.tds,
  dueDate: DateTime.now().add(const Duration(days: 30)),
  applicableTo: ['All Deductors'],
  isRecurring: true,
  frequency: ComplianceFrequency.monthly,
  status: ComplianceStatus.upcoming,
);

final _completedDeadline = ComplianceDeadline(
  id: 'test-cd-002',
  title: 'GST-3B Return',
  description: 'Monthly GSTR-3B summary return.',
  category: ComplianceCategory.gst,
  dueDate: DateTime.now().subtract(const Duration(days: 5)),
  applicableTo: ['Regular Taxpayers'],
  isRecurring: true,
  frequency: ComplianceFrequency.monthly,
  status: ComplianceStatus.completed,
);

final _overdueDeadline = ComplianceDeadline(
  id: 'test-cd-003',
  title: 'ITR Filing Deadline',
  description: 'Annual income tax return filing.',
  category: ComplianceCategory.incomeTax,
  dueDate: DateTime.now().subtract(const Duration(days: 10)),
  applicableTo: ['Individuals', 'HUFs'],
  isRecurring: true,
  frequency: ComplianceFrequency.annual,
  status: ComplianceStatus.upcoming,
);

// A related deadline in the same TDS category (different id).
final _relatedDeadline = ComplianceDeadline(
  id: 'test-cd-004',
  title: 'TDS Return Q4',
  description: 'Quarterly TDS return.',
  category: ComplianceCategory.tds,
  dueDate: DateTime.now().add(const Duration(days: 60)),
  applicableTo: ['All Deductors'],
  isRecurring: true,
  frequency: ComplianceFrequency.quarterly,
  status: ComplianceStatus.upcoming,
);

List<dynamic> _overrideWith(List<ComplianceDeadline> deadlines) {
  return [
    allComplianceDeadlinesProvider.overrideWith(
      () => _FakeDeadlinesNotifier(deadlines),
    ),
  ];
}

class _FakeDeadlinesNotifier extends AsyncNotifier<List<ComplianceDeadline>>
    implements AllComplianceDeadlinesNotifier {
  _FakeDeadlinesNotifier(this._deadlines);
  final List<ComplianceDeadline> _deadlines;

  @override
  Future<List<ComplianceDeadline>> build() async => _deadlines;

  @override
  Future<void> refresh() async {}

  @override
  void setDeadlines(List<ComplianceDeadline> value) {
    state = AsyncData(value);
  }

  @override
  void addDeadline(ComplianceDeadline deadline) {
    state = AsyncData([..._deadlines, deadline]);
  }

  @override
  void markCompleted(ComplianceDeadline deadline) {
    state = AsyncData(
      _deadlines
          .map(
            (d) => d.id == deadline.id
                ? d.copyWith(status: ComplianceStatus.completed)
                : d,
          )
          .toList(),
    );
  }

  @override
  void deleteDeadline(String deadlineId) {
    state = AsyncData(_deadlines.where((d) => d.id != deadlineId).toList());
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ComplianceDetailScreen', () {
    testWidgets('renders without crash for a known deadline', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.byType(ComplianceDetailScreen), findsOneWidget);
    });

    testWidgets('shows category label in app bar for known deadline', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      // Category label for TDS appears in the AppBar title.
      expect(find.text('TDS'), findsWidgets);
    });

    testWidgets('shows deadline title in header card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.text('TDS/TCS Payment'), findsWidgets);
    });

    testWidgets('shows Applicable To section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.text('Applicable To'), findsOneWidget);
      expect(find.text('All Deductors'), findsWidgets);
    });

    testWidgets('shows Timeline section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Deadline Created'), findsOneWidget);
    });

    testWidgets('shows Mark as Completed button for upcoming deadline', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.text('Mark as Completed'), findsOneWidget);
    });

    testWidgets('shows Set Reminder button for upcoming deadline', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.text('Set Reminder'), findsOneWidget);
    });

    testWidgets('shows completed status banner for completed deadline', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-002'),
        overrides: _overrideWith([_completedDeadline]),
      );
      expect(find.text('This deadline has been completed'), findsOneWidget);
    });

    testWidgets('shows not-found state when deadline id does not exist', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'non-existent-id'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.text('Deadline not found'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('shows overdue chip for an overdue deadline', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-003'),
        overrides: _overrideWith([_overdueDeadline]),
      );
      // The header shows "X days overdue".
      expect(find.textContaining('days overdue'), findsOneWidget);
    });

    testWidgets('shows related deadlines when same-category items exist', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline, _relatedDeadline]),
      );
      expect(find.textContaining('Related'), findsOneWidget);
      expect(find.text('TDS Return Q4'), findsWidgets);
    });

    testWidgets('shows Frequency and Due Date in date info card', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([_upcomingDeadline]),
      );
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Due Date'), findsWidgets);
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('shows Deadline not found when provider returns empty list', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        const ComplianceDetailScreen(deadlineId: 'test-cd-001'),
        overrides: _overrideWith([]),
      );
      expect(find.text('Deadline not found'), findsOneWidget);
    });
  });
}
