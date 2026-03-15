import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ocr/data/mappers/ocr_mapper.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_job.dart';

void main() {
  group('OcrMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'ocr-001',
          'client_id': 'client-001',
          'document_type': 'form16',
          'input_file_path': '/documents/form16_2025.pdf',
          'status': 'completed',
          'parsed_data': '{"employer": "TCS", "tds": 45000}',
          'confidence': 0.95,
          'created_at': '2025-09-01T10:00:00.000Z',
          'completed_at': '2025-09-01T10:01:30.000Z',
          'error_message': null,
        };

        final job = OcrMapper.fromJson(json);

        expect(job.id, 'ocr-001');
        expect(job.clientId, 'client-001');
        expect(job.documentType, OcrDocType.form16);
        expect(job.inputFilePath, '/documents/form16_2025.pdf');
        expect(job.status, OcrStatus.completed);
        expect(job.parsedData, '{"employer": "TCS", "tds": 45000}');
        expect(job.confidence, 0.95);
        expect(job.createdAt.year, 2025);
        expect(job.completedAt, isNotNull);
        expect(job.errorMessage, isNull);
      });

      test('handles null completedAt and errorMessage', () {
        final json = {
          'id': 'ocr-002',
          'client_id': 'client-002',
          'document_type': 'invoice',
          'input_file_path': '/documents/inv_001.jpg',
          'status': 'queued',
          'confidence': 0.0,
          'created_at': '2025-09-02T08:00:00.000Z',
        };

        final job = OcrMapper.fromJson(json);
        expect(job.completedAt, isNull);
        expect(job.errorMessage, isNull);
        expect(job.parsedData, isNull);
        expect(job.status, OcrStatus.queued);
        expect(job.documentType, OcrDocType.invoice);
      });

      test('handles failed job with error message', () {
        final json = {
          'id': 'ocr-003',
          'client_id': 'c1',
          'document_type': 'bankStatement',
          'input_file_path': '/docs/stmt.pdf',
          'status': 'failed',
          'confidence': 0.0,
          'created_at': '2025-09-01T09:00:00.000Z',
          'error_message': 'Unreadable PDF format',
        };

        final job = OcrMapper.fromJson(json);
        expect(job.status, OcrStatus.failed);
        expect(job.errorMessage, 'Unreadable PDF format');
      });

      test('defaults document_type to invoice for unknown value', () {
        final json = {
          'id': 'ocr-004',
          'client_id': 'c1',
          'document_type': 'unknownDocType',
          'input_file_path': '/docs/unknown.pdf',
          'status': 'queued',
          'confidence': 0.0,
          'created_at': '2025-09-01T09:00:00.000Z',
        };

        final job = OcrMapper.fromJson(json);
        expect(job.documentType, OcrDocType.invoice);
      });

      test('handles all OcrDocType values', () {
        for (final docType in OcrDocType.values) {
          final json = {
            'id': 'ocr-doctype-${docType.name}',
            'client_id': 'c1',
            'document_type': docType.name,
            'input_file_path': '/docs/test.pdf',
            'status': 'queued',
            'confidence': 0.0,
            'created_at': '2025-09-01T00:00:00.000Z',
          };
          final job = OcrMapper.fromJson(json);
          expect(job.documentType, docType);
        }
      });

      test('handles all OcrStatus values', () {
        for (final status in OcrStatus.values) {
          final json = {
            'id': 'ocr-status-${status.name}',
            'client_id': 'c1',
            'document_type': 'invoice',
            'input_file_path': '/docs/test.pdf',
            'status': status.name,
            'confidence': 0.0,
            'created_at': '2025-09-01T00:00:00.000Z',
          };
          final job = OcrMapper.fromJson(json);
          expect(job.status, status);
        }
      });

      test('handles integer confidence value', () {
        final json = {
          'id': 'ocr-005',
          'client_id': 'c1',
          'document_type': 'panCard',
          'input_file_path': '/docs/pan.jpg',
          'status': 'completed',
          'confidence': 1,
          'created_at': '2025-09-01T00:00:00.000Z',
        };

        final job = OcrMapper.fromJson(json);
        expect(job.confidence, 1.0);
        expect(job.confidence, isA<double>());
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final job = OcrJob(
          id: 'ocr-json-001',
          clientId: 'client-json-001',
          documentType: OcrDocType.form26as,
          inputFilePath: '/docs/26as_2025.pdf',
          status: OcrStatus.processing,
          parsedData: '{"tds_entries": []}',
          confidence: 0.88,
          createdAt: DateTime.utc(2025, 9, 5, 10),
          completedAt: null,
          errorMessage: null,
        );

        final json = OcrMapper.toJson(job);

        expect(json['id'], 'ocr-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['document_type'], 'form26as');
        expect(json['input_file_path'], '/docs/26as_2025.pdf');
        expect(json['status'], 'processing');
        expect(json['parsed_data'], '{"tds_entries": []}');
        expect(json['confidence'], 0.88);
        expect(json['completed_at'], isNull);
        expect(json['error_message'], isNull);

        final restored = OcrMapper.fromJson(json);
        expect(restored.id, job.id);
        expect(restored.documentType, job.documentType);
        expect(restored.status, job.status);
        expect(restored.confidence, job.confidence);
      });
    });
  });
}
