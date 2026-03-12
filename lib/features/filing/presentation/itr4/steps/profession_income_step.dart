import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr4_form_data_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr4/profession_income_44ada.dart';

class ProfessionIncomeStep extends ConsumerStatefulWidget {
  const ProfessionIncomeStep({super.key});

  @override
  ConsumerState<ProfessionIncomeStep> createState() =>
      _ProfessionIncomeStepState();
}

class _ProfessionIncomeStepState extends ConsumerState<ProfessionIncomeStep> {
  late final TextEditingController _professionCtrl;
  late final TextEditingController _receiptsCtrl;

  @override
  void initState() {
    super.initState();
    final pi = ref.read(itr4FormDataProvider).professionIncome44ADA;
    _professionCtrl = TextEditingController(text: pi.natureOfProfession);
    _receiptsCtrl = TextEditingController(
      text: pi.grossReceipts > 0 ? pi.grossReceipts.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _professionCtrl.dispose();
    _receiptsCtrl.dispose();
    super.dispose();
  }

  void _persist() {
    final pi = ProfessionIncome44ADA(
      natureOfProfession: _professionCtrl.text.trim(),
      grossReceipts: double.tryParse(_receiptsCtrl.text.trim()) ?? 0,
    );
    ref.read(itr4FormDataProvider.notifier).updateProfessionIncome(pi);
  }

  @override
  Widget build(BuildContext context) {
    final pi = ref.watch(itr4FormDataProvider).professionIncome44ADA;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Section 44ADA — Presumptive Professional Income',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'For professionals (doctors, lawyers, CAs, architects, etc.) '
            'with gross receipts ≤ ₹75 lakhs. Income deemed at 50% of '
            'gross receipts.',
            style: TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextFormField(
              controller: _professionCtrl,
              decoration: const InputDecoration(
                labelText: 'Nature of Profession',
                hintText: 'e.g. Chartered Accountant',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _persist(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextFormField(
              controller: _receiptsCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Gross Receipts',
                hintText: '0',
                prefixText: '₹ ',
                helperText: 'Max ₹75,00,000 for 44ADA',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _persist(),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppColors.secondary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Presumptive Income (50%)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(pi.presumptiveIncome),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (pi.grossReceipts > 7500000)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gross receipts exceed ₹75 lakhs limit for '
                      'Section 44ADA. Consider filing ITR-3 instead.',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
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
