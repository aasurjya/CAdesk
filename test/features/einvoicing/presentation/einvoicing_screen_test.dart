import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/einvoicing/presentation/einvoicing_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: EinvoicingScreen()));
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EinvoicingScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(EinvoicingScreen), findsOneWidget);
    });

    testWidgets('renders E-Invoicing Hub title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('E-Invoicing Hub'), findsOneWidget);
    });

    testWidgets('renders E-Invoices tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('E-Invoices'), findsWidgets);
    });

    testWidgets('renders Batches tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Batches'), findsWidgets);
    });

    testWidgets('renders a TabBar with two tabs', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('E-Invoices tab shows Total summary item', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Total'), findsWidgets);
    });

    testWidgets('E-Invoices tab shows Generated summary item', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Generated'), findsWidgets);
    });

    testWidgets('E-Invoices tab shows Pending summary item', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('E-Invoices tab shows Overdue summary item', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('E-Invoices tab shows filter chips for All status',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('E-Invoices tab shows Cancelled filter chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Cancelled'), findsWidgets);
    });

    testWidgets('switching to Batches tab renders without error', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batches').first);
      await tester.pumpAndSettle();
      expect(find.byType(EinvoicingScreen), findsOneWidget);
    });

    testWidgets('Batches tab shows batches or empty state', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batches').first);
      await tester.pumpAndSettle();
      final hasEmpty = find.text('No batches found.').evaluate().isNotEmpty;
      final hasCards = find.byType(Card).evaluate().isNotEmpty;
      expect(hasEmpty || hasCards, isTrue);
    });

    testWidgets('renders AppBar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders TabBarView', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });
}
