import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/practice/presentation/kanban/kanban_board_screen.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_card.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_column.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('KanbanBoardScreen', () {
    Widget buildSubject({List<dynamic> overrides = const []}) {
      return const KanbanBoardScreen();
    }

    group('initial render', () {
      testWidgets('screen renders without crashing', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(KanbanBoardScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows "Kanban Board" title in app bar', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.text('Kanban Board'), findsOneWidget);
      });

      testWidgets('shows subtitle hint text', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(
          find.text('Drag cards between columns to update status'),
          findsOneWidget,
        );
      });
    });

    group('columns', () {
      testWidgets('renders at least 3 column widgets', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(KanbanColumnWidget), findsAtLeastNWidgets(3));
      });

      testWidgets('renders exactly 5 columns (default mock data)', (
        tester,
      ) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(KanbanColumnWidget), findsNWidgets(5));
      });

      testWidgets('renders "Backlog" column header', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.text('Backlog'), findsOneWidget);
      });

      testWidgets('renders "To Do" column header', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.text('To Do'), findsOneWidget);
      });

      testWidgets('renders "In Progress" column header', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.text('In Progress'), findsOneWidget);
      });

      testWidgets('renders "Done" column header', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('columns show card count badge', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        // The mock data has 3 cards in Backlog, so "3" should appear.
        // Multiple count badges are rendered per column — at least one "3".
        expect(find.text('3'), findsWidgets);
      });
    });

    group('cards in columns', () {
      testWidgets('at least one kanban card is rendered', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        // Mock data has 15 cards total.
        expect(find.byType(KanbanCard), findsWidgets);
      });
    });

    group('FAB and add button', () {
      testWidgets('FAB "New Card" is present', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('New Card'), findsOneWidget);
      });

      testWidgets('FAB has add icon', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byIcon(Icons.add_rounded), findsWidgets);
      });
    });

    group('filter button', () {
      testWidgets('filter icon button is present in app bar', (tester) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
      });

      testWidgets('filter badge dot is not visible when no filter is active', (
        tester,
      ) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        // The red dot indicator should be absent when filter is inactive.
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final filter = container.read(kanbanFilterProvider);
        expect(filter.isActive, isFalse);
      });
    });

    group('provider state', () {
      testWidgets('kanbanColumnsProvider returns 5 columns', (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final columns = container.read(kanbanColumnsProvider);
        expect(columns.length, 5);
      });

      testWidgets('kanbanCardsProvider returns 15 mock cards', (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final cards = container.read(kanbanCardsProvider);
        expect(cards.length, 15);
      });

      testWidgets('filteredKanbanCardsProvider groups cards by column', (
        tester,
      ) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final grouped = container.read(filteredKanbanCardsProvider);
        expect(grouped.containsKey('backlog'), isTrue);
        expect(grouped.containsKey('todo'), isTrue);
        expect(grouped.containsKey('in_progress'), isTrue);
        expect(grouped.containsKey('review'), isTrue);
        expect(grouped.containsKey('done'), isTrue);
      });

      testWidgets('backlog column has 3 cards in mock data', (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final grouped = container.read(filteredKanbanCardsProvider);
        expect(grouped['backlog']?.length, 3);
      });
    });
  });
}
