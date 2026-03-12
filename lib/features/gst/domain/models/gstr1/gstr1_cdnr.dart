/// Type of credit/debit note issued to a registered recipient.
enum CdnrNoteType {
  creditNote(label: 'Credit Note'),
  debitNote(label: 'Debit Note');

  const CdnrNoteType({required this.label});

  final String label;
}

/// Immutable model representing a Credit/Debit Note to a Registered recipient
/// for GSTR-1 Table 9B (CDNR).
///
/// Credit notes reduce tax liability; debit notes increase it.
/// CDNR covers notes issued to registered (GSTIN-holding) recipients.
class Gstr1Cdnr {
  const Gstr1Cdnr({
    required this.noteNumber,
    required this.noteDate,
    required this.noteType,
    required this.recipientGstin,
    required this.recipientName,
    required this.originalInvoiceNumber,
    required this.originalInvoiceDate,
    required this.placeOfSupply,
    required this.isInterState,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.gstRate,
    this.preGst = false,
  });

  /// Credit/debit note number.
  final String noteNumber;

  /// Date the note was issued.
  final DateTime noteDate;

  /// Whether this is a credit note or debit note.
  final CdnrNoteType noteType;

  /// GSTIN of the recipient to whom the note is issued.
  final String recipientGstin;

  /// Trade name of the recipient.
  final String recipientName;

  /// Invoice number to which this note relates.
  final String originalInvoiceNumber;

  /// Date of the original invoice.
  final DateTime originalInvoiceDate;

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

  /// Compensation cess amount.
  final double cess;

  /// GST rate applied.
  final double gstRate;

  /// Whether the note relates to a pre-GST invoice.
  final bool preGst;

  /// Total tax = IGST + CGST + SGST + CESS.
  double get totalTax => igst + cgst + sgst + cess;

  /// Note value = taxableValue + totalTax.
  double get noteValue => taxableValue + totalTax;

  Gstr1Cdnr copyWith({
    String? noteNumber,
    DateTime? noteDate,
    CdnrNoteType? noteType,
    String? recipientGstin,
    String? recipientName,
    String? originalInvoiceNumber,
    DateTime? originalInvoiceDate,
    String? placeOfSupply,
    bool? isInterState,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? gstRate,
    bool? preGst,
  }) {
    return Gstr1Cdnr(
      noteNumber: noteNumber ?? this.noteNumber,
      noteDate: noteDate ?? this.noteDate,
      noteType: noteType ?? this.noteType,
      recipientGstin: recipientGstin ?? this.recipientGstin,
      recipientName: recipientName ?? this.recipientName,
      originalInvoiceNumber:
          originalInvoiceNumber ?? this.originalInvoiceNumber,
      originalInvoiceDate: originalInvoiceDate ?? this.originalInvoiceDate,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterState: isInterState ?? this.isInterState,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      gstRate: gstRate ?? this.gstRate,
      preGst: preGst ?? this.preGst,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr1Cdnr &&
          runtimeType == other.runtimeType &&
          noteNumber == other.noteNumber &&
          recipientGstin == other.recipientGstin;

  @override
  int get hashCode => Object.hash(noteNumber, recipientGstin);
}
