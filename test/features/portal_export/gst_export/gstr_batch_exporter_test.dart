import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr_batch_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GstrBatchExporter', () {
    late GstrBatchExporter exporter;

    setUp(() {
      exporter = GstrBatchExporter.instance;
    });

    const zeroTaxRow = Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);
    const zeroItcRow = ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

    Gstr1FormData gstr1Form(int month) => Gstr1FormData(
      gstin: '29AABCT1332L1ZB',
      periodMonth: month,
      periodYear: 2024,
      b2bInvoices: const [],
      b2cInvoices: const [],
      creditDebitNotes: const [],
      creditDebitNotesUnregistered: const [],
      exports: const [],
      advanceTax: const [],
    );

    Gstr3bFormData gstr3bForm(int month) => Gstr3bFormData(
      gstin: '29AABCT1332L1ZB',
      periodMonth: month,
      periodYear: 2024,
      taxLiability: const Gstr3bTaxLiability(
        outwardTaxable: zeroTaxRow,
        outwardZeroRated: zeroTaxRow,
        otherOutward: zeroTaxRow,
        inwardRcm: zeroTaxRow,
        nonGstOutward: zeroTaxRow,
      ),
      itcClaimed: const Gstr3bItcClaimed(
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
      exemptSupplies: const Gstr3bExemptSupplies(
        interStateExempt: 0,
        intraStateExempt: 0,
        interStateNilRated: 0,
        intraStateNilRated: 0,
        interStateNonGst: 0,
        intraStateNonGst: 0,
      ),
    );

    test('is a singleton', () {
      expect(GstrBatchExporter.instance, same(GstrBatchExporter.instance));
    });

    group('exportBatch (GSTR-1)', () {
      test('empty list returns empty result list', () {
        final results = exporter.exportBatch([], '29AABCT1332L1ZB');
        expect(results, isEmpty);
      });

      test('single form returns list with one result', () {
        final results = exporter.exportBatch([gstr1Form(3)], '29AABCT1332L1ZB');
        expect(results.length, 1);
      });

      test('three monthly forms return three results', () {
        final forms = [gstr1Form(1), gstr1Form(2), gstr1Form(3)];
        final results = exporter.exportBatch(forms, '29AABCT1332L1ZB');
        expect(results.length, 3);
      });

      test('all results have returnType gstr1', () {
        final forms = [gstr1Form(1), gstr1Form(2)];
        final results = exporter.exportBatch(forms, '29AABCT1332L1ZB');
        for (final r in results) {
          expect(r.returnType, GstrReturnType.gstr1);
        }
      });

      test('result periods match form months in MMYYYY format', () {
        final forms = [gstr1Form(1), gstr1Form(12)];
        final results = exporter.exportBatch(forms, '29AABCT1332L1ZB');
        expect(results[0].period, '012024');
        expect(results[1].period, '122024');
      });

      test('all results have provided gstin', () {
        final results = exporter.exportBatch([gstr1Form(3)], '27AABCE1234F1Z5');
        expect(results[0].gstin, '27AABCE1234F1Z5');
      });

      test('results are immutable — list is unmodifiable', () {
        final results = exporter.exportBatch([gstr1Form(3)], '29AABCT1332L1ZB');
        expect(() => results.add(results[0]), throwsUnsupportedError);
      });
    });

    group('exportGstr3bBatch', () {
      test('empty list returns empty result list', () {
        final results = exporter.exportGstr3bBatch([], '29AABCT1332L1ZB');
        expect(results, isEmpty);
      });

      test('single form returns list with one result', () {
        final results = exporter.exportGstr3bBatch([gstr3bForm(3)], '29AABCT1332L1ZB');
        expect(results.length, 1);
      });

      test('three monthly forms return three results', () {
        final forms = [gstr3bForm(1), gstr3bForm(2), gstr3bForm(3)];
        final results = exporter.exportGstr3bBatch(forms, '29AABCT1332L1ZB');
        expect(results.length, 3);
      });

      test('all results have returnType gstr3b', () {
        final forms = [gstr3bForm(1), gstr3bForm(2)];
        final results = exporter.exportGstr3bBatch(forms, '29AABCT1332L1ZB');
        for (final r in results) {
          expect(r.returnType, GstrReturnType.gstr3b);
        }
      });

      test('result periods match form months in MMYYYY format', () {
        final forms = [gstr3bForm(4), gstr3bForm(11)];
        final results = exporter.exportGstr3bBatch(forms, '29AABCT1332L1ZB');
        expect(results[0].period, '042024');
        expect(results[1].period, '112024');
      });

      test('all results have provided gstin', () {
        final results = exporter.exportGstr3bBatch([gstr3bForm(3)], '27AABCE1234F1Z5');
        expect(results[0].gstin, '27AABCE1234F1Z5');
      });

      test('results are immutable — list is unmodifiable', () {
        final results = exporter.exportGstr3bBatch([gstr3bForm(3)], '29AABCT1332L1ZB');
        expect(() => results.add(results[0]), throwsUnsupportedError);
      });
    });
  });
}
