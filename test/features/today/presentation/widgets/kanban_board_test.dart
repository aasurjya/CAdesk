import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/today/presentation/widgets/kanban_board.dart';
import 'package:ca_app/features/today/presentation/widgets/kanban_card.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  ComplianceDeadline makeDeadline({
    String id = 'd1',
    String title = 'File GSTR-3B',
    ComplianceCategory category = ComplianceCategory.gst,
    ComplianceStatus status = ComplianceStatus.upcoming,
    DateTime? dueDate,
  }) {
    return ComplianceDeadline(
      id: id,
      title: title,
      description: 'Monthly GST return',
      category: category,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 5)),
      applicableTo: const ['all'],
      isRecurring: true,
      frequency: ComplianceFrequency.monthly,
      status: status,
    );
  }

  KanbanColumnData makeColumnData({
    String title = 'Overdue',
    Color color = Colors.red,
    List<ComplianceDeadline> deadlines = const [],
  }) {
    return KanbanColumnData(title: title, color: color, deadlines: deadlines);
  }

  Widget buildSubject({
    List<KanbanColumnData>? columns,
    double columnWidth = 280,
    ValueChanged<ComplianceDeadline>? onDeadlineTap,
  }) {
    return SizedBox(
      height: 600,
      child: KanbanBoard(
        columns: columns ??
            [
              makeColumnData(title: 'Overdue', color: Colors.red),
              makeColumnData(title: 'Due Today', color: Colors.orange),
            ],
        columnWidth: columnWidth,
        onDeadlineTap: onDeadlineTap,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('KanbanBoard', () {
    group('column header rendering', () {
      testWidgets(
          'test_KanbanBoard_withColumns_rendersColumnTitles',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [
              makeColumnData(title: 'Overdue'),
              makeColumnData(title: 'Due Today'),
              makeColumnData(title: 'This Week'),
              makeColumnData(title: 'Later'),
            ],
          ),
        );

        expect(find.text('Overdue'), findsOneWidget);
        expect(find.text('Due Today'), findsOneWidget);
        expect(find.text('This Week'), findsOneWidget);
        expect(find.text('Later'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanBoard_withEmptyColumn_rendersZeroCount',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [makeColumnData(title: 'Overdue', deadlines: const [])],
          ),
        );

        expect(find.text('0'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanBoard_withTwoDeadlines_rendersTwoCount',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [
              makeColumnData(
                title: 'Overdue',
                deadlines: [
                  makeDeadline(id: 'd1'),
                  makeDeadline(id: 'd2'),
                ],
              ),
            ],
          ),
        );

        expect(find.text('2'), findsOneWidget);
      });
    });

    group('empty column state', () {
      testWidgets(
          'test_KanbanBoard_withEmptyColumn_rendersNoItemsText',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [makeColumnData(title: 'Overdue', deadlines: const [])],
          ),
        );

        expect(find.text('No items'), findsOneWidget);
      });
    });

    group('deadline cards', () {
      testWidgets(
          'test_KanbanBoard_withDeadlines_rendersKanbanCards',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [
              makeColumnData(
                title: 'Due Today',
                deadlines: [makeDeadline(id: 'd1', title: 'Pay advance tax')],
              ),
            ],
          ),
        );

        expect(find.byType(KanbanCard), findsOneWidget);
        expect(find.text('Pay advance tax'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanBoard_withMultipleDeadlines_rendersAllCards',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [
              makeColumnData(
                deadlines: [
                  makeDeadline(id: 'd1', title: 'Task Alpha'),
                  makeDeadline(id: 'd2', title: 'Task Beta'),
                  makeDeadline(id: 'd3', title: 'Task Gamma'),
                ],
              ),
            ],
          ),
        );

        expect(find.text('Task Alpha'), findsOneWidget);
        expect(find.text('Task Beta'), findsOneWidget);
        expect(find.text('Task Gamma'), findsOneWidget);
      });
    });

    group('tap interaction', () {
      testWidgets(
          'test_KanbanBoard_tapDeadlineCard_invokesOnDeadlineTap',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        ComplianceDeadline? tapped;
        final deadline = makeDeadline(id: 'd1', title: 'Tappable Deadline');

        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [makeColumnData(deadlines: [deadline])],
            onDeadlineTap: (d) => tapped = d,
          ),
        );

        await tester.tap(find.text('Tappable Deadline'));
        await tester.pump();

        expect(tapped, deadline);
      });

      testWidgets(
          'test_KanbanBoard_withNullOnDeadlineTap_doesNotThrow',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        final deadline = makeDeadline(title: 'No tap handler');

        await pumpTestWidget(
          tester,
          buildSubject(
            columns: [makeColumnData(deadlines: [deadline])],
            // onDeadlineTap intentionally omitted.
          ),
        );

        // Should render without error even with no tap handler.
        expect(find.text('No tap handler'), findsOneWidget);
      });
    });

    group('horizontal scroll', () {
      testWidgets(
          'test_KanbanBoard_always_wrapsInSingleChildScrollView',
          (tester) async {
        await setTestViewport(tester, size: const Size(800, 800));
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('custom column width', () {
      testWidgets(
          'test_KanbanBoard_withCustomColumnWidth_rendersSizedBoxes',
          (tester) async {
        await setTestViewport(tester, size: const Size(1200, 800));
        await pumpTestWidget(
          tester,
          buildSubject(
            columnWidth: 320,
            columns: [makeColumnData(title: 'Wide Column')],
          ),
        );

        // Board renders without error with custom width.
        expect(find.text('Wide Column'), findsOneWidget);
      });
    });
  });
}
