import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr3bTaxRow', () {
    Gstr3bTaxRow createRow({
      double igst = 10000.0,
      double cgst = 5000.0,
      double sgst = 5000.0,
      double cess = 0.0,
    }) {
      return Gstr3bTaxRow(igst: igst, cgst: cgst, sgst: sgst, cess: cess);
    }

    test('creates with correct field values', () {
      final row = createRow();
      expect(row.igst, 10000.0);
      expect(row.cgst, 5000.0);
      expect(row.sgst, 5000.0);
      expect(row.cess, 0.0);
    });

    test('totalTax → igst + cgst + sgst + cess', () {
      final row = createRow(igst: 10000, cgst: 5000, sgst: 5000, cess: 500);
      expect(row.totalTax, 20500.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createRow();
      final updated = original.copyWith(igst: 20000.0, cess: 1000.0);
      expect(updated.igst, 20000.0);
      expect(updated.cess, 1000.0);
      expect(updated.cgst, original.cgst);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createRow();
      final copy = original.copyWith();
      expect(copy, equals(original));
      expect(copy.hashCode, original.hashCode);
    });

    test('equality → equal when all tax amounts match', () {
      final a = createRow();
      final b = createRow();
      expect(a, equals(b));
    });

    test('equality → not equal when igst differs', () {
      final a = createRow(igst: 10000);
      final b = createRow(igst: 20000);
      expect(a, isNot(equals(b)));
    });
  });

  group('Gstr3bTaxLiability', () {
    final zeroRow = Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

    Gstr3bTaxLiability createLiability({
      Gstr3bTaxRow? outwardTaxable,
      Gstr3bTaxRow? outwardZeroRated,
      Gstr3bTaxRow? otherOutward,
      Gstr3bTaxRow? inwardRcm,
      Gstr3bTaxRow? nonGstOutward,
    }) {
      return Gstr3bTaxLiability(
        outwardTaxable:
            outwardTaxable ??
            Gstr3bTaxRow(igst: 18000, cgst: 9000, sgst: 9000, cess: 0),
        outwardZeroRated: outwardZeroRated ?? zeroRow,
        otherOutward: otherOutward ?? zeroRow,
        inwardRcm:
            inwardRcm ?? Gstr3bTaxRow(igst: 0, cgst: 1800, sgst: 1800, cess: 0),
        nonGstOutward: nonGstOutward ?? zeroRow,
      );
    }

    test('creates with correct field values', () {
      final liability = createLiability();
      expect(liability.outwardTaxable.igst, 18000.0);
      expect(liability.outwardTaxable.cgst, 9000.0);
      expect(liability.inwardRcm.cgst, 1800.0);
    });

    test('totalIgst → sum of IGST across all rows', () {
      final liability = createLiability();
      // outwardTaxable: 18000, rest: 0
      expect(liability.totalIgst, 18000.0);
    });

    test('totalCgst → sum of CGST across all rows', () {
      final liability = createLiability();
      // outwardTaxable: 9000, inwardRcm: 1800
      expect(liability.totalCgst, 10800.0);
    });

    test('totalSgst → sum of SGST across all rows', () {
      final liability = createLiability();
      expect(liability.totalSgst, 10800.0);
    });

    test('totalCess → sum of CESS across all rows', () {
      final liability = createLiability();
      expect(liability.totalCess, 0.0);
    });

    test('totalTaxLiability → sum of all tax components', () {
      final liability = createLiability();
      // 18000 + 9000 + 9000 + 1800 + 1800 = 39600
      expect(liability.totalTaxLiability, 39600.0);
    });

    test('copyWith → returns new instance with updated rows', () {
      final original = createLiability();
      final newRow = Gstr3bTaxRow(
        igst: 36000,
        cgst: 18000,
        sgst: 18000,
        cess: 0,
      );
      final updated = original.copyWith(outwardTaxable: newRow);
      expect(updated.outwardTaxable.igst, 36000.0);
      expect(updated.inwardRcm, original.inwardRcm);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createLiability();
      final copy = original.copyWith();
      expect(copy.outwardTaxable, original.outwardTaxable);
    });

    test('equality → equal when all rows match', () {
      final a = createLiability();
      final b = createLiability();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
