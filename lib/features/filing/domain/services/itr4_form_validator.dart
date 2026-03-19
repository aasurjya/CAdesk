import 'package:ca_app/features/filing/domain/models/itr4/business_income_44ad.dart';
import 'package:ca_app/features/filing/domain/models/itr4/goods_carriage_income_44ae.dart';
import 'package:ca_app/features/filing/domain/models/itr4/itr4_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr4/profession_income_44ada.dart';
import 'package:ca_app/features/filing/domain/models/validation_error.dart';
import 'package:ca_app/features/filing/domain/services/filing_validators.dart';

/// Validates complete ITR-4 (Sugam) form data before export/filing.
///
/// Checks eligibility conditions, required fields, and business rules
/// for presumptive taxation under Sections 44AD, 44ADA, and 44AE.
class Itr4FormValidator {
  Itr4FormValidator._();

  /// Validate the complete ITR-4 form data.
  ///
  /// Returns an empty list if the form is valid.
  static List<ValidationError> validate(Itr4FormData data) {
    final errors = <ValidationError>[];

    _validatePersonalInfo(data, errors);
    _validateAtLeastOneIncomeSource(data, errors);
    _validate44AD(data.businessIncome44AD, errors);
    _validate44ADA(data.professionIncome44ADA, errors);
    _validate44AE(data.goodsCarriageIncome44AE, errors);
    _validateOtherSourceIncome(data, errors);

    return List.unmodifiable(errors);
  }

  static void _validatePersonalInfo(
    Itr4FormData data,
    List<ValidationError> errors,
  ) {
    final pi = data.personalInfo;

    if (pi.firstName.trim().isEmpty) {
      errors.add(
        const ValidationError(
          field: 'firstName',
          message: 'First name is required',
          code: 'REQUIRED',
        ),
      );
    }

    if (pi.lastName.trim().isEmpty) {
      errors.add(
        const ValidationError(
          field: 'lastName',
          message: 'Last name is required',
          code: 'REQUIRED',
        ),
      );
    }

    final panError = FilingValidators.validatePan(pi.pan);
    if (panError != null) {
      errors.add(
        ValidationError(field: 'pan', message: panError, code: 'INVALID_PAN'),
      );
    }

    final aadhaarError = FilingValidators.validateAadhaar(pi.aadhaarNumber);
    if (aadhaarError != null) {
      errors.add(
        ValidationError(
          field: 'aadhaarNumber',
          message: aadhaarError,
          code: 'INVALID_AADHAAR',
        ),
      );
    }

    final mobileError = FilingValidators.validateMobile(pi.mobile);
    if (mobileError != null) {
      errors.add(
        ValidationError(
          field: 'mobile',
          message: mobileError,
          code: 'INVALID_MOBILE',
        ),
      );
    }

    final emailError = FilingValidators.validateEmail(pi.email);
    if (emailError != null) {
      errors.add(
        ValidationError(
          field: 'email',
          message: emailError,
          code: 'INVALID_EMAIL',
        ),
      );
    }

    final ifscError = FilingValidators.validateIfsc(pi.bankIfsc);
    if (ifscError != null) {
      errors.add(
        ValidationError(
          field: 'bankIfsc',
          message: ifscError,
          code: 'INVALID_IFSC',
        ),
      );
    }

    final pincodeError = FilingValidators.validatePincode(pi.pincode);
    if (pincodeError != null) {
      errors.add(
        ValidationError(
          field: 'pincode',
          message: pincodeError,
          code: 'INVALID_PINCODE',
        ),
      );
    }
  }

  static void _validateAtLeastOneIncomeSource(
    Itr4FormData data,
    List<ValidationError> errors,
  ) {
    final has44AD = data.businessIncome44AD.turnover > 0;
    final has44ADA = data.professionIncome44ADA.grossReceipts > 0;
    final has44AE = data.goodsCarriageIncome44AE.numberOfVehicles > 0;

    if (!has44AD && !has44ADA && !has44AE) {
      errors.add(
        const ValidationError(
          field: 'incomeSource',
          message:
              'At least one presumptive income source (44AD, 44ADA, or 44AE) '
              'is required for ITR-4.',
          code: 'NO_PRESUMPTIVE_INCOME',
        ),
      );
    }
  }

