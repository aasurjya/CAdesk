import 'package:ca_app/features/payroll/domain/models/attendance_record.dart';
import 'package:ca_app/features/payroll/domain/models/salary_package.dart';
import 'package:ca_app/features/payroll/domain/services/payroll_computation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PayrollComputationEngine', () {
    // Standard salary package for tests
    // Basic: ₹30,000 (3000000 paise)
    // HRA: ₹12,000 (1200000 paise)
    // Special: ₹5,000 (500000 paise)
    // Conveyance: ₹1,600 (160000 paise)
    // Medical: ₹1,250 (125000 paise)
    // LTA: ₹2,500 (250000 paise)
    // Gross = ₹52,350 → 5235000 paise
    const testPackage = SalaryPackage(
      basicPaise: 3000000,
      hraPaise: 1200000,
      specialAllowancePaise: 500000,
      ltaPaise: 250000,
      medicalPaise: 125000,
      conveyancePaise: 160000,
      pfWagePaise: 3000000,
      esiWagePaise: 5235000,
    );

    const fullAttendance = AttendanceRecord(
      employeeId: 'EMP001',
      month: 3,
      year: 2025,
      presentDays: 31,
      leaveDays: 0,
      lopDays: 0,
      holidays: 0,
    );

    const attendanceWithLop = AttendanceRecord(
      employeeId: 'EMP001',
      month: 3,
      year: 2025,
      presentDays: 26,
      leaveDays: 0,
      lopDays: 5,
      holidays: 0,
    );

    group('computePayroll', () {
      test(
        'computes gross pay correctly with full attendance (March 2025)',
        () {
          final run = PayrollComputationEngine.computePayroll(
            employeeId: 'EMP001',
            attendance: fullAttendance,
            package: testPackage,
            month: 3,
            year: 2025,
            monthlyTds: 0,
          );
          // Gross = 3000000+1200000+500000+250000+125000+160000 = 5235000
          expect(run.grossPayPaise, 5235000);
        },
      );

      test('applies LOP deduction correctly for March (31 days)', () {
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP001',
          attendance: attendanceWithLop,
          package: testPackage,
          month: 3,
          year: 2025,
          monthlyTds: 0,
        );
        // LOP = (5235000 * 5) / 31 = 26175000 / 31 = 844354 paise (truncated)
        // Net gross after LOP = 5235000 - 844354 = 4390646
        expect(run.lopDeductionPaise, 844354);
        expect(run.grossAfterLopPaise, 4390646);
      });

      test('computes PF employee contribution capped at wage ceiling', () {
        // PF wage = ₹30,000 which is exactly at ₹15,000 ceiling
        // But since pfWage = 3000000 > 1500000, it should be capped at 1500000
        // Employee PF = 12% of 1500000 = 180000 paise (₹1,800)
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP001',
          attendance: fullAttendance,
          package: testPackage,
          month: 3,
          year: 2025,
          monthlyTds: 0,
        );
        expect(run.pfContribution.employeeSharePaise, 180000);
      });

      test('computes ESI when wage is below ceiling', () {
        // ESI wage = 5235000 paise = ₹52,350 > ESI ceiling ₹21,000 → no ESI
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP001',
          attendance: fullAttendance,
          package: testPackage,
          month: 3,
          year: 2025,
          monthlyTds: 0,
        );
        // Above ESI ceiling, so no ESI
        expect(run.esiContribution.employeeContributionPaise, 0);
        expect(run.esiContribution.employerContributionPaise, 0);
      });

      test('computes ESI when wage is within ceiling', () {
        const lowWagePackage = SalaryPackage(
          basicPaise: 1000000, // ₹10,000
          hraPaise: 400000,
          specialAllowancePaise: 200000,
          ltaPaise: 0,
          medicalPaise: 0,
          conveyancePaise: 0,
          pfWagePaise: 1000000,
          esiWagePaise: 1600000, // ₹16,000 (below ₹21,000 ceiling)
        );
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP002',
          attendance: const AttendanceRecord(
            employeeId: 'EMP002',
            month: 3,
            year: 2025,
            presentDays: 31,
            leaveDays: 0,
            lopDays: 0,
            holidays: 0,
          ),
          package: lowWagePackage,
          month: 3,
          year: 2025,
          monthlyTds: 0,
        );
        // Employee ESI = 0.75% of 1600000 = 12000 paise
        expect(run.esiContribution.employeeContributionPaise, 12000);
        // Employer ESI = 3.25% of 1600000 = 52000 paise
        expect(run.esiContribution.employerContributionPaise, 52000);
      });

      test('computes net pay correctly', () {
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP001',
          attendance: fullAttendance,
          package: testPackage,
          month: 3,
          year: 2025,
          monthlyTds: 50000,
        );
        // Net = grossAfterLOP - employeePF - employeeESI - TDS
        // = 5235000 - 180000 - 0 - 50000 = 5005000
        expect(run.netPayPaise, 5005000);
      });

      test('sets month, year, and employeeId correctly', () {
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP001',
          attendance: fullAttendance,
          package: testPackage,
          month: 3,
          year: 2025,
          monthlyTds: 0,
        );
        expect(run.month, 3);
        expect(run.year, 2025);
        expect(run.employeeId, 'EMP001');
      });

      test('handles zero LOP correctly', () {
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP001',
          attendance: fullAttendance,
          package: testPackage,
          month: 3,
          year: 2025,
          monthlyTds: 0,
        );
        expect(run.lopDeductionPaise, 0);
        expect(run.grossAfterLopPaise, run.grossPayPaise);
      });
    });

    group('PF computation', () {
      test('PF wage below ceiling uses actual PF wage', () {
        const lowPfPackage = SalaryPackage(
          basicPaise: 1000000, // ₹10,000 < ₹15,000 ceiling
          hraPaise: 0,
          specialAllowancePaise: 0,
          ltaPaise: 0,
          medicalPaise: 0,
          conveyancePaise: 0,
          pfWagePaise: 1000000,
          esiWagePaise: 1000000,
        );
        final run = PayrollComputationEngine.computePayroll(
          employeeId: 'EMP003',
          attendance: const AttendanceRecord(
            employeeId: 'EMP003',
            month: 1,
            year: 2025,
            presentDays: 31,
            leaveDays: 0,
            lopDays: 0,
            holidays: 0,
          ),
          package: lowPfPackage,
          month: 1,
          year: 2025,
          monthlyTds: 0,
        );
        // Employee PF = 12% of 1000000 = 120000 paise
        expect(run.pfContribution.employeeSharePaise, 120000);
        // EPS = 8.33% of 1000000 = 83300 paise
        expect(run.pfContribution.employerEpsPaise, 83300);
        // EPF employer = 12% - EPS = 120000 - 83300 = 36700 paise
        expect(run.pfContribution.employerEpfPaise, 36700);
      });
    });
  });
}
