import 'package:flutter/material.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';

/// Converts between [AiScanResult] / [AutomationInsight] and JSON maps.
class AiAutomationMapper {
  const AiAutomationMapper._();

  static AiScanResult scanFromJson(Map<String, dynamic> json) {
    return AiScanResult(
      id: json['id'] as String,
      documentName: json['document_name'] as String,
      documentType: DocumentType.values.firstWhere(
        (e) => e.name == (json['document_type'] as String? ?? 'other'),
        orElse: () => DocumentType.other,
      ),
      extractedData: Map<String, String>.from(
        (json['extracted_data'] as Map<String, dynamic>? ?? {}),
      ),
      confidence: (json['confidence'] as num).toDouble(),
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      status: ScanStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'processing'),
        orElse: () => ScanStatus.processing,
      ),
      clientName: json['client_name'] as String,
    );
  }

  static Map<String, dynamic> scanToJson(AiScanResult result) {
    return {
      'id': result.id,
      'document_name': result.documentName,
      'document_type': result.documentType.name,
      'extracted_data': result.extractedData,
      'confidence': result.confidence,
      'scanned_at': result.scannedAt.toIso8601String(),
      'status': result.status.name,
      'client_name': result.clientName,
    };
  }

  static AutomationInsight insightFromJson(Map<String, dynamic> json) {
    return AutomationInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      clientName: json['client_name'] as String,
      description: json['description'] as String,
      metricLabel: json['metric_label'] as String,
      metricValue: json['metric_value'] as String,
      actionLabel: json['action_label'] as String,
      icon: const IconData(0xe000),
      color: const Color(0xFF1A7A3A),
      status: AutomationInsightStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'onTrack'),
        orElse: () => AutomationInsightStatus.onTrack,
      ),
    );
  }

  static Map<String, dynamic> insightToJson(AutomationInsight insight) {
    return {
      'id': insight.id,
      'title': insight.title,
      'client_name': insight.clientName,
      'description': insight.description,
      'metric_label': insight.metricLabel,
      'metric_value': insight.metricValue,
      'action_label': insight.actionLabel,
      'status': insight.status.name,
    };
  }
}
