import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/payroll_providers.dart';

final _inr = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// Compact summary card showing aggregate payroll figures for the current
/// period, computed dynamically from [payrollSummaryProvider].
class PayrollSummaryWidget extends ConsumerWidget {
  const PayrollSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(payrollSummaryProvider);

    final totalPfLiability =
        summary.totalPfContribution * 2; // employee + employer ≈ 2×

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Payroll Summary',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${summary.totalEmployees} employees',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Grid of summary chips
          Row(
            children: [
              _SummaryChip(
                label: 'Total Gross',
                value:
                    '₹${(summary.totalGrossPayout / 100000).toStringAsFixed(2)}L',
                color: AppColors.primary,
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Net Pay Out',
                value:
                    '₹${(summary.totalNetPayout / 100000).toStringAsFixed(2)}L',
                color: AppColors.success,
                icon: Icons.payments_rounded,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _SummaryChip(
                label: 'PF Liability',
                value: _inr.format(totalPfLiability),
                color: AppColors.secondary,
                icon: Icons.shield_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'ESI Liability',
                value: _inr.format(summary.totalEsiContribution * 4.333),
                color: const Color(0xFF0D7C7C),
                icon: Icons.health_and_safety_rounded,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _SummaryChip(
                label: 'Total TDS',
                value: _inr.format(summary.totalTdsContribution),
                color: AppColors.warning,
                icon: Icons.receipt_long_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Net Outflow',
                value:
                    '₹${(summary.totalNetPayout / 100000).toStringAsFixed(2)}L',
                color: AppColors.neutral600,
                icon: Icons.trending_down_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper
// ---------------------------------------------------------------------------

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
