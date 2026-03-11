import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/mis_report.dart';

/// Card widget displaying key financial metrics for a single MIS report.
class MisReportCard extends StatelessWidget {
  const MisReportCard({super.key, required this.report});

  final MisReport report;

  // ---------------------------------------------------------------------------
  // Status colours
  // ---------------------------------------------------------------------------

  Color _statusColor(String status) {
    switch (status) {
      case 'Draft':
        return AppColors.neutral400;
      case 'Review':
        return AppColors.warning;
      case 'Approved':
        return AppColors.success;
      case 'Delivered':
        return AppColors.primary;
      default:
        return AppColors.neutral400;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Draft':
        return Icons.edit_note_rounded;
      case 'Review':
        return Icons.rate_review_rounded;
      case 'Approved':
        return Icons.check_circle_rounded;
      case 'Delivered':
        return Icons.send_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(report.status);
    final ebitdaFraction =
        (report.ebitdaMarginPercent / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: client name + report type badge + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.clientName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _ReportTypeBadge(reportType: report.reportType),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  status: report.status,
                  color: statusColor,
                  icon: _statusIcon(report.status),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.neutral200),
            const SizedBox(height: 12),

            // Row 2: Revenue | Expenses | Net Profit
            Row(
              children: [
                _MetricCell(
                  label: 'Revenue',
                  value: '₹${report.revenue.toStringAsFixed(0)}L',
                  valueColor: AppColors.neutral900,
                ),
                _VerticalDivider(),
                _MetricCell(
                  label: 'Expenses',
                  value: '₹${report.expenses.toStringAsFixed(0)}L',
                  valueColor: AppColors.neutral900,
                ),
                _VerticalDivider(),
                _MetricCell(
                  label: 'Net Profit',
                  value: '₹${report.netProfit.toStringAsFixed(0)}L',
                  valueColor: AppColors.success,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // EBITDA margin progress bar
            Row(
              children: [
                Text(
                  'EBITDA',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${report.ebitdaMarginPercent.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ebitdaFraction,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),

            const SizedBox(height: 12),

            // Row 3: Cash balance pill + period label
            Row(
              children: [
                _CashPill(cashBalance: report.cashBalance),
                const Spacer(),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  report.period,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            // Key highlight (first bullet)
            if (report.keyHighlights.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.neutral100),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      report.keyHighlights.first,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ReportTypeBadge extends StatelessWidget {
  const _ReportTypeBadge({required this.reportType});

  final String reportType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        reportType,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.color,
    required this.icon,
  });

  final String status;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.neutral200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _CashPill extends StatelessWidget {
  const _CashPill({required this.cashBalance});

  final double cashBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 11,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Cash ₹${cashBalance.toStringAsFixed(0)}L',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
