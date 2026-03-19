import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/tasks/presentation/task_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// The TaskDetailScreen uses a hardcoded mock task driven by _mockTask(taskId),
// so any taskId value will render the same content. No provider overrides needed.

void main() {
  group('TaskDetailScreen', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.byType(TaskDetailScreen), findsOneWidget);
    });

    testWidgets('shows Task Detail in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('Task Detail'), findsOneWidget);
    });

    testWidgets('shows edit icon button in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.byTooltip('Edit'), findsOneWidget);
    });

    testWidgets('shows task title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(
        find.text('ITR Filing - Rajesh Sharma AY 2025-26'),
        findsOneWidget,
      );
    });

    testWidgets('shows priority badge', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('High'), findsWidgets);
    });

    testWidgets('shows status choice chips', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('In Review'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('shows metadata card with client, assignee, reviewer', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Rajesh Sharma'), findsOneWidget);
      expect(find.text('Assignee'), findsOneWidget);
      expect(find.text('Ananya Desai'), findsOneWidget);
      expect(find.text('Reviewer'), findsOneWidget);
      expect(find.text('Suresh Iyer'), findsOneWidget);
    });

    testWidgets('shows Time Progress card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('Time Progress'), findsOneWidget);
    });

    testWidgets('shows Subtasks section with count', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('Subtasks'), findsOneWidget);
      // 2 of 5 subtasks completed in mock data.
      expect(find.text('2/5'), findsOneWidget);
    });

    testWidgets('shows subtask titles', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('Collect Form 16 and documents'), findsOneWidget);
      expect(find.text('File on IT portal'), findsOneWidget);
    });

    testWidgets('shows Time Entries section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      expect(find.text('Time Entries'), findsOneWidget);
    });

    testWidgets('shows Comments section by scrolling', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      await tester.scrollUntilVisible(
        find.text('Comments'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Comments'), findsOneWidget);
    });

    testWidgets('shows comment author names by scrolling', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      // Ananya Desai is also in metadata card (Assignee field), visible without scroll.
      expect(find.text('Ananya Desai'), findsWidgets);
    });

    testWidgets('shows tag chips by scrolling', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const TaskDetailScreen(taskId: 'task-001'));
      await tester.scrollUntilVisible(
        find.text('ITR'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('ITR'), findsOneWidget);
      expect(find.text('Individual'), findsOneWidget);
      expect(find.text('Priority Client'), findsOneWidget);
    });
  });
}
