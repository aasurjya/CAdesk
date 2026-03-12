/// Return type for GSTN portal export.
enum GstrReturnType {
  /// Monthly outward supply return.
  gstr1,

  /// Monthly summary return with tax payment.
  gstr3b,

  /// Annual return.
  gstr9,

  /// Annual reconciliation statement (audited taxpayers).
  gstr9c,
}

/// Immutable result of serializing a GST return to GSTN API v3.0 JSON.
///
/// Encapsulates the generated JSON payload together with metadata needed
/// for submission validation and audit logging.
class GstrExportResult {
  const GstrExportResult({
    required this.returnType,
    required this.gstin,
    required this.period,
    required this.jsonPayload,
    required this.sectionCount,
    required this.exportedAt,
    required this.validationErrors,
  });

  /// Type of GST return (GSTR-1, GSTR-3B, GSTR-9, or GSTR-9C).
  final GstrReturnType returnType;

  /// GSTIN of the taxpayer for whom the return is prepared.
  final String gstin;

  /// Filing period in MMYYYY format (e.g. "032024" for March 2024).
  final String period;

  /// Serialized JSON string ready for GSTN API submission.
  final String jsonPayload;

  /// Number of populated table sections in the JSON (non-empty arrays).
  final int sectionCount;

  /// UTC timestamp when this export was generated.
  final DateTime exportedAt;

  /// Validation errors detected during serialization.
  ///
  /// An empty list indicates no errors were found.
  final List<String> validationErrors;

  /// Whether this export is free of validation errors.
  bool get isValid => validationErrors.isEmpty;

  GstrExportResult copyWith({
    GstrReturnType? returnType,
    String? gstin,
    String? period,
    String? jsonPayload,
    int? sectionCount,
    DateTime? exportedAt,
    List<String>? validationErrors,
  }) {
    return GstrExportResult(
      returnType: returnType ?? this.returnType,
      gstin: gstin ?? this.gstin,
      period: period ?? this.period,
      jsonPayload: jsonPayload ?? this.jsonPayload,
      sectionCount: sectionCount ?? this.sectionCount,
      exportedAt: exportedAt ?? this.exportedAt,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstrExportResult &&
          runtimeType == other.runtimeType &&
          returnType == other.returnType &&
          gstin == other.gstin &&
          period == other.period &&
          exportedAt == other.exportedAt;

  @override
  int get hashCode => Object.hash(returnType, gstin, period, exportedAt);
}
