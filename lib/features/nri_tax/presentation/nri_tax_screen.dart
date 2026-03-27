import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/nri_tax_providers.dart';
import '../domain/models/nri_client.dart';
import 'widgets/nri_client_tile.dart';
import 'widgets/foreign_asset_tile.dart';

class NriTaxScreen extends ConsumerStatefulWidget {
  const NriTaxScreen({super.key});

  @override
  ConsumerState<NriTaxScreen> createState() => _NriTaxScreenState();
}

class _NriTaxScreenState extends ConsumerState<NriTaxScreen>
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
    final summary = ref.watch(nriSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('NRI & Cross-Border Tax'),
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
            Tab(text: 'NRI Clients'),
            Tab(text: 'Foreign Assets'),
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
                  label: 'Total Clients',
                  count: summary['totalClients'] ?? 0,
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'DTAA Applicable',
                  count: summary['dtaaApplicable'] ?? 0,
                  icon: Icons.handshake_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Pending Docs',
                  count: summary['pendingDocuments'] ?? 0,
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Filing Due',
                  count: summary['filingDue'] ?? 0,
                  icon: Icons.assignment_late_rounded,
                  color: AppColors.error,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_NriClientsTab(), _ForeignAssetsTab()],
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
// NRI Clients tab
// ---------------------------------------------------------------------------

class _NriClientsTab extends ConsumerWidget {
  const _NriClientsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(filteredNriClientsProvider);
    final selectedStatus = ref.watch(nriStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        _StatusFilterBar<NriClientStatus>(
          values: NriClientStatus.values,
          selected: selectedStatus,
          labelOf: (s) => s.label,
          colorOf: (s) => s.color,
          onSelected: (s) {
            ref
                .read(nriStatusFilterProvider.notifier)
                .update(s == selectedStatus ? null : s);
          },
        ),

        // Client list
        Expanded(
          child: clients.isEmpty
              ? const _EmptyState(
                  message: 'No NRI clients match the selected filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: clients.length,
                  itemBuilder: (context, index) =>
                      NriClientTile(client: clients[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Foreign Assets tab
// ---------------------------------------------------------------------------

class _ForeignAssetsTab extends ConsumerWidget {
  const _ForeignAssetsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(allForeignAssetsProvider);

    return assets.isEmpty
        ? const _EmptyState(message: 'No foreign assets have been recorded')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: assets.length,
            itemBuilder: (context, index) =>
                ForeignAssetTile(asset: assets[index]),
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
