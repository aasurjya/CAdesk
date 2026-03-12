import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr3b_json_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr3bJsonSerializer', () {
    late Gstr3bJsonSerializer serializer;

    setUp(() {
      serializer = Gstr3bJsonSerializer.instance;
    });

    const zeroTaxRow = Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);
    const zeroItcRow = ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

    Gstr3bFormData _emptyForm() => const Gstr3bFormData(
      gstin: '29AABCT1332L1ZB',
      periodMonth: 3,
      periodYear: 2024,
      taxLiability: Gstr3bTaxLiability(
        outwardTaxable: zeroTaxRow,
        outwardZeroRated: zeroTaxRow,
        otherOutward: zeroTaxRow,
        inwardRcm: zeroTaxRow,
        nonGstOutward: zeroTaxRow,
      ),
      itcClaimed: Gstr3bItcClaimed(
        importGoods: zeroItcRow,
        importServices: zeroItcRow,
        inwardRcm: zeroItcRow,
        isd: zeroItcRow,
        otherItc: zeroItcRow,
        reversedSection17_5: zeroItcRow,
        reversedOthers: zeroItcRow,
        netItcAvailable: zeroItcRow,
        ineligibleRule38: zeroItcRow,
        ineligibleOthers: zeroItcRow,
      ),
      exemptSupplies: Gstr3bExemptSupplies(
        interStateExempt: 0,
        intraStateExempt: 0,
        interStateNilRated: 0,
        intraStateNilRated: 0,
        interStateNonGst: 0,
        intraStateNonGst: 0,
      ),
    );

    Gstr3bFormData _formWithTaxLiability() {
      return _emptyForm().copyWith(
        taxLiability: const Gstr3bTaxLiability(
          outwardTaxable: Gstr3bTaxRow(igst: 0, cgst: 9000, sgst: 9000, cess: 0),
          outwardZeroRated: Gstr3bTaxRow(igst: 5000, cgst: 0, sgst: 0, cess: 0),
          otherOutward: zeroTaxRow,
          inwardRcm: Gstr3bTaxRow(igst: 1000, cgst: 0, sgst: 0, cess: 0),
          nonGstOutward: zeroTaxRow,
        ),
      );
    }

    Gstr3bFormData _formWithItc() {
      return _emptyForm().copyWith(
        itcClaimed: const Gstr3bItcClaimed(
          importGoods: ItcRow(igst: 500, cgst: 0, sgst: 0, cess: 0),
          importServices: ItcRow(igst: 200, cgst: 0, sgst: 0, cess: 0),
          inwardRcm: ItcRow(igst: 100, cgst: 0, sgst: 0, cess: 0),
          isd: ItcRow(igst: 300, cgst: 0, sgst: 0, cess: 0),
          otherItc: ItcRow(igst: 0, cgst: 4000, sgst: 4000, cess: 0),
          reversedSection17_5: ItcRow(igst: 50, cgst: 0, sgst: 0, cess: 0),
          reversedOthers: ItcRow(igst: 0, cgst: 100, sgst: 100, cess: 0),
          netItcAvailable: ItcRow(igst: 950, cgst: 3900, sgst: 3900, cess: 0),
          ineligibleRule38: zeroItcRow,
          ineligibleOthers: zeroItcRow,
        ),
      );
    }

    test('is a singleton', () {
      expect(Gstr3bJsonSerializer.instance, same(Gstr3bJsonSerializer.instance));
    });

    test('serialize returns GstrExportResult with returnType gstr3b', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      expect(result.returnType, GstrReturnType.gstr3b);
    });

    test('serialize sets gstin and period on result', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      expect(result.gstin, '29AABCT1332L1ZB');
      expect(result.period, '032024');
    });

    test('serialize produces valid JSON string', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      expect(() => jsonDecode(result.jsonPayload), returnsNormally);
    });

    test('JSON contains gstin field', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
      expect(json['gstin'], '29AABCT1332L1ZB');
    });

    test('JSON contains ret_period field', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
      expect(json['ret_period'], '032024');
    });

    test('validationErrors is empty for valid form data', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      expect(result.validationErrors, isEmpty);
    });

    group('sup_details', () {
      test('JSON contains sup_details', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('sup_details'), isTrue);
      });

      test('sup_details contains osup_det for 3.1(a)', () {
        final result = serializer.serialize(_formWithTaxLiability(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final supDetails = json['sup_details'] as Map<String, Object?>;
        expect(supDetails.containsKey('osup_det'), isTrue);
      });

      test('osup_det has correct camt and samt values', () {
        final result = serializer.serialize(_formWithTaxLiability(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final supDetails = json['sup_details'] as Map<String, Object?>;
        final osupDet = supDetails['osup_det'] as Map<String, Object?>;
        expect(osupDet['camt'], '9000.00');
        expect(osupDet['samt'], '9000.00');
        expect(osupDet['iamt'], '0.00');
      });

      test('osup_zero has correct iamt for zero-rated', () {
        final result = serializer.serialize(_formWithTaxLiability(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final supDetails = json['sup_details'] as Map<String, Object?>;
        final osupZero = supDetails['osup_zero'] as Map<String, Object?>;
        expect(osupZero['iamt'], '5000.00');
      });

      test('isup_rev has correct iamt for RCM', () {
        final result = serializer.serialize(_formWithTaxLiability(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final supDetails = json['sup_details'] as Map<String, Object?>;
        final isupRev = supDetails['isup_rev'] as Map<String, Object?>;
        expect(isupRev['iamt'], '1000.00');
      });

      test('osup_nil_exmp has txval field', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final supDetails = json['sup_details'] as Map<String, Object?>;
        final osupNil = supDetails['osup_nil_exmp'] as Map<String, Object?>;
        expect(osupNil.containsKey('txval'), isTrue);
      });

      test('amounts in sup_details are formatted as strings with 2 decimals', () {
        final result = serializer.serialize(_formWithTaxLiability(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final supDetails = json['sup_details'] as Map<String, Object?>;
        final osupDet = supDetails['osup_det'] as Map<String, Object?>;
        expect(osupDet['camt'], isA<String>());
        expect(osupDet['camt'] as String, contains('.'));
      });
    });

    group('itc_elg', () {
      test('JSON contains itc_elg', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('itc_elg'), isTrue);
      });

      test('itc_elg contains itc_avl list', () {
        final result = serializer.serialize(_formWithItc(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final itcElg = json['itc_elg'] as Map<String, Object?>;
        expect(itcElg.containsKey('itc_avl'), isTrue);
        final itcAvl = itcElg['itc_avl'] as List<Object?>;
        expect(itcAvl, isNotEmpty);
      });

      test('itc_avl has entry with ty IMPG for import goods', () {
        final result = serializer.serialize(_formWithItc(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final itcElg = json['itc_elg'] as Map<String, Object?>;
        final itcAvl = (itcElg['itc_avl'] as List<Object?>)
            .cast<Map<String, Object?>>();
        final impg = itcAvl.firstWhere((e) => e['ty'] == 'IMPG');
        expect(impg['iamt'], '500.00');
      });

      test('itc_avl has entry with ty ISD for ISD credits', () {
        final result = serializer.serialize(_formWithItc(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final itcElg = json['itc_elg'] as Map<String, Object?>;
        final itcAvl = (itcElg['itc_avl'] as List<Object?>)
            .cast<Map<String, Object?>>();
        final isd = itcAvl.firstWhere((e) => e['ty'] == 'ISD');
        expect(isd['iamt'], '300.00');
      });

      test('itc_avl has entry with ty OTH for other ITC', () {
        final result = serializer.serialize(_formWithItc(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final itcElg = json['itc_elg'] as Map<String, Object?>;
        final itcAvl = (itcElg['itc_avl'] as List<Object?>)
            .cast<Map<String, Object?>>();
        final oth = itcAvl.firstWhere((e) => e['ty'] == 'OTH');
        expect(oth['camt'], '4000.00');
        expect(oth['samt'], '4000.00');
      });

      test('itc_elg contains itc_rev list', () {
        final result = serializer.serialize(_formWithItc(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final itcElg = json['itc_elg'] as Map<String, Object?>;
        expect(itcElg.containsKey('itc_rev'), isTrue);
        final itcRev = itcElg['itc_rev'] as List<Object?>;
        expect(itcRev, isNotEmpty);
      });

      test('itc_rev has entries for reversals', () {
        final result = serializer.serialize(_formWithItc(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final itcElg = json['itc_elg'] as Map<String, Object?>;
        final itcRev = (itcElg['itc_rev'] as List<Object?>)
            .cast<Map<String, Object?>>();
        // Rule 42/43 reversal
        final r1 = itcRev.firstWhere((e) => e['ty'] == 'RUL');
        expect(r1['iamt'], '50.00');
      });
    });

    group('intr_ltfee', () {
      test('JSON contains intr_ltfee', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('intr_ltfee'), isTrue);
      });

      test('intr_ltfee has intr_details and ltfee_details', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final intrLtfee = json['intr_ltfee'] as Map<String, Object?>;
        expect(intrLtfee.containsKey('intr_details'), isTrue);
        expect(intrLtfee.containsKey('ltfee_details'), isTrue);
      });

      test('intr_details has zero amounts for empty form', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final intrLtfee = json['intr_ltfee'] as Map<String, Object?>;
        final intrDetails = intrLtfee['intr_details'] as Map<String, Object?>;
        expect(intrDetails['iamt'], '0.00');
        expect(intrDetails['camt'], '0.00');
        expect(intrDetails['samt'], '0.00');
      });
    });

    test('exportedAt is set', () {
      final before = DateTime.now();
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      final after = DateTime.now();
      expect(result.exportedAt.isAfter(before) || result.exportedAt.isAtSameMomentAs(before), isTrue);
      expect(result.exportedAt.isBefore(after) || result.exportedAt.isAtSameMomentAs(after), isTrue);
    });
  });
}
