import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';
import 'package:ca_app/features/gst/domain/services/gstr1_builder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr1BuilderService', () {
    GstInvoice makeB2b({
      String invoiceNumber = 'INV-001',
      String buyerGstin = '29AABCU9603R1ZM',
      double taxableValue = 100000.0,
      double igst = 18000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      bool reverseCharge = false,
      String placeOfSupply = '29',
      String supplierStateCode = '27',
    }) {
      final item = GstInvoiceItem(
        description: 'Goods',
        hsnSacCode: '8471',
        itemType: InvoiceItemType.goods,
        quantity: 1,
        unit: 'NOS',
        unitPrice: taxableValue,
        taxableValue: taxableValue,
        gstRate: 18.0,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
      );
      return GstInvoice(
        id: invoiceNumber,
        invoiceNumber: invoiceNumber,
        invoiceDate: DateTime(2026, 1, 15),
        supplierGstin: '27AABCU9603R1ZM',
        supplierName: 'Supplier Co',
        supplierStateCode: supplierStateCode,
        buyerGstin: buyerGstin,
        buyerName: 'Buyer Corp',
        buyerStateCode: placeOfSupply,
        placeOfSupply: placeOfSupply,
        isInterState: true,
        reverseCharge: reverseCharge,
        isExport: false,
        invoiceType: 'Regular',
        items: [item],
      );
    }

    GstInvoice makeB2c({
      String invoiceNumber = 'INV-B2C-001',
      bool isInterState = true,
      double taxableValue = 300000.0,
      double igst = 54000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      String placeOfSupply = '29',
    }) {
      final item = GstInvoiceItem(
        description: 'Consumer Goods',
        hsnSacCode: '8471',
        itemType: InvoiceItemType.goods,
        quantity: 1,
        unit: 'NOS',
        unitPrice: taxableValue,
        taxableValue: taxableValue,
        gstRate: 18.0,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: 0.0,
      );
      return GstInvoice(
        id: invoiceNumber,
        invoiceNumber: invoiceNumber,
        invoiceDate: DateTime(2026, 1, 20),
        supplierGstin: '27AABCU9603R1ZM',
        supplierName: 'Supplier Co',
        supplierStateCode: '27',
        buyerGstin: null,
        buyerName: 'End Consumer',
        buyerStateCode: placeOfSupply,
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        reverseCharge: false,
        isExport: false,
        invoiceType: 'Regular',
        items: [item],
      );
    }

    GstInvoice makeExport({
      String invoiceNumber = 'EXP-001',
      double taxableValue = 800000.0,
      double igst = 144000.0,
    }) {
      final item = GstInvoiceItem(
        description: 'Export Goods',
        hsnSacCode: '8471',
        itemType: InvoiceItemType.goods,
        quantity: 1,
        unit: 'NOS',
        unitPrice: taxableValue,
        taxableValue: taxableValue,
        gstRate: 18.0,
        igst: igst,
        cgst: 0.0,
        sgst: 0.0,
        cess: 0.0,
      );
      return GstInvoice(
        id: invoiceNumber,
        invoiceNumber: invoiceNumber,
        invoiceDate: DateTime(2026, 1, 22),
        supplierGstin: '27AABCU9603R1ZM',
        supplierName: 'Supplier Co',
        supplierStateCode: '27',
        buyerGstin: null,
        buyerName: 'Foreign Buyer',
        buyerStateCode: '00',
        placeOfSupply: '00',
        isInterState: true,
        reverseCharge: false,
        isExport: true,
        invoiceType: 'Export',
        items: [item],
      );
    }

    test('build → empty invoice list → empty GSTR-1 form data', () {
      final result = Gstr1BuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        invoices: const [],
      );
      expect(result.b2bInvoices, isEmpty);
      expect(result.b2cInvoices, isEmpty);
      expect(result.exports, isEmpty);
      expect(result.totalTaxableValue, 0.0);
    });

    test('build → B2B invoice → appears in b2bInvoices table', () {
      final inv = makeB2b();
      final result = Gstr1BuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        invoices: [inv],
      );
      expect(result.b2bInvoices.length, 1);
      expect(result.b2bInvoices.first, isA<Gstr1B2bInvoice>());
      expect(result.b2bInvoices.first.recipientGstin, '29AABCU9603R1ZM');
      expect(result.b2bInvoices.first.taxableValue, 100000.0);
      expect(result.b2bInvoices.first.igst, 18000.0);
    });

    test(
      'build → B2C large invoice → appears in b2cInvoices with B2CL category',
      () {
        final inv = makeB2c(taxableValue: 300000, igst: 54000);
        final result = Gstr1BuilderService.build(
          gstin: '27AABCU9603R1ZM',
          periodMonth: 1,
          periodYear: 2026,
          invoices: [inv],
        );
        expect(result.b2cInvoices.length, 1);
        expect(result.b2cInvoices.first, isA<Gstr1B2cInvoice>());
        expect(result.b2cInvoices.first.category, B2cCategory.large);
      },
    );

    test(
      'build → B2C small invoice → appears in b2cInvoices with B2CS category',
      () {
        final inv = makeB2c(
          taxableValue: 100000,
          igst: 18000,
          isInterState: false,
          placeOfSupply: '27',
        );
        final result = Gstr1BuilderService.build(
          gstin: '27AABCU9603R1ZM',
          periodMonth: 1,
          periodYear: 2026,
          invoices: [inv],
        );
        expect(result.b2cInvoices.first.category, B2cCategory.small);
      },
    );

    test('build → export with IGST → appears in exports as withPayment', () {
      final inv = makeExport(igst: 144000);
      final result = Gstr1BuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        invoices: [inv],
      );
      expect(result.exports.length, 1);
      expect(result.exports.first, isA<Gstr1Exp>());
      expect(result.exports.first.exportType, ExportType.withPayment);
    });

    test(
      'build → export without IGST → appears in exports as withoutPayment',
      () {
        final inv = makeExport(igst: 0);
        final result = Gstr1BuilderService.build(
          gstin: '27AABCU9603R1ZM',
          periodMonth: 1,
          periodYear: 2026,
          invoices: [inv],
        );
        expect(result.exports.first.exportType, ExportType.withoutPayment);
      },
    );

    test('build → mixed invoices → routed to correct tables', () {
      final invoices = [
        makeB2b(invoiceNumber: 'INV-001'),
        makeB2c(taxableValue: 300000, igst: 54000),
        makeExport(),
      ];
      final result = Gstr1BuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        invoices: invoices,
      );
      expect(result.b2bInvoices.length, 1);
      expect(result.b2cInvoices.length, 1);
      expect(result.exports.length, 1);
    });

    test('build → totalTaxableValue sums across all tables', () {
      final invoices = [
        makeB2b(taxableValue: 100000, igst: 18000),
        makeB2c(taxableValue: 300000, igst: 54000),
        makeExport(taxableValue: 800000, igst: 144000),
      ];
      final result = Gstr1BuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        invoices: invoices,
      );
      expect(result.totalTaxableValue, 1200000.0);
    });

    test('build → sets correct gstin and period', () {
      final result = Gstr1BuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 3,
        periodYear: 2026,
        invoices: const [],
      );
      expect(result.gstin, '27AABCU9603R1ZM');
      expect(result.periodMonth, 3);
      expect(result.periodYear, 2026);
    });
  });
}
