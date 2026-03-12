import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_at.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr1At (Advance Tax Liability)', () {
    Gstr1At createAt({
      String receiptVoucherNumber = 'RV-001',
      DateTime? receiptDate,
      String? recipientGstin,
      String? recipientName = 'Customer A',
      String placeOfSupply = '27',
      bool isInterState = false,
      double advanceAmount = 100000.0,
      double igst = 0.0,
      double cgst = 9000.0,
      double sgst = 9000.0,
      double cess = 0.0,
      double gstRate = 18.0,
    }) {
      return Gstr1At(
        receiptVoucherNumber: receiptVoucherNumber,
        receiptDate: receiptDate ?? DateTime(2026, 1, 10),
        recipientGstin: recipientGstin,
        recipientName: recipientName,
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        advanceAmount: advanceAmount,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        gstRate: gstRate,
      );
    }

    test('creates with correct field values', () {
      final at = createAt();
      expect(at.receiptVoucherNumber, 'RV-001');
      expect(at.receiptDate, DateTime(2026, 1, 10));
      expect(at.recipientGstin, isNull);
      expect(at.recipientName, 'Customer A');
      expect(at.placeOfSupply, '27');
      expect(at.isInterState, false);
      expect(at.advanceAmount, 100000.0);
      expect(at.igst, 0.0);
      expect(at.cgst, 9000.0);
      expect(at.sgst, 9000.0);
      expect(at.cess, 0.0);
      expect(at.gstRate, 18.0);
    });

    test('totalTax → igst + cgst + sgst + cess', () {
      final at = createAt(igst: 0, cgst: 9000, sgst: 9000, cess: 500);
      expect(at.totalTax, 18500.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createAt();
      final updated = original.copyWith(
        advanceAmount: 200000.0,
        cgst: 18000.0,
        sgst: 18000.0,
      );
      expect(updated.advanceAmount, 200000.0);
      expect(updated.cgst, 18000.0);
      expect(updated.sgst, 18000.0);
      expect(updated.receiptVoucherNumber, original.receiptVoucherNumber);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createAt();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('equality → equal when same receiptVoucherNumber', () {
      final a = createAt(advanceAmount: 100000.0);
      final b = createAt(advanceAmount: 200000.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different receiptVoucherNumber', () {
      final a = createAt(receiptVoucherNumber: 'RV-001');
      final b = createAt(receiptVoucherNumber: 'RV-002');
      expect(a, isNot(equals(b)));
    });

    test('inter-state advance → IGST', () {
      final at = createAt(
        isInterState: true,
        igst: 18000,
        cgst: 0,
        sgst: 0,
        placeOfSupply: '29',
      );
      expect(at.isInterState, true);
      expect(at.igst, 18000.0);
      expect(at.cgst, 0.0);
    });
  });
}
