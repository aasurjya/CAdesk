import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/einvoice_json_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────

  GstInvoice buildGstInvoice({
    String invoiceNumber = 'INV001',
    DateTime? invoiceDate,
    bool isInterState = true,
    bool reverseCharge = false,
    List<GstInvoiceItem>? items,
  }) {
    final date = invoiceDate ?? DateTime(2024, 3, 1);
    final lineItems = items ??
        [
          const GstInvoiceItem(
            description: 'Office Laptop',
            hsnSacCode: '84713010',
            itemType: InvoiceItemType.goods,
            quantity: 1.0,
            unit: 'NOS',
            unitPrice: 1000.0,
            taxableValue: 1000.0,
            gstRate: 18.0,
            igst: 180.0,
            cgst: 0.0,
            sgst: 0.0,
            cess: 0.0,
          ),
        ];
    return GstInvoice(
      id: 'INV-001',
      invoiceNumber: invoiceNumber,
      invoiceDate: date,
      supplierGstin: '29AABCT1332L1ZY',
      supplierName: 'ABC Pvt Ltd',
      supplierStateCode: '29',
      buyerGstin: '36AABCT1332L1ZY',
      buyerName: 'XYZ Ltd',
      buyerStateCode: '36',
      placeOfSupply: '36',
      isInterState: isInterState,
      reverseCharge: reverseCharge,
      isExport: false,
      invoiceType: 'Regular',
      items: lineItems,
    );
  }

  // ── buildRequest ──────────────────────────────────────────────────────

  group('EInvoiceJsonSerializer.buildRequest', () {
    test('version defaults to "1.1"', () {
      final invoice = buildGstInvoice();
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.version, '1.1');
    });

    test('maps invoice number to docDtls.no', () {
      final invoice = buildGstInvoice(invoiceNumber: 'INV/2024/001');
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.docDtls.no, 'INV/2024/001');
    });

    test('maps invoice date to docDtls.dt', () {
      final date = DateTime(2024, 3, 15);
      final invoice = buildGstInvoice(invoiceDate: date);
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.docDtls.dt, date);
    });

    test('maps supplierGstin to sellerDtls.gstin', () {
      final invoice = buildGstInvoice();
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.sellerDtls.gstin, '29AABCT1332L1ZY');
    });

    test('maps buyerGstin to buyerDtls.gstin', () {
      final invoice = buildGstInvoice();
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.buyerDtls.gstin, '36AABCT1332L1ZY');
    });

    test('maps goods item with IsServc = N', () {
      final invoice = buildGstInvoice();
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.itemList.first.isServc, EInvoiceIsServc.no);
    });

    test('maps service item with IsServc = Y', () {
      final invoice = buildGstInvoice(
        items: [
          const GstInvoiceItem(
            description: 'Consulting',
            hsnSacCode: '9983',
            itemType: InvoiceItemType.services,
            quantity: 1.0,
            unit: 'NOS',
            unitPrice: 5000.0,
            taxableValue: 5000.0,
            gstRate: 18.0,
            igst: 900.0,
            cgst: 0.0,
            sgst: 0.0,
            cess: 0.0,
          ),
        ],
      );
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.itemList.first.isServc, EInvoiceIsServc.yes);
    });

    test('inter-state invoice sets supTyp to B2B', () {
      final invoice = buildGstInvoice(isInterState: true);
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.tranDtls.supTyp, 'B2B');
    });

    test('reverse charge sets chargeType to Y', () {
      final invoice = buildGstInvoice(reverseCharge: true);
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(req.tranDtls.chargeType, 'Y');
    });

    test('valDtls totals match sum of items', () {
      final invoice = buildGstInvoice();
      final req = EInvoiceJsonSerializer.buildRequest(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      final itemAssTotal =
          req.itemList.fold(0.0, (s, i) => s + i.assAmt);
      expect(req.valDtls.assVal, closeTo(itemAssTotal, 0.01));
    });
  });

  // ── toJson ────────────────────────────────────────────────────────────

  group('EInvoiceJsonSerializer.toJson', () {
    late EInvoiceRequest request;

    setUp(() {
      request = EInvoiceRequest(
        tranDtls: const EInvoiceTranDetails(
          supTyp: 'B2B',
          chargeType: 'N',
          igstOnIntra: 'N',
        ),
        docDtls: EInvoiceDocDetails(
          typ: 'INV',
          no: 'INV001',
          dt: DateTime(2024, 3, 1),
        ),
        sellerDtls: const EInvoicePartyDetails(
          gstin: '29AABCT1332L1ZY',
          legalName: 'ABC Pvt Ltd',
          address1: '123 Main St',
          location: 'Bengaluru',
          pincode: 560001,
          stateCode: '29',
        ),
        buyerDtls: const EInvoicePartyDetails(
          gstin: '36AABCT1332L1ZY',
          legalName: 'XYZ Ltd',
          address1: '456 Other St',
          location: 'Hyderabad',
          pincode: 500001,
          stateCode: '36',
          pos: '36',
        ),
        itemList: const [
          EInvoiceItem(
            slNo: 1,
            prdDesc: 'Office Chair',
            isServc: EInvoiceIsServc.no,
            hsnCd: '940130',
            qty: 1.0,
            unit: 'NOS',
            unitPrice: 1000.0,
            totAmt: 1000.0,
            assAmt: 1000.0,
            gstRt: 18.0,
            igstAmt: 180.0,
            cgstAmt: 0.0,
            sgstAmt: 0.0,
            totItemVal: 1180.0,
          ),
        ],
        valDtls: const EInvoiceValueDetails(
          assVal: 1000.0,
          igstVal: 180.0,
          cgstVal: 0.0,
          sgstVal: 0.0,
          totInvVal: 1180.0,
        ),
      );
    });

    test('toJson returns valid JSON string', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      expect(() => jsonDecode(json), returnsNormally);
    });

    test('JSON contains Version field with value "1.1"', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['Version'], '1.1');
    });

    test('JSON contains TranDtls with TaxSch = GST', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final tran = map['TranDtls'] as Map<String, dynamic>;
      expect(tran['TaxSch'], 'GST');
    });

    test('JSON contains DocDtls with Typ, No, Dt', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final doc = map['DocDtls'] as Map<String, dynamic>;
      expect(doc['Typ'], 'INV');
      expect(doc['No'], 'INV001');
      expect(doc['Dt'], '01/03/2024');
    });

    test('JSON date format is DD/MM/YYYY', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final doc = map['DocDtls'] as Map<String, dynamic>;
      expect(doc['Dt'], matches(RegExp(r'^\d{2}/\d{2}/\d{4}$')));
    });

    test('JSON SellerDtls contains correct Gstin', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final seller = map['SellerDtls'] as Map<String, dynamic>;
      expect(seller['Gstin'], '29AABCT1332L1ZY');
    });

    test('JSON BuyerDtls contains Pos field', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final buyer = map['BuyerDtls'] as Map<String, dynamic>;
      expect(buyer['Pos'], '36');
    });

    test('JSON ItemList has correct SlNo as string', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final items = map['ItemList'] as List<dynamic>;
      final firstItem = items.first as Map<String, dynamic>;
      expect(firstItem['SlNo'], '1');
    });

    test('JSON ItemList IsServc is "N" for goods', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final items = map['ItemList'] as List<dynamic>;
      final firstItem = items.first as Map<String, dynamic>;
      expect(firstItem['IsServc'], 'N');
    });

    test('JSON ValDtls contains AssVal', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final val = map['ValDtls'] as Map<String, dynamic>;
      expect(val['AssVal'], 1000.0);
    });

    test('JSON ValDtls contains TotInvVal', () {
      final json = EInvoiceJsonSerializer.toJson(request);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final val = map['ValDtls'] as Map<String, dynamic>;
      expect(val['TotInvVal'], 1180.0);
    });
  });

  // ── serialize ────────────────────────────────────────────────────────

  group('EInvoiceJsonSerializer.serialize', () {
    test('returns result with non-empty requestPayload', () {
      final invoice = buildGstInvoice();
      final result = EInvoiceJsonSerializer.serialize(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(result.requestPayload, isNotEmpty);
    });

    test('returns result with null response (not yet submitted)', () {
      final invoice = buildGstInvoice();
      final result = EInvoiceJsonSerializer.serialize(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(result.response, isNull);
    });

    test('returns result with exportedAt set', () {
      final invoice = buildGstInvoice();
      final before = DateTime.now();
      final result = EInvoiceJsonSerializer.serialize(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      final after = DateTime.now();
      expect(
        result.exportedAt.isAfter(before) ||
            result.exportedAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        result.exportedAt.isBefore(after) ||
            result.exportedAt.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('validation errors list is empty for valid invoice', () {
      final invoice = buildGstInvoice();
      final result = EInvoiceJsonSerializer.serialize(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(result.validationErrors, isEmpty);
    });

    test('validation errors list is non-empty for bad invoice number', () {
      final invoice = buildGstInvoice(invoiceNumber: 'INV NUMBER INVALID!@#');
      final result = EInvoiceJsonSerializer.serialize(
        invoice,
        '29AABCT1332L1ZY',
        '36AABCT1332L1ZY',
      );
      expect(result.validationErrors, isNotEmpty);
    });
  });
}
