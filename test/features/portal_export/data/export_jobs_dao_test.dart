import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_export/domain/models/export_job.dart';
import 'package:ca_app/features/portal_export/data/mappers/export_job_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  late int testCounter;

  setUpAll(() async {
    database = _createTestDatabase();
    testCounter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  group('ExportJobsDao', () {
    ExportJob createTestJob({
      String? id,
      String? clientId,
      ExportType? exportType,
      ExportJobStatus? status,
      DateTime? createdAt,
      DateTime? completedAt,
      String? filePath,
      String? errorMessage,
    }) {
      testCounter++;
      return ExportJob(
        id: id ?? 'ej-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        exportType: exportType ?? ExportType.itrXml,
        status: status ?? ExportJobStatus.queued,
        createdAt: createdAt ?? DateTime(2025, 7, 1),
        completedAt: completedAt,
        filePath: filePath,
        errorMessage: errorMessage,
      );
    }

    group('insertJob', () {
      test('inserts job and returns non-empty ID', () async {
        final job = createTestJob();
        final companion = ExportJobMapper.toCompanion(job);
        final id = await database.exportJobsDao.insertJob(companion);
        expect(id, isNotEmpty);
      });

      test('stored job has correct clientId', () async {
        final job = createTestJob();
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );
        final retrieved = await database.exportJobsDao.getById(job.id);
        expect(retrieved?.clientId, job.clientId);
      });

      test('stored job has correct exportType', () async {
        final job = createTestJob(exportType: ExportType.gstrJson);
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );
        final retrieved = await database.exportJobsDao.getById(job.id);
        final domain = retrieved != null
            ? ExportJobMapper.fromRow(retrieved)
            : null;
        expect(domain?.exportType, ExportType.gstrJson);
      });

      test('stored job has correct status', () async {
        final job = createTestJob(status: ExportJobStatus.processing);
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );
        final retrieved = await database.exportJobsDao.getById(job.id);
        final domain = retrieved != null
            ? ExportJobMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, ExportJobStatus.processing);
      });

      test('stored job preserves optional filePath', () async {
        final job = createTestJob(
          status: ExportJobStatus.completed,
          filePath: '/exports/test.xml',
        );
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );
        final retrieved = await database.exportJobsDao.getById(job.id);
        expect(retrieved?.filePath, '/exports/test.xml');
      });

      test('stored job preserves optional errorMessage', () async {
        final job = createTestJob(
          status: ExportJobStatus.failed,
          errorMessage: 'Validation failed',
        );
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );
        final retrieved = await database.exportJobsDao.getById(job.id);
        expect(retrieved?.errorMessage, 'Validation failed');
      });
    });

    group('getByClient', () {
      test('returns jobs for specific client', () async {
        const clientId = 'export-client-a';
        final j1 = createTestJob(clientId: clientId);
        final j2 = createTestJob(clientId: clientId);
        await database.exportJobsDao.insertJob(ExportJobMapper.toCompanion(j1));
        await database.exportJobsDao.insertJob(ExportJobMapper.toCompanion(j2));

        final results = await database.exportJobsDao.getByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.exportJobsDao.getByClient(
          'non-existent-export-client',
        );
        expect(results, isEmpty);
      });

      test('filters jobs by client correctly', () async {
        const clientA = 'export-filter-a-1';
        const clientB = 'export-filter-b-1';
        final j1 = createTestJob(clientId: clientA);
        final j2 = createTestJob(clientId: clientB);
        await database.exportJobsDao.insertJob(ExportJobMapper.toCompanion(j1));
        await database.exportJobsDao.insertJob(ExportJobMapper.toCompanion(j2));

        final results = await database.exportJobsDao.getByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getByStatus', () {
      test('returns jobs with specific status', () async {
        final j1 = createTestJob(status: ExportJobStatus.completed);
        final j2 = createTestJob(status: ExportJobStatus.completed);
        await database.exportJobsDao.insertJob(ExportJobMapper.toCompanion(j1));
        await database.exportJobsDao.insertJob(ExportJobMapper.toCompanion(j2));

        final results = await database.exportJobsDao.getByStatus(
          ExportJobStatus.completed.name,
        );
        expect(results.length, greaterThanOrEqualTo(2));
        expect(
          results.every((r) => r.status == ExportJobStatus.completed.name),
          isTrue,
        );
      });
    });

    group('updateStatus', () {
      test('updates status from queued to completed with filePath', () async {
        final job = createTestJob(status: ExportJobStatus.queued);
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );

        final success = await database.exportJobsDao.updateStatus(
          job.id,
          ExportJobStatus.completed.name,
          filePath: '/exports/result.xml',
          completedAt: DateTime(2025, 7, 2),
        );
        expect(success, isTrue);

        final retrieved = await database.exportJobsDao.getById(job.id);
        final domain = retrieved != null
            ? ExportJobMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, ExportJobStatus.completed);
        expect(domain?.filePath, '/exports/result.xml');
      });

      test('updates status to failed with errorMessage', () async {
        final job = createTestJob(status: ExportJobStatus.processing);
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );

        await database.exportJobsDao.updateStatus(
          job.id,
          ExportJobStatus.failed.name,
          errorMessage: 'FVU validation error',
        );

        final retrieved = await database.exportJobsDao.getById(job.id);
        final domain = retrieved != null
            ? ExportJobMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, ExportJobStatus.failed);
        expect(domain?.errorMessage, 'FVU validation error');
      });

      test('returns false for non-existent ID', () async {
        final success = await database.exportJobsDao.updateStatus(
          'non-existent-ej-id',
          ExportJobStatus.completed.name,
        );
        expect(success, isFalse);
      });
    });

    group('deleteOldJobs', () {
      test('deletes jobs older than cutoff date', () async {
        final oldDate = DateTime(2024, 1, 1);
        final job = createTestJob(createdAt: oldDate);
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );

        final cutoff = DateTime(2025, 1, 1);
        final deleted = await database.exportJobsDao.deleteOldJobs(cutoff);
        expect(deleted, greaterThanOrEqualTo(1));

        final retrieved = await database.exportJobsDao.getById(job.id);
        expect(retrieved == null, isTrue);
      });

      test('does not delete jobs newer than cutoff date', () async {
        final recentDate = DateTime(2025, 7, 1);
        final job = createTestJob(createdAt: recentDate);
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );

        final cutoff = DateTime(2025, 1, 1);
        await database.exportJobsDao.deleteOldJobs(cutoff);

        final retrieved = await database.exportJobsDao.getById(job.id);
        expect(retrieved != null, isTrue);
      });
    });

    group('getById', () {
      test('retrieves job by ID', () async {
        final job = createTestJob();
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );

        final retrieved = await database.exportJobsDao.getById(job.id);
        expect(retrieved != null, isTrue);
        expect(retrieved?.id, job.id);
      });

      test('returns null for non-existent ID', () async {
        final retrieved = await database.exportJobsDao.getById(
          'non-existent-export-id',
        );
        expect(retrieved == null, isTrue);
      });
    });

    group('watchByClient', () {
      test('emits jobs for client on watch', () async {
        final job = createTestJob();
        await database.exportJobsDao.insertJob(
          ExportJobMapper.toCompanion(job),
        );

        final stream = database.exportJobsDao.watchByClient(job.clientId);
        expect(
          stream,
          emits(
            isA<List<ExportJobRow>>().having(
              (rows) => rows.isNotEmpty,
              'has jobs',
              true,
            ),
          ),
        );
      });
    });

    group('Immutability', () {
      test('ExportJob has copyWith for immutable updates', () {
        final j1 = createTestJob();
        final j2 = j1.copyWith(status: ExportJobStatus.completed);

        expect(j1.status, ExportJobStatus.queued);
        expect(j2.status, ExportJobStatus.completed);
        expect(j1.id, j2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final j1 = createTestJob(
          exportType: ExportType.tdsFvu,
          filePath: '/exports/fvu.txt',
        );
        final j2 = j1.copyWith(status: ExportJobStatus.processing);

        expect(j2.clientId, j1.clientId);
        expect(j2.exportType, ExportType.tdsFvu);
        expect(j2.filePath, '/exports/fvu.txt');
      });

      test('ExportJob equality is based on id', () {
        testCounter++;
        final j1 = ExportJob(
          id: 'same-export-id',
          clientId: 'c1',
          exportType: ExportType.itrXml,
          status: ExportJobStatus.queued,
          createdAt: DateTime(2025),
        );
        final j2 = ExportJob(
          id: 'same-export-id',
          clientId: 'c2',
          exportType: ExportType.gstrJson,
          status: ExportJobStatus.completed,
          createdAt: DateTime(2024),
        );
        expect(j1, equals(j2));
        expect(j1.hashCode, equals(j2.hashCode));
      });
    });
  });
}
