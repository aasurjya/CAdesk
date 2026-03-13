/// LLP e-Form types filed with the Ministry of Corporate Affairs.
enum LlpFormType {
  form3('Form-3'),
  form4('Form-4'),
  form8('Form-8'),
  form11('Form-11'),
  form15('Form-15'),
  llpin('LLPIN'),
  fllpin('FLLPIN'),
  other('Other');

  const LlpFormType(this.label);

  final String label;
}

/// Immutable data-layer model for an LLP filing record.
class LlpFiling {
  const LlpFiling({
    required this.id,
    required this.clientId,
    required this.formType,
    required this.financialYear,
    required this.dueDate,
    required this.status,
    this.filedDate,
    this.filingNumber,
  });

  final String id;
  final String clientId;
  final LlpFormType formType;
  final String financialYear;
  final DateTime dueDate;
  final DateTime? filedDate;

  /// Filing status string (e.g. 'pending', 'filed', 'approved', 'rejected').
  final String status;

  /// Reference number assigned after filing.
  final String? filingNumber;

  LlpFiling copyWith({
    String? id,
    String? clientId,
    LlpFormType? formType,
    String? financialYear,
    DateTime? dueDate,
    DateTime? filedDate,
    String? status,
    String? filingNumber,
  }) {
    return LlpFiling(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      formType: formType ?? this.formType,
      financialYear: financialYear ?? this.financialYear,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      filingNumber: filingNumber ?? this.filingNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlpFiling &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LlpFiling(id: $id, clientId: $clientId, '
      'formType: ${formType.name}, financialYear: $financialYear, '
      'status: $status)';
}
