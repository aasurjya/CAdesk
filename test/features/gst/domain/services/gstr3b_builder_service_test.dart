import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';
import 'package:ca_app/features/gst/domain/services/gstr3b_builder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr3bBuilderService', () {
    GstInvoice makeOutwardInvoice({
      String id = 'INV-001',
      double taxableValue = 100000.0,
      double igst = 18000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      bool reverseCharge = false,
      bool isExport = false,
      bool isInterState = true,
      String? buyerGstin = '29AABCU9603R1ZM',
    }) {
      final item = GstInvoiceItem(
        description: 'Product',
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
        id: id,
        invoiceNumber: id,
        invoiceDate: DateTime(2026, 1, 15),
        supplierGstin: '27AABCU9603R1ZM',
        supplierName: 'Supplier Co',
        supplierStateCode: '27',
        buyerGstin: buyerGstin,
        buyerName: 'Buyer',
        buyerStateCode: '29',
        placeOfSupply: '29',
        isInterState: isInterState,
        reverseCharge: reverseCharge,
        isExport: isExport,
        invoiceType: 'Regular',
        items: [item],
      );
    }

    Gstr2bEntry makeItcEntry({
      String supplierGstin = '27AABCU9603R1ZM',
      String invoiceNumber = 'PUR-001',
      double taxableValue = 50000.0,
      double igst = 9000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      bool reverseCharge = false,
    }) {
      return Gstr2bEntry(
        supplierGstin: supplierGstin,
        supplierName: 'Vendor Co',
        invoiceNumber: invoiceNumber,
        invoiceDate: DateTime(2026, 1, 10),
        invoiceValue: taxableValue + igst + cgst + sgst,
        taxableValue: taxableValue,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        placeOfSupply: '27',
        reverseCharge: reverseCharge,
        itcAvailable: ItcAvailability.yes,
      );
    }

    test('build → empty invoices and ITC → all rows are zero', () {
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: const [],
        itcEntries: const [],
      );
      expect(result.taxLiability.outwardTaxable.igst, 0.0);
      expect(result.taxLiability.outwardTaxable.cgst, 0.0);
      expect(result.itcClaimed.otherItc.igst, 0.0);
    });

    test('build → outward B2B taxable → populates 3.1(a) outwardTaxable', () {
      final inv = makeOutwardInvoice(taxableValue: 100000, igst: 18000);
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: [inv],
        itcEntries: const [],
      );
      expect(result.taxLiability.outwardTaxable.igst, 18000.0);
      expect(result.taxLiability.outwardTaxable.cgst, 0.0);
    });

    test('build → RCM invoice → appears in 3.1(d) inwardRcm', () {
      final inv = makeOutwardInvoice(
        reverseCharge: true,
        taxableValue: 50000,
        igst: 0,
        cgst: 4500,
        sgst: 4500,
        isInterState: false,
      );
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: [inv],
        itcEntries: const [],
      );
      expect(result.taxLiability.inwardRcm.cgst, 4500.0);
      expect(result.taxLiability.inwardRcm.sgst, 4500.0);
    });

    test('build → export invoice → populates 3.1(b) outwardZeroRated', () {
      final inv = makeOutwardInvoice(
        isExport: true,
        taxableValue: 800000,
        igst: 144000,
        buyerGstin: null,
      );
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: [inv],
        itcEntries: const [],
      );
      expect(result.taxLiability.outwardZeroRated.igst, 144000.0);
    });

    test('build → ITC from GSTR-2B → populates 4A(5) otherItc', () {
      final itc = makeItcEntry(igst: 9000);
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: const [],
        itcEntries: [itc],
      );
      expect(result.itcClaimed.otherItc.igst, 9000.0);
    });

    test('build → RCM ITC entry → populates 4A(3) inwardRcm ITC', () {
      final itc = makeItcEntry(
        reverseCharge: true,
        igst: 0,
        cgst: 1800,
        sgst: 1800,
      );
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: const [],
        itcEntries: [itc],
      );
      expect(result.itcClaimed.inwardRcm.cgst, 1800.0);
      expect(result.itcClaimed.inwardRcm.sgst, 1800.0);
    });

    test('build → multiple outward invoices → sums correctly', () {
      final invoices = [
        makeOutwardInvoice(id: 'INV-001', taxableValue: 100000, igst: 18000),
        makeOutwardInvoice(id: 'INV-002', taxableValue: 200000, igst: 36000),
      ];
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: invoices,
        itcEntries: const [],
      );
      expect(result.taxLiability.outwardTaxable.igst, 54000.0);
    });

    test('build → sets correct gstin and period', () {
      final result = Gstr3bBuilderService.build(
        gstin: '29XYZCO1234A1ZP',
        periodMonth: 3,
        periodYear: 2026,
        outwardInvoices: const [],
        itcEntries: const [],
      );
      expect(result.gstin, '29XYZCO1234A1ZP');
      expect(result.periodMonth, 3);
      expect(result.periodYear, 2026);
    });

    test('build → netTaxPayable accounts for ITC offset', () {
      final outward = [makeOutwardInvoice(taxableValue: 100000, igst: 18000)];
      final itc = [makeItcEntry(igst: 9000)];
      final result = Gstr3bBuilderService.build(
        gstin: '27AABCU9603R1ZM',
        periodMonth: 1,
        periodYear: 2026,
        outwardInvoices: outward,
        itcEntries: itc,
      );
      // Liability: 18000 IGST; ITC: 9000 IGST → net = 9000
      expect(result.netTaxPayable, closeTo(9000.0, 0.01));
    });
  });
}
