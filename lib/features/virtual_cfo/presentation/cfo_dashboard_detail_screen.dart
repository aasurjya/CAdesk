import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _Ratio {
  const _Ratio({
    required this.name,
    required this.value,
    required this.previousValue,
    required this.benchmark,
    required this.unit,
  });

  final String name;
  final String value;
  final String previousValue;
  final String benchmark;
  final String unit;

  String get trend {
    final curr = double.tryParse(value) ?? 0;
    final prev = double.tryParse(previousValue) ?? 0;
    if (curr > prev) return 'up';
    if (curr < prev) return 'down';
    return 'stable';
  }
}

class _BudgetLine {
  const _BudgetLine({
    required this.category,
    required this.budget,
    required this.actual,
  });

  final String category;
  final double budget;
  final double actual;

  double get variance => actual - budget;
  double get variancePct => budget > 0 ? (variance / budget) * 100 : 0;
}

class _CashFlowEntry {
  const _CashFlowEntry({
    required this.month,
    required this.inflow,
    required this.outflow,
  });

  final String month;
  final double inflow;
  final double outflow;

  double get net => inflow - outflow;
}

class _CfoDashboard {
  const _CfoDashboard({
    required this.clientId,
    required this.clientName,
    required this.industry,
    required this.workingCapitalDays,
    required this.currentRatio,
    required this.debtEquity,
    required this.ratios,
    required this.cashFlow,
    required this.budget,
  });

  final String clientId;
  final String clientName;
  final String industry;
  final int workingCapitalDays;
  final double currentRatio;
  final double debtEquity;
  final List<_Ratio> ratios;
  final List<_CashFlowEntry> cashFlow;
  final List<_BudgetLine> budget;
}

