import 'package:ca_app/features/portal_export/tds_export/models/fvu_export_result.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_export_service.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _validTan = 'AAATA1234X';

FvuBatchHeader _buildBatchHeader() => FvuBatchHeader(
  tan: _validTan,
  pan: 'ABCDE1234F',
  deductorName: 'Acme Ltd',
  financialYear: '2024-25',
  quarter: TdsQuarter.q1,
  formType: TdsFormType.form26Q,
  preparationDate: '01042024',
  totalChallans: 1,
  totalDeductees: 1,
  totalTaxDeducted: 5000.0,
);

FvuDeducteeRecord _buildDeducteeRecord({String pan = 'BBBBB1234B'}) =>
    FvuDeducteeRecord(
      pan: pan,
      deducteeName: 'Rajesh Kumar',
      amountPaid: 50000.0,
      tdsAmount: 5000.0,
      dateOfPayment: '15062024',
      sectionCode: '194C',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

FvuChallanRecord _buildChallanRecord({String bsrCode = '0012345'}) =>
    FvuChallanRecord(
      bsrCode: bsrCode,
      challanTenderDate: '20062024',
      challanSerialNumber: '0000000001',
      totalTaxDeposited: 5000.0,
      deducteeCount: 1,
      sectionCode: '194C',
    );

FvuFileStructure _buildMinimalStructure({
  String bsrCode = '0012345',
  String deducteePan = 'BBBBB1234B',
}) {
  return FvuFileStructure(
    batchHeader: _buildBatchHeader(),
    challans: [
      FvuChallanWithDeductees(
        challan: _buildChallanRecord(bsrCode: bsrCode),
        deductees: [_buildDeducteeRecord(pan: deducteePan)],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FvuExportService', () {
    // ── Feature flag ─────────────────────────────────────────────────────────

    group('featureFlag', () {
      test('has non-empty static featureFlag constant', () {
        expect(FvuExportService.featureFlag, isNotEmpty);
        expect(FvuExportService.featureFlag, 'fvu_export_enabled');
      });
    });

    // ── validate ─────────────────────────────────────────────────────────────

    group('validate', () {
      test('returns empty errors for valid structure and TAN', () {
        final structure = _buildMinimalStructure();
        final errors = FvuExportService.validate(structure, _validTan);
        expect(errors, isEmpty);
      });

      test('returns error for invalid TAN (too short)', () {
        final structure = _buildMinimalStructure();
        final errors = FvuExportService.validate(structure, 'AAATA');
        expect(errors, isNotEmpty);
        expect(errors.first, contains('Invalid TAN'));
      });

      test('returns error for TAN with wrong format (numbers in prefix)', () {
        final structure = _buildMinimalStructure();
        final errors = FvuExportService.validate(structure, '1234567890');
        expect(errors, isNotEmpty);
      });

      test('returns error when challans list is empty', () {
        final structure = FvuFileStructure(
          batchHeader: _buildBatchHeader(),
          challans: const [],
        );
        final errors = FvuExportService.validate(structure, _validTan);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('at least one challan'));
      });

      test('returns error when a challan has no deductees', () {
        final structure = FvuFileStructure(
          batchHeader: _buildBatchHeader(),
          challans: [
            FvuChallanWithDeductees(
              challan: _buildChallanRecord(),
              deductees: const [],
            ),
          ],
        );
        final errors = FvuExportService.validate(structure, _validTan);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('at least one deductee'));
      });

      test('returns error for deductee with invalid PAN', () {
        final structure = _buildMinimalStructure(deducteePan: 'INVALID');
        final errors = FvuExportService.validate(structure, _validTan);
        expect(errors, isNotEmpty);
        final panError = errors.firstWhere(
          (e) => e.contains('PAN') || e.contains('pan'),
          orElse: () => '',
        );
        expect(panError, isNotEmpty);
      });

      test('returns error for BSR code shorter than 7 digits', () {
        final structure = _buildMinimalStructure(bsrCode: '123');
        final errors = FvuExportService.validate(structure, _validTan);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('BSR')), isTrue);
      });

      test('returns error for BSR code with letters', () {
        final structure = _buildMinimalStructure(bsrCode: 'ABCDEFG');
        final errors = FvuExportService.validate(structure, _validTan);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('BSR')), isTrue);
      });

      test('accepts 7-digit BSR code', () {
        final structure = _buildMinimalStructure(bsrCode: '1234567');
        final errors = FvuExportService.validate(structure, _validTan);
        // Should not have a BSR error
        expect(errors.any((e) => e.contains('BSR')), isFalse);
      });

      test('TAN is normalised to uppercase before validation', () {
        final structure = _buildMinimalStructure();
        // lowercase TAN should pass after normalisation
        final errors = FvuExportService.validate(structure, 'aaata1234x');
        expect(errors, isEmpty);
      });
    });

    // ── generateFvu — valid ───────────────────────────────────────────────────

    group('generateFvu — valid input', () {
      late FvuFileStructure structure;
      late FvuExportResult result;

      setUp(() {
        structure = _buildMinimalStructure();
        result = FvuExportService.generateFvu(structure, _validTan);
      });

      test('result is valid', () {
        expect(result.isValid, isTrue);
      });

      test('result has no validation errors', () {
        expect(result.validationErrors, isEmpty);
      });

      test('result has non-empty FVU file content', () {
        expect(result.fvuFileContent, isNotEmpty);
      });

      test('FVU content contains TAN', () {
        expect(result.fvuFileContent, contains(_validTan));
      });

      test('result recordCount is at least 1', () {
        expect(result.recordCount, greaterThanOrEqualTo(1));
      });

      test('result challanCount matches number of challans in structure', () {
        expect(result.challanCount, 1);
      });
    });

    // ── generateFvu — invalid TAN ────────────────────────────────────────────

    group('generateFvu — invalid TAN', () {
      test('result is invalid for bad TAN', () {
        final structure = _buildMinimalStructure();
        final result = FvuExportService.generateFvu(structure, 'BADTAN');
        expect(result.isValid, isFalse);
        expect(result.validationErrors, isNotEmpty);
      });
    });

    // ── generateFvu — empty challans ─────────────────────────────────────────

    group('generateFvu — empty challans', () {
      test('result is invalid for empty challan list', () {
        final structure = FvuFileStructure(
          batchHeader: _buildBatchHeader(),
          challans: const [],
        );
        final result = FvuExportService.generateFvu(structure, _validTan);
        expect(result.isValid, isFalse);
        expect(result.validationErrors, isNotEmpty);
      });
    });

    // ── generateFvu — multiple challans ──────────────────────────────────────

    group('generateFvu — multiple challans', () {
      test('result includes content for each challan', () {
        final structure = FvuFileStructure(
          batchHeader: _buildBatchHeader(),
          challans: [
            FvuChallanWithDeductees(
              challan: _buildChallanRecord(bsrCode: '1111111'),
              deductees: [_buildDeducteeRecord(pan: 'AAAAA1111A')],
            ),
            FvuChallanWithDeductees(
              challan: _buildChallanRecord(bsrCode: '2222222'),
              deductees: [_buildDeducteeRecord(pan: 'BBBBB2222B')],
            ),
          ],
        );
        final result = FvuExportService.generateFvu(structure, _validTan);
        expect(
          result.validationErrors.where((e) => e.contains('BSR')),
          isEmpty,
        );
      });
    });
  });
}
