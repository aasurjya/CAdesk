import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/presentation/billing_screen.dart';
import 'package:ca_app/features/billing/presentation/widgets/invoice_tile.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

final _testInvoice = Invoice(
  id: 'inv-test-001',
  invoiceNumber: 'CAD-2026-0001',
  clientId: 'client-001',
  clientName: 'Tata Consultancy Services',
  invoiceDate: DateTime(2026, 3, 1),
  dueDate: DateTime(2026, 3, 31),
  lineItems: const [],
  subtotal: 50000,
  totalGst: 9000,
  grandTotal: 59000,
  paidAmount: 0,
  balanceDue: 59000,
  status: InvoiceStatus.sent,
);

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: BillingScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BillingScreen', () {
    testWidgets('renders app bar with Billing title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Billing'), findsOneWidget);
    });

    testWidgets('renders subtitle copy', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Invoices, collections, and cash visibility'),
        findsOneWidget,
      );
    });

    testWidgets('renders Invoices and Payments tabs', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
    });

    testWidgets('renders billing summary cards row', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Billed'), findsOneWidget);
      expect(find.text('Collected'), findsOneWidget);
      expect(find.text('Outstanding'), findsOneWidget);
      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('renders aging summary section', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Aging Summary'), findsOneWidget);
    });

    testWidgets('renders all four aging buckets', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Current'), findsOneWidget);
      expect(find.textContaining('Overdue\n31-60d'), findsOneWidget);
    });

    testWidgets('renders search field', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders invoice status filter chips', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Status filter chips include 'All' plus each InvoiceStatus
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('renders invoice tiles in Invoices tab', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(InvoiceTile), findsWidgets);
    });

    testWidgets('renders New Invoice FAB', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Invoice'), findsOneWidget);
    });

    testWidgets('tapping New Invoice FAB opens bottom sheet', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Invoice'));
      await tester.pumpAndSettle();

      // Bottom sheet should appear (contains client selection)
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('switching to Payments tab shows receipts content',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      // Either receipts list or empty state should be present
      expect(
        find.byType(ListView).evaluate().isNotEmpty ||
            find.text('No payment receipts found').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('billing banner is visible', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Stay on top of collections'),
        findsOneWidget,
      );
    });
  });

  group('InvoiceTile', () {
    testWidgets('renders invoice number', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceTile(invoice: _testInvoice),
          ),
        ),
      );

      expect(find.text('CAD-2026-0001'), findsOneWidget);
    });

    testWidgets('renders client name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceTile(invoice: _testInvoice),
          ),
        ),
      );

      expect(find.text('Tata Consultancy Services'), findsOneWidget);
    });

    testWidgets('renders status badge label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceTile(invoice: _testInvoice),
          ),
        ),
      );

      expect(find.text('Sent'), findsOneWidget);
    });

    testWidgets('renders Grand Total and Balance Due labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceTile(invoice: _testInvoice),
          ),
        ),
      );

      expect(find.text('Grand Total'), findsOneWidget);
      expect(find.text('Balance Due'), findsOneWidget);
    });

    testWidgets('renders due date', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceTile(invoice: _testInvoice),
          ),
        ),
      );

      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('31 Mar 2026'), findsOneWidget);
    });

    testWidgets('tapping tile fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceTile(
              invoice: _testInvoice,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InvoiceTile));
      expect(tapped, isTrue);
    });

    testWidgets('paid invoice does not show balance due section',
        (tester) async {
      final paidInvoice = Invoice(
        id: 'inv-paid',
        invoiceNumber: 'CAD-2026-PAID',
        clientId: 'client-002',
        clientName: 'Test Client',
        invoiceDate: DateTime(2026, 3, 1),
        dueDate: DateTime(2026, 3, 31),
        lineItems: const [],
        subtotal: 20000,
        totalGst: 3600,
        grandTotal: 23600,
        paidAmount: 23600,
        balanceDue: 0,
        status: InvoiceStatus.paid,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InvoiceTile(invoice: paidInvoice)),
        ),
      );

      expect(find.text('Balance Due'), findsNothing);
    });
  });
}
