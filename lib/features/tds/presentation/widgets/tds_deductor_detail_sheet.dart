import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';
import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_section_summary.dart';

/// Draggable bottom sheet showing full TDS details for a single deductor.
///
/// Displays three tabs: Challans, Sections, and Returns.
class TdsDeductorDetailSheet extends ConsumerStatefulWidget {
  const TdsDeductorDetailSheet({super.key, required this.deductor});

  final TdsDeductor deductor;

  @override
  ConsumerState<TdsDeductorDetailSheet> createState() =>
      _TdsDeductorDetailSheetState();
}

class _TdsDeductorDetailSheetState extends ConsumerState<TdsDeductorDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _SheetHandle(),
            _DeductorHeader(deductor: widget.deductor),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Challans'),
                Tab(text: 'Sections'),
                Tab(text: 'Returns'),
              ],
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.neutral400,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ChallansTab(
                    deductorId: widget.deductor.id,
                    scrollController: scrollController,
                  ),
                  _SectionsTab(scrollController: scrollController),
                  _ReturnsTab(
                    deductorId: widget.deductor.id,
                    scrollController: scrollController,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Internal widgets
// ---------------------------------------------------------------------------

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _DeductorHeader extends StatelessWidget {
  const _DeductorHeader({required this.deductor});

  final TdsDeductor deductor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deductor.deductorName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'TAN: ${deductor.tan}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              deductor.deductorType.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Challans tab
// ---------------------------------------------------------------------------

class _ChallansTab extends ConsumerWidget {
  const _ChallansTab({
    required this.deductorId,
    required this.scrollController,
  });

  final String deductorId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challans = ref.watch(challanForDeductorProvider(deductorId));
    final summary = ref.watch(challanSummaryProvider);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _ChallanMiniCard(summary: summary),
        const SizedBox(height: 12),
        if (challans.isEmpty)
          const _EmptyTabState(message: 'No challans found for this deductor.')
        else
          ...challans.map((c) => _ChallanCard(challan: c)),
      ],
    );
  }
}

class _ChallanMiniCard extends StatelessWidget {
  const _ChallanMiniCard({required this.summary});

  final ChallanSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.neutral50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _MiniStat(
              label: 'Total Deposited',
              value: CurrencyUtils.formatINRCompact(summary.totalPaid),
              color: AppColors.primary,
            ),
            const _MiniDivider(),
            _MiniStat(
              label: 'Challans',
              value: summary.total.toString(),
              color: AppColors.secondary,
            ),
            const _MiniDivider(),
            _MiniStat(
              label: 'Overdue',
              value: summary.overdue.toString(),
              color: summary.overdue > 0 ? AppColors.error : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.neutral200);
  }
}

class _ChallanCard extends StatelessWidget {
  const _ChallanCard({required this.challan});

