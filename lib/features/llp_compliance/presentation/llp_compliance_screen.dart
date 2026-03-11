import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp_compliance/data/providers/llp_providers.dart';
import 'package:ca_app/features/llp_compliance/presentation/widgets/llp_entity_card.dart';
import 'package:ca_app/features/llp_compliance/presentation/widgets/llp_filing_tile.dart';
import 'package:ca_app/features/llp_compliance/presentation/widgets/llp_filing_detail_sheet.dart';

/// Main LLP Compliance screen (Module 28).
/// Tabs: LLPs, Filings, Penalties.
class LLPComplianceScreen extends ConsumerWidget {
  const LLPComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LLP Compliance'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'LLPs'),
              Tab(text: 'Filings'),
              Tab(text: 'Penalties'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.neutral400,
          ),
        ),
        body: const TabBarView(
          children: [
            _LLPsTab(),
            _FilingsTab(),
            _PenaltiesTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LLPs tab
// ---------------------------------------------------------------------------

class _LLPsTab extends ConsumerWidget {
  const _LLPsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entities = ref.watch(llpEntitiesProvider);
    final summary = ref.watch(llpComplianceSummaryProvider);
    final penaltySummary = ref.watch(llpPenaltySummaryProvider);
    final filingRecords = ref.watch(allLlpFilingsProvider);

    return Column(
      children: [
        _SummaryBar(summary: summary),
        _PenaltySummaryBanner(penaltySummary: penaltySummary),
        Expanded(
          child: entities.isEmpty
              ? const _EmptyState(
                  icon: Icons.business_rounded,
                  message: 'No LLPs found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: entities.length,
                  itemBuilder: (context, index) {
                    final entity = entities[index];
                    // Find matching filing record for tap action.
                    final record = filingRecords.cast<LlpFilingRecord?>().firstWhere(
                          (r) => r?.llpin == entity.llpin,
                          orElse: () => null,
                        );
                    return GestureDetector(
                      onTap: record != null
                          ? () => LlpFilingDetailSheet.show(context, record)
                          : null,
                      child: LLPEntityCard(entity: entity),
                    );
                  },
                ),
        ),
      ],
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
    final filings = ref.watch(filteredLLPFilingsProvider);

    return Column(
      children: [
        const _FilingFilters(),
        Expanded(
          child: filings.isEmpty
              ? const _EmptyState(
                  icon: Icons.description_rounded,
                  message: 'No filings found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filings.length,
                  itemBuilder: (context, index) {
                    return LLPFilingTile(filing: filings[index]);
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
    final selectedLlp = ref.watch(selectedLLPFilterProvider);
    final entities = ref.watch(llpEntitiesProvider);
    final selectedForm = ref.watch(selectedLLPFormTypeProvider);
    final selectedFy = ref.watch(selectedLLPFYProvider);
    final financialYears = ref.watch(llpFinancialYearsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // LLP + FY dropdowns
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedLlp,
                      isDense: true,
                      isExpanded: true,
                      style: theme.textTheme.bodyMedium,
                      hint: const Text('All LLPs'),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All LLPs'),
                        ),
                        ...entities.map(
                          (e) => DropdownMenuItem<String?>(
                            value: e.id,
                            child: Text(
                              e.llpName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref
                            .read(selectedLLPFilterProvider.notifier)
                            .update(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFy,
                      isDense: true,
                      isExpanded: true,
                      style: theme.textTheme.bodyMedium,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                      ),
                      items: financialYears
                          .map(
                            (fy) => DropdownMenuItem(
                              value: fy,
                              child: Text('FY $fy'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(selectedLLPFYProvider.notifier)
                              .update(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Form type chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Forms',
                  isSelected: selectedForm == null,
                  onTap: () => ref
                      .read(selectedLLPFormTypeProvider.notifier)
                      .update(null),
                ),
                ...LLPFormType.values.map(
                  (f) => _FilterChip(
                    label: f.label,
                    isSelected: selectedForm == f,
                    onTap: () => ref
                        .read(selectedLLPFormTypeProvider.notifier)
                        .update(f),
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
// Penalties tab
// ---------------------------------------------------------------------------

class _PenaltiesTab extends ConsumerWidget {
  const _PenaltiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFilings = ref.watch(llpFilingsProvider);
    final overdueFilings = allFilings
        .where((f) => f.status == LLPFilingStatus.overdue)
        .toList()
      ..sort((a, b) => b.currentPenalty.compareTo(a.currentPenalty));
    final totalPenalty = ref.watch(totalPenaltyExposureProvider);
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    return Column(
      children: [
        // Total penalty card
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.error.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Penalty Exposure',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(totalPenalty),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${overdueFilings.length}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Overdue',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Audit threshold warnings
        const _AuditThresholdWarnings(),
        // Overdue filing list
        Expanded(
          child: overdueFilings.isEmpty
              ? const _EmptyState(
                  icon: Icons.check_circle_rounded,
                  message: 'No overdue filings',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: overdueFilings.length,
                  itemBuilder: (context, index) {
                    return LLPFilingTile(filing: overdueFilings[index]);
                  },
                ),
        ),
      ],
    );
  }
}

/// Shows audit threshold warnings for LLPs approaching limits.
class _AuditThresholdWarnings extends ConsumerWidget {
  const _AuditThresholdWarnings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditRequired = ref.watch(auditRequiredLLPsProvider);
    final theme = Theme.of(context);

    if (auditRequired.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  '${auditRequired.length} LLPs require statutory audit',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...auditRequired.map(
              (e) => Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: Text(
                  '\u2022 ${e.llpName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Penalty summary banner
// ---------------------------------------------------------------------------

class _PenaltySummaryBanner extends StatelessWidget {
  const _PenaltySummaryBanner({required this.penaltySummary});

  final LlpPenaltySummary penaltySummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (penaltySummary.totalPenalty == 0 &&
        penaltySummary.strikeOffRiskCount == 0) {
      return const SizedBox.shrink();
    }

    final formattedPenalty = penaltySummary.totalPenalty >= 100000
        ? '₹${(penaltySummary.totalPenalty / 100000).toStringAsFixed(2)}L'
        : '₹${penaltySummary.totalPenalty.toStringAsFixed(0)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total penalty exposure: $formattedPenalty',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (penaltySummary.strikeOffRiskCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'LLPs at strike-off risk: '
                    '${penaltySummary.strikeOffRiskCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${penaltySummary.overdueCount} overdue',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
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

  final LLPComplianceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _MetricTile(
              label: 'LLPs',
              value: summary.totalLLPs.toString(),
              color: AppColors.primary,
              icon: Icons.business_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Audit Req.',
              value: summary.auditRequired.toString(),
              color: AppColors.warning,
              icon: Icons.gavel_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Overdue',
              value: summary.overdueCount.toString(),
              color: AppColors.error,
              icon: Icons.warning_amber_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Penalty',
              value: _formatCompact(
                summary.totalPenaltyExposure.toDouble(),
              ),
              color: AppColors.error,
              icon: Icons.currency_rupee_rounded,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCompact(double value) {
    if (value >= 100000) {
      return '\u20B9${(value / 100000).toStringAsFixed(1)}L';
    }
    if (value >= 1000) {
      return '\u20B9${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${value.toStringAsFixed(0)}';
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
            style: theme.textTheme.titleMedium?.copyWith(
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
