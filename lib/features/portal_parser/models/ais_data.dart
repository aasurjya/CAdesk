import 'package:ca_app/features/portal_parser/models/ais_income_source.dart';
import 'package:flutter/foundation.dart';

/// Immutable aggregate model for all data parsed from AIS (Annual Information
/// Statement) or TIS (Taxpayer Information Summary).
///
/// All monetary amounts are stored in **paise** (1 rupee = 100 paise).
@immutable
class AisData {
  const AisData({
    required this.pan,
    required this.financialYear,
    required this.salarySources,
    required this.dividendSources,
    required this.interestSources,
    required this.capitalGainTransactions,
    required this.foreignRemittances,
  });

  /// PAN of the taxpayer.
  final String pan;

  /// Financial year in "YYYY-YY" format (e.g. "2023-24").
  final String financialYear;

  /// Salary income sources.
  final List<AisIncomeSource> salarySources;

  /// Dividend income sources.
  final List<AisIncomeSource> dividendSources;

  /// Interest income sources.
  final List<AisIncomeSource> interestSources;

  /// Capital gain transactions.
  final List<AisCapGainTransaction> capitalGainTransactions;

  /// Foreign remittances received.
  final List<AisForeignRemittance> foreignRemittances;

  AisData copyWith({
    String? pan,
    String? financialYear,
    List<AisIncomeSource>? salarySources,
    List<AisIncomeSource>? dividendSources,
    List<AisIncomeSource>? interestSources,
    List<AisCapGainTransaction>? capitalGainTransactions,
    List<AisForeignRemittance>? foreignRemittances,
  }) {
    return AisData(
      pan: pan ?? this.pan,
      financialYear: financialYear ?? this.financialYear,
      salarySources: salarySources ?? this.salarySources,
      dividendSources: dividendSources ?? this.dividendSources,
      interestSources: interestSources ?? this.interestSources,
      capitalGainTransactions:
          capitalGainTransactions ?? this.capitalGainTransactions,
      foreignRemittances: foreignRemittances ?? this.foreignRemittances,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisData &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          financialYear == other.financialYear &&
          salarySources == other.salarySources &&
          dividendSources == other.dividendSources &&
          interestSources == other.interestSources &&
          capitalGainTransactions == other.capitalGainTransactions &&
          foreignRemittances == other.foreignRemittances;

  @override
  int get hashCode => Object.hash(
    pan,
    financialYear,
    Object.hashAll(salarySources),
    Object.hashAll(dividendSources),
    Object.hashAll(interestSources),
    Object.hashAll(capitalGainTransactions),
    Object.hashAll(foreignRemittances),
  );

  @override
  String toString() =>
      'AisData(pan: $pan, fy: $financialYear, '
      'salary: ${salarySources.length}, interest: ${interestSources.length})';
}
