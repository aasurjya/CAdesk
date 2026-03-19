import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/einvoicing/presentation/einvoice_form_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('EinvoiceFormScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());
    });

    testWidgets('shows "New E-Invoice" title in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('New E-Invoice'), findsOneWidget);
    });

    testWidgets('shows "Edit E-Invoice" title when invoiceId is provided', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceFormScreen(invoiceId: 'inv-001'),
      );

      expect(find.text('Edit E-Invoice'), findsOneWidget);
    });

    testWidgets('Buyer GSTIN field is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Buyer GSTIN'), findsOneWidget);
    });

    testWidgets('Legal Name field is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Legal Name'), findsOneWidget);
    });

    testWidgets('Trade Name field is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Trade Name'), findsOneWidget);
    });

    testWidgets('Place of Supply field is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Place of Supply'), findsOneWidget);
    });

    testWidgets('Save Draft button is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Save Draft'), findsOneWidget);
    });

    testWidgets('Validate button is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Validate'), findsOneWidget);
    });

    testWidgets('Generate IRN button is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Generate IRN'), findsOneWidget);
    });

    testWidgets('Document Type segmented button is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Tax Invoice'), findsOneWidget);
    });

    testWidgets('Add Item button is present for line items', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets(
      'form validation fires when Validate is tapped with empty GSTIN',
      (tester) async {
        await setDesktopViewport(tester);
        await pumpTestWidget(tester, const EinvoiceFormScreen());

        await tester.tap(find.text('Validate'));
        await tester.pumpAndSettle();

        // Validation error message for empty GSTIN
        expect(find.text('GSTIN is required'), findsOneWidget);
      },
    );

    testWidgets('GSTIN validation fires for wrong length', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      // Enter a short GSTIN
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Buyer GSTIN'),
        '12345',
      );
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();

      expect(find.text('GSTIN must be 15 characters'), findsOneWidget);
    });

    testWidgets('shows empty state message when no line items', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.text('No line items'), findsOneWidget);
    });

    testWidgets('form has a Form widget wrapping the body', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const EinvoiceFormScreen());

      expect(find.byType(Form), findsOneWidget);
    });
  });
}
