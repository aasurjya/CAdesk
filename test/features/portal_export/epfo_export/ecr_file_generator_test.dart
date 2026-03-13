import 'package:ca_app/features/payroll/domain/models/esi_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/pf_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';
import 'package:ca_app/features/portal_export/epfo_export/models/ecr_export_result.dart';
import 'package:ca_app/features/portal_export/epfo_export/models/ecr_member_row.dart';
import 'package:ca_app/features/portal_export/epfo_export/services/ecr_file_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared test fixtures
  // ---------------------------------------------------------------------------

  const esiZero = EsiContribution(
    esiWagePaise: 0,
    employeeContributionPaise: 0,
    employerContributionPaise: 0,
    isApplicable: false,
  );

  /// Employee A: wages at ceiling (₹15,000 gross, PF on full ₹15,000).
  final runA = PayrollRun(
    runId: 'RUN-A',
    month: 3,
    year: 2024,
    employeeId: 'EMP001',
    employeeName: 'John Doe',
    uan: '100123456789',
    grossPayPaise: 1500000, // ₹15,000
    lopDeductionPaise: 0,
    grossAfterLopPaise: 1500000,
    deductionsPaise: 180000,
    netPayPaise: 1320000,
    tdsDeductedPaise: 0,
    pfContribution: const PfContribution(
      pfWagePaise: 1500000, // ₹15,000
      employeeSharePaise: 180000, // 12% of 15,000
      employerEpsPaise:
          124950, // 8.33% of 15,000 ~ 1249.50 → min ₹1,250 → 125000
      employerEpfPaise: 55050, // 3.67% of 15,000
      adminChargesPaise: 7500,
    ),
    esiContribution: esiZero,
  );

  /// Employee B: wages above ceiling (₹20,000 gross, PF capped at ₹15,000), 2 LOP days.
  final runB = PayrollRun(
    runId: 'RUN-B',
    month: 3,
    year: 2024,
    employeeId: 'EMP002',
    employeeName: 'Jane Smith',
    uan: '100987654321',
    grossPayPaise: 2000000, // ₹20,000
    lopDeductionPaise: 133333, // 2 days LOP
    grossAfterLopPaise: 1866667,
    deductionsPaise: 180000,
    netPayPaise: 1686667,
    tdsDeductedPaise: 0,
    pfContribution: const PfContribution(
      pfWagePaise: 1500000, // capped
      employeeSharePaise: 180000,
      employerEpsPaise: 125000, // min ₹1,250
      employerEpfPaise: 55000,
      adminChargesPaise: 7500,
    ),
    esiContribution: esiZero,
  );

  const establishmentId = '7001234';
  const month = 3;
  const year = 2024;

  // ---------------------------------------------------------------------------
  // EcrFileGenerator tests
  // ---------------------------------------------------------------------------

  group('EcrFileGenerator', () {
    group('generateFileName', () {
      test('returns correctly formatted file name', () {
        final name = EcrFileGenerator.instance.generateFileName(
          establishmentId,
          month,
          year,
        );
        expect(name, 'ECR_7001234_032024.txt');
      });

      test('zero-pads single-digit month', () {
        final name = EcrFileGenerator.instance.generateFileName(
          '1234567',
          1,
          2025,
        );
        expect(name, 'ECR_1234567_012025.txt');
      });

      test('does not pad two-digit month', () {
        final name = EcrFileGenerator.instance.generateFileName(
          '1234567',
          12,
          2025,
        );
        expect(name, 'ECR_1234567_122025.txt');
      });
    });

    group('generateHeader', () {
      test('header has correct EPFO prefix', () {
        final header = EcrFileGenerator.instance.generateHeader(
          establishmentId,
          month,
          year,
          2,
        );
        expect(header, startsWith('#~#EPFO#~#ECR#~#V2.0#~#'));
      });

      test('header contains establishment ID', () {
        final header = EcrFileGenerator.instance.generateHeader(
          establishmentId,
          month,
          year,
          2,
        );
        expect(header, contains(establishmentId));
      });

      test('header contains zero-padded month and year', () {
        final header = EcrFileGenerator.instance.generateHeader(
          establishmentId,
          month,
          year,
          2,
        );
        expect(header, contains('03 2024'));
      });

      test('header contains member count', () {
        final header = EcrFileGenerator.instance.generateHeader(
          establishmentId,
          month,
          year,
          5,
        );
        expect(header, contains('#~#5#~#'));
      });

      test('header ends with #~#', () {
        final header = EcrFileGenerator.instance.generateHeader(
          establishmentId,
          month,
          year,
          1,
        );
        expect(header, endsWith('#~#'));
      });

      test('exact header format matches ECR v2.0 spec', () {
        final header = EcrFileGenerator.instance.generateHeader(
          '7001234',
          3,
          2024,
          2,
        );
        expect(header, '#~#EPFO#~#ECR#~#V2.0#~#7001234#~#03 2024#~#2#~#');
      });
    });

    group('generateDetailRow', () {
      const row = EcrMemberRow(
        uan: '100123456789',
        memberName: 'John Doe',
        grossWagesPaise: 1500000,
        epfWagesPaise: 1500000,
        epsWagesPaise: 1500000,
        edliWagesPaise: 1500000,
        employeeEpfPaise: 180000,
        employerEpsPaise: 125000,
        employerEpfPaise: 55000,
        ncp: 0,
        refundsPaise: 0,
      );

      test('detail row starts with UAN', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        expect(line, startsWith('100123456789#~#'));
      });

      test('detail row ends with #~#', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        expect(line, endsWith('#~#'));
      });

      test('detail row contains member name', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        expect(line, contains('#~#John Doe#~#'));
      });

      test('wages are converted from paise to rupees', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        // 1500000 paise = 15000 rupees
        expect(line, contains('#~#15000#~#'));
      });

      test('employee EPF in rupees', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        // 180000 paise = 1800 rupees
        expect(line, contains('#~#1800#~#'));
      });

      test('employer EPS in rupees', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        // 125000 paise = 1250 rupees
        expect(line, contains('#~#1250#~#'));
      });

      test('employer EPF in rupees', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        // 55000 paise = 550 rupees
        expect(line, contains('#~#550#~#'));
      });

      test('NCP days included', () {
        const rowWithNcp = EcrMemberRow(
          uan: '100123456789',
          memberName: 'John Doe',
          grossWagesPaise: 1500000,
          epfWagesPaise: 1500000,
          epsWagesPaise: 1500000,
          edliWagesPaise: 1500000,
          employeeEpfPaise: 180000,
          employerEpsPaise: 125000,
          employerEpfPaise: 55000,
          ncp: 3,
          refundsPaise: 0,
        );
        final line = EcrFileGenerator.instance.generateDetailRow(rowWithNcp);
        expect(line, contains('#~#3#~#'));
      });

      test('detail row has exactly 11 #~# separators', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        final count = '#~#'.allMatches(line).length;
        expect(count, 11);
      });

      test('exact row format matches ECR v2.0 spec', () {
        final line = EcrFileGenerator.instance.generateDetailRow(row);
        expect(
          line,
          '100123456789#~#John Doe#~#15000#~#15000#~#15000#~#15000#~#1800#~#1250#~#550#~#0#~#0#~#',
        );
      });
    });

    group('buildMemberRows', () {
      test('returns one row per payroll run', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA, runB]);
        expect(rows.length, 2);
      });

      test('maps UAN from payroll run', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.uan, '100123456789');
      });

      test('maps member name from payroll run', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.memberName, 'John Doe');
      });

      test('gross wages from grossAfterLopPaise', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runB]);
        // grossAfterLopPaise = 1866667
        expect(rows.first.grossWagesPaise, 1866667);
      });

      test('epfWagesPaise from pfWagePaise', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.epfWagesPaise, 1500000);
      });

      test('epsWagesPaise equals epfWagesPaise', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.epsWagesPaise, rows.first.epfWagesPaise);
      });

      test('edliWagesPaise equals epfWagesPaise', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.edliWagesPaise, rows.first.epfWagesPaise);
      });

      test('employeeEpfPaise from employeeSharePaise', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.employeeEpfPaise, 180000);
      });

      test('employerEpsPaise from pfContribution', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.employerEpsPaise, 124950);
      });

      test('employerEpfPaise from pfContribution', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.employerEpfPaise, 55050);
      });

      test('ncp derives LOP days from lopDeductionPaise (0 when no LOP)', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.ncp, 0);
      });

      test('refundsPaise is 0 by default', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([runA]);
        expect(rows.first.refundsPaise, 0);
      });

      test('returns empty list for empty input', () {
        final rows = EcrFileGenerator.instance.buildMemberRows([]);
        expect(rows, isEmpty);
      });
    });

    group('generate', () {
      test('returns EcrExportResult', () {
        final result = EcrFileGenerator.instance.generate(
          [runA, runB],
          establishmentId,
          month,
          year,
        );
        expect(result, isA<EcrExportResult>());
      });

      test('result has correct establishment ID', () {
        final result = EcrFileGenerator.instance.generate(
          [runA],
          establishmentId,
          month,
          year,
        );
        expect(result.establishmentId, establishmentId);
      });

      test('result has correct month and year', () {
        final result = EcrFileGenerator.instance.generate(
          [runA],
          establishmentId,
          month,
          year,
        );
        expect(result.month, month);
        expect(result.year, year);
      });

      test('result ecrType is ecr1', () {
        final result = EcrFileGenerator.instance.generate(
          [runA],
          establishmentId,
          month,
          year,
        );
        expect(result.ecrType, EcrType.ecr1);
      });

      test('result memberCount matches run count', () {
        final result = EcrFileGenerator.instance.generate(
          [runA, runB],
          establishmentId,
          month,
          year,
        );
        expect(result.memberCount, 2);
      });

      test('result fileName is correctly formatted', () {
        final result = EcrFileGenerator.instance.generate(
          [runA],
          establishmentId,
          month,
          year,
        );
        expect(result.fileName, 'ECR_7001234_032024.txt');
      });

      test('fileContent starts with ECR header', () {
        final result = EcrFileGenerator.instance.generate(
          [runA],
          establishmentId,
          month,
          year,
        );
        expect(result.fileContent, startsWith('#~#EPFO#~#ECR#~#V2.0#~#'));
      });

      test('fileContent has header plus one detail line per run', () {
        final result = EcrFileGenerator.instance.generate(
          [runA, runB],
          establishmentId,
          month,
          year,
        );
        final lines = result.fileContent
            .split('\n')
            .where((l) => l.isNotEmpty)
            .toList();
        // 1 header + 2 detail rows
        expect(lines.length, 3);
      });

      test('totalWages is sum of grossAfterLopPaise for all runs', () {
        final result = EcrFileGenerator.instance.generate(
          [runA, runB],
          establishmentId,
          month,
          year,
        );
        final expected = runA.grossAfterLopPaise + runB.grossAfterLopPaise;
        expect(result.totalWages, expected);
      });

      test('totalPfContribution is sum of employeeSharePaise for all runs', () {
        final result = EcrFileGenerator.instance.generate(
          [runA, runB],
          establishmentId,
          month,
          year,
        );
        final expected =
            runA.pfContribution.employeeSharePaise +
            runB.pfContribution.employeeSharePaise;
        expect(result.totalPfContribution, expected);
      });

      test('validationErrors is empty for valid input', () {
        final result = EcrFileGenerator.instance.generate(
          [runA, runB],
          establishmentId,
          month,
          year,
        );
        expect(result.validationErrors, isEmpty);
      });

      test('returns result with errors for invalid establishment ID', () {
        final result = EcrFileGenerator.instance.generate(
          [runA],
          'INVALID', // not 7-digit numeric
          month,
          year,
        );
        expect(result.validationErrors, isNotEmpty);
      });

      test('returns result with errors for invalid UAN in run', () {
        final badUanRun = runA.copyWith(uan: 'SHORT');
        final result = EcrFileGenerator.instance.generate(
          [badUanRun],
          establishmentId,
          month,
          year,
        );
        expect(result.validationErrors, isNotEmpty);
      });

      test('empty runs list returns empty fileContent', () {
        final result = EcrFileGenerator.instance.generate(
          [],
          establishmentId,
          month,
          year,
        );
        expect(result.fileContent, isEmpty);
        expect(result.memberCount, 0);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // EcrMemberRow model tests
  // ---------------------------------------------------------------------------

  group('EcrMemberRow', () {
    const row = EcrMemberRow(
      uan: '100123456789',
      memberName: 'John Doe',
      grossWagesPaise: 1500000,
      epfWagesPaise: 1500000,
      epsWagesPaise: 1500000,
      edliWagesPaise: 1500000,
      employeeEpfPaise: 180000,
      employerEpsPaise: 125000,
      employerEpfPaise: 55000,
      ncp: 0,
      refundsPaise: 0,
    );

    test('copyWith returns new instance with changed field', () {
      final updated = row.copyWith(ncp: 5);
      expect(updated.ncp, 5);
      expect(updated.uan, row.uan);
    });

    test('equality holds for identical objects', () {
      const same = EcrMemberRow(
        uan: '100123456789',
        memberName: 'John Doe',
        grossWagesPaise: 1500000,
        epfWagesPaise: 1500000,
        epsWagesPaise: 1500000,
        edliWagesPaise: 1500000,
        employeeEpfPaise: 180000,
        employerEpsPaise: 125000,
        employerEpfPaise: 55000,
        ncp: 0,
        refundsPaise: 0,
      );
      expect(row, same);
    });

    test('hashCode is consistent', () {
      expect(row.hashCode, row.hashCode);
    });

    test('toString contains UAN', () {
      expect(row.toString(), contains('100123456789'));
    });
  });

  // ---------------------------------------------------------------------------
  // EcrExportResult model tests
  // ---------------------------------------------------------------------------

  group('EcrExportResult', () {
    const result = EcrExportResult(
      establishmentId: '7001234',
      month: 3,
      year: 2024,
      ecrType: EcrType.ecr1,
      fileContent: '#~#EPFO#~#ECR#~#V2.0#~#7001234#~#03 2024#~#1#~#\n',
      fileName: 'ECR_7001234_032024.txt',
      memberCount: 1,
      totalWages: 1500000,
      totalPfContribution: 180000,
      validationErrors: [],
    );

    test('copyWith returns new instance with changed field', () {
      final updated = result.copyWith(memberCount: 5);
      expect(updated.memberCount, 5);
      expect(updated.establishmentId, result.establishmentId);
    });

    test('equality holds for identical objects', () {
      const same = EcrExportResult(
        establishmentId: '7001234',
        month: 3,
        year: 2024,
        ecrType: EcrType.ecr1,
        fileContent: '#~#EPFO#~#ECR#~#V2.0#~#7001234#~#03 2024#~#1#~#\n',
        fileName: 'ECR_7001234_032024.txt',
        memberCount: 1,
        totalWages: 1500000,
        totalPfContribution: 180000,
        validationErrors: [],
      );
      expect(result, same);
    });

    test('hashCode is consistent', () {
      expect(result.hashCode, result.hashCode);
    });

    test('toString contains establishment ID', () {
      expect(result.toString(), contains('7001234'));
    });

    test('EcrType.ecr1 and EcrType.ecr2 are distinct', () {
      expect(EcrType.ecr1, isNot(EcrType.ecr2));
    });
  });
}
