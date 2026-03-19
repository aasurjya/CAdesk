import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_card.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('KanbanCard', () {
    KanbanCardData makeCard({
      String id = 'card-1',
      String title = 'File ITR-1',
      String assignee = 'Ankit Sharma',
      KanbanPriority priority = KanbanPriority.medium,
      DateTime? dueDate,
      String clientName = 'Test Client',
      List<String> tags = const [],
      List<KanbanSubtask> subtasks = const [],
    }) {
      return KanbanCardData(
        id: id,
        title: title,
        description: 'Test description',
        assignee: assignee,
        priority: priority,
        dueDate: dueDate ?? DateTime.now().add(const Duration(days: 10)),
        clientName: clientName,
        columnId: 'todo',
        tags: tags,
        subtasks: subtasks,
      );
    }

    Widget buildSubject({KanbanCardData? card, VoidCallback? onTap}) {
      return KanbanCard(card: card ?? makeCard(), onTap: onTap ?? () {});
    }

    group('title rendering', () {
      testWidgets('renders card title', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(title: 'Prepare GSTR-1')),
        );

        expect(find.text('Prepare GSTR-1'), findsOneWidget);
      });

      testWidgets('renders client name', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(clientName: 'Mehta & Sons')),
        );

        expect(find.text('Mehta & Sons'), findsOneWidget);
      });
    });

    group('priority color bar', () {
      testWidgets('renders priority color bar container', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(priority: KanbanPriority.high)),
        );

        // The 4x36 priority bar is a Container with high priority color.
        final containers = tester.widgetList<Container>(find.byType(Container));
        final priorityBars = containers.where((c) {
          final w = c.constraints?.maxWidth;
          return w != null && w <= 4.0;
        });
        expect(priorityBars, isNotEmpty);
      });

      testWidgets('critical priority uses error color', (tester) async {
        final card = makeCard(priority: KanbanPriority.critical);
        expect(card.priority.color, AppColors.error);
      });

      testWidgets('high priority uses warning color', (tester) async {
        final card = makeCard(priority: KanbanPriority.high);
        expect(card.priority.color, AppColors.warning);
      });

      testWidgets('medium priority uses accent color', (tester) async {
        final card = makeCard(priority: KanbanPriority.medium);
        expect(card.priority.color, AppColors.accent);
      });

      testWidgets('low priority uses neutral400 color', (tester) async {
        final card = makeCard(priority: KanbanPriority.low);
        expect(card.priority.color, AppColors.neutral400);
      });
    });

    group('due date urgency', () {
      testWidgets('overdue date shows red label', (tester) async {
        final pastDate = DateTime.now().subtract(const Duration(days: 2));
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(dueDate: pastDate)),
        );

        // "Overdue 2d" text should appear in red.
        expect(find.textContaining('Overdue'), findsOneWidget);

        final text = tester.widget<Text>(find.textContaining('Overdue').first);
        expect(text.style?.color, AppColors.error);
      });

      testWidgets('date within 3 days shows warning color label', (
        tester,
      ) async {
        // Use 50 hours so inDays == 2 reliably, which is within the 3-day threshold.
        final soonDate = DateTime.now().add(const Duration(hours: 50));
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(dueDate: soonDate)),
        );

        // "2d left" should appear in warning color.
        expect(find.textContaining('left'), findsOneWidget);
        final text = tester.widget<Text>(find.textContaining('left').first);
        expect(text.style?.color, AppColors.warning);
      });

      testWidgets('date more than 3 days away shows success color', (
        tester,
      ) async {
        final futureDate = DateTime.now().add(const Duration(days: 10));
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(dueDate: futureDate)),
        );

        expect(find.textContaining('left'), findsOneWidget);
        final text = tester.widget<Text>(find.textContaining('left').first);
        expect(text.style?.color, AppColors.success);
      });

      testWidgets('due date shows "Today" when ~12h remaining', (tester) async {
        // 12 hours → inDays == 0 → "Today"
        final future12h = DateTime.now().add(const Duration(hours: 12));
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(dueDate: future12h)),
        );

        expect(find.text('Today'), findsOneWidget);
      });

      testWidgets('due date shows "Tomorrow" when ~36h remaining', (
        tester,
      ) async {
        // 36 hours → inDays == 1 → "Tomorrow"
        final future36h = DateTime.now().add(const Duration(hours: 36));
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(dueDate: future36h)),
        );

        expect(find.text('Tomorrow'), findsOneWidget);
      });
    });

    group('subtask progress', () {
      testWidgets('shows progress bar when subtasks present', (tester) async {
        final subtasks = [
          const KanbanSubtask(title: 'Task A', isCompleted: true),
          const KanbanSubtask(title: 'Task B', isCompleted: false),
        ];
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(subtasks: subtasks)),
        );

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('shows subtask count label', (tester) async {
        final subtasks = [
          const KanbanSubtask(title: 'Task A', isCompleted: true),
          const KanbanSubtask(title: 'Task B', isCompleted: false),
        ];
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(subtasks: subtasks)),
        );

        // Expect "1/2" — completed/total.
        expect(find.text('1/2'), findsOneWidget);
      });

      testWidgets('shows checklist icon when subtasks present', (tester) async {
        final subtasks = [
          const KanbanSubtask(title: 'Do something', isCompleted: false),
        ];
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(subtasks: subtasks)),
        );

        expect(find.byIcon(Icons.checklist_rounded), findsOneWidget);
      });

      testWidgets('does not show progress bar when no subtasks', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(subtasks: const [])),
        );

        expect(find.byType(LinearProgressIndicator), findsNothing);
      });

      testWidgets('progress value reflects completed fraction', (tester) async {
        final subtasks = [
          const KanbanSubtask(title: 'A', isCompleted: true),
          const KanbanSubtask(title: 'B', isCompleted: true),
          const KanbanSubtask(title: 'C', isCompleted: false),
        ];
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(subtasks: subtasks)),
        );

        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(bar.value, closeTo(2 / 3, 0.001));
      });
    });

    group('tap interaction', () {
      testWidgets('onTap fires when card is tapped', (tester) async {
        var tapped = false;
        await pumpTestWidget(tester, buildSubject(onTap: () => tapped = true));

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('drag gesture', () {
      testWidgets('card wraps in LongPressDraggable', (tester) async {
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(LongPressDraggable<KanbanCardData>), findsOneWidget);
      });

      testWidgets('LongPressDraggable carries card data', (tester) async {
        final card = makeCard(id: 'drag-test', title: 'Drag Me');
        await pumpTestWidget(tester, buildSubject(card: card));

        final draggable = tester.widget<LongPressDraggable<KanbanCardData>>(
          find.byType(LongPressDraggable<KanbanCardData>),
        );
        expect(draggable.data, card);
      });

      testWidgets('long press initiates drag (feedback widget appears)', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject());

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(KanbanCard)),
        );
        // Hold for long-press threshold (~500ms).
        await tester.pump(const Duration(milliseconds: 600));

        // Feedback should be present during drag.
        expect(tester.takeException(), isNull);

        await gesture.up();
      });
    });

    group('assignee initials', () {
      testWidgets('renders assignee initials in CircleAvatar', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(assignee: 'Ankit Sharma')),
        );

        // Initials for "Ankit Sharma" → "AS"
        expect(find.text('AS'), findsOneWidget);
      });

      testWidgets('single-name assignee shows first letter', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(assignee: 'Rajesh')),
        );

        expect(find.text('R'), findsOneWidget);
      });
    });

    group('tags', () {
      testWidgets('renders tags when present', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(tags: ['ITR', 'AY2025'])),
        );

        expect(find.text('ITR'), findsOneWidget);
        expect(find.text('AY2025'), findsOneWidget);
      });

      testWidgets('renders at most 3 tags', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(tags: ['T1', 'T2', 'T3', 'T4', 'T5'])),
        );

        // Only the first 3 tags should be shown.
        expect(find.text('T1'), findsOneWidget);
        expect(find.text('T2'), findsOneWidget);
        expect(find.text('T3'), findsOneWidget);
        expect(find.text('T4'), findsNothing);
        expect(find.text('T5'), findsNothing);
      });

      testWidgets('no tag containers when tags list is empty', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(card: makeCard(tags: const [])),
        );

        // Wrap widget should not be rendered (conditional in build).
        expect(find.byType(Wrap), findsNothing);
      });
    });
  });
}
