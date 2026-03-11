import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';
import 'package:ca_app/features/tds/presentation/widgets/tds_summary_card.dart';
import 'package:ca_app/features/tds/presentation/widgets/tds_deductor_tile.dart';
import 'package:ca_app/features/tds/presentation/widgets/tds_deductor_detail_sheet.dart';

/// Main TDS / TCS screen with summary cards, form type tabs,
/// quarter and FY selectors, and a deductor list.
class TdsScreen extends ConsumerWidget {
  const TdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (context) {
          // Sync tab controller with provider.
          final tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              ref
                  .read(selectedFormTabProvider.notifier)
                  .update(tabController.index);
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('TDS / TCS'),
              bottom: TabBar(
                tabs: const [
                  Tab(text: '24Q'),
                  Tab(text: '26Q'),
                  Tab(text: '27Q'),
                  Tab(text: '27EQ'),
                ],
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.neutral400,
              ),
            ),
            body: const _TdsBody(),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'tds_fab',
              onPressed: () {
                _showNewReturnSheet(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('New Return'),
            ),
          );
        },
      ),
    );
  }

  void _showNewReturnSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const _NewReturnSheet();
      },
    );
  }
}

class _TdsBody extends ConsumerWidget {
  const _TdsBody();

  void _openDetailSheet(BuildContext context, TdsDeductor deductor) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return TdsDeductorDetailSheet(deductor: deductor);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deductors = ref.watch(deductorsForCurrentTabProvider);

    return Column(
      children: [
        const TdsSummaryCard(),
        const _ChallanSummaryRow(),
        const _FilterRow(),
        Expanded(
          child: deductors.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: deductors.length,
                  itemBuilder: (context, index) {
                    return TdsDeductorTile(
                      deductor: deductors[index],
                      onTap: () => _openDetailSheet(context, deductors[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Compact summary row showing challan payment statistics for the quarter.
class _ChallanSummaryRow extends ConsumerWidget {
  const _ChallanSummaryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(challanSummaryProvider);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_rounded, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            'Challans: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          Text(
            '${summary.total - summary.overdue - summary.due} paid',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (summary.overdue > 0) ...[
            Text(
              ' · ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            Text(
              '${summary.overdue} overdue',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (summary.due > 0) ...[
            Text(
              ' · ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            Text(
              '${summary.due} due',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${CurrencyUtils.formatINRCompact(summary.totalPaid)} deposited',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of FY dropdown and quarter chip filters.
class _FilterRow extends ConsumerWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFy = ref.watch(selectedFinancialYearProvider);
    final financialYears = ref.watch(financialYearsProvider);
    final selectedQuarter = ref.watch(selectedQuarterProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // FY selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFy,
                isDense: true,
                style: theme.textTheme.bodyMedium,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                items: financialYears
                    .map(
                      (fy) =>
                          DropdownMenuItem(value: fy, child: Text('FY $fy')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(selectedFinancialYearProvider.notifier)
                        .update(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Quarter chips
          _QuarterChip(
            label: 'All',
            isSelected: selectedQuarter == null,
            onTap: () {
              ref.read(selectedQuarterProvider.notifier).update(null);
            },
          ),
          ...TdsQuarter.values.map(
            (q) => _QuarterChip(
              label: q.label,
              isSelected: selectedQuarter == q,
              onTap: () {
                ref.read(selectedQuarterProvider.notifier).update(q);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuarterChip extends StatelessWidget {
  const _QuarterChip({
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
      padding: const EdgeInsets.only(left: 6),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 16),
          Text(
            'No returns found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different form type, quarter, or financial year.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for creating a new return (placeholder form).
class _NewReturnSheet extends ConsumerStatefulWidget {
  const _NewReturnSheet();

  @override
  ConsumerState<_NewReturnSheet> createState() => _NewReturnSheetState();
}

class _NewReturnSheetState extends ConsumerState<_NewReturnSheet> {
  TdsFormType _formType = TdsFormType.form24Q;
  TdsQuarter _quarter = TdsQuarter.q1;
  String? _selectedDeductorId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deductors = ref.watch(tdsDeductorsProvider);
    final fy = ref.watch(selectedFinancialYearProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'New TDS/TCS Return',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Deductor dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedDeductorId,
            decoration: const InputDecoration(
              labelText: 'Deductor',
              prefixIcon: Icon(Icons.business_rounded),
            ),
            items: deductors
                .map(
                  (d) => DropdownMenuItem(
                    value: d.id,
                    child: Text(
                      d.deductorName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _selectedDeductorId = value);
            },
          ),
          const SizedBox(height: 16),
          // Form type & quarter side by side
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TdsFormType>(
                  initialValue: _formType,
                  decoration: const InputDecoration(
                    labelText: 'Form Type',
                    prefixIcon: Icon(Icons.description_rounded),
                  ),
                  items: TdsFormType.values
                      .map(
                        (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _formType = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TdsQuarter>(
                  initialValue: _quarter,
                  decoration: const InputDecoration(
                    labelText: 'Quarter',
                    prefixIcon: Icon(Icons.date_range_rounded),
                  ),
                  items: TdsQuarter.values
                      .map(
                        (q) => DropdownMenuItem(
                          value: q,
                          child: Text('${q.label} (${q.description})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _quarter = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // FY display (read-only)
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Financial Year',
              prefixIcon: Icon(Icons.calendar_today_rounded),
            ),
            child: Text('FY $fy'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _selectedDeductorId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Return ${_formType.label} ${_quarter.label} '
                          'created for FY $fy',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text('Create Return'),
          ),
        ],
      ),
    );
  }
}
