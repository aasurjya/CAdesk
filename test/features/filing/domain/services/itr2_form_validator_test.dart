import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_al.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/services/itr2_form_validator.dart';

void main() {
  group('Itr2FormValidator', () {
    group('validate', () {
      test('→ valid empty form returns no errors', () {
        // Fill in required fields for a valid minimal form
        final form = Itr2FormData.empty().copyWith(
          personalInfo: PersonalInfo.empty().copyWith(
            firstName: 'Ramesh',
            lastName: 'Kumar',
            pan: 'ABCPK1234F',
            aadhaarNumber: '',
            mobile: '9876543210',
            email: 'ramesh@example.com',
            bankIfsc: 'SBIN0001234',
            employerTan: 'ABCD12345E',
            pincode: '400001',
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        expect(errors, isEmpty);
      });

      test('→ missing firstName returns REQUIRED error', () {
        final form = Itr2FormData.empty();
        final errors = Itr2FormValidator.validate(form);
        final firstNameError = errors.where((e) => e.field == 'firstName');
        expect(firstNameError, isNotEmpty);
      });

      test('→ invalid PAN returns INVALID_PAN error', () {
        final form = Itr2FormData.empty().copyWith(
          personalInfo: PersonalInfo.empty().copyWith(
            firstName: 'Test',
            lastName: 'User',
            pan: 'INVALID',
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        final panErrors = errors.where((e) => e.code == 'INVALID_PAN');
        expect(panErrors, isNotEmpty);
      });

      test('→ no Schedule AL when income ≤ ₹50L but scheduleAl provided', () {
        final form = Itr2FormData.empty().copyWith(
          personalInfo: PersonalInfo.empty().copyWith(
            firstName: 'Test',
            lastName: 'User',
            pan: 'ABCPK1234F',
            aadhaarNumber: '',
            mobile: '9876543210',
            email: 'test@example.com',
            bankIfsc: 'SBIN0001234',
            employerTan: 'ABCD12345E',
            pincode: '400001',
          ),
          salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 3000000),
          scheduleAl: const ScheduleAl(
            immovablePropertyValue: 0,
            movablePropertyValue: 0,
            financialAssetValue: 0,
            totalLiabilities: 0,
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        // No SCHEDULE_AL_REQUIRED error since income ≤ 50L
        final alErrors = errors.where((e) => e.code == 'SCHEDULE_AL_REQUIRED');
        expect(alErrors, isEmpty);
      });

      test(
        '→ SCHEDULE_AL_REQUIRED when income > ₹50L and scheduleAl is null',
        () {
          final form = Itr2FormData.empty().copyWith(
            personalInfo: PersonalInfo.empty().copyWith(
              firstName: 'Rich',
              lastName: 'Person',
              pan: 'ABCPK1234F',
              aadhaarNumber: '',
              mobile: '9876543210',
              email: 'rich@example.com',
              bankIfsc: 'SBIN0001234',
              employerTan: 'ABCD12345E',
              pincode: '400001',
            ),
            salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 7000000),
          );
          final errors = Itr2FormValidator.validate(form);
          final alErrors = errors.where(
            (e) => e.code == 'SCHEDULE_AL_REQUIRED',
          );
          expect(alErrors, isNotEmpty);
        },
      );

      test('→ negative STCG broughtForward returns NEGATIVE_SETOFF error', () {
        final form = Itr2FormData.empty().copyWith(
          personalInfo: PersonalInfo.empty().copyWith(
            firstName: 'Test',
            lastName: 'User',
            pan: 'ABCPK1234F',
            aadhaarNumber: '',
            mobile: '9876543210',
            email: 'test@example.com',
            bankIfsc: 'SBIN0001234',
            employerTan: 'ABCD12345E',
            pincode: '400001',
          ),
          scheduleCg: const ScheduleCg(
            equityStcgEntries: [],
            equityLtcgEntries: [],
            debtStcgEntries: [],
            debtLtcgEntries: [],
            propertyLtcgEntries: [],
            otherStcgEntries: [],
            otherLtcgEntries: [],
            broughtForwardStcl: -1000,
            broughtForwardLtcl: 0,
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        final bfErrors = errors.where((e) => e.code == 'NEGATIVE_SETOFF');
        expect(bfErrors, isNotEmpty);
      });
    });
  });
}
