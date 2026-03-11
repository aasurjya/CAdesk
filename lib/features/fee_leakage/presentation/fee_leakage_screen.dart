import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/fee_leakage_providers.dart';
import '../domain/models/engagement.dart';
import '../domain/models/scope_item.dart';
import 'widgets/engagement_tile.dart';

class FeeLeakageScreen extends ConsumerStatefulWidget {
  const FeeLeakageScreen({super.key});

  @override
  ConsumerState<FeeLeakageScreen> createState() => _FeeLeakageScreenState();
}

class _FeeLeakageScreenState extends ConsumerState<FeeLeakageScreen>
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
    final summary = ref.watch(feeLeakageSummaryProvider);
    final totalLeakage = (summary['totalLeakage'] as double?) ?? 0.0;
    final onTrack = (summary['onTrack'] as int?) ?? 0;
    final overScope = (summary['overScope'] as int?) ?? 0;
    final underBilled = (summary['underBilled'] as int?) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Fee Leakage & Scope Control'),
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
            Tab(text: 'Engagements'),
            Tab(text: 'Scope Items'),
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
                  label: 'Total Leakage',
                  value: _formatLeakage(totalLeakage),
                  icon: Icons.money_off_rounded,
                  color: totalLeakage > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'On Track',
                  value: '$onTrack',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Over Scope',
                  value: '$overScope',
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Under-Billed',
                  value: '$underBilled',
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _EngagementsTab(),
                _ScopeItemsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLeakage(double amount) {
    if (amount.abs() >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
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
// Engagements tab
// ---------------------------------------------------------------------------

class _EngagementsTab extends ConsumerWidget {
  const _EngagementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engagements = ref.watch(filteredEngagementsProvider);
    final selected = ref.watch(engagementStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        _StatusFilterBar<EngagementStatus>(
          values: EngagementStatus.values,
          selected: selected,
          labelOf: (s) => s.label,
          colorOf: (s) => s.color,
          onSelected: (s) {
            ref.read(engagementStatusFilterProvider.notifier).update(
                  s == selected ? null : s,
                );
          },
        ),

        // Engagement list
        Expanded(
          child: engagements.isEmpty
              ? const _EmptyState(message: 'No engagements match the filter')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: engagements.length,
                  itemBuilder: (context, index) =>
                      EngagementTile(engagement: engagements[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Scope Items tab
// ---------------------------------------------------------------------------

class _ScopeItemsTab extends ConsumerWidget {
  const _ScopeItemsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(allScopeItemsProvider);

    return items.isEmpty
        ? const _EmptyState(message: 'No scope items found')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _ScopeItemTile(item: items[index]),
          );
  }
}

class _ScopeItemTile extends StatelessWidget {
  const _ScopeItemTile({required this.item});

  final ScopeItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final inScopeColor =
        item.isInScope ? AppColors.success : AppColors.neutral400;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scope indicator dot
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inScopeColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InScopeChip(isInScope: item.isInScope),
                      if (item.billedExtra) ...[
                        const SizedBox(width: 8),
                        _BilledExtraChip(),
                      ],
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(item.addedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
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

class _InScopeChip extends StatelessWidget {
  const _InScopeChip({required this.isInScope});

  final bool isInScope;

  @override
  Widget build(BuildContext context) {
    final color = isInScope ? AppColors.success : AppColors.neutral400;
    final label = isInScope ? 'In Scope' : 'Out of Scope';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _BilledExtraChip extends StatelessWidget {
  const _BilledExtraChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Billed Extra',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable filter bar
// ---------------------------------------------------------------------------

class _StatusFilterBar<T> extends StatelessWidget {
  const _StatusFilterBar({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.colorOf,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final Color Function(T) colorOf;
  final ValueChanged<T> onSelected;

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
          final value = values[index];
          final isActive = value == selected;
          final color = colorOf(value);

          return FilterChip(
            label: Text(labelOf(value)),
            selected: isActive,
            onSelected: (_) => onSelected(value),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : color,
            ),
            selectedColor: color,
            backgroundColor: color.withValues(alpha: 0.08),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
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
          const Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
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
