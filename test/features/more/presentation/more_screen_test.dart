import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/more/presentation/more_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: MoreScreen()));

void main() {
  group('MoreScreen', () {
    testWidgets('renders More app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('renders grid view toggle icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Grid view is the default, so list icon shows
      expect(find.byIcon(Icons.view_list), findsOneWidget);
    });

    testWidgets('renders CA Professional profile name', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('CA Professional'), findsOneWidget);
    });

    testWidgets('renders ca@example.com email in profile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('ca@example.com'), findsOneWidget);
    });

    testWidgets('renders Settings menu item', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders GST menu item', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('GST'), findsOneWidget);
    });

    testWidgets('renders Sign Out button when scrolled', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Scroll to the bottom to reveal the footer
      await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('renders CADesk version footer when scrolled', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.textContaining('CADesk v'), findsOneWidget);
    });

    testWidgets('tapping list view toggle switches to list view', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    });

    testWidgets('renders Income Tax menu item', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Income Tax'), findsOneWidget);
    });

    testWidgets('renders logout icon in Sign Out button when scrolled', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('renders CA avatar initials', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('CA'), findsOneWidget);
    });

    testWidgets('renders Billing menu item', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Billing'), findsOneWidget);
    });

    testWidgets('renders Analytics menu item', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('renders Documents menu item', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Documents'), findsOneWidget);
    });
  });
}
