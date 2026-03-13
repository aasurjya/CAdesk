/// MCA e-Form types filed with the Registrar of Companies (ROC).
enum MCAFormType {
  dir3('DIR-3'),
  inc22a('INC-22A'),
  aoc4('AOC-4'),
  dpt3('DPT-3'),
  mbp1('MBP-1'),
  form32('Form-32'),
  form33('Form-33'),
  other('Other');

  const MCAFormType(this.label);

  final String label;
}

/// Immutable data-layer model for an MCA/ROC filing record.
///
/// This model mirrors the local [MCAFilingsTable] schema and is used by the
/// repository data layer.  The richer presentation model [McaFiling] (with CIN,
/// SRN, fees, penalties, etc.) lives separately in [mca_filing.dart].
class McaFilingData {
  const McaFilingData({
    required this.id,
    required this.clientId,
    required this.formType,
    required this.financialYear,
    required this.dueDate,
    this.filedDate,
    required this.status,
    this.filingNumber,
    this.remarks,
  });

  final String id;
  final String clientId;
  final MCAFormType formType;
  final String financialYear;
  final DateTime dueDate;
  final DateTime? filedDate;

  /// Filing status string (e.g. 'pending', 'filed', 'approved', 'rejected').
  final String status;

  /// SRN or reference number assigned after filing.
  final String? filingNumber;

  final String? remarks;

  McaFilingData copyWith({
    String? id,
    String? clientId,
    MCAFormType? formType,
    String? financialYear,
    DateTime? dueDate,
    DateTime? filedDate,
    String? status,
    String? filingNumber,
    String? remarks,
  }) {
    return McaFilingData(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      formType: formType ?? this.formType,
      financialYear: financialYear ?? this.financialYear,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      filingNumber: filingNumber ?? this.filingNumber,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McaFilingData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'McaFilingData(id: $id, clientId: $clientId, '
      'formType: ${formType.name}, financialYear: $financialYear, '
      'status: $status)';
}
