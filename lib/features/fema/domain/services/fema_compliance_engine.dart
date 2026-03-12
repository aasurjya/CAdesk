import 'package:ca_app/features/fema/domain/models/fc_gpr.dart';

/// Validation error from FEMA compliance checks.
class ValidationError {
  const ValidationError({required this.field, required this.message});

  final String field;
  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationError &&
        other.field == field &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(field, message);
}

/// Engine for FEMA (Foreign Exchange Management Act) compliance checks.
///
/// Covers:
/// - FC-GPR (Foreign Currency - Gross Provisional Return) filing requirements
/// - FLA Return (Foreign Liabilities and Assets) deadline computation
/// - FDI pricing guideline compliance (Issue price must be >= FMV for equity)
class FemaComplianceEngine {
  FemaComplianceEngine._();

  static final FemaComplianceEngine instance = FemaComplianceEngine._();

  /// Computes the deadline for FC-GPR filing.
  ///
  /// FC-GPR must be filed within 30 days from [dateOfAllotment] of shares.
  DateTime computeFcGprDeadline(DateTime dateOfAllotment) {
    return dateOfAllotment.add(const Duration(days: 30));
  }

  /// Computes the FLA Return filing deadline for [year].
  ///
  /// Deadline is July 15 of [year].
  DateTime computeFlaDeadline(int year) {
    return DateTime(year, 7, 15);
  }

  /// Checks whether [form]'s issue price complies with FDI pricing guidelines.
  ///
  /// For equity instruments, the issue price to a foreign investor must be
  /// at or above the Fair Market Value (FMV) determined by a SEBI-registered
  /// merchant banker using DCF or other approved methodology.
  ///
  /// [fairMarketValue] is in units consistent with [form.issuePricePaise]
  /// (i.e., the FMV per share in paise as a double).
  ///
  /// Returns `true` if issue price >= FMV (compliant), `false` otherwise.
  bool checkPricingGuidelines(FcGpr form, double fairMarketValue) {
    final fmvPaise = fairMarketValue * 100; // convert Rs to paise if needed
    return form.issuePricePaise >= fmvPaise;
  }

  /// Validates the [form] and returns a list of [ValidationError]s.
  ///
  /// Returns an empty list if the form is valid.
  List<ValidationError> validateFcGpr(FcGpr form) {
    final errors = <ValidationError>[];

    if (form.entityName.trim().isEmpty) {
      errors.add(
        const ValidationError(
          field: 'entityName',
          message: 'Entity name must not be empty.',
        ),
      );
    }

    if (form.cin.trim().isEmpty) {
      errors.add(
        const ValidationError(field: 'cin', message: 'CIN must not be empty.'),
      );
    }

    if (form.sharesAllotted <= 0) {
      errors.add(
        const ValidationError(
          field: 'sharesAllotted',
          message: 'Number of shares allotted must be greater than zero.',
        ),
      );
    }

    if (form.foreignInvestorCountry.trim().isEmpty) {
      errors.add(
        const ValidationError(
          field: 'foreignInvestorCountry',
          message: 'Foreign investor country must not be empty.',
        ),
      );
    }

    if (form.issuePricePaise < form.faceValuePaise) {
      errors.add(
        const ValidationError(
          field: 'issuePricePaise',
          message: 'Issue price must not be below face value.',
        ),
      );
    }

    return errors;
  }
}
