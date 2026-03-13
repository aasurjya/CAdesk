/// SEBI compliance obligation types.
enum SebiType {
  insiderTrading('Insider Trading'),
  lodr('LODR'),
  takeovers('Takeovers'),
  pit('PIT'),
  sast('SAST'),
  other('Other');

  const SebiType(this.label);

  final String label;
}

/// Immutable data-layer model for a SEBI compliance record.
class SebiComplianceData {
  const SebiComplianceData({
    required this.id,
    required this.clientId,
    required this.complianceType,
    required this.dueDate,
    required this.status,
    this.filedDate,
    this.description,
    this.penalty,
  });

  final String id;
  final String clientId;
  final SebiType complianceType;
  final DateTime dueDate;
  final DateTime? filedDate;

  /// Compliance status (e.g. 'pending', 'filed', 'overdue', 'exempted').
  final String status;

  final String? description;

  /// Penalty amount (as string) if applicable.
  final String? penalty;

  SebiComplianceData copyWith({
    String? id,
    String? clientId,
    SebiType? complianceType,
    DateTime? dueDate,
    DateTime? filedDate,
    String? status,
    String? description,
    String? penalty,
  }) {
    return SebiComplianceData(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      complianceType: complianceType ?? this.complianceType,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      description: description ?? this.description,
      penalty: penalty ?? this.penalty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SebiComplianceData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SebiComplianceData(id: $id, clientId: $clientId, '
      'complianceType: ${complianceType.name}, status: $status)';
}
