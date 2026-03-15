import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/msme/data/mappers/msme_mapper.dart';
import 'package:ca_app/features/msme/domain/models/msme_record.dart';

void main() {
  group('MsmeMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'msme-001',
          'client_id': 'client-001',
          'udyam_number': 'UDYAM-MH-01-0012345',
          'registration_date': '2022-06-15T00:00:00.000Z',
          'category': 'small',
          'annual_turnover': '2500000',
          'employee_count': 35,
          'status': 'active',
        };

        final record = MsmeMapper.fromJson(json);

        expect(record.id, 'msme-001');
        expect(record.clientId, 'client-001');
        expect(record.udyamNumber, 'UDYAM-MH-01-0012345');
        expect(record.registrationDate.year, 2022);
        expect(record.category, MsmeCategory.small);
        expect(record.annualTurnover, '2500000');
        expect(record.employeeCount, 35);
        expect(record.status, 'active');
      });

      test('handles null annualTurnover and employeeCount', () {
        final json = {
          'id': 'msme-002',
          'client_id': 'client-002',
          'udyam_number': 'UDYAM-DL-02-0099999',
          'registration_date': '2023-01-01T00:00:00.000Z',
          'category': 'micro',
          'status': 'active',
        };

        final record = MsmeMapper.fromJson(json);
        expect(record.annualTurnover, isNull);
        expect(record.employeeCount, isNull);
        expect(record.category, MsmeCategory.micro);
      });

      test('defaults category to micro for unknown value', () {
        final json = {
          'id': 'msme-003',
          'client_id': 'c1',
          'udyam_number': 'UDYAM-XX-00-0000001',
          'registration_date': '2023-06-01T00:00:00.000Z',
          'category': 'unknownCategory',
          'status': 'active',
        };

        final record = MsmeMapper.fromJson(json);
        expect(record.category, MsmeCategory.micro);
      });

      test('defaults status to active when missing', () {
        final json = {
          'id': 'msme-004',
          'client_id': 'c1',
          'udyam_number': 'UDYAM-KA-03-0000002',
          'registration_date': '2021-04-01T00:00:00.000Z',
          'category': 'medium',
        };

        final record = MsmeMapper.fromJson(json);
        expect(record.status, 'active');
      });

      test('handles all MsmeCategory values', () {
        for (final cat in MsmeCategory.values) {
          final json = {
            'id': 'msme-cat-${cat.name}',
            'client_id': 'c1',
            'udyam_number': 'UDYAM-TN-04-000000${cat.index}',
            'registration_date': '2022-01-01T00:00:00.000Z',
            'category': cat.name,
            'status': 'active',
          };
          final record = MsmeMapper.fromJson(json);
          expect(record.category, cat);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final record = MsmeRecord(
          id: 'msme-json-001',
          clientId: 'client-json-001',
          udyamNumber: 'UDYAM-GJ-05-0007777',
          registrationDate: DateTime.utc(2020, 3, 15),
          category: MsmeCategory.medium,
          annualTurnover: '50000000',
          employeeCount: 120,
          status: 'active',
        );

        final json = MsmeMapper.toJson(record);

        expect(json['id'], 'msme-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['udyam_number'], 'UDYAM-GJ-05-0007777');
        expect(json['category'], 'medium');
        expect(json['annual_turnover'], '50000000');
        expect(json['employee_count'], 120);
        expect(json['status'], 'active');

        final restored = MsmeMapper.fromJson(json);
        expect(restored.id, record.id);
        expect(restored.udyamNumber, record.udyamNumber);
        expect(restored.category, record.category);
        expect(restored.annualTurnover, record.annualTurnover);
      });

      test('serializes null fields as null', () {
        final record = MsmeRecord(
          id: 'msme-null',
          clientId: 'c1',
          udyamNumber: '',
          registrationDate: DateTime.utc(2024, 1, 1),
          category: MsmeCategory.micro,
          status: 'suspended',
        );

        final json = MsmeMapper.toJson(record);
        expect(json['annual_turnover'], isNull);
        expect(json['employee_count'], isNull);
      });
    });
  });
}
