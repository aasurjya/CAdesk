import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/presentation/widgets/invoice_detail_sheet.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  Invoice makeInvoice({
    InvoiceStatus status = InvoiceStatus.sent,
    double paidAmount = 0,
    double grandTotal = 5900,
    double balanceDue = 5900,
    bool isRecurring = false,
    DateTime? dueDate,
  }) {
    return Invoice(
      id: 'inv-001',
      invoiceNumber: 'INV/2024-25/001',
      clientId: 'client-001',
      clientName: 'Rajesh Kumar',
      invoiceDate: DateTime(2024, 4, 1),
      dueDate: dueDate ?? DateTime(2024, 4, 30),
      lineItems: const [
        LineItem(
          description: 'ITR Filing AY 2024-25',
          hsn: '998231',
          quantity: 1,
          rate: 5000.0,
          taxableAmount: 5000.0,
          gstRate: 18,
          cgst: 450.0,
          sgst: 450.0,
          igst: 0.0,
          total: 5900.0,
        ),
      ],
      subtotal: 5000.0,
      totalGst: 900.0,
      grandTotal: grandTotal,
      paidAmount: paidAmount,
      balanceDue: balanceDue,
      status: status,
      isRecurring: isRecurring,
    );
  }

  Widget buildSheet(Invoice invoice) {
    return buildTestWidget(
      Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => InvoiceDetailSheet(invoice: invoice),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('InvoiceDetailSheet', () {
    group('initial rendering', () {
      testWidgets('renders without crashing', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeInvoice()));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(InvoiceDetailSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows invoice number', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeInvoice()));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.textContaining('INV/2024-25/001'), findsWidgets);
      });

      testWidgets('shows client name', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeInvoice()));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Rajesh Kumar'), findsWidgets);
      });

      testWidgets('shows sent status badge', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(makeInvoice(status: InvoiceStatus.sent)),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Sent'), findsWidgets);
      });
    });

    group('line items', () {
      testWidgets('shows line item description', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeInvoice()));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.textContaining('ITR Filing'), findsWidgets);
      });
    });

    group('payment status variants', () {
      testWidgets('paid invoice renders correctly', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(
            makeInvoice(
              status: InvoiceStatus.paid,
              paidAmount: 5900,
              balanceDue: 0,
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Paid'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('overdue invoice renders correctly', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(
            makeInvoice(
              status: InvoiceStatus.overdue,
              dueDate: DateTime.now().subtract(const Duration(days: 10)),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Overdue'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('draft invoice renders correctly', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(makeInvoice(status: InvoiceStatus.draft)),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Draft'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    });

    group('scrollable sheet structure', () {
      testWidgets('uses DraggableScrollableSheet', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeInvoice()));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });
    });
  });
}
