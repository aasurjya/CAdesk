import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr3bFormData', () {
    const zeroRow = Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);
    const zeroItc = ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

    Gstr3bTaxLiability createLiability() {
      return const Gstr3bTaxLiability(
        outwardTaxable: Gstr3bTaxRow(
          igst: 18000,
          cgst: 9000,
          sgst: 9000,
          cess: 0,
        ),
        outwardZeroRated: zeroRow,
        otherOutward: zeroRow,
        inwardRcm: Gstr3bTaxRow(igst: 0, cgst: 1800, sgst: 1800, cess: 0),
        nonGstOutward: zeroRow,
      );
    }

    Gstr3bItcClaimed createItcClaimed() {
      return const Gstr3bItcClaimed(
        importGoods: zeroItc,
        importServices: zeroItc,
        inwardRcm: ItcRow(igst: 0, cgst: 1800, sgst: 1800, cess: 0),
        isd: zeroItc,
        otherItc: ItcRow(igst: 18000, cgst: 9000, sgst: 9000, cess: 0),
        reversedSection17_5: ItcRow(igst: 0, cgst: 1000, sgst: 1000, cess: 0),
        reversedOthers: zeroItc,
        netItcAvailable: ItcRow(igst: 18000, cgst: 9800, sgst: 9800, cess: 0),
        ineligibleRule38: zeroItc,
        ineligibleOthers: zeroItc,
      );
    }

    Gstr3bExemptSupplies createExemptSupplies() {
      return const Gstr3bExemptSupplies(
        interStateExempt: 0,
        intraStateExempt: 50000,
        interStateNilRated: 0,
        intraStateNilRated: 0,
        interStateNonGst: 0,
        intraStateNonGst: 0,
      );
    }

    Gstr3bFormData createFormData({
      String gstin = '27AABCU9603R1ZM',
      int periodMonth = 1,
      int periodYear = 2026,
      Gstr3bTaxLiability? taxLiability,
      Gstr3bItcClaimed? itcClaimed,
      Gstr3bExemptSupplies? exemptSupplies,
    }) {
      return Gstr3bFormData(
        gstin: gstin,
        periodMonth: periodMonth,
        periodYear: periodYear,
        taxLiability: taxLiability ?? createLiability(),
        itcClaimed: itcClaimed ?? createItcClaimed(),
        exemptSupplies: exemptSupplies ?? createExemptSupplies(),
      );
    }

    test('creates with correct field values', () {
      final data = createFormData();
      expect(data.gstin, '27AABCU9603R1ZM');
      expect(data.periodMonth, 1);
      expect(data.periodYear, 2026);
      expect(data.taxLiability.outwardTaxable.igst, 18000.0);
      expect(data.itcClaimed.otherItc.igst, 18000.0);
      expect(data.exemptSupplies.intraStateExempt, 50000.0);
    });

    test('periodLabel → correct human-readable label', () {
      expect(
        createFormData(periodMonth: 3, periodYear: 2026).periodLabel,
        'Mar 2026',
      );
      expect(
        createFormData(periodMonth: 7, periodYear: 2025).periodLabel,
        'Jul 2025',
      );
    });

    test('netTaxPayable → totalTaxLiability - netItcAvailable', () {
      final data = createFormData();
      // Total liability: 18000+9000+9000+1800+1800 = 39600
      // Net ITC available: 18000+9800+9800 = 37600
      expect(data.netTaxPayable, closeTo(2000.0, 0.01));
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createFormData();
      final updated = original.copyWith(periodMonth: 2, periodYear: 2026);
      expect(updated.periodMonth, 2);
      expect(updated.periodYear, 2026);
      expect(updated.gstin, original.gstin);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createFormData();
      final copy = original.copyWith();
      expect(copy.gstin, original.gstin);
      expect(copy.taxLiability, original.taxLiability);
    });

    test('equality → equal when same gstin + period', () {
      final a = createFormData();
      final b = createFormData();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different periodMonth', () {
      final a = createFormData(periodMonth: 1);
      final b = createFormData(periodMonth: 2);
      expect(a, isNot(equals(b)));
    });
  });
}
