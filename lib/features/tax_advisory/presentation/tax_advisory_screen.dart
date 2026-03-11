import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/tax_advisory_providers.dart';
import '../domain/models/advisory_opportunity.dart';
import 'widgets/opportunity_tile.dart';
import 'widgets/proposal_tile.dart';

class TaxAdvisoryScreen extends ConsumerStatefulWidget {
  const TaxAdvisoryScreen({super.key});

  @override
  ConsumerState<TaxAdvisoryScreen> createState() => _TaxAdvisoryScreenState();
}

class _TaxAdvisoryScreenState extends ConsumerState<TaxAdvisoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(advisorySummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Tax Advisory Engine'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Opportunities'),
            Tab(text: 'Proposals'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _SummaryCard(
                  label: 'Total',
                  value: '${summary['total']}',
                  icon: Icons.lightbulb_outline_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'High Priority',
                  value: '${summary['highPriority']}',
                  icon: Icons.priority_high_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Converted',
                  value: '${summary['converted']}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Pipeline',
                  value: '${summary['totalFeesPipeline']}',
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_OpportunitiesTab(), _ProposalsTab()],
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
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Opportunities tab
// ---------------------------------------------------------------------------

class _OpportunitiesTab extends ConsumerWidget {
  const _OpportunitiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunities = ref.watch(filteredOpportunitiesProvider);
    final selectedType = ref.watch(opportunityTypeFilterProvider);

    return Column(
      children: [
        // Type filter chips (scrollable horizontal)
        _TypeFilterBar(
          values: OpportunityType.values,
          selected: selectedType,
          onSelected: (type) {
            ref
                .read(opportunityTypeFilterProvider.notifier)
                .update(type == selectedType ? null : type);
          },
        ),

        // Opportunities list
        Expanded(
          child: opportunities.isEmpty
              ? const _EmptyState(
                  message: 'No opportunities match the selected filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: opportunities.length,
                  itemBuilder: (context, index) =>
                      OpportunityTile(opportunity: opportunities[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Proposals tab
// ---------------------------------------------------------------------------

class _ProposalsTab extends ConsumerWidget {
  const _ProposalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposals = ref.watch(allProposalsProvider);

    return proposals.isEmpty
        ? const _EmptyState(message: 'No proposals have been created')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: proposals.length,
            itemBuilder: (context, index) =>
                ProposalTile(proposal: proposals[index]),
          );
  }
}

// ---------------------------------------------------------------------------
// Type filter bar
// ---------------------------------------------------------------------------

class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<OpportunityType> values;
  final OpportunityType? selected;
  final ValueChanged<OpportunityType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = values[index];
          final isActive = type == selected;

          return FilterChip(
            avatar: Icon(
              type.icon,
              size: 14,
              color: isActive ? Colors.white : type.color,
            ),
            label: Text(type.label),
            selected: isActive,
            onSelected: (_) => onSelected(type),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : type.color,
            ),
            selectedColor: type.color,
            backgroundColor: type.color.withValues(alpha: 0.08),
            side: BorderSide(color: type.color.withValues(alpha: 0.3)),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 48,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
