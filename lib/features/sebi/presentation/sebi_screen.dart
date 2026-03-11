import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/sebi_providers.dart';
import '../domain/models/sebi_disclosure.dart';
import '../domain/models/material_event.dart';
import 'widgets/disclosure_tile.dart';
import 'widgets/material_event_tile.dart';

class SebiScreen extends ConsumerStatefulWidget {
  const SebiScreen({super.key});

  @override
  ConsumerState<SebiScreen> createState() => _SebiScreenState();
}

class _SebiScreenState extends ConsumerState<SebiScreen>
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
    final summary = ref.watch(sebiSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('SEBI & Capital Market'),
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
            Tab(text: 'Disclosures'),
            Tab(text: 'Material Events'),
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
                  count: summary.totalDisclosures,
                  icon: Icons.article_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Pending',
                  count: summary.pendingDisclosures,
                  icon: Icons.hourglass_empty_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Overdue',
                  count: summary.overdueDisclosures,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Urgent',
                  count: summary.urgentEvents,
                  icon: Icons.notification_important_rounded,
                  color: const Color(0xFFC62828),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_DisclosuresTab(), _MaterialEventsTab()],
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
// Disclosures tab
// ---------------------------------------------------------------------------

class _DisclosuresTab extends ConsumerWidget {
  const _DisclosuresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disclosures = ref.watch(filteredDisclosuresProvider);
    final selectedStatus = ref.watch(disclosureStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: DisclosureStatus.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final status = DisclosureStatus.values[index];
              final isActive = status == selectedStatus;

              return FilterChip(
                label: Text(status.label),
                selected: isActive,
                onSelected: (_) {
                  ref
                      .read(disclosureStatusFilterProvider.notifier)
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

        // Disclosure list
        Expanded(
          child: disclosures.isEmpty
              ? _EmptyState(message: 'No disclosures match the filter')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: disclosures.length,
                  itemBuilder: (context, index) =>
                      DisclosureTile(disclosure: disclosures[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Material Events tab
// ---------------------------------------------------------------------------

class _MaterialEventsTab extends ConsumerWidget {
  const _MaterialEventsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(filteredMaterialEventsProvider);
    final selectedType = ref.watch(materialEventTypeFilterProvider);

    return Column(
      children: [
        // Event type filter chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: MaterialEventType.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final type = MaterialEventType.values[index];
              final isActive = type == selectedType;

              return FilterChip(
                label: Text(type.label),
                selected: isActive,
                onSelected: (_) {
                  ref
                      .read(materialEventTypeFilterProvider.notifier)
                      .update(type == selectedType ? null : type);
                },
                labelStyle: TextStyle(
                  fontSize: 12,
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
        ),

        // Events list
        Expanded(
          child: events.isEmpty
              ? _EmptyState(message: 'No material events match the filter')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: events.length,
                  itemBuilder: (context, index) =>
                      MaterialEventTile(event: events[index]),
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
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
