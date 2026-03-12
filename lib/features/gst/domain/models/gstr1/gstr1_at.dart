/// Immutable model representing tax liability on an advance received,
/// for GSTR-1 Table 11A (AT — Advance Tax).
///
/// When a registered dealer receives an advance against a future supply,
/// GST is payable on the advance at the time of receipt. This entry
/// records that advance and the GST liability arising from it.
class Gstr1At {
  const Gstr1At({
    required this.receiptVoucherNumber,
    required this.receiptDate,
    this.recipientGstin,
    this.recipientName,
    required this.placeOfSupply,
    required this.isInterState,
    required this.advanceAmount,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.gstRate,
  });

  /// Receipt voucher number generated on receiving the advance.
  final String receiptVoucherNumber;

  /// Date of receipt of advance payment.
  final DateTime receiptDate;

  /// GSTIN of the customer (if registered; null for unregistered).
  final String? recipientGstin;

  /// Name of the customer.
  final String? recipientName;

  /// State code of place of supply.
  final String placeOfSupply;

  /// Whether this is an inter-state advance (IGST) or intra-state (CGST+SGST).
  final bool isInterState;

  /// Gross advance amount received.
  final double advanceAmount;

  /// IGST payable on the advance.
  final double igst;

  /// CGST payable on the advance.
  final double cgst;

  /// SGST/UTGST payable on the advance.
  final double sgst;

  /// Compensation cess on the advance.
  final double cess;

  /// GST rate applicable to the anticipated supply.
  final double gstRate;

  /// Total tax = IGST + CGST + SGST + CESS.
  double get totalTax => igst + cgst + sgst + cess;

  Gstr1At copyWith({
    String? receiptVoucherNumber,
    DateTime? receiptDate,
    String? recipientGstin,
    String? recipientName,
    String? placeOfSupply,
    bool? isInterState,
    double? advanceAmount,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? gstRate,
  }) {
    return Gstr1At(
      receiptVoucherNumber: receiptVoucherNumber ?? this.receiptVoucherNumber,
      receiptDate: receiptDate ?? this.receiptDate,
      recipientGstin: recipientGstin ?? this.recipientGstin,
      recipientName: recipientName ?? this.recipientName,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterState: isInterState ?? this.isInterState,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      gstRate: gstRate ?? this.gstRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr1At &&
          runtimeType == other.runtimeType &&
          receiptVoucherNumber == other.receiptVoucherNumber;

  @override
  int get hashCode => receiptVoucherNumber.hashCode;
}
