import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/lead_funnel_providers.dart';
import '../domain/models/lead.dart';
import 'widgets/campaign_tile.dart';
import 'widgets/lead_tile.dart';

class LeadFunnelScreen extends ConsumerStatefulWidget {
  const LeadFunnelScreen({super.key});

  @override
  ConsumerState<LeadFunnelScreen> createState() => _LeadFunnelScreenState();
}

class _LeadFunnelScreenState extends ConsumerState<LeadFunnelScreen>
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
    final summary = ref.watch(leadFunnelSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Lead Funnel & Campaigns'),
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
            Tab(text: 'Leads'),
            Tab(text: 'Campaigns'),
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
                  label: 'Total Leads',
                  value: '${summary['totalLeads']}',
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'New This Week',
                  value: '${summary['newThisWeek']}',
                  icon: Icons.fiber_new_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Won',
                  value: '${summary['won']}',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Pipeline',
                  value: '${summary['totalPipelineValue']}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_LeadsTab(), _CampaignsTab()],
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
// Leads tab
// ---------------------------------------------------------------------------

class _LeadsTab extends ConsumerWidget {
  const _LeadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(filteredLeadsProvider);
    final selectedStage = ref.watch(leadStageFilterProvider);

    return Column(
      children: [
        // Stage filter chips
        _StageFilterBar(
          selected: selectedStage,
          onSelected: (stage) {
            ref
                .read(leadStageFilterProvider.notifier)
                .update(stage == selectedStage ? null : stage);
          },
        ),

        // Leads list
        Expanded(
          child: leads.isEmpty
              ? const _EmptyState(message: 'No leads match the selected stage')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: leads.length,
                  itemBuilder: (context, index) => LeadTile(lead: leads[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Campaigns tab
// ---------------------------------------------------------------------------

class _CampaignsTab extends ConsumerWidget {
  const _CampaignsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(allCampaignsProvider);

    return campaigns.isEmpty
        ? const _EmptyState(message: 'No campaigns found')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: campaigns.length,
            itemBuilder: (context, index) =>
                CampaignTile(campaign: campaigns[index]),
          );
  }
}

// ---------------------------------------------------------------------------
// Stage filter bar
// ---------------------------------------------------------------------------

class _StageFilterBar extends StatelessWidget {
  const _StageFilterBar({required this.selected, required this.onSelected});

  final LeadStage? selected;
  final ValueChanged<LeadStage> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: LeadStage.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final stage = LeadStage.values[index];
          final isActive = stage == selected;

          return FilterChip(
            label: Text(stage.label),
            selected: isActive,
            onSelected: (_) => onSelected(stage),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : stage.color,
            ),
            selectedColor: stage.color,
            backgroundColor: stage.color.withValues(alpha: 0.08),
            side: BorderSide(color: stage.color.withValues(alpha: 0.3)),
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
          const Icon(
            Icons.inbox_rounded,
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
