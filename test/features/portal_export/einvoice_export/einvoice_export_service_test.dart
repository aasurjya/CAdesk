import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_export_result.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/einvoice_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _sellerGstin = '27AABCE1234F1Z5';
const _buyerGstin = '29AABCE9999K1Z2';

GstInvoiceItem _buildInvoiceItem({
  String description = 'IT Services',
  String hsnSacCode = '998314',
  double taxableValue = 100000.0,
  double gstRate = 18.0,
}) {
  return GstInvoiceItem(
    description: description,
    hsnSacCode: hsnSacCode,
    itemType: InvoiceItemType.services,
    quantity: 1,
    unit: 'NOS',
    unitPrice: taxableValue,
    taxableValue: taxableValue,
    gstRate: gstRate,
    igst: taxableValue * gstRate / 100,
    cgst: 0,
    sgst: 0,
    cess: 0,
  );
}

GstInvoice _buildMinimalInvoice({
  String invoiceNumber = 'INV/2024/001',
  List<GstInvoiceItem>? items,
  String? overrideBuyerGstin = _buyerGstin,
}) {
  return GstInvoice(
    id: 'test-inv-001',
    invoiceNumber: invoiceNumber,
    invoiceDate: DateTime(2024, 3, 15),
    supplierGstin: _sellerGstin,
    supplierName: 'Acme Tech Pvt Ltd',
    supplierStateCode: '27',
    buyerGstin: overrideBuyerGstin,
    buyerName: 'Beta Corp',
    buyerStateCode: '29',
    placeOfSupply: '29',
    isInterState: true,
    reverseCharge: false,
    isExport: false,
    invoiceType: 'Regular',
    items: items ?? [_buildInvoiceItem()],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EinvoiceExportService', () {
    // ── Feature flag ─────────────────────────────────────────────────────────

    group('featureFlag', () {
      test('has non-empty static featureFlag constant', () {
        expect(EinvoiceExportService.featureFlag, isNotEmpty);
        expect(EinvoiceExportService.featureFlag, 'einvoice_export_enabled');
      });
    });

    // ── validate ─────────────────────────────────────────────────────────────

    group('validate', () {
      test('returns empty errors for valid invoice', () {
        final invoice = _buildMinimalInvoice();
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(errors, isEmpty);
      });

      test('returns error for invalid seller GSTIN', () {
        final invoice = _buildMinimalInvoice();
        final errors = EinvoiceExportService.validate(
          invoice,
          'BADGSTIN',
          _buyerGstin,
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('seller')), isTrue);
      });

      test('returns error for invalid buyer GSTIN', () {
        final invoice = _buildMinimalInvoice();
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          'BADGSTIN',
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('buyer')), isTrue);
      });

      test('returns error for invalid invoice number (too long)', () {
        final invoice = _buildMinimalInvoice(
          invoiceNumber: 'INV' * 20, // > 16 chars
        );
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('invoice number')), isTrue);
      });

      test('returns error for empty items list', () {
        final invoice = _buildMinimalInvoice(items: const []);
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('line item')), isTrue);
      });

      test('returns error for item with invalid HSN code (3 digits)', () {
        final invoice = _buildMinimalInvoice(
          items: [_buildInvoiceItem(hsnSacCode: '123')],
        );
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(errors, isNotEmpty);
        expect(
          errors.any((e) => e.contains('HSN') || e.contains('SAC')),
          isTrue,
        );
      });

      test('accepts 4-digit HSN code', () {
        final invoice = _buildMinimalInvoice(
          items: [_buildInvoiceItem(hsnSacCode: '9983')],
        );
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(errors.any((e) => e.contains('HSN')), isFalse);
      });

      test('accepts 6-digit HSN code', () {
        final invoice = _buildMinimalInvoice(
          items: [_buildInvoiceItem(hsnSacCode: '998314')],
        );
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(errors.any((e) => e.contains('HSN')), isFalse);
      });

      test('accepts 8-digit HSN code', () {
        final invoice = _buildMinimalInvoice(
          items: [_buildInvoiceItem(hsnSacCode: '99831401')],
        );
        final errors = EinvoiceExportService.validate(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(errors.any((e) => e.contains('HSN')), isFalse);
      });
    });

    // ── export — valid data ───────────────────────────────────────────────────

    group('export — valid data', () {
      late GstInvoice invoice;
      late EInvoiceExportResult result;

      setUp(() {
        invoice = _buildMinimalInvoice();
        result = EinvoiceExportService.export(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
      });

      test('result is valid', () {
        expect(result.isValid, isTrue);
      });

      test('result has no validation errors', () {
        expect(result.validationErrors, isEmpty);
      });

      test('result has non-empty request payload', () {
        expect(result.requestPayload, isNotEmpty);
      });

      test('request payload is valid JSON', () {
        expect(() => jsonDecode(result.requestPayload), returnsNormally);
      });

      test('exportedAt is recent', () {
        final before = DateTime.now().subtract(const Duration(seconds: 5));
        expect(result.exportedAt.isAfter(before), isTrue);
      });

      test('isSubmitted is false (no IRP response yet)', () {
        expect(result.isSubmitted, isFalse);
      });
    });

    // ── export — JSON schema ──────────────────────────────────────────────────

    group('export — JSON schema fields (NIC v1.03)', () {
      late Map<String, dynamic> decoded;

      setUp(() {
        final invoice = _buildMinimalInvoice();
        final result = EinvoiceExportService.export(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        decoded = jsonDecode(result.requestPayload) as Map<String, dynamic>;
      });

      test('payload contains Version field', () {
        expect(decoded.containsKey('Version'), isTrue);
      });

      test('payload contains TranDtls (transaction details)', () {
        expect(decoded.containsKey('TranDtls'), isTrue);
      });

      test('payload contains DocDtls (document details)', () {
        expect(decoded.containsKey('DocDtls'), isTrue);
      });

      test('payload contains SellerDtls', () {
        expect(decoded.containsKey('SellerDtls'), isTrue);
      });

      test('payload contains BuyerDtls', () {
        expect(decoded.containsKey('BuyerDtls'), isTrue);
      });

      test('payload contains ItemList', () {
        expect(decoded.containsKey('ItemList'), isTrue);
        expect(decoded['ItemList'], isA<List>());
        expect((decoded['ItemList'] as List).isNotEmpty, isTrue);
      });

      test('payload contains ValDtls (value details)', () {
        expect(decoded.containsKey('ValDtls'), isTrue);
      });

      test('SellerDtls has seller GSTIN', () {
        final seller = decoded['SellerDtls'] as Map<String, dynamic>;
        expect(seller['Gstin'], _sellerGstin);
      });

      test('BuyerDtls has buyer GSTIN', () {
        final buyer = decoded['BuyerDtls'] as Map<String, dynamic>;
        expect(buyer['Gstin'], _buyerGstin);
      });
    });

    // ── export — invalid seller/buyer GSTINs ─────────────────────────────────

    group('export — invalid GSTINs', () {
      test('result is invalid for bad seller GSTIN', () {
        final invoice = _buildMinimalInvoice();
        final result = EinvoiceExportService.export(
          invoice,
          'BADGSTIN',
          _buyerGstin,
        );
        expect(result.isValid, isFalse);
        expect(result.validationErrors, isNotEmpty);
      });

      test('result is invalid for bad buyer GSTIN', () {
        final invoice = _buildMinimalInvoice();
        final result = EinvoiceExportService.export(
          invoice,
          _sellerGstin,
          'BAD',
        );
        expect(result.isValid, isFalse);
        expect(result.validationErrors, isNotEmpty);
      });
    });

    // ── export — empty items ──────────────────────────────────────────────────

    group('export — empty items', () {
      test('result is invalid when invoice has no items', () {
        final invoice = _buildMinimalInvoice(items: const []);
        final result = EinvoiceExportService.export(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        expect(result.isValid, isFalse);
      });
    });

    // ── export — multiple items ───────────────────────────────────────────────

    group('export — multiple line items', () {
      test('ItemList has same count as invoice items', () {
        final invoice = _buildMinimalInvoice(
          items: [
            _buildInvoiceItem(description: 'Item A', taxableValue: 50000),
            _buildInvoiceItem(
              description: 'Item B',
              taxableValue: 30000,
              gstRate: 12,
            ),
          ],
        );
        final result = EinvoiceExportService.export(
          invoice,
          _sellerGstin,
          _buyerGstin,
        );
        final decoded =
            jsonDecode(result.requestPayload) as Map<String, dynamic>;
        expect((decoded['ItemList'] as List).length, 2);
      });
    });
  });
}
