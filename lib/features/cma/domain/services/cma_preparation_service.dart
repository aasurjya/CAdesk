import 'package:ca_app/features/cma/domain/models/cma_data.dart';
import 'package:ca_app/features/cma/domain/models/cma_operating_statement.dart';

/// A single validation failure returned by [CmaPreparationService.validateCmaData].
class ValidationError {
  const ValidationError({required this.field, required this.message});

  /// The field or data path that failed validation (e.g. `'pan'`).
  final String field;

  /// Human-readable description of the failure.
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

  @override
  String toString() => 'ValidationError($field: $message)';
}

/// Stateless singleton service responsible for CMA data preparation,
/// operating statement projection, and input validation.
///
/// This service is the primary entry point for constructing and validating
/// CMA packages before they are sent to the MPBF calculator or exported
/// in the bank-prescribed format.
class CmaPreparationService {
  CmaPreparationService._();

  /// Singleton access point.
  static final CmaPreparationService instance = CmaPreparationService._();

  // ── Projection ────────────────────────────────────────────────────────────

  /// Projects an operating statement forward by [growthRate] for [year].
  ///
  /// Every line item in [base] is scaled by `(1 + growthRate)` and the
  /// [year] field is updated. Results are truncated to whole paise.
  ///
  /// [growthRate] is a decimal fraction (e.g. 0.20 for 20% growth).
  CmaOperatingStatement projectOperatingStatement(
    CmaOperatingStatement base,
    double growthRate,
    int year,
  ) {
    final factor = 1.0 + growthRate;
    return CmaOperatingStatement(
      year: year,
      grossSales: (base.grossSales * factor).truncate(),
      returnsAndDiscounts: (base.returnsAndDiscounts * factor).truncate(),
      rawMaterials: (base.rawMaterials * factor).truncate(),
      wages: (base.wages * factor).truncate(),
      power: (base.power * factor).truncate(),
      storeItems: (base.storeItems * factor).truncate(),
      repairsAndMaintenance: (base.repairsAndMaintenance * factor).truncate(),
      otherManufacturing: (base.otherManufacturing * factor).truncate(),
      openingStock: (base.openingStock * factor).truncate(),
      closingStock: (base.closingStock * factor).truncate(),
      sellingExpenses: (base.sellingExpenses * factor).truncate(),
      adminExpenses: (base.adminExpenses * factor).truncate(),
      financialCharges: (base.financialCharges * factor).truncate(),
      depreciation: (base.depreciation * factor).truncate(),
      tax: (base.tax * factor).truncate(),
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────

  /// Validates a [CmaData] instance and returns all discovered errors.
  ///
  /// Returns an empty list when the data is valid.
  /// Checks performed:
  /// - Entity name is non-empty
  /// - PAN matches the 10-character alphanumeric pattern (AAAAA9999A)
  /// - At least one historical year is provided
  /// - At least one projection year is provided
  /// - Operating statements map is non-empty
  /// - Balance sheets map is non-empty
  List<ValidationError> validateCmaData(CmaData data) {
    final errors = <ValidationError>[];

    if (data.entityName.trim().isEmpty) {
      errors.add(
        const ValidationError(
          field: 'entityName',
          message: 'Entity name must not be empty',
        ),
      );
    }

    if (!_isValidPan(data.pan)) {
      errors.add(
        const ValidationError(
          field: 'pan',
          message:
              'PAN must be 10 characters in the format AAAAA9999A '
              '(5 letters, 4 digits, 1 letter)',
        ),
      );
    }

    if (data.historicalYears.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'historicalYears',
          message: 'At least one historical year is required',
        ),
      );
    }

    if (data.projectionYears.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'projectionYears',
          message: 'At least one projection year is required',
        ),
      );
    }

    if (data.operatingStatements.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'operatingStatements',
          message: 'At least one operating statement is required',
        ),
      );
    }

    if (data.balanceSheets.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'balanceSheets',
          message: 'At least one balance sheet is required',
        ),
      );
    }

    return List.unmodifiable(errors);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  bool _isValidPan(String pan) => _panPattern.hasMatch(pan);
}