  static void _validate44AD(
    BusinessIncome44AD income,
    List<ValidationError> errors,
  ) {
    if (income.turnover <= 0) return; // not applicable

    if (income.turnover > BusinessIncome44AD.maxTurnover) {
      errors.add(
        ValidationError(
          field: 'turnover44AD',
          message:
              'Turnover exceeds the Section 44AD limit of '
              '₹${_formatAmount(BusinessIncome44AD.maxTurnover)}. '
              'Use ITR-3 instead.',
          code: 'TURNOVER_EXCEEDS_44AD_LIMIT',
        ),
      );
    }

    if (income.cashTurnover < 0) {
      errors.add(
        const ValidationError(
          field: 'cashTurnover',
          message: 'Cash turnover cannot be negative.',
          code: 'NEGATIVE_TURNOVER',
        ),
      );
    }

    if (income.nonCashTurnover < 0) {
      errors.add(
        const ValidationError(
          field: 'nonCashTurnover',
          message: 'Non-cash turnover cannot be negative.',
          code: 'NEGATIVE_TURNOVER',
        ),
      );
    }

    if (income.natureOfBusiness.trim().isEmpty) {
      errors.add(
        const ValidationError(
          field: 'natureOfBusiness',
          message: 'Nature of business is required when claiming 44AD.',
          code: 'REQUIRED',
        ),
      );
    }
  }

  static void _validate44ADA(
    ProfessionIncome44ADA income,
    List<ValidationError> errors,
  ) {
    if (income.grossReceipts <= 0) return; // not applicable

    if (income.grossReceipts > ProfessionIncome44ADA.maxGrossReceipts) {
      errors.add(
        ValidationError(
          field: 'grossReceipts44ADA',
          message:
              'Gross receipts exceed the Section 44ADA limit of '
              '₹${_formatAmount(ProfessionIncome44ADA.maxGrossReceipts)}. '
              'Use ITR-3 instead.',
          code: 'RECEIPTS_EXCEED_44ADA_LIMIT',
        ),
      );
    }

    if (income.grossReceipts < 0) {
      errors.add(
        const ValidationError(
          field: 'grossReceipts44ADA',
          message: 'Gross receipts cannot be negative.',
          code: 'NEGATIVE_RECEIPTS',
        ),
      );
    }

    if (income.natureOfProfession.trim().isEmpty) {
      errors.add(
        const ValidationError(
          field: 'natureOfProfession',
          message: 'Nature of profession is required when claiming 44ADA.',
          code: 'REQUIRED',
        ),
      );
    }
  }

  static void _validate44AE(
    GoodsCarriageIncome44AE income,
    List<ValidationError> errors,
  ) {
    if (income.numberOfVehicles <= 0) return; // not applicable

    if (income.numberOfVehicles > GoodsCarriageIncome44AE.maxVehicles) {
      errors.add(
        const ValidationError(
          field: 'numberOfVehicles',
          message:
              'Number of vehicles exceeds the Section 44AE limit of '
              '${GoodsCarriageIncome44AE.maxVehicles}. Use ITR-3 instead.',
          code: 'VEHICLES_EXCEED_44AE_LIMIT',
        ),
      );
    }

    if (income.monthsOperatedPerVehicle.length != income.numberOfVehicles) {
      errors.add(
        const ValidationError(
          field: 'monthsOperatedPerVehicle',
          message: 'Months operated must be specified for each vehicle.',
          code: 'MONTHS_VEHICLE_MISMATCH',
        ),
      );
    }

    for (int i = 0; i < income.monthsOperatedPerVehicle.length; i++) {
      final months = income.monthsOperatedPerVehicle[i];
      if (months < 1 || months > 12) {
        errors.add(
          ValidationError(
            field: 'monthsOperatedPerVehicle[$i]',
            message:
                'Months operated for vehicle ${i + 1} must be between 1 and 12.',
            code: 'INVALID_MONTHS',
          ),
        );
      }
    }
  }

  static void _validateOtherSourceIncome(
    Itr4FormData data,
    List<ValidationError> errors,
  ) {
    final os = data.otherSourceIncome;

    if (os.savingsAccountInterest < 0 ||
        os.fixedDepositInterest < 0 ||
        os.dividendIncome < 0) {
      errors.add(
        const ValidationError(
          field: 'otherSourceIncome',
          message: 'Income from other sources cannot be negative.',
          code: 'NEGATIVE_OTHER_INCOME',
        ),
      );
    }
  }

  /// Format a numeric amount for display in error messages.
  static String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(0)} crore';
    }
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(0)} lakhs';
    }
    return amount.toStringAsFixed(0);
  }
}
