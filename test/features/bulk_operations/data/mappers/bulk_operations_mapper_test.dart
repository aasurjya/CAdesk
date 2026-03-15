import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/bulk_operations/data/mappers/bulk_operations_mapper.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';

void main() {
  group('BulkOperationsMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'job_id': 'job-001',
          'name': 'Bulk ITR Filing July 2025',
          'job_type': 'itrFiling',
          'priority': 'high',
          'items': [
            {
              'item_id': 'item-001',
              'client_name': 'Rahul Sharma',
              'pan': 'ABCDE1234F',
              'payload': '{"itr_type": "ITR-1"}',
              'status': 'pending',
              'attempts': 0,
            },
          ],
          'status': 'running',
          'started_at': '2025-07-15T09:00:00.000Z',
          'completed_at': null,
          'completed_items': 0,
          'failed_items': 0,
          'created_at': '2025-07-14T18:00:00.000Z',
        };

        final job = BulkOperationsMapper.fromJson(json);

        expect(job.jobId, 'job-001');
        expect(job.name, 'Bulk ITR Filing July 2025');
        expect(job.jobType, JobType.itrFiling);
        expect(job.priority, JobPriority.high);
        expect(job.items.length, 1);
        expect(job.items[0].itemId, 'item-001');
        expect(job.items[0].clientName, 'Rahul Sharma');
        expect(job.status, JobStatus.running);
        expect(job.startedAt, isNotNull);
        expect(job.completedAt, isNull);
        expect(job.completedItems, 0);
      });

      test('handles empty items list', () {
        final json = {
          'job_id': 'job-002',
          'name': 'Empty Job',
          'job_type': 'bulkExport',
          'priority': 'normal',
          'items': <dynamic>[],
          'status': 'queued',
          'completed_items': 0,
          'failed_items': 0,
          'created_at': '2025-07-14T18:00:00.000Z',
        };

        final job = BulkOperationsMapper.fromJson(json);
        expect(job.items, isEmpty);
      });

      test('handles missing items field with empty list', () {
        final json = {
          'job_id': 'job-003',
          'name': 'No Items',
          'job_type': 'tdsFiling',
          'priority': 'low',
          'status': 'queued',
          'completed_items': 0,
          'failed_items': 0,
          'created_at': '2025-07-14T18:00:00.000Z',
        };

        final job = BulkOperationsMapper.fromJson(json);
        expect(job.items, isEmpty);
      });

      test('defaults job_type to itrFiling for unknown value', () {
        final json = {
          'job_id': 'job-004',
          'name': '',
          'job_type': 'unknownType',
          'priority': 'normal',
          'items': <dynamic>[],
          'status': 'queued',
          'completed_items': 0,
          'failed_items': 0,
          'created_at': '2025-07-14T18:00:00.000Z',
        };

        final job = BulkOperationsMapper.fromJson(json);
        expect(job.jobType, JobType.itrFiling);
      });

      test('handles all JobType values', () {
        for (final type in JobType.values) {
          final json = {
            'job_id': 'job-type-${type.name}',
            'name': '',
            'job_type': type.name,
            'priority': 'normal',
            'items': <dynamic>[],
            'status': 'queued',
            'completed_items': 0,
            'failed_items': 0,
            'created_at': '2025-07-14T18:00:00.000Z',
          };
          final job = BulkOperationsMapper.fromJson(json);
          expect(job.jobType, type);
        }
      });

      test('handles all JobStatus values', () {
        for (final status in JobStatus.values) {
          final json = {
            'job_id': 'job-status-${status.name}',
            'name': '',
            'job_type': 'itrFiling',
            'priority': 'normal',
            'items': <dynamic>[],
            'status': status.name,
            'completed_items': 0,
            'failed_items': 0,
            'created_at': '2025-07-14T18:00:00.000Z',
          };
          final job = BulkOperationsMapper.fromJson(json);
          expect(job.status, status);
        }
      });

      test('maps item fields including optional error', () {
        final json = {
          'job_id': 'job-005',
          'name': '',
          'job_type': 'gstFiling',
          'priority': 'critical',
          'items': [
            {
              'item_id': 'item-err',
              'client_name': 'Error Client',
              'pan': 'XYZ12345A',
              'payload': '{}',
              'status': 'failed',
              'attempts': 3,
              'last_attempt_at': '2025-07-15T12:00:00.000Z',
              'error': 'Portal timeout',
              'completed_at': null,
            }
          ],
          'status': 'running',
          'completed_items': 0,
          'failed_items': 1,
          'created_at': '2025-07-14T18:00:00.000Z',
        };

        final job = BulkOperationsMapper.fromJson(json);
        expect(job.items[0].status, BatchJobItemStatus.failed);
        expect(job.items[0].attempts, 3);
        expect(job.items[0].error, 'Portal timeout');
        expect(job.items[0].lastAttemptAt, isNotNull);
      });
    });

    group('toJson', () {
      late BatchJob sampleJob;

      setUp(() {
        sampleJob = BatchJob(
          jobId: 'job-json-001',
          name: 'GST Filing Batch',
          jobType: JobType.gstFiling,
          priority: JobPriority.normal,
          items: const [
            BatchJobItem(
              itemId: 'item-json-001',
              clientName: 'Priya Singh',
              pan: 'PQRST5678G',
              payload: '{"gstin": "27ABCDE1234F1Z5"}',
              status: BatchJobItemStatus.completed,
              attempts: 1,
            ),
          ],
          status: JobStatus.completed,
          startedAt: DateTime(2025, 8, 1, 9, 0),
          completedAt: DateTime(2025, 8, 1, 9, 30),
          completedItems: 1,
          failedItems: 0,
          createdAt: DateTime(2025, 8, 1),
        );
      });

      test('includes all fields', () {
        final json = BulkOperationsMapper.toJson(sampleJob);

        expect(json['job_id'], 'job-json-001');
        expect(json['name'], 'GST Filing Batch');
        expect(json['job_type'], 'gstFiling');
        expect(json['priority'], 'normal');
        expect(json['status'], 'completed');
        expect(json['completed_items'], 1);
        expect(json['failed_items'], 0);
        expect(json['items'], isA<List>());
        expect((json['items'] as List).length, 1);
      });

      test('serializes timestamps as ISO strings', () {
        final json = BulkOperationsMapper.toJson(sampleJob);
        expect(json['started_at'], startsWith('2025-08-01'));
        expect(json['completed_at'], startsWith('2025-08-01'));
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = BulkOperationsMapper.toJson(sampleJob);
        final restored = BulkOperationsMapper.fromJson(json);

        expect(restored.jobId, sampleJob.jobId);
        expect(restored.name, sampleJob.name);
        expect(restored.jobType, sampleJob.jobType);
        expect(restored.priority, sampleJob.priority);
        expect(restored.status, sampleJob.status);
        expect(restored.items.length, sampleJob.items.length);
        expect(restored.items[0].itemId, sampleJob.items[0].itemId);
        expect(restored.completedItems, sampleJob.completedItems);
      });
    });
  });
}
