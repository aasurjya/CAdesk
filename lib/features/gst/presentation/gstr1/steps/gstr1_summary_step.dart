import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr1_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';

/// Step 7: Summary & Submit -- totals review, JSON export, submit.
class Gstr1SummaryStep extends ConsumerWidget {
  const Gstr1SummaryStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(gstr1FormDataProvider);
    final isValid = ref.watch(gstr1PeriodValidProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Period info
        _InfoCard(
          title: 'Filing Details',
          icon: Icons.info_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'GSTIN', value: formData.gstin),
              _DetailRow(label: 'Period', value: formData.periodLabel),
              _DetailRow(
                label: 'Status',
                value: isValid ? 'Ready' : 'Incomplete',
                valueColor: isValid ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Section-wise summary
        _SectionSummary(formData: formData),
        const SizedBox(height: 12),

        // Tax totals
        _TaxTotalsCard(formData: formData),
        const SizedBox(height: 12),

        // Validation
        _ValidationCard(formData: formData),
        const SizedBox(height: 20),

        // Export button
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('GSTR-1 JSON export initiated'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Export GSTR-1 JSON'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 12),

        // Submit button
        FilledButton.icon(
          onPressed: isValid
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GSTR-1 submitted for filing'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Submit GSTR-1'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),

        // EVC / DSC indicator
        Center(
          child: Text(
            'Verification: EVC / DSC',
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
// Section-wise summary
// ---------------------------------------------------------------------------

class _SectionSummary extends StatelessWidget {
  const _SectionSummary({required this.formData});

  final Gstr1FormData formData;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Section-wise Count',
      icon: Icons.list_alt_rounded,
      child: Column(
        children: [
          _CountRow(
            label: 'Table 4A: B2B Invoices',
            count: formData.b2bInvoices.length,
          ),
          _CountRow(
            label: 'Table 5/7: B2C Invoices',
            count: formData.b2cInvoices.length,
          ),
          _CountRow(
            label: 'Table 9: CDNR',
            count: formData.creditDebitNotes.length,
          ),
          _CountRow(
            label: 'Table 9: CDNUR',
            count: formData.creditDebitNotesUnregistered.length,
          ),
          _CountRow(label: 'Table 6A: Exports', count: formData.exports.length),
          _CountRow(
            label: 'Table 11: Advance Tax',
            count: formData.advanceTax.length,
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            count > 0 ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: count > 0 ? AppColors.success : AppColors.neutral300,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: count > 0 ? AppColors.neutral900 : AppColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax totals card
// ---------------------------------------------------------------------------

class _TaxTotalsCard extends StatelessWidget {
  const _TaxTotalsCard({required this.formData});

  final Gstr1FormData formData;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Tax Summary',
      icon: Icons.account_balance_wallet_rounded,
      child: Column(
        children: [
          _TaxRow(
            label: 'Total Taxable Value',
            value: formData.totalTaxableValue,
          ),
          const Divider(height: 16),
          _TaxRow(label: 'IGST', value: formData.totalIgst),
          _TaxRow(label: 'CGST', value: formData.totalCgst),
          _TaxRow(label: 'SGST', value: formData.totalSgst),
          _TaxRow(label: 'CESS', value: formData.totalCess),
          const Divider(height: 16),
          _TaxRow(
            label: 'Total Tax',
            value:
                formData.totalIgst +
                formData.totalCgst +
                formData.totalSgst +
                formData.totalCess,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _TaxRow extends StatelessWidget {
  const _TaxRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: AppColors.neutral600,
              ),
            ),
          ),
          Text(
            CurrencyUtils.formatINR(value),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Validation card
// ---------------------------------------------------------------------------

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.formData});

  final Gstr1FormData formData;

  @override
  Widget build(BuildContext context) {
    final checks = <_ValidationItem>[
      _ValidationItem('GSTIN provided', formData.gstin.isNotEmpty),
      _ValidationItem(
        'Period selected',
        formData.periodMonth >= 1 && formData.periodYear >= 2020,
      ),
      _ValidationItem(
        'At least one invoice/entry',
        formData.b2bInvoices.isNotEmpty ||
            formData.b2cInvoices.isNotEmpty ||
            formData.exports.isNotEmpty,
      ),
    ];

    return _InfoCard(
      title: 'Validation',
      icon: Icons.verified_rounded,
      child: Column(
        children: checks
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      item.passed
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                      size: 16,
                      color: item.passed
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.passed
                            ? AppColors.neutral600
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ValidationItem {
  const _ValidationItem(this.label, this.passed);
  final String label;
  final bool passed;
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
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
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
