import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/post_filing/data/providers/post_filing_providers.dart';
import 'package:ca_app/features/post_filing/presentation/widgets/filing_status_tile.dart';

/// Post-Filing Tracker dashboard showing summary cards, filter chips,
/// and a scrollable list of filing status tiles.
class PostFilingDashboardScreen extends ConsumerWidget {
  const PostFilingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(filingsSummaryProvider);
    final filter = ref.watch(postFilingFilterProvider);
    final filings = ref.watch(filteredFilingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post-Filing Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Monitor filings after submission',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.money_rounded),
            tooltip: 'Refund Tracker',
            onPressed: () => context.push('/post-filing/refunds'),
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
        child: RefreshIndicator(
          onRefresh: () async {
            // Mock refresh — in real app, re-fetch from API
            await Future<void>.delayed(const Duration(milliseconds: 800));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards
              _SummaryRow(summary: summary),
              const SizedBox(height: 16),
              // Filter chips
              _FilterChips(
                selected: filter,
                onSelected: (value) {
                  ref.read(postFilingFilterProvider.notifier).select(value);
                },
              ),
              const SizedBox(height: 16),
              // Filing list
              if (filings.isEmpty)
                _EmptyState(filter: filter)
              else
                ...filings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filing = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FilingStatusTile(
                      filing: filing,
                      onTap: () {
                        ref
                            .read(selectedFilingIndexProvider.notifier)
                            .select(index);
                        context.push('/post-filing/detail');
                      },
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary cards row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final FilingsSummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: [
        _SummaryCard(
          label: 'Total Filed',
          value: '${summary.totalFiled}',
          icon: Icons.description_rounded,
          color: AppColors.primary,
        ),
        _SummaryCard(
          label: 'Processed',
          value: '${summary.processed}',
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
        ),
        _SummaryCard(
          label: 'Refund Pending',
          value: '${summary.refundPending}',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.secondary,
        ),
        _SummaryCard(
          label: 'Demands',
          value: '${summary.demands}',
          icon: Icons.warning_rounded,
          color: AppColors.error,
        ),
      ],
    );
  }
}

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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final PostFilingFilter selected;
  final ValueChanged<PostFilingFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PostFilingFilter.values.map((filter) {
          final isActive = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isActive,
              onSelected: (_) => onSelected(filter),
              selectedColor: AppColors.primary.withAlpha(25),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isActive ? AppColors.primary : AppColors.neutral600,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final PostFilingFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 12),
            Text(
              'No filings match "${filter.label}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
