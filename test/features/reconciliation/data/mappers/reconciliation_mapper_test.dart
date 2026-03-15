import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/reconciliation/data/mappers/reconciliation_mapper.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';

void main() {
  group('ReconciliationMapper', () {
    // -------------------------------------------------------------------------
    // ReconciliationResult
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'recon-001',
          'client_id': 'client-001',
          'reconciliation_type': 'tds26as',
          'period': 'Q2 FY 2025-26',
          'total_matched': 145,
          'total_unmatched': 5,
          'discrepancies': jsonEncode([
            {
              'id': 'disc-001',
              'result_id': 'recon-001',
              'field': 'tds_amount',
              'expected_value': '5000',
              'actual_value': '4800',
              'source': '26AS',
              'resolved': false,
            },
          ]),
          'status': 'inProgress',
          'reviewed_by': 'ca-001',
          'reviewed_date': '2025-09-10T00:00:00.000Z',
          'created_at': '2025-09-05T00:00:00.000Z',
          'updated_at': '2025-09-10T00:00:00.000Z',
        };

        final result = ReconciliationMapper.fromJson(json);

        expect(result.id, 'recon-001');
        expect(result.clientId, 'client-001');
        expect(result.reconciliationType, ReconciliationType.tds26as);
        expect(result.period, 'Q2 FY 2025-26');
        expect(result.totalMatched, 145);
        expect(result.totalUnmatched, 5);
        expect(result.status, ReconciliationStatus.inProgress);
        expect(result.reviewedBy, 'ca-001');
        expect(result.reviewedDate, isNotNull);
        expect(result.discrepancies.length, 1);
        expect(result.discrepancies[0].field, 'tds_amount');
      });

      test('handles empty discrepancies list', () {
        final json = {
          'id': 'recon-002',
          'client_id': 'client-002',
          'reconciliation_type': 'gstr2b',
          'period': 'Sep 2025',
          'total_matched': 200,
          'total_unmatched': 0,
          'discrepancies': jsonEncode(<dynamic>[]),
          'status': 'completed',
          'created_at': '2025-09-05T00:00:00.000Z',
          'updated_at': '2025-09-05T00:00:00.000Z',
        };

        final result = ReconciliationMapper.fromJson(json);
        expect(result.discrepancies, isEmpty);
        expect(result.reviewedBy, isNull);
        expect(result.reviewedDate, isNull);
        expect(result.reconciliationType, ReconciliationType.gstr2b);
        expect(result.status, ReconciliationStatus.completed);
      });

      test('handles null discrepancies gracefully', () {
        final json = {
          'id': 'recon-003',
          'client_id': 'c1',
          'reconciliation_type': 'bankRecon',
          'period': 'Sep 2025',
          'total_matched': 0,
          'total_unmatched': 0,
          'discrepancies': null,
          'status': 'pending',
          'created_at': '2025-09-01T00:00:00.000Z',
          'updated_at': '2025-09-01T00:00:00.000Z',
        };

        final result = ReconciliationMapper.fromJson(json);
        expect(result.discrepancies, isEmpty);
      });

      test('defaults reconciliation_type to tds26as for unknown value', () {
        final json = {
          'id': 'recon-004',
          'client_id': 'c1',
          'reconciliation_type': 'unknownType',
          'period': 'Q1 FY 2025-26',
          'total_matched': 0,
          'total_unmatched': 0,
          'discrepancies': '[]',
          'status': 'pending',
          'created_at': '2025-09-01T00:00:00.000Z',
          'updated_at': '2025-09-01T00:00:00.000Z',
        };

        final result = ReconciliationMapper.fromJson(json);
        expect(result.reconciliationType, ReconciliationType.tds26as);
      });

      test('handles all ReconciliationType values', () {
        for (final type in ReconciliationType.values) {
          final json = {
            'id': 'recon-type-${type.name}',
            'client_id': 'c1',
            'reconciliation_type': type.name,
            'period': '',
            'total_matched': 0,
            'total_unmatched': 0,
            'discrepancies': '[]',
            'status': 'pending',
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          };
          final result = ReconciliationMapper.fromJson(json);
          expect(result.reconciliationType, type);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final result = ReconciliationResult(
          id: 'recon-json-001',
          clientId: 'client-json-001',
          reconciliationType: ReconciliationType.pan3way,
          period: 'Q3 FY 2025-26',
          totalMatched: 88,
          totalUnmatched: 2,
          discrepancies: const [
            Discrepancy(
              id: 'disc-json-001',
              resultId: 'recon-json-001',
              field: 'pan_name',
              expectedValue: 'RAMESH KUMAR',
              actualValue: 'R KUMAR',
              source: 'ITD',
              resolved: false,
            ),
          ],
          status: ReconciliationStatus.reviewed,
          reviewedBy: 'ca-002',
          reviewedDate: DateTime.utc(2025, 11, 15),
          createdAt: DateTime.utc(2025, 10, 1),
          updatedAt: DateTime.utc(2025, 11, 15),
        );

        final json = ReconciliationMapper.toJson(result);

        expect(json['id'], 'recon-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['reconciliation_type'], 'pan3way');
        expect(json['period'], 'Q3 FY 2025-26');
        expect(json['total_matched'], 88);
        expect(json['status'], 'reviewed');
        expect(json['reviewed_by'], 'ca-002');

        final restoredResult = ReconciliationMapper.fromJson(json);
        expect(restoredResult.id, result.id);
        expect(restoredResult.reconciliationType, result.reconciliationType);
        expect(restoredResult.discrepancies.length, 1);
        expect(restoredResult.discrepancies[0].field, 'pan_name');
      });
    });

    // -------------------------------------------------------------------------
    // Discrepancy
    // -------------------------------------------------------------------------
    group('discrepancyFromMap', () {
      test('maps all core fields from map', () {
        final map = {
          'id': 'disc-map-001',
          'result_id': 'recon-001',
          'field': 'tds_deducted',
          'expected_value': '10000',
          'actual_value': '9500',
          'source': 'Form 16',
          'resolved': true,
        };

        final discrepancy = ReconciliationMapper.discrepancyFromMap(map);

        expect(discrepancy.id, 'disc-map-001');
        expect(discrepancy.resultId, 'recon-001');
        expect(discrepancy.field, 'tds_deducted');
        expect(discrepancy.expectedValue, '10000');
        expect(discrepancy.actualValue, '9500');
        expect(discrepancy.source, 'Form 16');
        expect(discrepancy.resolved, true);
      });

      test('defaults resolved to false when missing', () {
        final map = {
          'id': 'disc-map-002',
          'result_id': 'recon-002',
          'field': 'gst_credit',
          'expected_value': '18000',
          'actual_value': '17500',
          'source': 'GSTR-2B',
        };

        final discrepancy = ReconciliationMapper.discrepancyFromMap(map);
        expect(discrepancy.resolved, false);
      });
    });
  });
}
