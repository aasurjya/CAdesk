/// Whether the item is a service or goods per NIC API spec.
enum EInvoiceIsServc {
  yes('Y'),
  no('N');

  const EInvoiceIsServc(this.code);

  /// Single-character code used in the NIC API JSON payload.
  final String code;
}

/// Immutable line item for NIC/IRP e-invoice API v1.03.
///
/// All monetary values are in Indian Rupees (double, 2 decimal places).
class EInvoiceItem {
  const EInvoiceItem({
    required this.slNo,
    required this.prdDesc,
    required this.isServc,
    required this.hsnCd,
    required this.qty,
    required this.unit,
    required this.unitPrice,
    required this.totAmt,
    required this.assAmt,
    required this.gstRt,
    required this.igstAmt,
    required this.cgstAmt,
    required this.sgstAmt,
    required this.totItemVal,
  });

  /// Serial number of the item (1-based).
  final int slNo;

  /// Product/service description.
  final String prdDesc;

  /// Whether this is a service (Y) or goods (N).
  final EInvoiceIsServc isServc;

  /// HSN code (4, 6, or 8 digits) for goods; SAC code for services.
  final String hsnCd;

  /// Quantity supplied.
  final double qty;

  /// Unit of measurement (e.g. 'NOS', 'KGS', 'MTR').
  final String unit;

  /// Unit price before tax.
  final double unitPrice;

  /// Total gross amount = qty × unitPrice.
  final double totAmt;

  /// Assessable/taxable value (after discounts).
  final double assAmt;

  /// GST rate (e.g. 5.0, 12.0, 18.0, 28.0).
  final double gstRt;

  /// IGST amount on this line.
  final double igstAmt;

  /// CGST amount on this line.
  final double cgstAmt;

  /// SGST/UTGST amount on this line.
  final double sgstAmt;

  /// Total item value = assAmt + igstAmt + cgstAmt + sgstAmt.
  final double totItemVal;

  EInvoiceItem copyWith({
    int? slNo,
    String? prdDesc,
    EInvoiceIsServc? isServc,
    String? hsnCd,
    double? qty,
    String? unit,
    double? unitPrice,
    double? totAmt,
    double? assAmt,
    double? gstRt,
    double? igstAmt,
    double? cgstAmt,
    double? sgstAmt,
    double? totItemVal,
  }) {
    return EInvoiceItem(
      slNo: slNo ?? this.slNo,
      prdDesc: prdDesc ?? this.prdDesc,
      isServc: isServc ?? this.isServc,
      hsnCd: hsnCd ?? this.hsnCd,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totAmt: totAmt ?? this.totAmt,
      assAmt: assAmt ?? this.assAmt,
      gstRt: gstRt ?? this.gstRt,
      igstAmt: igstAmt ?? this.igstAmt,
      cgstAmt: cgstAmt ?? this.cgstAmt,
      sgstAmt: sgstAmt ?? this.sgstAmt,
      totItemVal: totItemVal ?? this.totItemVal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceItem &&
          runtimeType == other.runtimeType &&
          slNo == other.slNo &&
          hsnCd == other.hsnCd &&
          assAmt == other.assAmt &&
          gstRt == other.gstRt;

  @override
  int get hashCode => Object.hash(slNo, hsnCd, assAmt, gstRt);
}
