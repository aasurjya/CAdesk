import 'package:flutter/foundation.dart';

/// FVU deductee type code: Company (1) or Non-company (2).
enum FvuDeducteeTypeCode {
  company(code: '1'),
  nonCompany(code: '2');

  const FvuDeducteeTypeCode({required this.code});

  /// Single-character code used in the FVU DD record.
  final String code;
}

/// Immutable model representing a Deductee Detail (DD) record in an FVU file.
///
/// Each DD record represents one deductee's payment and TDS deduction within
/// a challan period.
@immutable
class FvuDeducteeRecord {
  const FvuDeducteeRecord({
    required this.pan,
    required this.deducteeName,
    required this.amountPaid,
    required this.tdsAmount,
    required this.dateOfPayment,
    required this.sectionCode,
    required this.deducteeTypeCode,
  });

  /// PAN of the deductee (10 chars). Use 'PANNOTAVBL' when PAN is unavailable.
  final String pan;

  /// Name of the deductee (up to 40 chars).
  final String deducteeName;

  /// Amount paid / credited to the deductee (in rupees).
  final double amountPaid;

  /// TDS amount deducted (in rupees).
  final double tdsAmount;

  /// Date of payment in DDMMYYYY format.
  final String dateOfPayment;

  /// TDS section code, e.g. "194C", "192".
  final String sectionCode;

  /// Whether the deductee is a company or non-company entity.
  final FvuDeducteeTypeCode deducteeTypeCode;

  // ---------------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------------

  /// Returns true when the deductee has a valid PAN on record.
  bool get hasPan => pan != 'PANNOTAVBL';

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  FvuDeducteeRecord copyWith({
    String? pan,
    String? deducteeName,
    double? amountPaid,
    double? tdsAmount,
    String? dateOfPayment,
    String? sectionCode,
    FvuDeducteeTypeCode? deducteeTypeCode,
  }) {
    return FvuDeducteeRecord(
      pan: pan ?? this.pan,
      deducteeName: deducteeName ?? this.deducteeName,
      amountPaid: amountPaid ?? this.amountPaid,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      dateOfPayment: dateOfPayment ?? this.dateOfPayment,
      sectionCode: sectionCode ?? this.sectionCode,
      deducteeTypeCode: deducteeTypeCode ?? this.deducteeTypeCode,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FvuDeducteeRecord &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          deducteeName == other.deducteeName &&
          amountPaid == other.amountPaid &&
          tdsAmount == other.tdsAmount &&
          dateOfPayment == other.dateOfPayment &&
          sectionCode == other.sectionCode &&
          deducteeTypeCode == other.deducteeTypeCode;

  @override
  int get hashCode => Object.hash(
    pan,
    deducteeName,
    amountPaid,
    tdsAmount,
    dateOfPayment,
    sectionCode,
    deducteeTypeCode,
  );

  @override
  String toString() =>
      'FvuDeducteeRecord(pan: $pan, section: $sectionCode, '
      'amountPaid: $amountPaid, tds: $tdsAmount)';
}
