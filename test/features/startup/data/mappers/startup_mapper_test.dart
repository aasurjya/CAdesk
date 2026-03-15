import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/startup/data/mappers/startup_mapper.dart';
import 'package:ca_app/features/startup/domain/models/startup_record.dart';

void main() {
  group('StartupMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'startup-001',
          'client_id': 'client-001',
          'dpiit_number': 'DIPP67890',
          'incorporation_date': '2021-03-15T00:00:00.000Z',
          'sector_category': 'fintech',
          'recognition_status': 'recognised',
          'section_80iac_eligible': true,
          'section_56_exempt_eligible': true,
          'notes': 'Angel tax exemption applicable',
        };

        final record = StartupMapper.fromJson(json);

        expect(record.id, 'startup-001');
        expect(record.clientId, 'client-001');
        expect(record.dpiitNumber, 'DIPP67890');
        expect(record.incorporationDate.year, 2021);
        expect(record.sectorCategory, 'fintech');
        expect(record.recognitionStatus, 'recognised');
        expect(record.section80IacEligible, true);
        expect(record.section56ExemptEligible, true);
        expect(record.notes, 'Angel tax exemption applicable');
      });

      test('handles null notes', () {
        final json = {
          'id': 'startup-002',
          'client_id': 'client-002',
          'dpiit_number': 'DIPP11111',
          'incorporation_date': '2022-06-01T00:00:00.000Z',
          'sector_category': 'healthtech',
          'recognition_status': 'pending',
          'section_80iac_eligible': false,
          'section_56_exempt_eligible': false,
        };

        final record = StartupMapper.fromJson(json);
        expect(record.notes, isNull);
        expect(record.section80IacEligible, false);
        expect(record.section56ExemptEligible, false);
        expect(record.recognitionStatus, 'pending');
      });

      test('defaults eligibility flags to false when missing', () {
        final json = {
          'id': 'startup-003',
          'client_id': 'c1',
          'dpiit_number': 'DIPP22222',
          'incorporation_date': '2023-01-01T00:00:00.000Z',
          'sector_category': '',
          'recognition_status': 'pending',
        };

        final record = StartupMapper.fromJson(json);
        expect(record.section80IacEligible, false);
        expect(record.section56ExemptEligible, false);
        expect(record.sectorCategory, '');
      });

      test('defaults recognitionStatus to pending when missing', () {
        final json = {
          'id': 'startup-004',
          'client_id': 'c1',
          'incorporation_date': '2023-06-01T00:00:00.000Z',
        };

        final record = StartupMapper.fromJson(json);
        expect(record.recognitionStatus, 'pending');
        expect(record.dpiitNumber, '');
        expect(record.sectorCategory, '');
      });

      test('handles various recognition statuses', () {
        for (final status in ['recognised', 'pending', 'rejected', 'expired']) {
          final json = {
            'id': 'startup-status-$status',
            'client_id': 'c1',
            'dpiit_number': 'DIPP33333',
            'incorporation_date': '2022-01-01T00:00:00.000Z',
            'sector_category': 'agritech',
            'recognition_status': status,
          };
          final record = StartupMapper.fromJson(json);
          expect(record.recognitionStatus, status);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final record = StartupRecord(
          id: 'startup-json-001',
          clientId: 'client-json-001',
          dpiitNumber: 'DIPP99999',
          incorporationDate: DateTime.utc(2020, 11, 10),
          sectorCategory: 'edtech',
          recognitionStatus: 'recognised',
          section80IacEligible: true,
          section56ExemptEligible: false,
          notes: 'Tax holiday from AY 2023-24',
        );

        final json = StartupMapper.toJson(record);

        expect(json['id'], 'startup-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['dpiit_number'], 'DIPP99999');
        expect(json['sector_category'], 'edtech');
        expect(json['recognition_status'], 'recognised');
        expect(json['section_80iac_eligible'], true);
        expect(json['section_56_exempt_eligible'], false);
        expect(json['notes'], 'Tax holiday from AY 2023-24');

        final restored = StartupMapper.fromJson(json);
        expect(restored.id, record.id);
        expect(restored.dpiitNumber, record.dpiitNumber);
        expect(restored.section80IacEligible, record.section80IacEligible);
        expect(restored.recognitionStatus, record.recognitionStatus);
      });

      test('serializes null notes as null', () {
        final record = StartupRecord(
          id: 'startup-null',
          clientId: 'c1',
          dpiitNumber: 'DIPP00000',
          incorporationDate: DateTime.utc(2024, 4, 1),
          sectorCategory: 'cleantech',
          recognitionStatus: 'pending',
        );

        final json = StartupMapper.toJson(record);
        expect(json['notes'], isNull);
        expect(json['section_80iac_eligible'], false);
      });

      test('serializes incorporation_date as ISO string', () {
        final record = StartupRecord(
          id: 'startup-date',
          clientId: 'c1',
          dpiitNumber: 'DIPP11111',
          incorporationDate: DateTime.utc(2021, 8, 15),
          sectorCategory: 'saas',
          recognitionStatus: 'recognised',
        );

        final json = StartupMapper.toJson(record);
        expect(json['incorporation_date'], startsWith('2021-08-15'));
      });
    });
  });
}
