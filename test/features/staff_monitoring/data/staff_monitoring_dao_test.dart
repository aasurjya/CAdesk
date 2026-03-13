import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_activity.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_performance.dart';
import 'package:ca_app/features/staff_monitoring/data/mappers/staff_monitoring_mapper.dart';

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

  group('StaffMonitoringDao', () {
    StaffActivity makeActivity({
      String? id,
      String? staffId,
      ActivityType? activityType,
      String? clientId,
      DateTime? startTime,
      int? durationMinutes,
    }) {
      counter++;
      return StaffActivity(
        id: id ?? 'act-$counter',
        staffId: staffId ?? 'staff-$counter',
        activityType: activityType ?? ActivityType.filing,
        clientId: clientId,
        startTime: startTime ?? DateTime(2026, 3, counter % 28 + 1, 9, 0),
        durationMinutes: durationMinutes ?? 60,
      );
    }

    StaffPerformance makePerformance({
      String? id,
      String? staffId,
      String? period,
      int? tasksCompleted,
      double? hoursLogged,
      int? clientsHandled,
      double? avgCompletionTime,
    }) {
      counter++;
      return StaffPerformance(
        id: id ?? 'perf-$counter',
        staffId: staffId ?? 'staff-$counter',
        period: period ?? '2026-03',
        tasksCompleted: tasksCompleted ?? counter * 5,
        hoursLogged: hoursLogged ?? 40.0,
        clientsHandled: clientsHandled ?? counter * 3,
        avgCompletionTime: avgCompletionTime ?? 3.5,
        createdAt: DateTime(2026, 3, 1),
      );
    }

    group('insertActivity', () {
      test('inserts activity and is retrievable by staffId', () async {
        final activity = makeActivity(staffId: 'staff-insert-test');
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(activity),
        );
        final results = await database.staffMonitoringDao.getByStaff('staff-insert-test');
        expect(results.any((r) => r.id == activity.id), isTrue);
      });

      test('stored activity has correct activityType', () async {
        final activity = makeActivity(activityType: ActivityType.clientCall);
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(activity),
        );
        final results =
            await database.staffMonitoringDao.getByStaff(activity.staffId);
        final row = results.firstWhere((r) => r.id == activity.id);
        expect(row.activityType, ActivityType.clientCall.name);
      });

      test('stored activity has correct durationMinutes', () async {
        final activity = makeActivity(durationMinutes: 120);
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(activity),
        );
        final results =
            await database.staffMonitoringDao.getByStaff(activity.staffId);
        final row = results.firstWhere((r) => r.id == activity.id);
        expect(row.durationMinutes, 120);
      });

      test('stored activity with null clientId is stored correctly', () async {
        final activity = makeActivity();
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(activity),
        );
        final results =
            await database.staffMonitoringDao.getByStaff(activity.staffId);
        final row = results.firstWhere((r) => r.id == activity.id);
        expect(row.clientId, isNull);
      });
    });

    group('getByStaff', () {
      test('returns activities for specific staff', () async {
        final staffId = 'staff-by-staff';
        final a1 = makeActivity(staffId: staffId);
        final a2 = makeActivity(staffId: staffId);
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(a1),
        );
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(a2),
        );
        final results = await database.staffMonitoringDao.getByStaff(staffId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty for unknown staff', () async {
        final results =
            await database.staffMonitoringDao.getByStaff('no-such-staff');
        expect(results, isEmpty);
      });

      test('filters by staffId correctly', () async {
        final staffA = 'staff-filter-a';
        final staffB = 'staff-filter-b';
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(makeActivity(staffId: staffA)),
        );
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(makeActivity(staffId: staffB)),
        );
        final results = await database.staffMonitoringDao.getByStaff(staffA);
        expect(results.every((r) => r.staffId == staffA), isTrue);
      });
    });

    group('getByPeriod', () {
      test('returns activities within date range', () async {
        final from = DateTime(2026, 3, 1);
        final to = DateTime(2026, 3, 31);
        final activity = StaffActivity(
          id: 'period-test-act',
          staffId: 'staff-period',
          activityType: ActivityType.dataEntry,
          startTime: DateTime(2026, 3, 15),
          durationMinutes: 30,
        );
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(activity),
        );
        final results = await database.staffMonitoringDao.getByPeriod(from, to);
        expect(results.any((r) => r.id == 'period-test-act'), isTrue);
      });

      test('excludes activities outside date range', () async {
        final from = DateTime(2026, 3, 1);
        final to = DateTime(2026, 3, 31);
        final outsideActivity = StaffActivity(
          id: 'outside-period-act',
          staffId: 'staff-outside',
          activityType: ActivityType.other,
          startTime: DateTime(2025, 1, 1),
          durationMinutes: 30,
        );
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(outsideActivity),
        );
        final results = await database.staffMonitoringDao.getByPeriod(from, to);
        expect(results.any((r) => r.id == 'outside-period-act'), isFalse);
      });
    });

    group('getByClient', () {
      test('returns activities for specific client', () async {
        final clientId = 'client-staff-act';
        final activity = makeActivity(clientId: clientId);
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(activity),
        );
        final results = await database.staffMonitoringDao.getByClient(clientId);
        expect(results.any((r) => r.id == activity.id), isTrue);
      });

      test('returns empty list for unknown client', () async {
        final results =
            await database.staffMonitoringDao.getByClient('no-client-x');
        expect(results, isEmpty);
      });

      test('filters by clientId correctly', () async {
        final clientA = 'sm-client-a';
        final clientB = 'sm-client-b';
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(
            makeActivity(clientId: clientA),
          ),
        );
        await database.staffMonitoringDao.insertActivity(
          StaffMonitoringMapper.activityToCompanion(
            makeActivity(clientId: clientB),
          ),
        );
        final results = await database.staffMonitoringDao.getByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('insertPerformance', () {
      test('inserts performance and is retrievable', () async {
        final perf = makePerformance(staffId: 'staff-perf-insert');
        await database.staffMonitoringDao.insertPerformance(
          StaffMonitoringMapper.performanceToCompanion(perf),
        );
        final result = await database.staffMonitoringDao.getPerformance(
          'staff-perf-insert',
          perf.period,
        );
        expect(result, isNotNull);
        expect(result!.id, perf.id);
      });

      test('stored performance has correct tasksCompleted', () async {
        final perf = makePerformance(tasksCompleted: 42);
        await database.staffMonitoringDao.insertPerformance(
          StaffMonitoringMapper.performanceToCompanion(perf),
        );
        final result = await database.staffMonitoringDao.getPerformance(
          perf.staffId,
          perf.period,
        );
        expect(result?.tasksCompleted, 42);
      });

      test('stored performance has correct hoursLogged', () async {
        final perf = makePerformance(hoursLogged: 76.5);
        await database.staffMonitoringDao.insertPerformance(
          StaffMonitoringMapper.performanceToCompanion(perf),
        );
        final result = await database.staffMonitoringDao.getPerformance(
          perf.staffId,
          perf.period,
        );
        expect(result?.hoursLogged, 76.5);
      });
    });

    group('getPerformance', () {
      test('returns performance for matching staffId and period', () async {
        final staffId = 'staff-perf-q';
        final period = '2026-02';
        final perf = makePerformance(staffId: staffId, period: period);
        await database.staffMonitoringDao.insertPerformance(
          StaffMonitoringMapper.performanceToCompanion(perf),
        );
        final result = await database.staffMonitoringDao.getPerformance(
          staffId,
          period,
        );
        expect(result, isNotNull);
        expect(result?.staffId, staffId);
        expect(result?.period, period);
      });

      test('returns null for unknown staff', () async {
        final result = await database.staffMonitoringDao.getPerformance(
          'no-such-staff',
          '2026-03',
        );
        expect(result, isNull);
      });

      test('returns null for correct staff but wrong period', () async {
        final staffId = 'staff-wrong-period';
        final perf = makePerformance(staffId: staffId, period: '2026-01');
        await database.staffMonitoringDao.insertPerformance(
          StaffMonitoringMapper.performanceToCompanion(perf),
        );
        final result = await database.staffMonitoringDao.getPerformance(
          staffId,
          '2026-12',
        );
        expect(result, isNull);
      });
    });

    group('Immutability', () {
      test('StaffActivity copyWith returns new instance', () {
        final a1 = makeActivity(activityType: ActivityType.filing);
        final a2 = a1.copyWith(activityType: ActivityType.portalWork);
        expect(a1.activityType, ActivityType.filing);
        expect(a2.activityType, ActivityType.portalWork);
        expect(a1.id, a2.id);
      });

      test('StaffActivity copyWith preserves unchanged fields', () {
        final a1 = makeActivity(staffId: 'st-x', durationMinutes: 90);
        final a2 = a1.copyWith(activityType: ActivityType.clientCall);
        expect(a2.staffId, 'st-x');
        expect(a2.durationMinutes, 90);
      });

      test('StaffPerformance copyWith returns new instance', () {
        final p1 = makePerformance(tasksCompleted: 10);
        final p2 = p1.copyWith(tasksCompleted: 20);
        expect(p1.tasksCompleted, 10);
        expect(p2.tasksCompleted, 20);
        expect(p1.id, p2.id);
      });

      test('StaffPerformance copyWith preserves unchanged fields', () {
        final p1 = makePerformance(
          staffId: 'st-y',
          period: '2026-01',
          hoursLogged: 80.0,
        );
        final p2 = p1.copyWith(avgCompletionTime: 2.5);
        expect(p2.staffId, 'st-y');
        expect(p2.period, '2026-01');
        expect(p2.hoursLogged, 80.0);
        expect(p2.avgCompletionTime, 2.5);
      });
    });
  });
}
