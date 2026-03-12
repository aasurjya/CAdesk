import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr4/business_income_44ad.dart';
import 'package:ca_app/features/filing/domain/models/itr4/goods_carriage_income_44ae.dart';
import 'package:ca_app/features/filing/domain/models/itr4/itr4_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr4/profession_income_44ada.dart';
import 'package:ca_app/features/filing/domain/services/itr4_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Build a valid ITR-4 form with personal info and one 44AD income source.
Itr4FormData _validForm() {
  return Itr4FormData.empty().copyWith(
    personalInfo: PersonalInfo.empty().copyWith(
      firstName: 'Raj',
      lastName: 'Kumar',
      pan: 'ABCPK1234F',
      aadhaarNumber: '',
      mobile: '9876543210',
      email: 'raj@example.com',
      bankIfsc: 'SBIN0001234',
      pincode: '110001',
    ),
    businessIncome44AD: BusinessIncome44AD.empty().copyWith(
      natureOfBusiness: 'Retail Trade',
      tradeName: 'Kumar Store',
      cashTurnover: 1000000,
    ),
  );
}

void main() {
  group('Itr4FormValidator — valid form', () {
    test('valid form returns no errors', () {
      final errors = Itr4FormValidator.validate(_validForm());
      expect(errors, isEmpty);
    });
  });

  group('Itr4FormValidator — personal info', () {
    test('missing firstName produces REQUIRED error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(firstName: ''),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'firstName'), isTrue);
    });

    test('missing lastName produces REQUIRED error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(lastName: ''),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.field == 'lastName'), isTrue);
    });

    test('invalid PAN produces INVALID_PAN error', () {
      final form = _validForm().copyWith(
        personalInfo: _validForm().personalInfo.copyWith(pan: 'INVALID'),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'INVALID_PAN'), isTrue);
    });
  });

  group('Itr4FormValidator — at least one presumptive income source', () {
    test('no income source produces NO_PRESUMPTIVE_INCOME error', () {
      final form = _validForm().copyWith(
        businessIncome44AD: BusinessIncome44AD.empty(),
        professionIncome44ADA: ProfessionIncome44ADA.empty(),
        goodsCarriageIncome44AE: GoodsCarriageIncome44AE.empty(),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'NO_PRESUMPTIVE_INCOME'), isTrue);
    });

    test('only 44ADA income satisfies requirement', () {
      final form = _validForm().copyWith(
        businessIncome44AD: BusinessIncome44AD.empty(),
        professionIncome44ADA: ProfessionIncome44ADA.empty().copyWith(
          natureOfProfession: 'Legal',
          grossReceipts: 500000,
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'NO_PRESUMPTIVE_INCOME'), isFalse);
    });

    test('only 44AE income satisfies requirement', () {
      final form = _validForm().copyWith(
        businessIncome44AD: BusinessIncome44AD.empty(),
        goodsCarriageIncome44AE: const GoodsCarriageIncome44AE(
          numberOfVehicles: 1,
          monthsOperatedPerVehicle: [12],
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'NO_PRESUMPTIVE_INCOME'), isFalse);
    });
  });

  group('Itr4FormValidator — 44AD turnover limit (3 Cr)', () {
    test('turnover exactly at limit passes', () {
      final form = _validForm().copyWith(
        businessIncome44AD: BusinessIncome44AD.empty().copyWith(
          natureOfBusiness: 'Retail',
          cashTurnover: 30000000,
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(
        errors.any((e) => e.code == 'TURNOVER_EXCEEDS_44AD_LIMIT'),
        isFalse,
      );
    });

    test('turnover exceeding limit produces error', () {
      final form = _validForm().copyWith(
        businessIncome44AD: BusinessIncome44AD.empty().copyWith(
          natureOfBusiness: 'Retail',
          cashTurnover: 30000001,
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(
        errors.any((e) => e.code == 'TURNOVER_EXCEEDS_44AD_LIMIT'),
        isTrue,
      );
    });
  });

  group('Itr4FormValidator — 44ADA receipts limit (75L)', () {
    test('receipts at limit passes', () {
      final form = _validForm().copyWith(
        professionIncome44ADA: ProfessionIncome44ADA.empty().copyWith(
          natureOfProfession: 'Medical',
          grossReceipts: 7500000,
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(
        errors.any((e) => e.code == 'RECEIPTS_EXCEED_44ADA_LIMIT'),
        isFalse,
      );
    });

    test('receipts exceeding limit produces error', () {
      final form = _validForm().copyWith(
        professionIncome44ADA: ProfessionIncome44ADA.empty().copyWith(
          natureOfProfession: 'Medical',
          grossReceipts: 7500001,
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(
        errors.any((e) => e.code == 'RECEIPTS_EXCEED_44ADA_LIMIT'),
        isTrue,
      );
    });
  });

  group('Itr4FormValidator — 44AE vehicle count limit (10)', () {
    test('10 vehicles at limit passes', () {
      final form = _validForm().copyWith(
        goodsCarriageIncome44AE: GoodsCarriageIncome44AE(
          numberOfVehicles: 10,
          monthsOperatedPerVehicle: List.filled(10, 12),
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(
        errors.any((e) => e.code == 'VEHICLES_EXCEED_44AE_LIMIT'),
        isFalse,
      );
    });

    test('11 vehicles exceeds limit', () {
      final form = _validForm().copyWith(
        goodsCarriageIncome44AE: GoodsCarriageIncome44AE(
          numberOfVehicles: 11,
          monthsOperatedPerVehicle: List.filled(11, 12),
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'VEHICLES_EXCEED_44AE_LIMIT'), isTrue);
    });

    test('months mismatch produces error', () {
      final form = _validForm().copyWith(
        goodsCarriageIncome44AE: const GoodsCarriageIncome44AE(
          numberOfVehicles: 3,
          monthsOperatedPerVehicle: [12, 6],
        ),
      );
      final errors = Itr4FormValidator.validate(form);
      expect(errors.any((e) => e.code == 'MONTHS_VEHICLE_MISMATCH'), isTrue);
    });
  });
}
