import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';

/// A tile displaying an e-proceeding with type badge, deadline countdown,
/// and demand amount.
class EProceedingTile extends StatelessWidget {
  const EProceedingTile({super.key, required this.proceeding, this.onTap});

  final EProceeding proceeding;
  final VoidCallback? onTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = proceeding.daysUntilDeadline;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: proceeding.isUrgent || proceeding.isOverdue
            ? BorderSide(color: AppColors.error.withValues(alpha: 0.4))
            : BorderSide.none,
      ),
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
                    proceeding.status.icon,
                    size: 20,
                    color: proceeding.status.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      proceeding.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _DeadlineCountdown(daysLeft: daysLeft),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _TypeBadge(type: proceeding.proceedingType),
                  const SizedBox(width: 8),
                  _StatusBadge(status: proceeding.status),
                  const Spacer(),
                  Text(
                    proceeding.assessmentYear,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.tag, size: 12, color: AppColors.neutral400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      proceeding.nfacReferenceNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Notice: ${_dateFormat.format(proceeding.noticeDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (proceeding.demandAmount != null &&
                      proceeding.demandAmount! > 0) ...[
                    Text(
                      'Demand: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(proceeding.demandAmount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
              if (proceeding.remarks != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    proceeding.remarks!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadlineCountdown extends StatelessWidget {
  const _DeadlineCountdown({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;

    if (daysLeft < 0) {
      color = AppColors.error;
      text = '${daysLeft.abs()}d overdue';
    } else if (daysLeft <= 7) {
      color = AppColors.error;
      text = '${daysLeft}d left';
    } else if (daysLeft <= 15) {
      color = AppColors.warning;
      text = '${daysLeft}d left';
    } else {
      color = AppColors.success;
      text = '${daysLeft}d left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final ProceedingType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProceedingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}
