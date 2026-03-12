/// ITR form types supported by the ITD e-Filing 2.0 export engine.
enum ItrType {
  /// ITR-1 (Sahaj) — salaried individuals with income up to ₹50L.
  itr1,

  /// ITR-2 — individuals/HUFs with capital gains or foreign assets.
  itr2,

  /// ITR-3 — individuals/HUFs with business or professional income.
  itr3,

  /// ITR-4 (Sugam) — presumptive income under Sections 44AD/44ADA/44AE.
  itr4,

  /// ITR-5 — partnership firms, LLPs, AOPs, BOIs.
  itr5,

  /// ITR-6 — companies other than those claiming exemption u/s 11.
  itr6,

  /// ITR-7 — trusts, political parties, charitable institutions.
  itr7;

  /// Portal key used in JSON: e.g. "ITR1", "ITR2", etc.
  String get jsonKey => name.toUpperCase();
}

/// Immutable result of an ITD e-Filing 2.0 JSON export operation.
///
/// Carries the complete JSON payload, its SHA-256 checksum, and any
/// validation errors discovered during export.
class ItrExportResult {
  const ItrExportResult({
    required this.itrType,
    required this.jsonPayload,
    required this.checksum,
    required this.exportedAt,
    required this.assessmentYear,
    required this.panNumber,
    required this.validationErrors,
  });

  /// Type of ITR form that was exported.
  final ItrType itrType;

  /// Complete ITD e-Filing 2.0 JSON string (UTF-8 encoded).
  final String jsonPayload;

  /// SHA-256 hex digest of [jsonPayload].
  final String checksum;

  /// UTC timestamp when the export was produced.
  final DateTime exportedAt;

  /// Assessment year in "YYYY-YY" format, e.g. "2024-25".
  final String assessmentYear;

  /// PAN of the assessee.
  final String panNumber;

  /// Validation errors found during schema validation (empty if valid).
  final List<String> validationErrors;

  /// Whether the export passed schema validation.
  bool get isValid => validationErrors.isEmpty;

  ItrExportResult copyWith({
    ItrType? itrType,
    String? jsonPayload,
    String? checksum,
    DateTime? exportedAt,
    String? assessmentYear,
    String? panNumber,
    List<String>? validationErrors,
  }) {
    return ItrExportResult(
      itrType: itrType ?? this.itrType,
      jsonPayload: jsonPayload ?? this.jsonPayload,
      checksum: checksum ?? this.checksum,
      exportedAt: exportedAt ?? this.exportedAt,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      panNumber: panNumber ?? this.panNumber,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItrExportResult &&
        other.itrType == itrType &&
        other.jsonPayload == jsonPayload &&
        other.checksum == checksum &&
        other.exportedAt == exportedAt &&
        other.assessmentYear == assessmentYear &&
        other.panNumber == panNumber &&
        _listEquals(other.validationErrors, validationErrors);
  }

  @override
  int get hashCode => Object.hash(
    itrType,
    jsonPayload,
    checksum,
    exportedAt,
    assessmentYear,
    panNumber,
    Object.hashAll(validationErrors),
  );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
