/// Processing status of an MCA e-Form submission.
enum McaEFormStatusValue {
  pending,
  underProcessing,
  approved,
  rejected,
  resubmissionRequired,
}

/// Immutable status record for a submitted MCA e-Form.
class McaEFormStatus {
  const McaEFormStatus({
    required this.srn,
    required this.formType,
    required this.cin,
    required this.filedAt,
    required this.status,
    this.approvalDate,
    this.remarks,
  });

  /// Service Request Number assigned by MCA.
  final String srn;

  /// Form identifier (e.g. "MGT-7", "AOC-4", "DIR-3 KYC").
  final String formType;

  /// CIN of the company for which the form was filed.
  final String cin;

  final DateTime filedAt;
  final McaEFormStatusValue status;

  /// Nullable — set only when status is [McaEFormStatusValue.approved].
  final DateTime? approvalDate;

  /// Nullable — remarks from the MCA processing officer.
  final String? remarks;

  McaEFormStatus copyWith({
    String? srn,
    String? formType,
    String? cin,
    DateTime? filedAt,
    McaEFormStatusValue? status,
    DateTime? approvalDate,
    String? remarks,
  }) {
    return McaEFormStatus(
      srn: srn ?? this.srn,
      formType: formType ?? this.formType,
      cin: cin ?? this.cin,
      filedAt: filedAt ?? this.filedAt,
      status: status ?? this.status,
      approvalDate: approvalDate ?? this.approvalDate,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McaEFormStatus &&
        other.srn == srn &&
        other.formType == formType &&
        other.cin == cin &&
        other.filedAt == filedAt &&
        other.status == status &&
        other.approvalDate == approvalDate &&
        other.remarks == remarks;
  }

  @override
  int get hashCode =>
      Object.hash(srn, formType, cin, filedAt, status, approvalDate, remarks);
}
