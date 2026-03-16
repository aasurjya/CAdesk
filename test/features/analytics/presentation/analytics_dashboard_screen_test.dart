import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:ca_app/features/analytics/presentation/widgets/kpi_card.dart';
import 'package:ca_app/features/analytics/presentation/widgets/kpi_grid_widget.dart';
import 'package:ca_app/features/analytics/presentation/widgets/revenue_chart_widget.dart';
import 'package:ca_app/features/analytics/presentation/widgets/client_health_chart_widget.dart';
import 'package:ca_app/features/analytics/data/providers/analytics_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: AnalyticsDashboardScreen()),
  );
}

/// Use a very tall display so the full ListView is rendered.
Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 8000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AnalyticsDashboardScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(AnalyticsDashboardScreen), findsOneWidget);
    });

    testWidgets('renders Analytics & BI title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Analytics & BI'), findsOneWidget);
    });

    testWidgets('renders Performance and growth intelligence subtitle', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Performance and growth intelligence'), findsOneWidget);
    });

    testWidgets('renders banner headline text', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('A clearer view of firm performance'), findsOneWidget);
    });

    testWidgets('renders Practice KPIs section header', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Practice KPIs'), findsOneWidget);
    });

    testWidgets('renders Revenue Trend section header', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Revenue Trend'), findsOneWidget);
    });

    testWidgets('renders Client Health Overview section header', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Client Health Overview'), findsOneWidget);
    });

    testWidgets('renders Revenue by Service section header', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Revenue by Service'), findsOneWidget);
    });

    testWidgets('renders Aging Analysis section header', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Aging Analysis'), findsOneWidget);
    });

    testWidgets('renders Tax Practice Growth section header', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Tax Practice Growth'), findsOneWidget);
    });

    testWidgets('renders KpiGridWidget', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(KpiGridWidget), findsOneWidget);
    });

    testWidgets('renders RevenueChartWidget', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(RevenueChartWidget), findsOneWidget);
    });

    testWidgets('renders ClientHealthChartWidget', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(ClientHealthChartWidget), findsOneWidget);
    });

    testWidgets('renders KpiCard widgets in the Key Metrics grid', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(KpiCard), findsWidgets);
    });

    testWidgets('renders period dropdown', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButton<AnalyticsPeriod>), findsOneWidget);
    });

    testWidgets('renders Growth Pipeline card title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Growth Pipeline'), findsOneWidget);
    });

    testWidgets('renders query_stats icon in banner', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.query_stats_rounded), findsOneWidget);
    });
  });
}
