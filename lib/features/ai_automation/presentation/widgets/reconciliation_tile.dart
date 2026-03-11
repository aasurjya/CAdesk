import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ai_automation/domain/models/bank_reconciliation.dart';

/// Displays a bank reconciliation entry with a confidence bar.
class ReconciliationTile extends StatelessWidget {
  const ReconciliationTile({
    super.key,
    required this.reconciliation,
    this.onTap,
  });

  final BankReconciliation reconciliation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('dd MMM, hh:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: status icon + client + amount
              Row(
                children: [
                  Icon(
                    reconciliation.matchStatus.icon,
                    color: reconciliation.matchStatus.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reconciliation.clientName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    reconciliation.formattedAmount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: reconciliation.amountInr >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Bank entry → Book entry
              _EntryRow(
                label: 'Bank',
                value: reconciliation.bankEntry,
                icon: Icons.account_balance_rounded,
              ),
              const SizedBox(height: 4),
              _EntryRow(
                label: 'Book',
                value: reconciliation.bookEntry.isEmpty
                    ? 'No matching entry'
                    : reconciliation.bookEntry,
                icon: Icons.menu_book_rounded,
                isEmpty: reconciliation.bookEntry.isEmpty,
              ),
              const SizedBox(height: 10),
              // Confidence bar + status badge + time
              Row(
                children: [
                  _ConfidenceBar(confidence: reconciliation.matchConfidence),
                  const SizedBox(width: 12),
                  _StatusBadge(status: reconciliation.matchStatus),
                  const Spacer(),
                  Text(
                    timeFormat.format(reconciliation.reconciledAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
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

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isEmpty = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isEmpty ? AppColors.error : AppColors.neutral600,
              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final color = confidence >= 0.90
        ? AppColors.success
        : confidence >= 0.70
            ? AppColors.warning
            : AppColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${(confidence * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
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
