/// Immutable model representing an audit report (SA Report / Form 3CD) for a client.
class AuditReport {
  const AuditReport({
    required this.id,
    required this.clientId,
    required this.year,
    this.saReportNumber,
    this.reportDate,
    this.reportedBy,
    this.auditFindings,
  });

  final String id;
  final String clientId;

  /// Financial year (e.g. 2024 = FY 2024-25).
  final int year;

  final String? saReportNumber;
  final DateTime? reportDate;
  final String? reportedBy;

  /// Audit findings stored as a JSON string (maps to JSONB in Supabase).
  /// Each entry is a key-value pair representing a finding.
  final Map<String, dynamic>? auditFindings;

  AuditReport copyWith({
    String? id,
    String? clientId,
    int? year,
    String? saReportNumber,
    DateTime? reportDate,
    String? reportedBy,
    Map<String, dynamic>? auditFindings,
  }) {
    return AuditReport(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      year: year ?? this.year,
      saReportNumber: saReportNumber ?? this.saReportNumber,
      reportDate: reportDate ?? this.reportDate,
      reportedBy: reportedBy ?? this.reportedBy,
      auditFindings: auditFindings ?? this.auditFindings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AuditReport(id: $id, clientId: $clientId, year: $year, '
      'saReportNumber: $saReportNumber)';
}
