import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_column.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  KanbanColumn makeColumn({
    String id = 'todo',
    String title = 'To Do',
    int order = 1,
    Color color = AppColors.primary,
  }) {
    return KanbanColumn(id: id, title: title, order: order, color: color);
  }

  KanbanCardData makeCard({
    String id = 'card-1',
    String title = 'File GSTR-1',
    String columnId = 'todo',
  }) {
    return KanbanCardData(
      id: id,
      title: title,
      description: 'desc',
      assignee: 'Ankit',
      priority: KanbanPriority.medium,
      dueDate: DateTime(2026, 6, 15),
      clientName: 'Test Corp',
      columnId: columnId,
      tags: const [],
      subtasks: const [],
    );
  }

  Widget buildSubject({
    KanbanColumn? column,
    List<KanbanCardData> cards = const [],
    void Function(KanbanCardData)? onCardDropped,
    void Function(KanbanCardData)? onCardTap,
    VoidCallback? onAddCard,
  }) {
    return SizedBox(
      height: 600,
      child: KanbanColumnWidget(
        column: column ?? makeColumn(),
        cards: cards,
        onCardDropped: onCardDropped ?? (_) {},
        onCardTap: onCardTap ?? (_) {},
        onAddCard: onAddCard ?? () {},
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('KanbanColumnWidget', () {
    group('column header', () {
      testWidgets(
          'test_KanbanColumnWidget_withTitle_rendersColumnTitle',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(
          tester,
          buildSubject(column: makeColumn(title: 'In Progress')),
        );

        expect(find.text('In Progress'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanColumnWidget_withZeroCards_rendersZeroCount',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(tester, buildSubject(cards: const []));

        expect(find.text('0'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanColumnWidget_withThreeCards_rendersThreeCount',
          (tester) async {
        await setTestViewport(tester);
        final cards = [
          makeCard(id: 'c1'),
          makeCard(id: 'c2'),
          makeCard(id: 'c3'),
        ];
        await pumpTestWidget(tester, buildSubject(cards: cards));

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanColumnWidget_always_rendersAddButton',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byTooltip('Add card'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanColumnWidget_tapAddButton_invokesOnAddCard',
          (tester) async {
        await setTestViewport(tester);
        var addCalled = false;
        await pumpTestWidget(
          tester,
          buildSubject(onAddCard: () => addCalled = true),
        );

        await tester.tap(find.byTooltip('Add card'));
        await tester.pump();

        expect(addCalled, isTrue);
      });
    });

    group('empty state', () {
      testWidgets(
          'test_KanbanColumnWidget_withNoCards_rendersNoCardsHint',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(tester, buildSubject(cards: const []));

        expect(find.text('No cards'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanColumnWidget_withNoCards_rendersDragIndicatorIcon',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(tester, buildSubject(cards: const []));

        expect(find.byIcon(Icons.drag_indicator_rounded), findsOneWidget);
      });
    });

    group('card list', () {
      testWidgets(
          'test_KanbanColumnWidget_withCards_rendersCardTitles',
          (tester) async {
        await setTestViewport(tester);
        final cards = [
          makeCard(id: 'c1', title: 'First Task'),
          makeCard(id: 'c2', title: 'Second Task'),
        ];
        await pumpTestWidget(tester, buildSubject(cards: cards));

        expect(find.text('First Task'), findsOneWidget);
        expect(find.text('Second Task'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanColumnWidget_tapCard_invokesOnCardTap',
          (tester) async {
        await setTestViewport(tester);
        KanbanCardData? tappedCard;
        final card = makeCard(id: 'tap-card', title: 'Tap Me');

        await pumpTestWidget(
          tester,
          buildSubject(
            cards: [card],
            onCardTap: (c) => tappedCard = c,
          ),
        );

        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        expect(tappedCard, card);
      });
    });

    group('drag target', () {
      testWidgets(
          'test_KanbanColumnWidget_always_wrapsDragTarget',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(DragTarget<KanbanCardData>), findsOneWidget);
      });

      testWidgets(
          'test_KanbanColumnWidget_always_rendersAnimatedContainer',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(AnimatedContainer), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets(
          'test_KanbanColumnWidget_always_rendersColumnDivider',
          (tester) async {
        await setTestViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(Divider), findsOneWidget);
      });
    });
  });
}
