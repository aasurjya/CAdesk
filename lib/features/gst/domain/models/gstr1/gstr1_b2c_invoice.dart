/// Category of B2C invoice for GSTR-1 reporting.
enum B2cCategory {
  /// B2CL: inter-state supplies to unregistered persons > ₹2.5L (Table 5A).
  large(label: 'B2CL'),

  /// B2CS: all other supplies to unregistered persons (Table 5B).
  small(label: 'B2CS');

  const B2cCategory({required this.label});

  final String label;
}

/// Immutable model representing a B2C invoice for GSTR-1 Tables 5A/5B.
///
/// B2C invoices are supplies to unregistered recipients (no GSTIN).
/// - Table 5A (B2CL): inter-state supplies where invoice value > ₹2.5L
/// - Table 5B (B2CS): all other supplies to unregistered recipients,
///   reported as consolidated state-wise summary.
class Gstr1B2cInvoice {
  const Gstr1B2cInvoice({
    this.invoiceNumber,
    required this.invoiceDate,
    this.recipientName,
    required this.placeOfSupply,
    required this.isInterState,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.gstRate,
    required this.category,
  });

  /// Invoice number (null for consolidated B2CS entries).
  final String? invoiceNumber;

  /// Date of invoice.
  final DateTime invoiceDate;

  /// Name of the unregistered recipient (optional, required for B2CL).
  final String? recipientName;

  /// State code of place of supply.
  final String placeOfSupply;

  /// Whether this is an inter-state supply.
  final bool isInterState;

  /// Total taxable value.
  final double taxableValue;

  /// IGST amount (for inter-state B2CL supplies).
  final double igst;

  /// CGST amount (for intra-state B2CS supplies).
  final double cgst;

  /// SGST/UTGST amount (for intra-state B2CS supplies).
  final double sgst;

  /// Compensation cess.
  final double cess;

  /// GST rate applied.
  final double gstRate;

  /// Whether this is B2CL (large) or B2CS (small/consolidated).
  final B2cCategory category;

  /// Total tax = IGST + CGST + SGST + CESS.
  double get totalTax => igst + cgst + sgst + cess;

  /// Invoice value = taxableValue + totalTax.
  double get invoiceValue => taxableValue + totalTax;

  Gstr1B2cInvoice copyWith({
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? recipientName,
    String? placeOfSupply,
    bool? isInterState,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? gstRate,
    B2cCategory? category,
  }) {
    return Gstr1B2cInvoice(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      recipientName: recipientName ?? this.recipientName,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterState: isInterState ?? this.isInterState,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      gstRate: gstRate ?? this.gstRate,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr1B2cInvoice &&
          runtimeType == other.runtimeType &&
          invoiceNumber == other.invoiceNumber &&
          placeOfSupply == other.placeOfSupply;

  @override
  int get hashCode => Object.hash(invoiceNumber, placeOfSupply);
}
