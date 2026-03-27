import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/esg_reporting_providers.dart';
import 'widgets/carbon_metric_tile.dart';
import 'widgets/esg_score_card.dart';

/// Entry-point screen for the ESG Reporting & Sustainability Compliance module.
class EsgReportingScreen extends ConsumerStatefulWidget {
  const EsgReportingScreen({super.key});

  @override
  ConsumerState<EsgReportingScreen> createState() => _EsgReportingScreenState();
}

class _EsgReportingScreenState extends ConsumerState<EsgReportingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _statusFilters = <String?>[
    null,
    'Draft',
    'Under Review',
    'Filed',
    'Published',
  ];

  static const _statusLabels = <String>[
    'All',
    'Draft',
    'Under Review',
    'Filed',
    'Published',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('ESG Reporting'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.surface,
          unselectedLabelColor: AppColors.surface.withAlpha(153),
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Disclosures'),
            Tab(text: 'Carbon Metrics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _DisclosuresTab(
            statusFilters: _statusFilters,
            statusLabels: _statusLabels,
          ),
          const _CarbonMetricsTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalClients,
    required this.avgScore,
    required this.filedCount,
    required this.carbonNeutralCount,
  });

  final int totalClients;
  final double avgScore;
  final int filedCount;
  final int carbonNeutralCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESG Portfolio Overview · FY 2024-25',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.surface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryMetric(
                label: 'Total Clients',
                value: '$totalClients',
                icon: Icons.business_outlined,
              ),
              _SummaryMetric(
                label: 'Avg ESG Score',
                value: '${avgScore.toStringAsFixed(1)}/100',
                icon: Icons.bar_chart_outlined,
              ),
              _SummaryMetric(
                label: 'Filed',
                value: '$filedCount',
                icon: Icons.check_circle_outline,
              ),
              _SummaryMetric(
                label: 'Carbon Neutral',
                value: '$carbonNeutralCount',
                icon: Icons.eco_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.surface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Disclosures Tab
// ---------------------------------------------------------------------------

class _DisclosuresTab extends ConsumerWidget {
  const _DisclosuresTab({
    required this.statusFilters,
    required this.statusLabels,
  });

  final List<String?> statusFilters;
  final List<String> statusLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allEsgDisclosuresProvider);
    final filtered = ref.watch(filteredEsgDisclosuresProvider);
    final selected = ref.watch(selectedEsgStatusProvider);

    final totalClients = all.length;
    final avgScore = all.isEmpty
        ? 0.0
        : all.map((d) => d.overallScore).reduce((a, b) => a + b) / all.length;
    final filedCount = all.where((d) => d.status == 'Filed').length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _SummaryCard(
            totalClients: totalClients,
            avgScore: avgScore,
            filedCount: filedCount,
            carbonNeutralCount: 1,
          ),
        ),
        SliverToBoxAdapter(
          child: _FilterChips(
            filters: statusFilters,
            labels: statusLabels,
            selected: selected,
            onSelected: (value) =>
                ref.read(selectedEsgStatusProvider.notifier).update(value),
          ),
        ),
        if (filtered.isEmpty)
          const SliverFillRemaining(
            child: _EmptyState(message: 'No disclosures match this filter.'),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => EsgScoreCard(disclosure: filtered[index]),
              childCount: filtered.length,
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String?> filters;
  final List<String> labels;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = selected == filters[index];
          return FilterChip(
            label: Text(labels[index]),
            selected: isActive,
            onSelected: (_) => onSelected(filters[index]),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary.withAlpha(26),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isActive ? AppColors.primary : AppColors.neutral600,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isActive ? AppColors.primary : AppColors.neutral300,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carbon Metrics Tab
// ---------------------------------------------------------------------------

class _CarbonMetricsTab extends ConsumerWidget {
  const _CarbonMetricsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(allCarbonMetricsProvider);
    final theme = Theme.of(context);

    final totalEmissions = metrics.fold<double>(
      0,
      (sum, m) => sum + m.emissionsTonnes,
    );
    final scope1Count = metrics
        .where((m) => m.scope.startsWith('Scope 1'))
        .length;
    final scope2Count = metrics
        .where((m) => m.scope.startsWith('Scope 2'))
        .length;
    final scope3Count = metrics
        .where((m) => m.scope.startsWith('Scope 3'))
        .length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CarbonSummaryCard(
            totalEmissions: totalEmissions,
            scope1Count: scope1Count,
            scope2Count: scope2Count,
            scope3Count: scope3Count,
            theme: theme,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => CarbonMetricTile(metric: metrics[index]),
            childCount: metrics.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _CarbonSummaryCard extends StatelessWidget {
  const _CarbonSummaryCard({
    required this.totalEmissions,
    required this.scope1Count,
    required this.scope2Count,
    required this.scope3Count,
    required this.theme,
  });

  final double totalEmissions;
  final int scope1Count;
  final int scope2Count;
  final int scope3Count;
  final ThemeData theme;

  String _formatTotalEmissions(double tonnes) {
    if (tonnes >= 1000000) {
      return '${(tonnes / 1000000).toStringAsFixed(2)} Mt';
    } else if (tonnes >= 1000) {
      return '${(tonnes / 1000).toStringAsFixed(1)} kt';
    } else {
      return '${tonnes.toStringAsFixed(0)} t';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aggregate Carbon Footprint · FY 2024-25',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.surface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CarbonMetricStat(
                label: 'Total CO₂e',
                value: _formatTotalEmissions(totalEmissions),
                icon: Icons.cloud_outlined,
              ),
              _CarbonMetricStat(
                label: 'Scope 1',
                value: '$scope1Count records',
                icon: Icons.factory_outlined,
                color: AppColors.error,
              ),
              _CarbonMetricStat(
                label: 'Scope 2',
                value: '$scope2Count records',
                icon: Icons.bolt_outlined,
                color: AppColors.warning,
              ),
              _CarbonMetricStat(
                label: 'Scope 3',
                value: '$scope3Count records',
                icon: Icons.link_outlined,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarbonMetricStat extends StatelessWidget {
  const _CarbonMetricStat({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? AppColors.surface;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.surface.withAlpha(153),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
