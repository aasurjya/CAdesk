import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/irn_batch.dart';

/// Card widget that renders a single [IrnBatch] in the Batches tab.
///
/// Shows client, date, success/failed/pending counts, a progress bar,
/// total value, and a status chip.
class IrnBatchCard extends StatelessWidget {
  const IrnBatchCard({super.key, required this.batch});

  final IrnBatch batch;

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Color _statusColor() {
    switch (batch.batchStatus) {
      case 'Completed':
        return AppColors.success;
      case 'Failed':
        return AppColors.error;
      case 'Processing':
        return AppColors.warning;
      case 'Partial':
      default:
        return AppColors.accent;
    }
  }

  double _progressValue() {
    if (batch.totalInvoices == 0) {
      return 0.0;
    }
    return batch.successCount / batch.totalInvoices;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(textTheme),
            const SizedBox(height: 10),
            _buildStatsRow(textTheme),
            const SizedBox(height: 10),
            _buildProgressBar(),
            const SizedBox(height: 10),
            _buildFooterRow(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                batch.clientName,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    batch.processedDate,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${batch.totalInvoices} invoices',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _StatusChip(label: batch.batchStatus, color: _statusColor()),
      ],
    );
  }

  Widget _buildStatsRow(TextTheme textTheme) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          label: 'Success',
          value: '${batch.successCount}',
          textTheme: textTheme,
        ),
        const SizedBox(width: 16),
        _StatItem(
          icon: Icons.cancel_rounded,
          iconColor: AppColors.error,
          label: 'Failed',
          value: '${batch.failedCount}',
          textTheme: textTheme,
        ),
        const SizedBox(width: 16),
        _StatItem(
          icon: Icons.hourglass_empty_rounded,
          iconColor: AppColors.warning,
          label: 'Pending',
          value: '${batch.pendingCount}',
          textTheme: textTheme,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'IRN Success Rate',
              style: TextStyle(fontSize: 11, color: AppColors.neutral600),
            ),
            Text(
              '${(_progressValue() * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progressValue(),
            minHeight: 6,
            backgroundColor: AppColors.neutral200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterRow(TextTheme textTheme) {
    return Row(
      children: [
        const Icon(
          Icons.currency_rupee_rounded,
          size: 14,
          color: AppColors.neutral600,
        ),
        Text(
          '${batch.totalValue.toStringAsFixed(2)} L',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'total value',
          style: textTheme.labelSmall?.copyWith(color: AppColors.neutral400),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
