/// Type of item — goods or services.
enum InvoiceItemType {
  goods(label: 'Goods'),
  services(label: 'Services');

  const InvoiceItemType({required this.label});

  final String label;
}

/// Immutable line item on a GST invoice.
///
/// Each item has its own HSN/SAC code, rate, and tax breakdown.
class GstInvoiceItem {
  const GstInvoiceItem({
    required this.description,
    required this.hsnSacCode,
    required this.itemType,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.taxableValue,
    required this.gstRate,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
  });

  /// Description of the goods or service.
  final String description;

  /// HSN code (goods) or SAC code (services).
  final String hsnSacCode;

  /// Whether this is goods or services.
  final InvoiceItemType itemType;

  /// Quantity supplied.
  final double quantity;

  /// Unit of measurement (e.g. 'NOS', 'KGS', 'MTR').
  final String unit;

  /// Price per unit (before tax).
  final double unitPrice;

  /// Total taxable value = quantity × unitPrice (minus discounts).
  final double taxableValue;

  /// GST rate applied (e.g. 5, 12, 18, 28).
  final double gstRate;

  /// IGST amount on this line.
  final double igst;

  /// CGST amount on this line.
  final double cgst;

  /// SGST/UTGST amount on this line.
  final double sgst;

  /// Compensation cess on this line.
  final double cess;

  /// Total tax on this line = IGST + CGST + SGST + CESS.
  double get totalTax => igst + cgst + sgst + cess;

  /// Line total = taxableValue + totalTax.
  double get lineTotal => taxableValue + totalTax;

  GstInvoiceItem copyWith({
    String? description,
    String? hsnSacCode,
    InvoiceItemType? itemType,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? taxableValue,
    double? gstRate,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
  }) {
    return GstInvoiceItem(
      description: description ?? this.description,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      taxableValue: taxableValue ?? this.taxableValue,
      gstRate: gstRate ?? this.gstRate,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstInvoiceItem &&
          runtimeType == other.runtimeType &&
          hsnSacCode == other.hsnSacCode &&
          description == other.description &&
          taxableValue == other.taxableValue &&
          gstRate == other.gstRate;

  @override
  int get hashCode =>
      Object.hash(hsnSacCode, description, taxableValue, gstRate);
}

/// Immutable master invoice model representing a single GST-compliant
/// tax invoice issued by a registered supplier.
///
/// This is the source data from which GSTR-1 tables are populated.
/// Supports B2B, B2C, export, and RCM invoice types.
class GstInvoice {
  const GstInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.supplierGstin,
    required this.supplierName,
    required this.supplierStateCode,
    this.buyerGstin,
    required this.buyerName,
    required this.buyerStateCode,
    required this.placeOfSupply,
    required this.isInterState,
    required this.reverseCharge,
    required this.isExport,
    required this.invoiceType,
    required this.items,
  });

  /// Internal unique identifier.
  final String id;

  /// Invoice number as printed on the document.
  final String invoiceNumber;

  /// Date of the invoice.
  final DateTime invoiceDate;

  /// GSTIN of the issuing supplier.
  final String supplierGstin;

  /// Trade name of the supplier.
  final String supplierName;

  /// State code of the supplier's place of business.
  final String supplierStateCode;

  /// GSTIN of the buyer (null for B2C/unregistered/exports).
  final String? buyerGstin;

  /// Name of the buyer.
  final String buyerName;

  /// State code of the buyer's address.
  final String buyerStateCode;

  /// Place of supply state code (determines IGST vs CGST+SGST).
  final String placeOfSupply;

  /// Whether this is an inter-state supply.
  final bool isInterState;

  /// Whether this invoice is under Reverse Charge Mechanism.
  final bool reverseCharge;

  /// Whether this is an export invoice.
  final bool isExport;

  /// Invoice type: 'Regular', 'SEZ', 'Export', etc.
  final String invoiceType;

  /// Line items on the invoice.
  final List<GstInvoiceItem> items;

  /// Whether this is a B2B invoice (buyer has GSTIN).
  bool get isB2b => buyerGstin != null && buyerGstin!.isNotEmpty;

  /// Sum of taxable values across all line items.
  double get totalTaxableValue =>
      items.fold(0.0, (sum, item) => sum + item.taxableValue);

  /// Sum of IGST across all line items.
  double get totalIgst => items.fold(0.0, (sum, item) => sum + item.igst);

  /// Sum of CGST across all line items.
  double get totalCgst => items.fold(0.0, (sum, item) => sum + item.cgst);

  /// Sum of SGST across all line items.
  double get totalSgst => items.fold(0.0, (sum, item) => sum + item.sgst);

  /// Sum of CESS across all line items.
  double get totalCess => items.fold(0.0, (sum, item) => sum + item.cess);

  /// Grand total = taxableValue + IGST + CGST + SGST + CESS.
  double get grandTotal =>
      totalTaxableValue + totalIgst + totalCgst + totalSgst + totalCess;

  GstInvoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? supplierGstin,
    String? supplierName,
    String? supplierStateCode,
    String? buyerGstin,
    String? buyerName,
    String? buyerStateCode,
    String? placeOfSupply,
    bool? isInterState,
    bool? reverseCharge,
    bool? isExport,
    String? invoiceType,
    List<GstInvoiceItem>? items,
  }) {
    return GstInvoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      supplierGstin: supplierGstin ?? this.supplierGstin,
      supplierName: supplierName ?? this.supplierName,
      supplierStateCode: supplierStateCode ?? this.supplierStateCode,
      buyerGstin: buyerGstin ?? this.buyerGstin,
      buyerName: buyerName ?? this.buyerName,
      buyerStateCode: buyerStateCode ?? this.buyerStateCode,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterState: isInterState ?? this.isInterState,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      isExport: isExport ?? this.isExport,
      invoiceType: invoiceType ?? this.invoiceType,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstInvoice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceNumber == other.invoiceNumber;

  @override
  int get hashCode => Object.hash(id, invoiceNumber);
}
