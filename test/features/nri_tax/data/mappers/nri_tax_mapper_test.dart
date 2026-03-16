import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/nri_tax/data/mappers/nri_tax_mapper.dart';
import 'package:ca_app/features/nri_tax/domain/models/nri_tax_record.dart';

void main() {
  group('NriTaxMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'nri-001',
          'client_id': 'client-001',
          'assessment_year': '2025-26',
          'residency_status': 'nonResident',
          'foreign_income_sources': 'Employment in USA, dividends from UK',
          'dtaa_country': 'USA',
          'dtaa_relief': 45000.0,
          'schedule_fa': true,
          'schedule_fsl': false,
          'status': 'filed',
          'created_at': '2025-08-01T00:00:00.000Z',
          'updated_at': '2025-09-01T00:00:00.000Z',
        };

        final record = NriTaxMapper.fromJson(json);

        expect(record.id, 'nri-001');
        expect(record.clientId, 'client-001');
        expect(record.assessmentYear, '2025-26');
        expect(record.residencyStatus, ResidencyStatus.nonResident);
        expect(
          record.foreignIncomeSources,
          'Employment in USA, dividends from UK',
        );
        expect(record.dtaaCountry, 'USA');
        expect(record.dtaaRelief, 45000.0);
        expect(record.scheduleFA, true);
        expect(record.scheduleFSL, false);
        expect(record.status, NriTaxStatus.filed);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'nri-002',
          'client_id': 'client-002',
          'assessment_year': '2025-26',
          'residency_status': 'rnor',
          'schedule_fa': false,
          'schedule_fsl': false,
          'status': 'draft',
          'created_at': '2025-07-01T00:00:00.000Z',
          'updated_at': '2025-07-01T00:00:00.000Z',
        };

        final record = NriTaxMapper.fromJson(json);
        expect(record.foreignIncomeSources, isNull);
        expect(record.dtaaCountry, isNull);
        expect(record.dtaaRelief, isNull);
        expect(record.residencyStatus, ResidencyStatus.rnor);
        expect(record.status, NriTaxStatus.draft);
      });

      test('defaults residency_status to resident for unknown value', () {
        final json = {
          'id': 'nri-003',
          'client_id': 'c1',
          'assessment_year': '2025-26',
          'residency_status': 'unknownStatus',
          'schedule_fa': false,
          'schedule_fsl': false,
          'status': 'draft',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };

        final record = NriTaxMapper.fromJson(json);
        expect(record.residencyStatus, ResidencyStatus.resident);
      });

      test('handles integer dtaa_relief as double', () {
        final json = {
          'id': 'nri-004',
          'client_id': 'c1',
          'assessment_year': '2025-26',
          'residency_status': 'nonResident',
          'dtaa_relief': 30000,
          'schedule_fa': false,
          'schedule_fsl': true,
          'status': 'inProgress',
          'created_at': '2025-05-01T00:00:00.000Z',
          'updated_at': '2025-06-01T00:00:00.000Z',
        };

        final record = NriTaxMapper.fromJson(json);
        expect(record.dtaaRelief, 30000.0);
        expect(record.dtaaRelief, isA<double>());
      });

      test('handles all ResidencyStatus values', () {
        for (final status in ResidencyStatus.values) {
          final json = {
            'id': 'nri-res-${status.name}',
            'client_id': 'c1',
            'assessment_year': '2025-26',
            'residency_status': status.name,
            'schedule_fa': false,
            'schedule_fsl': false,
            'status': 'draft',
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          };
          final record = NriTaxMapper.fromJson(json);
          expect(record.residencyStatus, status);
        }
      });

      test('handles all NriTaxStatus values', () {
        for (final taxStatus in NriTaxStatus.values) {
          final json = {
            'id': 'nri-status-${taxStatus.name}',
            'client_id': 'c1',
            'assessment_year': '2025-26',
            'residency_status': 'resident',
            'schedule_fa': false,
            'schedule_fsl': false,
            'status': taxStatus.name,
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          };
          final record = NriTaxMapper.fromJson(json);
          expect(record.status, taxStatus);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final record = NriTaxRecord(
          id: 'nri-json-001',
          clientId: 'client-json-001',
          assessmentYear: '2025-26',
          residencyStatus: ResidencyStatus.nonResident,
          foreignIncomeSources: 'Salary from Singapore',
          dtaaCountry: 'Singapore',
          dtaaRelief: 60000.0,
          scheduleFA: true,
          scheduleFSL: true,
          status: NriTaxStatus.inProgress,
          createdAt: DateTime.utc(2025, 4, 1),
          updatedAt: DateTime.utc(2025, 9, 1),
        );

        final json = NriTaxMapper.toJson(record);

        expect(json['id'], 'nri-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['assessment_year'], '2025-26');
        expect(json['residency_status'], 'nonResident');
        expect(json['foreign_income_sources'], 'Salary from Singapore');
        expect(json['dtaa_country'], 'Singapore');
        expect(json['dtaa_relief'], 60000.0);
        expect(json['schedule_fa'], true);
        expect(json['schedule_fsl'], true);
        expect(json['status'], 'inProgress');

        final restored = NriTaxMapper.fromJson(json);
        expect(restored.id, record.id);
        expect(restored.residencyStatus, record.residencyStatus);
        expect(restored.dtaaRelief, record.dtaaRelief);
        expect(restored.status, record.status);
      });

      test('serializes null optional fields as null', () {
        final record = NriTaxRecord(
          id: 'nri-null',
          clientId: 'c1',
          assessmentYear: '2024-25',
          residencyStatus: ResidencyStatus.resident,
          scheduleFA: false,
          scheduleFSL: false,
          status: NriTaxStatus.draft,
          createdAt: DateTime.utc(2024, 4, 1),
          updatedAt: DateTime.utc(2024, 4, 1),
        );

        final json = NriTaxMapper.toJson(record);
        expect(json['foreign_income_sources'], isNull);
        expect(json['dtaa_country'], isNull);
        expect(json['dtaa_relief'], isNull);
      });
    });
  });
}
