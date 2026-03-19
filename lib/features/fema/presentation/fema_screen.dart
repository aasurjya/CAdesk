import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/fema_providers.dart';
import '../domain/models/fema_filing.dart';
import '../domain/models/fdi_transaction.dart';
import 'widgets/fema_filing_tile.dart';
import 'widgets/fdi_transaction_tile.dart';

class FemaScreen extends ConsumerStatefulWidget {
  const FemaScreen({super.key});

  @override
  ConsumerState<FemaScreen> createState() => _FemaScreenState();
}

class _FemaScreenState extends ConsumerState<FemaScreen>
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
    final summary = ref.watch(femaSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('FEMA & RBI Compliance'),
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
            Tab(text: 'Filings'),
            Tab(text: 'FDI Tracker'),
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
                  label: 'Total Filings',
                  count: summary.totalFilings,
                  icon: Icons.description_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Pending',
                  count: summary.pendingFilings,
                  icon: Icons.hourglass_empty_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Overdue',
                  count: summary.overdueFilings,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Active FDI',
                  count: summary.activeFdiTransactions,
                  icon: Icons.trending_up_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_FilingsTab(), _FdiTrackerTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card widget
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
// Filings tab
// ---------------------------------------------------------------------------

class _FilingsTab extends ConsumerWidget {
  const _FilingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filings = ref.watch(filteredFemaFilingsProvider);
    final selectedStatus = ref.watch(femaStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        _StatusFilterBar<FemaFilingStatus>(
          values: FemaFilingStatus.values,
          selected: selectedStatus,
          labelOf: (s) => s.label,
          colorOf: (s) => s.color,
          onSelected: (s) {
            ref
                .read(femaStatusFilterProvider.notifier)
                .update(s == selectedStatus ? null : s);
          },
        ),

        // Filing list
        Expanded(
          child: filings.isEmpty
              ? const _EmptyState(
                  message: 'No filings match the selected filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: filings.length,
                  itemBuilder: (context, index) =>
                      FemaFilingTile(filing: filings[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FDI Tracker tab
// ---------------------------------------------------------------------------

class _FdiTrackerTab extends ConsumerWidget {
  const _FdiTrackerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredFdiTransactionsProvider);
    final selectedStatus = ref.watch(fdiStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        _StatusFilterBar<FdiTransactionStatus>(
          values: FdiTransactionStatus.values,
          selected: selectedStatus,
          labelOf: (s) => s.label,
          colorOf: (s) => s.color,
          onSelected: (s) {
            ref
                .read(fdiStatusFilterProvider.notifier)
                .update(s == selectedStatus ? null : s);
          },
        ),

        // Transaction list
        Expanded(
          child: transactions.isEmpty
              ? const _EmptyState(
                  message: 'No FDI transactions match the selected filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) =>
                      FdiTransactionTile(transaction: transactions[index]),
                ),
        ),
      ],
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
