import 'package:ca_app/features/payroll/domain/models/salary_package.dart';
import 'package:ca_app/features/payroll/domain/services/full_and_final_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FullAndFinalService', () {
    const testPackage = SalaryPackage(
      basicPaise: 3000000, // ₹30,000/month
      hraPaise: 1200000,
      specialAllowancePaise: 500000,
      ltaPaise: 250000,
      medicalPaise: 125000,
      conveyancePaise: 160000,
      pfWagePaise: 3000000,
      esiWagePaise: 5235000,
    );

    group('compute', () {
      test(
        'computes full and final with 10 years service and 15 pending leaves',
        () {
          final settlement = FullAndFinalService.compute(
            employeeId: 'EMP001',
            relievingDate: DateTime(2025, 3, 31),
            joiningDate: DateTime(2015, 3, 1),
            pendingLeaves: 15,
            package: testPackage,
          );

          // Gratuity: Basic ₹30,000, 10 years
          // = 3000000 * 15 * 10 / 26 = 450000000 / 26 = 17307692 paise
          expect(settlement.gratuityAmountPaise, 17307692);

          // Leave encashment: daily = 3000000 ~/ 26 = 115384 paise (integer truncation)
          // 15 days = 15 * 115384 = 1730760 paise
          expect(settlement.leaveEncashmentAmountPaise, 1730760);

          expect(settlement.employeeId, 'EMP001');
          expect(settlement.relievingDate, DateTime(2025, 3, 31));
          expect(settlement.pendingLeaves, 15);
        },
      );

      test('computes no gratuity for less than 5 years service', () {
        final settlement = FullAndFinalService.compute(
          employeeId: 'EMP002',
          relievingDate: DateTime(2025, 3, 31),
          joiningDate: DateTime(2022, 1, 1),
          pendingLeaves: 5,
          package: testPackage,
        );
        expect(settlement.gratuityAmountPaise, 0);
      });

      test('computes notice pay when notice period not served', () {
        // noticePeriodDays = 30, daysServed = 10 → owe 20 days notice pay
        final settlement = FullAndFinalService.compute(
          employeeId: 'EMP003',
          relievingDate: DateTime(2025, 3, 10),
          joiningDate: DateTime(2018, 1, 1),
          pendingLeaves: 0,
          package: testPackage,
          noticePeriodDays: 30,
          noticeDaysServed: 10,
        );
        // Days owed = 20, daily basic = 3000000 / 26 = 115384 paise
        // Notice pay deduction = 20 * 115384 = 2307692 paise (negative)
        // Since notice not served, notice pay should be negative (deduction)
        expect(settlement.noticePayPaise, isNegative);
      });

      test(
        'computes positive notice pay when employer terminates without notice',
        () {
          // noticePeriodDays = 30, daysServed = 0, employerInitiated = true
          final settlement = FullAndFinalService.compute(
            employeeId: 'EMP004',
            relievingDate: DateTime(2025, 3, 1),
            joiningDate: DateTime(2018, 1, 1),
            pendingLeaves: 0,
            package: testPackage,
            noticePeriodDays: 30,
            noticeDaysServed: 0,
            employerInitiatedTermination: true,
          );
          // Employer owes 30 days notice pay → positive
          expect(settlement.noticePayPaise, isPositive);
        },
      );

      test('computes total payable correctly', () {
        final settlement = FullAndFinalService.compute(
          employeeId: 'EMP001',
          relievingDate: DateTime(2025, 3, 31),
          joiningDate: DateTime(2015, 3, 1),
          pendingLeaves: 10,
          package: testPackage,
        );
        // totalPayable = gratuity + leaveEncashment + noticePay
        final expected =
            settlement.gratuityAmountPaise +
            settlement.leaveEncashmentAmountPaise +
            settlement.noticePayPaise;
        expect(settlement.totalPayablePaise, expected);
      });

      test('sets years of service correctly', () {
        final settlement = FullAndFinalService.compute(
          employeeId: 'EMP001',
          relievingDate: DateTime(2025, 3, 31),
          joiningDate: DateTime(2015, 3, 1),
          pendingLeaves: 0,
          package: testPackage,
        );
        expect(settlement.yearsOfService, 10);
      });
    });
  });
}
