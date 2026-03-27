import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_card_detail_sheet.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Test data helpers
  // ---------------------------------------------------------------------------

  KanbanCardData makeCard({
    String id = 'card-1',
    String title = 'Prepare GSTR-3B',
    String description = 'Monthly GST filing',
    String assignee = 'Ankit Sharma',
    KanbanPriority priority = KanbanPriority.medium,
    DateTime? dueDate,
    String clientName = 'Mehta & Sons',
    String columnId = 'todo',
    List<KanbanSubtask> subtasks = const [],
    double hoursLogged = 2.5,
  }) {
    return KanbanCardData(
      id: id,
      title: title,
      description: description,
      assignee: assignee,
      priority: priority,
      dueDate: dueDate ?? DateTime(2026, 6, 15),
      clientName: clientName,
      columnId: columnId,
      tags: const [],
      subtasks: subtasks,
      hoursLogged: hoursLogged,
    );
  }

  // Provider overrides that give clean, duplicate-free test data.
  // The DropdownButton for assignees and columns requires unique items.
  List<dynamic> testOverrides(KanbanCardData card) => [
        kanbanColumnsProvider.overrideWithValue([
          const KanbanColumn(
            id: 'todo',
            title: 'To Do',
            order: 0,
            color: AppColors.primary,
          ),
          const KanbanColumn(
            id: 'done',
            title: 'Done',
            order: 1,
            color: AppColors.success,
          ),
        ]),
        kanbanAssigneesProvider.overrideWithValue([
          card.assignee,
        ]),
        kanbanCardsProvider.overrideWith(KanbanCardsNotifier.new),
      ];

  /// Pumps a [ConsumerWidget] host that opens [showKanbanCardDetailSheet]
  /// on a button tap, with clean provider overrides.
  ///
  /// Uses a tall viewport (800×2000) so the entire sheet content is visible
  /// without scrolling.
  Future<void> openSheet(
    WidgetTester tester,
    KanbanCardData card, {
    bool scrollToBottom = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final overrides = testOverrides(card);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: MaterialApp(
          home: _SheetHost(card: card),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_btn')));
    await tester.pumpAndSettle();

    if (scrollToBottom) {
      // Scroll the ListView inside the sheet to the bottom.
      await tester.dragFrom(
        tester.getCenter(find.byType(DraggableScrollableSheet)),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();
    }
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('KanbanCardDetailSheet', () {
    group('bottom sheet display', () {
      testWidgets(
          'test_showKanbanCardDetailSheet_onTap_showsBottomSheet',
          (tester) async {
        await openSheet(tester, makeCard());

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });
    });

    group('title and description', () {
      testWidgets(
          'test_KanbanCardDetailSheet_withCardTitle_rendersTitle',
          (tester) async {
        await openSheet(tester, makeCard(title: 'File ITR-1'));

        expect(find.text('File ITR-1'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withDescription_rendersDescription',
          (tester) async {
        await openSheet(tester, makeCard(description: 'Detailed work notes'));

        expect(find.text('Detailed work notes'), findsOneWidget);
      });
    });

    group('detail row labels', () {
      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersAssigneeLabel',
          (tester) async {
        await openSheet(tester, makeCard());

        expect(find.text('Assignee'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersPriorityLabel',
          (tester) async {
        await openSheet(tester, makeCard());

        expect(find.text('Priority'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersStatusLabel',
          (tester) async {
        await openSheet(tester, makeCard());

        expect(find.text('Status'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersDueDateLabel',
          (tester) async {
        await openSheet(tester, makeCard());

        expect(find.text('Due Date'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersTimeLoggedLabel',
          (tester) async {
        await openSheet(tester, makeCard());

        expect(find.text('Time Logged'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersClientLabel',
          (tester) async {
        await openSheet(tester, makeCard());

        expect(find.text('Client'), findsOneWidget);
      });
    });

    group('detail row values', () {
      testWidgets(
          'test_KanbanCardDetailSheet_withClientName_rendersClientName',
          (tester) async {
        await openSheet(tester, makeCard(clientName: 'ABC Corp'));

        expect(find.text('ABC Corp'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withHoursLogged_rendersHoursText',
          (tester) async {
        await openSheet(tester, makeCard(hoursLogged: 3.5));

        expect(find.textContaining('3.5 hrs'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withDueDate_rendersDueDateFormatted',
          (tester) async {
        await openSheet(tester, makeCard(dueDate: DateTime(2026, 6, 15)));

        // _formatDate: "15 Jun 2026"
        expect(find.text('15 Jun 2026'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withMediumPriority_showsPriorityLabel',
          (tester) async {
        await openSheet(tester, makeCard(priority: KanbanPriority.medium));

        expect(find.text('Medium'), findsWidgets);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withHighPriority_showsHighLabel',
          (tester) async {
        await openSheet(tester, makeCard(priority: KanbanPriority.high));

        expect(find.text('High'), findsWidgets);
      });
    });

    group('action buttons', () {
      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersSaveButton',
          (tester) async {
        await openSheet(tester, makeCard());

        await tester.ensureVisible(find.text('Save'));
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_always_rendersDeleteButton',
          (tester) async {
        await openSheet(tester, makeCard());

        await tester.ensureVisible(find.text('Delete'));
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_tapSave_dismissesSheet',
          (tester) async {
        await openSheet(tester, makeCard());

        await tester.ensureVisible(find.text('Save'));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // After save the sheet is dismissed; the host button reappears.
        expect(find.byKey(const Key('open_btn')), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_tapDelete_dismissesSheet',
          (tester) async {
        await openSheet(tester, makeCard());

        await tester.ensureVisible(find.text('Delete'));
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('open_btn')), findsOneWidget);
      });
    });

    group('subtasks checklist', () {
      testWidgets(
          'test_KanbanCardDetailSheet_withSubtasks_rendersSubtasksSection',
          (tester) async {
        await openSheet(
          tester,
          makeCard(
            subtasks: const [
              KanbanSubtask(title: 'Collect invoices', isCompleted: true),
              KanbanSubtask(title: 'Upload to portal', isCompleted: false),
            ],
          ),
        );

        await tester.ensureVisible(find.text('Subtasks'));
        expect(find.text('Subtasks'), findsOneWidget);
        await tester.ensureVisible(find.text('Collect invoices'));
        expect(find.text('Collect invoices'), findsOneWidget);
        await tester.ensureVisible(find.text('Upload to portal'));
        expect(find.text('Upload to portal'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withSubtasks_rendersCheckboxListTiles',
          (tester) async {
        await openSheet(
          tester,
          makeCard(
            subtasks: const [
              KanbanSubtask(title: 'Task A', isCompleted: false),
            ],
          ),
        );

        await tester.ensureVisible(find.byType(CheckboxListTile).first);
        expect(find.byType(CheckboxListTile), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withNoSubtasks_hidesSubtasksSection',
          (tester) async {
        await openSheet(tester, makeCard(subtasks: const []));

        expect(find.text('Subtasks'), findsNothing);
        expect(find.byType(CheckboxListTile), findsNothing);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withCompletedSubtask_isChecked',
          (tester) async {
        await openSheet(
          tester,
          makeCard(
            subtasks: const [
              KanbanSubtask(title: 'Done task', isCompleted: true),
            ],
          ),
        );

        await tester.ensureVisible(find.byType(CheckboxListTile).first);
        final checkbox = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile),
        );
        expect(checkbox.value, isTrue);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_withIncompleteSubtask_isUnchecked',
          (tester) async {
        await openSheet(
          tester,
          makeCard(
            subtasks: const [
              KanbanSubtask(title: 'Pending task', isCompleted: false),
            ],
          ),
        );

        await tester.ensureVisible(find.byType(CheckboxListTile).first);
        final checkbox = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile),
        );
        expect(checkbox.value, isFalse);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_tapSubtask_togglesCheckboxState',
          (tester) async {
        await openSheet(
          tester,
          makeCard(
            subtasks: const [
              KanbanSubtask(title: 'Toggle me', isCompleted: false),
            ],
          ),
        );

        await tester.ensureVisible(find.byType(CheckboxListTile).first);
        final checkboxBefore = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile),
        );
        expect(checkboxBefore.value, isFalse);

        // Tap the checkbox.
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pump();

        final checkboxAfter = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile),
        );
        expect(checkboxAfter.value, isTrue);
      });
    });

    group('hint text for empty fields', () {
      testWidgets(
          'test_KanbanCardDetailSheet_always_showsCardTitleHint',
          (tester) async {
        // Build a card with no title to see the hint text.
        await openSheet(tester, makeCard(title: ''));

        expect(find.text('Card title'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCardDetailSheet_always_showsDescriptionHint',
          (tester) async {
        await openSheet(tester, makeCard(description: ''));

        expect(find.text('Add description...'), findsOneWidget);
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Test helper widget — ConsumerWidget that opens the sheet via WidgetRef.
// ---------------------------------------------------------------------------

class _SheetHost extends ConsumerWidget {
  const _SheetHost({required this.card});

  final KanbanCardData card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('open_btn'),
          onPressed: () => showKanbanCardDetailSheet(context, ref, card),
          child: const Text('Open'),
        ),
      ),
    );
  }
}
