import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/billing/presentation/invoice_form_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget buildNewInvoice() => const InvoiceFormScreen();
Widget buildEditInvoice() => const InvoiceFormScreen(invoiceId: 'inv-001');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('InvoiceFormScreen — new invoice', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows New Invoice title in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('New Invoice'), findsOneWidget);
    });

    testWidgets('shows Save Draft button in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Save Draft'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Client section label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Client'), findsOneWidget);
    });

    testWidgets('shows client dropdown hint', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Select client'), findsOneWidget);
    });

    testWidgets('shows Invoice Date field', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Invoice Date'), findsOneWidget);
    });

    testWidgets('shows Due Date field', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Due Date'), findsOneWidget);
    });

    testWidgets('shows Line Items section label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Line Items'), findsOneWidget);
    });

    testWidgets('shows pre-populated ITR Filing line item', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('ITR Filing'), findsOneWidget);
    });

    testWidgets('shows Add Line Item button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Add Line Item'), findsOneWidget);
    });

    testWidgets('shows Discount % field', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Discount %'), findsOneWidget);
    });

    testWidgets('shows GST Rate dropdown', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('GST Rate'), findsOneWidget);
    });

    testWidgets('shows Subtotal in computation summary', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Subtotal'), findsOneWidget);
    });

    testWidgets('shows Total in computation summary', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('shows Send to Client button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildNewInvoice());

      await tester.dragUntilVisible(
        find.text('Send to Client'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Send to Client'), findsOneWidget);
    });
  });

  group('InvoiceFormScreen — edit invoice', () {
    testWidgets('shows Edit Invoice title in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, buildEditInvoice());

      expect(find.text('Edit Invoice'), findsOneWidget);
    });
  });
}
