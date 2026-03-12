import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr4_form_data_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';

class Itr4TaxComputationStep extends ConsumerWidget {
  const Itr4TaxComputationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(itr4FormDataProvider);
    final taxResult = ref.watch(liveItr4TaxComputationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income Summary',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _row(
                    'Business (44AD)',
                    CurrencyUtils.formatINR(
                      formData.businessIncome44AD.presumptiveIncome,
                    ),
                  ),
                  _row(
                    'Professional (44ADA)',
                    CurrencyUtils.formatINR(
                      formData.professionIncome44ADA.presumptiveIncome,
                    ),
                  ),
                  _row(
                    'Other Sources',
                    CurrencyUtils.formatINR(formData.otherSourceIncome.total),
                  ),
                  const Divider(height: 12),
                  _row(
                    'Gross Total Income',
                    CurrencyUtils.formatINR(formData.grossTotalIncome),
                    highlighted: true,
                  ),
                  _row(
                    'Deductions (Ch VI-A)',
                    CurrencyUtils.formatINR(-formData.allowableDeductions),
                  ),
                  _row(
                    'Taxable Income',
                    CurrencyUtils.formatINR(formData.taxableIncome),
                    highlighted: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tax Comparison',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _RegimeCard(
                  title: 'Old Regime',
                  taxableIncome: taxResult.oldRegimeTaxableIncome,
                  baseTax: taxResult.oldRegimeTaxBeforeCess,
                  surcharge: taxResult.oldRegimeSurcharge,
                  cess: taxResult.oldRegimeCess,
                  total: taxResult.oldRegimeTax,
                  isRecommended:
                      taxResult.recommendedRegime == TaxRegime.oldRegime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RegimeCard(
                  title: 'New Regime',
                  taxableIncome: taxResult.newRegimeTaxableIncome,
                  baseTax: taxResult.newRegimeTaxBeforeCess,
                  surcharge: taxResult.newRegimeSurcharge,
                  cess: taxResult.newRegimeCess,
                  total: taxResult.newRegimeTax,
                  isRecommended:
                      taxResult.recommendedRegime == TaxRegime.newRegime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.success,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended: ${taxResult.recommendedRegime.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Save ${CurrencyUtils.formatINR(taxResult.savings)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _row(String label, String value, {bool highlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: highlighted ? AppColors.primary : AppColors.neutral600,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: highlighted ? AppColors.primary : AppColors.neutral900,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegimeCard extends StatelessWidget {
  const _RegimeCard({
    required this.title,
    required this.taxableIncome,
    required this.baseTax,
    required this.surcharge,
    required this.cess,
    required this.total,
    required this.isRecommended,
  });

  final String title;
  final double taxableIncome;
  final double baseTax;
  final double surcharge;
  final double cess;
  final double total;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isRecommended
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                if (isRecommended) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _miniRow('Tax', CurrencyUtils.formatINR(baseTax)),
            _miniRow('Surcharge', CurrencyUtils.formatINR(surcharge)),
            _miniRow('Cess', CurrencyUtils.formatINR(cess)),
            const Divider(height: 8),
            _miniRow('Total', CurrencyUtils.formatINR(total), bold: true),
          ],
        ),
      ),
    );
  }

  Widget _miniRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
