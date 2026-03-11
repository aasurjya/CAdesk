import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';
import 'package:ca_app/features/startup_compliance/data/providers/startup_providers.dart';
import 'package:ca_app/features/startup_compliance/presentation/widgets/startup_card.dart';
import 'package:ca_app/features/startup_compliance/presentation/widgets/startup_filing_tile.dart';
import 'package:ca_app/features/startup_compliance/presentation/widgets/startup_detail_sheet.dart';

/// Main Startup Compliance screen (Module 27).
/// Tabs: Startups, Filings, Calendar.
class StartupComplianceScreen extends ConsumerWidget {
  const StartupComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Startup Compliance'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Startups'),
              Tab(text: 'Filings'),
              Tab(text: 'Calendar'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.neutral400,
          ),
        ),
        body: const TabBarView(
          children: [
            _StartupsTab(),
            _FilingsTab(),
            _CalendarTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Startups tab
// ---------------------------------------------------------------------------

class _StartupsTab extends ConsumerWidget {
  const _StartupsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startups = ref.watch(filteredStartupsProvider);
    final summary = ref.watch(startupComplianceSummaryProvider);
    final iacSummary = ref.watch(startupIacSummaryProvider);
    final profiles = ref.watch(startupProfilesProvider);

    return Column(
      children: [
        _SummaryBar(summary: summary),
        _IacSummaryBanner(iacSummary: iacSummary),
        const _RecognitionFilter(),
        Expanded(
          child: startups.isEmpty
              ? const _EmptyState(
                  icon: Icons.rocket_launch_rounded,
                  message: 'No startups found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: startups.length,
                  itemBuilder: (context, index) {
                    final startup = startups[index];
                    // Find matching profile by entity name for detail tap.
                    final profile = profiles
                        .cast<StartupProfile?>()
                        .firstWhere(
                          (p) => p?.name == startup.entityName,
                          orElse: () => null,
                        );
                    return GestureDetector(
                      onTap: profile != null
                          ? () => StartupDetailSheet.show(context, profile)
                          : null,
                      child: StartupCard(startup: startup),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RecognitionFilter extends ConsumerWidget {
  const _RecognitionFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedRecognitionStatusProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selected == null,
              onTap: () => ref
                  .read(selectedRecognitionStatusProvider.notifier)
                  .update(null),
            ),
            ...RecognitionStatus.values.map(
              (s) => _FilterChip(
                label: s.label,
                isSelected: selected == s,
                onTap: () => ref
                    .read(selectedRecognitionStatusProvider.notifier)
                    .update(s),
              ),
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
    final filings = ref.watch(filteredStartupFilingsProvider);

    return Column(
      children: [
        const _FilingFilters(),
        Expanded(
          child: filings.isEmpty
              ? const _EmptyState(
                  icon: Icons.assignment_rounded,
                  message: 'No filings found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filings.length,
                  itemBuilder: (context, index) {
                    return StartupFilingTile(filing: filings[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _FilingFilters extends ConsumerWidget {
  const _FilingFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStartup = ref.watch(selectedStartupFilterProvider);
    final startups = ref.watch(startupEntitiesProvider);
    final selectedType = ref.watch(selectedStartupFilingTypeProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Startup dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedStartup,
                isDense: true,
                isExpanded: true,
                style: theme.textTheme.bodyMedium,
                hint: const Text('All Startups'),
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Startups'),
                  ),
                  ...startups.map(
                    (s) => DropdownMenuItem<String?>(
                      value: s.id,
                      child: Text(
                        s.entityName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  ref
                      .read(selectedStartupFilterProvider.notifier)
                      .update(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Filing type chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Types',
                  isSelected: selectedType == null,
                  onTap: () => ref
                      .read(selectedStartupFilingTypeProvider.notifier)
                      .update(null),
                ),
                ...StartupFilingType.values.map(
                  (t) => _FilterChip(
                    label: t.label,
                    isSelected: selectedType == t,
                    onTap: () => ref
                        .read(selectedStartupFilingTypeProvider.notifier)
                        .update(t),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar tab
// ---------------------------------------------------------------------------

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingStartupFilingsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Upcoming Deadlines',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: upcoming.isEmpty
              ? const _EmptyState(
                  icon: Icons.event_available_rounded,
                  message: 'No upcoming deadlines',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) {
                    return StartupFilingTile(filing: upcoming[index]);
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// IAC summary banner
// ---------------------------------------------------------------------------

class _IacSummaryBanner extends StatelessWidget {
  const _IacSummaryBanner({required this.iacSummary});

  final StartupIacSummary iacSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.savings_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total 80-IAC deduction: '
                  '₹${iacSummary.total80IacDeductionCrore.toStringAsFixed(2)}Cr',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tax savings: '
                  '₹${iacSummary.totalTaxSavingCrore.toStringAsFixed(2)}Cr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${iacSummary.dpiitRecognizedCount}/'
                '${iacSummary.totalStartups}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'DPIIT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary bar
// ---------------------------------------------------------------------------

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summary});

  final StartupComplianceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _MetricTile(
              label: 'Startups',
              value: summary.totalStartups.toString(),
              color: AppColors.primary,
              icon: Icons.rocket_launch_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Recognized',
              value: summary.recognizedCount.toString(),
              color: AppColors.success,
              icon: Icons.verified_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Pending',
              value: summary.pendingFilings.toString(),
              color: AppColors.warning,
              icon: Icons.schedule_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Overdue',
              value: summary.overdueFilings.toString(),
              color: AppColors.error,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.neutral200);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withValues(alpha: 0.18),
        checkmarkColor: AppColors.accent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.neutral600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.neutral200),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
