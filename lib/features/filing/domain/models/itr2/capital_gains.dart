import 'package:flutter/foundation.dart';

/// Type of capital gain, mapped to Income Tax Act sections.
enum CapitalGainType {
  /// Short-term capital gain under Section 111A (equity with STT paid).
  stcg111A('STCG — s.111A'),

  /// Short-term capital gain on other assets.
  stcgOther('STCG — Other'),

  /// Long-term capital gain under Section 112A (equity with STT paid).
  ltcg112A('LTCG — s.112A'),

  /// Long-term capital gain under Section 112.
  ltcg112('LTCG — s.112'),

  /// Long-term capital gain on other assets.
  ltcgOther('LTCG — Other');

  const CapitalGainType(this.label);
  final String label;

  /// Whether this gain type is short-term.
  bool get isShortTerm =>
      this == CapitalGainType.stcg111A || this == CapitalGainType.stcgOther;

  /// Whether this gain type is long-term.
  bool get isLongTerm => !isShortTerm;
}

/// Immutable model for a single capital gain transaction.
class CapitalGainEntry {
  const CapitalGainEntry({
    required this.description,
    required this.salePrice,
    required this.purchasePrice,
    required this.expenses,
    required this.gainType,
    required this.holdingPeriodMonths,
  });

  /// Description of the asset sold.
  final String description;

  /// Sale / transfer consideration received.
  final double salePrice;

  /// Cost of acquisition.
  final double purchasePrice;

  /// Expenses incurred in connection with the transfer.
  final double expenses;

  /// Classification of the capital gain.
  final CapitalGainType gainType;

  /// Number of months the asset was held before transfer.
  final int holdingPeriodMonths;

  /// Net capital gain (or loss) on this transaction.
  double get gain => salePrice - purchasePrice - expenses;

  CapitalGainEntry copyWith({
    String? description,
    double? salePrice,
    double? purchasePrice,
    double? expenses,
    CapitalGainType? gainType,
    int? holdingPeriodMonths,
  }) {
    return CapitalGainEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      expenses: expenses ?? this.expenses,
      gainType: gainType ?? this.gainType,
      holdingPeriodMonths: holdingPeriodMonths ?? this.holdingPeriodMonths,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CapitalGainEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.purchasePrice == purchasePrice &&
        other.expenses == expenses &&
        other.gainType == gainType &&
        other.holdingPeriodMonths == holdingPeriodMonths;
  }

  @override
  int get hashCode => Object.hash(
    description,
    salePrice,
    purchasePrice,
    expenses,
    gainType,
    holdingPeriodMonths,
  );
}

/// Immutable summary of all capital gains for an ITR-2 / ITR-3 return.
class CapitalGainsSummary {
  const CapitalGainsSummary({required this.entries});

  /// All capital gain transactions.
  final List<CapitalGainEntry> entries;

  /// Total short-term capital gains (or losses).
  double get totalSTCG => entries
      .where((e) => e.gainType.isShortTerm)
      .fold(0.0, (sum, e) => sum + e.gain);

  /// Total long-term capital gains (or losses).
  double get totalLTCG => entries
      .where((e) => e.gainType.isLongTerm)
      .fold(0.0, (sum, e) => sum + e.gain);

  /// Net capital gains across all types.
  double get netCapitalGains => totalSTCG + totalLTCG;

  CapitalGainsSummary copyWith({List<CapitalGainEntry>? entries}) {
    return CapitalGainsSummary(entries: entries ?? this.entries);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CapitalGainsSummary && listEquals(other.entries, entries);
  }

  @override
  int get hashCode => Object.hashAll(entries);
}
