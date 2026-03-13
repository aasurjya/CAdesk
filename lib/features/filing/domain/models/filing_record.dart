enum FilingType {
  itr1('ITR-1'),
  itr2('ITR-2'),
  itr3('ITR-3'),
  itr4('ITR-4'),
  itr5('ITR-5'),
  itr6('ITR-6'),
  itr7('ITR-7'),
  gstr1('GSTR-1'),
  gstr3b('GSTR-3B'),
  gstr9('GSTR-9'),
  tds24q('TDS 24Q'),
  tds26q('TDS 26Q'),
  tds27q('TDS 27Q');

  const FilingType(this.label);

  final String label;
}

enum FilingStatus {
  pending('Pending'),
  inProgress('In Progress'),
  filed('Filed'),
  verified('Verified'),
  rejected('Rejected');

  const FilingStatus(this.label);

  final String label;
}

class FilingRecord {
  const FilingRecord({
    required this.id,
    required this.clientId,
    required this.filingType,
    required this.financialYear,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.filedDate,
    this.acknowledgementNumber,
    this.remarks,
  });

  final String id;
  final String clientId;
  final FilingType filingType;
  final String financialYear;
  final FilingStatus status;
  final DateTime? filedDate;
  final String? acknowledgementNumber;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  FilingRecord copyWith({
    String? id,
    String? clientId,
    FilingType? filingType,
    String? financialYear,
    FilingStatus? status,
    DateTime? filedDate,
    String? acknowledgementNumber,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FilingRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      filingType: filingType ?? this.filingType,
      financialYear: financialYear ?? this.financialYear,
      status: status ?? this.status,
      filedDate: filedDate ?? this.filedDate,
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
