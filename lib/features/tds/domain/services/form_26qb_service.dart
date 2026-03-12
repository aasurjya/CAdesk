import 'package:ca_app/features/tds/domain/models/tds_26qb.dart';
import 'package:flutter/foundation.dart';

/// Result of a Form 26QB TDS computation.
@immutable
class Form26QBComputationResult {
  const Form26QBComputationResult({
    required this.propertyValue,
    required this.tdsRate,
    required this.tdsAmount,
    required this.isLiable,
  });

  final double propertyValue;
  final double tdsRate;
  final double tdsAmount;
  final bool isLiable;

  @override
  String toString() =>
      'Form26QBComputationResult(property: $propertyValue, '
      'rate: $tdsRate%, tds: $tdsAmount, liable: $isLiable)';
}

/// Static service for Form 26QB (TDS on property purchase) operations.
///
/// Section 194IA: Buyer must deduct TDS at 1% when purchasing immovable
/// property from a resident for consideration > ₹50 lakhs.
class Form26QBService {
  Form26QBService._();

  static const double _tdsRate = 1.0;
  static const double _thresholdAmount = 5000000.0; // ₹50 lakhs

  // PAN: 5 uppercase alpha + 4 digits + 1 uppercase alpha
  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  // ---------------------------------------------------------------------------
  // TDS Computation
  // ---------------------------------------------------------------------------

  /// Computes TDS for a property purchase.
  ///
  /// [propertyValue] is the total consideration paid.
  /// [numberOfBuyers] defaults to 1; TDS applies on total value regardless.
  ///
  /// Returns a [Form26QBComputationResult] with zero TDS when [propertyValue]
  /// is at or below the ₹50 lakh threshold.
  static Form26QBComputationResult computeTds({
    required double propertyValue,
    int numberOfBuyers = 1,
  }) {
    final isLiable = propertyValue > _thresholdAmount;
    if (!isLiable) {
      return Form26QBComputationResult(
        propertyValue: propertyValue,
        tdsRate: _tdsRate,
        tdsAmount: 0.0,
        isLiable: false,
      );
    }

    final tdsAmount = propertyValue * _tdsRate / 100.0;
    return Form26QBComputationResult(
      propertyValue: propertyValue,
      tdsRate: _tdsRate,
      tdsAmount: tdsAmount,
      isLiable: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Validates a [Tds26QB] form and returns a list of error messages.
  ///
  /// An empty list indicates a valid form.
  static List<String> validate(Tds26QB form) {
    final errors = <String>[];

    if (!_panPattern.hasMatch(form.buyerPan)) {
      errors.add('Invalid buyer PAN format: ${form.buyerPan}');
    }
    if (!_panPattern.hasMatch(form.sellerPan)) {
      errors.add('Invalid seller PAN format: ${form.sellerPan}');
    }

    // When property is below threshold, TDS should be zero.
    if (!form.isAboveThreshold && form.tdsAmount > 0) {
      errors.add(
        'Property value ${form.propertyValue} is at or below the '
        '₹50 lakh threshold; TDS should not be deducted',
      );
    }

    // When property is above threshold, verify TDS amount matches 1%.
    if (form.isAboveThreshold) {
      final expectedTds = form.propertyValue * _tdsRate / 100.0;
      const tolerance = 1.0; // ₹1 tolerance for rounding
      if ((form.tdsAmount - expectedTds).abs() > tolerance) {
        errors.add(
          'TDS amount ${form.tdsAmount} does not match expected '
          '${expectedTds.toStringAsFixed(2)} (1% of ${form.propertyValue})',
        );
      }
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Numbering
  // ---------------------------------------------------------------------------

  /// Generates a 26QB acknowledgement number.
  ///
  /// Format: 26QB + YYYYYYY (FY compact) + NNN
  /// Example: "26QB202526042" for FY 2025-26, sequence 42.
  static String generateAcknowledgementNumber({
    required String financialYear,
    required int sequenceNumber,
  }) {
    // "2025-26" → "202526"
    final fyCompact = financialYear.replaceAll('-', '');
    final seq = sequenceNumber.toString().padLeft(3, '0');
    return '26QB$fyCompact$seq';
  }
}
