import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_export/tds_export/models/fvu_export_result.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_file_generator.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

void main() {
  // Shared test fixtures
  final batchHeader = FvuBatchHeader(
    tan: 'AAATA1234X',
    pan: 'ABCDE1234F',
    deductorName: 'Test Company Ltd',
    financialYear: '2024-25',
    quarter: TdsQuarter.q1,
    formType: TdsFormType.form26Q,
    preparationDate: '01042024',
    totalChallans: 1,
    totalDeductees: 2,
    totalTaxDeducted: 1500.0,
  );

  final deductee1 = FvuDeducteeRecord(
    pan: 'ABCDE1234F',
    deducteeName: 'John Doe',
    amountPaid: 100000.0,
    tdsAmount: 1000.0,
    dateOfPayment: '01042024',
    sectionCode: '194C',
    deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
  );

  final deductee2 = FvuDeducteeRecord(
    pan: 'PANNOTAVBL',
    deducteeName: 'Jane Smith',
    amountPaid: 50000.0,
    tdsAmount: 500.0,
    dateOfPayment: '01042024',
    sectionCode: '194C',
    deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
  );

  final challan = FvuChallanRecord(
    bsrCode: '0012345',
    challanTenderDate: '10042024',
    challanSerialNumber: '0000000001',
    totalTaxDeposited: 1500.0,
    deducteeCount: 2,
    sectionCode: '194C',
  );

  final structure = FvuFileStructure(
    batchHeader: batchHeader,
    challans: [
      FvuChallanWithDeductees(
        challan: challan,
        deductees: [deductee1, deductee2],
      ),
    ],
  );

  group('FvuFileGenerator', () {
    group('generate', () {
      test('returns an FvuExportResult', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result, isA<FvuExportResult>());
      });

      test('result contains non-empty fvuFileContent', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.fvuFileContent, isNotEmpty);
      });

      test('fvuFileContent starts with BH record', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.fvuFileContent, startsWith('BH'));
      });

      test('fvuFileContent contains BT record', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.fvuFileContent, contains('BT'));
      });

      test('fvuFileContent contains CD record', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.fvuFileContent, contains('CD'));
      });

      test('fvuFileContent contains DD records', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.fvuFileContent, contains('DD'));
      });

      test('result challanCount matches structure', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.challanCount, equals(1));
      });

      test(
        'result recordCount matches total records (1 BH + 1 CD + 2 DD + 1 BT)',
        () {
          final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
          // recordCount = total deductee entries
          expect(result.recordCount, equals(2));
        },
      );

      test('result tanNumber matches provided TAN', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.tanNumber, equals('AAATA1234X'));
      });

      test('result has correct quarter', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.quarter, equals(FvuExportQuarter.q1));
      });

      test('result has correct formType', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.formType, equals(FvuExportFormType.form26Q));
      });

      test('result validationErrors is empty for valid structure', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.validationErrors, isEmpty);
      });

      test('result fileName follows naming convention', () {
        final result = FvuFileGenerator.generate(structure, 'AAATA1234X');
        expect(result.fileName, equals('TDS_26Q_Q1_2024_AAATA1234X.fvu'));
      });
    });

    group('generateFileName', () {
      test('generates correct file name for 26Q Q1', () {
        expect(
          FvuFileGenerator.generateFileName('26Q', 1, 2024, 'AAATA1234X'),
          equals('TDS_26Q_Q1_2024_AAATA1234X.fvu'),
        );
      });

      test('generates correct file name for 24Q Q4', () {
        expect(
          FvuFileGenerator.generateFileName('24Q', 4, 2023, 'MUMM12345Z'),
          equals('TDS_24Q_Q4_2023_MUMM12345Z.fvu'),
        );
      });

      test('generates correct file name for 27EQ Q2', () {
        expect(
          FvuFileGenerator.generateFileName('27EQ', 2, 2025, 'DELH98765B'),
          equals('TDS_27EQ_Q2_2025_DELH98765B.fvu'),
        );
      });

      test('converts TAN to uppercase in file name', () {
        expect(
          FvuFileGenerator.generateFileName('26Q', 1, 2024, 'aaata1234x'),
          equals('TDS_26Q_Q1_2024_AAATA1234X.fvu'),
        );
      });
    });
  });

  group('FvuExportResult', () {
    final sampleResult = FvuExportResult(
      formType: FvuExportFormType.form26Q,
      quarter: FvuExportQuarter.q1,
      financialYear: 2024,
      tanNumber: 'AAATA1234X',
      fvuFileContent: 'BH|...\nBT|...',
      fileName: 'TDS_26Q_Q1_2024_AAATA1234X.fvu',
      recordCount: 2,
      challanCount: 1,
      validationErrors: const [],
    );

    test('equality: two identical results are equal', () {
      final other = FvuExportResult(
        formType: FvuExportFormType.form26Q,
        quarter: FvuExportQuarter.q1,
        financialYear: 2024,
        tanNumber: 'AAATA1234X',
        fvuFileContent: 'BH|...\nBT|...',
        fileName: 'TDS_26Q_Q1_2024_AAATA1234X.fvu',
        recordCount: 2,
        challanCount: 1,
        validationErrors: const [],
      );
      expect(sampleResult, equals(other));
    });

    test('equality: results with different TAN are not equal', () {
      final other = sampleResult.copyWith(tanNumber: 'MUMM12345Z');
      expect(sampleResult, isNot(equals(other)));
    });

    test('hashCode is consistent', () {
      expect(sampleResult.hashCode, equals(sampleResult.hashCode));
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = sampleResult.copyWith(recordCount: 5);
      expect(updated.recordCount, equals(5));
      expect(updated.tanNumber, equals(sampleResult.tanNumber));
    });

    test('isValid returns true when validationErrors is empty', () {
      expect(sampleResult.isValid, isTrue);
    });

    test('isValid returns false when validationErrors is non-empty', () {
      final invalid = sampleResult.copyWith(
        validationErrors: ['BH record missing'],
      );
      expect(invalid.isValid, isFalse);
    });

    test('toString does not throw', () {
      expect(() => sampleResult.toString(), returnsNormally);
    });
  });
}
