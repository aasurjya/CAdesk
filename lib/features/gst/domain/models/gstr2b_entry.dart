/// ITC availability status as reported in GSTR-2B.
enum ItcAvailability {
  yes(label: 'Available'),
  no(label: 'Not Available'),
  partial(label: 'Partially Available');

  const ItcAvailability({required this.label});
  final String label;
}

/// Type of match found during GSTR-2B reconciliation.
enum MatchType {
  exactMatch(label: 'Exact Match'),
  partialMatch(label: 'Partial Match'),
  unmatchedIn2b(label: 'Only in GSTR-2B'),
  unmatchedInBooks(label: 'Only in Books');

  const MatchType({required this.label});
  final String label;
}

/// Discrepancy type found during matching.
enum MatchDiscrepancy {
  amountMismatch(label: 'Amount Mismatch'),
  dateMismatch(label: 'Date Mismatch'),
  gstinMismatch(label: 'GSTIN Mismatch'),
  invoiceNumberFormat(label: 'Invoice Number Format'),
  taxRateMismatch(label: 'Tax Rate Mismatch');

  const MatchDiscrepancy({required this.label});
  final String label;
}

/// Immutable model representing a single GSTR-2B entry from the GST portal.
class Gstr2bEntry {
  const Gstr2bEntry({
    required this.supplierGstin,
    required this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.placeOfSupply,
    required this.reverseCharge,
    required this.itcAvailable,
    this.itcReason,
  });

  final String supplierGstin;
  final String supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final double taxableValue;
  final double igst;
  final double cgst;
  final double sgst;
  final double cess;
  final String placeOfSupply;
  final bool reverseCharge;
  final ItcAvailability itcAvailable;
  final String? itcReason;

  /// Total ITC (IGST + CGST + SGST) for this entry.
  double get totalItc => igst + cgst + sgst;

  Gstr2bEntry copyWith({
    String? supplierGstin,
    String? supplierName,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? invoiceValue,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    String? placeOfSupply,
    bool? reverseCharge,
    ItcAvailability? itcAvailable,
    String? itcReason,
  }) {
    return Gstr2bEntry(
      supplierGstin: supplierGstin ?? this.supplierGstin,
      supplierName: supplierName ?? this.supplierName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceValue: invoiceValue ?? this.invoiceValue,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      itcAvailable: itcAvailable ?? this.itcAvailable,
      itcReason: itcReason ?? this.itcReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr2bEntry &&
          runtimeType == other.runtimeType &&
          supplierGstin == other.supplierGstin &&
          invoiceNumber == other.invoiceNumber;

  @override
  int get hashCode => Object.hash(supplierGstin, invoiceNumber);
}

/// Immutable model representing a purchase entry from the books of accounts.
class BooksPurchaseEntry {
  const BooksPurchaseEntry({
    required this.supplierGstin,
    required this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    this.hsnCode,
    required this.reverseCharge,
  });

  final String supplierGstin;
  final String supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final double taxableValue;
  final double igst;
  final double cgst;
  final double sgst;
  final double cess;
  final String? hsnCode;
  final bool reverseCharge;

  /// Total ITC (IGST + CGST + SGST) for this entry.
  double get totalItc => igst + cgst + sgst;

  BooksPurchaseEntry copyWith({
    String? supplierGstin,
    String? supplierName,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? invoiceValue,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    String? hsnCode,
    bool? reverseCharge,
  }) {
    return BooksPurchaseEntry(
      supplierGstin: supplierGstin ?? this.supplierGstin,
      supplierName: supplierName ?? this.supplierName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceValue: invoiceValue ?? this.invoiceValue,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      hsnCode: hsnCode ?? this.hsnCode,
      reverseCharge: reverseCharge ?? this.reverseCharge,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooksPurchaseEntry &&
          runtimeType == other.runtimeType &&
          supplierGstin == other.supplierGstin &&
          invoiceNumber == other.invoiceNumber;

  @override
  int get hashCode => Object.hash(supplierGstin, invoiceNumber);
}

/// Immutable result of matching a single GSTR-2B entry against books.
class MatchResult {
  const MatchResult({
    required this.gstr2bEntry,
    required this.booksEntry,
    required this.matchType,
    required this.discrepancies,
    required this.suggestedAction,
  });

  final Gstr2bEntry? gstr2bEntry;
  final BooksPurchaseEntry? booksEntry;
  final MatchType matchType;
  final List<MatchDiscrepancy> discrepancies;
  final String suggestedAction;

  MatchResult copyWith({
    Gstr2bEntry? gstr2bEntry,
    BooksPurchaseEntry? booksEntry,
    MatchType? matchType,
    List<MatchDiscrepancy>? discrepancies,
    String? suggestedAction,
  }) {
    return MatchResult(
      gstr2bEntry: gstr2bEntry ?? this.gstr2bEntry,
      booksEntry: booksEntry ?? this.booksEntry,
      matchType: matchType ?? this.matchType,
      discrepancies: discrepancies ?? this.discrepancies,
      suggestedAction: suggestedAction ?? this.suggestedAction,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchResult &&
          runtimeType == other.runtimeType &&
          gstr2bEntry == other.gstr2bEntry &&
          booksEntry == other.booksEntry &&
          matchType == other.matchType;

  @override
  int get hashCode => Object.hash(gstr2bEntry, booksEntry, matchType);
}

/// Immutable result of a full GSTR-2B reconciliation run.
class Gstr2bReconciliationResult {
  const Gstr2bReconciliationResult({
    required this.exactMatches,
    required this.partialMatches,
    required this.unmatchedIn2b,
    required this.unmatchedInBooks,
    required this.totalItcIn2b,
    required this.totalItcInBooks,
    required this.reconciledItc,
    required this.unreconciledItc,
    required this.matchRate,
  });

  final List<MatchResult> exactMatches;
  final List<MatchResult> partialMatches;
  final List<MatchResult> unmatchedIn2b;
  final List<MatchResult> unmatchedInBooks;
  final double totalItcIn2b;
  final double totalItcInBooks;
  final double reconciledItc;
  final double unreconciledItc;

  /// Percentage of exact matches (0-100).
  final double matchRate;

  Gstr2bReconciliationResult copyWith({
    List<MatchResult>? exactMatches,
    List<MatchResult>? partialMatches,
    List<MatchResult>? unmatchedIn2b,
    List<MatchResult>? unmatchedInBooks,
    double? totalItcIn2b,
    double? totalItcInBooks,
    double? reconciledItc,
    double? unreconciledItc,
    double? matchRate,
  }) {
    return Gstr2bReconciliationResult(
      exactMatches: exactMatches ?? this.exactMatches,
      partialMatches: partialMatches ?? this.partialMatches,
      unmatchedIn2b: unmatchedIn2b ?? this.unmatchedIn2b,
      unmatchedInBooks: unmatchedInBooks ?? this.unmatchedInBooks,
      totalItcIn2b: totalItcIn2b ?? this.totalItcIn2b,
      totalItcInBooks: totalItcInBooks ?? this.totalItcInBooks,
      reconciledItc: reconciledItc ?? this.reconciledItc,
      unreconciledItc: unreconciledItc ?? this.unreconciledItc,
      matchRate: matchRate ?? this.matchRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr2bReconciliationResult &&
          runtimeType == other.runtimeType &&
          totalItcIn2b == other.totalItcIn2b &&
          totalItcInBooks == other.totalItcInBooks &&
          reconciledItc == other.reconciledItc &&
          matchRate == other.matchRate;

  @override
  int get hashCode =>
      Object.hash(totalItcIn2b, totalItcInBooks, reconciledItc, matchRate);
}
