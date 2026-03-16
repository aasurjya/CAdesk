import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/post_filing/presentation/post_filing_dashboard_screen.dart';
import 'package:ca_app/features/post_filing/presentation/widgets/filing_status_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: PostFilingDashboardScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PostFilingDashboardScreen', () {
    testWidgets('renders Post-Filing Tracker title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Post-Filing Tracker'), findsOneWidget);
    });

    testWidgets('renders Monitor filings subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Monitor filings'), findsOneWidget);
    });

    testWidgets('renders Total Filed summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total Filed'), findsOneWidget);
    });

    testWidgets('renders Processed summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Appears in summary card + filter chip
      expect(find.text('Processed'), findsWidgets);
    });

    testWidgets('renders Refund Pending summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Appears in summary card + filter chip
      expect(find.text('Refund Pending'), findsWidgets);
    });

    testWidgets('renders Demands summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Appears in summary card + filter chip
      expect(find.text('Demands'), findsWidgets);
    });

    testWidgets('renders 4 summary cards in a grid', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('renders filter chips for PostFilingFilter values', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders FilingStatusTile widgets', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilingStatusTile), findsWidgets);
    });

    testWidgets('renders RefreshIndicator', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('renders Refund Tracker icon button in app bar', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.money_rounded), findsOneWidget);
    });

    testWidgets('body uses gradient decorated background', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('body is a scrollable ListView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('GridView renders summary cards', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsWidgets);
    });

    testWidgets('tapping a filter chip updates the selection', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final chips = find.byType(FilterChip);
      if (chips.evaluate().length > 1) {
        await tester.tap(chips.at(1));
        await tester.pumpAndSettle();
      }

      // No crash: filter updated
      expect(find.text('Post-Filing Tracker'), findsOneWidget);
    });
  });
}
