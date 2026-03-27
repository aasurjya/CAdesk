import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/collaboration/presentation/shared_workspace_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('SharedWorkspaceScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows workspace name in app bar', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.text('ITR Filing FY25-26'), findsOneWidget);
    });

    testWidgets('shows client name in app bar subtitle', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.text('Rajesh Kumar'), findsOneWidget);
    });

    testWidgets('shows Team section header', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      // 2 users are online in the mock data
      expect(find.textContaining('Team'), findsOneWidget);
    });

    testWidgets('shows online count in team header', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.textContaining('2 online'), findsOneWidget);
    });

    testWidgets('shows Documents section header', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.textContaining('Documents (4)'), findsOneWidget);
    });

    testWidgets('shows Activity section header', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.text('Activity'), findsOneWidget);
    });

    testWidgets('shows a document name from mock data', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.textContaining('Form 16 - Rajesh Kumar'), findsOneWidget);
    });

    testWidgets('shows user first name Amit in team list', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.text('Amit'), findsOneWidget);
    });

    testWidgets('shows ITR-1 Draft Computation document', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.textContaining('ITR-1 Draft Computation'), findsOneWidget);
    });

    testWidgets('shows permission label on a document tile', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      // First document has View permission
      expect(find.text('View'), findsWidgets);
    });

    testWidgets('shows an activity item from mock data', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      // Activity text is inside RichText spans — use byWidgetPredicate
      final richTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Updated ITR-1 Draft'),
      );
      expect(richTextFinder, findsOneWidget);
    });

    testWidgets('shows Sneha in activity feed', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      // Sneha appears in RichText activity rows (user name bold span)
      final snehaFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText().contains('Sneha'),
      );
      expect(snehaFinder, findsWidgets);
    });

    testWidgets('body uses ListView', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SharedWorkspaceScreen(workspaceId: 'ws-001'),
      );

      expect(find.byType(ListView), findsWidgets);
    });
  });
}
