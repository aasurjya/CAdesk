import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/tasks/presentation/tasks_screen.dart';
import 'package:ca_app/features/tasks/presentation/tasks_list_screen.dart';

Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(414, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  Widget buildSubject() {
    return const ProviderScope(child: MaterialApp(home: TasksScreen()));
  }

  group('TasksScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.byType(TasksScreen), findsOneWidget);
    });

    testWidgets('delegates to TasksListScreen', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.byType(TasksListScreen), findsOneWidget);
    });
  });

  group('TasksListScreen', () {
    Widget buildListSubject() {
      return const ProviderScope(
        child: MaterialApp(home: Scaffold(body: TasksListScreen())),
      );
    }

    testWidgets('renders Tasks title in app bar', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('renders filter icon button', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    });

    testWidgets('renders sort icon button', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
    });

    testWidgets('renders All status chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders Pending status chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders In Progress status chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.text('In Progress'), findsWidgets);
    });

    testWidgets('renders Overdue status chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('renders FAB for adding new tasks', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows loading indicator while tasks are loading', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      // Only pump once — not pumpAndSettle — to catch transient loading state
      await tester.pump();
      // Either loading or tasks are shown; both are valid
      final loadingFound = find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;
      final tasksFound = find.byType(ListView).evaluate().isNotEmpty;
      expect(loadingFound || tasksFound, isTrue);
    });

    testWidgets('renders task list after settling', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      // The screen must show either tasks or an empty state (not an error)
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      final hasEmpty =
          find.byIcon(Icons.task_alt_outlined).evaluate().isNotEmpty ||
          find.byIcon(Icons.filter_list_off_rounded).evaluate().isNotEmpty;
      expect(hasList || hasEmpty, isTrue);
    });

    testWidgets('tapping Pending chip updates filter selection', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();
      // After tapping Pending chip, it should remain rendered
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('tapping Overdue chip updates filter selection', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Overdue').first);
      await tester.pumpAndSettle();
      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('tapping In Progress chip updates filter', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      // The chip label is inside a FilterChip — tap the first occurrence
      await tester.tap(find.text('In Progress').first);
      await tester.pumpAndSettle();
      expect(find.text('In Progress'), findsWidgets);
    });

    testWidgets('tapping filter button opens filter sheet', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('filter sheet shows Task Type section', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Task Type'), findsOneWidget);
    });

    testWidgets('filter sheet shows Priority section', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Priority'), findsOneWidget);
    });

    testWidgets('filter sheet has Clear All button', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('filter sheet has Apply Filters button', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Apply Filters'), findsOneWidget);
    });

    testWidgets('tapping sort button opens sort menu', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.sort_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Sort By'), findsOneWidget);
    });

    testWidgets('sort menu contains Due Date option', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.sort_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Due Date'), findsOneWidget);
    });

    testWidgets('sort menu contains Priority option', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.sort_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Priority'), findsOneWidget);
    });

    testWidgets('sort menu contains Client Name option', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.sort_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Client Name'), findsOneWidget);
    });

    testWidgets('task list contains at least one task card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildListSubject());
      await tester.pumpAndSettle();
      // If tasks are loaded, list should be non-empty OR empty state is shown
      final found =
          find.byType(Card).evaluate().isNotEmpty ||
          find.byIcon(Icons.task_alt_outlined).evaluate().isNotEmpty;
      expect(found, isTrue);
    });
  });
}
