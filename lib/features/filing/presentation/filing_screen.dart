import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_hub_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_hub_item.dart';
import 'package:ca_app/features/filing/presentation/widgets/draft_filing_tile.dart';
import 'package:ca_app/features/filing/presentation/widgets/new_filing_bottom_sheet.dart';
import 'package:ca_app/features/filing/presentation/widgets/recent_filing_tile.dart';
import 'package:ca_app/features/filing/presentation/widgets/urgency_card.dart';

const _assessmentYears = <String>[
  'AY 2026-27',
  'AY 2025-26',
  'AY 2024-25',
  'AY 2023-24',
];

/// The Filing Hub — the primary landing screen for the app.
///
/// Shows urgent filings, in-progress drafts, and recently filed returns
/// for the selected assessment year.
class FilingScreen extends ConsumerWidget {
  const FilingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(selectedAssessmentYearProvider);
    final urgentItems = ref.watch(urgentFilingsProvider);
    final inProgressItems = ref.watch(inProgressFilingsProvider);
    final recentItems = ref.watch(recentFilingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filing Hub',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _AssessmentYearDropdown(
              value: selectedYear,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(selectedAssessmentYearProvider.notifier)
                      .update(value);
                }
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _SectionHeader(
            title: 'Urgent',
            count: urgentItems.length,
            countColor: AppColors.error,
          ),
          if (urgentItems.isEmpty)
            const _EmptyState(
              icon: Icons.check_circle_outline,
              message: 'No urgent filings. All caught up!',
              color: AppColors.success,
            )
          else
            SizedBox(
              height: 148,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: urgentItems.length,
                itemBuilder: (context, index) {
                  return UrgencyCard(
                    item: urgentItems[index],
                    onTap: () => _openFiling(context, urgentItems[index]),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          _SectionHeader(
            title: 'In Progress',
            count: inProgressItems.length,
            countColor: AppColors.primaryVariant,
          ),
          if (inProgressItems.isEmpty)
            const _EmptyState(
              icon: Icons.inbox_outlined,
              message: 'No filings in progress.',
              color: AppColors.neutral400,
            )
          else
            Column(
              children: [
                for (int i = 0; i < inProgressItems.length; i++) ...[
                  DraftFilingTile(
                    item: inProgressItems[i],
                    onTap: () => _openFiling(context, inProgressItems[i]),
                  ),
                  if (i < inProgressItems.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              ],
            ),
          const SizedBox(height: 8),
          _SectionHeader(
            title: 'Recently Filed',
            count: recentItems.length,
            countColor: AppColors.success,
          ),
          if (recentItems.isEmpty)
            const _EmptyState(
              icon: Icons.history_outlined,
              message: 'No recently filed returns.',
              color: AppColors.neutral400,
            )
          else
            Column(
              children: [
                for (int i = 0; i < recentItems.length; i++) ...[
                  RecentFilingTile(
                    item: recentItems[i],
                    onTap: () => _showComingSoon(context),
                  ),
                  if (i < recentItems.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              ],
            ),
          const SizedBox(height: 16),
          const _SectionHeader(
            title: 'Tools',
            count: 0,
            countColor: AppColors.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  icon: Icons.queue,
                  label: 'Filing Queue',
                  onTap: () => context.push('/filing/queue'),
                ),
                _QuickActionChip(
                  icon: Icons.compare_arrows,
                  label: '26AS / AIS',
                  onTap: () => context.push('/filing/reconciliation'),
                ),
                _QuickActionChip(
                  icon: Icons.bar_chart,
                  label: 'Analytics',
                  onTap: () => context.push('/filing/analytics'),
                ),
                _QuickActionChip(
                  icon: Icons.update,
                  label: 'ITR-U',
                  onTap: () => context.push('/filing/itr-u'),
                ),
                _QuickActionChip(
                  icon: Icons.calendar_today,
                  label: 'Advance Tax',
                  onTap: () => context.push('/filing/advance-tax'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 88),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewFilingSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New Filing'),
        tooltip: 'Start a new filing',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _showNewFilingSheet(BuildContext context) async {
    final jobId = await showNewFilingBottomSheet(context);
    if (jobId != null && context.mounted) {
      // Navigate to the ITR-1 wizard for the newly created job
      context.push('/filing/itr1/$jobId');
    }
  }

  void _openFiling(BuildContext context, FilingHubItem item) {
    switch ((item.filingType, item.subType)) {
      case (FilingCategory.itr, 'ITR-1'):
        context.push('/filing/itr1/${item.id}');
      case (FilingCategory.itr, 'ITR-2'):
        context.push('/filing/itr2/${item.id}');
      case (FilingCategory.itr, 'ITR-4'):
        context.push('/filing/itr4/${item.id}');
      default:
        context.push('/filing/status/${item.id}');
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _AssessmentYearDropdown extends StatelessWidget {
  const _AssessmentYearDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isDense: true,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(
            Icons.expand_more,
            size: 16,
            color: AppColors.primary,
          ),
          items: [
            for (final year in _assessmentYears)
              DropdownMenuItem(value: year, child: Text(year)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.countColor,
  });

  final String title;
  final int count;
  final Color countColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: countColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: countColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      side: const BorderSide(color: AppColors.neutral300),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
