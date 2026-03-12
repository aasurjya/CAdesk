import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/eway_bill_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────

  EInvoiceRequest _buildRequest({
    double totInvVal = 60000.0,
    double igstVal = 0.0,
    EInvoiceIsServc isServc = EInvoiceIsServc.no,
    String sellerStateCode = '29',
    String buyerStateCode = '36',
  }) {
    return EInvoiceRequest(
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
      sellerDtls: EInvoicePartyDetails(
        gstin: '${sellerStateCode}AABCT1332L1ZY',
        legalName: 'ABC Pvt Ltd',
        address1: '123 Main St',
        location: 'Bengaluru',
        pincode: 560001,
        stateCode: sellerStateCode,
      ),
      buyerDtls: EInvoicePartyDetails(
        gstin: '${buyerStateCode}AABCT1332L1ZY',
        legalName: 'XYZ Ltd',
        address1: '456 Other St',
        location: 'Hyderabad',
        pincode: 500001,
        stateCode: buyerStateCode,
      ),
      itemList: [
        EInvoiceItem(
          slNo: 1,
          prdDesc: 'Office Chair',
          isServc: isServc,
          hsnCd: '940130',
          qty: 1.0,
          unit: 'NOS',
          unitPrice: totInvVal,
          totAmt: totInvVal,
          assAmt: totInvVal,
          gstRt: 0.0,
          igstAmt: igstVal,
          cgstAmt: 0.0,
          sgstAmt: 0.0,
          totItemVal: totInvVal + igstVal,
        ),
      ],
      valDtls: EInvoiceValueDetails(
        assVal: totInvVal,
        igstVal: igstVal,
        cgstVal: 0.0,
        sgstVal: 0.0,
        totInvVal: totInvVal + igstVal,
      ),
    );
  }

  // ── isEWayBillRequired ────────────────────────────────────────────────

  group('EWayBillService.isEWayBillRequired', () {
    test('returns true when value > 50000 with goods and interstate', () {
      final req = _buildRequest(totInvVal: 60000.0);
      expect(EWayBillService.isEWayBillRequired(req), isTrue);
    });

    test('returns false when value <= 50000', () {
      final req = _buildRequest(totInvVal: 40000.0);
      expect(EWayBillService.isEWayBillRequired(req), isFalse);
    });

    test('returns false when all items are services', () {
      final req = _buildRequest(
        totInvVal: 60000.0,
        isServc: EInvoiceIsServc.yes,
      );
      expect(EWayBillService.isEWayBillRequired(req), isFalse);
    });

    test('returns true when value exactly 50001', () {
      final req = _buildRequest(totInvVal: 50001.0);
      expect(EWayBillService.isEWayBillRequired(req), isTrue);
    });
  });

  // ── computeDistance ───────────────────────────────────────────────────

  group('EWayBillService.computeDistance', () {
    test('returns 100 for any two pincodes (mock)', () {
      expect(EWayBillService.computeDistance('560001', '500001'), 100);
    });

    test('returns 100 even for same pincode (mock)', () {
      expect(EWayBillService.computeDistance('560001', '560001'), 100);
    });
  });

  // ── buildEWayBillPayload ──────────────────────────────────────────────

  group('EWayBillService.buildEWayBillPayload', () {
    test('returns map with required keys', () {
      final req = _buildRequest(totInvVal: 60000.0);
      final payload = EWayBillService.buildEWayBillPayload(
        req,
        '1',
        'KA01AB1234',
      );
      expect(payload, containsPair('supplyType', anything));
      expect(payload, containsPair('docType', anything));
      expect(payload, containsPair('docNo', 'INV001'));
      expect(payload, containsPair('fromGstin', anything));
      expect(payload, containsPair('toGstin', anything));
      expect(payload, containsPair('transMode', '1'));
      expect(payload, containsPair('vehicleNo', 'KA01AB1234'));
      expect(payload, containsPair('totInvValue', anything));
    });

    test('docNo matches invoice number', () {
      final req = _buildRequest(totInvVal: 60000.0);
      final payload = EWayBillService.buildEWayBillPayload(req, '1', 'VH0001');
      expect(payload['docNo'], equals('INV001'));
    });

    test('fromGstin matches seller GSTIN', () {
      final req = _buildRequest(totInvVal: 60000.0);
      final payload = EWayBillService.buildEWayBillPayload(req, '1', 'VH0001');
      expect(payload['fromGstin'], equals(req.sellerDtls.gstin));
    });

    test('toGstin matches buyer GSTIN', () {
      final req = _buildRequest(totInvVal: 60000.0);
      final payload = EWayBillService.buildEWayBillPayload(req, '1', 'VH0001');
      expect(payload['toGstin'], equals(req.buyerDtls.gstin));
    });
  });
}
