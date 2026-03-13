import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';
import 'package:ca_app/features/time_tracking/data/mappers/time_entry_mapper.dart';

AppDatabase _createTestDatabase() =>
    AppDatabase(executor: NativeDatabase.memory());

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

  TimeEntry makeEntry({
    String? id,
    String? clientId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? isBilled,
    TimeEntryStatus? status,
  }) {
    counter++;
    final start = startTime ?? DateTime(2026, 3, counter, 9);
    return TimeEntry(
      id: id ?? 'te-$counter',
      staffId: 'staff-1',
      staffName: 'Test Staff',
      clientId: clientId ?? 'client-1',
      clientName: 'Test Client',
      taskDescription: 'Task description $counter',
      startTime: start,
      endTime: endTime ?? start.add(const Duration(hours: 2)),
      durationMinutes: durationMinutes ?? 120,
      isBillable: true,
      hourlyRate: 1500.0,
      billedAmount: 0,
      status: status ?? TimeEntryStatus.completed,
    );
  }

  group('TimeEntriesDao', () {
    group('insertEntry', () {
      test('returns the ID of the inserted entry', () async {
        final e = makeEntry();
        final id = await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        expect(id, e.id);
      });

      test('stored entry has correct clientId', () async {
        final e = makeEntry(clientId: 'client-abc');
        await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        final row = await database.timeEntriesDao.getEntryById(e.id);
        expect(row?.clientId, 'client-abc');
      });

      test('stored entry has correct durationMinutes', () async {
        final e = makeEntry(durationMinutes: 90);
        await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        final row = await database.timeEntriesDao.getEntryById(e.id);
        expect(row?.durationMinutes, 90);
      });

      test('stored entry has correct status', () async {
        final e = makeEntry(status: TimeEntryStatus.billed);
        await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        final row = await database.timeEntriesDao.getEntryById(e.id);
        expect(row?.status, TimeEntryStatus.billed.name);
      });
    });

    group('getByClient', () {
      test('returns entries for the specific client', () async {
        final e1 = makeEntry(clientId: 'client-filter-x');
        final e2 = makeEntry(clientId: 'client-filter-x');
        final e3 = makeEntry(clientId: 'client-other');
        for (final e in [e1, e2, e3]) {
          await database.timeEntriesDao
              .insertEntry(TimeEntryMapper.toCompanion(e));
        }

        final results =
            await database.timeEntriesDao.getByClient('client-filter-x');
        final ids = results.map((r) => r.id).toSet();
        expect(ids, containsAll([e1.id, e2.id]));
        expect(ids.contains(e3.id), isFalse);
      });

      test('returns empty list for non-existent client', () async {
        final results =
            await database.timeEntriesDao.getByClient('no-such-client');
        expect(results, isEmpty);
      });
    });

    group('getByDateRange', () {
      test('returns entries within date range', () async {
        final inRange = makeEntry(
          startTime: DateTime(2026, 3, 10, 10),
        );
        final outOfRange = makeEntry(
          startTime: DateTime(2026, 1, 5, 10),
        );
        await database.timeEntriesDao
            .insertEntry(TimeEntryMapper.toCompanion(inRange));
        await database.timeEntriesDao
            .insertEntry(TimeEntryMapper.toCompanion(outOfRange));

        final results = await database.timeEntriesDao.getByDateRange(
          DateTime(2026, 3, 1),
          DateTime(2026, 3, 31),
        );
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(inRange.id), isTrue);
        expect(ids.contains(outOfRange.id), isFalse);
      });

      test('returns empty list when no entries in range', () async {
        final results = await database.timeEntriesDao.getByDateRange(
          DateTime(2020, 1, 1),
          DateTime(2020, 1, 2),
        );
        expect(results, isEmpty);
      });
    });

    group('getUnbilled', () {
      test('returns only non-billed entries for client', () async {
        final clientId = 'client-unbilled-test';
        final billed = makeEntry(
          clientId: clientId,
          status: TimeEntryStatus.billed,
        );
        final unbilled = makeEntry(
          clientId: clientId,
          status: TimeEntryStatus.completed,
        );
        await database.timeEntriesDao
            .insertEntry(TimeEntryMapper.toCompanion(billed));
        await database.timeEntriesDao
            .insertEntry(TimeEntryMapper.toCompanion(unbilled));

        final results =
            await database.timeEntriesDao.getUnbilled(clientId);
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(unbilled.id), isTrue);
        expect(ids.contains(billed.id), isFalse);
      });
    });

    group('getEntriesForMonth', () {
      test('returns entries matching client, month, year', () async {
        final clientId = 'client-month-test';
        final march = makeEntry(
          clientId: clientId,
          startTime: DateTime(2026, 3, 15, 10),
        );
        final april = makeEntry(
          clientId: clientId,
          startTime: DateTime(2026, 4, 1, 10),
        );
        await database.timeEntriesDao
            .insertEntry(TimeEntryMapper.toCompanion(march));
        await database.timeEntriesDao
            .insertEntry(TimeEntryMapper.toCompanion(april));

        final results = await database.timeEntriesDao
            .getEntriesForMonth(clientId, 3, 2026);
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(march.id), isTrue);
        expect(ids.contains(april.id), isFalse);
      });

      test('returns empty list when no entries in month', () async {
        final results = await database.timeEntriesDao
            .getEntriesForMonth('no-client', 12, 2020);
        expect(results, isEmpty);
      });
    });

    group('updateEntry', () {
      test('update returns true for existing entry', () async {
        final e = makeEntry();
        await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        final updated =
            e.copyWith(durationMinutes: 200, status: TimeEntryStatus.billed);
        final result = await database.timeEntriesDao.updateEntry(
          TimeEntryMapper.toCompanion(updated),
        );
        expect(result, isTrue);
      });

      test('updated entry has new durationMinutes', () async {
        final e = makeEntry(durationMinutes: 60);
        await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        final updated = e.copyWith(durationMinutes: 180);
        await database.timeEntriesDao.updateEntry(
          TimeEntryMapper.toCompanion(updated),
        );
        final row = await database.timeEntriesDao.getEntryById(e.id);
        expect(row?.durationMinutes, 180);
      });

      test('update returns false for non-existent ID', () async {
        final e = makeEntry(id: 'ghost-id-xyz');
        final result = await database.timeEntriesDao.updateEntry(
          TimeEntryMapper.toCompanion(e),
        );
        expect(result, isFalse);
      });
    });

    group('deleteEntry', () {
      test('delete returns true for existing entry', () async {
        final e = makeEntry();
        await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        final result = await database.timeEntriesDao.deleteEntry(e.id);
        expect(result, isTrue);
      });

      test('deleted entry is no longer retrievable', () async {
        final e = makeEntry();
        await database.timeEntriesDao.insertEntry(
          TimeEntryMapper.toCompanion(e),
        );
        await database.timeEntriesDao.deleteEntry(e.id);
        final row = await database.timeEntriesDao.getEntryById(e.id);
        expect(row, isNull);
      });

      test('delete returns false for non-existent ID', () async {
        final result =
            await database.timeEntriesDao.deleteEntry('ghost-delete-id');
        expect(result, isFalse);
      });
    });

    group('Immutability', () {
      test('TimeEntry has copyWith', () {
        final e1 = makeEntry(durationMinutes: 60);
        final e2 = e1.copyWith(durationMinutes: 90);
        expect(e1.durationMinutes, 60);
        expect(e2.durationMinutes, 90);
        expect(e1.id, e2.id);
      });

      test('copyWith preserves all unchanged fields', () {
        final e1 = makeEntry(clientId: 'client-kept');
        final e2 = e1.copyWith(durationMinutes: 30);
        expect(e2.clientId, 'client-kept');
        expect(e2.staffId, e1.staffId);
        expect(e2.taskDescription, e1.taskDescription);
      });
    });
  });
}
