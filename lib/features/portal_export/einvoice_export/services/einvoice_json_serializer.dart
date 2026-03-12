import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_export_result.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/einvoice_validator.dart';

/// Stateless service that maps a [GstInvoice] to the NIC/IRP API v1.03
/// JSON payload and returns an [EInvoiceExportResult].
///
/// Usage:
/// ```dart
/// final result = EInvoiceJsonSerializer.serialize(
///   invoice, sellerGstin, buyerGstin,
/// );
/// if (result.isValid) {
///   // Submit result.requestPayload to the IRP portal.
/// }
/// ```
class EInvoiceJsonSerializer {
  EInvoiceJsonSerializer._();

  /// Serialises [invoice] into an [EInvoiceExportResult].
  ///
  /// Runs validation and populates [EInvoiceExportResult.validationErrors].
  /// [response] is always null — it is populated externally after IRP
  /// submission.
  static EInvoiceExportResult serialize(
    GstInvoice invoice,
    String sellerGstin,
    String buyerGstin,
  ) {
    final request = buildRequest(invoice, sellerGstin, buyerGstin);
    final errors = EInvoiceValidator.validate(request);
    final payload = toJson(request);
    return EInvoiceExportResult(
      requestPayload: payload,
      validationErrors: List.unmodifiable(errors),
      exportedAt: DateTime.now(),
    );
  }

  /// Maps [invoice] to an [EInvoiceRequest] without serialising to JSON.
  ///
  /// Useful when you need to inspect the structured request before serialising.
  static EInvoiceRequest buildRequest(
    GstInvoice invoice,
    String sellerGstin,
    String buyerGstin,
  ) {
    final itemList = _buildItems(invoice.items);
    final valDtls = _buildValueDetails(invoice);

    return EInvoiceRequest(
      tranDtls: EInvoiceTranDetails(
        supTyp: _supplyType(invoice),
        chargeType: invoice.reverseCharge ? 'Y' : 'N',
        igstOnIntra: 'N',
      ),
      docDtls: EInvoiceDocDetails(
        typ: _docType(invoice),
        no: invoice.invoiceNumber,
        dt: invoice.invoiceDate,
      ),
      sellerDtls: EInvoicePartyDetails(
        gstin: sellerGstin,
        legalName: invoice.supplierName,
        address1: '',
        location: '',
        pincode: 0,
        stateCode: _stateCodeFromGstin(sellerGstin),
      ),
      buyerDtls: EInvoicePartyDetails(
        gstin: buyerGstin,
        legalName: invoice.buyerName,
        address1: '',
        location: '',
        pincode: 0,
        stateCode: _stateCodeFromGstin(buyerGstin),
        pos: invoice.placeOfSupply,
      ),
      itemList: itemList,
      valDtls: valDtls,
    );
  }

  /// Serialises [request] to a compact JSON string matching the NIC API spec.
  ///
  /// Key names follow the NIC/IRP v1.03 casing exactly (e.g. "Version",
  /// "TranDtls", "SellerDtls", "ItemList", "ValDtls").
  static String toJson(EInvoiceRequest request) {
    final map = <String, dynamic>{
      'Version': request.version,
      'TranDtls': {
        'TaxSch': 'GST',
        'SupTyp': request.tranDtls.supTyp,
        'RegRev': request.tranDtls.chargeType,
        'IgstOnIntra': request.tranDtls.igstOnIntra,
      },
      'DocDtls': {
        'Typ': request.docDtls.typ,
        'No': request.docDtls.no,
        'Dt': _formatDate(request.docDtls.dt),
      },
      'SellerDtls': _partyToMap(request.sellerDtls),
      'BuyerDtls': _partyToMap(request.buyerDtls, includePosInBuyer: true),
      'ItemList': request.itemList.map(_itemToMap).toList(),
      'ValDtls': {
        'AssVal': request.valDtls.assVal,
        'IgstVal': request.valDtls.igstVal,
        'CgstVal': request.valDtls.cgstVal,
        'SgstVal': request.valDtls.sgstVal,
        'CesVal': request.valDtls.cessVal,
        'TotInvVal': request.valDtls.totInvVal,
      },
    };
    return jsonEncode(map);
  }

  // ── Private helpers ───────────────────────────────────────────────────

  static List<EInvoiceItem> _buildItems(List<GstInvoiceItem> items) {
    return List.generate(items.length, (i) {
      final src = items[i];
      return EInvoiceItem(
        slNo: i + 1,
        prdDesc: src.description,
        isServc: src.itemType == InvoiceItemType.services
            ? EInvoiceIsServc.yes
            : EInvoiceIsServc.no,
        hsnCd: src.hsnSacCode,
        qty: src.quantity,
        unit: src.unit,
        unitPrice: src.unitPrice,
        totAmt: src.quantity * src.unitPrice,
        assAmt: src.taxableValue,
        gstRt: src.gstRate,
        igstAmt: src.igst,
        cgstAmt: src.cgst,
        sgstAmt: src.sgst,
        totItemVal: src.lineTotal,
      );
    });
  }

  static EInvoiceValueDetails _buildValueDetails(GstInvoice invoice) {
    return EInvoiceValueDetails(
      assVal: invoice.totalTaxableValue,
      igstVal: invoice.totalIgst,
      cgstVal: invoice.totalCgst,
      sgstVal: invoice.totalSgst,
      cessVal: invoice.totalCess,
      totInvVal: invoice.grandTotal,
    );
  }

  static String _supplyType(GstInvoice invoice) {
    if (invoice.isExport) return 'EXPWP';
    return 'B2B';
  }

  static String _docType(GstInvoice invoice) => 'INV';

  static String _stateCodeFromGstin(String gstin) =>
      gstin.length >= 2 ? gstin.substring(0, 2) : '00';

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static Map<String, dynamic> _partyToMap(
    EInvoicePartyDetails party, {
    bool includePosInBuyer = false,
  }) {
    final map = <String, dynamic>{
      'Gstin': party.gstin,
      'LglNm': party.legalName,
      if (party.tradeName != null) 'TrdNm': party.tradeName,
      'Addr1': party.address1,
      if (party.address2 != null) 'Addr2': party.address2,
      'Loc': party.location,
      'Pin': party.pincode,
      'Stcd': party.stateCode,
    };
    if (includePosInBuyer && party.pos != null) {
      map['Pos'] = party.pos;
    }
    return map;
  }

  static Map<String, dynamic> _itemToMap(EInvoiceItem item) {
    return {
      'SlNo': '${item.slNo}',
      'PrdDesc': item.prdDesc,
      'IsServc': item.isServc.code,
      'HsnCd': item.hsnCd,
      'Qty': item.qty,
      'Unit': item.unit,
      'UnitPrice': item.unitPrice,
      'TotAmt': item.totAmt,
      'AssAmt': item.assAmt,
      'GstRt': item.gstRt,
      'IgstAmt': item.igstAmt,
      'CgstAmt': item.cgstAmt,
      'SgstAmt': item.sgstAmt,
      'TotItemVal': item.totItemVal,
    };
  }
}
