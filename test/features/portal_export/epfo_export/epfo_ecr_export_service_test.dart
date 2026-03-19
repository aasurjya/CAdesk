import 'package:ca_app/features/payroll/domain/models/esi_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';
import 'package:ca_app/features/payroll/domain/models/pf_contribution.dart';
import 'package:ca_app/features/portal_export/epfo_export/models/ecr_export_result.dart';
import 'package:ca_app/features/portal_export/epfo_export/services/epfo_ecr_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _validEstablishmentId = '1001234';

PfContribution _buildPf({int wagePaise = 1500000}) => PfContribution(
  pfWagePaise: wagePaise,
  employeeSharePaise: (wagePaise * 0.12).round(),
  employerEpsPaise: (wagePaise * 0.0833).round(),
  employerEpfPaise: (wagePaise * 0.0367).round(),
  adminChargesPaise: (wagePaise * 0.005).round(),
);

EsiContribution _buildEsi({int wagePaise = 1500000}) => EsiContribution(
  esiWagePaise: wagePaise,
  employeeContributionPaise: (wagePaise * 0.0075).round(),
  employerContributionPaise: (wagePaise * 0.0325).round(),
  isApplicable: wagePaise <= EsiContribution.wageCeilingPaise,
);

PayrollRun _buildPayrollRun({
  String runId = 'run-001',
  String employeeId = 'EMP001',
  String employeeName = 'Rahul Sharma',
  String uan = '100123456789',
  int grossPayPaise = 5000000, // ₹50,000
}) {
  return PayrollRun(
    runId: runId,
    month: 3,
    year: 2024,
    employeeId: employeeId,
    employeeName: employeeName,
    uan: uan,
    grossPayPaise: grossPayPaise,
    lopDeductionPaise: 0,
    grossAfterLopPaise: grossPayPaise,
    deductionsPaise: 300000,
    netPayPaise: grossPayPaise - 300000,
    tdsDeductedPaise: 50000,
    pfContribution: _buildPf(),
    esiContribution: _buildEsi(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EpfoEcrExportService', () {
    // ── Feature flag ─────────────────────────────────────────────────────────

    group('featureFlag', () {
      test('has non-empty static featureFlag constant', () {
        expect(EpfoEcrExportService.featureFlag, isNotEmpty);
        expect(EpfoEcrExportService.featureFlag, 'epfo_ecr_export_enabled');
      });
    });

    // ── validate ─────────────────────────────────────────────────────────────

    group('validate', () {
      test('returns empty errors for valid input', () {
        final runs = [_buildPayrollRun()];
        final errors = EpfoEcrExportService.validate(
          runs,
          _validEstablishmentId,
          3,
          2024,
        );
        expect(errors, isEmpty);
      });

      test('returns error for establishment ID with only 6 digits', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun()],
          '100123',
          3,
          2024,
        );
        expect(errors, isNotEmpty);
        expect(errors.first, contains('Establishment ID'));
      });

      test('returns error for establishment ID with 8 digits', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun()],
          '10012345',
          3,
          2024,
        );
        expect(errors, isNotEmpty);
        expect(errors.first, contains('Establishment ID'));
      });

      test('returns error for establishment ID with letters', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun()],
          'ABC1234',
          3,
          2024,
        );
        expect(errors, isNotEmpty);
      });

      test('returns error for month = 0', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun()],
          _validEstablishmentId,
          0,
          2024,
        );
        expect(errors, isNotEmpty);
        expect(errors.first, contains('wage month'));
      });

      test('returns error for month = 13', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun()],
          _validEstablishmentId,
          13,
          2024,
        );
        expect(errors, isNotEmpty);
        expect(errors.first, contains('wage month'));
      });

      test('returns error for year before 2012', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun()],
          _validEstablishmentId,
          3,
          2011,
        );
        expect(errors, isNotEmpty);
        expect(errors.first, contains('2012'));
      });

      test('accepts boundary month values 1 and 12', () {
        expect(
          EpfoEcrExportService.validate(
            [_buildPayrollRun()],
            _validEstablishmentId,
            1,
            2024,
          ),
          isEmpty,
        );
        expect(
          EpfoEcrExportService.validate(
            [_buildPayrollRun()],
            _validEstablishmentId,
            12,
            2024,
          ),
          isEmpty,
        );
      });

      test('accepts boundary year 2012', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun()],
          _validEstablishmentId,
          3,
          2012,
        );
        expect(errors, isEmpty);
      });

      test('returns error for employee UAN with 11 digits', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun(uan: '10012345678')],
          _validEstablishmentId,
          3,
          2024,
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('UAN')), isTrue);
      });

      test('returns error for employee UAN with 13 digits', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun(uan: '1001234567890')],
          _validEstablishmentId,
          3,
          2024,
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('UAN')), isTrue);
      });

      test('returns error for employee UAN with letters', () {
        final errors = EpfoEcrExportService.validate(
          [_buildPayrollRun(uan: 'AAAAAAAAAA12')],
          _validEstablishmentId,
          3,
          2024,
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('UAN')), isTrue);
      });

      test('collects errors for multiple invalid employees', () {
        final errors = EpfoEcrExportService.validate(
          [
            _buildPayrollRun(runId: 'r1', uan: 'BAD1'),
            _buildPayrollRun(runId: 'r2', uan: 'BAD2'),
          ],
          _validEstablishmentId,
          3,
          2024,
        );
        expect(errors.length, greaterThanOrEqualTo(2));
      });
    });

    // ── generateEcr — valid data ──────────────────────────────────────────────

    group('generateEcr — valid data', () {
      late List<PayrollRun> runs;
      late EcrExportResult result;

      setUp(() {
        runs = [
          _buildPayrollRun(
            runId: 'run-001',
            employeeId: 'EMP001',
            employeeName: 'Rahul Sharma',
            uan: '100123456789',
          ),
          _buildPayrollRun(
            runId: 'run-002',
            employeeId: 'EMP002',
            employeeName: 'Priya Singh',
            uan: '100987654321',
          ),
        ];
        result = EpfoEcrExportService.generateEcr(
          runs,
          _validEstablishmentId,
          3,
          2024,
        );
      });

      test('result is valid', () {
        expect(result.isValid, isTrue);
      });

      test('result has no validation errors', () {
        expect(result.validationErrors, isEmpty);
      });

      test('result establishmentId matches input', () {
        expect(result.establishmentId, _validEstablishmentId);
      });

      test('result month and year match input', () {
        expect(result.month, 3);
        expect(result.year, 2024);
      });

      test('result has non-empty file content', () {
        expect(result.fileContent, isNotEmpty);
      });

      test('result memberCount equals number of payroll runs', () {
        expect(result.memberCount, 2);
      });

      test('result has non-empty fileName', () {
        expect(result.fileName, isNotEmpty);
      });

      test('fileContent contains first employee name', () {
        expect(result.fileContent, contains('Rahul Sharma'));
      });

      test('fileContent contains second employee name', () {
        expect(result.fileContent, contains('Priya Singh'));
      });

      test('fileContent contains establishment ID', () {
        expect(result.fileContent, contains(_validEstablishmentId));
      });

      test('totalWages is sum of gross wages across all runs', () {
        final expectedTotal = runs.fold(0, (sum, r) => sum + r.grossPayPaise);
        expect(result.totalWages, expectedTotal);
      });
    });

    // ── generateEcr — single employee ────────────────────────────────────────

    group('generateEcr — single employee', () {
      test('memberCount is 1 for single run', () {
        final result = EpfoEcrExportService.generateEcr(
          [_buildPayrollRun()],
          _validEstablishmentId,
          1,
          2024,
        );
        expect(result.memberCount, 1);
        expect(result.isValid, isTrue);
      });
    });

    // ── generateEcr — invalid establishment ID ────────────────────────────────

    group('generateEcr — invalid establishment ID', () {
      test('result is invalid for 6-digit establishment ID', () {
        final result = EpfoEcrExportService.generateEcr(
          [_buildPayrollRun()],
          '100123',
          3,
          2024,
        );
        expect(result.isValid, isFalse);
        expect(result.validationErrors, isNotEmpty);
      });
    });

    // ── generateEcr — invalid month ───────────────────────────────────────────

    group('generateEcr — invalid month', () {
      test('result is invalid for month 0', () {
        final result = EpfoEcrExportService.generateEcr(
          [_buildPayrollRun()],
          _validEstablishmentId,
          0,
          2024,
        );
        expect(result.isValid, isFalse);
      });
    });

    // ── generateEcr — invalid UAN ────────────────────────────────────────────

    group('generateEcr — invalid UAN', () {
      test('result is invalid for employee with bad UAN', () {
        final result = EpfoEcrExportService.generateEcr(
          [_buildPayrollRun(uan: 'NOTAUAN')],
          _validEstablishmentId,
          3,
          2024,
        );
        expect(result.isValid, isFalse);
        expect(result.validationErrors.any((e) => e.contains('UAN')), isTrue);
      });
    });
  });
}
