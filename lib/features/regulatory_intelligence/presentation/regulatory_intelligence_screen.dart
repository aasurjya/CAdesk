import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/regulatory_intelligence/data/providers/regulatory_intelligence_providers.dart';
import 'package:ca_app/features/regulatory_intelligence/presentation/widgets/circular_card.dart';
import 'package:ca_app/features/regulatory_intelligence/presentation/widgets/impact_alert_tile.dart';

/// Main Regulatory Intelligence screen with a daily digest, circulars tab,
/// and client alerts tab.
class RegulatoryIntelligenceScreen extends ConsumerWidget {
  const RegulatoryIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Regulatory Intelligence'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Circulars'),
              Tab(text: 'Client Alerts'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.neutral400,
          ),
        ),
        body: const _ScreenBody(),
      ),
    );
  }
}

class _ScreenBody extends ConsumerWidget {
  const _ScreenBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCirculars = ref.watch(allCircularsProvider);
    final allAlerts = ref.watch(allImpactAlertsProvider);

    final todayCircularsCount = allCirculars
        .where((c) => c.issueDate.contains('2026'))
        .length;
    final highImpactCount = allCirculars
        .where((c) => c.impactLevel == 'High')
        .length;
    final totalAffectedClients = allCirculars.fold<int>(
      0,
      (sum, c) => sum + c.affectedClientsCount,
    );
    final urgentAlertsCount = allAlerts
        .where((a) => a.urgency == 'Urgent')
        .length;

    return TabBarView(
      children: [
        _CircularsTab(
          todayCount: todayCircularsCount,
          highImpactCount: highImpactCount,
          totalAffectedClients: totalAffectedClients,
        ),
        _AlertsTab(
          urgentCount: urgentAlertsCount,
          totalAlerts: allAlerts.length,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Circulars tab
// ---------------------------------------------------------------------------

class _CircularsTab extends ConsumerWidget {
  const _CircularsTab({
    required this.todayCount,
    required this.highImpactCount,
    required this.totalAffectedClients,
  });

  final int todayCount;
  final int highImpactCount;
  final int totalAffectedClients;

  static const _categories = [
    'Income Tax',
    'GST',
    'MCA',
    'RBI',
    'SEBI',
    'Labour',
    'ICAI',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circulars = ref.watch(filteredCircularsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _DigestCard(
            todayCount: todayCount,
            highImpactCount: highImpactCount,
            totalAffectedClients: totalAffectedClients,
          ),
        ),
        SliverToBoxAdapter(
          child: _CategoryFilterRow(
            categories: _categories,
            selectedCategory: selectedCategory,
            onSelected: (cat) {
              ref.read(selectedCategoryProvider.notifier).select(cat);
            },
          ),
        ),
        if (circulars.isEmpty)
          const SliverFillRemaining(child: _EmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => CircularCard(circular: circulars[index]),
              childCount: circulars.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Alerts tab
// ---------------------------------------------------------------------------

class _AlertsTab extends ConsumerWidget {
  const _AlertsTab({required this.urgentCount, required this.totalAlerts});

  final int urgentCount;
  final int totalAlerts;

  static const _urgencies = ['Urgent', 'Normal', 'Low'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(filteredAlertsProvider);
    final selectedUrgency = ref.watch(selectedUrgencyProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _AlertsSummaryCard(
            urgentCount: urgentCount,
            totalAlerts: totalAlerts,
          ),
        ),
        SliverToBoxAdapter(
          child: _UrgencyFilterRow(
            urgencies: _urgencies,
            selectedUrgency: selectedUrgency,
            onSelected: (u) {
              ref.read(selectedUrgencyProvider.notifier).select(u);
            },
          ),
        ),
        if (alerts.isEmpty)
          const SliverFillRemaining(child: _EmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ImpactAlertTile(alert: alerts[index]),
              childCount: alerts.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Digest card
// ---------------------------------------------------------------------------

class _DigestCard extends StatelessWidget {
  const _DigestCard({
    required this.todayCount,
    required this.highImpactCount,
    required this.totalAffectedClients,
  });

  final int todayCount;
  final int highImpactCount;
  final int totalAffectedClients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.surface,
              ),
              const SizedBox(width: 6),
              Text(
                'Today\'s Digest — 11 Mar 2026',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DigestStat(
                label: 'New Circulars',
                value: '$todayCount',
                icon: Icons.article_rounded,
              ),
              const _DigestDivider(),
              _DigestStat(
                label: 'High Impact',
                value: '$highImpactCount',
                icon: Icons.warning_amber_rounded,
              ),
              const _DigestDivider(),
              _DigestStat(
                label: 'Clients Affected',
                value: '$totalAffectedClients',
                icon: Icons.people_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DigestStat extends StatelessWidget {
  const _DigestStat({
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
          Icon(icon, size: 20, color: AppColors.surface),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.surface.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DigestDivider extends StatelessWidget {
  const _DigestDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.surface.withAlpha(60),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ---------------------------------------------------------------------------
// Alerts summary card
// ---------------------------------------------------------------------------

class _AlertsSummaryCard extends StatelessWidget {
  const _AlertsSummaryCard({
    required this.urgentCount,
    required this.totalAlerts,
  });

  final int urgentCount;
  final int totalAlerts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            size: 28,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$urgentCount urgent alerts need your attention',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  '$totalAlerts total client impact alerts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
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
// Filter rows
// ---------------------------------------------------------------------------

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () => onSelected(null),
          ),
          ...categories.map(
            (cat) => _FilterChip(
              label: cat,
              isSelected: selectedCategory == cat,
              onTap: () => onSelected(selectedCategory == cat ? null : cat),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyFilterRow extends StatelessWidget {
  const _UrgencyFilterRow({
    required this.urgencies,
    required this.selectedUrgency,
    required this.onSelected,
  });

  final List<String> urgencies;
  final String? selectedUrgency;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedUrgency == null,
            onTap: () => onSelected(null),
          ),
          ...urgencies.map(
            (u) => _FilterChip(
              label: u,
              isSelected: selectedUrgency == u,
              onTap: () => onSelected(selectedUrgency == u ? null : u),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withAlpha(45),
        checkmarkColor: AppColors.accent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.neutral600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.policy_rounded,
            size: 64,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try selecting a different filter.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
