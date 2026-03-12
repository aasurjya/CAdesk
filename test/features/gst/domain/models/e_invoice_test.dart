import 'package:ca_app/features/gst/domain/models/e_invoice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Enum Tests ──────────────────────────────────────────────────────

  group('EInvoiceDocType enum', () {
    test('invoice → has correct label and code', () {
      expect(EInvoiceDocType.invoice.label, 'Invoice');
      expect(EInvoiceDocType.invoice.code, 'INV');
    });

    test('creditNote → has correct label and code', () {
      expect(EInvoiceDocType.creditNote.label, 'Credit Note');
      expect(EInvoiceDocType.creditNote.code, 'CRN');
    });

    test('debitNote → has correct label and code', () {
      expect(EInvoiceDocType.debitNote.label, 'Debit Note');
      expect(EInvoiceDocType.debitNote.code, 'DBN');
    });
  });

  group('EInvoiceSupplyType enum', () {
    test('b2b → has correct label and code', () {
      expect(EInvoiceSupplyType.b2b.label, 'B2B');
      expect(EInvoiceSupplyType.b2b.code, 'B2B');
    });

    test('sez → has correct label and code', () {
      expect(EInvoiceSupplyType.sez.label, 'SEZ');
      expect(EInvoiceSupplyType.sez.code, 'SEZWP');
    });

    test('export → has correct label and code', () {
      expect(EInvoiceSupplyType.export.label, 'Export');
      expect(EInvoiceSupplyType.export.code, 'EXPWP');
    });

    test('deemedExport → has correct label and code', () {
      expect(EInvoiceSupplyType.deemedExport.label, 'Deemed Export');
      expect(EInvoiceSupplyType.deemedExport.code, 'DEXP');
    });
  });

  group('EInvoiceStatus enum', () {
    test('draft → has correct label', () {
      expect(EInvoiceStatus.draft.label, 'Draft');
    });

    test('generated → has correct label', () {
      expect(EInvoiceStatus.generated.label, 'Generated');
    });

    test('cancelled → has correct label', () {
      expect(EInvoiceStatus.cancelled.label, 'Cancelled');
    });
  });

  // ── Model Helpers ───────────────────────────────────────────────────

  EInvoiceAddress createAddress({
    String legalName = 'Test Corp Pvt Ltd',
    String? tradeName,
    String address1 = '123 Main Street',
    String? address2,
    String city = 'Mumbai',
    String state = 'Maharashtra',
    String stateCode = '27',
    String pincode = '400001',
  }) {
    return EInvoiceAddress(
      legalName: legalName,
      tradeName: tradeName,
      address1: address1,
      address2: address2,
      city: city,
      state: state,
      stateCode: stateCode,
      pincode: pincode,
    );
  }

  EInvoiceItem createItem({
    int slNo = 1,
    String productDescription = 'Office Laptop',
    String hsnCode = '84713010',
    double quantity = 2.0,
    String unit = 'NOS',
    double unitPrice = 50000.0,
    double discount = 0.0,
    double taxableValue = 100000.0,
    double gstRate = 18.0,
    double igst = 18000.0,
    double cgst = 0.0,
    double sgst = 0.0,
    double cess = 0.0,
    double totalItemValue = 118000.0,
  }) {
    return EInvoiceItem(
      slNo: slNo,
      productDescription: productDescription,
      hsnCode: hsnCode,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      discount: discount,
      taxableValue: taxableValue,
      gstRate: gstRate,
      igst: igst,
      cgst: cgst,
      sgst: sgst,
      cess: cess,
      totalItemValue: totalItemValue,
    );
  }

  EInvoiceTotals createTotals({
    double totalValue = 118000.0,
    double totalTaxableValue = 100000.0,
    double totalIgst = 18000.0,
    double totalCgst = 0.0,
    double totalSgst = 0.0,
    double totalCess = 0.0,
    double totalInvoiceValue = 118000.0,
  }) {
    return EInvoiceTotals(
      totalValue: totalValue,
      totalTaxableValue: totalTaxableValue,
      totalIgst: totalIgst,
      totalCgst: totalCgst,
      totalSgst: totalSgst,
      totalCess: totalCess,
      totalInvoiceValue: totalInvoiceValue,
    );
  }

  // ── EInvoiceAddress ─────────────────────────────────────────────────

  group('EInvoiceAddress', () {
    test('creates with const constructor and correct field values', () {
      final address = createAddress(tradeName: 'Test Trade');

      expect(address.legalName, 'Test Corp Pvt Ltd');
      expect(address.tradeName, 'Test Trade');
      expect(address.address1, '123 Main Street');
      expect(address.address2, isNull);
      expect(address.city, 'Mumbai');
      expect(address.state, 'Maharashtra');
      expect(address.stateCode, '27');
      expect(address.pincode, '400001');
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createAddress();
      final updated = original.copyWith(city: 'Pune', pincode: '411001');

      expect(updated.city, 'Pune');
      expect(updated.pincode, '411001');
      expect(updated.legalName, original.legalName);
    });

    test('equality → equal when all fields match', () {
      final a = createAddress();
      final b = createAddress();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when fields differ', () {
      final a = createAddress(city: 'Mumbai');
      final b = createAddress(city: 'Delhi');

      expect(a, isNot(equals(b)));
    });
  });

  // ── EInvoiceItem ────────────────────────────────────────────────────

  group('EInvoiceItem', () {
    test('creates with const constructor and correct field values', () {
      final item = createItem();

      expect(item.slNo, 1);
      expect(item.productDescription, 'Office Laptop');
      expect(item.hsnCode, '84713010');
      expect(item.quantity, 2.0);
      expect(item.unit, 'NOS');
      expect(item.unitPrice, 50000.0);
      expect(item.discount, 0.0);
      expect(item.taxableValue, 100000.0);
      expect(item.gstRate, 18.0);
      expect(item.igst, 18000.0);
      expect(item.cgst, 0.0);
      expect(item.sgst, 0.0);
      expect(item.cess, 0.0);
      expect(item.totalItemValue, 118000.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createItem();
      final updated = original.copyWith(quantity: 5.0, discount: 1000.0);

      expect(updated.quantity, 5.0);
      expect(updated.discount, 1000.0);
      expect(updated.hsnCode, original.hsnCode);
    });

    test('equality → equal when all fields match', () {
      final a = createItem();
      final b = createItem();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when fields differ', () {
      final a = createItem(slNo: 1);
      final b = createItem(slNo: 2);

      expect(a, isNot(equals(b)));
    });
  });

  // ── EInvoiceTotals ──────────────────────────────────────────────────

  group('EInvoiceTotals', () {
    test('creates with const constructor and correct field values', () {
      final totals = createTotals();

      expect(totals.totalValue, 118000.0);
      expect(totals.totalTaxableValue, 100000.0);
      expect(totals.totalIgst, 18000.0);
      expect(totals.totalCgst, 0.0);
      expect(totals.totalSgst, 0.0);
      expect(totals.totalCess, 0.0);
      expect(totals.totalInvoiceValue, 118000.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createTotals();
      final updated = original.copyWith(totalCess: 500.0);

      expect(updated.totalCess, 500.0);
      expect(updated.totalIgst, original.totalIgst);
    });

    test('equality → equal when all fields match', () {
      final a = createTotals();
      final b = createTotals();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  // ── EInvoice ────────────────────────────────────────────────────────

  group('EInvoice', () {
    EInvoice createInvoice({
      String? irn,
      String? ackNumber,
      DateTime? ackDate,
      EInvoiceStatus status = EInvoiceStatus.draft,
      String? qrCodeData,
    }) {
      return EInvoice(
        irn: irn,
        ackNumber: ackNumber,
        ackDate: ackDate,
        sellerAddress: createAddress(),
        sellerGstin: '27AABCU9603R1ZM',
        buyerAddress: createAddress(
          legalName: 'Buyer Corp',
          city: 'Delhi',
          state: 'Delhi',
          stateCode: '07',
          pincode: '110001',
        ),
        buyerGstin: '07BBBCU1234D1ZP',
        documentType: EInvoiceDocType.invoice,
        documentNumber: 'INV/2026/001',
        documentDate: DateTime(2026, 1, 15),
        supplyType: EInvoiceSupplyType.b2b,
        items: [createItem()],
        totals: createTotals(),
        status: status,
        qrCodeData: qrCodeData,
      );
    }

    test('creates with correct field values', () {
      final invoice = createInvoice();

      expect(invoice.irn, isNull);
      expect(invoice.ackNumber, isNull);
      expect(invoice.sellerGstin, '27AABCU9603R1ZM');
      expect(invoice.buyerGstin, '07BBBCU1234D1ZP');
      expect(invoice.documentType, EInvoiceDocType.invoice);
      expect(invoice.documentNumber, 'INV/2026/001');
      expect(invoice.supplyType, EInvoiceSupplyType.b2b);
      expect(invoice.items.length, 1);
      expect(invoice.status, EInvoiceStatus.draft);
      expect(invoice.qrCodeData, isNull);
    });

    test('copyWith → returns new instance with updated status', () {
      final original = createInvoice();
      final updated = original.copyWith(
        irn: 'a' * 64,
        ackNumber: '1234567890',
        status: EInvoiceStatus.generated,
      );

      expect(updated.irn, 'a' * 64);
      expect(updated.ackNumber, '1234567890');
      expect(updated.status, EInvoiceStatus.generated);
      expect(updated.sellerGstin, original.sellerGstin);
    });

    test('equality → equal when all fields match', () {
      final a = createInvoice();
      final b = createInvoice();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when documentNumber differs', () {
      final a = createInvoice();
      final b = a.copyWith(documentNumber: 'INV/2026/002');

      expect(a, isNot(equals(b)));
    });
  });
}
