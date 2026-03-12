import 'package:flutter/foundation.dart';

/// Type of entity receiving a payment subject to TDS deduction.
enum DeducteeType {
  individual(label: 'Individual'),
  huf(label: 'HUF'),
  company(label: 'Company'),
  firm(label: 'Firm'),
  aop(label: 'AOP/BOI'),
  trust(label: 'Trust'),
  government(label: 'Government'),
  other(label: 'Other');

  const DeducteeType({required this.label});
  final String label;
}

/// Immutable model representing the TDS rate for a specific section.
@immutable
class TdsSectionRate {
  const TdsSectionRate({
    required this.section,
    required this.subSection,
    required this.description,
    required this.rateIndividualHuf,
    required this.rateOthers,
    required this.rateNoPan,
    required this.thresholdSingle,
    required this.thresholdAggregate,
    required this.financialYear,
    required this.notes,
  });

  /// Section code, e.g. "194C".
  final String section;

  /// Sub-section code, e.g. "194J(a)" or empty string.
  final String subSection;

  /// Human-readable description of the section.
  final String description;

  /// TDS rate (%) for Individual / HUF deductees.
  final double rateIndividualHuf;

  /// TDS rate (%) for Company / Firm / AOP / Other deductees.
  final double rateOthers;

  /// TDS rate (%) when deductee does not have a PAN.
  final double rateNoPan;

  /// Single-transaction threshold amount.
  final double thresholdSingle;

  /// Annual aggregate threshold amount.
  final double thresholdAggregate;

  /// Financial year this rate applies to, e.g. "2025-26".
  final String financialYear;

  /// Special conditions or notes.
  final String notes;

  TdsSectionRate copyWith({
    String? section,
    String? subSection,
    String? description,
    double? rateIndividualHuf,
    double? rateOthers,
    double? rateNoPan,
    double? thresholdSingle,
    double? thresholdAggregate,
    String? financialYear,
    String? notes,
  }) {
    return TdsSectionRate(
      section: section ?? this.section,
      subSection: subSection ?? this.subSection,
      description: description ?? this.description,
      rateIndividualHuf: rateIndividualHuf ?? this.rateIndividualHuf,
      rateOthers: rateOthers ?? this.rateOthers,
      rateNoPan: rateNoPan ?? this.rateNoPan,
      thresholdSingle: thresholdSingle ?? this.thresholdSingle,
      thresholdAggregate: thresholdAggregate ?? this.thresholdAggregate,
      financialYear: financialYear ?? this.financialYear,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsSectionRate &&
          runtimeType == other.runtimeType &&
          section == other.section &&
          subSection == other.subSection &&
          description == other.description &&
          rateIndividualHuf == other.rateIndividualHuf &&
          rateOthers == other.rateOthers &&
          rateNoPan == other.rateNoPan &&
          thresholdSingle == other.thresholdSingle &&
          thresholdAggregate == other.thresholdAggregate &&
          financialYear == other.financialYear &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
    section,
    subSection,
    description,
    rateIndividualHuf,
    rateOthers,
    rateNoPan,
    thresholdSingle,
    thresholdAggregate,
    financialYear,
    notes,
  );

  @override
  String toString() =>
      'TdsSectionRate(section: $section, description: $description, '
      'indHuf: $rateIndividualHuf%, others: $rateOthers%)';
}

/// Immutable result of a TDS computation for a single payment.
@immutable
class TdsComputationResult {
  const TdsComputationResult({
    required this.section,
    required this.grossAmount,
    required this.tdsRate,
    required this.tdsAmount,
    required this.surcharge,
    required this.educationCess,
    required this.totalTds,
    required this.thresholdApplied,
  });

  /// Section under which TDS is computed.
  final String section;

  /// Gross payment amount.
  final double grossAmount;

  /// Applicable TDS rate (%).
  final double tdsRate;

  /// Base TDS amount (grossAmount * tdsRate / 100).
  final double tdsAmount;

  /// Surcharge amount, if applicable.
  final double surcharge;

  /// Health & Education Cess (4% of TDS + surcharge for NRI).
  final double educationCess;

  /// Total TDS = tdsAmount + surcharge + educationCess.
  final double totalTds;

  /// Whether a threshold exemption was applied (amount below threshold).
  final bool thresholdApplied;

  TdsComputationResult copyWith({
    String? section,
    double? grossAmount,
    double? tdsRate,
    double? tdsAmount,
    double? surcharge,
    double? educationCess,
    double? totalTds,
    bool? thresholdApplied,
  }) {
    return TdsComputationResult(
      section: section ?? this.section,
      grossAmount: grossAmount ?? this.grossAmount,
      tdsRate: tdsRate ?? this.tdsRate,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      surcharge: surcharge ?? this.surcharge,
      educationCess: educationCess ?? this.educationCess,
      totalTds: totalTds ?? this.totalTds,
      thresholdApplied: thresholdApplied ?? this.thresholdApplied,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsComputationResult &&
          runtimeType == other.runtimeType &&
          section == other.section &&
          grossAmount == other.grossAmount &&
          tdsRate == other.tdsRate &&
          tdsAmount == other.tdsAmount &&
          surcharge == other.surcharge &&
          educationCess == other.educationCess &&
          totalTds == other.totalTds &&
          thresholdApplied == other.thresholdApplied;

  @override
  int get hashCode => Object.hash(
    section,
    grossAmount,
    tdsRate,
    tdsAmount,
    surcharge,
    educationCess,
    totalTds,
    thresholdApplied,
  );

  @override
  String toString() =>
      'TdsComputationResult(section: $section, gross: $grossAmount, '
      'rate: $tdsRate%, total: $totalTds)';
}
