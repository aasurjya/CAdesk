import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductee_entry.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:flutter/foundation.dart';

/// Immutable address model for a TDS deductor.
@immutable
class TdsAddress {
  const TdsAddress({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;

  TdsAddress copyWith({
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? pincode,
  }) {
    return TdsAddress(
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsAddress &&
          runtimeType == other.runtimeType &&
          line1 == other.line1 &&
          line2 == other.line2 &&
          city == other.city &&
          state == other.state &&
          pincode == other.pincode;

  @override
  int get hashCode => Object.hash(line1, line2, city, state, pincode);

  @override
  String toString() => 'TdsAddress(line1: $line1, city: $city, pin: $pincode)';
}

/// Immutable model representing a complete TDS return form with all
/// deductee entries, challans, and computed totals.
@immutable
class TdsReturnForm {
  const TdsReturnForm({
    required this.id,
    required this.formType,
    required this.quarter,
    required this.financialYear,
    required this.deductorTan,
    required this.deductorPan,
    required this.deductorName,
    required this.deductorAddress,
    required this.responsiblePerson,
    required this.entries,
    required this.challans,
    required this.status,
    this.filedDate,
    this.tokenNumber,
  });

  /// Unique record identifier.
  final String id;

  /// Form type (24Q, 26Q, 27Q, 27EQ).
  final TdsFormType formType;

  /// Quarter of the financial year.
  final TdsQuarter quarter;

  /// Financial year, e.g. "2025-26".
  final String financialYear;

  /// TAN of the deductor.
  final String deductorTan;

  /// PAN of the deductor.
  final String deductorPan;

  /// Name of the deductor.
  final String deductorName;

  /// Address of the deductor.
  final TdsAddress deductorAddress;

  /// Name of the responsible person.
  final String responsiblePerson;

  /// List of deductee entries in this return.
  final List<TdsDeducteeEntry> entries;

  /// List of challans linked to this return.
  final List<TdsChallan> challans;

  /// Filing status.
  final TdsReturnStatus status;

  /// Date when the return was filed, if applicable.
  final DateTime? filedDate;

  /// Token number received on filing.
  final String? tokenNumber;

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// Sum of TDS deducted across all entries.
  double get totalTdsDeducted =>
      entries.fold(0.0, (sum, e) => sum + e.tdsDeducted);

  /// Sum of TDS deposited across all entries.
  double get totalTdsDeposited =>
      entries.fold(0.0, (sum, e) => sum + e.tdsDeposited);

  /// Difference between deducted and deposited amounts.
  double get shortfall => totalTdsDeducted - totalTdsDeposited;

  /// Number of deductee entries.
  int get entryCount => entries.length;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  TdsReturnForm copyWith({
    String? id,
    TdsFormType? formType,
    TdsQuarter? quarter,
    String? financialYear,
    String? deductorTan,
    String? deductorPan,
    String? deductorName,
    TdsAddress? deductorAddress,
    String? responsiblePerson,
    List<TdsDeducteeEntry>? entries,
    List<TdsChallan>? challans,
    TdsReturnStatus? status,
    DateTime? filedDate,
    String? tokenNumber,
  }) {
    return TdsReturnForm(
      id: id ?? this.id,
      formType: formType ?? this.formType,
      quarter: quarter ?? this.quarter,
      financialYear: financialYear ?? this.financialYear,
      deductorTan: deductorTan ?? this.deductorTan,
      deductorPan: deductorPan ?? this.deductorPan,
      deductorName: deductorName ?? this.deductorName,
      deductorAddress: deductorAddress ?? this.deductorAddress,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      entries: entries ?? this.entries,
      challans: challans ?? this.challans,
      status: status ?? this.status,
      filedDate: filedDate ?? this.filedDate,
      tokenNumber: tokenNumber ?? this.tokenNumber,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality by id
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsReturnForm &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TdsReturnForm(id: $id, form: ${formType.label}, '
      'quarter: ${quarter.label}, fy: $financialYear, '
      'entries: $entryCount, status: ${status.label})';
}
