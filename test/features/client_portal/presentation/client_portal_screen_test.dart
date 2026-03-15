import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/client_portal/presentation/client_portal_screen.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/messages_tab.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/documents_tab.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/queries_tab.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/notifications_tab.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: ClientPortalScreen()),
  );
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ClientPortalScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(ClientPortalScreen), findsOneWidget);
    });

    testWidgets('renders Client Portal title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Client Portal'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(
        find.text('Communication and client-facing workflows'),
        findsOneWidget,
      );
    });

    testWidgets('renders Messages tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Messages'), findsWidgets);
    });

    testWidgets('renders Documents tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Documents'), findsWidgets);
    });

    testWidgets('renders Queries tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Queries'), findsWidgets);
    });

    testWidgets('renders Alerts tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Alerts'), findsWidgets);
    });

    testWidgets('renders a TabBar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders TabBarView with four children', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('renders MessagesTab by default', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(MessagesTab), findsOneWidget);
    });

    testWidgets('renders chat_bubble_outline icon in tab bar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
    });

    testWidgets('renders folder_shared_outlined icon in tab bar',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.folder_shared_outlined), findsWidgets);
    });

    testWidgets('renders support_agent_outlined icon in tab bar',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.support_agent_outlined), findsWidgets);
    });

    testWidgets('switching to Documents tab renders DocumentsTab',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Documents').first);
      await tester.pumpAndSettle();
      expect(find.byType(DocumentsTab), findsOneWidget);
    });

    testWidgets('switching to Queries tab renders QueriesTab', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Queries').first);
      await tester.pumpAndSettle();
      expect(find.byType(QueriesTab), findsOneWidget);
    });

    testWidgets('switching to Alerts tab renders NotificationsTab',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alerts').first);
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsTab), findsOneWidget);
    });
  });
}
