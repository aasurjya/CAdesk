import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/data/mappers/filing_record_mapper.dart';
import 'package:ca_app/features/filing/domain/models/filing_record.dart';

void main() {
  group('FilingRecordMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'filing-001',
          'client_id': 'client-001',
          'filing_type': 'itr1',
          'financial_year': '2024-25',
          'status': 'filed',
          'filed_date': '2025-07-15T00:00:00.000Z',
          'acknowledgement_number': 'ACK202425001',
          'remarks': 'Filed before deadline',
          'created_at': '2025-04-01T00:00:00.000Z',
          'updated_at': '2025-07-15T00:00:00.000Z',
        };

        final record = FilingRecordMapper.fromJson(json);

        expect(record.id, 'filing-001');
        expect(record.clientId, 'client-001');
        expect(record.filingType, FilingType.itr1);
        expect(record.financialYear, '2024-25');
        expect(record.status, FilingStatus.filed);
        expect(record.filedDate, isNotNull);
        expect(record.acknowledgementNumber, 'ACK202425001');
        expect(record.remarks, 'Filed before deadline');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'filing-002',
          'client_id': 'client-002',
          'filing_type': 'gstr1',
          'financial_year': '2024-25',
          'status': 'pending',
          'created_at': '2025-04-01T00:00:00.000Z',
          'updated_at': '2025-04-01T00:00:00.000Z',
        };

        final record = FilingRecordMapper.fromJson(json);
        expect(record.filedDate, isNull);
        expect(record.acknowledgementNumber, isNull);
        expect(record.remarks, isNull);
      });

      test('defaults filing_type to itr1 for unknown value', () {
        final json = {
          'id': 'filing-003',
          'client_id': 'c1',
          'filing_type': 'unknownType',
          'financial_year': '2024-25',
          'status': 'pending',
          'created_at': '2025-04-01T00:00:00.000Z',
          'updated_at': '2025-04-01T00:00:00.000Z',
        };

        final record = FilingRecordMapper.fromJson(json);
        expect(record.filingType, FilingType.itr1);
      });

      test('defaults status to pending for unknown value', () {
        final json = {
          'id': 'filing-004',
          'client_id': 'c1',
          'filing_type': 'itr2',
          'financial_year': '2024-25',
          'status': 'unknownStatus',
          'created_at': '2025-04-01T00:00:00.000Z',
          'updated_at': '2025-04-01T00:00:00.000Z',
        };

        final record = FilingRecordMapper.fromJson(json);
        expect(record.status, FilingStatus.pending);
      });

      test('handles all FilingType values', () {
        for (final type in FilingType.values) {
          final json = {
            'id': 'filing-type-${type.name}',
            'client_id': 'c1',
            'filing_type': type.name,
            'financial_year': '2024-25',
            'status': 'pending',
            'created_at': '2025-04-01T00:00:00.000Z',
            'updated_at': '2025-04-01T00:00:00.000Z',
          };
          final record = FilingRecordMapper.fromJson(json);
          expect(record.filingType, type);
        }
      });

      test('handles all FilingStatus values', () {
        for (final status in FilingStatus.values) {
          final json = {
            'id': 'filing-status-${status.name}',
            'client_id': 'c1',
            'filing_type': 'itr1',
            'financial_year': '2024-25',
            'status': status.name,
            'created_at': '2025-04-01T00:00:00.000Z',
            'updated_at': '2025-04-01T00:00:00.000Z',
          };
          final record = FilingRecordMapper.fromJson(json);
          expect(record.status, status);
        }
      });

      test('parses GST filing type correctly', () {
        final json = {
          'id': 'filing-005',
          'client_id': 'c1',
          'filing_type': 'gstr3b',
          'financial_year': '2024-25',
          'status': 'filed',
          'created_at': '2025-04-01T00:00:00.000Z',
          'updated_at': '2025-04-01T00:00:00.000Z',
        };

        final record = FilingRecordMapper.fromJson(json);
        expect(record.filingType, FilingType.gstr3b);
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late FilingRecord sampleRecord;

      setUp(() {
        sampleRecord = FilingRecord(
          id: 'filing-json-001',
          clientId: 'client-json-001',
          filingType: FilingType.itr2,
          financialYear: '2024-25',
          status: FilingStatus.verified,
          filedDate: DateTime(2025, 7, 20),
          acknowledgementNumber: 'ACK202425002',
          remarks: 'Verified by IT dept',
          createdAt: DateTime(2025, 4, 1),
          updatedAt: DateTime(2025, 7, 20),
        );
      });

      test('includes all non-internal fields', () {
        final json = FilingRecordMapper.toJson(sampleRecord);

        expect(json['id'], 'filing-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['filing_type'], 'itr2');
        expect(json['financial_year'], '2024-25');
        expect(json['status'], 'verified');
        expect(json['acknowledgement_number'], 'ACK202425002');
        expect(json['remarks'], 'Verified by IT dept');
      });

      test('serializes filed_date as ISO string', () {
        final json = FilingRecordMapper.toJson(sampleRecord);
        expect(json['filed_date'], startsWith('2025-07-20'));
      });

      test('serializes null filed_date as null', () {
        final pendingRecord = FilingRecord(
          id: 'filing-pending',
          clientId: 'c1',
          filingType: FilingType.itr1,
          financialYear: '2024-25',
          status: FilingStatus.pending,
          createdAt: DateTime(2025, 4, 1),
          updatedAt: DateTime(2025, 4, 1),
        );
        final json = FilingRecordMapper.toJson(pendingRecord);
        expect(json['filed_date'], isNull);
        expect(json['acknowledgement_number'], isNull);
        expect(json['remarks'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all serializable fields', () {
        final json = FilingRecordMapper.toJson(sampleRecord);
        // Add created_at/updated_at for fromJson
        json['created_at'] = sampleRecord.createdAt.toIso8601String();
        json['updated_at'] = sampleRecord.updatedAt.toIso8601String();

        final restored = FilingRecordMapper.fromJson(json);

        expect(restored.id, sampleRecord.id);
        expect(restored.clientId, sampleRecord.clientId);
        expect(restored.filingType, sampleRecord.filingType);
        expect(restored.financialYear, sampleRecord.financialYear);
        expect(restored.status, sampleRecord.status);
        expect(
          restored.acknowledgementNumber,
          sampleRecord.acknowledgementNumber,
        );
        expect(restored.remarks, sampleRecord.remarks);
      });

      test('serializes TDS form types correctly', () {
        final tdsRecord = sampleRecord.copyWith(
          id: 'filing-tds',
          filingType: FilingType.tds26q,
        );
        final json = FilingRecordMapper.toJson(tdsRecord);
        expect(json['filing_type'], 'tds26q');
      });
    });
  });
}
