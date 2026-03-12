/// Immutable model for an investor entry in a funding round.
class InvestorEntry {
  const InvestorEntry({
    required this.investorName,
    required this.amountInvestedPaise,
    required this.equityPercentage,
  });

  final String investorName;

  /// Amount invested in paise.
  final int amountInvestedPaise;

  /// Equity percentage post-investment (post-money diluted stake).
  final double equityPercentage;

  InvestorEntry copyWith({
    String? investorName,
    int? amountInvestedPaise,
    double? equityPercentage,
  }) {
    return InvestorEntry(
      investorName: investorName ?? this.investorName,
      amountInvestedPaise: amountInvestedPaise ?? this.amountInvestedPaise,
      equityPercentage: equityPercentage ?? this.equityPercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestorEntry &&
        other.investorName == investorName &&
        other.amountInvestedPaise == amountInvestedPaise &&
        other.equityPercentage == equityPercentage;
  }

  @override
  int get hashCode =>
      Object.hash(investorName, amountInvestedPaise, equityPercentage);
}

/// Immutable model representing a single funding round.
class FundingRound {
  FundingRound({
    required this.roundName,
    required this.date,
    required this.preMoneyValuationPaise,
    required this.amountRaisedPaise,
    required this.investors,
  });

  final String roundName;
  final DateTime date;

  /// Pre-money valuation of the company before this round in paise.
  final int preMoneyValuationPaise;

  /// Total amount raised in this round in paise.
  final int amountRaisedPaise;

  final List<InvestorEntry> investors;

  /// Post-money valuation = pre-money + amount raised.
  int get postMoneyValuationPaise => preMoneyValuationPaise + amountRaisedPaise;

  FundingRound copyWith({
    String? roundName,
    DateTime? date,
    int? preMoneyValuationPaise,
    int? amountRaisedPaise,
    List<InvestorEntry>? investors,
  }) {
    return FundingRound(
      roundName: roundName ?? this.roundName,
      date: date ?? this.date,
      preMoneyValuationPaise:
          preMoneyValuationPaise ?? this.preMoneyValuationPaise,
      amountRaisedPaise: amountRaisedPaise ?? this.amountRaisedPaise,
      investors: investors ?? this.investors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FundingRound) return false;
    if (other.roundName != roundName) return false;
    if (other.date != date) return false;
    if (other.preMoneyValuationPaise != preMoneyValuationPaise) return false;
    if (other.amountRaisedPaise != amountRaisedPaise) return false;
    if (other.investors.length != investors.length) return false;
    for (var i = 0; i < investors.length; i++) {
      if (other.investors[i] != investors[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        roundName,
        date,
        preMoneyValuationPaise,
        amountRaisedPaise,
        Object.hashAll(investors),
      );
}
