// ---------------------------------------------------------------------------
// Financial Ratio Calculator — pure static utility
// ---------------------------------------------------------------------------

/// Computes key financial ratios from balance sheet and P&L data.
class FinancialRatioCalculator {
  FinancialRatioCalculator._();

  /// Liquidity
  static double currentRatio(
    double currentAssets,
    double currentLiabilities,
  ) {
    if (currentLiabilities == 0) {
      return 0;
    }
    return currentAssets / currentLiabilities;
  }

  static double quickRatio(
    double currentAssets,
    double inventory,
    double currentLiabilities,
  ) {
    if (currentLiabilities == 0) {
      return 0;
    }
    return (currentAssets - inventory) / currentLiabilities;
  }

  /// Profitability
  static double grossMarginPercent(double revenue, double cogs) {
    if (revenue == 0) {
      return 0;
    }
    return (revenue - cogs) / revenue * 100;
  }

  static double netMarginPercent(double revenue, double netProfit) {
    if (revenue == 0) {
      return 0;
    }
    return netProfit / revenue * 100;
  }

  static double ebitdaMarginPercent(double revenue, double ebitda) {
    if (revenue == 0) {
      return 0;
    }
    return ebitda / revenue * 100;
  }

  static double returnOnEquity(double netProfit, double equity) {
    if (equity == 0) {
      return 0;
    }
    return netProfit / equity * 100;
  }

  static double returnOnAssets(double netProfit, double totalAssets) {
    if (totalAssets == 0) {
      return 0;
    }
    return netProfit / totalAssets * 100;
  }

  /// Leverage
  static double debtToEquity(double totalDebt, double equity) {
    if (equity == 0) {
      return 0;
    }
    return totalDebt / equity;
  }

  static double interestCoverageRatio(double ebit, double interestExpense) {
    if (interestExpense == 0) {
      return double.infinity;
    }
    return ebit / interestExpense;
  }

  /// Activity
  static double debtorDays(double tradeReceivables, double revenue) {
    if (revenue == 0) {
      return 0;
    }
    return tradeReceivables / revenue * 365;
  }

  static double creditorDays(double tradePayables, double cogs) {
    if (cogs == 0) {
      return 0;
    }
    return tradePayables / cogs * 365;
  }

  static double inventoryDays(double inventory, double cogs) {
    if (cogs == 0) {
      return 0;
    }
    return inventory / cogs * 365;
  }
}

// ---------------------------------------------------------------------------
// Depreciation Calculator — WDV method as per Income Tax Act
// ---------------------------------------------------------------------------

/// WDV (Written Down Value) depreciation as per the Income Tax Act.
class DepreciationCalculator {
  DepreciationCalculator._();

  /// Standard IT Act rates by asset block name.
  static const Map<String, double> rates = <String, double>{
    'Buildings (Residential)': 5.0,
    'Buildings (Non-Residential)': 10.0,
    'Plant & Machinery (General)': 15.0,
    'Plant & Machinery (Ships)': 20.0,
    'Computers & Software': 40.0,
    'Furniture & Fittings': 10.0,
    'Motor Vehicles (Cars)': 15.0,
    'Motor Vehicles (Heavy)': 30.0,
    'Intangibles (Patents/Know-how)': 25.0,
  };

  /// WDV method: depreciation = opening WDV * rate / 100.
  /// For additions during the year: half-year convention if added after Oct 3.
  static double annualDepreciation({
    required double openingWdv,
    required double additionsDuringYear,
    required double disposalsDuringYear,
    required double ratePercent,
    required bool isAdditionAfterOct3,
  }) {
    final effectiveAdditions =
        isAdditionAfterOct3 ? additionsDuringYear / 2 : additionsDuringYear;
    final netBlock = openingWdv + effectiveAdditions - disposalsDuringYear;
    if (netBlock <= 0) {
      return 0;
    }
    return netBlock * ratePercent / 100;
  }

  static double closingWdv({
    required double openingWdv,
    required double additions,
    required double disposals,
    required double depreciation,
  }) {
    return (openingWdv + additions - disposals - depreciation)
        .clamp(0, double.infinity);
  }
}
