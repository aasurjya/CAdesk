import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_al.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
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

  // Helper to build a fully valid personal info
  PersonalInfo validPi() => PersonalInfo.empty().copyWith(
    firstName: 'Ramesh',
    lastName: 'Kumar',
    pan: 'ABCPK1234F',
    aadhaarNumber: '',
    mobile: '9876543210',
    email: 'ramesh@example.com',
    bankIfsc: 'SBIN0001234',
    employerTan: 'ABCD12345E',
    pincode: '400001',
  );

  group('Itr2FormValidator — personal info branches', () {
    test('→ missing lastName returns REQUIRED error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: PersonalInfo.empty().copyWith(
          firstName: 'Ramesh',
          lastName: '',
          pan: 'ABCPK1234F',
          mobile: '9876543210',
        ),
      );
      final errors = Itr2FormValidator.validate(form);
      final lastNameErrors = errors.where((e) => e.field == 'lastName');
      expect(lastNameErrors, isNotEmpty);
      expect(lastNameErrors.first.code, 'REQUIRED');
    });

    test('→ whitespace-only firstName returns REQUIRED error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: PersonalInfo.empty().copyWith(firstName: '   '),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(
        errors.where((e) => e.field == 'firstName' && e.code == 'REQUIRED'),
        isNotEmpty,
      );
    });

    test('→ invalid mobile (starts with 5) returns INVALID_MOBILE error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(mobile: '5123456789'),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_MOBILE'), isNotEmpty);
    });

    test('→ empty mobile returns INVALID_MOBILE error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(mobile: ''),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_MOBILE'), isNotEmpty);
    });

    test('→ invalid email format returns INVALID_EMAIL error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(email: 'not-an-email'),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_EMAIL'), isNotEmpty);
    });

    test('→ empty email is accepted (optional)', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(email: ''),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_EMAIL'), isEmpty);
    });

    test('→ invalid IFSC returns INVALID_IFSC error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(bankIfsc: 'BADIFSC'),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_IFSC'), isNotEmpty);
    });

    test('→ empty IFSC is accepted (optional)', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(bankIfsc: ''),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_IFSC'), isEmpty);
    });

    test('→ invalid TAN format returns INVALID_TAN error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(employerTan: 'BADTAN'),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_TAN'), isNotEmpty);
    });

    test('→ empty TAN is accepted (optional)', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(employerTan: ''),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_TAN'), isEmpty);
    });

    test('→ invalid pincode (too short) returns INVALID_PINCODE error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(pincode: '1234'),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_PINCODE'), isNotEmpty);
    });

    test('→ pincode starting with 0 returns INVALID_PINCODE error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(pincode: '012345'),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_PINCODE'), isNotEmpty);
    });

    test('→ empty pincode is accepted (optional)', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(pincode: ''),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_PINCODE'), isEmpty);
    });

    test('→ invalid Aadhaar (wrong length) returns INVALID_AADHAAR error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(aadhaarNumber: '123456789'),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_AADHAAR'), isNotEmpty);
    });

    test(
      '→ Aadhaar with non-digit characters returns INVALID_AADHAAR error',
      () {
        final form = Itr2FormData.empty().copyWith(
          personalInfo: validPi().copyWith(aadhaarNumber: '12345678901A'),
        );
        final errors = Itr2FormValidator.validate(form);
        expect(errors.where((e) => e.code == 'INVALID_AADHAAR'), isNotEmpty);
      },
    );

    test('→ empty Aadhaar is accepted (optional)', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi().copyWith(aadhaarNumber: ''),
      );
      final errors = Itr2FormValidator.validate(form);
      expect(errors.where((e) => e.code == 'INVALID_AADHAAR'), isEmpty);
    });
  });

  group('Itr2FormValidator — capital gains branches', () {
    test('→ negative broughtForwardLtcl returns NEGATIVE_SETOFF error', () {
      final form = Itr2FormData.empty().copyWith(
        personalInfo: validPi(),
        scheduleCg: const ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: -5000,
        ),
      );
      final errors = Itr2FormValidator.validate(form);
      final bfErrors = errors.where((e) => e.field == 'broughtForwardLtcl');
      expect(bfErrors, isNotEmpty);
      expect(bfErrors.first.code, 'NEGATIVE_SETOFF');
    });

    test(
      '→ equityStcgEntry with negative salePrice returns NEGATIVE_SALE_PRICE',
      () {
        final entry = EquityStcgEntry(
          description: 'Bad entry',
          salePrice: -100000,
          costOfAcquisition: 50000,
          transferExpenses: 0,
        );
        final form = Itr2FormData.empty().copyWith(
          personalInfo: validPi(),
          scheduleCg: ScheduleCg(
            equityStcgEntries: [entry],
            equityLtcgEntries: const [],
            debtStcgEntries: const [],
            debtLtcgEntries: const [],
            propertyLtcgEntries: const [],
            otherStcgEntries: const [],
            otherLtcgEntries: const [],
            broughtForwardStcl: 0,
            broughtForwardLtcl: 0,
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        final saleErrors = errors.where(
          (e) =>
              e.field == 'equityStcgEntries' && e.code == 'NEGATIVE_SALE_PRICE',
        );
        expect(saleErrors, isNotEmpty);
      },
    );

    test(
      '→ propertyLtcgEntry with negative salePrice returns NEGATIVE_SALE_PRICE',
      () {
        final entry = PropertyLtcgEntry(
          description: 'Bad property',
          salePrice: -500000,
          indexedCostOfAcquisition: 300000,
          improvementCost: 0,
          transferExpenses: 0,
          acquisitionDate: DateTime(2015, 1, 1),
        );
        final form = Itr2FormData.empty().copyWith(
          personalInfo: validPi(),
          scheduleCg: ScheduleCg(
            equityStcgEntries: const [],
            equityLtcgEntries: const [],
            debtStcgEntries: const [],
            debtLtcgEntries: const [],
            propertyLtcgEntries: [entry],
            otherStcgEntries: const [],
            otherLtcgEntries: const [],
            broughtForwardStcl: 0,
            broughtForwardLtcl: 0,
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        final saleErrors = errors.where(
          (e) =>
              e.field == 'propertyLtcgEntries' &&
              e.code == 'NEGATIVE_SALE_PRICE',
        );
        expect(saleErrors, isNotEmpty);
      },
    );

    test(
      '→ propertyLtcgEntry with negative indexedCost returns NEGATIVE_INDEXED_COST',
      () {
        final entry = PropertyLtcgEntry(
          description: 'Bad indexed cost',
          salePrice: 500000,
          indexedCostOfAcquisition: -100000,
          improvementCost: 0,
          transferExpenses: 0,
          acquisitionDate: DateTime(2015, 1, 1),
        );
        final form = Itr2FormData.empty().copyWith(
          personalInfo: validPi(),
          scheduleCg: ScheduleCg(
            equityStcgEntries: const [],
            equityLtcgEntries: const [],
            debtStcgEntries: const [],
            debtLtcgEntries: const [],
            propertyLtcgEntries: [entry],
            otherStcgEntries: const [],
            otherLtcgEntries: const [],
            broughtForwardStcl: 0,
            broughtForwardLtcl: 0,
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        final indexedErrors = errors.where(
          (e) =>
              e.field == 'propertyLtcgEntries' &&
              e.code == 'NEGATIVE_INDEXED_COST',
        );
        expect(indexedErrors, isNotEmpty);
      },
    );

    test('→ result list is unmodifiable', () {
      final form = Itr2FormData.empty().copyWith(personalInfo: validPi());
      final errors = Itr2FormValidator.validate(form);
      expect(() => (errors as dynamic).add(null), throwsA(anything));
    });

    test(
      '→ accumulates multiple errors from different validation sections',
      () {
        // Missing firstName AND invalid PAN AND negative LTCL
        final form = Itr2FormData.empty().copyWith(
          personalInfo: PersonalInfo.empty().copyWith(
            firstName: '',
            pan: 'BADPAN',
          ),
          scheduleCg: const ScheduleCg(
            equityStcgEntries: [],
            equityLtcgEntries: [],
            debtStcgEntries: [],
            debtLtcgEntries: [],
            propertyLtcgEntries: [],
            otherStcgEntries: [],
            otherLtcgEntries: [],
            broughtForwardStcl: 0,
            broughtForwardLtcl: -1000,
          ),
        );
        final errors = Itr2FormValidator.validate(form);
        expect(errors.length, greaterThanOrEqualTo(3));
      },
    );
  });
}
