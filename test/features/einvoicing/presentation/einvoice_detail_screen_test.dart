import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/einvoicing/data/providers/einvoicing_providers.dart';
import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/presentation/einvoice_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _generatedRecord = EinvoiceRecord(
  id: 'test-001',
  clientName: 'Test Seller Ltd',
  invoiceNumber: 'INV-TEST-0001',
  buyerName: 'Test Buyer Corp',
  invoiceValue: 1000000,
  gstAmount: 180000,
  irn: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
  status: 'Generated',
  windowType: '3-day',
  daysRemaining: 2,
  invoiceDate: '01 Mar 2026',
  qrGenerated: true,
);

const _pendingRecord = EinvoiceRecord(
  id: 'test-002',
  clientName: 'Pending Seller Ltd',
  invoiceNumber: 'INV-TEST-0002',
  buyerName: 'Pending Buyer Corp',
  invoiceValue: 500000,
  gstAmount: 90000,
  irn: '0000000000000000000000000000000000000000000000000000000000000000',
  status: 'Pending',
  windowType: '30-day',
  daysRemaining: 20,
  invoiceDate: '15 Feb 2026',
  qrGenerated: false,
);

const _cancelledRecord = EinvoiceRecord(
  id: 'test-003',
  clientName: 'Cancelled Seller Ltd',
  invoiceNumber: 'INV-TEST-0003',
  buyerName: 'Cancelled Buyer Corp',
  invoiceValue: 750000,
  gstAmount: 135000,
  irn: '1111111111111111111111111111111111111111111111111111111111111111',
  status: 'Cancelled',
  windowType: '3-day',
  daysRemaining: 0,
  invoiceDate: '01 Mar 2026',
  qrGenerated: false,
);

List<dynamic> _overrideWith(List<EinvoiceRecord> records) => [
  allEinvoiceRecordsProvider.overrideWithValue(records),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EinvoiceDetailScreen', () {
    testWidgets('renders without crashing for Generated invoice', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows invoice number in AppBar for found record', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('INV-TEST-0001'), findsWidgets);
    });

    testWidgets('shows Generated status badge', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('Generated'), findsWidgets);
    });

    testWidgets('shows IRN Details card for Generated invoice', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('IRN Details'), findsOneWidget);
    });

    testWidgets('shows QR Code Generated badge when qrGenerated is true', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('QR Code Generated'), findsOneWidget);
    });

    testWidgets('shows Parties section with Seller and Buyer', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('Parties'), findsOneWidget);
      expect(find.text('Seller'), findsOneWidget);
      expect(find.text('Buyer'), findsOneWidget);
    });

    testWidgets('shows client name and buyer name in party details', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('Test Seller Ltd'), findsWidgets);
      expect(find.text('Test Buyer Corp'), findsWidgets);
    });

    testWidgets('shows Line Items section header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('Line Items'), findsOneWidget);
    });

    testWidgets('shows Grand Total in totals card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      await tester.scrollUntilVisible(find.text('Grand Total'), 100);
      expect(find.text('Grand Total'), findsOneWidget);
    });

    testWidgets('shows Generate IRN button for Pending invoice', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-002'),
        overrides: _overrideWith([_pendingRecord]),
      );
      await tester.scrollUntilVisible(find.text('Generate IRN'), 100);
      expect(find.text('Generate IRN'), findsOneWidget);
    });

    testWidgets('does not show IRN Details for Pending invoice', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-002'),
        overrides: _overrideWith([_pendingRecord]),
      );
      expect(find.text('IRN Details'), findsNothing);
    });

    testWidgets('shows Cancel IRN button for Generated invoice', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      await tester.scrollUntilVisible(find.text('Cancel IRN'), 100);
      expect(find.text('Cancel IRN'), findsWidgets);
    });

    testWidgets('shows Invoice Not Found screen when id is missing', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'nonexistent'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.text('Invoice Not Found'), findsOneWidget);
    });

    testWidgets('shows Cancelled status in timeline for cancelled invoice', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-003'),
        overrides: _overrideWith([_cancelledRecord]),
      );
      expect(find.text('Cancelled'), findsWidgets);
    });

    testWidgets('shows mock line item description', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const EinvoiceDetailScreen(invoiceId: 'test-001'),
        overrides: _overrideWith([_generatedRecord]),
      );
      expect(find.textContaining('Laptop'), findsOneWidget);
    });
  });
}
