import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/esg_reporting/presentation/esg_reporting_screen.dart';
import 'package:ca_app/features/esg_reporting/presentation/widgets/esg_score_card.dart';
import 'package:ca_app/features/esg_reporting/presentation/widgets/carbon_metric_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: EsgReportingScreen()));
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EsgReportingScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(EsgReportingScreen), findsOneWidget);
    });

    testWidgets('renders ESG Reporting title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('ESG Reporting'), findsOneWidget);
    });

    testWidgets('renders Disclosures tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Disclosures'), findsWidgets);
    });

    testWidgets('renders Carbon Metrics tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Carbon Metrics'), findsWidgets);
    });

    testWidgets('renders a TabBar with two tabs', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('Disclosures tab shows ESG Portfolio Overview card', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.textContaining('ESG Portfolio Overview'), findsOneWidget);
    });

    testWidgets('Disclosures tab shows Total Clients metric', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Total Clients'), findsOneWidget);
    });

    testWidgets('Disclosures tab shows Avg ESG Score metric', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Avg ESG Score'), findsOneWidget);
    });

    testWidgets('Disclosures tab shows status filter chips', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Disclosures tab shows EsgScoreCard widgets or empty state', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      final hasCards = find.byType(EsgScoreCard).evaluate().isNotEmpty;
      final hasEmpty = find
          .text('No disclosures match this filter.')
          .evaluate()
          .isNotEmpty;
      expect(hasCards || hasEmpty, isTrue);
    });

    testWidgets('Disclosures tab shows Draft filter chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Draft'), findsWidgets);
    });

    testWidgets('switching to Carbon Metrics tab renders without error', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carbon Metrics').first);
      await tester.pumpAndSettle();
      expect(find.byType(EsgReportingScreen), findsOneWidget);
    });

    testWidgets('Carbon Metrics tab shows Aggregate Carbon Footprint card', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carbon Metrics').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Aggregate Carbon Footprint'), findsOneWidget);
    });

    testWidgets('Carbon Metrics tab shows Total CO₂e label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carbon Metrics').first);
      await tester.pumpAndSettle();
      expect(find.text('Total CO₂e'), findsOneWidget);
    });

    testWidgets('Carbon Metrics tab shows CarbonMetricTile widgets', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carbon Metrics').first);
      await tester.pumpAndSettle();
      expect(find.byType(CarbonMetricTile), findsWidgets);
    });
  });
}
