import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/compliance/data/mappers/compliance_mapper.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';

void main() {
  group('ComplianceMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'ce-001',
          'client_id': 'client-001',
          'type': 'itr',
          'description': 'ITR-1 filing for AY 2025-26',
          'due_date': '2025-07-31T00:00:00.000Z',
          'filed_date': '2025-07-28T00:00:00.000Z',
          'status': 'filed',
          'penalty': null,
        };

        final event = ComplianceMapper.fromJson(json);

        expect(event.id, 'ce-001');
        expect(event.clientId, 'client-001');
        expect(event.type, ComplianceEventType.itr);
        expect(event.description, 'ITR-1 filing for AY 2025-26');
        expect(event.status, ComplianceEventStatus.filed);
        expect(event.filedDate, isNotNull);
        expect(event.penalty, isNull);
      });

      test('handles null filed_date', () {
        final json = {
          'id': 'ce-002',
          'client_id': 'client-002',
          'type': 'gst',
          'description': 'GSTR-3B for April 2025',
          'due_date': '2025-05-20T00:00:00.000Z',
          'filed_date': null,
          'status': 'pending',
          'penalty': null,
        };

        final event = ComplianceMapper.fromJson(json);
        expect(event.filedDate, isNull);
        expect(event.status, ComplianceEventStatus.pending);
      });

      test('handles non-null penalty value', () {
        final json = {
          'id': 'ce-003',
          'client_id': 'client-003',
          'type': 'tds',
          'description': 'TDS Q1 return',
          'due_date': '2025-07-31T00:00:00.000Z',
          'status': 'overdue',
          'penalty': 5000.0,
        };

        final event = ComplianceMapper.fromJson(json);
        expect(event.penalty, 5000.0);
        expect(event.status, ComplianceEventStatus.overdue);
      });

      test('defaults type to other for unknown value', () {
        final json = {
          'id': 'ce-004',
          'client_id': 'c1',
          'type': 'unknownType',
          'description': 'Unknown compliance',
          'due_date': '2025-12-31T00:00:00.000Z',
          'status': 'pending',
        };

        final event = ComplianceMapper.fromJson(json);
        expect(event.type, ComplianceEventType.other);
      });

      test('defaults status to pending for unknown value', () {
        final json = {
          'id': 'ce-005',
          'client_id': 'c1',
          'type': 'audit',
          'description': 'Audit compliance',
          'due_date': '2025-09-30T00:00:00.000Z',
          'status': 'unknownStatus',
        };

        final event = ComplianceMapper.fromJson(json);
        expect(event.status, ComplianceEventStatus.pending);
      });

      test('handles all ComplianceEventType values', () {
        for (final type in ComplianceEventType.values) {
          final json = {
            'id': 'ce-type-${type.name}',
            'client_id': 'c1',
            'type': type.name,
            'description': 'Compliance event',
            'due_date': '2025-12-31T00:00:00.000Z',
            'status': 'pending',
          };
          final event = ComplianceMapper.fromJson(json);
          expect(event.type, type);
        }
      });

      test('handles all ComplianceEventStatus values', () {
        for (final status in ComplianceEventStatus.values) {
          final json = {
            'id': 'ce-status-${status.name}',
            'client_id': 'c1',
            'type': 'itr',
            'description': 'Compliance event',
            'due_date': '2025-12-31T00:00:00.000Z',
            'status': status.name,
          };
          final event = ComplianceMapper.fromJson(json);
          expect(event.status, status);
        }
      });

      test('handles integer penalty via num coercion', () {
        final json = {
          'id': 'ce-006',
          'client_id': 'c1',
          'type': 'mca',
          'description': 'MCA filing penalty',
          'due_date': '2025-12-31T00:00:00.000Z',
          'status': 'overdue',
          'penalty': 10000,
        };

        final event = ComplianceMapper.fromJson(json);
        expect(event.penalty, 10000.0);
        expect(event.penalty, isA<double>());
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late ComplianceEvent sampleEvent;

      setUp(() {
        sampleEvent = ComplianceEvent(
          id: 'ce-json-001',
          clientId: 'client-json-001',
          type: ComplianceEventType.gst,
          description: 'GSTR-9 annual return FY 2024-25',
          dueDate: DateTime(2025, 12, 31),
          filedDate: DateTime(2025, 12, 28),
          status: ComplianceEventStatus.completed,
          penalty: null,
        );
      });

      test('includes all fields', () {
        final json = ComplianceMapper.toJson(sampleEvent);

        expect(json['id'], 'ce-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['type'], 'gst');
        expect(json['description'], 'GSTR-9 annual return FY 2024-25');
        expect(json['status'], 'completed');
        expect(json['penalty'], isNull);
      });

      test('serializes due_date and filed_date as ISO strings', () {
        final json = ComplianceMapper.toJson(sampleEvent);
        expect(json['due_date'], startsWith('2025-12-31'));
        expect(json['filed_date'], startsWith('2025-12-28'));
      });

      test('serializes null filed_date as null', () {
        final pendingEvent = ComplianceEvent(
          id: 'ce-pending',
          clientId: 'c1',
          type: ComplianceEventType.tds,
          description: 'TDS Q3 return',
          dueDate: DateTime(2026, 1, 31),
          status: ComplianceEventStatus.pending,
        );
        final json = ComplianceMapper.toJson(pendingEvent);
        expect(json['filed_date'], isNull);
      });

      test('serializes penalty when present', () {
        final penaltyEvent = sampleEvent.copyWith(
          id: 'ce-penalty',
          penalty: 25000.0,
          status: ComplianceEventStatus.overdue,
        );
        final json = ComplianceMapper.toJson(penaltyEvent);
        expect(json['penalty'], 25000.0);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = ComplianceMapper.toJson(sampleEvent);
        final restored = ComplianceMapper.fromJson(json);

        expect(restored.id, sampleEvent.id);
        expect(restored.clientId, sampleEvent.clientId);
        expect(restored.type, sampleEvent.type);
        expect(restored.description, sampleEvent.description);
        expect(restored.status, sampleEvent.status);
        expect(restored.penalty, sampleEvent.penalty);
      });

      test('handles empty description', () {
        final emptyDesc = sampleEvent.copyWith(description: '');
        final json = ComplianceMapper.toJson(emptyDesc);
        expect(json['description'], '');
      });
    });
  });
}
