import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvoiceItemType enum', () {
    test('goods → has correct label', () {
      expect(InvoiceItemType.goods.label, 'Goods');
    });

    test('services → has correct label', () {
      expect(InvoiceItemType.services.label, 'Services');
    });
  });

  group('GstInvoiceItem', () {
    GstInvoiceItem createItem({
      String description = 'Product A',
      String hsnSacCode = '8471',
      InvoiceItemType itemType = InvoiceItemType.goods,
      double quantity = 10.0,
      String unit = 'NOS',
      double unitPrice = 10000.0,
      double taxableValue = 100000.0,
      double gstRate = 18.0,
      double igst = 18000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
    }) {
      return GstInvoiceItem(
        description: description,
        hsnSacCode: hsnSacCode,
        itemType: itemType,
        quantity: quantity,
        unit: unit,
        unitPrice: unitPrice,
        taxableValue: taxableValue,
        gstRate: gstRate,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
      );
    }

    test('creates with correct field values', () {
      final item = createItem();
      expect(item.description, 'Product A');
      expect(item.hsnSacCode, '8471');
      expect(item.itemType, InvoiceItemType.goods);
      expect(item.quantity, 10.0);
      expect(item.unit, 'NOS');
      expect(item.unitPrice, 10000.0);
      expect(item.taxableValue, 100000.0);
      expect(item.gstRate, 18.0);
      expect(item.igst, 18000.0);
    });

    test('totalTax → sum of all tax components', () {
      final item = createItem(igst: 18000, cess: 1000);
      expect(item.totalTax, 19000.0);
    });

    test('lineTotal → taxableValue + totalTax', () {
      final item = createItem(taxableValue: 100000, igst: 18000);
      expect(item.lineTotal, 118000.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createItem();
      final updated = original.copyWith(quantity: 20.0, taxableValue: 200000.0);
      expect(updated.quantity, 20.0);
      expect(updated.taxableValue, 200000.0);
      expect(updated.hsnSacCode, original.hsnSacCode);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createItem();
      final copy = original.copyWith();
      expect(copy, equals(original));
      expect(copy.hashCode, original.hashCode);
    });

    test('equality → equal when all fields match', () {
      final a = createItem();
      final b = createItem();
      expect(a, equals(b));
    });

    test('equality → not equal when hsnSacCode differs', () {
      final a = createItem(hsnSacCode: '8471');
      final b = createItem(hsnSacCode: '8472');
      expect(a, isNot(equals(b)));
    });
  });

  group('GstInvoice', () {
    GstInvoiceItem createItem({
      double taxableValue = 100000.0,
      double igst = 18000.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
    }) {
      return GstInvoiceItem(
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
    }

    GstInvoice createInvoice({
      String id = 'INV-2026-001',
      String invoiceNumber = 'INV-001',
      DateTime? invoiceDate,
      String supplierGstin = '27AABCU9603R1ZM',
      String supplierName = 'Supplier Co',
      String supplierStateCode = '27',
      String? buyerGstin = '29AABCU9603R1ZM',
      String buyerName = 'Buyer Corp',
      String buyerStateCode = '29',
      String placeOfSupply = '29',
      bool isInterState = true,
      bool reverseCharge = false,
      bool isExport = false,
      String invoiceType = 'Regular',
      List<GstInvoiceItem>? items,
    }) {
      return GstInvoice(
        id: id,
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate ?? DateTime(2026, 1, 15),
        supplierGstin: supplierGstin,
        supplierName: supplierName,
        supplierStateCode: supplierStateCode,
        buyerGstin: buyerGstin,
        buyerName: buyerName,
        buyerStateCode: buyerStateCode,
        placeOfSupply: placeOfSupply,
        isInterState: isInterState,
        reverseCharge: reverseCharge,
        isExport: isExport,
        invoiceType: invoiceType,
        items: items ?? [createItem()],
      );
    }

    test('creates with correct field values', () {
      final inv = createInvoice();
      expect(inv.id, 'INV-2026-001');
      expect(inv.invoiceNumber, 'INV-001');
      expect(inv.supplierGstin, '27AABCU9603R1ZM');
      expect(inv.buyerGstin, '29AABCU9603R1ZM');
      expect(inv.placeOfSupply, '29');
      expect(inv.isInterState, true);
      expect(inv.items.length, 1);
    });

    test('totalTaxableValue → sum of all item taxableValues', () {
      final items = [
        createItem(taxableValue: 100000, igst: 18000),
        createItem(taxableValue: 50000, igst: 9000),
      ];
      final inv = createInvoice(items: items);
      expect(inv.totalTaxableValue, 150000.0);
    });

    test('totalIgst → sum across all items', () {
      final items = [
        createItem(taxableValue: 100000, igst: 18000),
        createItem(taxableValue: 50000, igst: 9000),
      ];
      final inv = createInvoice(items: items);
      expect(inv.totalIgst, 27000.0);
    });

    test('totalCgst → sum across all items', () {
      final items = [
        createItem(taxableValue: 100000, igst: 0, cgst: 9000),
        createItem(taxableValue: 50000, igst: 0, cgst: 4500),
      ];
      final inv = createInvoice(items: items);
      expect(inv.totalCgst, 13500.0);
    });

    test('totalCess → sum across all items', () {
      final inv = createInvoice(
        items: [createItem(taxableValue: 100000, igst: 18000, cess: 2000)],
      );
      expect(inv.totalCess, 2000.0);
    });

    test('grandTotal → totalTaxableValue + all tax totals', () {
      final inv = createInvoice(
        items: [createItem(taxableValue: 100000, igst: 18000)],
      );
      expect(inv.grandTotal, 118000.0);
    });

    test('isB2b → true when buyerGstin is present', () {
      final inv = createInvoice(buyerGstin: '29AABCU9603R1ZM');
      expect(inv.isB2b, true);
    });

    test('isB2b → false when buyerGstin is null', () {
      final inv = createInvoice(buyerGstin: null);
      expect(inv.isB2b, false);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createInvoice();
      final updated = original.copyWith(invoiceNumber: 'INV-002');
      expect(updated.invoiceNumber, 'INV-002');
      expect(updated.id, original.id);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createInvoice();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('equality → equal when same id', () {
      final a = createInvoice();
      final b = createInvoice();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different id', () {
      final a = createInvoice(id: 'INV-2026-001');
      final b = createInvoice(id: 'INV-2026-002');
      expect(a, isNot(equals(b)));
    });
  });
}
