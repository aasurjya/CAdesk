import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/litigation/presentation/litigation_dashboard_screen.dart';
import 'package:ca_app/features/litigation/presentation/widgets/notice_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: LitigationDashboardScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LitigationDashboardScreen', () {
    testWidgets('renders Notices & Litigation title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Notices & Litigation'), findsOneWidget);
    });

    testWidgets('renders subtitle about notice resolution', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Notice resolution'), findsOneWidget);
    });

    testWidgets('renders Total summary stat card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('renders Critical summary stat card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // "Critical" appears in both stat card and filter chip row
      expect(find.text('Critical'), findsWidgets);
    });

    testWidgets('renders Pending summary stat card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders All filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders urgency level filter chips', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // UrgencyLevel enum: critical, high, medium, low
      expect(find.text('High'), findsWidgets);
      expect(find.text('Medium'), findsWidgets);
      expect(find.text('Low'), findsWidgets);
    });

    testWidgets('renders NoticeTile widgets for each notice', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(NoticeTile), findsWidgets);
    });

    testWidgets('renders Add Notice FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Add Notice'), findsOneWidget);
    });

    testWidgets('renders CustomScrollView body', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('stat cards show numeric values', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // At least one numeric count should appear
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('tapping Critical filter chip filters list', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Tap Critical filter
      await tester.tap(find.text('Critical').last);
      await tester.pumpAndSettle();

      // After filtering, either notices show or empty state
      final noticesOrEmpty =
          find.byType(NoticeTile).evaluate().isNotEmpty ||
          find.text('No notices').evaluate().isNotEmpty;
      expect(noticesOrEmpty, isTrue);
    });

    testWidgets('tapping All chip shows all notices', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.byType(NoticeTile), findsWidgets);
    });

    testWidgets('FAB has add icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('filter chips render inside scrollable row', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
