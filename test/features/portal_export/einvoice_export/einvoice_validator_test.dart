import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/einvoice_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────

  EInvoicePartyDetails seller({
    String gstin = '29AABCT1332L1ZY',
    String legalName = 'ABC Pvt Ltd',
    String address1 = '123 Main St',
    String location = 'Bengaluru',
    int pincode = 560001,
    String stateCode = '29',
  }) {
    return EInvoicePartyDetails(
      gstin: gstin,
      legalName: legalName,
      address1: address1,
      location: location,
      pincode: pincode,
      stateCode: stateCode,
    );
  }

  EInvoicePartyDetails buyer({
    String gstin = '36AABCT1332L1ZY',
    String legalName = 'XYZ Ltd',
    String address1 = '456 Other St',
    String location = 'Hyderabad',
    int pincode = 500001,
    String stateCode = '36',
    String? pos,
  }) {
    return EInvoicePartyDetails(
      gstin: gstin,
      legalName: legalName,
      address1: address1,
      location: location,
      pincode: pincode,
      stateCode: stateCode,
      pos: pos,
    );
  }

  EInvoiceItem makeItem({
    int slNo = 1,
    String prdDesc = 'Office Chair',
    EInvoiceIsServc isServc = EInvoiceIsServc.no,
    String hsnCd = '940130',
    double qty = 2.0,
    String unit = 'NOS',
    double unitPrice = 5000.0,
    double totAmt = 10000.0,
    double assAmt = 10000.0,
    double gstRt = 18.0,
    double igstAmt = 1800.0,
    double cgstAmt = 0.0,
    double sgstAmt = 0.0,
    double totItemVal = 11800.0,
  }) {
    return EInvoiceItem(
      slNo: slNo,
      prdDesc: prdDesc,
      isServc: isServc,
      hsnCd: hsnCd,
      qty: qty,
      unit: unit,
      unitPrice: unitPrice,
      totAmt: totAmt,
      assAmt: assAmt,
      gstRt: gstRt,
      igstAmt: igstAmt,
      cgstAmt: cgstAmt,
      sgstAmt: sgstAmt,
      totItemVal: totItemVal,
    );
  }

  EInvoiceRequest validRequest({
    List<EInvoiceItem>? items,
    EInvoicePartyDetails? sellerDtls,
    EInvoicePartyDetails? buyerDtls,
    EInvoiceDocDetails? docDtls,
    EInvoiceValueDetails? valDtls,
  }) {
    final itemList = items ?? [makeItem()];
    return EInvoiceRequest(
      tranDtls: const EInvoiceTranDetails(
        supTyp: 'B2B',
        chargeType: 'N',
        igstOnIntra: 'N',
      ),
      docDtls: docDtls ??
          EInvoiceDocDetails(
            typ: 'INV',
            no: 'INV001',
            dt: DateTime(2024, 3, 1),
          ),
      sellerDtls: sellerDtls ?? seller(),
      buyerDtls: buyerDtls ?? buyer(),
      itemList: itemList,
      valDtls: valDtls ??
          EInvoiceValueDetails(
            assVal: itemList.fold(0.0, (s, i) => s + i.assAmt),
            igstVal: itemList.fold(0.0, (s, i) => s + i.igstAmt),
            cgstVal: itemList.fold(0.0, (s, i) => s + i.cgstAmt),
            sgstVal: itemList.fold(0.0, (s, i) => s + i.sgstAmt),
            totInvVal: itemList.fold(0.0, (s, i) => s + i.totItemVal),
          ),
    );
  }

  // ── validateGstin ────────────────────────────────────────────────────

  group('EInvoiceValidator.validateGstin', () {
    test('returns true for valid 15-char GSTIN', () {
      expect(EInvoiceValidator.validateGstin('29AABCT1332L1ZY'), isTrue);
    });

    test('returns false when GSTIN is shorter than 15 chars', () {
      expect(EInvoiceValidator.validateGstin('29AABCT1332L1Z'), isFalse);
    });

    test('returns false when GSTIN is longer than 15 chars', () {
      expect(EInvoiceValidator.validateGstin('29AABCT1332L1ZYX'), isFalse);
    });

    test('returns false for empty string', () {
      expect(EInvoiceValidator.validateGstin(''), isFalse);
    });
  });

  // ── validateHsn ──────────────────────────────────────────────────────

  group('EInvoiceValidator.validateHsn', () {
    test('returns true for 4-digit HSN', () {
      expect(EInvoiceValidator.validateHsn('9954'), isTrue);
    });

    test('returns true for 6-digit HSN', () {
      expect(EInvoiceValidator.validateHsn('940130'), isTrue);
    });

    test('returns true for 8-digit HSN', () {
      expect(EInvoiceValidator.validateHsn('84713010'), isTrue);
    });

    test('returns false for 3-digit code', () {
      expect(EInvoiceValidator.validateHsn('994'), isFalse);
    });

    test('returns false for 5-digit code', () {
      expect(EInvoiceValidator.validateHsn('94013'), isFalse);
    });

    test('returns false for 7-digit code', () {
      expect(EInvoiceValidator.validateHsn('9401300'), isFalse);
    });

    test('returns false for empty string', () {
      expect(EInvoiceValidator.validateHsn(''), isFalse);
    });

    test('returns false for non-numeric', () {
      expect(EInvoiceValidator.validateHsn('ABCD'), isFalse);
    });
  });

  // ── validateInvoiceNumber ────────────────────────────────────────────

  group('EInvoiceValidator.validateInvoiceNumber', () {
    test('returns true for alphanumeric invoice number', () {
      expect(EInvoiceValidator.validateInvoiceNumber('INV001'), isTrue);
    });

    test('returns true for invoice number with slash', () {
      expect(EInvoiceValidator.validateInvoiceNumber('INV/2024/001'), isTrue);
    });

    test('returns true for invoice number with hyphen', () {
      expect(EInvoiceValidator.validateInvoiceNumber('INV-2024-001'), isTrue);
    });

    test('returns true for max length 16 chars', () {
      expect(
        EInvoiceValidator.validateInvoiceNumber('ABCDEFGHIJ123456'),
        isTrue,
      );
    });

    test('returns false for empty invoice number', () {
      expect(EInvoiceValidator.validateInvoiceNumber(''), isFalse);
    });

    test('returns false for invoice number > 16 chars', () {
      expect(
        EInvoiceValidator.validateInvoiceNumber('ABCDEFGHIJ1234567'),
        isFalse,
      );
    });

    test('returns false for invoice number with space', () {
      expect(EInvoiceValidator.validateInvoiceNumber('INV 001'), isFalse);
    });

    test('returns false for invoice number with special char @', () {
      expect(EInvoiceValidator.validateInvoiceNumber('INV@001'), isFalse);
    });
  });

  // ── validate (full request) ──────────────────────────────────────────

  group('EInvoiceValidator.validate', () {
    test('returns empty list for valid request', () {
      final errors = EInvoiceValidator.validate(validRequest());
      expect(errors, isEmpty);
    });

    test('returns error for invalid seller GSTIN', () {
      final req = validRequest(sellerDtls: seller(gstin: 'SHORT'));
      final errors = EInvoiceValidator.validate(req);
      expect(errors, anyElement(contains('Seller GSTIN')));
    });

    test('returns error for invalid buyer GSTIN', () {
      final req = validRequest(buyerDtls: buyer(gstin: 'TOOSHORT'));
      final errors = EInvoiceValidator.validate(req);
      expect(errors, anyElement(contains('Buyer GSTIN')));
    });

    test('returns error for invalid invoice number', () {
      final req = validRequest(
        docDtls: EInvoiceDocDetails(
          typ: 'INV',
          no: 'INV NUMBER WITH SPACES!!',
          dt: DateTime(2024, 3, 1),
        ),
      );
      final errors = EInvoiceValidator.validate(req);
      expect(errors, anyElement(contains('invoice number')));
    });

    test('returns error for future invoice date', () {
      final req = validRequest(
        docDtls: EInvoiceDocDetails(
          typ: 'INV',
          no: 'INV001',
          dt: DateTime.now().add(const Duration(days: 10)),
        ),
      );
      final errors = EInvoiceValidator.validate(req);
      expect(errors, anyElement(contains('future')));
    });

    test('returns error for invalid HSN code in item', () {
      final badItem = makeItem(hsnCd: '12');
      final req = validRequest(items: [badItem]);
      final errors = EInvoiceValidator.validate(req);
      expect(errors, anyElement(contains('HSN')));
    });

    test('returns error when item totals do not match valDtls', () {
      final req = validRequest(
        valDtls: const EInvoiceValueDetails(
          assVal: 999.0,
          igstVal: 0.0,
          cgstVal: 0.0,
          sgstVal: 0.0,
          totInvVal: 999.0,
        ),
      );
      final errors = EInvoiceValidator.validate(req);
      expect(errors, isNotEmpty);
    });

    test('returns no error for single-item B2B with correct totals', () {
      final item = makeItem(
        hsnCd: '8471',
        assAmt: 1000.0,
        igstAmt: 180.0,
        cgstAmt: 0.0,
        sgstAmt: 0.0,
        totItemVal: 1180.0,
        gstRt: 18.0,
      );
      final req = validRequest(
        items: [item],
        valDtls: const EInvoiceValueDetails(
          assVal: 1000.0,
          igstVal: 180.0,
          cgstVal: 0.0,
          sgstVal: 0.0,
          totInvVal: 1180.0,
        ),
      );
      final errors = EInvoiceValidator.validate(req);
      expect(errors, isEmpty);
    });
  });
}
