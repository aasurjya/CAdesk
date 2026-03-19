import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/mca_filing.dart';

final _dateFmt = DateFormat('dd MMM yyyy');
final _currencyFmt = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// Counts days from today (2026-03-10) to [due]; negative means overdue.
int _daysUntil(DateTime due) {
  final today = DateTime(2026, 3, 10);
  return due.difference(today).inDays;
}

/// Card tile for a single [McaFiling] showing form type badge, deadline
/// countdown, and penalty indicator.
class McaFilingTile extends StatelessWidget {
  const McaFilingTile({super.key, required this.filing, this.onTap});

  final McaFiling filing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = _daysUntil(filing.dueDate);
    final isComplete =
        filing.status == McaFilingStatus.approved ||
        filing.status == McaFilingStatus.filed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: filing.isOverdue
              ? AppColors.error.withValues(alpha: 0.4)
              : AppColors.neutral200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: form badge + status chip
              Row(
                children: [
                  _FormTypeBadge(formType: filing.formType),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filing.formType.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(status: filing.status),
                ],
              ),

              const SizedBox(height: 8),

              // Row 2: company name + CIN
              Text(
                filing.companyName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                filing.cin,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontFamily: 'monospace',
                  letterSpacing: 0.4,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 10),

              // Row 3: FY + due date + countdown
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.calendar_today_rounded,
                    label: 'FY ${filing.financialYear}',
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.event_rounded,
                    label: 'Due: ${_dateFmt.format(filing.dueDate)}',
                  ),
                  const Spacer(),
                  if (!isComplete) _DeadlineCountdown(daysLeft: daysLeft),
                  if (isComplete && filing.filedDate != null)
                    _MetaChip(
                      icon: Icons.check_circle_outline_rounded,
                      label: _dateFmt.format(filing.filedDate!),
                      iconColor: AppColors.success,
                    ),
                ],
              ),

              // Row 4: penalty indicator (if any)
              if (filing.hasPenalty) ...[
                const SizedBox(height: 8),
                _PenaltyBanner(amount: filing.penaltyAmount),
              ],

              // Row 5: SRN if filed
              if (filing.srn != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 13,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SRN: ${filing.srn}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral400,
                        fontFamily: 'monospace',
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _FormTypeBadge extends StatelessWidget {
  const _FormTypeBadge({required this.formType});

  final McaFormType formType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: formType.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: formType.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        formType.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: formType.color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final McaFilingStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon, size: 13, color: status.color),
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
    );
  }
}

class _DeadlineCountdown extends StatelessWidget {
  const _DeadlineCountdown({required this.daysLeft});

  final int daysLeft;

  Color get _color {
    if (daysLeft < 0) return AppColors.error;
    if (daysLeft <= 7) return AppColors.warning;
    return AppColors.neutral400;
  }

  String get _label {
    if (daysLeft < 0) return '${-daysLeft}d overdue';
    if (daysLeft == 0) return 'Due today';
    return 'in ${daysLeft}d';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _PenaltyBanner extends StatelessWidget {
  const _PenaltyBanner({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: 6),
          Text(
            'Penalty: ${_currencyFmt.format(amount)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.neutral400,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
        ),
      ],
    );
  }
}
