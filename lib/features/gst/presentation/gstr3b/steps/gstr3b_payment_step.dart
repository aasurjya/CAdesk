import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr3b_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';

/// Step 4: Payment & Summary -- cash/ITC utilization, challan, submit.
class Gstr3bPaymentStep extends ConsumerWidget {
  const Gstr3bPaymentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(gstr3bFormDataProvider);
    final isValid = ref.watch(gstr3bPeriodValidProvider);
    final netTax = ref.watch(gstr3bNetTaxPayableProvider);
    // Assume 0 days late for now; in production this would be computed.
    final interest = ref.watch(gstr3bInterestProvider(0));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filing details
        _InfoCard(
          title: 'Filing Details',
          icon: Icons.info_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'GSTIN', value: formData.gstin),
              _DetailRow(label: 'Period', value: formData.periodLabel),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ITC Utilization Matrix
        _ItcUtilizationCard(formData: formData),
        const SizedBox(height: 12),

        // Tax payment summary
        _PaymentSummaryCard(
          formData: formData,
          netTax: netTax,
          interest: interest,
        ),
        const SizedBox(height: 12),

        // Late fee info
        _LateFeeCard(),
        const SizedBox(height: 12),

        // Challan preview
        _ChallanPreview(netTax: netTax, interest: interest),
        const SizedBox(height: 20),

        // Submit button
        FilledButton.icon(
          onPressed: isValid
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GSTR-3B submitted for filing'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Submit GSTR-3B'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Payment via Challan (PMT-06) required before submission',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ITC Utilization Matrix
// ---------------------------------------------------------------------------

class _ItcUtilizationCard extends StatelessWidget {
  const _ItcUtilizationCard({required this.formData});

  final Gstr3bFormData formData;

  @override
  Widget build(BuildContext context) {
    final liability = formData.taxLiability;
    final itc = formData.itcClaimed;

    // IGST ITC utilization order: IGST liability first, then CGST, then SGST
    final igstItc = itc.netItcAvailable.igst;
    final igstUsedForIgst = igstItc.clamp(0.0, liability.totalIgst);
    final igstRemaining = igstItc - igstUsedForIgst;
    final igstUsedForCgst = igstRemaining.clamp(0.0, liability.totalCgst);
    final igstRem2 = igstRemaining - igstUsedForCgst;
    final igstUsedForSgst = igstRem2.clamp(0.0, liability.totalSgst);

    final cgstItc = itc.netItcAvailable.cgst;
    final cgstLiabAfterIgst = liability.totalCgst - igstUsedForCgst;
    final cgstUsed = cgstItc.clamp(0.0, cgstLiabAfterIgst);

    final sgstItc = itc.netItcAvailable.sgst;
    final sgstLiabAfterIgst = liability.totalSgst - igstUsedForSgst;
    final sgstUsed = sgstItc.clamp(0.0, sgstLiabAfterIgst);

    return _InfoCard(
      title: 'ITC Utilization (IGST -> CGST -> SGST)',
      icon: Icons.account_balance_rounded,
      child: Column(
        children: [
          _UtilRow(
            head: 'IGST',
            liability: CurrencyUtils.formatINR(liability.totalIgst),
            itcUsed: CurrencyUtils.formatINR(igstUsedForIgst),
            cash: CurrencyUtils.formatINR(
              (liability.totalIgst - igstUsedForIgst).clamp(
                0.0,
                double.infinity,
              ),
            ),
          ),
          const Divider(height: 8),
          _UtilRow(
            head: 'CGST',
            liability: CurrencyUtils.formatINR(liability.totalCgst),
            itcUsed: CurrencyUtils.formatINR(igstUsedForCgst + cgstUsed),
            cash: CurrencyUtils.formatINR(
              (cgstLiabAfterIgst - cgstUsed).clamp(0.0, double.infinity),
            ),
          ),
          const Divider(height: 8),
          _UtilRow(
            head: 'SGST',
            liability: CurrencyUtils.formatINR(liability.totalSgst),
            itcUsed: CurrencyUtils.formatINR(igstUsedForSgst + sgstUsed),
            cash: CurrencyUtils.formatINR(
              (sgstLiabAfterIgst - sgstUsed).clamp(0.0, double.infinity),
            ),
          ),
          const Divider(height: 8),
          _UtilRow(
            head: 'Cess',
            liability: CurrencyUtils.formatINR(liability.totalCess),
            itcUsed: CurrencyUtils.formatINR(
              itc.netItcAvailable.cess.clamp(0.0, liability.totalCess),
            ),
            cash: CurrencyUtils.formatINR(
              (liability.totalCess - itc.netItcAvailable.cess).clamp(
                0.0,
                double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilRow extends StatelessWidget {
  const _UtilRow({
    required this.head,
    required this.liability,
    required this.itcUsed,
    required this.cash,
  });

  final String head;
  final String liability;
  final String itcUsed;
  final String cash;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              head,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              liability,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              itcUsed,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              cash,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment summary
// ---------------------------------------------------------------------------

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({
    required this.formData,
    required this.netTax,
    required this.interest,
  });

  final Gstr3bFormData formData;
  final double netTax;
  final double interest;

  @override
  Widget build(BuildContext context) {
    final liability = formData.taxLiability.totalTaxLiability;
    final itcAvail = formData.itcClaimed.netItcAvailable.totalItc;
    final cashRequired = netTax > 0 ? netTax : 0.0;

    return _InfoCard(
      title: 'Payment Summary',
      icon: Icons.payment_rounded,
      child: Column(
        children: [
          _PayRow(
            label: 'Total Tax Liability',
            value: CurrencyUtils.formatINR(liability),
          ),
          _PayRow(
            label: 'ITC Utilization',
            value:
                '- ${CurrencyUtils.formatINR(itcAvail.clamp(0.0, liability))}',
            valueColor: AppColors.success,
          ),
          const Divider(height: 12),
          _PayRow(
            label: 'Cash Payment Required',
            value: CurrencyUtils.formatINR(cashRequired),
            isBold: true,
            valueColor: cashRequired > 0 ? AppColors.error : AppColors.success,
          ),
          if (interest > 0)
            _PayRow(
              label: 'Interest (18% p.a.)',
              value: CurrencyUtils.formatINR(interest),
              valueColor: AppColors.warning,
            ),
          _PayRow(
            label: 'Total Payable',
            value: CurrencyUtils.formatINR(cashRequired + interest),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Late fee card
// ---------------------------------------------------------------------------

class _LateFeeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Late Fee Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Regular: \u20B950/day (max \u20B910,000)\n'
                  'Nil return: \u20B920/day (max \u20B9500)\n'
                  'Interest: 18% p.a. on outstanding tax',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral600,
                    height: 1.4,
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

// ---------------------------------------------------------------------------
// Challan preview
// ---------------------------------------------------------------------------

class _ChallanPreview extends StatelessWidget {
  const _ChallanPreview({required this.netTax, required this.interest});

  final double netTax;
  final double interest;

  @override
  Widget build(BuildContext context) {
    final cashRequired = netTax > 0 ? netTax : 0.0;
    final total = cashRequired + interest;

    return _InfoCard(
      title: 'Challan Preview (PMT-06)',
      icon: Icons.receipt_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                CurrencyUtils.formatINR(total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: cashRequired > 0
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Generating challan...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Generate Challan'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared info card
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
