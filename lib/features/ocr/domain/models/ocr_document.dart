import 'package:flutter/foundation.dart';

/// The category of document recognized by the OCR pipeline.
enum DocumentType {
  form16,
  form16a,
  form26as,
  bankStatement,
  invoice,
  panCard,
  aadhaarCard,
  salarySlip,
  gstCertificate,
}

/// Lifecycle status of an OCR processing job.
enum ProcessingStatus { pending, processing, completed, failed }

/// Immutable representation of a raw OCR-scanned document before or after
/// structured data extraction.
@immutable
class OcrDocument {
  const OcrDocument({
    required this.documentId,
    required this.documentType,
    required this.rawText,
    required this.confidence,
    required this.extractedAt,
    required this.pageCount,
    required this.processingStatus,
  });

  /// Unique identifier for this document scan.
  final String documentId;

  /// Detected or assigned type of document.
  final DocumentType documentType;

  /// Full raw text output from the OCR engine.
  final String rawText;

  /// Overall OCR engine confidence score in [0.0, 1.0].
  final double confidence;

  /// When the document was processed.
  final DateTime extractedAt;

  /// Number of pages in the source document.
  final int pageCount;

  /// Current stage of the processing pipeline.
  final ProcessingStatus processingStatus;

  OcrDocument copyWith({
    String? documentId,
    DocumentType? documentType,
    String? rawText,
    double? confidence,
    DateTime? extractedAt,
    int? pageCount,
    ProcessingStatus? processingStatus,
  }) {
    return OcrDocument(
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      rawText: rawText ?? this.rawText,
      confidence: confidence ?? this.confidence,
      extractedAt: extractedAt ?? this.extractedAt,
      pageCount: pageCount ?? this.pageCount,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrDocument &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          documentType == other.documentType &&
          rawText == other.rawText &&
          confidence == other.confidence &&
          extractedAt == other.extractedAt &&
          pageCount == other.pageCount &&
          processingStatus == other.processingStatus;

  @override
  int get hashCode => Object.hash(
    documentId,
    documentType,
    rawText,
    confidence,
    extractedAt,
    pageCount,
    processingStatus,
  );

  @override
  String toString() =>
      'OcrDocument(id: $documentId, type: $documentType, '
      'status: $processingStatus, confidence: $confidence)';
}
