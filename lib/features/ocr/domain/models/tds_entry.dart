import 'package:flutter/foundation.dart';

/// Immutable TDS entry ready to be fed into a TDS return filing workflow.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
///
/// This model is a lightweight output type produced by [OcrDataMapperService]
/// from an [ExtractedForm16]. It mirrors the minimum fields needed for
/// Schedule TDS in ITR forms.
@immutable
class TdsEntry {
  const TdsEntry({
    required this.deducteePan,
    required this.deductorTan,
    required this.assessmentYear,
    required this.grossAmount,
    required this.tdsDeducted,
  });

  /// PAN of the deductee (employee).
  final String deducteePan;

  /// TAN of the deductor (employer).
  final String deductorTan;

  /// Assessment year (e.g. "2024-25").
  final String assessmentYear;

  /// Gross salary / payment in paise.
  final int grossAmount;

  /// TDS deducted in paise.
  final int tdsDeducted;

  TdsEntry copyWith({
    String? deducteePan,
    String? deductorTan,
    String? assessmentYear,
    int? grossAmount,
    int? tdsDeducted,
  }) {
    return TdsEntry(
      deducteePan: deducteePan ?? this.deducteePan,
      deductorTan: deductorTan ?? this.deductorTan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      grossAmount: grossAmount ?? this.grossAmount,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsEntry &&
          runtimeType == other.runtimeType &&
          deducteePan == other.deducteePan &&
          deductorTan == other.deductorTan &&
          assessmentYear == other.assessmentYear &&
          grossAmount == other.grossAmount &&
          tdsDeducted == other.tdsDeducted;

  @override
  int get hashCode => Object.hash(
        deducteePan,
        deductorTan,
        assessmentYear,
        grossAmount,
        tdsDeducted,
      );

  @override
  String toString() =>
      'TdsEntry(pan: $deducteePan, tan: $deductorTan, '
      'ay: $assessmentYear, gross: $grossAmount, tds: $tdsDeducted)';
}
