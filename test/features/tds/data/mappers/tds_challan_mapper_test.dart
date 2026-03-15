import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/data/mappers/tds_challan_mapper.dart';
import 'package:ca_app/features/tds/domain/models/tds_challan.dart';

void main() {
  group('TdsChallanMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'challan-001',
          'deductor_id': 'deductor-001',
          'challan_number': 'ITNS281-2025-0234',
          'bsr_code': '0002390',
          'section': '194J',
          'deductee_count': 5,
          'tds_amount': 50000.0,
          'surcharge': 0.0,
          'education_cess': 2000.0,
          'interest': 0.0,
          'penalty': 0.0,
          'total_amount': 52000.0,
          'payment_date': '07 Apr 2025',
          'month': 4,
          'financial_year': '2025-26',
          'status': 'Paid',
        };

        final challan = TdsChallanMapper.fromJson(json);

        expect(challan.id, 'challan-001');
        expect(challan.deductorId, 'deductor-001');
        expect(challan.challanNumber, 'ITNS281-2025-0234');
        expect(challan.bsrCode, '0002390');
        expect(challan.section, '194J');
        expect(challan.deducteeCount, 5);
        expect(challan.tdsAmount, 50000.0);
        expect(challan.surcharge, 0.0);
        expect(challan.educationCess, 2000.0);
        expect(challan.interest, 0.0);
        expect(challan.penalty, 0.0);
        expect(challan.totalAmount, 52000.0);
        expect(challan.paymentDate, '07 Apr 2025');
        expect(challan.month, 4);
        expect(challan.financialYear, '2025-26');
        expect(challan.status, 'Paid');
      });

      test('defaults numeric fields to 0.0 when absent', () {
        final json = {
          'id': 'challan-002',
          'deductor_id': 'deductor-002',
          'challan_number': 'ITNS281-2025-0235',
          'bsr_code': '0001234',
          'section': '192',
          'payment_date': '05 May 2025',
          'month': 5,
          'financial_year': '2025-26',
          'status': 'Due',
        };

        final challan = TdsChallanMapper.fromJson(json);
        expect(challan.deducteeCount, 0);
        expect(challan.tdsAmount, 0.0);
        expect(challan.surcharge, 0.0);
        expect(challan.educationCess, 0.0);
        expect(challan.interest, 0.0);
        expect(challan.penalty, 0.0);
        expect(challan.totalAmount, 0.0);
      });

      test('defaults status to Due when absent', () {
        final json = {
          'id': 'challan-003',
          'deductor_id': 'deductor-003',
          'challan_number': 'ITNS281-2025-0236',
          'bsr_code': '0001234',
          'section': '194C',
          'deductee_count': 3,
          'tds_amount': 10000.0,
          'surcharge': 0.0,
          'education_cess': 400.0,
          'interest': 0.0,
          'penalty': 0.0,
          'total_amount': 10400.0,
          'payment_date': '07 May 2025',
          'month': 5,
          'financial_year': '2025-26',
        };

        final challan = TdsChallanMapper.fromJson(json);
        expect(challan.status, 'Due');
      });

      test('handles integer amounts via num coercion', () {
        final json = {
          'id': 'challan-004',
          'deductor_id': 'd1',
          'challan_number': 'ITNS281-001',
          'bsr_code': '0001234',
          'section': '194H',
          'deductee_count': 2,
          'tds_amount': 25000,
          'surcharge': 0,
          'education_cess': 1000,
          'interest': 500,
          'penalty': 0,
          'total_amount': 26500,
          'payment_date': '07 Jun 2025',
          'month': 6,
          'financial_year': '2025-26',
          'status': 'Partial',
        };

        final challan = TdsChallanMapper.fromJson(json);
        expect(challan.tdsAmount, isA<double>());
        expect(challan.tdsAmount, 25000.0);
        expect(challan.interest, 500.0);
      });

      test('section description for known section', () {
        final json = {
          'id': 'challan-005',
          'deductor_id': 'd1',
          'challan_number': 'ITNS281-002',
          'bsr_code': '0001234',
          'section': '192',
          'deductee_count': 10,
          'tds_amount': 100000.0,
          'surcharge': 0.0,
          'education_cess': 4000.0,
          'interest': 0.0,
          'penalty': 0.0,
          'total_amount': 104000.0,
          'payment_date': '07 Apr 2025',
          'month': 4,
          'financial_year': '2025-26',
          'status': 'Paid',
        };

        final challan = TdsChallanMapper.fromJson(json);
        expect(challan.sectionDescription, 'Salary');
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late TdsChallan sampleChallan;

      setUp(() {
        sampleChallan = const TdsChallan(
          id: 'challan-json-001',
          deductorId: 'deductor-json-001',
          challanNumber: 'ITNS281-2025-JSON',
          bsrCode: '0009876',
          section: '194J',
          deducteeCount: 8,
          tdsAmount: 80000.0,
          surcharge: 0.0,
          educationCess: 3200.0,
          interest: 200.0,
          penalty: 0.0,
          totalAmount: 83400.0,
          paymentDate: '15 Apr 2025',
          month: 4,
          financialYear: '2025-26',
          status: 'Paid',
        );
      });

      test('includes all fields', () {
        final json = TdsChallanMapper.toJson(sampleChallan);

        expect(json['id'], 'challan-json-001');
        expect(json['deductor_id'], 'deductor-json-001');
        expect(json['challan_number'], 'ITNS281-2025-JSON');
        expect(json['bsr_code'], '0009876');
        expect(json['section'], '194J');
        expect(json['deductee_count'], 8);
        expect(json['tds_amount'], 80000.0);
        expect(json['surcharge'], 0.0);
        expect(json['education_cess'], 3200.0);
        expect(json['interest'], 200.0);
        expect(json['penalty'], 0.0);
        expect(json['total_amount'], 83400.0);
        expect(json['payment_date'], '15 Apr 2025');
        expect(json['month'], 4);
        expect(json['financial_year'], '2025-26');
        expect(json['status'], 'Paid');
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = TdsChallanMapper.toJson(sampleChallan);
        final restored = TdsChallanMapper.fromJson(json);

        expect(restored.id, sampleChallan.id);
        expect(restored.deductorId, sampleChallan.deductorId);
        expect(restored.challanNumber, sampleChallan.challanNumber);
        expect(restored.bsrCode, sampleChallan.bsrCode);
        expect(restored.section, sampleChallan.section);
        expect(restored.deducteeCount, sampleChallan.deducteeCount);
        expect(restored.tdsAmount, sampleChallan.tdsAmount);
        expect(restored.totalAmount, sampleChallan.totalAmount);
        expect(restored.paymentDate, sampleChallan.paymentDate);
        expect(restored.month, sampleChallan.month);
        expect(restored.financialYear, sampleChallan.financialYear);
        expect(restored.status, sampleChallan.status);
      });

      test('handles zero penalty and surcharge', () {
        final json = TdsChallanMapper.toJson(sampleChallan);
        expect(json['surcharge'], 0.0);
        expect(json['penalty'], 0.0);
      });

      test('handles overdue status', () {
        final overdueChallan = sampleChallan.copyWith(status: 'Overdue');
        final json = TdsChallanMapper.toJson(overdueChallan);
        expect(json['status'], 'Overdue');
      });
    });
  });
}
