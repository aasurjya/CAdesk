import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/advance_tax_providers.dart';

/// Card displaying interest computation under Sections 234B and 234C.
class InterestCalculationCard extends StatelessWidget {
  const InterestCalculationCard({
    super.key,
    required this.interest,
    required this.totalLiability,
    required this.totalPaid,
  });

  final AdvanceTaxInterest interest;
  final double totalLiability;
  final double totalPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasInterest = interest.totalInterest > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasInterest
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.neutral200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  hasInterest
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 18,
                  color: hasInterest ? AppColors.error : AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Interest Computation',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Section 234B
            _InterestRow(
              section: 'Section 234B',
              description: 'Default on assessed tax (1% p.m.)',
              amount: interest.section234B,
            ),

            const Divider(height: 16),

            // Section 234C
            _InterestRow(
              section: 'Section 234C',
              description: 'Deferment of installments (1% p.m.)',
              amount: interest.section234C,
            ),

            // Quarterly breakdown
            if (interest.section234C > 0) ...[
              const SizedBox(height: 10),
              _QuarterlyBreakdown(quarterlyDetails: interest.quarterlyDetails),
            ],

            const Divider(height: 16),

            // Total interest
            Row(
              children: [
                Text(
                  'Total Interest Payable',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyUtils.formatINR(interest.totalInterest),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: hasInterest ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Visual bar: liability vs payment
            _PaymentProgressBar(
              totalLiability: totalLiability,
              totalPaid: totalPaid,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _InterestRow extends StatelessWidget {
  const _InterestRow({
    required this.section,
    required this.description,
    required this.amount,
  });

  final String section;
  final String description;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final hasAmount = amount > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasAmount ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
        Text(
          CurrencyUtils.formatINR(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: hasAmount ? AppColors.error : AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _QuarterlyBreakdown extends StatelessWidget {
  const _QuarterlyBreakdown({required this.quarterlyDetails});

  final List<double> quarterlyDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Quarter',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '234C Interest',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 8),
          // Rows
          for (int i = 0; i < quarterlyDetails.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Q${i + 1}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      CurrencyUtils.formatINR(quarterlyDetails[i]),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: quarterlyDetails[i] > 0
                            ? AppColors.error
                            : AppColors.neutral600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentProgressBar extends StatelessWidget {
  const _PaymentProgressBar({
    required this.totalLiability,
    required this.totalPaid,
  });

  final double totalLiability;
  final double totalPaid;

  @override
  Widget build(BuildContext context) {
    final progress = totalLiability > 0
        ? (totalPaid / totalLiability).clamp(0.0, 1.0)
        : 0.0;

    final color = progress >= 0.9
        ? AppColors.success
        : progress >= 0.5
        ? AppColors.warning
        : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Payment Progress',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral400,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.neutral100,
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Paid: ${CurrencyUtils.formatINRCompact(totalPaid)}',
              style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
            ),
            const Spacer(),
            Text(
              'Liability: ${CurrencyUtils.formatINRCompact(totalLiability)}',
              style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
            ),
          ],
        ),
      ],
    );
  }
}
