import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';
import 'package:flutter/foundation.dart';

/// Immutable model representing a single deductee entry in a TDS return.
@immutable
class TdsDeducteeEntry {
  const TdsDeducteeEntry({
    required this.id,
    required this.deducteeName,
    required this.deducteePan,
    required this.deducteeType,
    required this.section,
    required this.dateOfPayment,
    required this.dateOfDeduction,
    required this.amountPaid,
    required this.tdsDeducted,
    required this.tdsDeposited,
    this.challanId,
    this.certificateNumber,
    this.remarks,
  });

  /// Unique record identifier.
  final String id;

  /// Name of the deductee.
  final String deducteeName;

  /// PAN of the deductee.
  final String deducteePan;

  /// Type of deductee (individual, company, etc.).
  final DeducteeType deducteeType;

  /// TDS section code, e.g. "194C".
  final String section;

  /// Date when payment was made.
  final DateTime dateOfPayment;

  /// Date when TDS was deducted.
  final DateTime dateOfDeduction;

  /// Gross amount paid to the deductee.
  final double amountPaid;

  /// TDS amount deducted.
  final double tdsDeducted;

  /// TDS amount deposited with the government.
  final double tdsDeposited;

  /// Linked challan ID, if any.
  final String? challanId;

  /// TDS certificate number, if issued.
  final String? certificateNumber;

  /// Additional remarks.
  final String? remarks;

  TdsDeducteeEntry copyWith({
    String? id,
    String? deducteeName,
    String? deducteePan,
    DeducteeType? deducteeType,
    String? section,
    DateTime? dateOfPayment,
    DateTime? dateOfDeduction,
    double? amountPaid,
    double? tdsDeducted,
    double? tdsDeposited,
    String? challanId,
    String? certificateNumber,
    String? remarks,
  }) {
    return TdsDeducteeEntry(
      id: id ?? this.id,
      deducteeName: deducteeName ?? this.deducteeName,
      deducteePan: deducteePan ?? this.deducteePan,
      deducteeType: deducteeType ?? this.deducteeType,
      section: section ?? this.section,
      dateOfPayment: dateOfPayment ?? this.dateOfPayment,
      dateOfDeduction: dateOfDeduction ?? this.dateOfDeduction,
      amountPaid: amountPaid ?? this.amountPaid,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      tdsDeposited: tdsDeposited ?? this.tdsDeposited,
      challanId: challanId ?? this.challanId,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsDeducteeEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TdsDeducteeEntry(id: $id, name: $deducteeName, '
      'section: $section, tds: $tdsDeducted)';
}
