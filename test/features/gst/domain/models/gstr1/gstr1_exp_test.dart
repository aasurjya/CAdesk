import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportType enum', () {
    test('withPayment → has correct label', () {
      expect(ExportType.withPayment.label, 'WPAY');
    });

    test('withoutPayment → has correct label', () {
      expect(ExportType.withoutPayment.label, 'WOPAY');
    });

    test('sezWithPayment → has correct label', () {
      expect(ExportType.sezWithPayment.label, 'SEZWP');
    });

    test('sezWithoutPayment → has correct label', () {
      expect(ExportType.sezWithoutPayment.label, 'SEZWOP');
    });

    test('deemed → has correct label', () {
      expect(ExportType.deemed.label, 'DE');
    });
  });

  group('Gstr1Exp', () {
    Gstr1Exp createExp({
      String invoiceNumber = 'EXP-001',
      DateTime? invoiceDate,
      ExportType exportType = ExportType.withPayment,
      String? shippingBillNumber = 'SB12345',
      DateTime? shippingBillDate,
      String? portCode = 'INBOM4',
      String currencyCode = 'USD',
      double foreignCurrencyValue = 10000.0,
      double taxableValue = 800000.0,
      double igst = 144000.0,
      double cess = 0.0,
      double gstRate = 18.0,
    }) {
      return Gstr1Exp(
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate ?? DateTime(2026, 1, 20),
        exportType: exportType,
        shippingBillNumber: shippingBillNumber,
        shippingBillDate: shippingBillDate ?? DateTime(2026, 1, 22),
        portCode: portCode,
        currencyCode: currencyCode,
        foreignCurrencyValue: foreignCurrencyValue,
        taxableValue: taxableValue,
        igst: igst,
        cess: cess,
        gstRate: gstRate,
      );
    }

    test('creates with correct field values', () {
      final exp = createExp();
      expect(exp.invoiceNumber, 'EXP-001');
      expect(exp.exportType, ExportType.withPayment);
      expect(exp.shippingBillNumber, 'SB12345');
      expect(exp.portCode, 'INBOM4');
      expect(exp.currencyCode, 'USD');
      expect(exp.foreignCurrencyValue, 10000.0);
      expect(exp.taxableValue, 800000.0);
      expect(exp.igst, 144000.0);
      expect(exp.cess, 0.0);
      expect(exp.gstRate, 18.0);
    });

    test('isZeroRated → true for withoutPayment type', () {
      final exp = createExp(exportType: ExportType.withoutPayment, igst: 0);
      expect(exp.isZeroRated, true);
    });

    test('isZeroRated → false for withPayment type', () {
      final exp = createExp(exportType: ExportType.withPayment);
      expect(exp.isZeroRated, false);
    });

    test('totalTax → igst + cess', () {
      final exp = createExp(igst: 144000, cess: 5000);
      expect(exp.totalTax, 149000.0);
    });

    test('invoiceValue → taxableValue + totalTax', () {
      final exp = createExp(taxableValue: 800000, igst: 144000);
      expect(exp.invoiceValue, 944000.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createExp();
      final updated = original.copyWith(
        exportType: ExportType.sezWithPayment,
        taxableValue: 1000000.0,
      );
      expect(updated.exportType, ExportType.sezWithPayment);
      expect(updated.taxableValue, 1000000.0);
      expect(updated.invoiceNumber, original.invoiceNumber);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createExp();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('equality → equal when same invoiceNumber', () {
      final a = createExp(taxableValue: 800000.0);
      final b = createExp(taxableValue: 900000.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different invoiceNumber', () {
      final a = createExp(invoiceNumber: 'EXP-001');
      final b = createExp(invoiceNumber: 'EXP-002');
      expect(a, isNot(equals(b)));
    });

    test('export without payment → igst = 0', () {
      final exp = createExp(
        exportType: ExportType.withoutPayment,
        igst: 0,
        shippingBillNumber: null,
        shippingBillDate: null,
      );
      expect(exp.igst, 0.0);
      expect(exp.shippingBillNumber, isNull);
      expect(exp.isZeroRated, true);
    });
  });
}
