import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/itr_u_filing.dart';

/// A tile displaying an ITR-U (Updated Return) filing with penalty
/// calculation display.
class ItrUTile extends StatelessWidget {
  const ItrUTile({super.key, required this.filing, this.onTap});

  final ItrUFiling filing;
  final VoidCallback? onTap;
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    filing.status.icon,
                    size: 20,
                    color: filing.status.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filing.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: filing.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'PAN: ${filing.pan}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    filing.originalAssessmentYear,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Reason: ${filing.updateReason.label}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _PenaltyBreakdown(filing: filing),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Original filed: ${_dateFormat.format(filing.originalFilingDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.timer, size: 12, color: AppColors.neutral400),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_dateFormat.format(filing.filingDeadline)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: filing.daysUntilDeadline <= 30
                          ? AppColors.warning
                          : AppColors.neutral400,
                      fontSize: 11,
                      fontWeight: filing.daysUntilDeadline <= 30
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PenaltyBreakdown extends StatelessWidget {
  const _PenaltyBreakdown({required this.filing});

  final ItrUFiling filing;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          _AmountColumn(
            label: 'Add. Tax',
            value: _currencyFormat.format(filing.additionalTax),
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text('+', style: TextStyle(color: AppColors.neutral400)),
          const SizedBox(width: 4),
          _AmountColumn(
            label: 'Penalty (${filing.penaltyPercentage}%)',
            value: _currencyFormat.format(filing.penaltyAmount),
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text('=', style: TextStyle(color: AppColors.neutral400)),
          const SizedBox(width: 4),
          _AmountColumn(
            label: 'Total Payable',
            value: _currencyFormat.format(filing.totalPayable),
            color: AppColors.error,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 13 : 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ItrUStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
