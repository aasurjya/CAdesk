import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr1B2bInvoice', () {
    Gstr1B2bInvoice createInvoice({
      String invoiceNumber = 'INV-001',
      DateTime? invoiceDate,
      String recipientGstin = '29AABCU9603R1ZM',
      String recipientName = 'Buyer Corp',
      String placeOfSupply = '29',
      bool isInterState = true,
      double taxableValue = 100000.0,
      double igst = 18000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      double gstRate = 18.0,
      String invoiceType = 'Regular',
      bool reverseCharge = false,
    }) {
      return Gstr1B2bInvoice(
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate ?? DateTime(2026, 1, 15),
        recipientGstin: recipientGstin,
        recipientName: recipientName,
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        taxableValue: taxableValue,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        gstRate: gstRate,
        invoiceType: invoiceType,
        reverseCharge: reverseCharge,
      );
    }

    test('creates with correct field values', () {
      final inv = createInvoice();
      expect(inv.invoiceNumber, 'INV-001');
      expect(inv.recipientGstin, '29AABCU9603R1ZM');
      expect(inv.recipientName, 'Buyer Corp');
      expect(inv.placeOfSupply, '29');
      expect(inv.isInterState, true);
      expect(inv.taxableValue, 100000.0);
      expect(inv.igst, 18000.0);
      expect(inv.cgst, 0.0);
      expect(inv.sgst, 0.0);
      expect(inv.cess, 0.0);
      expect(inv.gstRate, 18.0);
      expect(inv.invoiceType, 'Regular');
      expect(inv.reverseCharge, false);
    });

    test('totalTax → sum of igst + cgst + sgst + cess', () {
      final inv = createInvoice(igst: 0, cgst: 9000, sgst: 9000, cess: 500);
      expect(inv.totalTax, 18500.0);
    });

    test('invoiceValue → taxableValue + totalTax', () {
      final inv = createInvoice(
        taxableValue: 100000,
        igst: 18000,
        cgst: 0,
        sgst: 0,
        cess: 0,
      );
      expect(inv.invoiceValue, 118000.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createInvoice();
      final updated = original.copyWith(
        taxableValue: 200000.0,
        igst: 36000.0,
        reverseCharge: true,
      );
      expect(updated.taxableValue, 200000.0);
      expect(updated.igst, 36000.0);
      expect(updated.reverseCharge, true);
      // Unchanged
      expect(updated.invoiceNumber, original.invoiceNumber);
      expect(updated.recipientGstin, original.recipientGstin);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createInvoice();
      final copy = original.copyWith();
      expect(copy, equals(original));
      expect(copy.hashCode, original.hashCode);
    });

    test('equality → equal when same invoiceNumber and recipientGstin', () {
      final a = createInvoice(taxableValue: 100.0);
      final b = createInvoice(taxableValue: 200.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different invoiceNumber', () {
      final a = createInvoice(invoiceNumber: 'INV-001');
      final b = createInvoice(invoiceNumber: 'INV-002');
      expect(a, isNot(equals(b)));
    });

    test('equality → not equal when different recipientGstin', () {
      final a = createInvoice(recipientGstin: '27AABCU9603R1ZM');
      final b = createInvoice(recipientGstin: '29AABCU9603R1ZN');
      expect(a, isNot(equals(b)));
    });

    test('intra-state invoice → CGST+SGST, not inter-state', () {
      final inv = createInvoice(
        isInterState: false,
        igst: 0,
        cgst: 9000,
        sgst: 9000,
      );
      expect(inv.isInterState, false);
      expect(inv.cgst, 9000.0);
      expect(inv.sgst, 9000.0);
      expect(inv.igst, 0.0);
    });
  });
}
