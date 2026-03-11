import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';

/// Tile displaying an LLP filing with penalty calculator
/// (INR 100/day, max INR 1,00,000) and status information.
class LLPFilingTile extends StatelessWidget {
  const LLPFilingTile({super.key, required this.filing});

  final LLPFiling filing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Form type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _formColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _formShortLabel,
                      style: TextStyle(
                        color: _formColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filing details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filing.formType.label} - '
                        '${filing.formType.description}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${filing.llpName} \u2022 FY ${filing.financialYear}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: filing.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Date row
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${dateFormat.format(filing.dueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                if (filing.filedDate != null) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Filed: ${dateFormat.format(filing.filedDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
                if (filing.certifyingProfessional != null) ...[
                  const Spacer(),
                  Text(
                    filing.certifyingProfessional!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
            // Penalty calculator for overdue filings
            if (filing.status == LLPFilingStatus.overdue) ...[
              const SizedBox(height: 10),
              _PenaltyCalculator(
                filing: filing,
                currencyFormat: currencyFormat,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color get _formColor {
    switch (filing.formType) {
      case LLPFormType.form11:
        return AppColors.primary;
      case LLPFormType.form8:
        return AppColors.secondary;
      case LLPFormType.form3:
        return const Color(0xFF6A1B9A);
      case LLPFormType.form4:
        return AppColors.accent;
      case LLPFormType.itr5:
        return AppColors.success;
      case LLPFormType.formDir3Kyc:
        return const Color(0xFF1565C0);
    }
  }

  String get _formShortLabel {
    switch (filing.formType) {
      case LLPFormType.form11:
        return 'F11';
      case LLPFormType.form8:
        return 'F8';
      case LLPFormType.form3:
        return 'F3';
      case LLPFormType.form4:
        return 'F4';
      case LLPFormType.itr5:
        return 'ITR5';
      case LLPFormType.formDir3Kyc:
        return 'KYC';
    }
  }
}

/// Penalty calculator showing daily penalty, days overdue,
/// current penalty, and max penalty cap.
class _PenaltyCalculator extends StatelessWidget {
  const _PenaltyCalculator({
    required this.filing,
    required this.currencyFormat,
  });

  final LLPFiling filing;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysOverdue = filing.daysOverdue;
    final penaltyProgress =
        (filing.currentPenalty / filing.maxPenalty).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                size: 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                'Penalty Calculator',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PenaltyDetail(
                label: 'Rate',
                value:
                    '\u20B9${filing.penaltyPerDay}/day',
              ),
              _PenaltyDetail(
                label: 'Days',
                value: '$daysOverdue',
              ),
              _PenaltyDetail(
                label: 'Current',
                value: currencyFormat.format(filing.currentPenalty),
              ),
              _PenaltyDetail(
                label: 'Max Cap',
                value: currencyFormat.format(filing.maxPenalty),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: penaltyProgress,
              minHeight: 6,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(
                penaltyProgress >= 0.8 ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(penaltyProgress * 100).toStringAsFixed(1)}% of max penalty',
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

class _PenaltyDetail extends StatelessWidget {
  const _PenaltyDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LLPFilingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
