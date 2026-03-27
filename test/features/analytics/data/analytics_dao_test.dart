import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/analytics/domain/models/analytics_snapshot.dart';
import 'package:ca_app/features/analytics/domain/models/client_metric.dart';
import 'package:ca_app/features/analytics/data/mappers/analytics_mapper.dart';

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

  group('AnalyticsDao', () {
    AnalyticsSnapshot makeSnapshot({
      String? id,
      String? firmId,
      String? period,
      double? totalRevenue,
      int? totalClients,
      int? filingCompleted,
      int? filingPending,
      double? avgResponseTime,
      String? topModule,
    }) {
      counter++;
      return AnalyticsSnapshot(
        id: id ?? 'snap-$counter',
        firmId: firmId ?? 'firm-1',
        period: period ?? '2026-0$counter',
        totalRevenue: totalRevenue ?? 100000.0 * counter,
        totalClients: totalClients ?? counter * 10,
        filingCompleted: filingCompleted ?? counter * 5,
        filingPending: filingPending ?? counter * 2,
        avgResponseTime: avgResponseTime ?? 3.5,
        topModule: topModule ?? 'gst',
        createdAt: DateTime(2026, counter % 12 + 1, 1),
      );
    }

    ClientMetric makeMetric({
      String? id,
      String? clientId,
      String? period,
      double? revenue,
      int? filingsCompleted,
      double? outstandingAmount,
      double? satisfactionScore,
    }) {
      counter++;
      return ClientMetric(
        id: id ?? 'metric-$counter',
        clientId: clientId ?? 'client-$counter',
        period: period ?? '2026-03',
        revenue: revenue ?? 15000.0 * counter,
        filingsCompleted: filingsCompleted ?? counter,
        outstandingAmount: outstandingAmount ?? 5000.0,
        satisfactionScore: satisfactionScore,
        createdAt: DateTime(2026, 3, counter),
      );
    }

    group('insertSnapshot', () {
      test('inserts snapshot successfully', () async {
        final snap = makeSnapshot();
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snap),
        );
        final result = await database.analyticsDao.getLatest(snap.firmId);
        expect(result, isNotNull);
      });

      test('stored snapshot has correct period', () async {
        final snap = makeSnapshot(period: '2026-03');
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snap),
        );
        final results = await database.analyticsDao.getByPeriod(
          snap.firmId,
          '2026-03',
        );
        expect(results.any((r) => r.id == snap.id), isTrue);
      });

      test('stored snapshot has correct totalRevenue', () async {
        final snap = makeSnapshot(totalRevenue: 987654.0);
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snap),
        );
        final results = await database.analyticsDao.getByPeriod(
          snap.firmId,
          snap.period,
        );
        final row = results.firstWhere((r) => r.id == snap.id);
        expect(row.totalRevenue, 987654.0);
      });

      test('stored snapshot has correct totalClients', () async {
        final snap = makeSnapshot(totalClients: 150);
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snap),
        );
        final results = await database.analyticsDao.getByPeriod(
          snap.firmId,
          snap.period,
        );
        final row = results.firstWhere((r) => r.id == snap.id);
        expect(row.totalClients, 150);
      });

      test('stored snapshot preserves topModule', () async {
        final snap = makeSnapshot(topModule: 'itr');
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snap),
        );
        final result = (await database.analyticsDao.getByPeriod(
          snap.firmId,
          snap.period,
        )).firstWhere((r) => r.id == snap.id);
        expect(result.topModule, 'itr');
      });
    });

    group('getByPeriod', () {
      test('returns snapshots for matching firmId and period', () async {
        const firmId = 'firm-period-test';
        const period = '2026-01';
        final snap = makeSnapshot(firmId: firmId, period: period);
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snap),
        );
        final results = await database.analyticsDao.getByPeriod(firmId, period);
        expect(results.length, greaterThanOrEqualTo(1));
      });

      test('returns empty list for unknown period', () async {
        final results = await database.analyticsDao.getByPeriod(
          'firm-1',
          'unknown-period',
        );
        expect(results, isEmpty);
      });

      test('filters by firmId correctly', () async {
        const firmA = 'firm-filter-a';
        const firmB = 'firm-filter-b';
        const period = '2026-02';
        final snapA = makeSnapshot(firmId: firmA, period: period);
        final snapB = makeSnapshot(firmId: firmB, period: period);
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snapA),
        );
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(snapB),
        );
        final results = await database.analyticsDao.getByPeriod(firmA, period);
        expect(results.every((r) => r.firmId == firmA), isTrue);
      });
    });

    group('getLatest', () {
      test('returns most recently created snapshot', () async {
        const firmId = 'firm-latest-test';
        final older = AnalyticsSnapshot(
          id: 'older-snap',
          firmId: firmId,
          period: '2026-01',
          totalRevenue: 50000,
          totalClients: 10,
          filingCompleted: 5,
          filingPending: 2,
          avgResponseTime: 3.0,
          createdAt: DateTime(2026, 1, 1),
        );
        final newer = AnalyticsSnapshot(
          id: 'newer-snap',
          firmId: firmId,
          period: '2026-03',
          totalRevenue: 80000,
          totalClients: 15,
          filingCompleted: 8,
          filingPending: 3,
          avgResponseTime: 2.5,
          createdAt: DateTime(2026, 3, 1),
        );
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(older),
        );
        await database.analyticsDao.insertSnapshot(
          AnalyticsMapper.snapshotToCompanion(newer),
        );
        final result = await database.analyticsDao.getLatest(firmId);
        expect(result?.id, 'newer-snap');
      });

      test('returns null for unknown firmId', () async {
        final result = await database.analyticsDao.getLatest('non-existent');
        expect(result, isNull);
      });
    });

    group('insertClientMetric', () {
      test('inserts metric and is retrievable by clientId', () async {
        final metric = makeMetric(clientId: 'client-insert-test');
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(metric),
        );
        final results = await database.analyticsDao.getClientMetrics(
          'client-insert-test',
        );
        expect(results.any((r) => r.id == metric.id), isTrue);
      });

      test('stored metric has correct revenue', () async {
        final metric = makeMetric(revenue: 42500.0);
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(metric),
        );
        final results = await database.analyticsDao.getClientMetrics(
          metric.clientId,
        );
        final row = results.firstWhere((r) => r.id == metric.id);
        expect(row.revenue, 42500.0);
      });

      test('stored metric handles null satisfactionScore', () async {
        final metric = makeMetric(satisfactionScore: null);
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(metric),
        );
        final results = await database.analyticsDao.getClientMetrics(
          metric.clientId,
        );
        final row = results.firstWhere((r) => r.id == metric.id);
        final domain = AnalyticsMapper.metricFromRow(row);
        expect(domain.satisfactionScore, isNull);
      });

      test('stored metric has correct filingsCompleted', () async {
        final metric = makeMetric(filingsCompleted: 12);
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(metric),
        );
        final results = await database.analyticsDao.getClientMetrics(
          metric.clientId,
        );
        final row = results.firstWhere((r) => r.id == metric.id);
        expect(row.filingsCompleted, 12);
      });
    });

    group('getClientMetrics', () {
      test('returns metrics for specific client', () async {
        const clientId = 'client-metrics-q1';
        final m1 = makeMetric(clientId: clientId, period: '2026-01');
        final m2 = makeMetric(clientId: clientId, period: '2026-02');
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(m1),
        );
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(m2),
        );
        final results = await database.analyticsDao.getClientMetrics(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for unknown client', () async {
        final results = await database.analyticsDao.getClientMetrics(
          'no-such-client',
        );
        expect(results, isEmpty);
      });

      test('filters metrics by clientId correctly', () async {
        const clientA = 'client-metric-a';
        const clientB = 'client-metric-b';
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(makeMetric(clientId: clientA)),
        );
        await database.analyticsDao.insertClientMetric(
          AnalyticsMapper.metricToCompanion(makeMetric(clientId: clientB)),
        );
        final results = await database.analyticsDao.getClientMetrics(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getRevenueByPeriod', () {
      test(
        'returns metrics for matching period ordered by revenue desc',
        () async {
          const period = '2026-rev-period';
          final low = makeMetric(period: period, revenue: 5000);
          final high = makeMetric(period: period, revenue: 50000);
          await database.analyticsDao.insertClientMetric(
            AnalyticsMapper.metricToCompanion(low),
          );
          await database.analyticsDao.insertClientMetric(
            AnalyticsMapper.metricToCompanion(high),
          );
          final results = await database.analyticsDao.getRevenueByPeriod(
            period,
          );
          expect(results.length, greaterThanOrEqualTo(2));
          final revenues = results.map((r) => r.revenue).toList();
          for (var i = 0; i < revenues.length - 1; i++) {
            expect(revenues[i], greaterThanOrEqualTo(revenues[i + 1]));
          }
        },
      );

      test('returns empty for unknown period', () async {
        final results = await database.analyticsDao.getRevenueByPeriod(
          'unknown-period-x',
        );
        expect(results, isEmpty);
      });
    });

    group('Immutability', () {
      test('AnalyticsSnapshot copyWith returns new instance', () {
        final s1 = makeSnapshot(totalRevenue: 100000);
        final s2 = s1.copyWith(totalRevenue: 200000);
        expect(s1.totalRevenue, 100000);
        expect(s2.totalRevenue, 200000);
        expect(s1.id, s2.id);
      });

      test('copyWith preserves unchanged fields', () {
        final s1 = makeSnapshot(
          firmId: 'firm-x',
          period: '2026-03',
          topModule: 'tds',
        );
        final s2 = s1.copyWith(totalClients: 999);
        expect(s2.firmId, 'firm-x');
        expect(s2.period, '2026-03');
        expect(s2.topModule, 'tds');
      });

      test('ClientMetric copyWith returns new instance', () {
        final m1 = makeMetric(revenue: 10000);
        final m2 = m1.copyWith(revenue: 20000);
        expect(m1.revenue, 10000);
        expect(m2.revenue, 20000);
        expect(m1.id, m2.id);
      });

      test('ClientMetric copyWith preserves unchanged fields', () {
        final m1 = makeMetric(clientId: 'cl-x', period: '2026-02');
        final m2 = m1.copyWith(filingsCompleted: 7);
        expect(m2.clientId, 'cl-x');
        expect(m2.period, '2026-02');
        expect(m2.filingsCompleted, 7);
      });
    });
  });
}
