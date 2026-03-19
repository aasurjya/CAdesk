import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_job.dart';
import 'package:ca_app/features/ocr/data/mappers/ocr_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  late int counter;

  setUpAll(() async {
    database = _createTestDatabase();
    counter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  group('OcrDao', () {
    OcrJob makeJob({
      String? id,
      String? clientId,
      OcrDocType? documentType,
      OcrStatus? status,
      DateTime? createdAt,
    }) {
      counter++;
      return OcrJob(
        id: id ?? 'job-$counter',
        clientId: clientId ?? 'client-$counter',
        documentType: documentType ?? OcrDocType.form16,
        inputFilePath: '/docs/file-$counter.pdf',
        status: status ?? OcrStatus.queued,
        confidence: 0.0,
        createdAt: createdAt ?? DateTime(2026, 3, counter % 28 + 1),
      );
    }

    group('insert', () {
      test('inserts a job and is retrievable by clientId', () async {
        final job = makeJob(clientId: 'client-insert');
        await database.ocrDao.insert(OcrMapper.toCompanion(job));
        final results = await database.ocrDao.getByClient('client-insert');
        expect(results.any((r) => r.id == job.id), isTrue);
      });

      test('inserted job has correct documentType', () async {
        final job = makeJob(documentType: OcrDocType.bankStatement);
        await database.ocrDao.insert(OcrMapper.toCompanion(job));
        final results = await database.ocrDao.getByClient(job.clientId);
        final row = results.firstWhere((r) => r.id == job.id);
        expect(row.documentType, OcrDocType.bankStatement.name);
      });

      test('inserted job has queued status by default', () async {
        final job = makeJob(status: OcrStatus.queued);
        await database.ocrDao.insert(OcrMapper.toCompanion(job));
        final results = await database.ocrDao.getByStatus(
          OcrStatus.queued.name,
        );
        expect(results.any((r) => r.id == job.id), isTrue);
      });

      test('inserted job preserves inputFilePath', () async {
        final job = makeJob();
        await database.ocrDao.insert(OcrMapper.toCompanion(job));
        final results = await database.ocrDao.getByClient(job.clientId);
        final row = results.firstWhere((r) => r.id == job.id);
        expect(row.inputFilePath, job.inputFilePath);
      });
    });

    group('getByClient', () {
      test('returns jobs for specific client', () async {
        const clientId = 'client-by-client';
        final j1 = makeJob(clientId: clientId);
        final j2 = makeJob(clientId: clientId);
        await database.ocrDao.insert(OcrMapper.toCompanion(j1));
        await database.ocrDao.insert(OcrMapper.toCompanion(j2));
        final results = await database.ocrDao.getByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for unknown client', () async {
        final results = await database.ocrDao.getByClient('no-such-client');
        expect(results, isEmpty);
      });

      test('filters by clientId correctly', () async {
        const clientA = 'client-filter-ocr-a';
        const clientB = 'client-filter-ocr-b';
        await database.ocrDao.insert(
          OcrMapper.toCompanion(makeJob(clientId: clientA)),
        );
        await database.ocrDao.insert(
          OcrMapper.toCompanion(makeJob(clientId: clientB)),
        );
        final results = await database.ocrDao.getByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getByStatus', () {
      test('returns jobs matching the given status', () async {
        final job = makeJob(status: OcrStatus.processing);
        await database.ocrDao.insert(OcrMapper.toCompanion(job));
        final results = await database.ocrDao.getByStatus(
          OcrStatus.processing.name,
        );
        expect(results.any((r) => r.id == job.id), isTrue);
      });

      test('returns empty list when no jobs match status', () async {
        final results = await database.ocrDao.getByStatus('nonexistent-status');
        expect(results, isEmpty);
      });
    });

    group('updateStatus', () {
      test('updates job status to completed', () async {
        final job = makeJob(status: OcrStatus.queued);
        await database.ocrDao.insert(OcrMapper.toCompanion(job));

        final success = await database.ocrDao.updateStatus(
          job.id,
          OcrStatus.completed.name,
          completedAt: DateTime(2026, 3, 15),
        );
        expect(success, isTrue);

        final results = await database.ocrDao.getByClient(job.clientId);
        final updated = results.firstWhere((r) => r.id == job.id);
        expect(updated.status, OcrStatus.completed.name);
        expect(updated.completedAt, isNotNull);
      });

      test('updates status to failed with errorMessage', () async {
        final job = makeJob(status: OcrStatus.processing);
        await database.ocrDao.insert(OcrMapper.toCompanion(job));

        await database.ocrDao.updateStatus(
          job.id,
          OcrStatus.failed.name,
          errorMessage: 'Image quality too low',
        );

        final results = await database.ocrDao.getByClient(job.clientId);
        final updated = results.firstWhere((r) => r.id == job.id);
        expect(updated.status, OcrStatus.failed.name);
        expect(updated.errorMessage, 'Image quality too low');
      });

      test('returns false for non-existent job id', () async {
        final success = await database.ocrDao.updateStatus(
          'non-existent',
          OcrStatus.completed.name,
        );
        expect(success, isFalse);
      });
    });

    group('updateParsedData', () {
      test('updates parsed data and confidence', () async {
        final job = makeJob();
        await database.ocrDao.insert(OcrMapper.toCompanion(job));

        final success = await database.ocrDao.updateParsedData(
          job.id,
          '{"pan":"ABCDE1234F"}',
          0.95,
        );
        expect(success, isTrue);

        final results = await database.ocrDao.getByClient(job.clientId);
        final updated = results.firstWhere((r) => r.id == job.id);
        expect(updated.parsedData, '{"pan":"ABCDE1234F"}');
        expect(updated.confidence, 0.95);
      });

      test('returns false for non-existent job', () async {
        final success = await database.ocrDao.updateParsedData(
          'no-such-job',
          '{}',
          0.5,
        );
        expect(success, isFalse);
      });
    });

    group('getByDocType', () {
      test('returns jobs matching documentType', () async {
        final job = makeJob(documentType: OcrDocType.invoice);
        await database.ocrDao.insert(OcrMapper.toCompanion(job));
        final results = await database.ocrDao.getByDocType(
          OcrDocType.invoice.name,
        );
        expect(results.any((r) => r.id == job.id), isTrue);
      });

      test('filters by documentType correctly', () async {
        final j1 = makeJob(documentType: OcrDocType.panCard);
        final j2 = makeJob(documentType: OcrDocType.aadhar);
        await database.ocrDao.insert(OcrMapper.toCompanion(j1));
        await database.ocrDao.insert(OcrMapper.toCompanion(j2));
        final results = await database.ocrDao.getByDocType(
          OcrDocType.panCard.name,
        );
        expect(
          results.every((r) => r.documentType == OcrDocType.panCard.name),
          isTrue,
        );
      });
    });

    group('cleanup', () {
      test('removes records created before given date', () async {
        final oldDate = DateTime(2025, 1, 1);
        final newDate = DateTime(2026, 3, 1);
        final oldJob = OcrJob(
          id: 'old-cleanup-job',
          clientId: 'cleanup-client',
          documentType: OcrDocType.form16,
          inputFilePath: '/old.pdf',
          status: OcrStatus.completed,
          confidence: 0.9,
          createdAt: oldDate,
        );
        final newJob = OcrJob(
          id: 'new-cleanup-job',
          clientId: 'cleanup-client',
          documentType: OcrDocType.form16,
          inputFilePath: '/new.pdf',
          status: OcrStatus.queued,
          confidence: 0.0,
          createdAt: newDate,
        );
        await database.ocrDao.insert(OcrMapper.toCompanion(oldJob));
        await database.ocrDao.insert(OcrMapper.toCompanion(newJob));

        final cutoff = DateTime(2025, 6, 1);
        final deleted = await database.ocrDao.cleanup(cutoff);
        expect(deleted, greaterThanOrEqualTo(1));

        final remaining = await database.ocrDao.getByClient('cleanup-client');
        expect(remaining.any((r) => r.id == 'old-cleanup-job'), isFalse);
        expect(remaining.any((r) => r.id == 'new-cleanup-job'), isTrue);
      });
    });

    group('Immutability', () {
      test('OcrJob copyWith returns new instance', () {
        final j1 = makeJob(status: OcrStatus.queued);
        final j2 = j1.copyWith(status: OcrStatus.completed);
        expect(j1.status, OcrStatus.queued);
        expect(j2.status, OcrStatus.completed);
        expect(j1.id, j2.id);
      });

      test('copyWith preserves unchanged fields', () {
        final j1 = makeJob(clientId: 'cl-x', documentType: OcrDocType.form26as);
        final j2 = j1.copyWith(confidence: 0.99);
        expect(j2.clientId, 'cl-x');
        expect(j2.documentType, OcrDocType.form26as);
        expect(j2.confidence, 0.99);
      });
    });
  });
}
