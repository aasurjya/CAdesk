import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/analytics/data/providers/analytics_providers.dart';
import 'package:ca_app/features/analytics/domain/models/growth_opportunity.dart';
import 'package:ca_app/features/analytics/domain/models/kpi_metric.dart';
import 'package:ca_app/features/analytics/presentation/widgets/aging_bar.dart';
import 'package:ca_app/features/analytics/presentation/widgets/client_health_chart_widget.dart';
import 'package:ca_app/features/analytics/presentation/widgets/kpi_card.dart';
import 'package:ca_app/features/analytics/presentation/widgets/kpi_grid_widget.dart';
import 'package:ca_app/features/analytics/presentation/widgets/revenue_chart_widget.dart';

/// Main analytics dashboard showing KPIs, revenue summary, and aging chart.
class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final kpis = ref.watch(kpiMetricsProvider);
    final revenueByService = ref.watch(revenueByServiceProvider);
    final totalRevenue = ref.watch(totalRevenueProvider);
    final bucketTotals = ref.watch(receivablesByBucketProvider);
    final totalReceivables = ref.watch(totalReceivablesProvider);
    final growthCounts = ref.watch(growthOpportunitiesByStageProvider);
    final growthPipeline = ref.watch(totalGrowthPipelineValueProvider);
    final weightedPipeline = ref.watch(weightedGrowthPipelineValueProvider);
    final topGrowthOpportunities = ref.watch(topGrowthOpportunitiesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics & BI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Performance and growth intelligence',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AnalyticsPeriod>(
                  value: period,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  items: AnalyticsPeriod.values.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.label));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(analyticsPeriodProvider.notifier).update(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _AnalyticsBanner(),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: 'Practice KPIs',
              icon: Icons.dashboard_customize_rounded,
            ),
            const SizedBox(height: 10),
            const KpiGridWidget(),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Revenue Trend',
              icon: Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 10),
            const RevenueChartWidget(),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Client Health Overview',
              icon: Icons.health_and_safety_rounded,
            ),
            const SizedBox(height: 10),
            const ClientHealthChartWidget(),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Key Metrics',
              icon: Icons.insights_rounded,
            ),
            const SizedBox(height: 10),
            _KpiGrid(kpis: kpis),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Revenue by Service',
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 10),
            _RevenueCard(
              revenueByService: revenueByService,
              totalRevenue: totalRevenue,
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Aging Analysis',
              icon: Icons.schedule_rounded,
            ),
            const SizedBox(height: 10),
            AgingBar(bucketTotals: bucketTotals, grandTotal: totalReceivables),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Tax Practice Growth',
              icon: Icons.trending_up_rounded,
            ),
            const SizedBox(height: 10),
            _GrowthPipelineCard(
              growthCounts: growthCounts,
              totalPipeline: growthPipeline,
              weightedPipeline: weightedPipeline,
            ),
            const SizedBox(height: 12),
            _GrowthOpportunitiesList(opportunities: topGrowthOpportunities),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsBanner extends StatelessWidget {
  const _AnalyticsBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.query_stats_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A clearer view of firm performance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track revenue, receivables, and growth opportunities in a calmer light workspace designed for quick decision-making.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// KPI grid (2 columns)
// ---------------------------------------------------------------------------

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis});

  final List<KpiMetric> kpis;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) => KpiCard(metric: kpis[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Revenue summary card
// ---------------------------------------------------------------------------

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({
    required this.revenueByService,
    required this.totalRevenue,
  });

  final Map<String, double> revenueByService;
  final double totalRevenue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = revenueByService.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  _formatInr(totalRevenue),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stacked bar
            _StackedBar(entries: sorted, total: totalRevenue),
            const SizedBox(height: 12),
            // Legend
            ...sorted.map((entry) {
              final percent = totalRevenue > 0
                  ? (entry.value / totalRevenue * 100).toStringAsFixed(1)
                  : '0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _serviceColor(entry.key),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                    Text(
                      '${_formatInr(entry.value)} ($percent%)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static String _formatInr(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class _GrowthPipelineCard extends StatelessWidget {
  const _GrowthPipelineCard({
    required this.growthCounts,
    required this.totalPipeline,
    required this.weightedPipeline,
  });

  final Map<GrowthOpportunityStage, int> growthCounts;
  final double totalPipeline;
  final double weightedPipeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Pipeline',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Advisory, campaign, NRI, and retainer opportunities surfaced from live compliance work.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _GrowthMetric(
                    label: 'Open pipeline',
                    value: _RevenueCard._formatInr(totalPipeline),
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _GrowthMetric(
                    label: 'Weighted value',
                    value: _RevenueCard._formatInr(weightedPipeline),
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GrowthOpportunityStage.values.map((stage) {
                final count = growthCounts[stage] ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: stage.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${stage.label}: $count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: stage.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthMetric extends StatelessWidget {
  const _GrowthMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

class _GrowthOpportunitiesList extends StatelessWidget {
  const _GrowthOpportunitiesList({required this.opportunities});

  final List<GrowthOpportunity> opportunities;

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: opportunities
          .map(
            (opportunity) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GrowthOpportunityTile(opportunity: opportunity),
            ),
          )
          .toList(),
    );
  }
}

class _GrowthOpportunityTile extends StatelessWidget {
  const _GrowthOpportunityTile({required this.opportunity});

  final GrowthOpportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opportunity.clientName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: opportunity.stage.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    opportunity.stage.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: opportunity.stage.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              opportunity.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _GrowthTileMeta(
                    label: 'Est. fee',
                    value: _RevenueCard._formatInr(opportunity.estimatedFee),
                  ),
                ),
                Expanded(
                  child: _GrowthTileMeta(
                    label: 'Probability',
                    value:
                        '${(opportunity.conversionProbability * 100).round()}%',
                  ),
                ),
                Expanded(
                  child: _GrowthTileMeta(
                    label: 'Owner',
                    value: opportunity.owner,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Next: ${opportunity.nextAction}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthTileMeta extends StatelessWidget {
  const _GrowthTileMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.entries, required this.total});

  final List<MapEntry<String, double>> entries;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox(height: 16);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 16,
        child: Row(
          children: entries.map((entry) {
            final flex = (entry.value / total * 1000).round().clamp(1, 1000);
            return Expanded(
              flex: flex,
              child: Container(color: _serviceColor(entry.key)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

Color _serviceColor(String service) {
  switch (service) {
    case 'ITR Filing':
      return AppColors.primary;
    case 'GST Filing':
      return AppColors.secondary;
    case 'Audit':
      return const Color(0xFF7C3AED);
    case 'TDS Return':
      return AppColors.accent;
    case 'Bookkeeping':
      return const Color(0xFF2196F3);
    case 'Payroll':
      return const Color(0xFF00897B);
    case 'ROC Filing':
      return const Color(0xFF8D6E63);
    default:
      return AppColors.neutral400;
  }
}
