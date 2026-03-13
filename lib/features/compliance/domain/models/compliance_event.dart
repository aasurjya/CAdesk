/// Type of compliance event (filing type).
enum ComplianceEventType {
  itr('ITR'),
  gst('GST'),
  tds('TDS'),
  mca('MCA'),
  audit('Audit'),
  payroll('Payroll'),
  other('Other');

  const ComplianceEventType(this.label);

  final String label;
}

/// Status of a compliance event.
enum ComplianceEventStatus {
  pending('Pending'),
  filed('Filed'),
  overdue('Overdue'),
  completed('Completed'),
  rejected('Rejected');

  const ComplianceEventStatus(this.label);

  final String label;
}

/// Immutable model representing a compliance event (filing, deadline, etc.).
class ComplianceEvent {
  const ComplianceEvent({
    required this.id,
    required this.clientId,
    required this.type,
    required this.description,
    required this.dueDate,
    this.filedDate,
    required this.status,
    this.penalty,
  });

  final String id;
  final String clientId;
  final ComplianceEventType type;
  final String description;
  final DateTime dueDate;
  final DateTime? filedDate;
  final ComplianceEventStatus status;
  final double? penalty;

  /// Number of days until due (negative if overdue).
  int get daysUntilDue {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.difference(todayMidnight).inDays;
  }

  /// Whether the event is overdue.
  bool get isOverdue => daysUntilDue < 0 && status != ComplianceEventStatus.completed;

  /// Whether the event is due today.
  bool get isDueToday => daysUntilDue == 0 && status != ComplianceEventStatus.completed;

  ComplianceEvent copyWith({
    String? id,
    String? clientId,
    ComplianceEventType? type,
    String? description,
    DateTime? dueDate,
    DateTime? filedDate,
    ComplianceEventStatus? status,
    double? penalty,
  }) {
    return ComplianceEvent(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      penalty: penalty ?? this.penalty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplianceEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ComplianceEvent(id: $id, clientId: $clientId, type: ${type.label}, status: ${status.label})';
}
