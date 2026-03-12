import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_at.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr1_json_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr1JsonSerializer', () {
    late Gstr1JsonSerializer serializer;

    setUp(() {
      serializer = Gstr1JsonSerializer.instance;
    });

    Gstr1FormData _emptyForm() => const Gstr1FormData(
      gstin: '29AABCT1332L1ZB',
      periodMonth: 3,
      periodYear: 2024,
      b2bInvoices: [],
      b2cInvoices: [],
      creditDebitNotes: [],
      creditDebitNotesUnregistered: [],
      exports: [],
      advanceTax: [],
    );

    Gstr1B2bInvoice _b2bInvoice() => Gstr1B2bInvoice(
      invoiceNumber: 'INV001',
      invoiceDate: DateTime(2024, 3, 1),
      recipientGstin: '01AABCE2207R1Z5',
      recipientName: 'Test Buyer',
      placeOfSupply: '29',
      isInterState: false,
      taxableValue: 10000.0,
      igst: 0.0,
      cgst: 900.0,
      sgst: 900.0,
      cess: 0.0,
      gstRate: 18.0,
      invoiceType: 'Regular',
      reverseCharge: false,
    );

    Gstr1B2cInvoice _b2csInvoice() => Gstr1B2cInvoice(
      invoiceDate: DateTime(2024, 3, 5),
      placeOfSupply: '29',
      isInterState: false,
      taxableValue: 5000.0,
      igst: 0.0,
      cgst: 250.0,
      sgst: 250.0,
      cess: 0.0,
      gstRate: 10.0,
      category: B2cCategory.small,
    );

    Gstr1B2cInvoice _b2clInvoice() => Gstr1B2cInvoice(
      invoiceNumber: 'B2CL001',
      invoiceDate: DateTime(2024, 3, 10),
      placeOfSupply: '27',
      isInterState: true,
      taxableValue: 300000.0,
      igst: 54000.0,
      cgst: 0.0,
      sgst: 0.0,
      cess: 0.0,
      gstRate: 18.0,
      category: B2cCategory.large,
    );

    Gstr1Cdnr _cdnrNote() => Gstr1Cdnr(
      noteNumber: 'CN001',
      noteDate: DateTime(2024, 3, 15),
      noteType: CdnrNoteType.creditNote,
      recipientGstin: '01AABCE2207R1Z5',
      recipientName: 'Test Buyer',
      originalInvoiceNumber: 'INV001',
      originalInvoiceDate: DateTime(2024, 3, 1),
      placeOfSupply: '29',
      isInterState: false,
      taxableValue: 1000.0,
      igst: 0.0,
      cgst: 90.0,
      sgst: 90.0,
      cess: 0.0,
      gstRate: 18.0,
    );

    Gstr1Exp _exportInvoice() => Gstr1Exp(
      invoiceNumber: 'EXP001',
      invoiceDate: DateTime(2024, 3, 20),
      exportType: ExportType.withPayment,
      shippingBillNumber: 'SB001',
      shippingBillDate: DateTime(2024, 3, 21),
      portCode: 'INMAA1',
      currencyCode: 'USD',
      foreignCurrencyValue: 1000.0,
      taxableValue: 83000.0,
      igst: 14940.0,
      cess: 0.0,
      gstRate: 18.0,
    );

    test('is a singleton', () {
      expect(Gstr1JsonSerializer.instance, same(Gstr1JsonSerializer.instance));
    });

    test('serialize returns GstrExportResult with returnType gstr1', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      expect(result.returnType, GstrReturnType.gstr1);
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

    test('JSON contains fp (filing period) field', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
      expect(json['fp'], '032024');
    });

    test('sectionCount is 0 for empty form data', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      expect(result.sectionCount, 0);
    });

    test('exportedAt is set to a recent DateTime', () {
      final before = DateTime.now();
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      final after = DateTime.now();
      expect(result.exportedAt.isAfter(before) || result.exportedAt.isAtSameMomentAs(before), isTrue);
      expect(result.exportedAt.isBefore(after) || result.exportedAt.isAtSameMomentAs(after), isTrue);
    });

    test('validationErrors is empty for valid form data', () {
      final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
      expect(result.validationErrors, isEmpty);
    });

    group('b2b section', () {
      test('b2b section present when b2bInvoices non-empty', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('b2b'), isTrue);
      });

      test('b2b section absent when b2bInvoices empty', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('b2b'), isFalse);
      });

      test('b2b entry has ctin matching recipient GSTIN', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        expect(entry['ctin'], '01AABCE2207R1Z5');
      });

      test('b2b invoice has correct inum', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        final inv = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        expect(inv['inum'], 'INV001');
      });

      test('b2b invoice date formatted as DD-MM-YYYY', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        final inv = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        expect(inv['idt'], '01-03-2024');
      });

      test('b2b invoice val is total invoice value as string with 2 decimals', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        final inv = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        // taxableValue 10000 + cgst 900 + sgst 900 = 11800
        expect(inv['val'], '11800.00');
      });

      test('b2b invoice pos is place of supply', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        final inv = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        expect(inv['pos'], '29');
      });

      test('b2b invoice rchrg is Y for reverse charge', () {
        final inv = _b2bInvoice().copyWith(reverseCharge: true);
        final form = _emptyForm().copyWith(b2bInvoices: [inv]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        final invJson = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        expect(invJson['rchrg'], 'Y');
      });

      test('b2b invoice rchrg is N for non-reverse charge', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        final invJson = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        expect(invJson['rchrg'], 'N');
      });

      test('b2b invoice itms has num and itm_det with correct tax amounts', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        final entry = b2b[0] as Map<String, Object?>;
        final inv = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        final itms = inv['itms'] as List<Object?>;
        expect(itms, isNotEmpty);
        final item = itms[0] as Map<String, Object?>;
        expect(item['num'], 1);
        final itmDet = item['itm_det'] as Map<String, Object?>;
        expect(itmDet['txval'], '10000.00');
        expect(itmDet['rt'], 18.0);
        expect(itmDet['camt'], '900.00');
        expect(itmDet['samt'], '900.00');
      });

      test('two b2b invoices for same recipient are grouped under one ctin entry', () {
        final inv2 = _b2bInvoice().copyWith(invoiceNumber: 'INV002');
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice(), inv2]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2b = json['b2b'] as List<Object?>;
        // Same ctin => one group
        expect(b2b.length, 1);
        final entry = b2b[0] as Map<String, Object?>;
        expect((entry['inv'] as List<Object?>).length, 2);
      });

      test('sectionCount increments when b2b present', () {
        final form = _emptyForm().copyWith(b2bInvoices: [_b2bInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        expect(result.sectionCount, greaterThan(0));
      });
    });

    group('b2cs section', () {
      test('b2cs section present when B2CS invoices present', () {
        final form = _emptyForm().copyWith(b2cInvoices: [_b2csInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('b2cs'), isTrue);
      });

      test('b2cs section absent when no B2CS invoices', () {
        final result = serializer.serialize(_emptyForm(), '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('b2cs'), isFalse);
      });

      test('b2cs entry has typ field set to OE', () {
        final form = _emptyForm().copyWith(b2cInvoices: [_b2csInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2cs = json['b2cs'] as List<Object?>;
        final entry = b2cs[0] as Map<String, Object?>;
        expect(entry['typ'], 'OE');
      });

      test('b2cs entry has pos and rt', () {
        final form = _emptyForm().copyWith(b2cInvoices: [_b2csInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2cs = json['b2cs'] as List<Object?>;
        final entry = b2cs[0] as Map<String, Object?>;
        expect(entry['pos'], '29');
        expect(entry['rt'], 10.0);
      });

      test('b2cs entry has txval as string with 2 decimals', () {
        final form = _emptyForm().copyWith(b2cInvoices: [_b2csInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2cs = json['b2cs'] as List<Object?>;
        final entry = b2cs[0] as Map<String, Object?>;
        expect(entry['txval'], '5000.00');
      });
    });

    group('b2cl section', () {
      test('b2cl section present when B2CL invoices present', () {
        final form = _emptyForm().copyWith(b2cInvoices: [_b2clInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('b2cl'), isTrue);
      });

      test('b2cl entry has pos and inv list', () {
        final form = _emptyForm().copyWith(b2cInvoices: [_b2clInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2cl = json['b2cl'] as List<Object?>;
        final entry = b2cl[0] as Map<String, Object?>;
        expect(entry['pos'], '27');
        expect(entry['inv'], isA<List>());
      });

      test('b2cl invoice has inum idt val', () {
        final form = _emptyForm().copyWith(b2cInvoices: [_b2clInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final b2cl = json['b2cl'] as List<Object?>;
        final entry = b2cl[0] as Map<String, Object?>;
        final inv = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        expect(inv['inum'], 'B2CL001');
        expect(inv['idt'], '10-03-2024');
        // 300000 + 54000 = 354000
        expect(inv['val'], '354000.00');
      });
    });

    group('cdnr section', () {
      test('cdnr section present when creditDebitNotes non-empty', () {
        final form = _emptyForm().copyWith(creditDebitNotes: [_cdnrNote()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('cdnr'), isTrue);
      });

      test('cdnr entry has ctin', () {
        final form = _emptyForm().copyWith(creditDebitNotes: [_cdnrNote()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final cdnr = json['cdnr'] as List<Object?>;
        final entry = cdnr[0] as Map<String, Object?>;
        expect(entry['ctin'], '01AABCE2207R1Z5');
      });

      test('cdnr note has ntNum ntDt ntty val', () {
        final form = _emptyForm().copyWith(creditDebitNotes: [_cdnrNote()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final cdnr = json['cdnr'] as List<Object?>;
        final entry = cdnr[0] as Map<String, Object?>;
        final note = (entry['nt'] as List<Object?>)[0] as Map<String, Object?>;
        expect(note['ntNum'], 'CN001');
        expect(note['ntDt'], '15-03-2024');
        expect(note['ntty'], 'C'); // credit note = 'C'
        // 1000 + 90 + 90 = 1180
        expect(note['val'], '1180.00');
      });

      test('debit note type maps to D', () {
        final dn = _cdnrNote().copyWith(noteType: CdnrNoteType.debitNote);
        final form = _emptyForm().copyWith(creditDebitNotes: [dn]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final cdnr = json['cdnr'] as List<Object?>;
        final entry = cdnr[0] as Map<String, Object?>;
        final note = (entry['nt'] as List<Object?>)[0] as Map<String, Object?>;
        expect(note['ntty'], 'D');
      });
    });

    group('exp section', () {
      test('exp section present when exports non-empty', () {
        final form = _emptyForm().copyWith(exports: [_exportInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        expect(json.containsKey('exp'), isTrue);
      });

      test('exp entry has expTyp and inv list', () {
        final form = _emptyForm().copyWith(exports: [_exportInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final exp = json['exp'] as List<Object?>;
        final entry = exp[0] as Map<String, Object?>;
        expect(entry['expTyp'], 'WPAY');
        expect(entry['inv'], isA<List>());
      });

      test('exp invoice has inum idt val sbNum sbDt', () {
        final form = _emptyForm().copyWith(exports: [_exportInvoice()]);
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
        final exp = json['exp'] as List<Object?>;
        final entry = exp[0] as Map<String, Object?>;
        final inv = (entry['inv'] as List<Object?>)[0] as Map<String, Object?>;
        expect(inv['inum'], 'EXP001');
        expect(inv['idt'], '20-03-2024');
        // 83000 + 14940 = 97940
        expect(inv['val'], '97940.00');
        expect(inv['sbNum'], 'SB001');
        expect(inv['sbDt'], '21-03-2024');
      });
    });

    group('sectionCount', () {
      test('sectionCount reflects number of populated sections', () {
        final form = _emptyForm().copyWith(
          b2bInvoices: [_b2bInvoice()],
          exports: [_exportInvoice()],
        );
        final result = serializer.serialize(form, '29AABCT1332L1ZB', '032024');
        expect(result.sectionCount, 2);
      });
    });
  });
}
