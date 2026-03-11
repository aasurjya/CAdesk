import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/sme_cfo_providers.dart';
import '../domain/models/cfo_retainer.dart';
import 'widgets/cfo_retainer_tile.dart';
import 'widgets/cfo_deliverable_tile.dart';

class SmeCfoScreen extends ConsumerStatefulWidget {
  const SmeCfoScreen({super.key});

  @override
  ConsumerState<SmeCfoScreen> createState() => _SmeCfoScreenState();
}

class _SmeCfoScreenState extends ConsumerState<SmeCfoScreen>
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
    final summary = ref.watch(cfoDashboardSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('SME CFO Retainers'),
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
            Tab(text: 'Retainers'),
            Tab(text: 'Deliverables'),
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
                  value: '${summary['totalRetainers']}',
                  icon: Icons.handshake_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Active',
                  value: '${summary['activeRetainers']}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Monthly Rev',
                  value: '${summary['monthlyRevenue']}',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Avg Health',
                  value: '${summary['avgHealthScore']}',
                  icon: Icons.favorite_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _RetainersTab(),
                _DeliverablesTab(),
              ],
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
// Retainers tab
// ---------------------------------------------------------------------------

class _RetainersTab extends ConsumerWidget {
  const _RetainersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retainers = ref.watch(filteredRetainersProvider);
    final selectedStatus = ref.watch(retainerStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        _StatusFilterBar<CfoRetainerStatus>(
          values: CfoRetainerStatus.values,
          selected: selectedStatus,
          labelOf: (s) => s.label,
          colorOf: (s) => s.color,
          onSelected: (s) {
            ref
                .read(retainerStatusFilterProvider.notifier)
                .update(s == selectedStatus ? null : s);
          },
        ),

        // Retainer list
        Expanded(
          child: retainers.isEmpty
              ? const _EmptyState(
                  icon: Icons.handshake_rounded,
                  message: 'No retainers match the selected filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: retainers.length,
                  itemBuilder: (context, index) =>
                      CfoRetainerTile(retainer: retainers[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Deliverables tab
// ---------------------------------------------------------------------------

class _DeliverablesTab extends ConsumerWidget {
  const _DeliverablesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliverables = ref.watch(allDeliverablesProvider);

    return deliverables.isEmpty
        ? const _EmptyState(
            icon: Icons.checklist_rounded,
            message: 'No deliverables found',
          )
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: deliverables.length,
            itemBuilder: (context, index) =>
                CfoDeliverableTile(deliverable: deliverables[index]),
          );
  }
}

// ---------------------------------------------------------------------------
// Reusable status filter bar
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
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.neutral200),
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
