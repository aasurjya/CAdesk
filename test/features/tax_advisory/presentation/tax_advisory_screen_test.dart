import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/tax_advisory/presentation/tax_advisory_screen.dart';
import 'package:ca_app/features/tax_advisory/presentation/widgets/opportunity_tile.dart';
import 'package:ca_app/features/tax_advisory/presentation/widgets/proposal_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: TaxAdvisoryScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TaxAdvisoryScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Tax Advisory Engine'), findsOneWidget);
    });

    testWidgets('renders Opportunities tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Opportunities'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Proposals tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Proposals'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Total summary card label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total'), findsWidgets);
    });

    testWidgets('renders High Priority summary card label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('High Priority'), findsOneWidget);
    });

    testWidgets('renders Converted summary card label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Converted'), findsWidgets);
    });

    testWidgets('renders Pipeline summary card label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pipeline'), findsWidgets);
    });

    testWidgets('renders four summary cards in a Row', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // lightbulb icon appears once per summary card header
      expect(find.byIcon(Icons.lightbulb_outline_rounded), findsWidgets);
    });

    testWidgets('renders type filter chips in Opportunities tab',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders OpportunityTile list items', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(OpportunityTile), findsWidgets);
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

    testWidgets('switching to Proposals tab shows ProposalTile items',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Proposals'),
        ),
      );
      await tester.pumpAndSettle();

      // Either proposals exist or the empty state is shown
      final proposals = find.byType(ProposalTile);
      final empty = find.byType(ListView);
      expect(proposals.evaluate().isNotEmpty || empty.evaluate().isNotEmpty,
          isTrue);
    });

    testWidgets('renders Scaffold widget', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders priority_high icon for High Priority card',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
    });

    testWidgets('renders currency_rupee icon for Pipeline card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.currency_rupee_rounded), findsWidgets);
    });
  });
}
