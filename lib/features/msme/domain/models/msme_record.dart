/// MSME enterprise category under the MSMED Act 2006.
enum MsmeCategory {
  micro('Micro'),
  small('Small'),
  medium('Medium');

  const MsmeCategory(this.label);

  final String label;
}

/// Immutable data-layer model for an MSME Udyam registration record.
class MsmeRecord {
  const MsmeRecord({
    required this.id,
    required this.clientId,
    required this.udyamNumber,
    required this.registrationDate,
    required this.category,
    required this.status,
    this.annualTurnover,
    this.employeeCount,
  });

  final String id;
  final String clientId;
  final String udyamNumber;
  final DateTime registrationDate;
  final MsmeCategory category;

  /// Annual turnover in INR (as string to avoid floating-point issues).
  final String? annualTurnover;

  final int? employeeCount;

  /// Registration status (e.g. 'active', 'cancelled', 'suspended').
  final String status;

  MsmeRecord copyWith({
    String? id,
    String? clientId,
    String? udyamNumber,
    DateTime? registrationDate,
    MsmeCategory? category,
    String? annualTurnover,
    int? employeeCount,
    String? status,
  }) {
    return MsmeRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      udyamNumber: udyamNumber ?? this.udyamNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      category: category ?? this.category,
      annualTurnover: annualTurnover ?? this.annualTurnover,
      employeeCount: employeeCount ?? this.employeeCount,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsmeRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MsmeRecord(id: $id, clientId: $clientId, '
      'udyamNumber: $udyamNumber, category: ${category.name}, '
      'status: $status)';
}
