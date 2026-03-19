import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/fema/presentation/fema_transaction_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// Use a wide/tall viewport to avoid RenderFlex overflow in _FormStep rows.
Future<void> _setViewport(WidgetTester tester) =>
    setTestViewport(tester, size: const Size(600, 2000));

void main() {
  group('FemaTransactionScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows entity name in app bar', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.textContaining('TechGlobal India Pvt Ltd'), findsWidgets);
    });

    testWidgets('shows FEMA prefix in app bar', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.textContaining('FEMA'), findsOneWidget);
    });

    testWidgets('shows Inward Remittance type label', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.text('Inward Remittance'), findsOneWidget);
    });

    testWidgets('shows FC-GPR form type badge', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.text('FC-GPR'), findsWidgets);
    });

    testWidgets('shows USD currency in header', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      // USD appears in both the amount text and the currency detail row
      expect(find.textContaining('USD'), findsWidgets);
    });

    testWidgets('shows INR equivalent text', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.textContaining('INR equivalent'), findsOneWidget);
    });

    testWidgets('shows RBI Compliance Checklist section', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.text('RBI Compliance Checklist'), findsOneWidget);
    });

    testWidgets('shows checklist item count (5/7)', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.text('5 / 7'), findsOneWidget);
    });

    testWidgets('shows Form Tracking section', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.textContaining('Form Tracking'), findsOneWidget);
    });

    testWidgets('shows File FC-GPR action button', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.textContaining('File FC-GPR'), findsOneWidget);
    });

    testWidgets('shows Export Report button', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.text('Export Report'), findsOneWidget);
    });

    testWidgets('shows RBI reference number', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      expect(find.textContaining('RBI/2026/FDI/00487'), findsOneWidget);
    });

    testWidgets('tapping Export Report shows snackbar', (tester) async {
      await _setViewport(tester);
      await pumpTestWidget(
        tester,
        const FemaTransactionScreen(transactionId: 'fema-txn-001'),
      );

      await tester.tap(find.text('Export Report'));
      await tester.pump();

      expect(find.textContaining('PDF report generated'), findsOneWidget);
    });
  });
}
