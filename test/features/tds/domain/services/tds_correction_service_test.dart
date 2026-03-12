import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/services/tds_correction_service.dart';

void main() {
  group('TdsCorrectionService', () {
    group('CorrectionType', () {
      test('C1 is for deductor information', () {
        expect(CorrectionType.c1.label, isNotEmpty);
        expect(CorrectionType.c1.description, contains('deductor'));
      });

      test('C2 is for challan details', () {
        expect(CorrectionType.c2.label, isNotEmpty);
        expect(CorrectionType.c2.description, contains('challan'));
      });

      test('C3 is for deductee details', () {
        expect(CorrectionType.c3.label, isNotEmpty);
        expect(CorrectionType.c3.description, contains('deductee'));
      });

      test('C5 is for PAN update', () {
        expect(CorrectionType.c5.label, isNotEmpty);
        expect(CorrectionType.c5.description, contains('PAN'));
      });

      test('C9 is for addition of challan/deductee rows', () {
        expect(CorrectionType.c9.label, isNotEmpty);
        expect(CorrectionType.c9.description, contains('add'));
      });
    });

    group('TdsCorrectionStatement', () {
      const statement = TdsCorrectionStatement(
        id: 'corr-001',
        originalReturnId: 'return-001',
        correctionType: CorrectionType.c3,
        financialYear: '2025-26',
        quarter: 1,
        tan: 'MUMA12345B',
        changedFields: {'deducteePan': 'ABCDE1234F', 'tdsDeducted': '10000.0'},
        createdAt: null,
      );

      test('creates immutable instance with correct values', () {
        expect(statement.id, 'corr-001');
        expect(statement.originalReturnId, 'return-001');
        expect(statement.correctionType, CorrectionType.c3);
        expect(statement.financialYear, '2025-26');
        expect(statement.quarter, 1);
        expect(statement.changedFields['deducteePan'], 'ABCDE1234F');
      });

      test('copyWith creates new instance with updated fields', () {
        final updated = statement.copyWith(correctionType: CorrectionType.c5);
        expect(updated.correctionType, CorrectionType.c5);
        expect(updated.id, statement.id);
      });

      test('equality is value-based', () {
        const same = TdsCorrectionStatement(
          id: 'corr-001',
          originalReturnId: 'return-001',
          correctionType: CorrectionType.c3,
          financialYear: '2025-26',
          quarter: 1,
          tan: 'MUMA12345B',
          changedFields: {
            'deducteePan': 'ABCDE1234F',
            'tdsDeducted': '10000.0',
          },
          createdAt: null,
        );
        expect(statement, equals(same));
        expect(statement.hashCode, equals(same.hashCode));
      });

      test('inequality when fields differ', () {
        final different = statement.copyWith(id: 'corr-999');
        expect(statement, isNot(equals(different)));
      });

      test('toString includes key fields', () {
        final str = statement.toString();
        expect(str, contains('corr-001'));
        expect(str, contains('C3'));
      });
    });

    group('createCorrection', () {
      test('creates C1 correction for deductor info change', () {
        final correction = TdsCorrectionService.createCorrection(
          originalReturnId: 'return-001',
          correctionType: CorrectionType.c1,
          financialYear: '2025-26',
          quarter: 1,
          tan: 'MUMA12345B',
          changedFields: {'deductorName': 'New Corp Name'},
        );
        expect(correction.correctionType, CorrectionType.c1);
        expect(correction.originalReturnId, 'return-001');
        expect(correction.changedFields['deductorName'], 'New Corp Name');
        expect(correction.id, isNotEmpty);
      });

      test('creates C5 correction for PAN update', () {
        final correction = TdsCorrectionService.createCorrection(
          originalReturnId: 'return-002',
          correctionType: CorrectionType.c5,
          financialYear: '2025-26',
          quarter: 2,
          tan: 'MUMA12345B',
          changedFields: {'oldPan': 'WRONGPAN1A', 'newPan': 'ABCDE1234F'},
        );
        expect(correction.correctionType, CorrectionType.c5);
        expect(correction.changedFields['newPan'], 'ABCDE1234F');
      });
    });

    group('validate correction', () {
      test('valid C3 correction passes validation', () {
        final correction = TdsCorrectionService.createCorrection(
          originalReturnId: 'return-001',
          correctionType: CorrectionType.c3,
          financialYear: '2025-26',
          quarter: 1,
          tan: 'MUMA12345B',
          changedFields: {'tdsDeducted': '12000.0'},
        );
        final errors = TdsCorrectionService.validate(correction);
        expect(errors, isEmpty);
      });

      test('empty changedFields returns error', () {
        final correction = TdsCorrectionService.createCorrection(
          originalReturnId: 'return-001',
          correctionType: CorrectionType.c3,
          financialYear: '2025-26',
          quarter: 1,
          tan: 'MUMA12345B',
          changedFields: {},
        );
        final errors = TdsCorrectionService.validate(correction);
        expect(errors, isNotEmpty);
      });

      test('invalid quarter returns error', () {
        final correction = TdsCorrectionService.createCorrection(
          originalReturnId: 'return-001',
          correctionType: CorrectionType.c3,
          financialYear: '2025-26',
          quarter: 5, // invalid
          tan: 'MUMA12345B',
          changedFields: {'field': 'value'},
        );
        final errors = TdsCorrectionService.validate(correction);
        expect(errors, isNotEmpty);
      });

      test('invalid TAN returns error', () {
        final correction = TdsCorrectionService.createCorrection(
          originalReturnId: 'return-001',
          correctionType: CorrectionType.c1,
          financialYear: '2025-26',
          quarter: 1,
          tan: 'BADTAN',
          changedFields: {'deductorName': 'New Name'},
        );
        final errors = TdsCorrectionService.validate(correction);
        expect(errors, isNotEmpty);
      });
    });
  });
}
