import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/accounts/presentation/balance_sheet_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// Known mock client IDs with balance sheet data (from balance_sheet_providers.dart)
const _validClientId = 'acc-001';
const _unknownClientId = 'acc-unknown-xyz';

void main() {
  group('BalanceSheetScreen — with valid data', () {
    testWidgets('renders without throwing', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );
    });

    testWidgets('shows "Balance Sheet" in app bar', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.text('Balance Sheet'), findsOneWidget);
    });

    testWidgets('shows ASSETS section heading', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.text('ASSETS'), findsOneWidget);
    });

    testWidgets('shows EQUITY & LIABILITIES section heading', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.text('EQUITY & LIABILITIES'), findsOneWidget);
    });

    testWidgets('shows Non-Current Assets line item', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.text('Non-Current Assets'), findsOneWidget);
    });

    testWidgets('shows Current Assets line item', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.text('Current Assets'), findsOneWidget);
    });

    testWidgets('shows TOTAL ASSETS subtotal line', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.text('TOTAL ASSETS'), findsOneWidget);
    });

    testWidgets("shows Shareholders' Equity line", (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.textContaining("Shareholders"), findsOneWidget);
    });

    testWidgets('shows TOTAL EQUITY & LIABILITIES subtotal line', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      // Scroll down to see the total
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(find.text('TOTAL EQUITY & LIABILITIES'), findsOneWidget);
    });

    testWidgets('shows PDF export icon button', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.byIcon(Icons.picture_as_pdf_rounded), findsWidgets);
    });

    testWidgets('shows Excel export icon button', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      expect(find.byIcon(Icons.table_chart_rounded), findsWidgets);
    });

    testWidgets('shows company name from client data', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      // acc-001 is 'Mehta Textiles Pvt Ltd'
      expect(find.textContaining('Mehta Textiles'), findsOneWidget);
    });

    testWidgets('shows financial year label', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _validClientId),
      );

      // FY 2024-25 for acc-001
      expect(find.textContaining('FY 2024'), findsWidgets);
    });
  });

  group('BalanceSheetScreen — with unknown clientId', () {
    testWidgets('renders without throwing when no data found', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _unknownClientId),
      );
    });

    testWidgets('shows fallback message when no balance sheet data', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const BalanceSheetScreen(clientId: _unknownClientId),
      );

      expect(find.textContaining('No balance sheet data'), findsOneWidget);
    });
  });
}
