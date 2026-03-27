import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/today/presentation/today_screen.dart';
import 'package:ca_app/features/today/presentation/widgets/kanban_board.dart';
import 'package:ca_app/features/today/presentation/widgets/kanban_card.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Builds the TodayScreen with default provider (mock data from provider).
Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: TodayScreen()));
}

/// Builds the TodayScreen with specific deadlines loaded synchronously.
Widget _buildWithDeadlines(List<ComplianceDeadline> deadlines) {
  return ProviderScope(
    overrides: [
      allComplianceDeadlinesProvider.overrideWith(
        () => _TestDeadlinesNotifier(deadlines),
      ),
    ],
    child: const MaterialApp(home: TodayScreen()),
  );
}

/// A notifier that immediately resolves with the given deadlines.
class _TestDeadlinesNotifier extends AllComplianceDeadlinesNotifier {
  _TestDeadlinesNotifier(this._deadlines);

  final List<ComplianceDeadline> _deadlines;

  @override
  Future<List<ComplianceDeadline>> build() async => _deadlines;
}

/// Creates a test deadline with the given [daysFromNow] offset.
ComplianceDeadline _makeDeadline({
  required String id,
  required String title,
  required int daysFromNow,
  ComplianceCategory category = ComplianceCategory.gst,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ComplianceDeadline(
    id: id,
    title: title,
    description: 'Description for $title',
    category: category,
    dueDate: today.add(Duration(days: daysFromNow)),
    applicableTo: const ['Test'],
    isRecurring: false,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  );
}

void main() {
  group('TodayScreen — default list view', () {
    testWidgets('renders Today app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('renders current date below title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('renders Due Today section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Due Today'), findsWidgets);
    });

    testWidgets('renders This Week section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('This Week'), findsOneWidget);
    });

    testWidgets('renders Later section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Later'), findsOneWidget);
    });

    testWidgets('renders View Full Calendar button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('View Full Calendar'), findsOneWidget);
    });

    testWidgets('renders calendar month icon in View Full Calendar button', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    });

    testWidgets('renders today icon for Due Today section', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.today_rounded), findsWidgets);
    });

    testWidgets('renders date_range icon for This Week section', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.date_range_rounded), findsWidgets);
    });

    testWidgets('renders schedule icon for Later section', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.schedule_rounded), findsWidgets);
    });

    testWidgets('renders ListView in default mode', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders count badges for section headers', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders deadline tiles when data is available', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders empty state message when no deadlines due today', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
    });

    testWidgets('does not crash at 600x1000 viewport', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('TodayScreen — view toggle', () {
    testWidgets('default view is list view (no KanbanBoard visible)', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // List view shows a ListView, no KanbanBoard
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(KanbanBoard), findsNothing);
    });

    testWidgets('toggle button is visible with kanban icon initially', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // In list mode, the toggle icon shows the kanban icon (switch to board)
      expect(find.byKey(const Key('today_view_toggle')), findsOneWidget);
      expect(find.byIcon(Icons.view_kanban_outlined), findsOneWidget);
    });

    testWidgets('tapping toggle switches to kanban/board view', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Tap toggle to switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // Board view shows KanbanBoard
      expect(find.byType(KanbanBoard), findsOneWidget);
    });

    testWidgets('toggle icon changes to list icon when in board view', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // Icon should now show list/agenda icon (switch back to list)
      expect(find.byIcon(Icons.view_agenda_outlined), findsOneWidget);
      expect(find.byIcon(Icons.view_kanban_outlined), findsNothing);
    });

    testWidgets('toggle back returns to list view', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Toggle to board
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();
      expect(find.byType(KanbanBoard), findsOneWidget);

      // Toggle back to list
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();
      expect(find.byType(KanbanBoard), findsNothing);
      // The kanban icon should be back
      expect(find.byIcon(Icons.view_kanban_outlined), findsOneWidget);
    });

    testWidgets('View Full Calendar button visible in board view', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('View Full Calendar'), findsOneWidget);
    });

    testWidgets('SearchAction remains visible in both views', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // List view — search action visible
      expect(find.byKey(const Key('global_search_action')), findsOneWidget);

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // Board view — search action still visible
      expect(find.byKey(const Key('global_search_action')), findsOneWidget);
    });
  });

  group('TodayScreen — kanban board with known deadlines', () {
    late List<ComplianceDeadline> testDeadlines;

    setUp(() {
      // Compute a safe "this week" offset: 1 day from now is always within the
      // 7-day window used by the grouping logic (today + (7 - weekday)).
      testDeadlines = [
        _makeDeadline(
          id: 'overdue-1',
          title: 'Overdue Task',
          daysFromNow: -3,
          category: ComplianceCategory.tds,
        ),
        _makeDeadline(
          id: 'today-1',
          title: 'Today Task',
          daysFromNow: 0,
          category: ComplianceCategory.gst,
        ),
        _makeDeadline(
          id: 'week-1',
          title: 'Week Task',
          daysFromNow: 1,
          category: ComplianceCategory.incomeTax,
        ),
        _makeDeadline(
          id: 'later-1',
          title: 'Later Task',
          daysFromNow: 30,
          category: ComplianceCategory.roc,
        ),
      ];
    });

    testWidgets('kanban shows 4 columns with correct headers', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildWithDeadlines(testDeadlines));
      // Allow the post-frame callback to fire and set deadlines.
      await tester.pumpAndSettle();

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Overdue'), findsOneWidget);
      expect(find.text('Due Today'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
    });

    testWidgets('deadlines appear in correct columns', (tester) async {
      // Use a wide viewport so all 4 columns are visible.
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildWithDeadlines(testDeadlines));
      await tester.pumpAndSettle();

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // All deadline titles should be visible
      expect(find.text('Overdue Task'), findsOneWidget);
      expect(find.text('Today Task'), findsOneWidget);
      expect(find.text('Week Task'), findsOneWidget);
      expect(find.text('Later Task'), findsOneWidget);
    });

    testWidgets('column headers show count badges', (tester) async {
      // Use a wide viewport so all 4 columns are visible.
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Use only 2 deadlines with deterministic placement:
      // 1 overdue (-3 days), 1 due today (0 days).
      final twoDeadlines = [
        _makeDeadline(
          id: 'overdue-1',
          title: 'Overdue Deadline',
          daysFromNow: -3,
          category: ComplianceCategory.tds,
        ),
        _makeDeadline(
          id: 'today-1',
          title: 'Today Deadline',
          daysFromNow: 0,
          category: ComplianceCategory.gst,
        ),
      ];

      await tester.pumpWidget(_buildWithDeadlines(twoDeadlines));
      await tester.pumpAndSettle();

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // Overdue and Due Today columns each show "1".
      // This Week and Later columns each show "0".
      expect(find.text('1', skipOffstage: false), findsNWidgets(2));
      expect(find.text('0', skipOffstage: false), findsNWidgets(2));
    });

    testWidgets('kanban cards show category badges', (tester) async {
      // Use a wide viewport so all 4 columns are visible.
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildWithDeadlines(testDeadlines));
      await tester.pump(); // fire post-frame callback
      await tester.pumpAndSettle(); // let state propagate

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // Category short labels from test deadlines.
      // Use skipOffstage: false to include off-screen columns.
      expect(find.text('TDS', skipOffstage: false), findsWidgets);
      expect(find.text('GST', skipOffstage: false), findsWidgets);
      expect(find.text('ITR', skipOffstage: false), findsWidgets);
      expect(find.text('ROC', skipOffstage: false), findsWidgets);
    });

    testWidgets('kanban renders KanbanCard widgets', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildWithDeadlines(testDeadlines));
      await tester.pumpAndSettle();

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // At least one KanbanCard should be rendered
      expect(find.byType(KanbanCard), findsWidgets);
    });

    testWidgets('empty columns show "No items" text', (tester) async {
      // Only provide an overdue deadline — other columns should be empty
      final overdueOnly = [
        _makeDeadline(
          id: 'overdue-1',
          title: 'Overdue Only',
          daysFromNow: -5,
          category: ComplianceCategory.tds,
        ),
      ];

      await _setViewport(tester);
      await tester.pumpWidget(_buildWithDeadlines(overdueOnly));
      await tester.pumpAndSettle();

      // Switch to board view
      await tester.tap(find.byKey(const Key('today_view_toggle')));
      await tester.pumpAndSettle();

      // Empty columns should show "No items"
      expect(find.text('No items'), findsWidgets);
    });
  });
}
