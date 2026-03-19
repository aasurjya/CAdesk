import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _inrFmt = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// CMA data projection screen for bank loan applications.
///
/// Route: `/cma/projection`
class CmaProjectionScreen extends ConsumerStatefulWidget {
  const CmaProjectionScreen({super.key});

  @override
  ConsumerState<CmaProjectionScreen> createState() =>
      _CmaProjectionScreenState();
}

class _CmaProjectionScreenState extends ConsumerState<CmaProjectionScreen> {
  // Inputs
  double _baseSales = 50000000; // 5 Cr
  double _revenueGrowth = 15; // %
  double _grossMargin = 35; // %
  double _operatingExpenseRatio = 15; // %
  double _capexPerYear = 8000000;
  double _loanAmount = 20000000;
  double _interestRate = 10; // %
  int _projectionYears = 5;
  final String _bankName = 'State Bank of India';

  // Computed projections
  List<_YearData> get _projections {
    final result = <_YearData>[];
    for (int year = 1; year <= _projectionYears; year++) {
      final growthFactor = _pow(1 + _revenueGrowth / 100, year);
      final sales = _baseSales * growthFactor;
      final grossProfit = sales * _grossMargin / 100;
      final opex = sales * _operatingExpenseRatio / 100;
      final ebitda = grossProfit - opex;
      final depreciation = _capexPerYear * 0.15 * year;
      final interestExpense = _loanAmount * _interestRate / 100;
      final pbt = ebitda - depreciation - interestExpense;
      final tax = pbt > 0 ? pbt * 0.25 : 0;
      final netProfit = pbt - tax;

      // Ratios
      final currentAssets = sales * 0.25;
      final currentLiabilities = sales * 0.15;
      final currentRatio = currentLiabilities > 0
          ? currentAssets / currentLiabilities
          : 0.0;
      final totalDebt = _loanAmount * (1 - year / (_projectionYears + 2));
      final netWorth = _baseSales * 0.4 + netProfit * year;
      final deRatio = netWorth > 0 ? totalDebt / netWorth : 0.0;
      final annualDebtService =
          (_loanAmount / _projectionYears) + interestExpense;
      final dscr = annualDebtService > 0 ? ebitda / annualDebtService : 0.0;

      result.add(
        _YearData(
          year: year,
          sales: sales,
          grossProfit: grossProfit,
          ebitda: ebitda,
          netProfit: netProfit,
          currentRatio: currentRatio,
          deRatio: deRatio,
          dscr: dscr,
        ),
      );
    }
    return result;
  }

