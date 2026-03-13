enum OcrDocType {
  form16,
  form26as,
  bankStatement,
  invoice,
  panCard,
  aadhar,
  balanceSheet,
}

enum OcrStatus { queued, processing, completed, failed }

class OcrJob {
  const OcrJob({
    required this.id,
    required this.clientId,
    required this.documentType,
    required this.inputFilePath,
    required this.status,
    this.parsedData,
    required this.confidence,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  final String id;
  final String clientId;
  final OcrDocType documentType;
  final String inputFilePath;
  final OcrStatus status;
  final String? parsedData;
  final double confidence;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  OcrJob copyWith({
    String? id,
    String? clientId,
    OcrDocType? documentType,
    String? inputFilePath,
    OcrStatus? status,
    String? parsedData,
    double? confidence,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return OcrJob(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      documentType: documentType ?? this.documentType,
      inputFilePath: inputFilePath ?? this.inputFilePath,
      status: status ?? this.status,
      parsedData: parsedData ?? this.parsedData,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
