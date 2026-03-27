import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/crypto_vda/presentation/vda_tax_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('VdaTaxScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows client name in AppBar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.textContaining('Arjun Sharma'), findsWidgets);
    });

    testWidgets('shows Section 115BBH heading', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.textContaining('115BBH'), findsOneWidget);
    });

    testWidgets('shows client PAN and assessment year', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.textContaining('ABCPS1234K'), findsOneWidget);
      expect(find.textContaining('AY 2026-27'), findsOneWidget);
    });

    testWidgets('shows Total Gains and Total Losses boxes', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.text('Total Gains'), findsOneWidget);
      expect(find.text('Total Losses'), findsOneWidget);
    });

    testWidgets('shows no-loss set-off banner', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.textContaining('losses cannot be set off'), findsOneWidget);
    });

    testWidgets('shows Transactions card title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('shows Bitcoin transaction', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.textContaining('Bitcoin (BTC)'), findsWidgets);
    });

    testWidgets('shows Ethereum transaction', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.textContaining('Ethereum (ETH)'), findsOneWidget);
    });

    testWidgets('shows 1% TDS Section 194S card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.textContaining('194S'), findsWidgets);
    });

    testWidgets('shows Schedule VDA for ITR card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.text('Schedule VDA for ITR'), findsOneWidget);
    });

    testWidgets('shows Export Schedule VDA button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.text('Export Schedule VDA'), findsOneWidget);
    });

    testWidgets('shows Download Computation button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.text('Download Computation'), findsOneWidget);
    });

    testWidgets('shows Tax @ 30% and TDS Deducted amount boxes', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      expect(find.text('Tax @ 30%'), findsOneWidget);
      expect(find.text('TDS Deducted'), findsWidgets);
    });

    testWidgets('export button shows snackbar when tapped', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const VdaTaxScreen(clientId: 'client-001'));
      await tester.ensureVisible(find.text('Export Schedule VDA'));
      await tester.tap(find.text('Export Schedule VDA'));
      await tester.pump();
      expect(find.text('Schedule VDA exported'), findsOneWidget);
    });
  });
}
