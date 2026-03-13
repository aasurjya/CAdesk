/// Immutable record of a single MCA e-Form filing.
///
/// [feesPaid] is in paise.
class McaFilingRecord {
  const McaFilingRecord({
    required this.srn,
    required this.formType,
    required this.filedAt,
    required this.status,
    required this.documentDescription,
    required this.feesPaid,
  });

  /// Service Request Number.
  final String srn;

  /// Form identifier (e.g. "MGT-7", "AOC-4").
  final String formType;

  final DateTime filedAt;

  /// Human-readable status string (e.g. "Approved", "Pending").
  final String status;

  final String documentDescription;

  /// Government fees paid for this filing in paise.
  final int feesPaid;

  McaFilingRecord copyWith({
    String? srn,
    String? formType,
    DateTime? filedAt,
    String? status,
    String? documentDescription,
    int? feesPaid,
  }) {
    return McaFilingRecord(
      srn: srn ?? this.srn,
      formType: formType ?? this.formType,
      filedAt: filedAt ?? this.filedAt,
      status: status ?? this.status,
      documentDescription: documentDescription ?? this.documentDescription,
      feesPaid: feesPaid ?? this.feesPaid,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McaFilingRecord &&
        other.srn == srn &&
        other.formType == formType &&
        other.filedAt == filedAt &&
        other.status == status &&
        other.documentDescription == documentDescription &&
        other.feesPaid == feesPaid;
  }

  @override
  int get hashCode => Object.hash(
        srn,
        formType,
        filedAt,
        status,
        documentDescription,
        feesPaid,
      );
}
