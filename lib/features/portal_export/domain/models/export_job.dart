enum ExportType {
  itrXml('ITR XML'),
  gstrJson('GSTR JSON'),
  tdsFvu('TDS FVU'),
  form16Pdf('Form 16 PDF'),
  form16aPdf('Form 16A PDF');

  const ExportType(this.label);

  final String label;
}

enum ExportJobStatus {
  queued('Queued'),
  processing('Processing'),
  completed('Completed'),
  failed('Failed');

  const ExportJobStatus(this.label);

  final String label;
}

class ExportJob {
  const ExportJob({
    required this.id,
    required this.clientId,
    required this.exportType,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.filePath,
    this.errorMessage,
  });

  final String id;
  final String clientId;
  final ExportType exportType;
  final ExportJobStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? filePath;
  final String? errorMessage;

  ExportJob copyWith({
    String? id,
    String? clientId,
    ExportType? exportType,
    ExportJobStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? filePath,
    String? errorMessage,
  }) {
    return ExportJob(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      exportType: exportType ?? this.exportType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExportJob && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
