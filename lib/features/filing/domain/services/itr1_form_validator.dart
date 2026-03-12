import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/validation_error.dart';
import 'package:ca_app/features/filing/domain/services/filing_validators.dart';

/// Validates complete ITR-1 (Sahaj) form data before export/filing.
///
/// Checks eligibility conditions, required fields, and business rules.
class Itr1FormValidator {
  Itr1FormValidator._();

  /// Maximum gross total income allowed for ITR-1 eligibility.
  static const double maxGrossIncomeForItr1 = 5000000; // ₹50 lakhs

  /// Maximum interest deduction for self-occupied property.
  static const double maxSelfOccupiedInterest = 200000; // ₹2 lakhs

  /// Validate the complete ITR-1 form data.
  ///
  /// Returns an empty list if the form is valid.
  static List<ValidationError> validate(Itr1FormData data) {
    final errors = <ValidationError>[];

    _validatePersonalInfo(data, errors);
    _validateEligibility(data, errors);
    _validateHouseProperty(data, errors);
    _validateIncomeSources(data, errors);

    return List.unmodifiable(errors);
  }

  static void _validatePersonalInfo(
    Itr1FormData data,
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

    final tanError = FilingValidators.validateTan(pi.employerTan);
    if (tanError != null) {
      errors.add(
        ValidationError(
          field: 'employerTan',
          message: tanError,
          code: 'INVALID_TAN',
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

  static void _validateEligibility(
    Itr1FormData data,
    List<ValidationError> errors,
  ) {
    if (data.grossTotalIncome > maxGrossIncomeForItr1) {
      errors.add(
        ValidationError(
          field: 'grossTotalIncome',
          message:
              'Gross total income exceeds ₹50 lakhs. '
              'ITR-1 is not applicable — use ITR-2 or ITR-3.',
          code: 'ITR1_INCOME_LIMIT',
        ),
      );
    }
  }

  static void _validateHouseProperty(
    Itr1FormData data,
    List<ValidationError> errors,
  ) {
    final hp = data.housePropertyIncome;

    // For self-occupied property (annualLetableValue == 0),
    // interest deduction is capped at ₹2,00,000.
    if (hp.annualLetableValue == 0 &&
        hp.interestOnLoan > maxSelfOccupiedInterest) {
      errors.add(
        const ValidationError(
          field: 'interestOnLoan',
          message:
              'Interest on housing loan for self-occupied property '
              'is capped at ₹2,00,000 under Section 24(b).',
          code: 'SELF_OCCUPIED_INTEREST_CAP',
        ),
      );
    }

    if (hp.municipalTaxesPaid > hp.annualLetableValue &&
        hp.annualLetableValue > 0) {
      errors.add(
        const ValidationError(
          field: 'municipalTaxesPaid',
          message: 'Municipal taxes paid cannot exceed annual letable value.',
          code: 'MUNICIPAL_TAX_EXCEEDS_ALV',
        ),
      );
    }
  }

  static void _validateIncomeSources(
    Itr1FormData data,
    List<ValidationError> errors,
  ) {
    if (data.salaryIncome.grossSalary < 0) {
      errors.add(
        const ValidationError(
          field: 'grossSalary',
          message: 'Gross salary cannot be negative.',
          code: 'NEGATIVE_SALARY',
        ),
      );
    }

    if (data.otherSourceIncome.savingsAccountInterest < 0 ||
        data.otherSourceIncome.fixedDepositInterest < 0 ||
        data.otherSourceIncome.dividendIncome < 0) {
      errors.add(
        const ValidationError(
          field: 'otherSourceIncome',
          message: 'Income from other sources cannot be negative.',
          code: 'NEGATIVE_OTHER_INCOME',
        ),
      );
    }
  }
}
