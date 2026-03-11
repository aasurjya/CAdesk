import 'package:flutter/material.dart';

/// Type of document that was scanned via OCR.
enum DocumentType {
  panCard(label: 'PAN Card', icon: Icons.credit_card_rounded),
  aadhaarCard(label: 'Aadhaar Card', icon: Icons.badge_rounded),
  form16(label: 'Form 16', icon: Icons.description_rounded),
  form26as(label: 'Form 26AS', icon: Icons.summarize_rounded),
  bankStatement(label: 'Bank Statement', icon: Icons.account_balance_rounded),
  invoice(label: 'Invoice', icon: Icons.receipt_long_rounded),
  gstReturn(label: 'GST Return', icon: Icons.receipt_rounded),
  itrForm(label: 'ITR Form', icon: Icons.article_rounded),
  balanceSheet(label: 'Balance Sheet', icon: Icons.balance_rounded),
  other(label: 'Other', icon: Icons.insert_drive_file_rounded);

  const DocumentType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Processing status of an OCR scan.
enum ScanStatus {
  processing(label: 'Processing', color: Color(0xFF1565C0)),
  completed(label: 'Completed', color: Color(0xFF1A7A3A)),
  failed(label: 'Failed', color: Color(0xFFC62828)),
  reviewNeeded(label: 'Review Needed', color: Color(0xFFEF6C00));

  const ScanStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Immutable model representing an OCR scan result.
class AiScanResult {
  const AiScanResult({
    required this.id,
    required this.documentName,
    required this.documentType,
    required this.extractedData,
    required this.confidence,
    required this.scannedAt,
    required this.status,
    required this.clientName,
  });

  final String id;
  final String documentName;
  final DocumentType documentType;
  final Map<String, String> extractedData;
  final double confidence;
  final DateTime scannedAt;
  final ScanStatus status;
  final String clientName;

  /// Confidence percentage as a user-friendly string.
  String get confidenceLabel => '${(confidence * 100).toStringAsFixed(1)}%';

  /// True when confidence is below 80%.
  bool get isLowConfidence => confidence < 0.80;

  AiScanResult copyWith({
    String? id,
    String? documentName,
    DocumentType? documentType,
    Map<String, String>? extractedData,
    double? confidence,
    DateTime? scannedAt,
    ScanStatus? status,
    String? clientName,
  }) {
    return AiScanResult(
      id: id ?? this.id,
      documentName: documentName ?? this.documentName,
      documentType: documentType ?? this.documentType,
      extractedData: extractedData ?? this.extractedData,
      confidence: confidence ?? this.confidence,
      scannedAt: scannedAt ?? this.scannedAt,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiScanResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
