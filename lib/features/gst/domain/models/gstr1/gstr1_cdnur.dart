/// Type of credit/debit note issued to an unregistered recipient.
enum CdnurType {
  /// B2CL: credit/debit note related to large inter-state B2C invoices.
  b2cl(label: 'B2CL'),

  /// Exports with payment of IGST.
  exports(label: 'EXPWP'),

  /// Exports without payment of IGST (LUT/bond).
  exportsWithoutPayment(label: 'EXPWOP');

  const CdnurType({required this.label});

  final String label;
}

/// Immutable model representing a Credit/Debit Note to an Unregistered
/// recipient for GSTR-1 Table 9C (CDNUR).
///
/// CDNUR covers notes issued against supplies to unregistered persons
/// (no GSTIN) where the original invoice was B2CL or export.
class Gstr1Cdnur {
  const Gstr1Cdnur({
    required this.noteNumber,
    required this.noteDate,
    required this.noteType,
    this.recipientName,
    required this.placeOfSupply,
    required this.isInterState,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.gstRate,
    this.preGst = false,
    this.originalInvoiceNumber,
    required this.originalInvoiceDate,
  });

  /// Credit/debit note number.
  final String noteNumber;

  /// Date the note was issued.
  final DateTime noteDate;

  /// Type: B2CL, EXPWP, or EXPWOP.
  final CdnurType noteType;

  /// Name of the unregistered recipient (optional).
  final String? recipientName;

  /// State code of place of supply.
  final String placeOfSupply;

  /// Whether this is an inter-state transaction.
  final bool isInterState;

  /// Taxable value of the note.
  final double taxableValue;

  /// IGST amount.
  final double igst;

  /// CGST amount.
  final double cgst;

  /// SGST/UTGST amount.
  final double sgst;

  /// Compensation cess.
  final double cess;

  /// GST rate applied.
  final double gstRate;

  /// Whether the note relates to a pre-GST invoice.
  final bool preGst;

  /// Original invoice number (optional for some CDNUR types).
  final String? originalInvoiceNumber;

  /// Date of the original invoice.
  final DateTime originalInvoiceDate;

  /// Total tax = IGST + CGST + SGST + CESS.
  double get totalTax => igst + cgst + sgst + cess;

  /// Note value = taxableValue + totalTax.
  double get noteValue => taxableValue + totalTax;

  Gstr1Cdnur copyWith({
    String? noteNumber,
    DateTime? noteDate,
    CdnurType? noteType,
    String? recipientName,
    String? placeOfSupply,
    bool? isInterState,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? gstRate,
    bool? preGst,
    String? originalInvoiceNumber,
    DateTime? originalInvoiceDate,
  }) {
    return Gstr1Cdnur(
      noteNumber: noteNumber ?? this.noteNumber,
      noteDate: noteDate ?? this.noteDate,
      noteType: noteType ?? this.noteType,
      recipientName: recipientName ?? this.recipientName,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterState: isInterState ?? this.isInterState,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      gstRate: gstRate ?? this.gstRate,
      preGst: preGst ?? this.preGst,
      originalInvoiceNumber:
          originalInvoiceNumber ?? this.originalInvoiceNumber,
      originalInvoiceDate: originalInvoiceDate ?? this.originalInvoiceDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr1Cdnur &&
          runtimeType == other.runtimeType &&
          noteNumber == other.noteNumber;

  @override
  int get hashCode => noteNumber.hashCode;
}
