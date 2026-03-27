import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/presentation/advance_tax/advance_tax_calculator_screen.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('AdvanceTaxCalculatorScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());
    });

    testWidgets('shows "Advance Tax Calculator" in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.text('Advance Tax Calculator'), findsOneWidget);
    });

    testWidgets('shows Income Estimation section header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.text('Income Estimation'), findsOneWidget);
    });

    testWidgets('shows FY 2025-26 Installments section header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.textContaining('Installments'), findsWidgets);
    });

    testWidgets('shows Interest Computation section header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.textContaining('Interest Computation'), findsWidgets);
    });

    testWidgets('shows salary income input field', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.textContaining('Salary Income'), findsWidgets);
    });

    testWidgets('shows Compute Tax button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.text('Compute Tax'), findsOneWidget);
    });

    testWidgets('shows quarterly installment cards (Q1 through Q4)', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      // At least Q1 label should be present in the widget tree
      expect(find.textContaining('Q1'), findsWidgets);
    });

    testWidgets('shows Save Draft FAB', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.byType(FloatingActionButton), findsWidgets);
      expect(find.text('Save Draft'), findsWidgets);
    });

    testWidgets('Save Draft button in app bar is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      // Icon button for save in app bar
      expect(find.byIcon(Icons.save_outlined), findsWidgets);
    });

    testWidgets('Collapse/Edit toggle button is visible', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      // Defaults to showing estimation form with "Collapse" button
      expect(find.text('Collapse'), findsOneWidget);
    });

    testWidgets('tapping Collapse hides estimation form', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const AdvanceTaxCalculatorScreen());

      expect(find.text('Collapse'), findsOneWidget);

      await tester.tap(find.text('Collapse'));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Collapse'), findsNothing);
    });
  });
}
