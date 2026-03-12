import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/services/fvu_generation_service.dart';

void main() {
  group('FvuGenerationService', () {
    const batchHeader = FvuBatchHeader(
      tan: 'MUMA12345B',
      pan: 'ABCDE1234F',
      deductorName: 'Test Corporation',
      financialYear: '2025-26',
      quarter: TdsQuarter.q1,
      formType: TdsFormType.form26Q,
      preparationDate: '15032026',
      totalChallans: 1,
      totalDeductees: 2,
      totalTaxDeducted: 20000.00,
    );

    const challan = FvuChallanRecord(
      bsrCode: '0002390',
      challanTenderDate: '07032026',
      challanSerialNumber: '0000000234',
      totalTaxDeposited: 20000.00,
      deducteeCount: 2,
      sectionCode: '194C',
    );

    const deductee1 = FvuDeducteeRecord(
      pan: 'ABCDE1234F',
      deducteeName: 'Vendor One Company',
      amountPaid: 100000.00,
      tdsAmount: 10000.00,
      dateOfPayment: '01032026',
      sectionCode: '194C',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

    const deductee2 = FvuDeducteeRecord(
      pan: 'XYZAB5678G',
      deducteeName: 'Vendor Two',
      amountPaid: 100000.00,
      tdsAmount: 10000.00,
      dateOfPayment: '05032026',
      sectionCode: '194C',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

    const structure = FvuFileStructure(
      batchHeader: batchHeader,
      challans: [
        FvuChallanWithDeductees(
          challan: challan,
          deductees: [deductee1, deductee2],
        ),
      ],
    );

    test('generate returns non-empty string', () {
      final result = FvuGenerationService.generate(structure);
      expect(result, isNotEmpty);
    });

    test('generated file starts with BH record', () {
      final result = FvuGenerationService.generate(structure);
      final lines = result.split('\n');
      expect(lines.first.substring(0, 2), 'BH');
    });

    test('generated file ends with BT record', () {
      final result = FvuGenerationService.generate(structure);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      expect(lines.last.substring(0, 2), 'BT');
    });

    test('generated file contains CD records for each challan', () {
      final result = FvuGenerationService.generate(structure);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      final cdLines = lines.where((l) => l.startsWith('CD')).toList();
      expect(cdLines.length, 1);
    });

    test('generated file contains DD records for each deductee', () {
      final result = FvuGenerationService.generate(structure);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      final ddLines = lines.where((l) => l.startsWith('DD')).toList();
      expect(ddLines.length, 2);
    });

    test('BH record contains TAN at correct position', () {
      final result = FvuGenerationService.generate(structure);
      final bhLine = result.split('\n').first;
      // TAN at positions 3-12 (0-indexed: 2-11)
      expect(bhLine.substring(2, 12).trim(), 'MUMA12345B');
    });

    test('BH record contains PAN at correct position', () {
      final result = FvuGenerationService.generate(structure);
      final bhLine = result.split('\n').first;
      // PAN at positions 13-22 (0-indexed: 12-21)
      expect(bhLine.substring(12, 22).trim(), 'ABCDE1234F');
    });

    test('BH record contains deductor name at correct position', () {
      final result = FvuGenerationService.generate(structure);
      final bhLine = result.split('\n').first;
      // Name at positions 23-62 (0-indexed: 22-61, 40 chars)
      expect(bhLine.substring(22, 62).trim(), 'Test Corporation');
    });

    test('CD record starts with CD at correct position', () {
      final result = FvuGenerationService.generate(structure);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      final cdLine = lines.firstWhere((l) => l.startsWith('CD'));
      // BSR at positions 3-10 (0-indexed: 2-9)
      expect(cdLine.substring(2, 9).trim(), '0002390');
    });

    test('DD record starts with DD and contains PAN', () {
      final result = FvuGenerationService.generate(structure);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      final ddLine = lines.firstWhere((l) => l.startsWith('DD'));
      // PAN at positions 3-12 (0-indexed: 2-11)
      expect(ddLine.substring(2, 12).trim(), 'ABCDE1234F');
    });

    test('PANNOTAVBL deductee appears correctly in DD record', () {
      const noPanDeductee = FvuDeducteeRecord(
        pan: 'PANNOTAVBL',
        deducteeName: 'Unknown Person',
        amountPaid: 5000.00,
        tdsAmount: 1000.00,
        dateOfPayment: '01032026',
        sectionCode: '194C',
        deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
      );
      const noPanStructure = FvuFileStructure(
        batchHeader: batchHeader,
        challans: [
          FvuChallanWithDeductees(challan: challan, deductees: [noPanDeductee]),
        ],
      );
      final result = FvuGenerationService.generate(noPanStructure);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      final ddLine = lines.firstWhere((l) => l.startsWith('DD'));
      expect(ddLine.substring(2, 12), 'PANNOTAVBL');
    });

    test('amount formatting pads with zeros to 15 digits', () {
      final formatted = FvuGenerationService.formatAmount(25000.50);
      expect(formatted.length, 15);
      expect(formatted, '000000002500050');
    });

    test('formatAmount for zero value', () {
      final formatted = FvuGenerationService.formatAmount(0.0);
      expect(formatted, '000000000000000');
    });

    test('formatAmount for large value', () {
      final formatted = FvuGenerationService.formatAmount(1234567.89);
      expect(formatted.length, 15);
    });

    test('padRight pads string to given width', () {
      final padded = FvuGenerationService.padRight('ABC', 10);
      expect(padded.length, 10);
      expect(padded.startsWith('ABC'), isTrue);
    });

    test('padLeft pads string with zeros to given width', () {
      final padded = FvuGenerationService.padLeft('123', 10);
      expect(padded.length, 10);
      expect(padded, '0000000123');
    });
  });
}