const _mockDashboard = _CfoDashboard(
  clientId: 'CLI-045',
  clientName: 'Meridian Steel Industries Ltd',
  industry: 'Manufacturing',
  workingCapitalDays: 68,
  currentRatio: 1.45,
  debtEquity: 0.82,
  ratios: [
    _Ratio(
      name: 'Gross Margin',
      value: '32.5',
      previousValue: '30.1',
      benchmark: '35',
      unit: '%',
    ),
    _Ratio(
      name: 'EBITDA Margin',
      value: '18.2',
      previousValue: '16.8',
      benchmark: '20',
      unit: '%',
    ),
    _Ratio(
      name: 'ROE',
      value: '14.5',
      previousValue: '12.9',
      benchmark: '15',
      unit: '%',
    ),
    _Ratio(
      name: 'Asset Turnover',
      value: '1.8',
      previousValue: '1.6',
      benchmark: '2.0',
      unit: 'x',
    ),
    _Ratio(
      name: 'Interest Coverage',
      value: '4.2',
      previousValue: '3.8',
      benchmark: '3.0',
      unit: 'x',
    ),
    _Ratio(
      name: 'Inventory Days',
      value: '42',
      previousValue: '48',
      benchmark: '35',
      unit: 'days',
    ),
  ],
  cashFlow: [
    _CashFlowEntry(month: 'Oct', inflow: 45, outflow: 38),
    _CashFlowEntry(month: 'Nov', inflow: 52, outflow: 41),
    _CashFlowEntry(month: 'Dec', inflow: 48, outflow: 55),
    _CashFlowEntry(month: 'Jan', inflow: 60, outflow: 42),
    _CashFlowEntry(month: 'Feb', inflow: 55, outflow: 47),
    _CashFlowEntry(month: 'Mar', inflow: 65, outflow: 50),
  ],
  budget: [
    _BudgetLine(category: 'Revenue', budget: 3200000, actual: 3450000),
    _BudgetLine(category: 'Raw Materials', budget: 1800000, actual: 1920000),
    _BudgetLine(category: 'Employee Cost', budget: 650000, actual: 640000),
    _BudgetLine(category: 'Overheads', budget: 320000, actual: 355000),
    _BudgetLine(category: 'Finance Cost', budget: 180000, actual: 175000),
    _BudgetLine(category: 'Capex', budget: 500000, actual: 420000),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Client-specific CFO dashboard with ratios, cash flow, and budget analysis.
///
/// Route: `/virtual-cfo/dashboard/:clientId`
class CfoDashboardDetailScreen extends ConsumerWidget {
  const CfoDashboardDetailScreen({required this.clientId, super.key});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = _mockDashboard;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('CFO Dashboard'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text('MIS'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Client header
          _ClientHeader(dashboard: d),
          const SizedBox(height: 12),

          // KPI cards
          Row(
            children: [
              SummaryCard(
                label: 'WC Days',
                value: '${d.workingCapitalDays}',
                icon: Icons.swap_horiz_rounded,
                color: AppColors.primary,
              ),
              SummaryCard(
                label: 'Current Ratio',
                value: d.currentRatio.toStringAsFixed(2),
                icon: Icons.balance_rounded,
                color: d.currentRatio >= 1.5
                    ? AppColors.success
                    : AppColors.warning,
              ),
              SummaryCard(
                label: 'Debt/Equity',
                value: d.debtEquity.toStringAsFixed(2),
                icon: Icons.account_balance_rounded,
                color: d.debtEquity <= 1.0
                    ? AppColors.success
                    : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cash flow projection
          const SectionHeader(
            title: 'Cash Flow Projection',
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 8),
          _CashFlowTable(entries: d.cashFlow),
          const SizedBox(height: 20),

          // Key ratios
          const SectionHeader(
            title: 'Key Ratios & Trends',
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 8),
          ...d.ratios.map((r) => _RatioRow(ratio: r)),
          const SizedBox(height: 20),

          // Budget vs actual
          const SectionHeader(
            title: 'Budget vs Actual',
            icon: Icons.compare_arrows_rounded,
          ),
          const SizedBox(height: 8),
          ...d.budget.map((b) => _BudgetRow(line: b)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.dashboard});

  final _CfoDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dashboard.clientName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                StatusBadge(
                  label: dashboard.industry,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: dashboard.clientId,
                  color: AppColors.neutral400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CashFlowTable extends StatelessWidget {
  const _CashFlowTable({required this.entries});

  final List<_CashFlowEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header row
            const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Month',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.neutral400,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Inflow',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.neutral400,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Outflow',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.neutral400,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Net',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.neutral400,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        e.month,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${e.inflow.toInt()}L',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${e.outflow.toInt()}L',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${e.net >= 0 ? "+" : ""}${e.net.toInt()}L',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: e.net >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatioRow extends StatelessWidget {
  const _RatioRow({required this.ratio});

  final _Ratio ratio;

  IconData get _trendIcon => switch (ratio.trend) {
    'up' => Icons.arrow_upward_rounded,
    'down' => Icons.arrow_downward_rounded,
    _ => Icons.horizontal_rule_rounded,
  };

  Color get _trendColor => switch (ratio.trend) {
    'up' => AppColors.success,
    'down' => AppColors.error,
    _ => AppColors.neutral400,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                ratio.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            Icon(_trendIcon, size: 14, color: _trendColor),
            const SizedBox(width: 4),
            SizedBox(
              width: 56,
              child: Text(
                '${ratio.value}${ratio.unit}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 56,
              child: Text(
                'BM: ${ratio.benchmark}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.neutral400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.line});

  final _BudgetLine line;

  @override
  Widget build(BuildContext context) {
    final isPositiveVariance = line.category == 'Revenue'
        ? line.variance >= 0
        : line.variance <= 0;
    final varianceColor = isPositiveVariance
        ? AppColors.success
        : AppColors.error;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                line.category,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                _fmt(line.budget),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                _fmt(line.actual),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: Text(
                '${line.variancePct >= 0 ? "+" : ""}${line.variancePct.toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: varianceColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}