  double _pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final projections = _projections;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('CMA Projections', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export CMA Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CMA report exported as PDF'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bank & period header
            _BankHeader(bankName: _bankName, years: _projectionYears),
            const SizedBox(height: 16),

            // Input section
            _SectionTitle(title: 'Projection Inputs'),
            const SizedBox(height: 12),
            _InputCard(
              baseSales: _baseSales,
              revenueGrowth: _revenueGrowth,
              grossMargin: _grossMargin,
              opexRatio: _operatingExpenseRatio,
              capex: _capexPerYear,
              loanAmount: _loanAmount,
              interestRate: _interestRate,
              onBaseSalesChanged: (v) => setState(() => _baseSales = v),
              onGrowthChanged: (v) => setState(() => _revenueGrowth = v),
              onMarginChanged: (v) => setState(() => _grossMargin = v),
              onOpexChanged: (v) => setState(() => _operatingExpenseRatio = v),
              onCapexChanged: (v) => setState(() => _capexPerYear = v),
              onLoanChanged: (v) => setState(() => _loanAmount = v),
              onRateChanged: (v) => setState(() => _interestRate = v),
            ),
            const SizedBox(height: 8),

            // Projection years & bank selector
            Row(
              children: [
                const Text(
                  'Projection:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                ...[3, 5, 7].map(
                  (y) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('$y Y'),
                      selected: _projectionYears == y,
                      onSelected: (_) => setState(() => _projectionYears = y),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _projectionYears == y
                            ? Colors.white
                            : AppColors.neutral600,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Projected financials
            _SectionTitle(title: 'Projected Financials'),
            const SizedBox(height: 12),
            _ProjectionTable(projections: projections),
            const SizedBox(height: 20),

            // Key ratios
            _SectionTitle(title: 'Key Ratios'),
            const SizedBox(height: 12),
            _RatiosCard(projections: projections),
            const SizedBox(height: 24),

            // Export button
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'CMA report generated and ready for download',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Export CMA Report'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Year data model
// ---------------------------------------------------------------------------

class _YearData {
  const _YearData({
    required this.year,
    required this.sales,
    required this.grossProfit,
    required this.ebitda,
    required this.netProfit,
    required this.currentRatio,
    required this.deRatio,
    required this.dscr,
  });

  final int year;
  final double sales;
  final double grossProfit;
  final double ebitda;
  final double netProfit;
  final double currentRatio;
  final double deRatio;
  final double dscr;
}

// ---------------------------------------------------------------------------
// Bank header
// ---------------------------------------------------------------------------

class _BankHeader extends StatelessWidget {
  const _BankHeader({required this.bankName, required this.years});

  final String bankName;
  final int years;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryVariant.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$years-year CMA projection',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input card with sliders
// ---------------------------------------------------------------------------

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.baseSales,
    required this.revenueGrowth,
    required this.grossMargin,
    required this.opexRatio,
    required this.capex,
    required this.loanAmount,
    required this.interestRate,
    required this.onBaseSalesChanged,
    required this.onGrowthChanged,
    required this.onMarginChanged,
    required this.onOpexChanged,
    required this.onCapexChanged,
    required this.onLoanChanged,
    required this.onRateChanged,
  });

  final double baseSales;
  final double revenueGrowth;
  final double grossMargin;
  final double opexRatio;
  final double capex;
  final double loanAmount;
  final double interestRate;
  final ValueChanged<double> onBaseSalesChanged;
  final ValueChanged<double> onGrowthChanged;
  final ValueChanged<double> onMarginChanged;
  final ValueChanged<double> onOpexChanged;
  final ValueChanged<double> onCapexChanged;
  final ValueChanged<double> onLoanChanged;
  final ValueChanged<double> onRateChanged;

  String _crore(double v) => '${(v / 10000000).toStringAsFixed(1)} Cr';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SliderRow(
              label: 'Base Revenue',
              value: baseSales,
              min: 10000000,
              max: 200000000,
              displayValue: '₹${_crore(baseSales)}',
              onChanged: onBaseSalesChanged,
            ),
            _SliderRow(
              label: 'Revenue Growth',
              value: revenueGrowth,
              min: 5,
              max: 50,
              displayValue: '${revenueGrowth.round()}%',
              onChanged: onGrowthChanged,
            ),
            _SliderRow(
              label: 'Gross Margin',
              value: grossMargin,
              min: 10,
              max: 60,
              displayValue: '${grossMargin.round()}%',
              onChanged: onMarginChanged,
            ),
            _SliderRow(
              label: 'Opex Ratio',
              value: opexRatio,
              min: 5,
              max: 40,
              displayValue: '${opexRatio.round()}%',
              onChanged: onOpexChanged,
            ),
            _SliderRow(
              label: 'Loan Amount',
              value: loanAmount,
              min: 5000000,
              max: 100000000,
              displayValue: '₹${_crore(loanAmount)}',
              onChanged: onLoanChanged,
            ),
            _SliderRow(
              label: 'Interest Rate',
              value: interestRate,
              min: 6,
              max: 18,
              displayValue: '${interestRate.toStringAsFixed(1)}%',
              onChanged: onRateChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Projection table
// ---------------------------------------------------------------------------

class _ProjectionTable extends StatelessWidget {
  const _ProjectionTable({required this.projections});

  final List<_YearData> projections;

  String _compact(double v) {
    if (v.abs() >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v.abs() >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    return _inrFmt.format(v);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.06),
          ),
          columnSpacing: 16,
          columns: const [
            DataColumn(
              label: Text(
                'Year',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            DataColumn(
              label: Text(
                'Sales',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            DataColumn(
              label: Text(
                'EBITDA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            DataColumn(
              label: Text(
                'Net Profit',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            DataColumn(
              label: Text(
                'DSCR',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
          rows: projections
              .map(
                (p) => DataRow(
                  cells: [
                    DataCell(
                      Text('Y${p.year}', style: const TextStyle(fontSize: 12)),
                    ),
                    DataCell(
                      Text(
                        _compact(p.sales),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        _compact(p.ebitda),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        _compact(p.netProfit),
                        style: TextStyle(
                          fontSize: 12,
                          color: p.netProfit >= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        p.dscr.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p.dscr >= 1.25
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ratios card
// ---------------------------------------------------------------------------

class _RatiosCard extends StatelessWidget {
  const _RatiosCard({required this.projections});

  final List<_YearData> projections;

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) return const SizedBox.shrink();

    final last = projections.last;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _RatioCell(
              label: 'DSCR',
              value: last.dscr.toStringAsFixed(2),
              benchmark: '>= 1.25',
              isPassing: last.dscr >= 1.25,
            ),
            const SizedBox(width: 8),
            _RatioCell(
              label: 'Current Ratio',
              value: last.currentRatio.toStringAsFixed(2),
              benchmark: '>= 1.33',
              isPassing: last.currentRatio >= 1.33,
            ),
            const SizedBox(width: 8),
            _RatioCell(
              label: 'D/E Ratio',
              value: last.deRatio.toStringAsFixed(2),
              benchmark: '<= 2.00',
              isPassing: last.deRatio <= 2.0,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatioCell extends StatelessWidget {
  const _RatioCell({
    required this.label,
    required this.value,
    required this.benchmark,
    required this.isPassing,
  });

  final String label;
  final String value;
  final String benchmark;
  final bool isPassing;

  @override
  Widget build(BuildContext context) {
    final color = isPassing ? AppColors.success : AppColors.error;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(
              isPassing ? Icons.check_circle_rounded : Icons.warning_rounded,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              benchmark,
              style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}
