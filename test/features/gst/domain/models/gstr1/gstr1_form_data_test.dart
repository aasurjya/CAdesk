import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnur.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_at.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr1FormData', () {
    final b2bInvoice = Gstr1B2bInvoice(
      invoiceNumber: 'INV-001',
      invoiceDate: DateTime(2026, 1, 15),
      recipientGstin: '29AABCU9603R1ZM',
      recipientName: 'Buyer A',
      placeOfSupply: '29',
      isInterState: true,
      taxableValue: 100000.0,
      igst: 18000.0,
      cgst: 0.0,
      sgst: 0.0,
      cess: 0.0,
      gstRate: 18.0,
      invoiceType: 'Regular',
      reverseCharge: false,
    );

    final b2cLarge = Gstr1B2cInvoice(
      invoiceNumber: 'INV-B2C-001',
      invoiceDate: DateTime(2026, 1, 20),
      placeOfSupply: '29',
      isInterState: true,
      taxableValue: 300000.0,
      igst: 54000.0,
      cgst: 0.0,
      sgst: 0.0,
      cess: 0.0,
      gstRate: 18.0,
      category: B2cCategory.large,
    );

    final expInvoice = Gstr1Exp(
      invoiceNumber: 'EXP-001',
      invoiceDate: DateTime(2026, 1, 22),
      exportType: ExportType.withPayment,
      currencyCode: 'USD',
      foreignCurrencyValue: 10000.0,
      taxableValue: 800000.0,
      igst: 144000.0,
      cess: 0.0,
      gstRate: 18.0,
    );

    Gstr1FormData createFormData({
      String gstin = '27AABCU9603R1ZM',
      int periodMonth = 1,
      int periodYear = 2026,
      List<Gstr1B2bInvoice>? b2bInvoices,
      List<Gstr1B2cInvoice>? b2cInvoices,
      List<Gstr1Cdnr>? creditDebitNotes,
      List<Gstr1Cdnur>? creditDebitNotesUnregistered,
      List<Gstr1Exp>? exports,
      List<Gstr1At>? advanceTax,
    }) {
      return Gstr1FormData(
        gstin: gstin,
        periodMonth: periodMonth,
        periodYear: periodYear,
        b2bInvoices: b2bInvoices ?? [b2bInvoice],
        b2cInvoices: b2cInvoices ?? [b2cLarge],
        creditDebitNotes: creditDebitNotes ?? const [],
        creditDebitNotesUnregistered: creditDebitNotesUnregistered ?? const [],
        exports: exports ?? [expInvoice],
        advanceTax: advanceTax ?? const [],
      );
    }

    test('creates with correct field values', () {
      final data = createFormData();
      expect(data.gstin, '27AABCU9603R1ZM');
      expect(data.periodMonth, 1);
      expect(data.periodYear, 2026);
      expect(data.b2bInvoices.length, 1);
      expect(data.b2cInvoices.length, 1);
      expect(data.creditDebitNotes, isEmpty);
      expect(data.exports.length, 1);
    });

    test('periodLabel → correct human-readable label', () {
      expect(
        createFormData(periodMonth: 1, periodYear: 2026).periodLabel,
        'Jan 2026',
      );
      expect(
        createFormData(periodMonth: 12, periodYear: 2025).periodLabel,
        'Dec 2025',
      );
    });

    test('totalTaxableValue → sum across all table types', () {
      final data = createFormData();
      // B2B: 100000, B2C: 300000, EXP: 800000
      expect(data.totalTaxableValue, 1200000.0);
    });

    test('totalIgst → sum across all table types', () {
      final data = createFormData();
      // B2B: 18000, B2C: 54000, EXP: 144000
      expect(data.totalIgst, 216000.0);
    });

    test('totalCgst → sum of CGST across all table types', () {
      final data = createFormData();
      expect(data.totalCgst, 0.0);
    });

    test('totalSgst → sum of SGST across all table types', () {
      final data = createFormData();
      expect(data.totalSgst, 0.0);
    });

    test('totalCess → sum of CESS across all table types', () {
      final data = createFormData();
      expect(data.totalCess, 0.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createFormData();
      final updated = original.copyWith(
        gstin: '29NEWGSTIN001Z',
        periodMonth: 2,
      );
      expect(updated.gstin, '29NEWGSTIN001Z');
      expect(updated.periodMonth, 2);
      expect(updated.periodYear, original.periodYear);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createFormData();
      final copy = original.copyWith();
      expect(copy.gstin, original.gstin);
      expect(copy.b2bInvoices.length, original.b2bInvoices.length);
    });

    test('equality → equal when same gstin + period', () {
      final a = createFormData();
      final b = createFormData();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different gstin', () {
      final a = createFormData(gstin: '27AABCU9603R1ZM');
      final b = createFormData(gstin: '29XYZCO1234A1ZP');
      expect(a, isNot(equals(b)));
    });

    test('empty form data → all totals are zero', () {
      const data = Gstr1FormData(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        b2bInvoices: [],
        b2cInvoices: [],
        creditDebitNotes: [],
        creditDebitNotesUnregistered: [],
        exports: [],
        advanceTax: [],
      );
      expect(data.totalTaxableValue, 0.0);
      expect(data.totalIgst, 0.0);
      expect(data.totalCgst, 0.0);
    });
  });
}
