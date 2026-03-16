import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/fee_leakage/presentation/fee_leakage_screen.dart';
import 'package:ca_app/features/fee_leakage/presentation/widgets/engagement_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: FeeLeakageScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FeeLeakageScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Fee Leakage & Scope Control'), findsOneWidget);
    });

    testWidgets('renders Engagements tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Engagements'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Scope Items tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Scope Items'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Total Leakage summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total Leakage'), findsOneWidget);
    });

    testWidgets('renders On Track summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('On Track'), findsWidgets);
    });

    testWidgets('renders Over Scope summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Over Scope'), findsWidgets);
    });

    testWidgets('renders Under-Billed summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Under-Billed'), findsWidgets);
    });

    testWidgets('renders status filter chips in Engagements tab', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders EngagementTile list items', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(EngagementTile), findsWidgets);
    });

    testWidgets('renders TabBar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders TabBarView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('switching to Scope Items tab works', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Scope Items'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('renders money_off icon for Total Leakage', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.money_off_rounded), findsOneWidget);
    });

    testWidgets('renders warning icon for Over Scope', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_rounded), findsWidgets);
    });

    testWidgets('renders monetization_on icon for Under-Billed', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.monetization_on_rounded), findsWidgets);
    });

    testWidgets('renders Scaffold', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
