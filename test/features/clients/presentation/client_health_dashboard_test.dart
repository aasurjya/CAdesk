import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/clients/presentation/client_health_dashboard.dart';

import '../../../helpers/widget_test_helpers.dart';

// Use a very tall viewport so all SliverList sections render without scrolling.
Future<void> _setViewport(WidgetTester tester) =>
    setTestViewport(tester, size: const Size(600, 4000));

void main() {
  group('ClientHealthDashboard', () {
    testWidgets('renders without crashing', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows client name Rajesh Sharma in header', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('Rajesh Sharma'), findsOneWidget);
    });

    testWidgets('shows PAN in header', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.textContaining('ABCPS1234K'), findsOneWidget);
    });

    testWidgets('shows Client Health Dashboard subtitle', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.textContaining('Client Health Dashboard'), findsOneWidget);
    });

    testWidgets('shows Risk Score card', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('Risk Score'), findsOneWidget);
    });

    testWidgets('shows Low Risk label for score 25', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('Low Risk'), findsOneWidget);
    });

    testWidgets('shows Compliance Status section', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('Compliance Status'), findsOneWidget);
    });

    testWidgets('shows ITR compliance module', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('ITR'), findsOneWidget);
    });

    testWidgets('shows GST compliance module', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('GST'), findsOneWidget);
    });

    testWidgets('shows Active Engagements section', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('Active Engagements'), findsOneWidget);
    });

    testWidgets('shows ITR Filing engagement', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.textContaining('ITR Filing AY 2025-26'), findsOneWidget);
    });

    testWidgets('shows Invoices section', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('Invoices'), findsOneWidget);
    });

    testWidgets('shows invoice number from mock data', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.textContaining('INV-2026-042'), findsOneWidget);
    });

    testWidgets('shows Pending Documents section', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.textContaining('Pending Documents (4)'), findsOneWidget);
    });

    testWidgets('shows Payment History section', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const ClientHealthDashboard(clientId: 'client-001'),
      );

      expect(find.text('Payment History'), findsOneWidget);
    });
  });
}
