/// Status of an audit assignment.
enum AuditAssignmentStatus {
  scheduled('Scheduled'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  const AuditAssignmentStatus(this.label);

  final String label;
}

/// Immutable model representing an audit assignment for a client.
class AuditAssignment {
  const AuditAssignment({
    required this.id,
    required this.clientId,
    this.auditorId,
    this.financialYear,
    this.startDate,
    this.endDate,
    required this.status,
    this.fee,
  });

  final String id;
  final String clientId;
  final String? auditorId;
  final String? financialYear;
  final DateTime? startDate;
  final DateTime? endDate;
  final AuditAssignmentStatus status;

  /// Fee as a string to preserve decimal precision (matches Drift TEXT column).
  final String? fee;

  AuditAssignment copyWith({
    String? id,
    String? clientId,
    String? auditorId,
    String? financialYear,
    DateTime? startDate,
    DateTime? endDate,
    AuditAssignmentStatus? status,
    String? fee,
  }) {
    return AuditAssignment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      auditorId: auditorId ?? this.auditorId,
      financialYear: financialYear ?? this.financialYear,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      fee: fee ?? this.fee,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditAssignment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AuditAssignment(id: $id, clientId: $clientId, '
      'financialYear: $financialYear, status: ${status.label})';
}
