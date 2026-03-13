import 'package:ca_app/features/tax_advisory/domain/models/client_profile.dart';

// ---------------------------------------------------------------------------
// Supporting value objects
// ---------------------------------------------------------------------------

/// Result of comparing old vs new tax regime for a client.
class RegimeComparison {
  const RegimeComparison({
    required this.oldRegimeTax,
    required this.newRegimeTax,
    required this.recommendation,
    required this.savings,
  });

  /// Tax liability under old regime (paise).
  final int oldRegimeTax;

  /// Tax liability under new regime (paise, FY 2024-25 slabs).
  final int newRegimeTax;

  /// Human-readable recommendation (e.g. "Old regime saves ₹30K").
  final String recommendation;

  /// Absolute tax saving (|old - new|) in paise.
  final int savings;
}

/// A single equity / debt position for capital-gains harvesting analysis.
class CapGainPosition {
  const CapGainPosition({
    required this.symbol,
    required this.purchasePrice,
    required this.currentPrice,
    required this.quantity,
    required this.isLongTerm,
  });

  /// Ticker or instrument name.
  final String symbol;

  /// Purchase price per unit in paise.
  final int purchasePrice;

  /// Current market price per unit in paise.
  final int currentPrice;

  /// Number of units held.
  final int quantity;

  /// True if held for > 12 months (equity), else short-term.
  final bool isLongTerm;

  /// Unrealised gain/loss in paise (negative = loss).
  int get unrealisedPnl => (currentPrice - purchasePrice) * quantity;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Stateless singleton for precise tax saving calculations (FY 2024-25).
///
/// All monetary values are in **paise** (1 ₹ = 100 paise) throughout.
class TaxSavingCalculatorService {
  TaxSavingCalculatorService._();

  static final TaxSavingCalculatorService instance =
      TaxSavingCalculatorService._();

  // ---------------------------------------------------------------------------
  // Constants (paise)
  // ---------------------------------------------------------------------------

  static const int _section80cLimit = 15000000; // ₹1,50,000
  static const Set<String> _metroCities = {
    'Delhi',
    'Mumbai',
    'Chennai',
    'Kolkata',
  };

  // ---------------------------------------------------------------------------
  // 80C saving
  // ---------------------------------------------------------------------------

  /// Estimates tax saving from maximising Section 80C.
  ///
  /// Returns 0 if [regime] is new (80C not applicable) or if already maxed.
  int compute80cSaving({
    required int currentDeduction,
    required int taxableIncome,
    required TaxRegime regime,
  }) {
    if (regime == TaxRegime.newRegime) return 0;

    final gap = _section80cLimit - currentDeduction;
    if (gap <= 0) return 0;

    final marginalRate = _oldRegimeMarginalRate(taxableIncome);
    return (gap * marginalRate).round();
  }

  // ---------------------------------------------------------------------------
  // HRA saving
  // ---------------------------------------------------------------------------

  /// Calculates HRA exemption under Section 10(13A).
  ///
  /// Exemption = minimum of:
  ///   (a) HRA received
  ///   (b) Rent paid - 10% of basic salary
  ///   (c) 50% of basic (metro) or 40% of basic (non-metro)
  ///
  /// Returns 0 if [rentPaid] is 0 (no rent paid).
  int computeHraSaving({
    required int basicSalary,
    required int hraReceived,
    required int rentPaid,
    required String city,
  }) {
    if (rentPaid <= 0) return 0;

    final cityPct = _metroCities.contains(city) ? 0.50 : 0.40;

    final componentA = hraReceived;
    final componentB = rentPaid - (basicSalary * 0.10).round();
    final componentC = (basicSalary * cityPct).round();

    // If rent - 10% basic is negative the exemption is 0
    if (componentB <= 0) return 0;

    return [componentA, componentB, componentC].reduce((a, b) => a < b ? a : b);
  }

  // ---------------------------------------------------------------------------
  // Old vs New regime comparison
  // ---------------------------------------------------------------------------

  /// Computes tax under both regimes and recommends the better one.
  RegimeComparison computeOldVsNewRegime(ClientProfile profile) {
    final oldTax = _computeOldRegimeTax(
      income: profile.annualIncome,
      deductions: profile.currentDeductions,
    );
    final newTax = _computeNewRegimeTax(profile.annualIncome);
    final savings = (oldTax - newTax).abs();

    final String recommendation;
    if (oldTax < newTax) {
      final diff = _paiseFmt(newTax - oldTax);
      recommendation = 'Old regime saves $diff over new regime.';
    } else if (newTax < oldTax) {
      final diff = _paiseFmt(oldTax - newTax);
      recommendation = 'New regime saves $diff over old regime.';
    } else {
      recommendation = 'Both regimes result in the same tax liability.';
    }

    return RegimeComparison(
      oldRegimeTax: oldTax,
      newRegimeTax: newTax,
      recommendation: recommendation,
      savings: savings,
    );
  }

