import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/income_tax/data/mappers/itr_filing_mapper.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';

void main() {
  group('ItrFilingMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'itr-001',
          'name': 'Rajesh Kumar Sharma',
          'pan': 'ABCRS1234A',
          'email': 'rajesh@example.com',
          'phone': '+91-9876543210',
          'itr_type': 'itr1',
          'assessment_year': 'AY 2025-26',
          'filing_status': 'filed',
          'total_income': 850000.0,
          'tax_payable': 45000.0,
          'refund_due': 0.0,
          'filed_date': '2025-07-15T00:00:00.000Z',
          'acknowledgement_number': 'ACK202526001',
        };

        final client = ItrFilingMapper.fromJson(json);

        expect(client.id, 'itr-001');
        expect(client.name, 'Rajesh Kumar Sharma');
        expect(client.pan, 'ABCRS1234A');
        expect(client.email, 'rajesh@example.com');
        expect(client.phone, '+91-9876543210');
        expect(client.itrType, ItrType.itr1);
        expect(client.assessmentYear, 'AY 2025-26');
        expect(client.filingStatus, FilingStatus.filed);
        expect(client.totalIncome, 850000.0);
        expect(client.taxPayable, 45000.0);
        expect(client.refundDue, 0.0);
        expect(client.filedDate, isNotNull);
        expect(client.acknowledgementNumber, 'ACK202526001');
      });

      test('aadhaar is always empty string from remote JSON (DPDP)', () {
        final json = {
          'id': 'itr-002',
          'name': 'Test Client',
          'pan': 'XXXXX1234X',
          'itr_type': 'itr1',
          'assessment_year': 'AY 2025-26',
          'filing_status': 'pending',
          'total_income': 0.0,
          'tax_payable': 0.0,
          'refund_due': 0.0,
        };

        final client = ItrFilingMapper.fromJson(json);
        expect(client.aadhaar, '');
      });

      test('defaults itr_type to itr1 for unknown value', () {
        final json = {
          'id': 'itr-003',
          'name': 'Test',
          'pan': 'XXXXX1234X',
          'itr_type': 'unknownType',
          'assessment_year': 'AY 2025-26',
          'filing_status': 'pending',
          'total_income': 0.0,
          'tax_payable': 0.0,
          'refund_due': 0.0,
        };

        final client = ItrFilingMapper.fromJson(json);
        expect(client.itrType, ItrType.itr1);
      });

      test('defaults filing_status to pending for unknown value', () {
        final json = {
          'id': 'itr-004',
          'name': 'Test',
          'pan': 'XXXXX1234X',
          'itr_type': 'itr2',
          'assessment_year': 'AY 2025-26',
          'filing_status': 'unknownStatus',
          'total_income': 0.0,
          'tax_payable': 0.0,
          'refund_due': 0.0,
        };

        final client = ItrFilingMapper.fromJson(json);
        expect(client.filingStatus, FilingStatus.pending);
      });

      test('handles null optional fields with defaults', () {
        final json = {
          'id': 'itr-005',
          'name': 'Minimal Client',
          'pan': 'MINML1234M',
          'assessment_year': 'AY 2025-26',
        };

        final client = ItrFilingMapper.fromJson(json);
        expect(client.email, '');
        expect(client.phone, '');
        expect(client.filedDate, isNull);
        expect(client.acknowledgementNumber, isNull);
        expect(client.totalIncome, 0.0);
        expect(client.taxPayable, 0.0);
        expect(client.refundDue, 0.0);
      });

      test('handles all ItrType values', () {
        for (final type in ItrType.values) {
          final json = {
            'id': 'itr-type-${type.name}',
            'name': 'Test',
            'pan': 'XXXXX1234X',
            'itr_type': type.name,
            'assessment_year': 'AY 2025-26',
            'filing_status': 'pending',
            'total_income': 0.0,
            'tax_payable': 0.0,
            'refund_due': 0.0,
          };
          final client = ItrFilingMapper.fromJson(json);
          expect(client.itrType, type);
        }
      });

      test('handles all FilingStatus values', () {
        for (final status in FilingStatus.values) {
          final json = {
            'id': 'itr-status-${status.name}',
            'name': 'Test',
            'pan': 'XXXXX1234X',
            'itr_type': 'itr1',
            'assessment_year': 'AY 2025-26',
            'filing_status': status.name,
            'total_income': 0.0,
            'tax_payable': 0.0,
            'refund_due': 0.0,
          };
          final client = ItrFilingMapper.fromJson(json);
          expect(client.filingStatus, status);
        }
      });

      test('parses refund_due correctly for refund case', () {
        final json = {
          'id': 'itr-006',
          'name': 'Refund Client',
          'pan': 'REFND1234R',
          'itr_type': 'itr1',
          'assessment_year': 'AY 2025-26',
          'filing_status': 'verified',
          'total_income': 500000.0,
          'tax_payable': 0.0,
          'refund_due': 15000.0,
        };

        final client = ItrFilingMapper.fromJson(json);
        expect(client.refundDue, 15000.0);
        expect(client.taxPayable, 0.0);
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late ItrClient sampleClient;

      setUp(() {
        sampleClient = ItrClient(
          id: 'itr-json-001',
          name: 'Priya Nair',
          pan: 'CNPPN5678P',
          aadhaar: '',
          email: 'priya@example.com',
          phone: '+91-9123456789',
          itrType: ItrType.itr2,
          assessmentYear: 'AY 2025-26',
          filingStatus: FilingStatus.filed,
          totalIncome: 1200000.0,
          taxPayable: 125000.0,
          refundDue: 0.0,
          filedDate: DateTime(2025, 7, 20),
          acknowledgementNumber: 'ACK202526002',
        );
      });

      test('includes all core fields', () {
        final json = ItrFilingMapper.toJson(sampleClient);

        expect(json['id'], 'itr-json-001');
        expect(json['name'], 'Priya Nair');
        expect(json['pan'], 'CNPPN5678P');
        expect(json['email'], 'priya@example.com');
        expect(json['phone'], '+91-9123456789');
        expect(json['itr_type'], 'itr2');
        expect(json['assessment_year'], 'AY 2025-26');
        expect(json['filing_status'], 'filed');
        expect(json['total_income'], 1200000.0);
        expect(json['tax_payable'], 125000.0);
        expect(json['refund_due'], 0.0);
        expect(json['acknowledgement_number'], 'ACK202526002');
      });

      test('does NOT include aadhaar in JSON output (DPDP)', () {
        final json = ItrFilingMapper.toJson(sampleClient);
        expect(json.containsKey('aadhaar'), isFalse);
      });

      test('serializes filed_date as ISO string', () {
        final json = ItrFilingMapper.toJson(sampleClient);
        expect(json['filed_date'], startsWith('2025-07-20'));
      });

      test('serializes null filed_date as null', () {
        // Need a hack since copyWith can't clear non-nullable with null -
        // create a new object directly
        const noDateClient = ItrClient(
          id: 'itr-nodate',
          name: 'Test',
          pan: 'XXXXX1234X',
          aadhaar: '',
          email: '',
          phone: '',
          itrType: ItrType.itr1,
          assessmentYear: 'AY 2025-26',
          filingStatus: FilingStatus.pending,
          totalIncome: 0.0,
          taxPayable: 0.0,
          refundDue: 0.0,
        );
        final json = ItrFilingMapper.toJson(noDateClient);
        expect(json['filed_date'], isNull);
        expect(json['acknowledgement_number'], isNull);
      });

      test('round-trip fromJson(toJson) preserves core fields', () {
        final json = ItrFilingMapper.toJson(sampleClient);
        final restored = ItrFilingMapper.fromJson(json);

        expect(restored.id, sampleClient.id);
        expect(restored.name, sampleClient.name);
        expect(restored.pan, sampleClient.pan);
        expect(restored.itrType, sampleClient.itrType);
        expect(restored.filingStatus, sampleClient.filingStatus);
        expect(restored.totalIncome, sampleClient.totalIncome);
        expect(restored.acknowledgementNumber,
            sampleClient.acknowledgementNumber);
      });
    });

    // -------------------------------------------------------------------------
    // _ayToFy helper (exposed via toCompanion indirectly - test via public API)
    // -------------------------------------------------------------------------
    group('ItrClient computed properties', () {
      test('maskedPan masks first 5 characters', () {
        const client = ItrClient(
          id: 'c1',
          name: 'Test',
          pan: 'ABCDE1234F',
          aadhaar: '',
          email: '',
          phone: '',
          itrType: ItrType.itr1,
          assessmentYear: 'AY 2025-26',
          filingStatus: FilingStatus.pending,
          totalIncome: 0.0,
          taxPayable: 0.0,
          refundDue: 0.0,
        );
        expect(client.maskedPan, 'XXXXX1234F');
      });

      test('initials returns first two letters for single-word name', () {
        const client = ItrClient(
          id: 'c2',
          name: 'Priya',
          pan: 'XXXXX1234X',
          aadhaar: '',
          email: '',
          phone: '',
          itrType: ItrType.itr1,
          assessmentYear: 'AY 2025-26',
          filingStatus: FilingStatus.pending,
          totalIncome: 0.0,
          taxPayable: 0.0,
          refundDue: 0.0,
        );
        expect(client.initials, 'PR');
      });
    });
  });
}
