import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/irn_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── generateIrn ───────────────────────────────────────────────────────

  group('IrnGenerator.generateIrn', () {
    test('returns 64-character hex string', () {
      final irn = IrnGenerator.generateIrn(
        sellerGstin: '29AABCT1332L1ZY',
        docType: 'INV',
        docNumber: 'INV001',
        docDate: '01/03/2024',
      );
      expect(irn.length, 64);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(irn), isTrue);
    });

    test('same inputs always produce same IRN (deterministic)', () {
      const gstin = '29AABCT1332L1ZY';
      const docType = 'INV';
      const docNumber = 'INV001';
      const docDate = '01/03/2024';

      final irn1 = IrnGenerator.generateIrn(
        sellerGstin: gstin,
        docType: docType,
        docNumber: docNumber,
        docDate: docDate,
      );
      final irn2 = IrnGenerator.generateIrn(
        sellerGstin: gstin,
        docType: docType,
        docNumber: docNumber,
        docDate: docDate,
      );
      expect(irn1, equals(irn2));
    });

    test('different inputs produce different IRNs', () {
      final irn1 = IrnGenerator.generateIrn(
        sellerGstin: '29AABCT1332L1ZY',
        docType: 'INV',
        docNumber: 'INV001',
        docDate: '01/03/2024',
      );
      final irn2 = IrnGenerator.generateIrn(
        sellerGstin: '36AABCT1332L1ZY',
        docType: 'INV',
        docNumber: 'INV001',
        docDate: '01/03/2024',
      );
      expect(irn1, isNot(equals(irn2)));
    });

    test('different doc numbers produce different IRNs', () {
      final irn1 = IrnGenerator.generateIrn(
        sellerGstin: '29AABCT1332L1ZY',
        docType: 'INV',
        docNumber: 'INV001',
        docDate: '01/03/2024',
      );
      final irn2 = IrnGenerator.generateIrn(
        sellerGstin: '29AABCT1332L1ZY',
        docType: 'INV',
        docNumber: 'INV002',
        docDate: '01/03/2024',
      );
      expect(irn1, isNot(equals(irn2)));
    });
  });

  // ── generateQrData ────────────────────────────────────────────────────

  group('IrnGenerator.generateQrData', () {
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

    test('generateQrData returns a non-empty string', () {
      const irn =
          'abc123def456abc123def456abc123def456abc123def456abc123def456abc1';
      final qrData = IrnGenerator.generateQrData(request, irn);
      expect(qrData, isNotEmpty);
    });

    test('QR data contains seller GSTIN', () {
      const irn =
          'abc123def456abc123def456abc123def456abc123def456abc123def456abc1';
      final qrData = IrnGenerator.generateQrData(request, irn);
      expect(qrData, contains('29AABCT1332L1ZY'));
    });

    test('QR data contains buyer GSTIN', () {
      const irn =
          'abc123def456abc123def456abc123def456abc123def456abc123def456abc1';
      final qrData = IrnGenerator.generateQrData(request, irn);
      expect(qrData, contains('36AABCT1332L1ZY'));
    });

    test('QR data contains IRN', () {
      const irn =
          'abc123def456abc123def456abc123def456abc123def456abc123def456abc1';
      final qrData = IrnGenerator.generateQrData(request, irn);
      expect(qrData, contains(irn));
    });

    test('QR data contains doc number', () {
      const irn =
          'abc123def456abc123def456abc123def456abc123def456abc123def456abc1';
      final qrData = IrnGenerator.generateQrData(request, irn);
      expect(qrData, contains('INV001'));
    });

    test('QR data contains total invoice value', () {
      const irn =
          'abc123def456abc123def456abc123def456abc123def456abc123def456abc1';
      final qrData = IrnGenerator.generateQrData(request, irn);
      expect(qrData, contains('1180'));
    });
  });
}
