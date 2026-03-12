import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CdnrNoteType enum', () {
    test('creditNote → has correct label', () {
      expect(CdnrNoteType.creditNote.label, 'Credit Note');
    });

    test('debitNote → has correct label', () {
      expect(CdnrNoteType.debitNote.label, 'Debit Note');
    });
  });

  group('Gstr1Cdnr', () {
    Gstr1Cdnr createCdnr({
      String noteNumber = 'CN-001',
      DateTime? noteDate,
      CdnrNoteType noteType = CdnrNoteType.creditNote,
      String recipientGstin = '29AABCU9603R1ZM',
      String recipientName = 'Buyer Corp',
      String originalInvoiceNumber = 'INV-001',
      DateTime? originalInvoiceDate,
      String placeOfSupply = '29',
      bool isInterState = true,
      double taxableValue = 10000.0,
      double igst = 1800.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      double gstRate = 18.0,
      bool preGst = false,
    }) {
      return Gstr1Cdnr(
        noteNumber: noteNumber,
        noteDate: noteDate ?? DateTime(2026, 2, 5),
        noteType: noteType,
        recipientGstin: recipientGstin,
        recipientName: recipientName,
        originalInvoiceNumber: originalInvoiceNumber,
        originalInvoiceDate: originalInvoiceDate ?? DateTime(2026, 1, 15),
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        taxableValue: taxableValue,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        gstRate: gstRate,
        preGst: preGst,
      );
    }

    test('creates with correct field values', () {
      final cdnr = createCdnr();
      expect(cdnr.noteNumber, 'CN-001');
      expect(cdnr.noteType, CdnrNoteType.creditNote);
      expect(cdnr.recipientGstin, '29AABCU9603R1ZM');
      expect(cdnr.recipientName, 'Buyer Corp');
      expect(cdnr.originalInvoiceNumber, 'INV-001');
      expect(cdnr.placeOfSupply, '29');
      expect(cdnr.isInterState, true);
      expect(cdnr.taxableValue, 10000.0);
      expect(cdnr.igst, 1800.0);
      expect(cdnr.gstRate, 18.0);
      expect(cdnr.preGst, false);
    });

    test('totalTax → sum of all tax components', () {
      final cdnr = createCdnr(igst: 0, cgst: 900, sgst: 900, cess: 100);
      expect(cdnr.totalTax, 1900.0);
    });

    test('noteValue → taxableValue + totalTax', () {
      final cdnr = createCdnr(taxableValue: 10000, igst: 1800);
      expect(cdnr.noteValue, 11800.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createCdnr();
      final updated = original.copyWith(
        noteType: CdnrNoteType.debitNote,
        taxableValue: 20000.0,
        igst: 3600.0,
      );
      expect(updated.noteType, CdnrNoteType.debitNote);
      expect(updated.taxableValue, 20000.0);
      expect(updated.igst, 3600.0);
      expect(updated.noteNumber, original.noteNumber);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createCdnr();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('equality → equal when same noteNumber and recipientGstin', () {
      final a = createCdnr(taxableValue: 10000.0);
      final b = createCdnr(taxableValue: 20000.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different noteNumber', () {
      final a = createCdnr(noteNumber: 'CN-001');
      final b = createCdnr(noteNumber: 'CN-002');
      expect(a, isNot(equals(b)));
    });

    test('debit note → creates correctly', () {
      final dn = createCdnr(
        noteNumber: 'DN-001',
        noteType: CdnrNoteType.debitNote,
      );
      expect(dn.noteType, CdnrNoteType.debitNote);
      expect(dn.noteNumber, 'DN-001');
    });
  });
}
