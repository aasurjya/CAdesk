import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/statutory_return.dart';

final _inr = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);
final _dateFormat = DateFormat('dd MMM yyyy');

/// List tile for a statutory return showing type badge, due date,
/// and challan reference.
class StatutoryReturnTile extends StatelessWidget {
  const StatutoryReturnTile({
    super.key,
    required this.returnRecord,
    this.onTap,
  });

  final StatutoryReturn returnRecord;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rt = returnRecord.returnType;
    final st = returnRecord.status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: returnRecord.isOverdue
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
              // Header
              Row(
                children: [
                  _ReturnTypeBadge(returnType: rt),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rt.description,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          'Period: ${returnRecord.period}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: st),
                ],
              ),

              const SizedBox(height: 10),

              // Details row
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Due Date',
                      value: _dateFormat.format(returnRecord.dueDate),
                      valueColor: returnRecord.isOverdue
                          ? AppColors.error
                          : AppColors.neutral900,
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.people_rounded,
                      label: 'Employees',
                      value: returnRecord.totalEmployees.toString(),
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Contribution',
                      value: _inr.format(returnRecord.totalContribution),
                      valueColor: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Challan number (if filed)
              if (returnRecord.challanNumber != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 13,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Challan: ${returnRecord.challanNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (returnRecord.filedDate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Filed: ${_dateFormat.format(returnRecord.filedDate!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ],
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

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _ReturnTypeBadge extends StatelessWidget {
  const _ReturnTypeBadge({required this.returnType});

  final StatutoryReturnType returnType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: returnType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: returnType.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        returnType.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: returnType.color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StatutoryReturnStatus status;

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
          Icon(status.icon, size: 11, color: status.color),
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

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.neutral900,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.neutral400),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
