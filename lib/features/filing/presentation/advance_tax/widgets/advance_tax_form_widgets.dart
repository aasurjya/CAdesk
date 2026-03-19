import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/advance_tax_providers.dart';

/// Summary card displaying tax liability, paid, balance, and interest.
class AdvanceTaxSummaryCard extends StatelessWidget {
  const AdvanceTaxSummaryCard({super.key, required this.summary});

  final AdvanceTaxSummary summary;

  @override
  Widget build(BuildContext context) {
    final balanceColor = summary.balance > 0
        ? AppColors.error
        : summary.balance < 0
        ? AppColors.success
        : AppColors.neutral600;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _SummaryItem(
              label: 'Tax Liability',
              value: CurrencyUtils.formatINRCompact(summary.totalLiability),
              color: AppColors.primary,
            ),
            _SummaryItem(
              label: 'Total Paid',
              value: CurrencyUtils.formatINRCompact(summary.totalPaid),
              color: AppColors.success,
            ),
            _SummaryItem(
              label: 'Balance',
              value: CurrencyUtils.formatINRCompact(summary.balance.abs()),
              color: balanceColor,
            ),
            _SummaryItem(
              label: 'Interest',
              value: CurrencyUtils.formatINRCompact(summary.interestAccrued),
              color: summary.interestAccrued > 0
                  ? AppColors.error
                  : AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

/// Section header with icon and optional trailing widget.
class AdvanceTaxSectionHeader extends StatelessWidget {
  const AdvanceTaxSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.primary,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

/// Income estimation form card.
class IncomeEstimationForm extends StatelessWidget {
  const IncomeEstimationForm({
    super.key,
    required this.formKey,
    required this.salaryCtrl,
    required this.businessCtrl,
    required this.capitalGainsCtrl,
    required this.otherSourcesCtrl,
    required this.tdsCtrl,
    required this.onCompute,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController salaryCtrl;
  final TextEditingController businessCtrl;
  final TextEditingController capitalGainsCtrl;
  final TextEditingController otherSourcesCtrl;
  final TextEditingController tdsCtrl;
  final VoidCallback onCompute;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _IncomeField(
                controller: salaryCtrl,
                label: 'Salary Income',
                icon: Icons.work_rounded,
              ),
              const SizedBox(height: 10),
              _IncomeField(
                controller: businessCtrl,
                label: 'Business / Professional Income',
                icon: Icons.business_rounded,
              ),
              const SizedBox(height: 10),
              _IncomeField(
                controller: capitalGainsCtrl,
                label: 'Capital Gains',
                icon: Icons.trending_up_rounded,
              ),
              const SizedBox(height: 10),
              _IncomeField(
                controller: otherSourcesCtrl,
                label: 'Other Sources',
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 10),
              _IncomeField(
                controller: tdsCtrl,
                label: 'TDS Already Deducted',
                icon: Icons.remove_circle_outline_rounded,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onCompute,
                  icon: const Icon(Icons.calculate_rounded, size: 16),
                  label: const Text('Compute Tax'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomeField extends StatelessWidget {
  const _IncomeField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        prefixText: '\u20B9 ',
        prefixStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
      ),
      validator: (v) {
        if (v != null && v.isNotEmpty) {
          final parsed = double.tryParse(v);
          if (parsed == null) return 'Enter a valid amount';
          if (parsed < 0) return 'Amount cannot be negative';
        }
        return null;
      },
    );
  }
}
