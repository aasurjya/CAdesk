import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';

/// Transaction details for the NIC/IRP e-invoice payload.
///
/// [supTyp] supply type code: 'B2B', 'B2C', 'EXPWP', 'EXPWOP', 'SEZWP',
/// 'SEZWOP', 'DEXP'.
/// [chargeType] reverse charge: 'Y' or 'N'.
/// [igstOnIntra] IGST on intra-state supply: 'Y' or 'N'.
class EInvoiceTranDetails {
  const EInvoiceTranDetails({
    required this.supTyp,
    required this.chargeType,
    required this.igstOnIntra,
  });

  final String supTyp;
  final String chargeType;
  final String igstOnIntra;

  EInvoiceTranDetails copyWith({
    String? supTyp,
    String? chargeType,
    String? igstOnIntra,
  }) {
    return EInvoiceTranDetails(
      supTyp: supTyp ?? this.supTyp,
      chargeType: chargeType ?? this.chargeType,
      igstOnIntra: igstOnIntra ?? this.igstOnIntra,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceTranDetails &&
          runtimeType == other.runtimeType &&
          supTyp == other.supTyp &&
          chargeType == other.chargeType &&
          igstOnIntra == other.igstOnIntra;

  @override
  int get hashCode => Object.hash(supTyp, chargeType, igstOnIntra);
}

/// Document details — type, number, and date.
///
/// [typ] document type: 'INV' (invoice), 'CRN' (credit note), 'DBN' (debit).
/// [no] invoice number (max 16 alphanumeric chars plus / and -).
/// [dt] invoice date (serialised as DD/MM/YYYY in JSON output).
class EInvoiceDocDetails {
  EInvoiceDocDetails({required this.typ, required this.no, required this.dt});

  final String typ;
  final String no;
  final DateTime dt;

  EInvoiceDocDetails copyWith({String? typ, String? no, DateTime? dt}) {
    return EInvoiceDocDetails(
      typ: typ ?? this.typ,
      no: no ?? this.no,
      dt: dt ?? this.dt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceDocDetails &&
          runtimeType == other.runtimeType &&
          typ == other.typ &&
          no == other.no &&
          dt == other.dt;

  @override
  int get hashCode => Object.hash(typ, no, dt);
}

/// Party details (seller or buyer) for the NIC/IRP e-invoice payload.
///
/// [gstin] must be exactly 15 characters.
/// [stateCode] is the first 2 digits of the GSTIN.
/// [pos] place of supply (required for buyer details in the NIC API).
class EInvoicePartyDetails {
  const EInvoicePartyDetails({
    required this.gstin,
    required this.legalName,
    required this.address1,
    required this.location,
    required this.pincode,
    required this.stateCode,
    this.tradeName,
    this.address2,
    this.pos,
  });

  final String gstin;
  final String legalName;
  final String? tradeName;
  final String address1;
  final String? address2;
  final String location;
  final int pincode;
  final String stateCode;

  /// Place of supply state code — required in BuyerDtls per NIC API spec.
  final String? pos;

  EInvoicePartyDetails copyWith({
    String? gstin,
    String? legalName,
    String? tradeName,
    String? address1,
    String? address2,
    String? location,
    int? pincode,
    String? stateCode,
    String? pos,
  }) {
    return EInvoicePartyDetails(
      gstin: gstin ?? this.gstin,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      location: location ?? this.location,
      pincode: pincode ?? this.pincode,
      stateCode: stateCode ?? this.stateCode,
      pos: pos ?? this.pos,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoicePartyDetails &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          legalName == other.legalName;

  @override
  int get hashCode => Object.hash(gstin, legalName);
}

/// Invoice-level monetary totals for the NIC/IRP e-invoice payload.
///
/// All values in Indian Rupees (double, 2 decimal places).
class EInvoiceValueDetails {
  const EInvoiceValueDetails({
    required this.assVal,
    required this.igstVal,
    required this.cgstVal,
    required this.sgstVal,
    required this.totInvVal,
    this.cessVal = 0.0,
  });

  /// Total assessable (taxable) value across all items.
  final double assVal;

  /// Total IGST amount.
  final double igstVal;

  /// Total CGST amount.
  final double cgstVal;

  /// Total SGST/UTGST amount.
  final double sgstVal;

  /// Total compensation cess amount.
  final double cessVal;

  /// Grand total invoice value = assVal + igstVal + cgstVal + sgstVal + cessVal.
  final double totInvVal;

  EInvoiceValueDetails copyWith({
    double? assVal,
    double? igstVal,
    double? cgstVal,
    double? sgstVal,
    double? cessVal,
    double? totInvVal,
  }) {
    return EInvoiceValueDetails(
      assVal: assVal ?? this.assVal,
      igstVal: igstVal ?? this.igstVal,
      cgstVal: cgstVal ?? this.cgstVal,
      sgstVal: sgstVal ?? this.sgstVal,
      cessVal: cessVal ?? this.cessVal,
      totInvVal: totInvVal ?? this.totInvVal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceValueDetails &&
          runtimeType == other.runtimeType &&
          assVal == other.assVal &&
          totInvVal == other.totInvVal;

  @override
  int get hashCode => Object.hash(assVal, totInvVal);
}

/// Immutable root payload for the NIC/IRP e-invoice API v1.03.
///
/// This is the complete JSON structure submitted to the IRP portal to obtain
/// an Invoice Reference Number (IRN). The [version] field defaults to "1.1"
/// per the current NIC API specification.
class EInvoiceRequest {
  EInvoiceRequest({
    required this.tranDtls,
    required this.docDtls,
    required this.sellerDtls,
    required this.buyerDtls,
    required this.itemList,
    required this.valDtls,
    this.version = '1.1',
  });

  /// API version — defaults to "1.1" per NIC IRP spec.
  final String version;

  final EInvoiceTranDetails tranDtls;
  final EInvoiceDocDetails docDtls;
  final EInvoicePartyDetails sellerDtls;
  final EInvoicePartyDetails buyerDtls;

  /// List of line items — must contain at least one item.
  final List<EInvoiceItem> itemList;

  final EInvoiceValueDetails valDtls;

  EInvoiceRequest copyWith({
    String? version,
    EInvoiceTranDetails? tranDtls,
    EInvoiceDocDetails? docDtls,
    EInvoicePartyDetails? sellerDtls,
    EInvoicePartyDetails? buyerDtls,
    List<EInvoiceItem>? itemList,
    EInvoiceValueDetails? valDtls,
  }) {
    return EInvoiceRequest(
      version: version ?? this.version,
      tranDtls: tranDtls ?? this.tranDtls,
      docDtls: docDtls ?? this.docDtls,
      sellerDtls: sellerDtls ?? this.sellerDtls,
      buyerDtls: buyerDtls ?? this.buyerDtls,
      itemList: itemList ?? this.itemList,
      valDtls: valDtls ?? this.valDtls,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceRequest &&
          runtimeType == other.runtimeType &&
          docDtls == other.docDtls &&
          sellerDtls == other.sellerDtls;

  @override
  int get hashCode => Object.hash(docDtls, sellerDtls);
}
