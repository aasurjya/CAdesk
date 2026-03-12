import 'package:ca_app/features/ocr/domain/models/ocr_document.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_extracted_data.dart';
import 'package:flutter/foundation.dart';

/// Immutable result of running the full OCR extraction pipeline on a document.
///
/// If [requiresManualReview] is true the confidence score fell below 0.85 and
/// the extracted data should be verified by a human before use.
@immutable
class OcrExtractionResult {
  const OcrExtractionResult({
    required this.document,
    required this.extractedData,
    required this.validationErrors,
    required this.requiresManualReview,
  });

  /// The raw OCR document that was processed.
  final OcrDocument document;

  /// Structured data extracted from the document (type-safe union via sealed class).
  final OcrExtractedData extractedData;

  /// Validation errors found during post-extraction checks.
  final List<String> validationErrors;

  /// True when the overall confidence score is below the 0.85 threshold.
  final bool requiresManualReview;

  /// Constructs a result with [requiresManualReview] automatically derived from
  /// [document.confidence].
  factory OcrExtractionResult.fromDocument({
    required OcrDocument document,
    required OcrExtractedData extractedData,
    required List<String> validationErrors,
  }) {
    return OcrExtractionResult(
      document: document,
      extractedData: extractedData,
      validationErrors: validationErrors,
      requiresManualReview: document.confidence < 0.85,
    );
  }

  OcrExtractionResult copyWith({
    OcrDocument? document,
    OcrExtractedData? extractedData,
    List<String>? validationErrors,
    bool? requiresManualReview,
  }) {
    return OcrExtractionResult(
      document: document ?? this.document,
      extractedData: extractedData ?? this.extractedData,
      validationErrors: validationErrors ?? this.validationErrors,
      requiresManualReview: requiresManualReview ?? this.requiresManualReview,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrExtractionResult &&
          runtimeType == other.runtimeType &&
          document == other.document &&
          extractedData == other.extractedData &&
          _listEquals(validationErrors, other.validationErrors) &&
          requiresManualReview == other.requiresManualReview;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        document,
        extractedData,
        Object.hashAll(validationErrors),
        requiresManualReview,
      );

  @override
  String toString() =>
      'OcrExtractionResult(docId: ${document.documentId}, '
      'errors: ${validationErrors.length}, '
      'manualReview: $requiresManualReview)';
}
