/// Immutable model representing a compliance certificate issued by a
/// Company Secretary (CS) under the Companies Act 2013.
///
/// Covers:
/// - MGT-8: Certificate by Practising Company Secretary for Annual Return
/// - Secretarial Audit Report (Form MR-3) under Section 204
class ComplianceCertificate {
  const ComplianceCertificate({
    required this.certType,
    required this.period,
    required this.certifiedBy,
    required this.din,
    required this.date,
    required this.declarations,
  });

  /// E.g. "MGT-8", "Secretarial Audit Report".
  final String certType;

  /// Period covered, e.g. "2023-24", "FY 2024-25".
  final String period;

  /// Name of the certifying Company Secretary.
  final String certifiedBy;

  /// Membership number or DIN of the certifying CS.
  final String din;

  /// Date on which the certificate was issued.
  final DateTime date;

  /// List of statutory declarations included in the certificate.
  final List<String> declarations;

  ComplianceCertificate copyWith({
    String? certType,
    String? period,
    String? certifiedBy,
    String? din,
    DateTime? date,
    List<String>? declarations,
  }) {
    return ComplianceCertificate(
      certType: certType ?? this.certType,
      period: period ?? this.period,
      certifiedBy: certifiedBy ?? this.certifiedBy,
      din: din ?? this.din,
      date: date ?? this.date,
      declarations: declarations ?? this.declarations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ComplianceCertificate) return false;
    if (other.certType != certType) return false;
    if (other.period != period) return false;
    if (other.certifiedBy != certifiedBy) return false;
    if (other.din != din) return false;
    if (other.date != date) return false;
    if (other.declarations.length != declarations.length) return false;
    for (int i = 0; i < declarations.length; i++) {
      if (other.declarations[i] != declarations[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    certType,
    period,
    certifiedBy,
    din,
    date,
    Object.hashAll(declarations),
  );
}
