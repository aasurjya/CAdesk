import 'package:ca_app/features/audit/domain/models/form29b.dart';

/// P&L data needed for MAT computation under Sec 115JB.
///
/// All amounts in paise (int).
class PnlData {
  const PnlData({
    required this.netProfitPaise,
    required this.depreciationAsPerBooks,
    required this.provisionForTax,
    required this.provisionForDeferredTax,
    required this.deferredTaxLiability,
    required this.donationsAndCharities,
    required this.capitalGainsExempt,
    required this.broughtForwardLosses,
    required this.broughtForwardUnabsorbedDepreciation,
  });

  /// Net profit as per the profit and loss account (paise).
  final int netProfitPaise;

  /// Depreciation charged as per books of account (paise).
  final int depreciationAsPerBooks;

  /// Provision for income tax charged to P&L (paise).
  final int provisionForTax;

  /// Provision for deferred tax (paise).
  final int provisionForDeferredTax;

  /// Deferred tax liability (paise).
  final int deferredTaxLiability;

  /// Donations and charities debited to P&L (paise).
  final int donationsAndCharities;

  /// Exempt capital gains included in P&L (paise).
  final int capitalGainsExempt;

  /// Brought-forward losses as per books (paise).
  final int broughtForwardLosses;

  /// Brought-forward unabsorbed depreciation (paise).
  final int broughtForwardUnabsorbedDepreciation;
}

/// Balance sheet data needed for MAT computation.
///
/// All amounts in paise (int).
class BalanceSheetData {
  const BalanceSheetData({
    required this.netWorthPaise,
    required this.paidUpCapitalPaise,
    required this.reservesAndSurplusPaise,
  });

  final int netWorthPaise;
  final int paidUpCapitalPaise;
  final int reservesAndSurplusPaise;
}

/// Stateless service for computing Minimum Alternate Tax (MAT) under
/// Section 115JB of the Income Tax Act.
///
/// MAT = 15% of book profit.
/// Book profit = net profit ± prescribed adjustments per Sec 115JB.
/// MAT credit is available for carry-forward for 15 years (Sec 115JAA).
///
/// All amounts are in paise (int).
class Form29BService {
  Form29BService._();

  /// MAT rate as per Sec 115JB: 15%.
  static const double _matRate = 0.15;

  /// MAT credit carry-forward period in years per Sec 115JAA.
  static const int _matCreditCarryForwardYears = 15;

  /// Computes the [Form29B] MAT report for the given [financialYear].
  static Form29B computeMAT({
    required PnlData pnl,
    required BalanceSheetData bs,
    required int financialYear,
  }) {
    final adjustments = <BookProfitAdjustment>[];

    // Start with net profit as per books.
    int bookProfit = pnl.netProfitPaise;

    // ── Add-backs (items debited to P&L that must be added back) ─────────────

    if (pnl.provisionForTax > 0) {
      bookProfit += pnl.provisionForTax;
      adjustments.add(
        BookProfitAdjustment(
          description: 'Add: Provision for income tax',
          adjustmentPaise: pnl.provisionForTax,
        ),
      );
    }

    // Net deferred tax position: if DTL > provision, add the net; else deduct.
    final deferredTaxNet =
        pnl.deferredTaxLiability - pnl.provisionForDeferredTax;
    if (deferredTaxNet > 0) {
      bookProfit += deferredTaxNet;
      adjustments.add(
        BookProfitAdjustment(
          description: 'Add: Net deferred tax liability',
          adjustmentPaise: deferredTaxNet,
        ),
      );
    } else if (deferredTaxNet < 0) {
      bookProfit += deferredTaxNet; // deferredTaxNet is negative here
      adjustments.add(
        BookProfitAdjustment(
          description: 'Less: Net deferred tax asset',
          adjustmentPaise: deferredTaxNet,
        ),
      );
    }

    if (pnl.donationsAndCharities > 0) {
      bookProfit += pnl.donationsAndCharities;
      adjustments.add(
        BookProfitAdjustment(
          description: 'Add: Donations and charities',
          adjustmentPaise: pnl.donationsAndCharities,
        ),
      );
    }

    // ── Deductions ────────────────────────────────────────────────────────────

    if (pnl.capitalGainsExempt > 0) {
      bookProfit -= pnl.capitalGainsExempt;
      adjustments.add(
        BookProfitAdjustment(
          description: 'Less: Exempt capital gains',
          adjustmentPaise: -pnl.capitalGainsExempt,
        ),
      );
    }

    // Brought-forward losses: deduct lower of (BF losses + unabsorbed depr)
    // or book profit (after other adjustments). Cannot take book profit below 0.
    final bfTotal =
        pnl.broughtForwardLosses + pnl.broughtForwardUnabsorbedDepreciation;
    if (bfTotal > 0) {
      final allowedDeduction = bfTotal < bookProfit ? bfTotal : bookProfit;
      if (allowedDeduction > 0) {
        bookProfit -= allowedDeduction;
        adjustments.add(
          BookProfitAdjustment(
            description:
                'Less: Brought forward losses and unabsorbed depreciation',
            adjustmentPaise: -allowedDeduction,
          ),
        );
      }
    }

    // Book profit cannot be negative.
    if (bookProfit < 0) {
      bookProfit = 0;
    }

    // MAT = 15% of book profit (integer paise arithmetic).
    final matLiability = (bookProfit * _matRate).truncate();

    return Form29B(
      financialYear: financialYear,
      bookProfitPaise: bookProfit,
      matLiabilityPaise: matLiability,
      matCreditAvailablePaise: matLiability,
      matCreditCarryForwardYears: _matCreditCarryForwardYears,
      bookProfitAdjustments: List<BookProfitAdjustment>.unmodifiable(
        adjustments,
      ),
    );
  }
}
