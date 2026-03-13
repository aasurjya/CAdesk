import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/rpa/domain/models/rpa_task.dart';
import 'package:ca_app/features/rpa/data/mappers/rpa_mapper.dart';

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

  group('RpaDao', () {
    RpaTask makeTask({
      String? id,
      String? clientId,
      RpaTaskType? taskType,
      RpaStatus? status,
      DateTime? scheduledAt,
    }) {
      counter++;
      return RpaTask(
        id: id ?? 'rpa-$counter',
        taskType: taskType ?? RpaTaskType.gstLogin,
        clientId: clientId,
        status: status ?? RpaStatus.scheduled,
        scheduledAt: scheduledAt ?? DateTime(2026, 3, counter % 28 + 1),
        retryCount: 0,
      );
    }

    group('insert', () {
      test('inserts task and is retrievable', () async {
        final task = makeTask(clientId: 'client-rpa-insert');
        await database.rpaDao.insert(RpaMapper.toCompanion(task));
        final results = await database.rpaDao.getByClient(task.clientId!);
        expect(results.any((r) => r.id == task.id), isTrue);
      });

      test('inserted task has correct taskType', () async {
        final task = makeTask(taskType: RpaTaskType.tdsDownload);
        await database.rpaDao.insert(RpaMapper.toCompanion(task));
        final results = await database.rpaDao.getByType(RpaTaskType.tdsDownload.name);
        expect(results.any((r) => r.id == task.id), isTrue);
      });

      test('inserted task has correct status', () async {
        final task = makeTask(status: RpaStatus.running);
        await database.rpaDao.insert(RpaMapper.toCompanion(task));
        final results = await database.rpaDao.getByStatus(RpaStatus.running.name);
        expect(results.any((r) => r.id == task.id), isTrue);
      });

      test('inserted task with null clientId is stored correctly', () async {
        final task = makeTask();
        await database.rpaDao.insert(RpaMapper.toCompanion(task));
        final results = await database.rpaDao.getByStatus(task.status.name);
        final row = results.firstWhere((r) => r.id == task.id);
        expect(row.clientId, isNull);
      });
    });

    group('getByClient', () {
      test('returns tasks for specific client', () async {
        final clientId = 'client-rpa-q';
        final t1 = makeTask(clientId: clientId);
        final t2 = makeTask(clientId: clientId);
        await database.rpaDao.insert(RpaMapper.toCompanion(t1));
        await database.rpaDao.insert(RpaMapper.toCompanion(t2));
        final results = await database.rpaDao.getByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty for unknown client', () async {
        final results = await database.rpaDao.getByClient('no-such-rpa-client');
        expect(results, isEmpty);
      });

      test('filters by clientId correctly', () async {
        final clientA = 'rpa-filter-a';
        final clientB = 'rpa-filter-b';
        await database.rpaDao.insert(RpaMapper.toCompanion(makeTask(clientId: clientA)));
        await database.rpaDao.insert(RpaMapper.toCompanion(makeTask(clientId: clientB)));
        final results = await database.rpaDao.getByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getByStatus', () {
      test('returns tasks matching status', () async {
        final task = makeTask(status: RpaStatus.completed);
        await database.rpaDao.insert(RpaMapper.toCompanion(task));
        final results = await database.rpaDao.getByStatus(RpaStatus.completed.name);
        expect(results.any((r) => r.id == task.id), isTrue);
      });

      test('returns empty when no tasks match status', () async {
        final results = await database.rpaDao.getByStatus('bogus-status');
        expect(results, isEmpty);
      });
    });

    group('getByType', () {
      test('returns tasks of specific type', () async {
        final task = makeTask(taskType: RpaTaskType.mcaFiling);
        await database.rpaDao.insert(RpaMapper.toCompanion(task));
        final results = await database.rpaDao.getByType(RpaTaskType.mcaFiling.name);
        expect(results.any((r) => r.id == task.id), isTrue);
      });

      test('filters by taskType correctly', () async {
        final t1 = makeTask(taskType: RpaTaskType.itrSubmit);
        final t2 = makeTask(taskType: RpaTaskType.traces26asFetch);
        await database.rpaDao.insert(RpaMapper.toCompanion(t1));
        await database.rpaDao.insert(RpaMapper.toCompanion(t2));
        final results = await database.rpaDao.getByType(RpaTaskType.itrSubmit.name);
        expect(results.every((r) => r.taskType == RpaTaskType.itrSubmit.name), isTrue);
      });
    });

    group('updateStatus', () {
      test('updates status from scheduled to running', () async {
        final task = makeTask(status: RpaStatus.scheduled);
        await database.rpaDao.insert(RpaMapper.toCompanion(task));

        final success = await database.rpaDao.updateStatus(
          task.id,
          RpaStatus.running.name,
          startedAt: DateTime(2026, 3, 15, 10, 0),
        );
        expect(success, isTrue);

        final results = await database.rpaDao.getByStatus(RpaStatus.running.name);
        final updated = results.firstWhere((r) => r.id == task.id);
        expect(updated.status, RpaStatus.running.name);
        expect(updated.startedAt, isNotNull);
      });

      test('updates status to failed with errorMessage', () async {
        final task = makeTask(status: RpaStatus.running);
        await database.rpaDao.insert(RpaMapper.toCompanion(task));

        await database.rpaDao.updateStatus(
          task.id,
          RpaStatus.failed.name,
          errorMessage: 'Login timeout',
          retryCount: 1,
        );

        final results = await database.rpaDao.getByStatus(RpaStatus.failed.name);
        final updated = results.firstWhere((r) => r.id == task.id);
        expect(updated.status, RpaStatus.failed.name);
        expect(updated.errorMessage, 'Login timeout');
        expect(updated.retryCount, 1);
      });

      test('returns false for non-existent task id', () async {
        final success = await database.rpaDao.updateStatus(
          'non-existent',
          RpaStatus.completed.name,
        );
        expect(success, isFalse);
      });
    });

    group('getScheduled', () {
      test('returns tasks scheduled before given time', () async {
        final past = DateTime(2026, 1, 1);
        final future = DateTime(2027, 1, 1);
        final pastTask = RpaTask(
          id: 'scheduled-past',
          taskType: RpaTaskType.portalStatusCheck,
          status: RpaStatus.scheduled,
          scheduledAt: past,
          retryCount: 0,
        );
        final futureTask = RpaTask(
          id: 'scheduled-future',
          taskType: RpaTaskType.portalStatusCheck,
          status: RpaStatus.scheduled,
          scheduledAt: future,
          retryCount: 0,
        );
        await database.rpaDao.insert(RpaMapper.toCompanion(pastTask));
        await database.rpaDao.insert(RpaMapper.toCompanion(futureTask));

        final cutoff = DateTime(2026, 6, 1);
        final results = await database.rpaDao.getScheduled(cutoff);
        expect(results.any((r) => r.id == 'scheduled-past'), isTrue);
        expect(results.any((r) => r.id == 'scheduled-future'), isFalse);
      });
    });

    group('getPending', () {
      test('returns both scheduled and running tasks', () async {
        final sched = makeTask(status: RpaStatus.scheduled);
        final running = makeTask(status: RpaStatus.running);
        final completed = makeTask(status: RpaStatus.completed);
        await database.rpaDao.insert(RpaMapper.toCompanion(sched));
        await database.rpaDao.insert(RpaMapper.toCompanion(running));
        await database.rpaDao.insert(RpaMapper.toCompanion(completed));

        final results = await database.rpaDao.getPending();
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(sched.id), isTrue);
        expect(ids.contains(running.id), isTrue);
        expect(ids.contains(completed.id), isFalse);
      });
    });

    group('cancel', () {
      test('cancels a scheduled task', () async {
        final task = makeTask(status: RpaStatus.scheduled);
        await database.rpaDao.insert(RpaMapper.toCompanion(task));

        final success = await database.rpaDao.cancel(task.id);
        expect(success, isTrue);

        final results = await database.rpaDao.getByStatus(RpaStatus.cancelled.name);
        expect(results.any((r) => r.id == task.id), isTrue);
      });

      test('returns false for non-existent taskId', () async {
        final success = await database.rpaDao.cancel('no-such-task');
        expect(success, isFalse);
      });
    });

    group('Immutability', () {
      test('RpaTask copyWith returns new instance', () {
        final t1 = makeTask(status: RpaStatus.scheduled);
        final t2 = t1.copyWith(status: RpaStatus.completed);
        expect(t1.status, RpaStatus.scheduled);
        expect(t2.status, RpaStatus.completed);
        expect(t1.id, t2.id);
      });

      test('copyWith preserves unchanged fields', () {
        final t1 = makeTask(
          taskType: RpaTaskType.gstLogin,
          clientId: 'cl-preserve',
        );
        final t2 = t1.copyWith(retryCount: 3);
        expect(t2.taskType, RpaTaskType.gstLogin);
        expect(t2.clientId, 'cl-preserve');
        expect(t2.retryCount, 3);
      });
    });
  });
}
