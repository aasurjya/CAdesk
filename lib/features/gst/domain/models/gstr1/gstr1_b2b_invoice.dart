/// Immutable model representing a B2B taxable supply invoice for GSTR-1 Table 4A.
///
/// B2B invoices are supplies made to registered recipients (GSTIN present).
/// Tax type is IGST for inter-state and CGST+SGST for intra-state.
class Gstr1B2bInvoice {
  const Gstr1B2bInvoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.recipientGstin,
    required this.recipientName,
    required this.placeOfSupply,
    required this.isInterState,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.gstRate,
    required this.invoiceType,
    required this.reverseCharge,
  });

  /// Invoice number as on the tax invoice.
  final String invoiceNumber;

  /// Date of invoice.
  final DateTime invoiceDate;

  /// GST registration number of the recipient.
  final String recipientGstin;

  /// Trade name / legal name of the recipient.
  final String recipientName;

  /// State code of place of supply (e.g. '27' for Maharashtra).
  final String placeOfSupply;

  /// Whether this is an inter-state supply (IGST) or intra-state (CGST+SGST).
  final bool isInterState;

  /// Total taxable value of the invoice.
  final double taxableValue;

  /// IGST amount (applicable for inter-state supplies).
  final double igst;

  /// CGST amount (applicable for intra-state supplies).
  final double cgst;

  /// SGST/UTGST amount (applicable for intra-state supplies).
  final double sgst;

  /// Compensation cess amount.
  final double cess;

  /// GST rate applied (e.g. 5, 12, 18, 28).
  final double gstRate;

  /// Invoice type: 'Regular', 'SEZ supplies with payment', etc.
  final String invoiceType;

  /// Whether this invoice is under Reverse Charge Mechanism.
  final bool reverseCharge;

  /// Total tax = IGST + CGST + SGST + CESS.
  double get totalTax => igst + cgst + sgst + cess;

  /// Invoice value = taxableValue + totalTax.
  double get invoiceValue => taxableValue + totalTax;

  Gstr1B2bInvoice copyWith({
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? recipientGstin,
    String? recipientName,
    String? placeOfSupply,
    bool? isInterState,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? gstRate,
    String? invoiceType,
    bool? reverseCharge,
  }) {
    return Gstr1B2bInvoice(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      recipientGstin: recipientGstin ?? this.recipientGstin,
      recipientName: recipientName ?? this.recipientName,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterState: isInterState ?? this.isInterState,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      gstRate: gstRate ?? this.gstRate,
      invoiceType: invoiceType ?? this.invoiceType,
      reverseCharge: reverseCharge ?? this.reverseCharge,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr1B2bInvoice &&
          runtimeType == other.runtimeType &&
          invoiceNumber == other.invoiceNumber &&
          recipientGstin == other.recipientGstin;

  @override
  int get hashCode => Object.hash(invoiceNumber, recipientGstin);
}
