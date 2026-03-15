import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ai_automation/data/mappers/ai_automation_mapper.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';

void main() {
  group('AiAutomationMapper', () {
    // -------------------------------------------------------------------------
    // AiScanResult
    // -------------------------------------------------------------------------
    group('scanFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'scan-001',
          'document_name': 'Form16_FY2425.pdf',
          'document_type': 'form16',
          'extracted_data': {'pan': 'ABCDE1234F', 'employer': 'TCS Ltd'},
          'confidence': 0.95,
          'scanned_at': '2025-08-15T10:30:00.000Z',
          'status': 'completed',
          'client_name': 'Ramesh Kumar',
        };

        final result = AiAutomationMapper.scanFromJson(json);

        expect(result.id, 'scan-001');
        expect(result.documentName, 'Form16_FY2425.pdf');
        expect(result.documentType, DocumentType.form16);
        expect(result.extractedData['pan'], 'ABCDE1234F');
        expect(result.extractedData['employer'], 'TCS Ltd');
        expect(result.confidence, 0.95);
        expect(result.status, ScanStatus.completed);
        expect(result.clientName, 'Ramesh Kumar');
      });

      test('defaults document_type to other for unknown value', () {
        final json = {
          'id': 'scan-002',
          'document_name': 'unknown.pdf',
          'document_type': 'unknownType',
          'extracted_data': <String, dynamic>{},
          'confidence': 0.5,
          'scanned_at': '2025-08-15T10:30:00.000Z',
          'status': 'completed',
          'client_name': '',
        };

        final result = AiAutomationMapper.scanFromJson(json);
        expect(result.documentType, DocumentType.other);
      });

      test('defaults status to processing for unknown value', () {
        final json = {
          'id': 'scan-003',
          'document_name': 'test.pdf',
          'document_type': 'panCard',
          'extracted_data': <String, dynamic>{},
          'confidence': 0.75,
          'scanned_at': '2025-08-15T10:30:00.000Z',
          'status': 'unknownStatus',
          'client_name': '',
        };

        final result = AiAutomationMapper.scanFromJson(json);
        expect(result.status, ScanStatus.processing);
      });

      test('handles all DocumentType values', () {
        for (final docType in DocumentType.values) {
          final json = {
            'id': 'scan-type-${docType.name}',
            'document_name': 'doc.pdf',
            'document_type': docType.name,
            'extracted_data': <String, dynamic>{},
            'confidence': 0.8,
            'scanned_at': '2025-08-15T10:30:00.000Z',
            'status': 'completed',
            'client_name': '',
          };
          final result = AiAutomationMapper.scanFromJson(json);
          expect(result.documentType, docType);
        }
      });

      test('handles all ScanStatus values', () {
        for (final status in ScanStatus.values) {
          final json = {
            'id': 'scan-status-${status.name}',
            'document_name': 'doc.pdf',
            'document_type': 'other',
            'extracted_data': <String, dynamic>{},
            'confidence': 0.8,
            'scanned_at': '2025-08-15T10:30:00.000Z',
            'status': status.name,
            'client_name': '',
          };
          final result = AiAutomationMapper.scanFromJson(json);
          expect(result.status, status);
        }
      });

      test('handles empty extracted_data', () {
        final json = {
          'id': 'scan-004',
          'document_name': 'empty.pdf',
          'document_type': 'other',
          'extracted_data': <String, dynamic>{},
          'confidence': 0.3,
          'scanned_at': '2025-08-15T10:30:00.000Z',
          'status': 'reviewNeeded',
          'client_name': '',
        };

        final result = AiAutomationMapper.scanFromJson(json);
        expect(result.extractedData, isEmpty);
      });
    });

    group('scanToJson', () {
      late AiScanResult sampleResult;

      setUp(() {
        sampleResult = AiScanResult(
          id: 'scan-json-001',
          documentName: 'Form26AS_2425.pdf',
          documentType: DocumentType.form26as,
          extractedData: const {'total_income': '500000', 'tds': '50000'},
          confidence: 0.92,
          scannedAt: DateTime(2025, 9, 1, 10, 0),
          status: ScanStatus.completed,
          clientName: 'Sunita Patel',
        );
      });

      test('includes all fields', () {
        final json = AiAutomationMapper.scanToJson(sampleResult);

        expect(json['id'], 'scan-json-001');
        expect(json['document_name'], 'Form26AS_2425.pdf');
        expect(json['document_type'], 'form26as');
        expect(json['extracted_data']['total_income'], '500000');
        expect(json['confidence'], 0.92);
        expect(json['status'], 'completed');
        expect(json['client_name'], 'Sunita Patel');
      });

      test('serializes scanned_at as ISO string', () {
        final json = AiAutomationMapper.scanToJson(sampleResult);
        expect(json['scanned_at'], startsWith('2025-09-01'));
      });

      test('round-trip scanFromJson(scanToJson) preserves all fields', () {
        final json = AiAutomationMapper.scanToJson(sampleResult);
        final restored = AiAutomationMapper.scanFromJson(json);

        expect(restored.id, sampleResult.id);
        expect(restored.documentName, sampleResult.documentName);
        expect(restored.documentType, sampleResult.documentType);
        expect(restored.confidence, sampleResult.confidence);
        expect(restored.status, sampleResult.status);
        expect(restored.clientName, sampleResult.clientName);
      });
    });

    // -------------------------------------------------------------------------
    // AutomationInsight
    // -------------------------------------------------------------------------
    group('insightFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'insight-001',
          'title': 'TDS Deadline Approaching',
          'client_name': 'ABC Corp',
          'description': 'Q2 TDS filing due in 5 days',
          'metric_label': 'Days Remaining',
          'metric_value': '5',
          'action_label': 'File Now',
          'status': 'attentionNeeded',
        };

        final insight = AiAutomationMapper.insightFromJson(json);

        expect(insight.id, 'insight-001');
        expect(insight.title, 'TDS Deadline Approaching');
        expect(insight.clientName, 'ABC Corp');
        expect(insight.description, 'Q2 TDS filing due in 5 days');
        expect(insight.metricLabel, 'Days Remaining');
        expect(insight.metricValue, '5');
        expect(insight.actionLabel, 'File Now');
        expect(insight.status, AutomationInsightStatus.attentionNeeded);
      });

      test('defaults status to onTrack for unknown value', () {
        final json = {
          'id': 'insight-002',
          'title': 'Test',
          'client_name': '',
          'description': '',
          'metric_label': '',
          'metric_value': '',
          'action_label': '',
          'status': 'unknownStatus',
        };

        final insight = AiAutomationMapper.insightFromJson(json);
        expect(insight.status, AutomationInsightStatus.onTrack);
      });

      test('handles all AutomationInsightStatus values', () {
        for (final status in AutomationInsightStatus.values) {
          final json = {
            'id': 'insight-status-${status.name}',
            'title': '',
            'client_name': '',
            'description': '',
            'metric_label': '',
            'metric_value': '',
            'action_label': '',
            'status': status.name,
          };
          final insight = AiAutomationMapper.insightFromJson(json);
          expect(insight.status, status);
        }
      });
    });

    group('insightToJson', () {
      test('includes all serializable fields', () {
        final insight = AiAutomationMapper.insightFromJson({
          'id': 'insight-json-001',
          'title': 'GST Filing Pending',
          'client_name': 'XYZ Traders',
          'description': 'GSTR-3B for October 2025 not filed',
          'metric_label': 'Penalty Risk',
          'metric_value': '₹10,000',
          'action_label': 'File GSTR-3B',
          'status': 'blocked',
        });

        final json = AiAutomationMapper.insightToJson(insight);

        expect(json['id'], 'insight-json-001');
        expect(json['title'], 'GST Filing Pending');
        expect(json['client_name'], 'XYZ Traders');
        expect(json['description'], 'GSTR-3B for October 2025 not filed');
        expect(json['metric_label'], 'Penalty Risk');
        expect(json['metric_value'], '₹10,000');
        expect(json['action_label'], 'File GSTR-3B');
        expect(json['status'], 'blocked');
      });
    });
  });
}
