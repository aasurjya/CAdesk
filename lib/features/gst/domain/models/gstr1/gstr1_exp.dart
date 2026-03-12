/// Type of export transaction for GSTR-1 Table 6.
enum ExportType {
  /// Table 6B: Export with payment of IGST.
  withPayment(label: 'WPAY'),

  /// Table 6C: Export without payment (LUT/bond — zero-rated without tax payment).
  withoutPayment(label: 'WOPAY'),

  /// SEZ supply with payment of IGST.
  sezWithPayment(label: 'SEZWP'),

  /// SEZ supply without payment of IGST (LUT/bond).
  sezWithoutPayment(label: 'SEZWOP'),

  /// Deemed exports.
  deemed(label: 'DE');

  const ExportType({required this.label});

  final String label;
}

/// Immutable model representing an export/SEZ invoice for GSTR-1 Tables 6B/6C.
///
/// Exports are zero-rated supplies under Section 16 of the IGST Act.
/// - With payment (WPAY): IGST is paid; refund can be claimed later.
/// - Without payment (WOPAY/SEZWOP): Exported under LUT/bond, no IGST paid.
class Gstr1Exp {
  const Gstr1Exp({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.exportType,
    this.shippingBillNumber,
    this.shippingBillDate,
    this.portCode,
    required this.currencyCode,
    required this.foreignCurrencyValue,
    required this.taxableValue,
    required this.igst,
    required this.cess,
    required this.gstRate,
  });

  /// Invoice number.
  final String invoiceNumber;

  /// Date of invoice.
  final DateTime invoiceDate;

  /// Export type (WPAY, WOPAY, SEZWP, SEZWOP, DE).
  final ExportType exportType;

  /// Shipping bill number from customs (null for LUT/bond exports).
  final String? shippingBillNumber;

  /// Shipping bill date (null for LUT/bond exports).
  final DateTime? shippingBillDate;

  /// Port code from which goods were exported.
  final String? portCode;

  /// Currency code of the foreign currency (e.g. 'USD', 'EUR').
  final String currencyCode;

  /// Invoice value in foreign currency.
  final double foreignCurrencyValue;

  /// Taxable value in INR.
  final double taxableValue;

  /// IGST amount (0 for without-payment exports).
  final double igst;

  /// Compensation cess.
  final double cess;

  /// GST rate applied.
  final double gstRate;

  /// Whether this export is zero-rated without IGST payment.
  bool get isZeroRated =>
      exportType == ExportType.withoutPayment ||
      exportType == ExportType.sezWithoutPayment;

  /// Total tax = IGST + CESS (no CGST/SGST for exports).
  double get totalTax => igst + cess;

  /// Invoice value = taxableValue + totalTax.
  double get invoiceValue => taxableValue + totalTax;

  Gstr1Exp copyWith({
    String? invoiceNumber,
    DateTime? invoiceDate,
    ExportType? exportType,
    String? shippingBillNumber,
    DateTime? shippingBillDate,
    String? portCode,
    String? currencyCode,
    double? foreignCurrencyValue,
    double? taxableValue,
    double? igst,
    double? cess,
    double? gstRate,
  }) {
    return Gstr1Exp(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      exportType: exportType ?? this.exportType,
      shippingBillNumber: shippingBillNumber ?? this.shippingBillNumber,
      shippingBillDate: shippingBillDate ?? this.shippingBillDate,
      portCode: portCode ?? this.portCode,
      currencyCode: currencyCode ?? this.currencyCode,
      foreignCurrencyValue: foreignCurrencyValue ?? this.foreignCurrencyValue,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cess: cess ?? this.cess,
      gstRate: gstRate ?? this.gstRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr1Exp &&
          runtimeType == other.runtimeType &&
          invoiceNumber == other.invoiceNumber;

  @override
  int get hashCode => invoiceNumber.hashCode;
}
