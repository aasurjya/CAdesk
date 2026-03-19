import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/regulatory_trust_providers.dart';
import '../domain/models/security_control.dart';
import 'widgets/security_control_tile.dart';
import 'widgets/vapt_scan_tile.dart';

class RegulatoryTrustScreen extends ConsumerStatefulWidget {
  const RegulatoryTrustScreen({super.key});

  @override
  ConsumerState<RegulatoryTrustScreen> createState() =>
      _RegulatoryTrustScreenState();
}

class _RegulatoryTrustScreenState extends ConsumerState<RegulatoryTrustScreen>
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
    final summary = ref.watch(regulatoryTrustSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Regulatory Trust & Security'),
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
            Tab(text: 'Controls'),
            Tab(text: 'VAPT Scans'),
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
                  label: 'Total Controls',
                  count: summary.totalControls,
                  icon: Icons.shield_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Compliant',
                  count: summary.compliantControls,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Non-Compliant',
                  count: summary.nonCompliantControls,
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Upcoming VAPTs',
                  count: summary.upcomingVapts,
                  icon: Icons.security_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_ControlsTab(), _VaptScansTab()],
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
// Controls tab
// ---------------------------------------------------------------------------

class _ControlsTab extends ConsumerWidget {
  const _ControlsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controls = ref.watch(filteredControlsProvider);
    final selectedStatus = ref.watch(controlStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        _StatusFilterBar<SecurityControlStatus>(
          values: SecurityControlStatus.values,
          selected: selectedStatus,
          labelOf: (s) => s.label,
          colorOf: (s) => s.color,
          onSelected: (s) {
            ref
                .read(controlStatusFilterProvider.notifier)
                .update(s == selectedStatus ? null : s);
          },
        ),

        // Controls list
        Expanded(
          child: controls.isEmpty
              ? const _EmptyState(
                  message: 'No controls match the selected filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: controls.length,
                  itemBuilder: (context, index) =>
                      SecurityControlTile(control: controls[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// VAPT Scans tab
// ---------------------------------------------------------------------------

class _VaptScansTab extends ConsumerWidget {
  const _VaptScansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scans = ref.watch(vaptScansProvider);

    return scans.isEmpty
        ? const _EmptyState(message: 'No VAPT scans available')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: scans.length,
            itemBuilder: (context, index) => VaptScanTile(scan: scans[index]),
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
        separatorBuilder: (_, _) => const SizedBox(width: 8),
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
