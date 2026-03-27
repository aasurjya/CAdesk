import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../data/providers/balance_sheet_providers.dart';

/// Company header for P&L statement.
class PnlHeader extends StatelessWidget {
  const PnlHeader({
    super.key,
    required this.companyName,
    required this.financialYear,
  });

  final String companyName;
  final String financialYear;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Statement of Profit & Loss for $financialYear',
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profit highlight card with revenue, net profit, and net margin.
class PnlProfitHighlight extends StatelessWidget {
  const PnlProfitHighlight({super.key, required this.pnl});

  final PnlStatement pnl;

  @override
  Widget build(BuildContext context) {
    final isProfit = pnl.profitAfterTax >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HighlightStat(
              label: 'Revenue',
              value: CurrencyUtils.formatINRCompact(
                pnl.revenueFromOperations / 100,
              ),
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: _HighlightStat(
              label: isProfit ? 'Net Profit' : 'Net Loss',
              value: CurrencyUtils.formatINRCompact(
                pnl.profitAfterTax.abs() / 100,
              ),
              color: color,
            ),
          ),
          Expanded(
            child: _HighlightStat(
              label: 'Net Margin',
              value: pnl.revenueFromOperations > 0
                  ? '${(pnl.profitAfterTax * 100 / pnl.revenueFromOperations).toStringAsFixed(1)}%'
                  : 'N/A',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightStat extends StatelessWidget {
  const _HighlightStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
        ),
      ],
    );
  }
}

/// Column headers row for financial statements.
class PnlColumnHeaders extends StatelessWidget {
  const PnlColumnHeaders({super.key, required this.hasPreviousYear});

  final bool hasPreviousYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: Text(
              'Particulars',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral600,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Current Year',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral600,
              ),
            ),
          ),
          if (hasPreviousYear)
            const Expanded(
              flex: 3,
              child: Text(
                'Previous Year',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section label for financial statement sections.
class PnlSectionLabel extends StatelessWidget {
  const PnlSectionLabel({super.key, required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: color.withValues(alpha: 0.06),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// EPS display row.
class PnlEpsRow extends StatelessWidget {
  const PnlEpsRow({super.key, required this.epsBasic});

  final double epsBasic;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Earnings Per Share (Basic & Diluted)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              CurrencyUtils.formatINR(epsBasic),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Percentage analysis card showing expense ratios and margins.
class PnlPercentageAnalysis extends StatelessWidget {
  const PnlPercentageAnalysis({super.key, required this.pnl});

  final PnlStatement pnl;

  double _pct(int value) {
    if (pnl.revenueFromOperations == 0) return 0;
    return value * 100 / pnl.revenueFromOperations;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pie_chart_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Percentage Analysis (% of Revenue)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            _PctRow('COGS / Materials', _pct(pnl.costOfGoodsSold)),
            _PctRow('Employee Benefits', _pct(pnl.employeeBenefits)),
            _PctRow('Depreciation', _pct(pnl.depreciation)),
            _PctRow('Other Expenses', _pct(pnl.otherExpenses)),
            const Divider(height: 8),
            _PctRow(
              'Gross Margin',
              _pct(pnl.revenueFromOperations - pnl.costOfGoodsSold),
              highlight: true,
            ),
            _PctRow('Net Margin', _pct(pnl.profitAfterTax), highlight: true),
          ],
        ),
      ),
    );
  }
}

class _PctRow extends StatelessWidget {
  const _PctRow(this.label, this.percentage, {this.highlight = false});

  final String label;
  final double percentage;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
                color: highlight ? AppColors.primary : AppColors.neutral600,
              ),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight ? AppColors.primary : AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
