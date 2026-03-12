import 'package:ca_app/features/payroll/domain/models/esi_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/pf_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';
import 'package:ca_app/features/payroll/domain/services/epfo_ecr_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpfoEcrGenerator', () {
    final sampleRun1 = PayrollRun(
      runId: 'RUN-001',
      month: 3,
      year: 2025,
      employeeId: 'EMP001',
      employeeName: 'Rahul Sharma',
      uan: '100234567890',
      grossPayPaise: 5235000,
      lopDeductionPaise: 0,
      grossAfterLopPaise: 5235000,
      deductionsPaise: 230000,
      netPayPaise: 5005000,
      tdsDeductedPaise: 50000,
      pfContribution: const PfContribution(
        pfWagePaise: 1500000,
        employeeSharePaise: 180000,
        employerEpsPaise: 124950,
        employerEpfPaise: 55050,
        adminChargesPaise: 7500,
      ),
      esiContribution: const EsiContribution(
        esiWagePaise: 0,
        employeeContributionPaise: 0,
        employerContributionPaise: 0,
        isApplicable: false,
      ),
    );

    final sampleRun2 = PayrollRun(
      runId: 'RUN-002',
      month: 3,
      year: 2025,
      employeeId: 'EMP002',
      employeeName: 'Priya Patel',
      uan: '100234567891',
      grossPayPaise: 3000000,
      lopDeductionPaise: 0,
      grossAfterLopPaise: 3000000,
      deductionsPaise: 120000,
      netPayPaise: 2880000,
      tdsDeductedPaise: 0,
      pfContribution: const PfContribution(
        pfWagePaise: 1500000,
        employeeSharePaise: 180000,
        employerEpsPaise: 124950,
        employerEpfPaise: 55050,
        adminChargesPaise: 7500,
      ),
      esiContribution: const EsiContribution(
        esiWagePaise: 0,
        employeeContributionPaise: 0,
        employerContributionPaise: 0,
        isApplicable: false,
      ),
    );

    group('generateEcr', () {
      test('generates ECR with correct header line', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [sampleRun1],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        final lines = ecr.split('\n');
        expect(lines.first, startsWith('#~#'));
        expect(lines.first, contains('MHBAN0001234000'));
        expect(lines.first, contains('03'));
        expect(lines.first, contains('2025'));
      });

      test('generates ECR with correct number of detail rows', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [sampleRun1, sampleRun2],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        final lines = ecr
            .split('\n')
            .where((l) => l.isNotEmpty && !l.startsWith('#~#'))
            .toList();
        expect(lines.length, 2);
      });

      test('detail row contains pipe-delimited UAN', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [sampleRun1],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        final lines = ecr.split('\n');
        final detailLine = lines.firstWhere(
          (l) => l.contains('100234567890'),
          orElse: () => '',
        );
        expect(detailLine, isNotEmpty);
        expect(detailLine, contains('|'));
      });

      test('detail row has UAN as first field', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [sampleRun1],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        final detailLines = ecr
            .split('\n')
            .where((l) => l.isNotEmpty && !l.startsWith('#~#'))
            .toList();
        expect(detailLines.first.split('|').first.trim(), '100234567890');
      });

      test('detail row contains employee name as second field', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [sampleRun1],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        final detailLines = ecr
            .split('\n')
            .where((l) => l.isNotEmpty && !l.startsWith('#~#'))
            .toList();
        final fields = detailLines.first.split('|');
        expect(fields[1].trim(), 'Rahul Sharma');
      });

      test('detail row contains gross wages in rupees', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [sampleRun1],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        final detailLines = ecr
            .split('\n')
            .where((l) => l.isNotEmpty && !l.startsWith('#~#'))
            .toList();
        final fields = detailLines.first.split('|');
        // Gross wages in rupees = 5235000 / 100 = 52350
        expect(fields[2].trim(), '52350');
      });

      test('returns empty string for empty runs list', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        expect(ecr, isEmpty);
      });

      test('header contains total employees count', () {
        final ecr = EpfoEcrGenerator.generateEcr(
          runs: [sampleRun1, sampleRun2],
          establishmentId: 'MHBAN0001234000',
          month: 3,
          year: 2025,
        );
        final headerLine = ecr.split('\n').first;
        expect(headerLine, contains('2')); // 2 employees
      });
    });
  });
}
