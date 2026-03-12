/// Document type for e-invoicing.
enum EInvoiceDocType {
  invoice(label: 'Invoice', code: 'INV'),
  creditNote(label: 'Credit Note', code: 'CRN'),
  debitNote(label: 'Debit Note', code: 'DBN');

  const EInvoiceDocType({required this.label, required this.code});
  final String label;
  final String code;
}

/// Supply type for e-invoicing.
enum EInvoiceSupplyType {
  b2b(label: 'B2B', code: 'B2B'),
  sez(label: 'SEZ', code: 'SEZWP'),
  export(label: 'Export', code: 'EXPWP'),
  deemedExport(label: 'Deemed Export', code: 'DEXP');

  const EInvoiceSupplyType({required this.label, required this.code});
  final String label;
  final String code;
}

/// Status of an e-invoice in its lifecycle.
enum EInvoiceStatus {
  draft(label: 'Draft'),
  generated(label: 'Generated'),
  cancelled(label: 'Cancelled');

  const EInvoiceStatus({required this.label});
  final String label;
}

/// Immutable address details for e-invoicing (seller or buyer).
class EInvoiceAddress {
  const EInvoiceAddress({
    required this.legalName,
    this.tradeName,
    required this.address1,
    this.address2,
    required this.city,
    required this.state,
    required this.stateCode,
    required this.pincode,
  });

  final String legalName;
  final String? tradeName;
  final String address1;
  final String? address2;
  final String city;
  final String state;
  final String stateCode;
  final String pincode;

