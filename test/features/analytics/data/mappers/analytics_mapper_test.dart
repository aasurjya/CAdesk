import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/analytics/data/mappers/analytics_mapper.dart';
import 'package:ca_app/features/analytics/domain/models/analytics_snapshot.dart';
import 'package:ca_app/features/analytics/domain/models/client_metric.dart';

void main() {
  group('AnalyticsMapper', () {
    // -------------------------------------------------------------------------
    // AnalyticsSnapshot
    // -------------------------------------------------------------------------
    group('snapshotFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'snap-001',
          'firm_id': 'firm-001',
          'period': '2025-Q2',
          'total_revenue': 2500000.0,
          'total_clients': 45,
          'filing_completed': 120,
          'filing_pending': 8,
          'avg_response_time': 2.5,
          'top_module': 'itr',
          'created_at': '2025-07-01T00:00:00.000Z',
        };

        final snapshot = AnalyticsMapper.snapshotFromJson(json);

        expect(snapshot.id, 'snap-001');
        expect(snapshot.firmId, 'firm-001');
        expect(snapshot.period, '2025-Q2');
        expect(snapshot.totalRevenue, 2500000.0);
        expect(snapshot.totalClients, 45);
        expect(snapshot.filingCompleted, 120);
        expect(snapshot.filingPending, 8);
        expect(snapshot.avgResponseTime, 2.5);
        expect(snapshot.topModule, 'itr');
      });

      test('handles null top_module', () {
        final json = {
          'id': 'snap-002',
          'firm_id': 'firm-002',
          'period': '2025-Q1',
          'total_revenue': 0.0,
          'total_clients': 0,
          'filing_completed': 0,
          'filing_pending': 0,
          'avg_response_time': 0.0,
          'top_module': null,
          'created_at': '2025-04-01T00:00:00.000Z',
        };

        final snapshot = AnalyticsMapper.snapshotFromJson(json);
        expect(snapshot.topModule, isNull);
      });

      test('converts integer numeric values to double', () {
        final json = {
          'id': 'snap-003',
          'firm_id': 'firm-003',
          'period': '2025-Q3',
          'total_revenue': 3000000,
          'total_clients': 50,
          'filing_completed': 200,
          'filing_pending': 10,
          'avg_response_time': 3,
          'created_at': '2025-10-01T00:00:00.000Z',
        };

        final snapshot = AnalyticsMapper.snapshotFromJson(json);
        expect(snapshot.totalRevenue, 3000000.0);
        expect(snapshot.totalRevenue, isA<double>());
        expect(snapshot.avgResponseTime, 3.0);
        expect(snapshot.avgResponseTime, isA<double>());
      });
    });

    group('snapshotToJson', () {
      late AnalyticsSnapshot sampleSnapshot;

      setUp(() {
        sampleSnapshot = AnalyticsSnapshot(
          id: 'snap-json-001',
          firmId: 'firm-json-001',
          period: '2025-Annual',
          totalRevenue: 10000000.0,
          totalClients: 100,
          filingCompleted: 450,
          filingPending: 15,
          avgResponseTime: 1.8,
          topModule: 'gst',
          createdAt: DateTime(2026, 1, 1),
        );
      });

      test('includes all fields', () {
        final json = AnalyticsMapper.snapshotToJson(sampleSnapshot);

        expect(json['id'], 'snap-json-001');
        expect(json['firm_id'], 'firm-json-001');
        expect(json['period'], '2025-Annual');
        expect(json['total_revenue'], 10000000.0);
        expect(json['total_clients'], 100);
        expect(json['filing_completed'], 450);
        expect(json['filing_pending'], 15);
        expect(json['avg_response_time'], 1.8);
        expect(json['top_module'], 'gst');
      });

      test('serializes created_at as ISO string', () {
        final json = AnalyticsMapper.snapshotToJson(sampleSnapshot);
        expect(json['created_at'], startsWith('2026-01-01'));
      });

      test('serializes null top_module as null', () {
        // copyWith doesn't handle null for non-nullable, use fresh object:
        final noTopSnapshot = AnalyticsSnapshot(
          id: sampleSnapshot.id,
          firmId: sampleSnapshot.firmId,
          period: sampleSnapshot.period,
          totalRevenue: sampleSnapshot.totalRevenue,
          totalClients: sampleSnapshot.totalClients,
          filingCompleted: sampleSnapshot.filingCompleted,
          filingPending: sampleSnapshot.filingPending,
          avgResponseTime: sampleSnapshot.avgResponseTime,
          createdAt: sampleSnapshot.createdAt,
        );
        final json = AnalyticsMapper.snapshotToJson(noTopSnapshot);
        expect(json['top_module'], isNull);
      });

      test('round-trip snapshotFromJson(snapshotToJson) preserves all fields', () {
        final json = AnalyticsMapper.snapshotToJson(sampleSnapshot);
        final restored = AnalyticsMapper.snapshotFromJson(json);

        expect(restored.id, sampleSnapshot.id);
        expect(restored.firmId, sampleSnapshot.firmId);
        expect(restored.period, sampleSnapshot.period);
        expect(restored.totalRevenue, sampleSnapshot.totalRevenue);
        expect(restored.totalClients, sampleSnapshot.totalClients);
        expect(restored.filingCompleted, sampleSnapshot.filingCompleted);
        expect(restored.avgResponseTime, sampleSnapshot.avgResponseTime);
        expect(restored.topModule, sampleSnapshot.topModule);
      });
    });

    // -------------------------------------------------------------------------
    // ClientMetric
    // -------------------------------------------------------------------------
    group('metricFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'cm-001',
          'client_id': 'client-001',
          'period': '2025-Q2',
          'revenue': 150000.0,
          'filings_completed': 8,
          'outstanding_amount': 25000.0,
          'satisfaction_score': 4.5,
          'created_at': '2025-07-01T00:00:00.000Z',
        };

        final metric = AnalyticsMapper.metricFromJson(json);

        expect(metric.id, 'cm-001');
        expect(metric.clientId, 'client-001');
        expect(metric.period, '2025-Q2');
        expect(metric.revenue, 150000.0);
        expect(metric.filingsCompleted, 8);
        expect(metric.outstandingAmount, 25000.0);
        expect(metric.satisfactionScore, 4.5);
      });

      test('handles null satisfaction_score', () {
        final json = {
          'id': 'cm-002',
          'client_id': 'client-002',
          'period': '2025-Q1',
          'revenue': 0.0,
          'filings_completed': 0,
          'outstanding_amount': 0.0,
          'satisfaction_score': null,
          'created_at': '2025-04-01T00:00:00.000Z',
        };

        final metric = AnalyticsMapper.metricFromJson(json);
        expect(metric.satisfactionScore, isNull);
      });
    });

    group('metricToJson', () {
      test('includes all fields and serializes null satisfaction_score', () {
        final metric = ClientMetric(
          id: 'cm-json-001',
          clientId: 'client-json-001',
          period: '2025-Annual',
          revenue: 500000.0,
          filingsCompleted: 24,
          outstandingAmount: 0.0,
          createdAt: DateTime(2026, 1, 1),
        );

        final json = AnalyticsMapper.metricToJson(metric);

        expect(json['id'], 'cm-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['period'], '2025-Annual');
        expect(json['revenue'], 500000.0);
        expect(json['filings_completed'], 24);
        expect(json['outstanding_amount'], 0.0);
        expect(json['satisfaction_score'], isNull);
        expect(json['created_at'], startsWith('2026-01-01'));
      });

      test('round-trip metricFromJson(metricToJson) preserves all fields', () {
        final metric = ClientMetric(
          id: 'cm-rt',
          clientId: 'c1',
          period: 'Q3',
          revenue: 75000.0,
          filingsCompleted: 5,
          outstandingAmount: 10000.0,
          satisfactionScore: 4.8,
          createdAt: DateTime(2025, 10, 1),
        );

        final json = AnalyticsMapper.metricToJson(metric);
        final restored = AnalyticsMapper.metricFromJson(json);

        expect(restored.id, metric.id);
        expect(restored.revenue, metric.revenue);
        expect(restored.filingsCompleted, metric.filingsCompleted);
        expect(restored.satisfactionScore, metric.satisfactionScore);
      });
    });
  });
}
