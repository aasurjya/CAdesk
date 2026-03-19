import 'package:ca_app/features/gst/domain/models/e_invoice.dart';
import 'package:ca_app/features/gst/domain/services/e_invoice_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────

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

  EInvoice createValidInvoice({
    String sellerGstin = '27AABCU9603R1ZM',
    String buyerGstin = '07BBBCU1234D1ZP',
    String documentNumber = 'INV/2026/001',
    List<EInvoiceItem>? items,
    EInvoiceTotals? totals,
  }) {
    final itemList = items ?? [createItem()];
    final invoiceTotals =
        totals ??
        const EInvoiceTotals(
          totalValue: 118000.0,
          totalTaxableValue: 100000.0,
          totalIgst: 18000.0,
          totalCgst: 0.0,
          totalSgst: 0.0,
          totalCess: 0.0,
          totalInvoiceValue: 118000.0,
        );

    return EInvoice(
      sellerAddress: createAddress(),
      sellerGstin: sellerGstin,
      buyerAddress: createAddress(
        legalName: 'Buyer Corp',
        city: 'Delhi',
        state: 'Delhi',
        stateCode: '07',
        pincode: '110001',
      ),
      buyerGstin: buyerGstin,
      documentType: EInvoiceDocType.invoice,
      documentNumber: documentNumber,
      documentDate: DateTime(2026, 1, 15),
      supplyType: EInvoiceSupplyType.b2b,
      items: itemList,
      totals: invoiceTotals,
      status: EInvoiceStatus.draft,
    );
  }

  // ── validate ────────────────────────────────────────────────────────

  group('EInvoiceService.validate', () {
    test('valid invoice → empty errors', () {
      final invoice = createValidInvoice();
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isEmpty);
    });

    test('missing seller GSTIN → error', () {
      final invoice = createValidInvoice(sellerGstin: '');
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(
        errors.any(
          (e) =>
              e.toLowerCase().contains('seller') &&
              e.toLowerCase().contains('gstin'),
        ),
        isTrue,
      );
    });

    test('invalid seller GSTIN length → error', () {
      final invoice = createValidInvoice(sellerGstin: '27AAB');
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(
        errors.any(
          (e) =>
              e.toLowerCase().contains('seller') &&
              e.toLowerCase().contains('gstin'),
        ),
        isTrue,
      );
    });

    test('invalid buyer GSTIN → error', () {
      final invoice = createValidInvoice(buyerGstin: 'INVALID');
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(
        errors.any(
          (e) =>
              e.toLowerCase().contains('buyer') &&
              e.toLowerCase().contains('gstin'),
        ),
        isTrue,
      );
    });

    test('no items → error', () {
      final invoice = createValidInvoice(
        items: const [],
        totals: const EInvoiceTotals(
          totalValue: 0,
          totalTaxableValue: 0,
          totalIgst: 0,
          totalCgst: 0,
          totalSgst: 0,
          totalCess: 0,
          totalInvoiceValue: 0,
        ),
      );
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.toLowerCase().contains('item')), isTrue);
    });

    test('item without HSN code → error', () {
      final invoice = createValidInvoice(items: [createItem(hsnCode: '')]);
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.toLowerCase().contains('hsn')), isTrue);
    });

    test('item with HSN code less than 4 digits → error', () {
      final invoice = createValidInvoice(items: [createItem(hsnCode: '84')]);
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.toLowerCase().contains('hsn')), isTrue);
    });

    test('empty document number → error', () {
      final invoice = createValidInvoice(documentNumber: '');
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(
        errors.any((e) => e.toLowerCase().contains('document number')),
        isTrue,
      );
    });

    test('negative amount on item → error', () {
      final invoice = createValidInvoice(
        items: [createItem(taxableValue: -100.0)],
      );
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.toLowerCase().contains('negative')), isTrue);
    });

    test('totals do not match sum of items → error', () {
      final invoice = createValidInvoice(
        items: [createItem()],
        totals: const EInvoiceTotals(
          totalValue: 999999.0,
          totalTaxableValue: 100000.0,
          totalIgst: 18000.0,
          totalCgst: 0.0,
          totalSgst: 0.0,
          totalCess: 0.0,
          totalInvoiceValue: 999999.0,
        ),
      );
      final errors = EInvoiceService.validate(invoice);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.toLowerCase().contains('total')), isTrue);
    });

    test('invalid state code → error', () {
      final invoice = createValidInvoice();
      final badInvoice = invoice.copyWith(
        sellerAddress: createAddress(stateCode: '99'),
      );
      final errors = EInvoiceService.validate(badInvoice);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.toLowerCase().contains('state code')), isTrue);
    });
  });

  // ── calculateTotals ─────────────────────────────────────────────────

  group('EInvoiceService.calculateTotals', () {
    test('sums all items correctly', () {
      final items = [
        createItem(
          taxableValue: 100000.0,
          igst: 18000.0,
          cgst: 0,
          sgst: 0,
          cess: 0,
          totalItemValue: 118000.0,
        ),
        createItem(
          slNo: 2,
          taxableValue: 50000.0,
          igst: 9000.0,
          cgst: 0,
          sgst: 0,
          cess: 500.0,
          totalItemValue: 59500.0,
        ),
      ];

      final totals = EInvoiceService.calculateTotals(items);

      expect(totals.totalTaxableValue, 150000.0);
      expect(totals.totalIgst, 27000.0);
      expect(totals.totalCgst, 0.0);
      expect(totals.totalSgst, 0.0);
      expect(totals.totalCess, 500.0);
      expect(totals.totalInvoiceValue, 177500.0);
    });

    test('empty items → zero totals', () {
      final totals = EInvoiceService.calculateTotals(const []);

      expect(totals.totalTaxableValue, 0.0);
      expect(totals.totalIgst, 0.0);
      expect(totals.totalCgst, 0.0);
      expect(totals.totalSgst, 0.0);
      expect(totals.totalCess, 0.0);
      expect(totals.totalInvoiceValue, 0.0);
      expect(totals.totalValue, 0.0);
    });
  });

  // ── isEInvoiceApplicable ────────────────────────────────────────────

  group('EInvoiceService.isEInvoiceApplicable', () {
    test('turnover 6 crore → true', () {
      expect(EInvoiceService.isEInvoiceApplicable(turnover: 60000000), isTrue);
    });

    test('turnover exactly 5 crore → true', () {
      expect(EInvoiceService.isEInvoiceApplicable(turnover: 50000000), isTrue);
    });

    test('turnover 4 crore → false', () {
      expect(EInvoiceService.isEInvoiceApplicable(turnover: 40000000), isFalse);
    });

    test('turnover 0 → false', () {
      expect(EInvoiceService.isEInvoiceApplicable(turnover: 0), isFalse);
    });
  });

  // ── generateIrnPayload ──────────────────────────────────────────────

  group('EInvoiceService.generateIrnPayload', () {
    test('contains required top-level keys', () {
      final invoice = createValidInvoice();
      final payload = EInvoiceService.generateIrnPayload(invoice);

      expect(payload.containsKey('Version'), isTrue);
      expect(payload.containsKey('TranDtls'), isTrue);
      expect(payload.containsKey('DocDtls'), isTrue);
      expect(payload.containsKey('SellerDtls'), isTrue);
      expect(payload.containsKey('BuyerDtls'), isTrue);
      expect(payload.containsKey('ItemList'), isTrue);
      expect(payload.containsKey('ValDtls'), isTrue);
    });

    test('DocDtls → contains document type, number, date', () {
      final invoice = createValidInvoice();
      final payload = EInvoiceService.generateIrnPayload(invoice);
      final docDtls = payload['DocDtls'] as Map<String, dynamic>;

      expect(docDtls['Typ'], 'INV');
      expect(docDtls['No'], 'INV/2026/001');
      expect(docDtls['Dt'], isNotNull);
    });

    test('SellerDtls → contains GSTIN and address', () {
      final invoice = createValidInvoice();
      final payload = EInvoiceService.generateIrnPayload(invoice);
      final seller = payload['SellerDtls'] as Map<String, dynamic>;

      expect(seller['Gstin'], '27AABCU9603R1ZM');
      expect(seller['LglNm'], 'Test Corp Pvt Ltd');
      expect(seller['Addr1'], '123 Main Street');
    });

    test('BuyerDtls → contains GSTIN and address', () {
      final invoice = createValidInvoice();
      final payload = EInvoiceService.generateIrnPayload(invoice);
      final buyer = payload['BuyerDtls'] as Map<String, dynamic>;

      expect(buyer['Gstin'], '07BBBCU1234D1ZP');
      expect(buyer['LglNm'], 'Buyer Corp');
    });

    test('ItemList → contains correct number of items', () {
      final invoice = createValidInvoice();
      final payload = EInvoiceService.generateIrnPayload(invoice);
      final items = payload['ItemList'] as List<dynamic>;

      expect(items.length, 1);
    });

    test('ValDtls → contains total values', () {
      final invoice = createValidInvoice();
      final payload = EInvoiceService.generateIrnPayload(invoice);
      final valDtls = payload['ValDtls'] as Map<String, dynamic>;

      expect(valDtls['AssVal'], 100000.0);
      expect(valDtls['IgstVal'], 18000.0);
      expect(valDtls['TotInvVal'], 118000.0);
    });
  });
}
