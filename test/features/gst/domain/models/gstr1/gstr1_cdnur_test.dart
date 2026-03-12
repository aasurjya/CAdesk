import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnur.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CdnurType enum', () {
    test('b2cl → has correct label', () {
      expect(CdnurType.b2cl.label, 'B2CL');
    });

    test('exports → has correct label', () {
      expect(CdnurType.exports.label, 'EXPWP');
    });

    test('exportsWithoutPayment → has correct label', () {
      expect(CdnurType.exportsWithoutPayment.label, 'EXPWOP');
    });
  });

  group('Gstr1Cdnur', () {
    Gstr1Cdnur createCdnur({
      String noteNumber = 'CN-UR-001',
      DateTime? noteDate,
      CdnurType noteType = CdnurType.b2cl,
      String? recipientName = 'Unregistered Buyer',
      String placeOfSupply = '29',
      bool isInterState = true,
      double taxableValue = 300000.0,
      double igst = 54000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      double gstRate = 18.0,
      bool preGst = false,
      String? originalInvoiceNumber = 'INV-001',
      DateTime? originalInvoiceDate,
    }) {
      return Gstr1Cdnur(
        noteNumber: noteNumber,
        noteDate: noteDate ?? DateTime(2026, 2, 10),
        noteType: noteType,
        recipientName: recipientName,
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        taxableValue: taxableValue,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        gstRate: gstRate,
        preGst: preGst,
        originalInvoiceNumber: originalInvoiceNumber,
        originalInvoiceDate: originalInvoiceDate ?? DateTime(2026, 1, 15),
      );
    }

    test('creates with correct field values', () {
      final cdnur = createCdnur();
      expect(cdnur.noteNumber, 'CN-UR-001');
      expect(cdnur.noteType, CdnurType.b2cl);
      expect(cdnur.recipientName, 'Unregistered Buyer');
      expect(cdnur.placeOfSupply, '29');
      expect(cdnur.isInterState, true);
      expect(cdnur.taxableValue, 300000.0);
      expect(cdnur.igst, 54000.0);
      expect(cdnur.gstRate, 18.0);
      expect(cdnur.preGst, false);
    });

    test('totalTax → sum of all tax components', () {
      final cdnur = createCdnur(igst: 54000, cess: 2000);
      expect(cdnur.totalTax, 56000.0);
    });

    test('noteValue → taxableValue + totalTax', () {
      final cdnur = createCdnur(taxableValue: 300000, igst: 54000);
      expect(cdnur.noteValue, 354000.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createCdnur();
      final updated = original.copyWith(
        noteType: CdnurType.exports,
        taxableValue: 500000.0,
      );
      expect(updated.noteType, CdnurType.exports);
      expect(updated.taxableValue, 500000.0);
      expect(updated.noteNumber, original.noteNumber);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createCdnur();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('equality → equal when same noteNumber', () {
      final a = createCdnur(taxableValue: 300000.0);
      final b = createCdnur(taxableValue: 400000.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different noteNumber', () {
      final a = createCdnur(noteNumber: 'CN-UR-001');
      final b = createCdnur(noteNumber: 'CN-UR-002');
      expect(a, isNot(equals(b)));
    });
  });
}
