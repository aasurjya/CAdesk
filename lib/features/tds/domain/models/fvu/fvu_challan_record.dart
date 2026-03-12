import 'package:flutter/foundation.dart';

/// Immutable model representing a Challan Detail (CD) record in an FVU file.
///
/// Corresponds to a single TDS challan payment deposited at a bank branch.
@immutable
class FvuChallanRecord {
  const FvuChallanRecord({
    required this.bsrCode,
    required this.challanTenderDate,
    required this.challanSerialNumber,
    required this.totalTaxDeposited,
    required this.deducteeCount,
    required this.sectionCode,
  });

  /// Bank BSR code (7 digits).
  final String bsrCode;

  /// Challan tender date in DDMMYYYY format.
  final String challanTenderDate;

  /// Challan serial number (10 digits, zero-padded).
  final String challanSerialNumber;

  /// Total tax deposited via this challan (in rupees).
  final double totalTaxDeposited;

  /// Number of deductee entries covered by this challan.
  final int deducteeCount;

  /// TDS section code, e.g. "194C".
  final String sectionCode;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  FvuChallanRecord copyWith({
    String? bsrCode,
    String? challanTenderDate,
    String? challanSerialNumber,
    double? totalTaxDeposited,
    int? deducteeCount,
    String? sectionCode,
  }) {
    return FvuChallanRecord(
      bsrCode: bsrCode ?? this.bsrCode,
      challanTenderDate: challanTenderDate ?? this.challanTenderDate,
      challanSerialNumber: challanSerialNumber ?? this.challanSerialNumber,
      totalTaxDeposited: totalTaxDeposited ?? this.totalTaxDeposited,
      deducteeCount: deducteeCount ?? this.deducteeCount,
      sectionCode: sectionCode ?? this.sectionCode,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FvuChallanRecord &&
          runtimeType == other.runtimeType &&
          bsrCode == other.bsrCode &&
          challanTenderDate == other.challanTenderDate &&
          challanSerialNumber == other.challanSerialNumber &&
          totalTaxDeposited == other.totalTaxDeposited &&
          deducteeCount == other.deducteeCount &&
          sectionCode == other.sectionCode;

  @override
  int get hashCode => Object.hash(
    bsrCode,
    challanTenderDate,
    challanSerialNumber,
    totalTaxDeposited,
    deducteeCount,
    sectionCode,
  );

  @override
  String toString() =>
      'FvuChallanRecord(bsr: $bsrCode, date: $challanTenderDate, '
      'section: $sectionCode, deductees: $deducteeCount, '
      'taxDeposited: $totalTaxDeposited)';
}
