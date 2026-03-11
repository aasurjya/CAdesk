import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/llp_compliance/data/providers/llp_providers.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';

/// Bottom sheet showing LLP compliance status for a single [LlpFilingRecord].
class LlpFilingDetailSheet extends StatelessWidget {
  const LlpFilingDetailSheet({super.key, required this.record});

  final LlpFilingRecord record;

  /// Shows the bottom sheet anchored to [context].
  static void show(BuildContext context, LlpFilingRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LlpFilingDetailSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DragHandle(),
              const SizedBox(height: 12),
              _Header(record: record),
              const SizedBox(height: 16),
              if (record.hasStrikeOffRisk) ...[
                _StrikeOffWarning(theme: theme),
                const SizedBox(height: 12),
              ],
              _AuditBadge(requiresAudit: record.requiresAudit, theme: theme),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _FilingRow(
                label: 'Form 11 (Annual Return)',
                dueLabel: 'Due: 30 May',
                status: record.form11Status,
                daysLate: record.form11DaysLate,
                penalty: record.form11Penalty,
                theme: theme,
              ),
              const SizedBox(height: 10),
              _FilingRow(
                label: 'Form 8 (Statement of Accounts)',
                dueLabel: 'Due: 30 Oct',
                status: record.form8Status,
                daysLate: record.form8DaysLate,
                penalty: record.form8Penalty,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _TotalPenaltyCard(
                totalPenalty: record.totalPenalty,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _Itr5DueDateRow(record: record, theme: theme),
              const SizedBox(height: 20),
              _ActionButtons(record: record),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.neutral300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.record});

  final LlpFilingRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.business_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.llpName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LLPIN: ${record.llpin}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    record.assessmentYear,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StrikeOffWarning extends StatelessWidget {
  const _StrikeOffWarning({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Strike-off risk: No filing for 3+ years. '
              'MCA may initiate strike-off proceedings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditBadge extends StatelessWidget {
  const _AuditBadge({required this.requiresAudit, required this.theme});

  final bool requiresAudit;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = requiresAudit ? AppColors.warning : AppColors.success;
    final label = requiresAudit ? 'Audit Required' : 'Audit Exempt';
    final icon = requiresAudit
        ? Icons.gavel_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilingRow extends StatelessWidget {
  const _FilingRow({
    required this.label,
    required this.dueLabel,
    required this.status,
    required this.daysLate,
    required this.penalty,
    required this.theme,
  });

  final String label;
  final String dueLabel;
  final LLPFilingStatus status;
  final int daysLate;
  final double penalty;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dueLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              if (daysLate > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '$daysLate days late · ₹${penalty.toStringAsFixed(0)} penalty',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _StatusChip(status: status),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final LLPFilingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

class _TotalPenaltyCard extends StatelessWidget {
  const _TotalPenaltyCard({required this.totalPenalty, required this.theme});

  final double totalPenalty;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.currency_rupee_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Total Penalty',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ),
          Text(
            totalPenalty == 0
                ? '₹0'
                : '₹${(totalPenalty / 100000).toStringAsFixed(2)}L',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Itr5DueDateRow extends StatelessWidget {
  const _Itr5DueDateRow({required this.record, required this.theme});

  final LlpFilingRecord record;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final dueDate = LlpPenaltyCalculator.itr5DueDate(
      requiresAudit: record.requiresAudit,
      hasTransferPricing: false,
    );

    return Row(
      children: [
        const Icon(
          Icons.receipt_long_rounded,
          size: 16,
          color: AppColors.neutral400,
        ),
        const SizedBox(width: 8),
        Text(
          'ITR-5 due date: $dueDate',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.record});

  final LlpFilingRecord record;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('File Form 11'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Form 11 filing initiated for ${record.llpName}',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('File Form 8'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Form 8 filing initiated for ${record.llpName}',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
