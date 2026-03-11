import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/time_tracking/data/providers/time_tracking_providers.dart';
import 'package:ca_app/features/time_tracking/presentation/widgets/active_timer_widget.dart';
import 'package:ca_app/features/time_tracking/presentation/widgets/billing_summary_card.dart';
import 'package:ca_app/features/time_tracking/presentation/widgets/time_entry_tile.dart';
import 'package:ca_app/features/time_tracking/presentation/widgets/time_entry_to_invoice_sheet.dart';

/// Time tracking screen with active timer, today's entries, and weekly summary.
class TimeTrackingScreen extends ConsumerWidget {
  const TimeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timeEntryFilterProvider);
    final entries = ref.watch(filteredTimeEntriesProvider);
    final weeklySummary = ref.watch(weeklySummaryProvider);
    final billingSummaries = ref.watch(billingSummariesProvider);
    final realization = ref.watch(realizationSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'Generate Invoice',
            onPressed: () => _openInvoiceSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active timer (real running timer)
          const ActiveTimerWidget(),
          const SizedBox(height: 20),

          // Realization summary card
          _RealizationCard(realization: realization),
          const SizedBox(height: 16),

          // Weekly summary card
          _WeeklySummaryCard(summary: weeklySummary),
          const SizedBox(height: 20),

          // Filter chips
          _SectionHeader(
            title: "Today's Entries",
            icon: Icons.list_alt_rounded,
          ),
          const SizedBox(height: 8),
          _FilterChips(selected: filter, ref: ref),
          const SizedBox(height: 12),

          // Time entries list
          if (entries.isEmpty)
            _EmptyState(theme: theme)
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TimeEntryTile(
                  entry: entry,
                  onTap: () => _openInvoiceSheet(context),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Billing summaries
          _SectionHeader(
            title: 'Client Billing',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 8),
          ...billingSummaries.map(
            (summary) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BillingSummaryCard(summary: summary),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openInvoiceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TimeEntryToInvoiceSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Realization summary card
// ---------------------------------------------------------------------------

class _RealizationCard extends StatelessWidget {
  const _RealizationCard({required this.realization});

  final Map<String, double> realization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final utilizationPct = realization['utilizationPct'] ?? 0;
    final effectiveRate = realization['effectiveRate'] ?? 0;
    final totalBillable = realization['totalBillable'] ?? 0;

    final utilizationColor = utilizationPct >= 80
        ? AppColors.success
        : utilizationPct >= 60
        ? AppColors.accent
        : AppColors.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Realization',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _RealizationTile(
                  label: 'Utilization',
                  value: '${utilizationPct.toStringAsFixed(0)}%',
                  color: utilizationColor,
                  icon: Icons.pie_chart_outline_rounded,
                ),
                _RealizationTile(
                  label: 'Effective Rate',
                  value: '₹${effectiveRate.toStringAsFixed(0)}/hr',
                  color: AppColors.secondary,
                  icon: Icons.speed_rounded,
                ),
                _RealizationTile(
                  label: 'Total Billed',
                  value: _formatInr(totalBillable),
                  color: AppColors.primary,
                  icon: Icons.receipt_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatInr(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class _RealizationTile extends StatelessWidget {
  const _RealizationTile({
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
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly summary
// ---------------------------------------------------------------------------

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.summary});

  final Map<String, double> summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalHours = summary['totalHours'] ?? 0;
    final billableHours = summary['billableHours'] ?? 0;
    final totalBilled = summary['totalBilled'] ?? 0;
    final utilization = summary['utilizationRate'] ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _SummaryTile(
                  label: 'Total Hours',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  icon: Icons.schedule_rounded,
                  color: AppColors.primary,
                ),
                _SummaryTile(
                  label: 'Billable',
                  value: '${billableHours.toStringAsFixed(1)}h',
                  icon: Icons.attach_money_rounded,
                  color: AppColors.success,
                ),
                _SummaryTile(
                  label: 'Billed',
                  value: _formatInr(totalBilled),
                  icon: Icons.receipt_rounded,
                  color: AppColors.secondary,
                ),
                _SummaryTile(
                  label: 'Utilization',
                  value: '${utilization.toStringAsFixed(0)}%',
                  icon: Icons.pie_chart_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatInr(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
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
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
            textAlign: TextAlign.center,
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
  const _FilterChips({required this.selected, required this.ref});

  final TimeEntryFilter selected;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TimeEntryFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(timeEntryFilterProvider.notifier).update(filter);
              },
              selectedColor: AppColors.primary.withAlpha(26),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.neutral600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              size: 48,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 12),
            Text(
              'No time entries found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