  EInvoiceAddress copyWith({
    String? legalName,
    String? tradeName,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? stateCode,
    String? pincode,
  }) {
    return EInvoiceAddress(
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      pincode: pincode ?? this.pincode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceAddress &&
          runtimeType == other.runtimeType &&
          legalName == other.legalName &&
          tradeName == other.tradeName &&
          address1 == other.address1 &&
          address2 == other.address2 &&
          city == other.city &&
          state == other.state &&
          stateCode == other.stateCode &&
          pincode == other.pincode;

  @override
  int get hashCode => Object.hash(
        legalName,
        tradeName,
        address1,
        address2,
        city,
        state,
        stateCode,
        pincode,
      );
}

/// Immutable line item in an e-invoice.
class EInvoiceItem {
  const EInvoiceItem({
    required this.slNo,
    required this.productDescription,
    required this.hsnCode,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.discount,
    required this.taxableValue,
    required this.gstRate,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.totalItemValue,
  });

  final int slNo;
  final String productDescription;
  final String hsnCode;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double discount;
  final double taxableValue;
  final double gstRate;
  final double igst;
  final double cgst;
  final double sgst;
  final double cess;
  final double totalItemValue;

  EInvoiceItem copyWith({
    int? slNo,
    String? productDescription,
    String? hsnCode,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? discount,
    double? taxableValue,
    double? gstRate,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? totalItemValue,
  }) {
    return EInvoiceItem(
      slNo: slNo ?? this.slNo,
      productDescription: productDescription ?? this.productDescription,
      hsnCode: hsnCode ?? this.hsnCode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      taxableValue: taxableValue ?? this.taxableValue,
      gstRate: gstRate ?? this.gstRate,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      totalItemValue: totalItemValue ?? this.totalItemValue,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceItem &&
          runtimeType == other.runtimeType &&
          slNo == other.slNo &&
          productDescription == other.productDescription &&
          hsnCode == other.hsnCode &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice &&
          taxableValue == other.taxableValue &&
          totalItemValue == other.totalItemValue;

  @override
  int get hashCode => Object.hash(
        slNo,
        productDescription,
        hsnCode,
        quantity,
        unitPrice,
        taxableValue,
        totalItemValue,
      );
}

/// Immutable totals for an e-invoice.
class EInvoiceTotals {
  const EInvoiceTotals({
    required this.totalValue,
    required this.totalTaxableValue,
    required this.totalIgst,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalCess,
    required this.totalInvoiceValue,
  });

  final double totalValue;
  final double totalTaxableValue;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final double totalCess;
  final double totalInvoiceValue;

  EInvoiceTotals copyWith({
    double? totalValue,
    double? totalTaxableValue,
    double? totalIgst,
    double? totalCgst,
    double? totalSgst,
    double? totalCess,
    double? totalInvoiceValue,
  }) {
    return EInvoiceTotals(
      totalValue: totalValue ?? this.totalValue,
      totalTaxableValue: totalTaxableValue ?? this.totalTaxableValue,
      totalIgst: totalIgst ?? this.totalIgst,
      totalCgst: totalCgst ?? this.totalCgst,
      totalSgst: totalSgst ?? this.totalSgst,
      totalCess: totalCess ?? this.totalCess,
      totalInvoiceValue: totalInvoiceValue ?? this.totalInvoiceValue,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceTotals &&
          runtimeType == other.runtimeType &&
          totalValue == other.totalValue &&
          totalTaxableValue == other.totalTaxableValue &&
          totalIgst == other.totalIgst &&
          totalCgst == other.totalCgst &&
          totalSgst == other.totalSgst &&
          totalCess == other.totalCess &&
          totalInvoiceValue == other.totalInvoiceValue;

  @override
  int get hashCode => Object.hash(
        totalValue,
        totalTaxableValue,
        totalIgst,
        totalCgst,
        totalSgst,
        totalCess,
        totalInvoiceValue,
      );
}

/// Immutable model representing a complete e-invoice (IRN-ready).
class EInvoice {
  const EInvoice({
    this.irn,
    this.ackNumber,
    this.ackDate,
    required this.sellerAddress,
    required this.sellerGstin,
    required this.buyerAddress,
    required this.buyerGstin,
    required this.documentType,
    required this.documentNumber,
    required this.documentDate,
    required this.supplyType,
    required this.items,
    required this.totals,
    required this.status,
    this.qrCodeData,
  });

  /// 64-character IRN hash — null before generation.
  final String? irn;
  final String? ackNumber;
  final DateTime? ackDate;
  final EInvoiceAddress sellerAddress;
  final String sellerGstin;
  final EInvoiceAddress buyerAddress;
  final String buyerGstin;
  final EInvoiceDocType documentType;
  final String documentNumber;
  final DateTime documentDate;
  final EInvoiceSupplyType supplyType;
  final List<EInvoiceItem> items;
  final EInvoiceTotals totals;
  final EInvoiceStatus status;
  final String? qrCodeData;

  EInvoice copyWith({
    String? irn,
    String? ackNumber,
    DateTime? ackDate,
    EInvoiceAddress? sellerAddress,
    String? sellerGstin,
    EInvoiceAddress? buyerAddress,
    String? buyerGstin,
    EInvoiceDocType? documentType,
    String? documentNumber,
    DateTime? documentDate,
    EInvoiceSupplyType? supplyType,
    List<EInvoiceItem>? items,
    EInvoiceTotals? totals,
    EInvoiceStatus? status,
    String? qrCodeData,
  }) {
    return EInvoice(
      irn: irn ?? this.irn,
      ackNumber: ackNumber ?? this.ackNumber,
      ackDate: ackDate ?? this.ackDate,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      sellerGstin: sellerGstin ?? this.sellerGstin,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      buyerGstin: buyerGstin ?? this.buyerGstin,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      documentDate: documentDate ?? this.documentDate,
      supplyType: supplyType ?? this.supplyType,
      items: items ?? this.items,
      totals: totals ?? this.totals,
      status: status ?? this.status,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoice &&
          runtimeType == other.runtimeType &&
          irn == other.irn &&
          sellerGstin == other.sellerGstin &&
          buyerGstin == other.buyerGstin &&
          documentType == other.documentType &&
          documentNumber == other.documentNumber &&
          documentDate == other.documentDate &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        irn,
        sellerGstin,
        buyerGstin,
        documentType,
        documentNumber,
        documentDate,
        status,
      );
}