  final TdsChallan challan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: challan number + status chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    challan.challanNumber,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
                _StatusChip(status: challan.status),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: section + description
            Text(
              'Sec ${challan.section} — ${challan.sectionDescription}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            // Row 3: amount breakdown
            Row(
              children: [
                _AmountItem(
                  label: 'TDS',
                  value: CurrencyUtils.formatINRCompact(challan.tdsAmount),
                ),
                if (challan.interest > 0) ...[
                  const SizedBox(width: 12),
                  _AmountItem(
                    label: 'Interest',
                    value: CurrencyUtils.formatINRCompact(challan.interest),
                    valueColor: AppColors.warning,
                  ),
                ],
                if (challan.penalty > 0) ...[
                  const SizedBox(width: 12),
                  _AmountItem(
                    label: 'Penalty',
                    value: CurrencyUtils.formatINRCompact(challan.penalty),
                    valueColor: AppColors.error,
                  ),
                ],
                const Spacer(),
                Text(
                  CurrencyUtils.formatINRCompact(challan.totalAmount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Row 4: payment date + BSR
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  challan.paymentDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                const Spacer(),
                Text(
                  'BSR: ${challan.bsrCode}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountItem extends StatelessWidget {
  const _AmountItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: valueColor ?? AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sections tab
// ---------------------------------------------------------------------------

class _SectionsTab extends ConsumerWidget {
  const _SectionsTab({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(allSectionSummariesProvider);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: sections.map((s) => _SectionCard(section: s)).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final TdsSectionSummary section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compliance = section.compliancePercent;
    final hasOutstanding = section.outstandingTds > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: section + rate + deductee count
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Sec ${section.section}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.sectionDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${section.ratePercent.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Compliance bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: compliance / 100,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                color: compliance >= 100
                    ? AppColors.success
                    : compliance >= 75
                    ? AppColors.warning
                    : AppColors.error,
              ),
            ),
            const SizedBox(height: 6),
            // Row 3: amounts + outstanding
            Row(
              children: [
                _AmountItem(
                  label: 'Deducted',
                  value: CurrencyUtils.formatINRCompact(
                    section.totalTdsDeducted,
                  ),
                ),
                const SizedBox(width: 16),
                _AmountItem(
                  label: 'Paid',
                  value: CurrencyUtils.formatINRCompact(section.totalTdsPaid),
                  valueColor: AppColors.success,
                ),
                const Spacer(),
                if (hasOutstanding)
                  _AmountItem(
                    label: 'Outstanding',
                    value: CurrencyUtils.formatINRCompact(
                      section.outstandingTds,
                    ),
                    valueColor: AppColors.error,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Row 4: deductee count + compliance %
            Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  '${section.deducteeCount} deductees',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                const Spacer(),
                Text(
                  '${compliance.toStringAsFixed(0)}% compliant',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: hasOutstanding
                        ? AppColors.warning
                        : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Returns tab
// ---------------------------------------------------------------------------

class _ReturnsTab extends ConsumerWidget {
  const _ReturnsTab({required this.deductorId, required this.scrollController});

  final String deductorId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(returnsForDeductorProvider(deductorId));

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: returns.isEmpty
          ? [const _EmptyTabState(message: 'No returns found.')]
          : returns.map((r) => _ReturnCard(tdsReturn: r)).toList(),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.tdsReturn});

  final TdsReturn tdsReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = tdsReturn.status == TdsReturnStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: form type + quarter + status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tdsReturn.formType.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${tdsReturn.quarter.label} · FY ${tdsReturn.financialYear}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _StatusChip(status: tdsReturn.status.label),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: tax deducted + deposited
            Row(
              children: [
                _AmountItem(
                  label: 'Deducted',
                  value: CurrencyUtils.formatINRCompact(
                    tdsReturn.totalTaxDeducted,
                  ),
                ),
                const SizedBox(width: 16),
                _AmountItem(
                  label: 'Deposited',
                  value: CurrencyUtils.formatINRCompact(
                    tdsReturn.totalDeposited,
                  ),
                ),
                const Spacer(),
                if (tdsReturn.filedDate != null)
                  Text(
                    'Filed ${_formatDate(tdsReturn.filedDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
              ],
            ),
            // File Return button for pending returns
            if (isPending) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _FileReturnButton(tdsReturn: tdsReturn),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _FileReturnButton extends StatelessWidget {
  const _FileReturnButton({required this.tdsReturn});

  final TdsReturn tdsReturn;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Filing ${tdsReturn.formType.label} '
              '${tdsReturn.quarter.label} for FY ${tdsReturn.financialYear}…',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: const Text('File Return'),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helper widgets
// ---------------------------------------------------------------------------

/// Coloured status chip for challan or return status strings.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _colorForStatus(String status) {
    switch (status) {
      case 'Paid':
      case 'Filed':
      case 'Revised':
        return AppColors.success;
      case 'Overdue':
        return AppColors.error;
      case 'Due':
      case 'Partial':
      case 'Pending':
        return AppColors.warning;
      case 'Prepared':
        return AppColors.secondary;
      default:
        return AppColors.neutral400;
    }
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
