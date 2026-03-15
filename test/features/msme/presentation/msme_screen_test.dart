import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/msme/presentation/msme_screen.dart';
import 'package:ca_app/features/msme/presentation/widgets/msme_vendor_tile.dart';
import 'package:ca_app/features/msme/presentation/widgets/msme_payment_tile.dart';
import 'package:ca_app/features/msme/presentation/widgets/msme_summary_card.dart';
import 'package:ca_app/features/msme/domain/models/msme_vendor.dart';
import 'package:ca_app/features/msme/domain/models/msme_payment.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: MsmeScreen()),
  );
}

Widget _buildWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final _testVendor = MsmeVendor(
  id: 'mv-t01',
  clientId: 'c1',
  vendorName: 'Alpha Components Pvt Ltd',
  msmeRegistrationNumber: 'UDYAM-MH-12-0012345',
  classification: MsmeClassification.small,
  registeredDate: DateTime(2020, 3, 15),
  isVerified: true,
  outstandingAmount: 250000,
  daysPastDue: 30,
  section43BhAtRisk: false,
);

final _testPayment = MsmePayment(
  id: 'mp-t01',
  clientId: 'c1',
  vendorId: 'mv-t01',
  vendorName: 'Alpha Components Pvt Ltd',
  invoiceNumber: 'INV/2025-26/001',
  invoiceDate: DateTime(2026, 1, 15),
  invoiceAmount: 100000,
  dueDate: DateTime(2026, 3, 1),
  daysToPay: 44,
  isWithin45Days: true,
  penaltyInterest: 0,
  status: MsmePaymentStatus.paidOnTime,
);

// ---------------------------------------------------------------------------
// MsmeScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('MsmeScreen', () {
    testWidgets('renders app bar with MSME Compliance title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('MSME Compliance'), findsOneWidget);
    });

    testWidgets('renders Vendors, Payments, and 43B(h) Alerts tabs',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Vendors'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Payments'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('43B(h) Alerts'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Vendors summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Vendors'), findsWidgets);
    });

    testWidgets('renders Outstanding summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Outstanding'), findsWidgets);
    });

    testWidgets('renders At Risk summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('At Risk'), findsWidgets);
    });

    testWidgets('renders Overdue summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('renders MsmeSummaryCard widget', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(MsmeSummaryCard), findsOneWidget);
    });

    testWidgets('Vendors tab shows classification filter chips', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Vendors tab shows MsmeVendorTile list', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(MsmeVendorTile), findsWidgets);
    });

    testWidgets('switching to Payments tab shows MsmePaymentTile list',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Payments'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MsmePaymentTile), findsWidgets);
    });

    testWidgets('Payments tab shows payment status filter chips', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Payments'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Vendors tab shows Bharat Precision Tools from mock data',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Bharat Precision'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // MsmeVendorTile tests
  // ---------------------------------------------------------------------------

  group('MsmeVendorTile', () {
    testWidgets('renders vendor name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MsmeVendorTile(vendor: _testVendor)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha Components Pvt Ltd'), findsOneWidget);
    });

    testWidgets('renders MSME registration number', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MsmeVendorTile(vendor: _testVendor)),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('UDYAM-MH-12-0012345'),
        findsWidgets,
      );
    });

    testWidgets('renders Small classification badge', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MsmeVendorTile(vendor: _testVendor)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Small'), findsWidgets);
    });

    testWidgets('renders initials avatar AC', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MsmeVendorTile(vendor: _testVendor)),
      );
      await tester.pumpAndSettle();

      expect(find.text('AC'), findsOneWidget);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildWidget(
          MsmeVendorTile(vendor: _testVendor, onTap: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MsmeVendorTile));
      expect(tapped, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // MsmePaymentTile tests
  // ---------------------------------------------------------------------------

  group('MsmePaymentTile', () {
    testWidgets('renders vendor name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MsmePaymentTile(payment: _testPayment)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha Components Pvt Ltd'), findsOneWidget);
    });

    testWidgets('renders invoice number', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MsmePaymentTile(payment: _testPayment)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('INV/2025-26/001'), findsWidgets);
    });

    testWidgets('renders Paid On Time status', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MsmePaymentTile(payment: _testPayment)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Paid On Time'), findsWidgets);
    });
  });
}
