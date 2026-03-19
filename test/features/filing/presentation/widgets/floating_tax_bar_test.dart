import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/presentation/widgets/floating_tax_bar.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('FloatingTaxBar', () {
    testWidgets('renders gross income, deductions, and tax payable labels',
        (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: FloatingTaxBar(
            grossIncome: 500000,
            deductions: 150000,
            taxPayable: 25000,
          ),
        ),
      );

      expect(find.text('Gross Income'), findsOneWidget);
      expect(find.text('Deductions'), findsOneWidget);
      expect(find.text('Tax Payable'), findsOneWidget);
    });

    testWidgets('formats values as compact INR', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: FloatingTaxBar(
            grossIncome: 500000,
            deductions: 150000,
            taxPayable: 25000,
          ),
        ),
      );

      // 500000 = ₹5L, 150000 = ₹1.5L, 25000 = ₹25K
      expect(find.text('\u20b95L'), findsOneWidget);
      expect(find.text('\u20b91.5L'), findsOneWidget);
      expect(find.text('\u20b925K'), findsOneWidget);
    });

    testWidgets('shows zero values when no data', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: FloatingTaxBar(
            grossIncome: 0,
            deductions: 0,
            taxPayable: 0,
          ),
        ),
      );

      // 0 formatted compact is ₹0
      expect(find.text('\u20b90'), findsNWidgets(3));
    });

    testWidgets('has correct height of 64', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: FloatingTaxBar(
            grossIncome: 100000,
            deductions: 50000,
            taxPayable: 10000,
          ),
        ),
      );

      // The height is set via the Container's height property (64).
      expect(find.byType(FloatingTaxBar), findsOneWidget);
      // Verify the rendered box has the expected height.
      final box = tester.renderObject<RenderBox>(find.byType(FloatingTaxBar));
      expect(box.size.height, 64);
    });
  });
}
