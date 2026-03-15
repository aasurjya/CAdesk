import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_export/data/mappers/export_job_mapper.dart';
import 'package:ca_app/features/portal_export/domain/models/export_job.dart';

void main() {
  group('ExportJobMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'ej-001',
          'client_id': 'client-001',
          'export_type': 'itrXml',
          'status': 'completed',
          'created_at': '2025-07-20T10:00:00.000Z',
          'completed_at': '2025-07-20T10:05:00.000Z',
          'file_path': '/exports/itr_001.xml',
          'error_message': null,
        };

        final job = ExportJobMapper.fromJson(json);

        expect(job.id, 'ej-001');
        expect(job.clientId, 'client-001');
        expect(job.exportType, ExportType.itrXml);
        expect(job.status, ExportJobStatus.completed);
        expect(job.completedAt, isNotNull);
        expect(job.filePath, '/exports/itr_001.xml');
        expect(job.errorMessage, isNull);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'ej-002',
          'client_id': 'client-002',
          'export_type': 'gstrJson',
          'status': 'queued',
          'created_at': '2025-07-20T09:00:00.000Z',
        };

        final job = ExportJobMapper.fromJson(json);
        expect(job.completedAt, isNull);
        expect(job.filePath, isNull);
        expect(job.errorMessage, isNull);
      });

      test('handles failed job with error message', () {
        final json = {
          'id': 'ej-003',
          'client_id': 'c1',
          'export_type': 'tdsFvu',
          'status': 'failed',
          'created_at': '2025-07-20T09:00:00.000Z',
          'error_message': 'Connection timeout',
        };

        final job = ExportJobMapper.fromJson(json);
        expect(job.status, ExportJobStatus.failed);
        expect(job.errorMessage, 'Connection timeout');
      });

      test('defaults export_type to itrXml for unknown value', () {
        final json = {
          'id': 'ej-004',
          'client_id': 'c1',
          'export_type': 'unknownType',
          'status': 'queued',
          'created_at': '2025-07-20T09:00:00.000Z',
        };

        final job = ExportJobMapper.fromJson(json);
        expect(job.exportType, ExportType.itrXml);
      });

      test('defaults status to queued for unknown value', () {
        final json = {
          'id': 'ej-005',
          'client_id': 'c1',
          'export_type': 'form16Pdf',
          'status': 'unknownStatus',
          'created_at': '2025-07-20T09:00:00.000Z',
        };

        final job = ExportJobMapper.fromJson(json);
        expect(job.status, ExportJobStatus.queued);
      });

      test('handles all ExportType values', () {
        for (final exportType in ExportType.values) {
          final json = {
            'id': 'ej-type-${exportType.name}',
            'client_id': 'c1',
            'export_type': exportType.name,
            'status': 'queued',
            'created_at': '2025-07-20T09:00:00.000Z',
          };
          final job = ExportJobMapper.fromJson(json);
          expect(job.exportType, exportType);
        }
      });

      test('handles all ExportJobStatus values', () {
        for (final status in ExportJobStatus.values) {
          final json = {
            'id': 'ej-status-${status.name}',
            'client_id': 'c1',
            'export_type': 'itrXml',
            'status': status.name,
            'created_at': '2025-07-20T09:00:00.000Z',
          };
          final job = ExportJobMapper.fromJson(json);
          expect(job.status, status);
        }
      });
    });

    group('toJson', () {
      late ExportJob sampleJob;

      setUp(() {
        sampleJob = ExportJob(
          id: 'ej-json-001',
          clientId: 'client-json-001',
          exportType: ExportType.gstrJson,
          status: ExportJobStatus.completed,
          createdAt: DateTime(2025, 8, 1, 9, 0),
          completedAt: DateTime(2025, 8, 1, 9, 3),
          filePath: '/exports/gstr_json_001.json',
        );
      });

      test('includes all fields', () {
        final json = ExportJobMapper.toJson(sampleJob);

        expect(json['id'], 'ej-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['export_type'], 'gstrJson');
        expect(json['status'], 'completed');
        expect(json['file_path'], '/exports/gstr_json_001.json');
        expect(json['error_message'], isNull);
      });

      test('serializes completed_at as ISO string', () {
        final json = ExportJobMapper.toJson(sampleJob);
        expect(json['completed_at'], startsWith('2025-08-01'));
      });

      test('serializes null completed_at as null for queued job', () {
        final queuedJob = ExportJob(
          id: 'ej-queued',
          clientId: 'c1',
          exportType: ExportType.form16aPdf,
          status: ExportJobStatus.queued,
          createdAt: DateTime(2025, 8, 1),
        );
        final json = ExportJobMapper.toJson(queuedJob);
        expect(json['completed_at'], isNull);
        expect(json['file_path'], isNull);
      });

      test('serializes error_message for failed job', () {
        final failedJob = sampleJob.copyWith(
          id: 'ej-failed',
          status: ExportJobStatus.failed,
          errorMessage: 'Network error',
          filePath: null,
        );
        final json = ExportJobMapper.toJson(failedJob);
        expect(json['status'], 'failed');
        expect(json['error_message'], 'Network error');
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = ExportJobMapper.toJson(sampleJob);
        json['created_at'] = sampleJob.createdAt.toIso8601String();

        final restored = ExportJobMapper.fromJson(json);

        expect(restored.id, sampleJob.id);
        expect(restored.clientId, sampleJob.clientId);
        expect(restored.exportType, sampleJob.exportType);
        expect(restored.status, sampleJob.status);
        expect(restored.filePath, sampleJob.filePath);
      });
    });
  });
}
