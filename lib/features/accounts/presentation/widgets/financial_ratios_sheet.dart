import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/accounts_providers.dart';

/// Bottom sheet showing all computed financial ratios for a client.
///
/// Open via [showFinancialRatiosSheet].
class FinancialRatiosSheet extends StatelessWidget {
  const FinancialRatiosSheet({super.key, required this.snapshot});

  final FinancialRatioSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              const _SheetHandle(),

              // Header
              _SheetHeader(snapshot: snapshot, theme: theme),

              const Divider(height: 1, color: AppColors.neutral200),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    _RatioSection(
                      title: 'Liquidity Ratios',
                      icon: Icons.water_drop_outlined,
                      rows: [
                        _RatioRow(
                          label: 'Current Ratio',
                          value: snapshot.currentRatio.toStringAsFixed(2),
                          benchmark: '>2 Good  |  1–2 OK  |  <1 Poor',
                          color: _liquidityColor(snapshot.currentRatio),
                        ),
                        _RatioRow(
                          label: 'Quick Ratio',
                          value: snapshot.quickRatio.toStringAsFixed(2),
                          benchmark: '>1 Good  |  <1 Watch',
                          color: snapshot.quickRatio >= 1
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _RatioSection(
                      title: 'Profitability Ratios',
                      icon: Icons.trending_up_rounded,
                      rows: [
                        _RatioRow(
                          label: 'Gross Margin',
                          value: '${snapshot.grossMargin.toStringAsFixed(1)}%',
                          benchmark: '>40% Good  |  20–40% OK  |  <20% Poor',
                          color: _marginColor(snapshot.grossMargin, 40, 20),
                        ),
                        _RatioRow(
                          label: 'Net Margin',
                          value: '${snapshot.netMargin.toStringAsFixed(1)}%',
                          benchmark: '>15% Good  |  5–15% OK  |  <5% Poor',
                          color: _marginColor(snapshot.netMargin, 15, 5),
                        ),
                        _RatioRow(
                          label: 'EBITDA Margin',
                          value: '${snapshot.ebitdaMargin.toStringAsFixed(1)}%',
                          benchmark: '>20% Good  |  10–20% OK  |  <10% Poor',
                          color: _marginColor(snapshot.ebitdaMargin, 20, 10),
                        ),
                        _RatioRow(
                          label: 'Return on Equity',
                          value: '${snapshot.roe.toStringAsFixed(1)}%',
                          benchmark: '>15% Good  |  8–15% OK  |  <8% Poor',
                          color: _marginColor(snapshot.roe, 15, 8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _RatioSection(
                      title: 'Leverage & Coverage',
                      icon: Icons.balance_rounded,
                      rows: [
                        _RatioRow(
                          label: 'Debt / Equity',
                          value: snapshot.debtToEquity.toStringAsFixed(2),
                          benchmark: '<1 Good  |  1–2 Watch  |  >2 Concern',
                          color: _debtEquityColor(snapshot.debtToEquity),
                        ),
                        _RatioRow(
                          label: 'Interest Coverage',
                          value: snapshot.interestCoverage.isInfinite
                              ? '∞'
                              : snapshot.interestCoverage.toStringAsFixed(1),
                          benchmark: '>3 Good  |  1–3 Watch  |  <1 Concern',
                          color: _interestColor(snapshot.interestCoverage),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _RatioSection(
                      title: 'Efficiency (Days)',
                      icon: Icons.schedule_rounded,
                      rows: [
                        _RatioRow(
                          label: 'Debtor Days',
                          value:
                              '${snapshot.debtorDays.toStringAsFixed(0)} days',
                          benchmark: '<30 Good  |  30–60 OK  |  >60 Watch',
                          color: _daysColor(
                            snapshot.debtorDays,
                            goodBelow: 30,
                            watchAbove: 60,
                          ),
                        ),
                        _RatioRow(
                          label: 'Creditor Days',
                          value:
                              '${snapshot.creditorDays.toStringAsFixed(0)} days',
                          benchmark: '>30 Good  |  <15 Watch',
                          color: snapshot.creditorDays >= 30
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        _RatioRow(
                          label: 'Inventory Days',
                          value: snapshot.isServiceBusiness
                              ? 'N/A'
                              : '${snapshot.inventoryDays.toStringAsFixed(0)} days',
                          benchmark: snapshot.isServiceBusiness
                              ? 'Service business — not applicable'
                              : '<45 Good  |  45–90 OK  |  >90 Poor',
                          color: snapshot.isServiceBusiness
                              ? AppColors.neutral400
                              : _daysColor(
                                  snapshot.inventoryDays,
                                  goodBelow: 45,
                                  watchAbove: 90,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Color helpers
  // ---------------------------------------------------------------------------

  Color _liquidityColor(double ratio) {
    if (ratio >= 2.0) return AppColors.success;
    if (ratio >= 1.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _marginColor(double pct, double good, double ok) {
    if (pct >= good) return AppColors.success;
    if (pct >= ok) return AppColors.warning;
    return AppColors.error;
  }

  Color _debtEquityColor(double de) {
    if (de < 1.0) return AppColors.success;
    if (de <= 2.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _interestColor(double ic) {
    if (ic.isInfinite || ic >= 3.0) return AppColors.success;
    if (ic >= 1.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _daysColor(
    double days, {
    required double goodBelow,
    required double watchAbove,
  }) {
    if (days < goodBelow) return AppColors.success;
    if (days <= watchAbove) return AppColors.warning;
    return AppColors.error;
  }
}

// ---------------------------------------------------------------------------
// Helper to show the sheet
// ---------------------------------------------------------------------------

void showFinancialRatiosSheet(
  BuildContext context,
  FinancialRatioSnapshot snapshot,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FinancialRatiosSheet(snapshot: snapshot),
  );
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.snapshot, required this.theme});

  final FinancialRatioSnapshot snapshot;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final rating = snapshot.overallRating;
    final ratingColor = _ratingColor(rating);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Ratios',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${snapshot.clientName}  •  ${snapshot.period}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ratingColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ratingColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              rating,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ratingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _ratingColor(String rating) {
    switch (rating) {
      case 'Healthy':
        return AppColors.success;
      case 'Watch':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}

class _RatioSection extends StatelessWidget {
  const _RatioSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_RatioRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primaryVariant),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryVariant,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: AppColors.neutral200,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RatioRow extends StatelessWidget {
  const _RatioRow({
    required this.label,
    required this.value,
    required this.benchmark,
    required this.color,
  });

  final String label;
  final String value;
  final String benchmark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Color indicator dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),

          // Label + benchmark
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  benchmark,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
