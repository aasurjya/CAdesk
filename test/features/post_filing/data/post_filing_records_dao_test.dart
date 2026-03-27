import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/post_filing/domain/models/post_filing_record.dart';
import 'package:ca_app/features/post_filing/data/mappers/post_filing_record_mapper.dart';

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

  group('PostFilingRecordsDao', () {
    PostFilingRecord createTestRecord({
      String? id,
      String? clientId,
      String? filingId,
      PostFilingActivity? activityType,
      PostFilingStatus? status,
      DateTime? completedAt,
      String? notes,
      DateTime? createdAt,
    }) {
      testCounter++;
      return PostFilingRecord(
        id: id ?? 'pfr-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        filingId: filingId ?? 'filing-$testCounter',
        activityType: activityType ?? PostFilingActivity.itrVDownload,
        status: status ?? PostFilingStatus.pending,
        completedAt: completedAt,
        notes: notes,
        createdAt: createdAt ?? DateTime(2025, 7, 1),
      );
    }

    group('insertRecord', () {
      test('inserts record and returns non-empty ID', () async {
        final record = createTestRecord();
        final companion = PostFilingRecordMapper.toCompanion(record);
        final id = await database.postFilingRecordsDao.insertRecord(companion);
        expect(id, isNotEmpty);
      });

      test('stored record has correct clientId', () async {
        final record = createTestRecord();
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.postFilingRecordsDao.getById(
          record.id,
        );
        expect(retrieved?.clientId, record.clientId);
      });

      test('stored record has correct filingId', () async {
        final record = createTestRecord(filingId: 'specific-filing-id');
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.postFilingRecordsDao.getById(
          record.id,
        );
        expect(retrieved?.filingId, 'specific-filing-id');
      });

      test('stored record has correct activityType', () async {
        final record = createTestRecord(
          activityType: PostFilingActivity.eVerification,
        );
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.postFilingRecordsDao.getById(
          record.id,
        );
        final domain = retrieved != null
            ? PostFilingRecordMapper.fromRow(retrieved)
            : null;
        expect(domain?.activityType, PostFilingActivity.eVerification);
      });

      test('stored record has correct status', () async {
        final record = createTestRecord(status: PostFilingStatus.completed);
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.postFilingRecordsDao.getById(
          record.id,
        );
        final domain = retrieved != null
            ? PostFilingRecordMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, PostFilingStatus.completed);
      });

      test('stored record preserves optional notes', () async {
        final record = createTestRecord(notes: 'Verified via Aadhaar OTP');
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.postFilingRecordsDao.getById(
          record.id,
        );
        expect(retrieved?.notes, 'Verified via Aadhaar OTP');
      });
    });

    group('getByFiling', () {
      test('returns records for specific filing', () async {
        const filingId = 'post-filing-test-filing-1';
        final r1 = createTestRecord(filingId: filingId);
        final r2 = createTestRecord(filingId: filingId);
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r1),
        );
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r2),
        );

        final results = await database.postFilingRecordsDao.getByFiling(
          filingId,
        );
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent filing', () async {
        final results = await database.postFilingRecordsDao.getByFiling(
          'non-existent-filing-id',
        );
        expect(results, isEmpty);
      });

      test('filters records by filing correctly', () async {
        const filingA = 'post-filing-fa-1';
        const filingB = 'post-filing-fb-1';
        final r1 = createTestRecord(filingId: filingA);
        final r2 = createTestRecord(filingId: filingB);
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r1),
        );
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r2),
        );

        final results = await database.postFilingRecordsDao.getByFiling(
          filingA,
        );
        expect(results.every((r) => r.filingId == filingA), isTrue);
      });
    });

    group('getByClient', () {
      test('returns records for specific client', () async {
        const clientId = 'post-filing-client-a';
        final r1 = createTestRecord(clientId: clientId);
        final r2 = createTestRecord(clientId: clientId);
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r1),
        );
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r2),
        );

        final results = await database.postFilingRecordsDao.getByClient(
          clientId,
        );
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.postFilingRecordsDao.getByClient(
          'non-existent-pf-client',
        );
        expect(results, isEmpty);
      });
    });

    group('updateStatus', () {
      test(
        'updates status from pending to completed with completedAt',
        () async {
          final record = createTestRecord(status: PostFilingStatus.pending);
          await database.postFilingRecordsDao.insertRecord(
            PostFilingRecordMapper.toCompanion(record),
          );

          final completedAt = DateTime(2025, 7, 16);
          final success = await database.postFilingRecordsDao.updateStatus(
            record.id,
            PostFilingStatus.completed.name,
            completedAt: completedAt,
            notes: 'Completed successfully',
          );
          expect(success, isTrue);

          final retrieved = await database.postFilingRecordsDao.getById(
            record.id,
          );
          final domain = retrieved != null
              ? PostFilingRecordMapper.fromRow(retrieved)
              : null;
          expect(domain?.status, PostFilingStatus.completed);
          expect(domain?.completedAt, completedAt);
          expect(domain?.notes, 'Completed successfully');
        },
      );

      test('updates status to failed', () async {
        final record = createTestRecord(status: PostFilingStatus.inProgress);
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );

        await database.postFilingRecordsDao.updateStatus(
          record.id,
          PostFilingStatus.failed.name,
        );

        final retrieved = await database.postFilingRecordsDao.getById(
          record.id,
        );
        final domain = retrieved != null
            ? PostFilingRecordMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, PostFilingStatus.failed);
      });

      test('returns false for non-existent ID', () async {
        final success = await database.postFilingRecordsDao.updateStatus(
          'non-existent-pfr-id',
          PostFilingStatus.completed.name,
        );
        expect(success, isFalse);
      });
    });

    group('getPending', () {
      test('returns all pending records', () async {
        final r1 = createTestRecord(status: PostFilingStatus.pending);
        final r2 = createTestRecord(status: PostFilingStatus.pending);
        final r3 = createTestRecord(status: PostFilingStatus.completed);
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r1),
        );
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r2),
        );
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(r3),
        );

        final pending = await database.postFilingRecordsDao.getPending();
        expect(pending.length, greaterThanOrEqualTo(2));
        expect(
          pending.every((r) => r.status == PostFilingStatus.pending.name),
          isTrue,
        );
      });

      test('excludes completed records from pending list', () async {
        final record = createTestRecord(status: PostFilingStatus.completed);
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );

        final pending = await database.postFilingRecordsDao.getPending();
        expect(pending.where((r) => r.id == record.id).isEmpty, isTrue);
      });
    });

    group('getById', () {
      test('retrieves record by ID', () async {
        final record = createTestRecord();
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );

        final retrieved = await database.postFilingRecordsDao.getById(
          record.id,
        );
        expect(retrieved != null, isTrue);
        expect(retrieved?.id, record.id);
      });

      test('returns null for non-existent ID', () async {
        final retrieved = await database.postFilingRecordsDao.getById(
          'non-existent-post-filing-id',
        );
        expect(retrieved == null, isTrue);
      });
    });

    group('watchByClient', () {
      test('emits records for client on watch', () async {
        final record = createTestRecord();
        await database.postFilingRecordsDao.insertRecord(
          PostFilingRecordMapper.toCompanion(record),
        );

        final stream = database.postFilingRecordsDao.watchByClient(
          record.clientId,
        );
        expect(
          stream,
          emits(
            isA<List<PostFilingRecordRow>>().having(
              (rows) => rows.isNotEmpty,
              'has records',
              true,
            ),
          ),
        );
      });
    });

    group('Immutability', () {
      test('PostFilingRecord has copyWith for immutable updates', () {
        final r1 = createTestRecord();
        final r2 = r1.copyWith(status: PostFilingStatus.completed);

        expect(r1.status, PostFilingStatus.pending);
        expect(r2.status, PostFilingStatus.completed);
        expect(r1.id, r2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final r1 = createTestRecord(
          activityType: PostFilingActivity.refundClaim,
          notes: 'Refund expected in 3 months',
        );
        final r2 = r1.copyWith(status: PostFilingStatus.inProgress);

        expect(r2.clientId, r1.clientId);
        expect(r2.filingId, r1.filingId);
        expect(r2.activityType, PostFilingActivity.refundClaim);
        expect(r2.notes, 'Refund expected in 3 months');
      });

      test('PostFilingRecord equality is based on id', () {
        testCounter++;
        final r1 = PostFilingRecord(
          id: 'same-pfr-id',
          clientId: 'c1',
          filingId: 'f1',
          activityType: PostFilingActivity.itrVDownload,
          status: PostFilingStatus.pending,
          createdAt: DateTime(2025),
        );
        final r2 = PostFilingRecord(
          id: 'same-pfr-id',
          clientId: 'c2',
          filingId: 'f2',
          activityType: PostFilingActivity.eVerification,
          status: PostFilingStatus.completed,
          createdAt: DateTime(2024),
        );
        expect(r1, equals(r2));
        expect(r1.hashCode, equals(r2.hashCode));
      });

      test('all PostFilingActivity values are distinct', () {
        const activities = PostFilingActivity.values;
        final names = activities.map((a) => a.name).toSet();
        expect(names.length, activities.length);
      });

      test('all PostFilingStatus values are distinct', () {
        const statuses = PostFilingStatus.values;
        final names = statuses.map((s) => s.name).toSet();
        expect(names.length, statuses.length);
      });
    });
  });
}
