/// Immutable model representing a document processing job.
class DocumentJob {
  const DocumentJob({
    required this.id,
    required this.clientName,
    required this.documentType,
    required this.fileName,
    required this.status,
    required this.confidenceScore,
    required this.totalFields,
    required this.extractedFields,
    required this.flaggedFields,
    required this.submittedDate,
    required this.processingTime,
  });

  final String id;
  final String clientName;

  /// e.g. "Form 16", "26AS", "Bank Statement", "AIS", "TIS", "P&L",
  /// "Balance Sheet", "Salary Slip"
  final String documentType;

  final String fileName;

  /// One of: Queued, Processing, Review, Completed, Failed
  final String status;

  /// Extraction confidence in range 0.0–1.0.
  final double confidenceScore;

  final int totalFields;
  final int extractedFields;

  /// Number of fields with low confidence that need human review.
  final int flaggedFields;

  /// Human-readable date string, e.g. "11 Mar 2026".
  final String submittedDate;

  /// Human-readable duration, e.g. "2.4s", or "pending".
  final String processingTime;

  DocumentJob copyWith({
    String? id,
    String? clientName,
    String? documentType,
    String? fileName,
    String? status,
    double? confidenceScore,
    int? totalFields,
    int? extractedFields,
    int? flaggedFields,
    String? submittedDate,
    String? processingTime,
  }) {
    return DocumentJob(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      totalFields: totalFields ?? this.totalFields,
      extractedFields: extractedFields ?? this.extractedFields,
      flaggedFields: flaggedFields ?? this.flaggedFields,
      submittedDate: submittedDate ?? this.submittedDate,
      processingTime: processingTime ?? this.processingTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentJob && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
