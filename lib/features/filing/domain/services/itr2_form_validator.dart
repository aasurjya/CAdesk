import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/validation_error.dart';
import 'package:ca_app/features/filing/domain/services/filing_validators.dart';

/// Validates complete ITR-2 form data before export/filing.
///
/// Checks eligibility conditions, required personal info fields,
/// capital gains set-off validity, and Schedule AL requirements.
class Itr2FormValidator {
  Itr2FormValidator._();

  /// Validate the complete ITR-2 form data.
  ///
  /// Returns an empty list if the form is valid.
  static List<ValidationError> validate(Itr2FormData data) {
    final errors = <ValidationError>[];

    _validatePersonalInfo(data, errors);
    _validateCapitalGains(data, errors);
    _validateScheduleAl(data, errors);

    return List.unmodifiable(errors);
  }

  static void _validatePersonalInfo(
    Itr2FormData data,
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

  static void _validateCapitalGains(
    Itr2FormData data,
    List<ValidationError> errors,
  ) {
    final cg = data.scheduleCg;

    if (cg.broughtForwardStcl < 0) {
      errors.add(
        const ValidationError(
          field: 'broughtForwardStcl',
          message:
              'Brought-forward short-term capital loss cannot be negative. '
              'Enter the absolute value of the loss.',
          code: 'NEGATIVE_SETOFF',
        ),
      );
    }

    if (cg.broughtForwardLtcl < 0) {
      errors.add(
        const ValidationError(
          field: 'broughtForwardLtcl',
          message:
              'Brought-forward long-term capital loss cannot be negative. '
              'Enter the absolute value of the loss.',
          code: 'NEGATIVE_SETOFF',
        ),
      );
    }

    for (final entry in cg.equityStcgEntries) {
      if (entry.salePrice < 0) {
        errors.add(
          ValidationError(
            field: 'equityStcgEntries',
            message:
                'Sale price for "${entry.description}" cannot be negative.',
            code: 'NEGATIVE_SALE_PRICE',
          ),
        );
      }
    }

    for (final entry in cg.propertyLtcgEntries) {
      if (entry.salePrice < 0) {
        errors.add(
          ValidationError(
            field: 'propertyLtcgEntries',
            message:
                'Sale price for "${entry.description}" cannot be negative.',
            code: 'NEGATIVE_SALE_PRICE',
          ),
        );
      }
      if (entry.indexedCostOfAcquisition < 0) {
        errors.add(
          ValidationError(
            field: 'propertyLtcgEntries',
            message:
                'Indexed cost of acquisition for "${entry.description}" '
                'cannot be negative.',
            code: 'NEGATIVE_INDEXED_COST',
          ),
        );
      }
    }
  }

  static void _validateScheduleAl(
    Itr2FormData data,
    List<ValidationError> errors,
  ) {
    if (data.requiresScheduleAL && data.scheduleAl == null) {
      errors.add(
        ValidationError(
          field: 'scheduleAl',
          message:
              'Schedule AL (Assets and Liabilities) is mandatory when total '
              'income exceeds ₹50,00,000. '
              'Reported income: ₹${data.grossTotalIncome.toStringAsFixed(0)}.',
          code: 'SCHEDULE_AL_REQUIRED',
        ),
      );
    }
  }
}
