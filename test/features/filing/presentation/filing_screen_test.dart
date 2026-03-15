import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/presentation/filing_screen.dart';
import 'package:ca_app/features/filing/presentation/widgets/urgency_card.dart';
import 'package:ca_app/features/filing/presentation/widgets/draft_filing_tile.dart';
import 'package:ca_app/features/filing/presentation/widgets/recent_filing_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Use a tall viewport so the entire scrollable Filing Hub fits without clipping.
Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: FilingScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FilingScreen', () {
    testWidgets('renders Filing Hub app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filing Hub'), findsOneWidget);
    });

    testWidgets('renders assessment year dropdown in app bar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('AY'), findsWidgets);
    });

    testWidgets('renders Urgent section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Urgent'), findsOneWidget);
    });

    testWidgets('renders In Progress section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // "In Progress" appears in both the section header and DraftFilingTile status chips
      expect(find.text('In Progress'), findsWidgets);
    });

    testWidgets('renders Recently Filed section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recently Filed'), findsOneWidget);
    });

    testWidgets('renders Tools section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Tools'), findsOneWidget);
    });

    testWidgets('renders UrgencyCard widgets for urgent filings', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(UrgencyCard), findsWidgets);
    });

    testWidgets('renders DraftFilingTile widgets for in-progress filings',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DraftFilingTile), findsWidgets);
    });

    testWidgets('renders RecentFilingTile widgets for filed returns',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(RecentFilingTile), findsWidgets);
    });

    testWidgets('renders New Filing FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Filing'), findsOneWidget);
    });

    testWidgets('renders Filing Queue quick action chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filing Queue'), findsOneWidget);
    });

    testWidgets('renders 26AS / AIS quick action chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('26AS / AIS'), findsOneWidget);
    });

    testWidgets('renders Analytics quick action chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('renders ITR-U quick action chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('ITR-U'), findsOneWidget);
    });

    testWidgets('renders Advance Tax quick action chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Advance Tax'), findsOneWidget);
    });

    testWidgets('body is scrollable ListView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('shows client name in urgent card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // At least one urgent card should show a client name from mock data
      final hasSharma = find.textContaining('Sharma').evaluate().isNotEmpty;
      final hasMehta = find.textContaining('Mehta').evaluate().isNotEmpty;
      expect(hasSharma || hasMehta, isTrue);
    });

    testWidgets('FAB icon is add icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });
}
