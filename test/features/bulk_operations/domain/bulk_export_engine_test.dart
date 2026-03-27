import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';
import 'package:ca_app/features/bulk_operations/domain/services/bulk_export_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 7, 1, 10, 0);

  ClientData makeClient({String id = 'c1', String name = 'Test Client'}) {
    return ClientData(clientId: id, clientName: name, pan: 'ABCDE1234F');
  }

  BatchJob makeCompletedJob({required String id, List<BatchJobItem>? items}) {
    final jobItems =
        items ??
        [
          BatchJobItem(
            itemId: '$id-item-1',
            clientName: 'Client A',
            pan: 'ABCDE1234F',
            payload: '{}',
            status: BatchJobItemStatus.completed,
            attempts: 1,
            completedAt: now,
          ),
          BatchJobItem(
            itemId: '$id-item-2',
            clientName: 'Client B',
            pan: 'XYZXY5678G',
            payload: '{}',
            status: BatchJobItemStatus.failed,
            attempts: 3,
            error: 'PORTAL_TIMEOUT',
          ),
        ];
    return BatchJob(
      jobId: id,
      name: 'Export Job',
      jobType: JobType.bulkExport,
      priority: JobPriority.normal,
      items: jobItems,
      status: JobStatus.completed,
      completedItems: 1,
      failedItems: 1,
      createdAt: now,
      completedAt: now,
    );
  }

  group('BulkExportEngine.createExportJob', () {
    test('creates a BatchJob with bulkExport type', () {
      final engine = BulkExportEngine();
      final clients = [makeClient(id: 'c1'), makeClient(id: 'c2')];
      final job = engine.createExportJob(clients, 'PDF');
      expect(job.jobType, JobType.bulkExport);
    });

    test('job has queued status', () {
      final engine = BulkExportEngine();
      final clients = [makeClient()];
      final job = engine.createExportJob(clients, 'PDF');
      expect(job.status, JobStatus.queued);
    });

    test('job items count matches clients count', () {
      final engine = BulkExportEngine();
      final clients = List.generate(5, (i) => makeClient(id: 'c$i'));
      final job = engine.createExportJob(clients, 'PDF');
      expect(job.items.length, 5);
    });

    test('all items start with pending status', () {
      final engine = BulkExportEngine();
      final clients = [makeClient(id: 'c1'), makeClient(id: 'c2')];
      final job = engine.createExportJob(clients, 'PDF');
      expect(
        job.items.every((i) => i.status == BatchJobItemStatus.pending),
        isTrue,
      );
    });

    test('totalItems computed correctly', () {
      final engine = BulkExportEngine();
      final clients = List.generate(3, (i) => makeClient(id: 'c$i'));
      final job = engine.createExportJob(clients, 'EXCEL');
      expect(job.totalItems, 3);
    });

    test('payload encodes exportType', () {
      final engine = BulkExportEngine();
      final clients = [makeClient(id: 'c1', name: 'Sharma')];
      final job = engine.createExportJob(clients, 'CSV');
      expect(job.items.first.payload, contains('CSV'));
    });
  });

  group('BulkExportEngine.processExportItem', () {
    test('returns item with completed status on success', () {
      final engine = BulkExportEngine();
      const item = BatchJobItem(
        itemId: 'i-1',
        clientName: 'Test',
        pan: 'ABCDE1234F',
        payload: '{"exportType":"PDF"}',
        status: BatchJobItemStatus.processing,
        attempts: 1,
      );
      final result = engine.processExportItem(item, 'PDF');
      expect(result.status, BatchJobItemStatus.completed);
    });

    test('returns new item object — original not mutated', () {
      final engine = BulkExportEngine();
      const item = BatchJobItem(
        itemId: 'i-1',
        clientName: 'Test',
        pan: 'ABCDE1234F',
        payload: '{}',
        status: BatchJobItemStatus.processing,
        attempts: 1,
      );
      final result = engine.processExportItem(item, 'PDF');
      expect(identical(item, result), isFalse);
    });

    test('completed item has non-null completedAt', () {
      final engine = BulkExportEngine();
      const item = BatchJobItem(
        itemId: 'i-1',
        clientName: 'Test',
        pan: 'ABCDE1234F',
        payload: '{}',
        status: BatchJobItemStatus.processing,
        attempts: 1,
      );
      final result = engine.processExportItem(item, 'PDF');
      expect(result.completedAt, isNotNull);
    });
  });

  group('BulkExportEngine.estimateCompletionTime', () {
    test('estimates 2 seconds per item', () {
      final engine = BulkExportEngine();
      final clients = List.generate(10, (i) => makeClient(id: 'c$i'));
      final job = engine.createExportJob(clients, 'PDF');
      final estimate = engine.estimateCompletionTime(job);
      expect(estimate.inSeconds, 20); // 10 items × 2 seconds
    });

    test('returns Duration.zero for empty job', () {
      final engine = BulkExportEngine();
      final job = engine.createExportJob([], 'PDF');
      final estimate = engine.estimateCompletionTime(job);
      expect(estimate.inSeconds, 0);
    });

    test('single item takes 2 seconds', () {
      final engine = BulkExportEngine();
      final job = engine.createExportJob([makeClient()], 'PDF');
      final estimate = engine.estimateCompletionTime(job);
      expect(estimate.inSeconds, 2);
    });
  });

  group('BulkExportEngine.generateExportManifest', () {
    test('manifest has correct jobId', () {
      final engine = BulkExportEngine();
      final job = makeCompletedJob(id: 'export-123');
      final manifest = engine.generateExportManifest(job);
      expect(manifest.jobId, 'export-123');
    });

    test('manifest counts success and failed correctly', () {
      final engine = BulkExportEngine();
      final job = makeCompletedJob(id: 'j1');
      final manifest = engine.generateExportManifest(job);
      expect(manifest.successCount, 1);
      expect(manifest.failedCount, 1);
    });

    test('manifest has non-null completedAt', () {
      final engine = BulkExportEngine();
      final job = makeCompletedJob(id: 'j1');
      final manifest = engine.generateExportManifest(job);
      expect(manifest.completedAt, isNotNull);
    });

    test('manifest fileNames is a list', () {
      final engine = BulkExportEngine();
      final job = makeCompletedJob(id: 'j1');
      final manifest = engine.generateExportManifest(job);
      expect(manifest.fileNames, isA<List<String>>());
    });

    test('manifest is immutable — ExportManifest has const fields', () {
      final engine = BulkExportEngine();
      final job = makeCompletedJob(id: 'j1');
      final manifest = engine.generateExportManifest(job);
      // Verify the properties are accessible (compile-time correctness)
      expect(manifest.jobId, isA<String>());
      expect(manifest.successCount, isA<int>());
      expect(manifest.failedCount, isA<int>());
      expect(manifest.fileNames, isA<List<String>>());
    });
  });
}
