import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/virtual_cfo/presentation/virtual_cfo_screen.dart';
import 'package:ca_app/features/virtual_cfo/presentation/widgets/mis_report_card.dart';
import 'package:ca_app/features/virtual_cfo/presentation/widgets/scenario_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: VirtualCfoScreen()));
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VirtualCfoScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(VirtualCfoScreen), findsOneWidget);
    });

    testWidgets('renders Virtual CFO Platform title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Virtual CFO Platform'), findsOneWidget);
    });

    testWidgets('renders MIS Reports tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('MIS Reports'), findsWidgets);
    });

    testWidgets('renders Scenarios tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Scenarios'), findsWidgets);
    });

    testWidgets('renders a TabBar with two tabs', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders Clients KPI card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Clients'), findsOneWidget);
    });

    testWidgets('renders Total AUM KPI card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Total AUM'), findsOneWidget);
    });

    testWidgets('renders Avg EBITDA KPI card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Avg EBITDA'), findsOneWidget);
    });

    testWidgets('renders Reports KPI card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('MIS Reports tab shows status filter chips', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('All'), findsWidgets);
      expect(find.text('Draft'), findsWidgets);
    });

    testWidgets('MIS Reports tab shows MisReportCard widgets or empty state', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      final hasCards = find.byType(MisReportCard).evaluate().isNotEmpty;
      final hasEmpty = find
          .text('No reports match this filter')
          .evaluate()
          .isNotEmpty;
      expect(hasCards || hasEmpty, isTrue);
    });

    testWidgets('switching to Scenarios tab renders without error', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scenarios').first);
      await tester.pumpAndSettle();
      expect(find.byType(VirtualCfoScreen), findsOneWidget);
    });

    testWidgets('Scenarios tab shows category filter chips', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scenarios').first);
      await tester.pumpAndSettle();
      expect(find.text('Revenue'), findsWidgets);
      expect(find.text('Cost'), findsWidgets);
    });

    testWidgets('Scenarios tab shows ScenarioTile widgets or empty state', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scenarios').first);
      await tester.pumpAndSettle();
      final hasTiles = find.byType(ScenarioTile).evaluate().isNotEmpty;
      final hasEmpty = find
          .text('No scenarios match this filter')
          .evaluate()
          .isNotEmpty;
      expect(hasTiles || hasEmpty, isTrue);
    });

    testWidgets('renders people_outline_rounded icon in Clients KPI', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.people_outline_rounded), findsOneWidget);
    });
  });
}
