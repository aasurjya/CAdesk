import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItcRow', () {
    ItcRow createRow({
      double igst = 5000.0,
      double cgst = 2500.0,
      double sgst = 2500.0,
      double cess = 0.0,
    }) {
      return ItcRow(igst: igst, cgst: cgst, sgst: sgst, cess: cess);
    }

    test('creates with correct field values', () {
      final row = createRow();
      expect(row.igst, 5000.0);
      expect(row.cgst, 2500.0);
      expect(row.sgst, 2500.0);
      expect(row.cess, 0.0);
    });

    test('totalItc → igst + cgst + sgst + cess', () {
      final row = createRow(igst: 5000, cgst: 2500, sgst: 2500, cess: 250);
      expect(row.totalItc, 10250.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createRow();
      final updated = original.copyWith(igst: 10000.0);
      expect(updated.igst, 10000.0);
      expect(updated.cgst, original.cgst);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createRow();
      final copy = original.copyWith();
      expect(copy, equals(original));
      expect(copy.hashCode, original.hashCode);
    });

    test('equality → equal when all amounts match', () {
      final a = createRow();
      final b = createRow();
      expect(a, equals(b));
    });

    test('equality → not equal when cgst differs', () {
      final a = createRow(cgst: 2500);
      final b = createRow(cgst: 3000);
      expect(a, isNot(equals(b)));
    });
  });

  group('Gstr3bItcClaimed', () {
    final zeroRow = ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

    Gstr3bItcClaimed createItc({
      ItcRow? importGoods,
      ItcRow? importServices,
      ItcRow? inwardRcm,
      ItcRow? isd,
      ItcRow? otherItc,
      ItcRow? reversedSection17_5,
      ItcRow? reversedOthers,
      ItcRow? netItcAvailable,
      ItcRow? ineligibleRule38,
      ItcRow? ineligibleOthers,
    }) {
      return Gstr3bItcClaimed(
        importGoods: importGoods ?? zeroRow,
        importServices: importServices ?? zeroRow,
        inwardRcm:
            inwardRcm ?? ItcRow(igst: 0, cgst: 1800, sgst: 1800, cess: 0),
        isd: isd ?? zeroRow,
        otherItc:
            otherItc ?? ItcRow(igst: 18000, cgst: 9000, sgst: 9000, cess: 0),
        reversedSection17_5:
            reversedSection17_5 ??
            ItcRow(igst: 0, cgst: 1000, sgst: 1000, cess: 0),
        reversedOthers: reversedOthers ?? zeroRow,
        netItcAvailable:
            netItcAvailable ??
            ItcRow(igst: 18000, cgst: 9800, sgst: 9800, cess: 0),
        ineligibleRule38: ineligibleRule38 ?? zeroRow,
        ineligibleOthers: ineligibleOthers ?? zeroRow,
      );
    }

    test('creates with correct field values', () {
      final itc = createItc();
      expect(itc.importGoods.igst, 0.0);
      expect(itc.inwardRcm.cgst, 1800.0);
      expect(itc.otherItc.igst, 18000.0);
      expect(itc.reversedSection17_5.cgst, 1000.0);
      expect(itc.netItcAvailable.igst, 18000.0);
    });

    test('totalAvailableItc → sum of all available rows', () {
      final itc = createItc();
      // importGoods: 0, importServices: 0, inwardRcm: 3600, isd: 0, otherItc: 36000
      expect(itc.totalAvailableItc, 39600.0);
    });

    test('totalReversedItc → reversedSection17_5 + reversedOthers', () {
      final itc = createItc();
      // reversedSection17_5: 2000, reversedOthers: 0
      expect(itc.totalReversedItc, 2000.0);
    });

    test('copyWith → updates selected rows', () {
      final original = createItc();
      final newRow = ItcRow(igst: 36000, cgst: 18000, sgst: 18000, cess: 0);
      final updated = original.copyWith(otherItc: newRow);
      expect(updated.otherItc.igst, 36000.0);
      expect(updated.inwardRcm, original.inwardRcm);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createItc();
      final copy = original.copyWith();
      expect(copy.otherItc, original.otherItc);
    });

    test('equality → equal when all rows match', () {
      final a = createItc();
      final b = createItc();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
