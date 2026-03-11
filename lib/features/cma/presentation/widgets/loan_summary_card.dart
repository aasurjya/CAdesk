import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/loan_calculator.dart';

String _formatCrore(double amount) {
  final crore = amount / 10000000;
  if (crore >= 1) return '₹${crore.toStringAsFixed(2)} Cr';
  final lakh = amount / 100000;
  return '₹${lakh.toStringAsFixed(1)} L';
}

/// Card showing loan summary with EMI, total interest, and tenure progress.
class LoanSummaryCard extends StatelessWidget {
  const LoanSummaryCard({super.key, required this.loan, this.onTap});

  final LoanCalculator loan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emiFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final yearsLeft = ((loan.tenureMonths - loan.monthsElapsed) / 12).ceil();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${loan.interestRate}% p.a.  •  '
                          '${(loan.tenureMonths / 12).toStringAsFixed(0)} yrs',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // EMI badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'EMI / month',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.accent,
                          ),
                        ),
                        Text(
                          emiFormat.format(loan.emi),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Principal / Total Interest row
              Row(
                children: [
                  Expanded(
                    child: _MetricCell(
                      label: 'Loan Amount',
                      value: _formatCrore(loan.loanAmount),
                      color: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _MetricCell(
                      label: 'Total Interest',
                      value: _formatCrore(loan.totalInterest),
                      color: AppColors.error,
                    ),
                  ),
                  Expanded(
                    child: _MetricCell(
                      label: 'Total Outflow',
                      value: _formatCrore(loan.totalPayment),
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tenure progress bar
              _TenureProgressBar(
                monthsElapsed: loan.monthsElapsed,
                tenureMonths: loan.tenureMonths,
                progressFraction: loan.progressFraction,
                yearsLeft: yearsLeft,
              ),
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

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.neutral400,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TenureProgressBar extends StatelessWidget {
  const _TenureProgressBar({
    required this.monthsElapsed,
    required this.tenureMonths,
    required this.progressFraction,
    required this.yearsLeft,
  });

  final int monthsElapsed;
  final int tenureMonths;
  final double progressFraction;
  final int yearsLeft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$monthsElapsed of $tenureMonths months elapsed',
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
            Text(
              yearsLeft > 0 ? '$yearsLeft yr(s) remaining' : 'Completed',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: yearsLeft > 0 ? AppColors.primary : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressFraction.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: AppColors.neutral200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
