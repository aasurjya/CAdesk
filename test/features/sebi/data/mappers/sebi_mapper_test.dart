import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/sebi/data/mappers/sebi_mapper.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_compliance_data.dart';

void main() {
  group('SebiMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'sebi-001',
          'client_id': 'client-001',
          'compliance_type': 'lodr',
          'due_date': '2025-09-30T00:00:00.000Z',
          'filed_date': '2025-09-25T00:00:00.000Z',
          'status': 'filed',
          'description': 'LODR quarterly compliance - Board composition',
          'penalty': null,
        };

        final compliance = SebiMapper.fromJson(json);

        expect(compliance.id, 'sebi-001');
        expect(compliance.clientId, 'client-001');
        expect(compliance.complianceType, SebiType.lodr);
        expect(compliance.dueDate.year, 2025);
        expect(compliance.dueDate.month, 9);
        expect(compliance.filedDate, isNotNull);
        expect(compliance.status, 'filed');
        expect(
          compliance.description,
          'LODR quarterly compliance - Board composition',
        );
        expect(compliance.penalty, isNull);
      });

      test('handles null filed_date, description, and penalty', () {
        final json = {
          'id': 'sebi-002',
          'client_id': 'client-002',
          'compliance_type': 'insiderTrading',
          'due_date': '2025-10-15T00:00:00.000Z',
          'status': 'pending',
        };

        final compliance = SebiMapper.fromJson(json);
        expect(compliance.filedDate, isNull);
        expect(compliance.description, isNull);
        expect(compliance.penalty, isNull);
        expect(compliance.complianceType, SebiType.insiderTrading);
      });

      test('includes penalty when specified', () {
        final json = {
          'id': 'sebi-003',
          'client_id': 'c1',
          'compliance_type': 'sast',
          'due_date': '2025-08-31T00:00:00.000Z',
          'status': 'overdue',
          'penalty': '50000',
        };

        final compliance = SebiMapper.fromJson(json);
        expect(compliance.penalty, '50000');
        expect(compliance.status, 'overdue');
        expect(compliance.complianceType, SebiType.sast);
      });

      test('defaults compliance_type to other for unknown value', () {
        final json = {
          'id': 'sebi-004',
          'client_id': 'c1',
          'compliance_type': 'unknownType',
          'due_date': '2025-09-30T00:00:00.000Z',
          'status': 'pending',
        };

        final compliance = SebiMapper.fromJson(json);
        expect(compliance.complianceType, SebiType.other);
      });

      test('defaults status to pending when missing', () {
        final json = {
          'id': 'sebi-005',
          'client_id': 'c1',
          'compliance_type': 'pit',
          'due_date': '2025-09-30T00:00:00.000Z',
        };

        final compliance = SebiMapper.fromJson(json);
        expect(compliance.status, 'pending');
      });

      test('handles all SebiType values', () {
        for (final sebiType in SebiType.values) {
          final json = {
            'id': 'sebi-type-${sebiType.name}',
            'client_id': 'c1',
            'compliance_type': sebiType.name,
            'due_date': '2025-09-30T00:00:00.000Z',
            'status': 'pending',
          };
          final compliance = SebiMapper.fromJson(json);
          expect(compliance.complianceType, sebiType);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final compliance = SebiComplianceData(
          id: 'sebi-json-001',
          clientId: 'client-json-001',
          complianceType: SebiType.takeovers,
          dueDate: DateTime.utc(2025, 11, 30),
          filedDate: DateTime.utc(2025, 11, 20),
          status: 'filed',
          description: 'Open offer compliance under SAST regulations',
          penalty: null,
        );

        final json = SebiMapper.toJson(compliance);

        expect(json['id'], 'sebi-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['compliance_type'], 'takeovers');
        expect(json['status'], 'filed');
        expect(
          json['description'],
          'Open offer compliance under SAST regulations',
        );
        expect(json['penalty'], isNull);
        expect(json['filed_date'], isNotNull);

        final restored = SebiMapper.fromJson(json);
        expect(restored.id, compliance.id);
        expect(restored.complianceType, compliance.complianceType);
        expect(restored.status, compliance.status);
        expect(restored.description, compliance.description);
      });

      test('serializes null optional fields as null', () {
        final compliance = SebiComplianceData(
          id: 'sebi-null',
          clientId: 'c1',
          complianceType: SebiType.pit,
          dueDate: DateTime.utc(2025, 9, 30),
          status: 'pending',
        );

        final json = SebiMapper.toJson(compliance);
        expect(json['filed_date'], isNull);
        expect(json['description'], isNull);
        expect(json['penalty'], isNull);
      });
    });
  });
}
