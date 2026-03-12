import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/services/itr1_form_validator.dart';

Itr1FormData _validForm() {
  return Itr1FormData.empty().copyWith(
    personalInfo: PersonalInfo.empty().copyWith(
      firstName: 'Ramesh',
      lastName: 'Kumar',
      pan: 'ABCPK1234F',
      mobile: '9876543210',
      email: 'ramesh@example.com',
      bankIfsc: 'SBIN0001234',
      pincode: '400001',
    ),
    salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 800000),
  );
}

void main() {
  group('Itr1FormValidator — valid form', () {
    test('complete valid form → no errors', () {
      final errors = Itr1FormValidator.validate(_validForm());
      expect(errors, isEmpty);
    });
  });

  group('Itr1FormValidator — personal info validation', () {
    test('missing first name → error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(firstName: ''),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'firstName'), isTrue);
    });

    test('missing last name → error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(lastName: ''),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'lastName'), isTrue);
    });

    test('invalid PAN → error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(pan: 'INVALID'),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'pan'), isTrue);
    });

    test('invalid mobile → error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(mobile: '123'),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'mobile'), isTrue);
    });

    test('invalid email → error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(email: 'not-email'),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'email'), isTrue);
    });

    test('invalid IFSC → error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(bankIfsc: 'BAD'),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'bankIfsc'), isTrue);
    });
  });

  group('Itr1FormValidator — eligibility', () {
    test('gross income > ₹50L → ITR-1 not applicable', () {
      final form = _validForm().copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 6000000),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'ITR1_INCOME_LIMIT'), isTrue);
    });

    test('gross income ≤ ₹50L → no eligibility error', () {
      final form = _validForm().copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 4000000),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'ITR1_INCOME_LIMIT'), isFalse);
    });
  });

  group('Itr1FormValidator — house property', () {
    test('self-occupied with interest > ₹2L → capped warning', () {
      final form = _validForm().copyWith(
        housePropertyIncome: const HousePropertyIncome(
          annualLetableValue: 0, // self-occupied
          municipalTaxesPaid: 0,
          interestOnLoan: 250000, // > ₹2L cap
        ),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'SELF_OCCUPIED_INTEREST_CAP'), isTrue);
    });

    test('let-out with interest > ₹2L → no cap error', () {
      final form = _validForm().copyWith(
        housePropertyIncome: const HousePropertyIncome(
          annualLetableValue: 300000, // let-out
          municipalTaxesPaid: 10000,
          interestOnLoan: 250000,
        ),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(
        errors.any((e) => e.code == 'SELF_OCCUPIED_INTEREST_CAP'),
        isFalse,
      );
    });

    test('municipal taxes > ALV → warning', () {
      final form = _validForm().copyWith(
        housePropertyIncome: const HousePropertyIncome(
          annualLetableValue: 100000,
          municipalTaxesPaid: 150000, // exceeds ALV
          interestOnLoan: 0,
        ),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'MUNICIPAL_TAX_EXCEEDS_ALV'), isTrue);
    });
  });

  group('Itr1FormValidator — income sources', () {
    test('negative salary → error', () {
      final form = _validForm().copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: -10000),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'NEGATIVE_SALARY'), isTrue);
    });

    test('negative other income → error', () {
      final form = _validForm().copyWith(
        otherSourceIncome: OtherSourceIncome.empty().copyWith(
          savingsAccountInterest: -5000,
        ),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'NEGATIVE_OTHER_INCOME'), isTrue);
    });
  });

  group('Itr1FormValidator — error immutability', () {
    test('returned list is unmodifiable', () {
      // Use an invalid form to get a non-empty error list
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(firstName: ''),
      );
      final errors = Itr1FormValidator.validate(form);
      expect(errors, isNotEmpty);
      expect(() => errors.add(errors.first), throwsUnsupportedError);
    });
  });
}
