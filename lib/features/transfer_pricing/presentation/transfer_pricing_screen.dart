import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/transfer_pricing_providers.dart';
import '../domain/models/tp_study.dart';
import '../domain/models/tp_filing.dart';
import 'widgets/tp_study_tile.dart';
import 'widgets/tp_filing_tile.dart';

class TransferPricingScreen extends ConsumerStatefulWidget {
  const TransferPricingScreen({super.key});

  @override
  ConsumerState<TransferPricingScreen> createState() =>
      _TransferPricingScreenState();
}

class _TransferPricingScreenState extends ConsumerState<TransferPricingScreen>
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
    final summary = ref.watch(tpSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Transfer Pricing'),
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
            Tab(text: 'TP Studies'),
            Tab(text: 'Form 3CEB'),
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
                  label: 'Total Studies',
                  count: summary.totalStudies,
                  icon: Icons.science_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'In Progress',
                  count: summary.inProgress,
                  icon: Icons.trending_up_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Completed',
                  count: summary.completed,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: '3CEB Pending',
                  count: summary.filingsPending,
                  icon: Icons.description_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_TpStudiesTab(), _TpFilingsTab()],
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
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
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
              '$count',
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
// TP Studies tab
// ---------------------------------------------------------------------------

class _TpStudiesTab extends ConsumerWidget {
  const _TpStudiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studies = ref.watch(filteredTpStudiesProvider);
    final selectedStatus = ref.watch(tpStudyStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: TpStudyStatus.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final status = TpStudyStatus.values[index];
              final isActive = status == selectedStatus;

              return FilterChip(
                label: Text(status.label),
                selected: isActive,
                onSelected: (_) {
                  ref
                      .read(tpStudyStatusFilterProvider.notifier)
                      .update(status == selectedStatus ? null : status);
                },
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : status.color,
                ),
                selectedColor: status.color,
                backgroundColor: status.color.withValues(alpha: 0.08),
                side: BorderSide(color: status.color.withValues(alpha: 0.3)),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),

        // Studies list
        Expanded(
          child: studies.isEmpty
              ? const _EmptyState(message: 'No TP studies match the filter')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: studies.length,
                  itemBuilder: (context, index) =>
                      TpStudyTile(study: studies[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Form 3CEB tab
// ---------------------------------------------------------------------------

class _TpFilingsTab extends ConsumerWidget {
  const _TpFilingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filings = ref.watch(filteredTpFilingsProvider);
    final selectedStatus = ref.watch(tpFilingStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: TpFilingStatus.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final status = TpFilingStatus.values[index];
              final isActive = status == selectedStatus;

              return FilterChip(
                label: Text(status.label),
                selected: isActive,
                onSelected: (_) {
                  ref
                      .read(tpFilingStatusFilterProvider.notifier)
                      .update(status == selectedStatus ? null : status);
                },
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : status.color,
                ),
                selectedColor: status.color,
                backgroundColor: status.color.withValues(alpha: 0.08),
                side: BorderSide(color: status.color.withValues(alpha: 0.3)),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),

        // Filings list
        Expanded(
          child: filings.isEmpty
              ? const _EmptyState(
                  message: 'No Form 3CEB filings match the filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: filings.length,
                  itemBuilder: (context, index) =>
                      TpFilingTile(filing: filings[index]),
                ),
        ),
      ],
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
