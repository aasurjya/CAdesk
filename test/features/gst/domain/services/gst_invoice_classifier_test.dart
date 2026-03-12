import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/gst/domain/services/gst_invoice_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvoiceClassification enum', () {
    test('b2b → has correct label', () {
      expect(InvoiceClassification.b2b.label, 'B2B');
    });

    test('b2cLarge → has correct label', () {
      expect(InvoiceClassification.b2cLarge.label, 'B2CL');
    });

    test('b2cSmall → has correct label', () {
      expect(InvoiceClassification.b2cSmall.label, 'B2CS');
    });

    test('exportWithPayment → has correct label', () {
      expect(InvoiceClassification.exportWithPayment.label, 'EXP-WPAY');
    });

    test('exportWithoutPayment → has correct label', () {
      expect(InvoiceClassification.exportWithoutPayment.label, 'EXP-WOPAY');
    });
  });

  group('GstInvoiceClassifier.classify', () {
    GstInvoice createInvoice({
      String invoiceNumber = 'INV-001',
      String? buyerGstin,
      String placeOfSupply = '29',
      String supplierStateCode = '27',
      bool isInterState = true,
      bool isExport = false,
      bool reverseCharge = false,
      double taxableValue = 100000.0,
      double igst = 18000.0,
    }) {
      final item = GstInvoiceItem(
        description: 'Product',
        hsnSacCode: '8471',
        itemType: InvoiceItemType.goods,
        quantity: 1,
        unit: 'NOS',
        unitPrice: taxableValue,
        taxableValue: taxableValue,
        gstRate: 18.0,
        igst: igst,
        cgst: 0.0,
        sgst: 0.0,
        cess: 0.0,
      );
      return GstInvoice(
        id: 'ID-001',
        invoiceNumber: invoiceNumber,
        invoiceDate: DateTime(2026, 1, 15),
        supplierGstin: '27AABCU9603R1ZM',
        supplierName: 'Supplier Co',
        supplierStateCode: supplierStateCode,
        buyerGstin: buyerGstin,
        buyerName: 'Customer',
        buyerStateCode: placeOfSupply,
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        reverseCharge: reverseCharge,
        isExport: isExport,
        invoiceType: 'Regular',
        items: [item],
      );
    }

    test('export → classifies as exportWithPayment when IGST paid', () {
      final inv = createInvoice(
        isExport: true,
        igst: 144000,
        taxableValue: 800000,
      );
      final result = GstInvoiceClassifier.classify(inv);
      expect(result, InvoiceClassification.exportWithPayment);
    });

    test('export → classifies as exportWithoutPayment when IGST is zero', () {
      final inv = createInvoice(isExport: true, igst: 0, taxableValue: 800000);
      final result = GstInvoiceClassifier.classify(inv);
      expect(result, InvoiceClassification.exportWithoutPayment);
    });

    test('B2B → classifies as b2b when buyer GSTIN present', () {
      final inv = createInvoice(
        buyerGstin: '29AABCU9603R1ZM',
        taxableValue: 100000,
      );
      final result = GstInvoiceClassifier.classify(inv);
      expect(result, InvoiceClassification.b2b);
    });

    test('B2CL → inter-state, no GSTIN, value > 2.5L', () {
      final inv = createInvoice(
        buyerGstin: null,
        isInterState: true,
        taxableValue: 300000,
      );
      final result = GstInvoiceClassifier.classify(inv);
      expect(result, InvoiceClassification.b2cLarge);
    });

    test('B2CS → inter-state, no GSTIN, value <= 2.5L', () {
      final inv = createInvoice(
        buyerGstin: null,
        isInterState: true,
        taxableValue: 200000,
        igst: 36000,
      );
      final result = GstInvoiceClassifier.classify(inv);
      expect(result, InvoiceClassification.b2cSmall);
    });

    test('B2CS → intra-state, no GSTIN regardless of value', () {
      final inv = createInvoice(
        buyerGstin: null,
        isInterState: false,
        taxableValue: 500000,
        placeOfSupply: '27',
        igst: 0,
      );
      final result = GstInvoiceClassifier.classify(inv);
      expect(result, InvoiceClassification.b2cSmall);
    });

    test('B2CS → exactly 2.5L → classifies as b2cSmall', () {
      final inv = createInvoice(
        buyerGstin: null,
        isInterState: true,
        taxableValue: 250000,
        igst: 45000,
      );
      final result = GstInvoiceClassifier.classify(inv);
      expect(result, InvoiceClassification.b2cSmall);
    });

    test('classifyAll → returns map of invoice → classification', () {
      final b2bInv = createInvoice(buyerGstin: '29AABCU9603R1ZM');
      final b2clInv = createInvoice(
        invoiceNumber: 'INV-002',
        buyerGstin: null,
        isInterState: true,
        taxableValue: 300000,
      );
      final results = GstInvoiceClassifier.classifyAll([b2bInv, b2clInv]);
      expect(results[b2bInv], InvoiceClassification.b2b);
      expect(results[b2clInv], InvoiceClassification.b2cLarge);
    });
  });
}
