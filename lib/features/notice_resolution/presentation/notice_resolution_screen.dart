import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/notice_resolution_providers.dart';
import '../domain/models/notice_case.dart';
import 'widgets/notice_case_tile.dart';
import 'widgets/notice_stats_card.dart';

class NoticeResolutionScreen extends ConsumerStatefulWidget {
  const NoticeResolutionScreen({super.key});

  @override
  ConsumerState<NoticeResolutionScreen> createState() =>
      _NoticeResolutionScreenState();
}

class _NoticeResolutionScreenState extends ConsumerState<NoticeResolutionScreen>
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
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Notice Resolution Center'),
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
            Tab(text: 'Active Notices'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary stats row
          const NoticeStatsCard(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_ActiveNoticesTab(), _ResolvedNoticesTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active Notices tab
// ---------------------------------------------------------------------------

class _ActiveNoticesTab extends ConsumerWidget {
  const _ActiveNoticesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredNoticeCasesProvider);
    final selectedSeverity = ref.watch(noticeSeverityFilterProvider);

    final activeNotices = filtered
        .where((c) => c.status != NoticeStatus.closed)
        .toList();

    return Column(
      children: [
        // Severity filter chips
        _SeverityFilterBar(
          values: NoticeSeverity.values,
          selected: selectedSeverity,
          onSelected: (severity) {
            ref
                .read(noticeSeverityFilterProvider.notifier)
                .update(severity == selectedSeverity ? null : severity);
          },
        ),

        // Notice list
        Expanded(
          child: activeNotices.isEmpty
              ? const _EmptyState(message: 'No active notices match the filter')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: activeNotices.length,
                  itemBuilder: (context, index) =>
                      NoticeCaseTile(notice: activeNotices[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Resolved Notices tab
// ---------------------------------------------------------------------------

class _ResolvedNoticesTab extends ConsumerWidget {
  const _ResolvedNoticesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotices = ref.watch(allNoticeCasesProvider);
    final resolvedNotices = allNotices
        .where((c) => c.status == NoticeStatus.closed)
        .toList();

    return resolvedNotices.isEmpty
        ? const _EmptyState(message: 'No resolved notices yet')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: resolvedNotices.length,
            itemBuilder: (context, index) =>
                NoticeCaseTile(notice: resolvedNotices[index]),
          );
  }
}

// ---------------------------------------------------------------------------
// Severity filter bar
// ---------------------------------------------------------------------------

class _SeverityFilterBar extends StatelessWidget {
  const _SeverityFilterBar({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<NoticeSeverity> values;
  final NoticeSeverity? selected;
  final ValueChanged<NoticeSeverity> onSelected;

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
          final color = value.color;

          return FilterChip(
            label: Text(value.label),
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
