import 'package:flutter/material.dart';

/// Immutable model representing a client's VDA tax summary
/// for a given assessment year under Section 115BBH.
@immutable
class VdaSummary {
  const VdaSummary({
    required this.clientId,
    required this.clientName,
    required this.assessmentYear,
    required this.totalTransactions,
    required this.totalGains,
    required this.totalLosses,
    required this.netTaxableGain,
    required this.taxLiability,
    required this.tdsCollected,
    required this.tdsShortfall,
    required this.hasLossRestrictionViolation,
  });

  final String clientId;
  final String clientName;
  final String assessmentYear;
  final int totalTransactions;
  final double totalGains;
  final double totalLosses;
  final double netTaxableGain;
  final double taxLiability;
  final double tdsCollected;
  final double tdsShortfall;

  /// True if the client attempted to set off losses from one VDA
  /// against gains from another, which is not permitted under 115BBH.
  final bool hasLossRestrictionViolation;

  /// Returns a new [VdaSummary] with the given fields replaced.
  VdaSummary copyWith({
    String? clientId,
    String? clientName,
    String? assessmentYear,
    int? totalTransactions,
    double? totalGains,
    double? totalLosses,
    double? netTaxableGain,
    double? taxLiability,
    double? tdsCollected,
    double? tdsShortfall,
    bool? hasLossRestrictionViolation,
  }) {
    return VdaSummary(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalGains: totalGains ?? this.totalGains,
      totalLosses: totalLosses ?? this.totalLosses,
      netTaxableGain: netTaxableGain ?? this.netTaxableGain,
      taxLiability: taxLiability ?? this.taxLiability,
      tdsCollected: tdsCollected ?? this.tdsCollected,
      tdsShortfall: tdsShortfall ?? this.tdsShortfall,
      hasLossRestrictionViolation:
          hasLossRestrictionViolation ?? this.hasLossRestrictionViolation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VdaSummary &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          assessmentYear == other.assessmentYear &&
          totalTransactions == other.totalTransactions &&
          totalGains == other.totalGains &&
          totalLosses == other.totalLosses &&
          netTaxableGain == other.netTaxableGain &&
          taxLiability == other.taxLiability &&
          tdsCollected == other.tdsCollected &&
          tdsShortfall == other.tdsShortfall &&
          hasLossRestrictionViolation == other.hasLossRestrictionViolation;

  @override
  int get hashCode => Object.hash(
    clientId,
    assessmentYear,
    totalTransactions,
    totalGains,
    totalLosses,
    netTaxableGain,
    taxLiability,
    tdsCollected,
    tdsShortfall,
    hasLossRestrictionViolation,
  );

  @override
  String toString() =>
      'VdaSummary(client: $clientName, ay: $assessmentYear, '
      'taxLiability: $taxLiability)';
}
