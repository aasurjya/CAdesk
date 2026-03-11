/// Immutable model representing a single field extracted from a document job.
class ExtractedField {
  const ExtractedField({
    required this.id,
    required this.jobId,
    required this.fieldName,
    required this.extractedValue,
    required this.confidence,
    required this.needsReview,
    this.correctedValue,
  });

  final String id;
  final String jobId;

  /// e.g. "Gross Salary", "TDS Deducted", "PAN", "Employer Name"
  final String fieldName;

  final String extractedValue;

  /// Extraction confidence in range 0.0–1.0.
  final double confidence;

  /// True when the field has low confidence or was flagged for review.
  final bool needsReview;

  /// Non-null when a reviewer has manually corrected the extracted value.
  final String? correctedValue;

  ExtractedField copyWith({
    String? id,
    String? jobId,
    String? fieldName,
    String? extractedValue,
    double? confidence,
    bool? needsReview,
    String? correctedValue,
  }) {
    return ExtractedField(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      fieldName: fieldName ?? this.fieldName,
      extractedValue: extractedValue ?? this.extractedValue,
      confidence: confidence ?? this.confidence,
      needsReview: needsReview ?? this.needsReview,
      correctedValue: correctedValue ?? this.correctedValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExtractedField && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
