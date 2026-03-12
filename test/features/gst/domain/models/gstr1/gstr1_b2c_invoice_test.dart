import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('B2cCategory enum', () {
    test('large → has correct label', () {
      expect(B2cCategory.large.label, 'B2CL');
    });

    test('small → has correct label', () {
      expect(B2cCategory.small.label, 'B2CS');
    });
  });

  group('Gstr1B2cInvoice', () {
    Gstr1B2cInvoice createInvoice({
      String? invoiceNumber = 'INV-B2C-001',
      DateTime? invoiceDate,
      String? recipientName = 'End Consumer',
      String placeOfSupply = '29',
      bool isInterState = true,
      double taxableValue = 300000.0,
      double igst = 54000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      double gstRate = 18.0,
      B2cCategory category = B2cCategory.large,
    }) {
      return Gstr1B2cInvoice(
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate ?? DateTime(2026, 1, 20),
        recipientName: recipientName,
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        taxableValue: taxableValue,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        gstRate: gstRate,
        category: category,
      );
    }

    test('creates with correct field values for B2CL (large)', () {
      final inv = createInvoice();
      expect(inv.invoiceNumber, 'INV-B2C-001');
      expect(inv.recipientName, 'End Consumer');
      expect(inv.placeOfSupply, '29');
      expect(inv.isInterState, true);
      expect(inv.taxableValue, 300000.0);
      expect(inv.igst, 54000.0);
      expect(inv.cgst, 0.0);
      expect(inv.sgst, 0.0);
      expect(inv.cess, 0.0);
      expect(inv.gstRate, 18.0);
      expect(inv.category, B2cCategory.large);
    });

    test('creates B2CS with null invoiceNumber', () {
      final inv = createInvoice(
        invoiceNumber: null,
        isInterState: false,
        taxableValue: 50000.0,
        igst: 0,
        cgst: 4500,
        sgst: 4500,
        category: B2cCategory.small,
      );
      expect(inv.invoiceNumber, isNull);
      expect(inv.category, B2cCategory.small);
    });

    test('totalTax → sum of all tax components', () {
      final inv = createInvoice(igst: 0, cgst: 27000, sgst: 27000, cess: 1000);
      expect(inv.totalTax, 55000.0);
    });

    test('invoiceValue → taxableValue + totalTax', () {
      final inv = createInvoice(taxableValue: 300000, igst: 54000);
      expect(inv.invoiceValue, 354000.0);
    });

    test('copyWith → updates selected fields only', () {
      final original = createInvoice();
      final updated = original.copyWith(
        taxableValue: 500000.0,
        igst: 90000.0,
        category: B2cCategory.large,
      );
      expect(updated.taxableValue, 500000.0);
      expect(updated.igst, 90000.0);
      expect(updated.placeOfSupply, original.placeOfSupply);
    });

    test('equality → equal when same invoiceNumber and placeOfSupply', () {
      final a = createInvoice(taxableValue: 300000.0);
      final b = createInvoice(taxableValue: 400000.0);
      expect(a, equals(b));
    });

    test('equality → not equal when different placeOfSupply', () {
      final a = createInvoice(placeOfSupply: '27');
      final b = createInvoice(placeOfSupply: '29');
      expect(a, isNot(equals(b)));
    });
  });
}
