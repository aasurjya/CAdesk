import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/litigation/data/providers/litigation_providers.dart';
import 'package:ca_app/features/litigation/domain/models/notice_triage_result.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/presentation/widgets/notice_tile.dart';

/// Dashboard screen listing all tax notices with summary stats and filter chips.
class LitigationDashboardScreen extends ConsumerStatefulWidget {
  const LitigationDashboardScreen({super.key});

  @override
  ConsumerState<LitigationDashboardScreen> createState() =>
      _LitigationDashboardScreenState();
}

class _LitigationDashboardScreenState
    extends ConsumerState<LitigationDashboardScreen> {
  UrgencyLevel? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notices = ref.watch(noticeListProvider);
    final triageMap = ref.watch(triageResultsProvider);

    final filtered = _filter == null
        ? notices
        : notices
            .where((n) => urgencyOf(n) == _filter)
            .toList();

    final totalCount = notices.length;
    final criticalCount = notices
        .where((n) => urgencyOf(n) == UrgencyLevel.critical)
        .length;
    final pendingCount = notices
        .where(
          (n) =>
              n.status == NoticeStatus.received ||
              n.status == NoticeStatus.underReview,
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notices & Litigation',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Notice resolution & appeal tracking',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Notice'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _SummaryRow(
                total: totalCount,
                critical: criticalCount,
                pending: pendingCount,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _FilterChips(
                selected: _filter,
                onSelected: (level) {
                  setState(() => _filter = level);
                },
              ),
            ),
          ),
          filtered.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No notices',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final notice = filtered[index];
                    final triage = triageMap[notice.noticeId];
                    return NoticeTile(
                      notice: notice,
                      urgency: urgencyOf(notice),
                      riskLevel: triage?.riskLevel ?? RiskLevel.low,
                      onTap: () {
                        ref
                            .read(selectedNoticeProvider.notifier)
                            .select(notice);
                        context.push('/litigation/notice', extra: notice);
                      },
                    );
                  },
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.total,
    required this.critical,
    required this.pending,
  });

  final int total;
  final int critical;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: '$total',
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Critical',
            value: '$critical',
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: '$pending',
            color: const Color(0xFFE65100),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final UrgencyLevel? selected;
  final ValueChanged<UrgencyLevel?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 6),
          ...UrgencyLevel.values.map(
            (level) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _Chip(
                label: _levelLabel(level),
                isSelected: selected == level,
                onTap: () => onSelected(selected == level ? null : level),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _levelLabel(UrgencyLevel level) {
    return switch (level) {
      UrgencyLevel.critical => 'Critical',
      UrgencyLevel.high => 'High',
      UrgencyLevel.medium => 'Medium',
      UrgencyLevel.low => 'Low',
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
