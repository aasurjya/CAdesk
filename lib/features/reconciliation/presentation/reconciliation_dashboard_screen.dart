import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/reconciliation/data/providers/reconciliation_providers.dart';
import 'package:ca_app/features/reconciliation/presentation/widgets/match_summary_card.dart';
import 'package:ca_app/features/reconciliation/presentation/widgets/recon_entry_tile.dart';

/// Top-level reconciliation dashboard showing summary cards, tab selector
/// for source comparisons, and a filterable list of reconciliation entries.
class ReconciliationDashboardScreen extends ConsumerWidget {
  const ReconciliationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconAsync = ref.watch(reconResultsProvider);
    final summary = ref.watch(reconSummaryProvider);
    final entries = ref.watch(filteredReconEntriesProvider);
    final activeFilter = ref.watch(reconFilterProvider);
    final activeTab = ref.watch(reconTabProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reconciliation',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              '26AS vs AIS vs ITR three-way match',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: reconAsync.isLoading && entries.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : reconAsync.hasError && entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load reconciliation data',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(reconResultsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : isWide
            ? _WideLayout(
                summary: summary,
                entries: entries,
                activeFilter: activeFilter,
                activeTab: activeTab,
                ref: ref,
              )
            : _NarrowLayout(
                summary: summary,
                entries: entries,
                activeFilter: activeFilter,
                activeTab: activeTab,
                ref: ref,
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow (phone) layout
// ---------------------------------------------------------------------------

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.summary,
    required this.entries,
    required this.activeFilter,
    required this.activeTab,
    required this.ref,
  });

  final ReconSummary summary;
  final List<ReconEntry> entries;
  final ReconEntryStatus? activeFilter;
  final ReconTab activeTab;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ClientAySelector(),
        const SizedBox(height: 14),
        _SummaryRow(summary: summary),
        const SizedBox(height: 14),
        MatchSummaryCard(summary: summary),
        const SizedBox(height: 14),
        _TabBar(activeTab: activeTab, ref: ref),
        const SizedBox(height: 10),
        _FilterChips(activeFilter: activeFilter, ref: ref),
        const SizedBox(height: 10),
        _RunReconButton(),
        const SizedBox(height: 14),
        ...entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ReconEntryTile(
              entry: e,
              onTap: () => context.push('/reconciliation/detail', extra: e),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Wide (tablet) layout — side-by-side panels
// ---------------------------------------------------------------------------

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.summary,
    required this.entries,
    required this.activeFilter,
    required this.activeTab,
    required this.ref,
  });

  final ReconSummary summary;
  final List<ReconEntry> entries;
  final ReconEntryStatus? activeFilter;
  final ReconTab activeTab;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel: summary
        SizedBox(
          width: 340,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ClientAySelector(),
              const SizedBox(height: 14),
              _SummaryRow(summary: summary),
              const SizedBox(height: 14),
              MatchSummaryCard(summary: summary),
              const SizedBox(height: 14),
              _RunReconButton(),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right panel: entries
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TabBar(activeTab: activeTab, ref: ref),
              const SizedBox(height: 10),
              _FilterChips(activeFilter: activeFilter, ref: ref),
              const SizedBox(height: 10),
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ReconEntryTile(
                    entry: e,
                    onTap: () =>
                        context.push('/reconciliation/detail', extra: e),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _ClientAySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutral100),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rajesh Sharma',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.neutral400,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral100),
          ),
          child: Row(
            children: [
              Text(
                'AY 2025-26',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final ReconSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(
          label: 'Total',
          value: '${summary.total}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Matched',
          value: '${summary.matched}',
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Mismatch',
          value: '${summary.mismatched}',
          color: AppColors.warning,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Missing',
          value: '${summary.missing}',
          color: AppColors.error,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withAlpha(180),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.activeTab, required this.ref});

  final ReconTab activeTab;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReconTab.values.map((tab) {
          final isActive = tab == activeTab;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(tab.label),
              selected: isActive,
              onSelected: (_) =>
                  ref.read(reconTabProvider.notifier).select(tab),
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.surface : AppColors.neutral600,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isActive ? AppColors.primary : AppColors.neutral200,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.activeFilter, required this.ref});

  final ReconEntryStatus? activeFilter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, theme, null, 'All'),
          ...ReconEntryStatus.values.map(
            (s) => _buildChip(context, theme, s, s.label),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    ThemeData theme,
    ReconEntryStatus? status,
    String label,
  ) {
    final isActive = activeFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) =>
            ref.read(reconFilterProvider.notifier).select(status),
        labelStyle: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.surface : AppColors.neutral600,
        ),
        selectedColor: AppColors.secondary,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isActive ? AppColors.secondary : AppColors.neutral200,
        ),
      ),
    );
  }
}

class _RunReconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Running reconciliation...')),
        );
      },
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text('Run Reconciliation'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
