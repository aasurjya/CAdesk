import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/industry_playbooks/data/providers/industry_playbooks_providers.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/vertical_playbook.dart';
import 'package:ca_app/features/industry_playbooks/presentation/widgets/playbook_card.dart';
import 'package:ca_app/features/industry_playbooks/presentation/widgets/service_bundle_tile.dart';

/// Screen listing all industry-vertical tax playbooks and productized bundles.
class IndustryPlaybooksScreen extends ConsumerWidget {
  const IndustryPlaybooksScreen({super.key});

  static const _filterLabels = <String, String?>{
    'All': null,
    'E-Commerce': 'e-commerce',
    'Exporters': 'exporters',
    'Doctors': 'doctors',
    'Real Estate': 'real-estate',
    'SaaS': 'saas',
    'Creators': 'creators',
    'Manufacturing': 'manufacturing',
    'Hospitality': 'hospitality',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbooks = ref.watch(filteredPlaybooksProvider);
    final allPlaybooks = ref.watch(allPlaybooksProvider);
    final allBundles = ref.watch(allServiceBundlesProvider);
    final selectedVertical = ref.watch(selectedVerticalProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text(
          'Industry Playbooks',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.surface,
          ),
        ),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Summary card
          SliverToBoxAdapter(
            child: _SummaryCard(playbooks: allPlaybooks),
          ),

          // Horizontal filter chips
          SliverToBoxAdapter(
            child: _FilterChipRow(
              labels: _filterLabels,
              selectedVertical: selectedVertical,
              onSelected: (value) =>
                  ref.read(selectedVerticalProvider.notifier).select(value),
            ),
          ),

          // Playbooks list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlaybookCard(playbook: playbooks[index]),
                ),
                childCount: playbooks.length,
              ),
            ),
          ),

          // Service Bundles header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _SectionHeader(
                title: 'All Service Bundles',
                subtitle: 'Productized offerings across verticals',
              ),
            ),
          ),

          // Service Bundles list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) => ServiceBundleTile(bundle: allBundles[index]),
                childCount: allBundles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.playbooks});

  final List<VerticalPlaybook> playbooks;

  @override
  Widget build(BuildContext context) {
    final totalClients = playbooks.fold<int>(0, (sum, p) => sum + p.activeClients);
    final avgWinRate = playbooks.isEmpty
        ? 0.0
        : playbooks.fold<double>(0, (sum, p) => sum + p.winRate) / playbooks.length;

    final bestPlaybook = playbooks.isEmpty
        ? null
        : playbooks.reduce((a, b) => a.marginPercent > b.marginPercent ? a : b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Practice Overview',
            style: TextStyle(
              color: AppColors.surface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryMetric(
                label: 'Verticals',
                value: '${playbooks.length}',
              ),
              const _SummaryDivider(),
              _SummaryMetric(
                label: 'Total Clients',
                value: '$totalClients',
              ),
              const _SummaryDivider(),
              _SummaryMetric(
                label: 'Avg Win Rate',
                value: '${(avgWinRate * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
          if (bestPlaybook != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(bestPlaybook.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Best Margin Vertical',
                        style: TextStyle(
                          color: AppColors.neutral200,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${bestPlaybook.vertical.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')} '
                        '— ${(bestPlaybook.marginPercent * 100).toStringAsFixed(0)}% margin',
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.surface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral200,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.surface.withAlpha(60),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip row
// ---------------------------------------------------------------------------

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.labels,
    required this.selectedVertical,
    required this.onSelected,
  });

  final Map<String, String?> labels;
  final String? selectedVertical;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: labels.entries.map((entry) {
          final isSelected = selectedVertical == entry.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.key),
              selected: isSelected,
              onSelected: (_) => onSelected(entry.value),
              selectedColor: AppColors.primary.withAlpha(220),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.surface : AppColors.neutral900,
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.neutral300,
              ),
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.neutral200, height: 1),
        const SizedBox(height: 8),
      ],
    );
  }
}
