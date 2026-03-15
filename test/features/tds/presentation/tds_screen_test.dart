import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/presentation/tds_screen.dart';
import 'package:ca_app/features/tds/presentation/widgets/tds_deductor_tile.dart';
import 'package:ca_app/features/tds/presentation/widgets/tds_summary_card.dart';

// ---------------------------------------------------------------------------
// Shared test helpers
// ---------------------------------------------------------------------------

const _testDeductor = TdsDeductor(
  id: 'ded-001',
  deductorName: 'Tata Consultancy Services Ltd',
  tan: 'MUMS12345A',
  pan: 'AABCT1234A',
  deductorType: DeductorType.company,
  address: '9th Floor, Nirmal Building, Nariman Point, Mumbai 400021',
  email: 'tds@tcs.com',
  phone: '022-67789000',
  responsiblePerson: 'Rajesh Kumar',
);

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: TdsScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TdsScreen', () {
    testWidgets('renders app bar with TDS / TCS title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('TDS / TCS'), findsOneWidget);
    });

    testWidgets('renders four form-type tab labels', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('24Q')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('26Q')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('27Q')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('27EQ')),
        findsOneWidget,
      );
    });

    testWidgets('renders TdsSummaryCard', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TdsSummaryCard), findsOneWidget);
    });

    testWidgets('summary card shows Deductors metric label', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Deductors'), findsOneWidget);
    });

    testWidgets('summary card shows Due, Filed, Overdue labels', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Filed'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('renders challan summary row', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('paid'), findsWidgets);
    });

    testWidgets('renders FY dropdown', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('FY 2025-26'), findsOneWidget);
    });

    testWidgets('renders quarter filter chips', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Q1'), findsWidgets);
      expect(find.text('Q2'), findsWidgets);
    });

    testWidgets('renders TdsDeductorTiles in 24Q tab', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TdsDeductorTile), findsWidgets);
    });

    testWidgets('renders New Return FAB', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Return'), findsOneWidget);
    });

    testWidgets('New Return FAB is present and tappable', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final fab = find.widgetWithText(FloatingActionButton, 'New Return');
      expect(fab, findsWidgets);
    });

    testWidgets('switching to 26Q tab still shows deductor tiles',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('26Q'));
      await tester.pumpAndSettle();

      expect(find.byType(TdsDeductorTile), findsWidgets);
    });
  });

  group('TdsSummaryCard', () {
    testWidgets('renders all four metrics from provider', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TdsSummaryCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deductors'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Filed'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('renders numeric values for each metric', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TdsSummaryCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 6 deductors are defined in mock data
      expect(find.text('6'), findsOneWidget);
    });
  });

  group('TdsDeductorTile', () {
    testWidgets('renders deductor name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TdsDeductorTile(deductor: _testDeductor),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Tata Consultancy Services Ltd'),
        findsOneWidget,
      );
    });

    testWidgets('renders TAN', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TdsDeductorTile(deductor: _testDeductor),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MUMS12345A'), findsOneWidget);
    });

    testWidgets('renders quarter status dots', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TdsDeductorTile(deductor: _testDeductor),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Q1 through Q4 labels appear under the dots
      expect(find.text('Q1'), findsWidgets);
    });

    testWidgets('tapping tile fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TdsDeductorTile(
                deductor: _testDeductor,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TdsDeductorTile));
      expect(tapped, isTrue);
    });
  });
}
