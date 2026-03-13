enum ImportType {
  form26as('Form 26AS'),
  ais('AIS'),
  tis('TIS'),
  tracesStatement('TRACES Statement'),
  bankStatement('Bank Statement');

  const ImportType(this.label);

  final String label;
}

enum ImportStatus {
  pending('Pending'),
  parsing('Parsing'),
  completed('Completed'),
  failed('Failed');

  const ImportStatus(this.label);

  final String label;
}

class PortalImport {
  const PortalImport({
    required this.id,
    required this.clientId,
    required this.importType,
    required this.importDate,
    required this.status,
    required this.createdAt,
    this.rawData,
    this.parsedRecords,
    this.errorMessage,
  });

  final String id;
  final String clientId;
  final ImportType importType;
  final DateTime importDate;
  final String? rawData;
  final int? parsedRecords;
  final ImportStatus status;
  final String? errorMessage;
  final DateTime createdAt;

  PortalImport copyWith({
    String? id,
    String? clientId,
    ImportType? importType,
    DateTime? importDate,
    String? rawData,
    int? parsedRecords,
    ImportStatus? status,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return PortalImport(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      importType: importType ?? this.importType,
      importDate: importDate ?? this.importDate,
      rawData: rawData ?? this.rawData,
      parsedRecords: parsedRecords ?? this.parsedRecords,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortalImport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
