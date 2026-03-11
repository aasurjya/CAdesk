import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/data/providers/crypto_vda_providers.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_schedule_transaction_list.dart';

/// Shows a draggable bottom sheet with full Schedule VDA details for one client.
///
/// Section 115BBH: 30% flat tax, 4% cess, no loss set-off.
void showVdaScheduleSheet(
  BuildContext context, {
  required String clientId,
  required String clientName,
  required String assessmentYear,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VdaScheduleSheet(
      clientId: clientId,
      clientName: clientName,
      assessmentYear: assessmentYear,
    ),
  );
}

class _VdaScheduleSheet extends ConsumerWidget {
  const _VdaScheduleSheet({
    required this.clientId,
    required this.clientName,
    required this.assessmentYear,
  });

  final String clientId;
  final String clientName;
  final String assessmentYear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VdaScheduleSummary summary =
        ref.watch(vdaScheduleSummaryProvider(clientId));
    final List<VdaTransaction> transactions = ref
        .watch(allVdaTransactionsProvider)
        .where((VdaTransaction t) => t.clientId == clientId)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              _SheetHeader(
                clientName: clientName,
                assessmentYear: assessmentYear,
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 12),
                    VdaScheduleSummaryCard(summary: summary),
                    const SizedBox(height: 16),
                    _LossDisallowedBanner(note: summary.lossDisallowedNote),
                    const SizedBox(height: 16),
                    VdaScheduleTransactionList(transactions: transactions),
                    const SizedBox(height: 16),
                    _LegalNoteCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet chrome
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
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.clientName,
    required this.assessmentYear,
  });

  final String clientName;
  final String assessmentYear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule VDA — Section 115BBH',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$clientName  •  AY $assessmentYear',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

/// Schedule VDA summary card with full tax breakdown.
class VdaScheduleSummaryCard extends StatelessWidget {
  const VdaScheduleSummaryCard({super.key, required this.summary});

  final VdaScheduleSummary summary;

  /// Indian compact number format: ₹X.XXL / ₹X.XK / ₹X.XXCr.
  static String formatAmount(double v) {
    final int iv = v.round();
    if (iv >= 10000000) {
      return '₹${(iv / 10000000).toStringAsFixed(2)}Cr';
    }
    if (iv >= 100000) {
      return '₹${(iv / 100000).toStringAsFixed(2)}L';
    }
    if (iv >= 1000) {
      return '₹${(iv / 1000).toStringAsFixed(1)}K';
    }
    return '₹$iv';
  }

  @override
  Widget build(BuildContext context) {
    final double cess = summary.totalTaxPayable / 1.04 * 0.04;

    return Card(
      elevation: 0,
      color: AppColors.neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VdaScheduleRow(
              label: 'Total Sale Value',
              value: formatAmount(summary.totalSaleValue),
            ),
            VdaScheduleRow(
              label: 'Total Cost of Acquisition',
              value: formatAmount(summary.totalCost),
            ),
            const Divider(height: 20),
            if (summary.totalNetGains > 0)
              VdaScheduleRow(
                label: 'Net Gains',
                value: formatAmount(summary.totalNetGains),
                valueColor: AppColors.success,
                bold: true,
              ),
            if (summary.totalLosses > 0)
              VdaScheduleRow(
                label: 'Net Losses (disallowed)',
                value: formatAmount(summary.totalLosses),
                valueColor: AppColors.error,
                bold: true,
                trailingBadge: 'disallowed',
              ),
            const Divider(height: 20),
            VdaScheduleRow(
              label: 'Tax @ 30%',
              value: formatAmount(summary.totalTaxPayable / 1.04),
            ),
            VdaScheduleRow(
              label: '+ 4% Health & Education Cess',
              value: formatAmount(cess),
            ),
            const Divider(height: 12),
            VdaScheduleRow(
              label: 'Total Tax Payable',
              value: formatAmount(summary.totalTaxPayable),
              valueColor: AppColors.error,
              bold: true,
              large: true,
            ),
            const SizedBox(height: 8),
            VdaScheduleRow(
              label: 'Less: TDS Deducted u/s 194S',
              value: '– ${formatAmount(summary.totalTdsDeducted)}',
              valueColor: AppColors.success,
            ),
            const Divider(height: 12),
            VdaScheduleRow(
              label: 'Net Tax Payable',
              value: formatAmount(summary.netTaxAfterTds),
              valueColor: summary.netTaxAfterTds > 0
                  ? AppColors.error
                  : AppColors.success,
              bold: true,
              large: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single label-value row in the Schedule VDA summary card.
class VdaScheduleRow extends StatelessWidget {
  const VdaScheduleRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.large = false,
    this.trailingBadge,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final bool large;
  final String? trailingBadge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle valueStyle = (large
            ? theme.textTheme.titleMedium
            : theme.textTheme.bodyMedium)
        ?.copyWith(
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor ?? AppColors.neutral900,
        ) ??
        const TextStyle();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ),
          Text(value, style: valueStyle),
          if (trailingBadge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                trailingBadge!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loss disallowed banner
// ---------------------------------------------------------------------------

class _LossDisallowedBanner extends StatelessWidget {
  const _LossDisallowedBanner({required this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    if (note == null) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gpp_bad_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legal note card
// ---------------------------------------------------------------------------

class _LegalNoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'VDA losses cannot be set off against salary, business, or '
              'capital gains income under Section 115BBH of the Income Tax '
              'Act, 1961. Each VDA gain is taxed at a flat 30% plus 4% '
              'Health & Education Cess.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
