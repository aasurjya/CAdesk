import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';
import 'package:ca_app/features/filing/domain/models/interest_result.dart';

class TaxComputationStep extends ConsumerWidget {
  const TaxComputationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxResult = ref.watch(liveTaxComputationProvider);
    final interestResult = ref.watch(liveInterestProvider);
    final formData = ref.watch(itr1FormDataProvider);
    final selected = formData.selectedRegime;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecommendedBadge(result: taxResult),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RegimeCard(
                  title: 'Old Regime',
                  regime: TaxRegime.oldRegime,
                  taxableIncome: taxResult.oldRegimeTaxableIncome,
                  baseTax: taxResult.oldRegimeTaxBeforeCess,
                  surcharge: taxResult.oldRegimeSurcharge,
                  cess: taxResult.oldRegimeCess,
                  totalTax: taxResult.oldRegimeTax,
                  isRecommended:
                      taxResult.recommendedRegime == TaxRegime.oldRegime,
                  isSelected: selected == TaxRegime.oldRegime,
                  onSelect: () => ref
                      .read(itr1FormDataProvider.notifier)
                      .updateRegime(TaxRegime.oldRegime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RegimeCard(
                  title: 'New Regime',
                  regime: TaxRegime.newRegime,
                  taxableIncome: taxResult.newRegimeTaxableIncome,
                  baseTax: taxResult.newRegimeTaxBeforeCess,
                  surcharge: taxResult.newRegimeSurcharge,
                  cess: taxResult.newRegimeCess,
                  totalTax: taxResult.newRegimeTax,
                  isRecommended:
                      taxResult.recommendedRegime == TaxRegime.newRegime,
                  isSelected: selected == TaxRegime.newRegime,
                  onSelect: () => ref
                      .read(itr1FormDataProvider.notifier)
                      .updateRegime(TaxRegime.newRegime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (interestResult.totalInterest > 0)
            _InterestCard(result: interestResult),
        ],
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge({required this.result});

  final TaxRegimeResult result;

  @override
  Widget build(BuildContext context) {
    if (result.savings == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${result.recommendedRegime.label} saves you '
              '${CurrencyUtils.formatINR(result.savings)} in tax.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
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
    required this.regime,
    required this.taxableIncome,
    required this.baseTax,
    required this.surcharge,
    required this.cess,
    required this.totalTax,
    required this.isRecommended,
    required this.isSelected,
    required this.onSelect,
  });

  final String title;
  final TaxRegime regime;
  final double taxableIncome;
  final double baseTax;
  final double surcharge;
  final double cess;
  final double totalTax;
  final bool isRecommended;
  final bool isSelected;
  final VoidCallback onSelect;

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.neutral600,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            CurrencyUtils.formatINR(value),
            style: TextStyle(
              fontSize: 11,
              color: bold ? AppColors.primary : AppColors.neutral900,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.neutral400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Best',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 12),
            _row('Taxable Income', taxableIncome),
            _row('Base Tax', baseTax),
            _row('Surcharge', surcharge),
            _row('Cess (4%)', cess),
            const Divider(height: 10),
            _row('Total Tax', totalTax, bold: true),
          ],
        ),
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.result});

  final InterestResult result;

  Widget _iRow(String label, double amount, int months) {
    if (amount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label ($months mo.)',
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Text(
            CurrencyUtils.formatINR(amount),
            style: const TextStyle(fontSize: 12, color: AppColors.neutral900),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interest Liability (Sec 234A / B / C)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
                fontSize: 13,
              ),
            ),
            const Divider(height: 12),
            _iRow('234A — Late filing', result.interest234A, result.months234A),
            _iRow(
              '234B — Advance tax shortfall',
              result.interest234B,
              result.months234B,
            ),
            _iRow(
              '234C — Advance tax deferment',
              result.interest234C,
              result.months234C,
            ),
            const Divider(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Interest',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  CurrencyUtils.formatINR(result.totalInterest),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
