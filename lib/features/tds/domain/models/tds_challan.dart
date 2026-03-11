import 'package:flutter/foundation.dart';

/// TDS challan payment record (Form 26QB / 26QC / ITNS 281).
///
/// A challan represents a single TDS payment deposited at a bank branch.
/// Each challan is linked to a deductor and covers a specific section and month.
@immutable
class TdsChallan {
  const TdsChallan({
    required this.id,
    required this.deductorId,
    required this.challanNumber,
    required this.bsrCode,
    required this.section,
    required this.deducteeCount,
    required this.tdsAmount,
    required this.surcharge,
    required this.educationCess,
    required this.interest,
    required this.penalty,
    required this.totalAmount,
    required this.paymentDate,
    required this.month,
    required this.financialYear,
    required this.status,
  });

  /// Unique record identifier.
  final String id;

  /// Linked deductor ID.
  final String deductorId;

  /// Challan serial number, e.g. "ITNS281-2025-0234".
  final String challanNumber;

  /// Bank branch BSR code, e.g. "0002390".
  final String bsrCode;

  /// TDS section under which deduction was made, e.g. "192", "194J".
  final String section;

  /// Number of deductees covered in this challan.
  final int deducteeCount;

  /// Base TDS amount deposited.
  final double tdsAmount;

  /// Surcharge, if applicable.
  final double surcharge;

  /// Education cess (4% of TDS + surcharge).
  final double educationCess;

  /// Interest charged for late deduction / late deposit.
  final double interest;

  /// Penalty levied, if any.
  final double penalty;

  /// Grand total deposited (tdsAmount + surcharge + educationCess + interest + penalty).
  final double totalAmount;

  /// Human-readable payment date, e.g. "07 Mar 2026".
  final String paymentDate;

  /// Calendar month (1 = January … 12 = December).
  final int month;

  /// Financial year string, e.g. "2025-26".
  final String financialYear;

  /// Payment status: "Paid", "Overdue", "Due", or "Partial".
  final String status;

  // ---------------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------------

  /// Human-readable description for the TDS section.
  String get sectionDescription {
    const descriptions = <String, String>{
      '192': 'Salary',
      '194A': 'Interest (non-bank)',
      '194B': 'Lottery / winnings',
      '194C': 'Contractor payments',
      '194D': 'Insurance commission',
      '194H': 'Commission / brokerage',
      '194I': 'Rent',
      '194J': 'Professional / technical fees',
      '194N': 'Cash withdrawal',
      '194Q': 'Purchase of goods',
      '195': 'Non-resident payments',
    };
    return descriptions[section] ?? section;
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  TdsChallan copyWith({
    String? id,
    String? deductorId,
    String? challanNumber,
    String? bsrCode,
    String? section,
    int? deducteeCount,
    double? tdsAmount,
    double? surcharge,
    double? educationCess,
    double? interest,
    double? penalty,
    double? totalAmount,
    String? paymentDate,
    int? month,
    String? financialYear,
    String? status,
  }) {
    return TdsChallan(
      id: id ?? this.id,
      deductorId: deductorId ?? this.deductorId,
      challanNumber: challanNumber ?? this.challanNumber,
      bsrCode: bsrCode ?? this.bsrCode,
      section: section ?? this.section,
      deducteeCount: deducteeCount ?? this.deducteeCount,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      surcharge: surcharge ?? this.surcharge,
      educationCess: educationCess ?? this.educationCess,
      interest: interest ?? this.interest,
      penalty: penalty ?? this.penalty,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      month: month ?? this.month,
      financialYear: financialYear ?? this.financialYear,
      status: status ?? this.status,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsChallan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deductorId == other.deductorId &&
          challanNumber == other.challanNumber &&
          bsrCode == other.bsrCode &&
          section == other.section &&
          deducteeCount == other.deducteeCount &&
          tdsAmount == other.tdsAmount &&
          surcharge == other.surcharge &&
          educationCess == other.educationCess &&
          interest == other.interest &&
          penalty == other.penalty &&
          totalAmount == other.totalAmount &&
          paymentDate == other.paymentDate &&
          month == other.month &&
          financialYear == other.financialYear &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        deductorId,
        challanNumber,
        bsrCode,
        section,
        deducteeCount,
        tdsAmount,
        surcharge,
        educationCess,
        interest,
        penalty,
        totalAmount,
        paymentDate,
        month,
        financialYear,
        status,
      );

  @override
  String toString() =>
      'TdsChallan(id: $id, challan: $challanNumber, section: $section, '
      'status: $status, total: $totalAmount)';
}