  // ---------------------------------------------------------------------------
  // Capital gains harvesting
  // ---------------------------------------------------------------------------

  /// Estimates tax saving from harvesting unrealised capital losses.
  ///
  /// Short-term losses offset short-term gains at 15% STCG rate.
  /// Long-term losses offset long-term gains at 10% LTCG rate (above ₹1L).
  ///
  /// Returns the saving in paise.
  int computeCapGainsHarvesting(List<CapGainPosition> positions) {
    if (positions.isEmpty) return 0;

    // Separate gains and losses by term
    int stGains = 0;
    int stLosses = 0;
    int ltGains = 0;
    int ltLosses = 0;

    for (final pos in positions) {
      final pnl = pos.unrealisedPnl;
      if (pos.isLongTerm) {
        if (pnl >= 0) {
          ltGains += pnl;
        } else {
          ltLosses += pnl.abs();
        }
      } else {
        if (pnl >= 0) {
          stGains += pnl;
        } else {
          stLosses += pnl.abs();
        }
      }
    }

    // Short-term offset: save at 15% on harvested ST losses (up to ST gains)
    final stOffset = stLosses < stGains ? stLosses : stGains;
    final stSaving = (stOffset * 0.15).round();

    // Long-term offset: save at 10% on harvested LT losses (up to LT gains)
    final ltOffset = ltLosses < ltGains ? ltLosses : ltGains;
    final ltSaving = (ltOffset * 0.10).round();

    return stSaving + ltSaving;
  }

  // ---------------------------------------------------------------------------
  // Private tax computation helpers
  // ---------------------------------------------------------------------------

  /// Old regime tax (FY 2024-25) after deductions, with 4% cess.
  int _computeOldRegimeTax({required int income, required int deductions}) {
    final taxableIncome = (income - deductions).clamp(0, income);
    final baseTax = _oldRegimeSlabTax(taxableIncome);

    // Section 87A rebate: full rebate if taxable income ≤ ₹5L
    final incomeRs = taxableIncome / 100;
    final rebate = incomeRs <= 500000 ? baseTax : 0;
    final taxAfterRebate = (baseTax - rebate).clamp(0, baseTax);

    // 4% health & education cess
    return (taxAfterRebate * 1.04).round();
  }

  /// New regime tax (FY 2024-25) with 4% cess.
  /// Standard deduction ₹75,000 is allowed from FY 2024-25.
  int _computeNewRegimeTax(int income) {
    const standardDeduction = 7500000; // ₹75,000
    final taxableIncome = (income - standardDeduction).clamp(0, income);
    final baseTax = _newRegimeSlabTax(taxableIncome);

    // Section 87A rebate: ₹25,000 if taxable income ≤ ₹7L
    final incomeRs = taxableIncome / 100;
    final rebate = incomeRs <= 700000
        ? (baseTax < 2500000 ? baseTax : 2500000)
        : 0;
    final taxAfterRebate = (baseTax - rebate).clamp(0, baseTax);

    return (taxAfterRebate * 1.04).round();
  }

  /// Old regime income tax slabs (FY 2024-25, for individuals < 60).
  int _oldRegimeSlabTax(int taxableIncomePaise) {
    final rs = taxableIncomePaise / 100; // convert to rupees

    if (rs <= 250000) return 0;
    if (rs <= 500000) return ((rs - 250000) * 0.05 * 100).round();
    if (rs <= 1000000) {
      return ((12500 + (rs - 500000) * 0.20) * 100).round();
    }
    return ((112500 + (rs - 1000000) * 0.30) * 100).round();
  }

  /// New regime income tax slabs (FY 2024-25).
  int _newRegimeSlabTax(int taxableIncomePaise) {
    final rs = taxableIncomePaise / 100;

    if (rs <= 300000) return 0;
    if (rs <= 600000) return ((rs - 300000) * 0.05 * 100).round();
    if (rs <= 900000) {
      return ((15000 + (rs - 600000) * 0.10) * 100).round();
    }
    if (rs <= 1200000) {
      return ((45000 + (rs - 900000) * 0.15) * 100).round();
    }
    if (rs <= 1500000) {
      return ((90000 + (rs - 1200000) * 0.20) * 100).round();
    }
    return ((150000 + (rs - 1500000) * 0.30) * 100).round();
  }

  /// Approximate marginal rate for old regime income.
  double _oldRegimeMarginalRate(int incomePaise) {
    final rs = incomePaise / 100;
    if (rs <= 250000) return 0.0;
    if (rs <= 500000) return 0.05;
    if (rs <= 1000000) return 0.20;
    return 0.30;
  }

  String _paiseFmt(int paise) {
    final rs = paise / 100;
    if (rs >= 100000) return '₹${(rs / 100000).toStringAsFixed(1)}L';
    if (rs >= 1000) return '₹${(rs / 1000).toStringAsFixed(0)}K';
    return '₹${rs.toStringAsFixed(0)}';
  }
}
