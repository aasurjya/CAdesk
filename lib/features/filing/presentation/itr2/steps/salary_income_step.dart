import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';

/// ITR-2 salary income step — same structure as ITR-1 (gross salary,
/// exempt allowances, perquisites, profits in lieu, standard deduction).
class Itr2SalaryIncomeStep extends ConsumerStatefulWidget {
  const Itr2SalaryIncomeStep({super.key});

  @override
  ConsumerState<Itr2SalaryIncomeStep> createState() =>
      _Itr2SalaryIncomeStepState();
}

class _Itr2SalaryIncomeStepState extends ConsumerState<Itr2SalaryIncomeStep> {
  late final TextEditingController _grossCtrl;
  late final TextEditingController _exemptCtrl;
  late final TextEditingController _perqCtrl;
  late final TextEditingController _profitCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(itr2FormDataProvider).salaryIncome;
    _grossCtrl = TextEditingController(
      text: s.grossSalary > 0 ? s.grossSalary.toStringAsFixed(0) : '',
    );
    _exemptCtrl = TextEditingController(
      text: s.allowancesExemptUnderSection10 > 0
          ? s.allowancesExemptUnderSection10.toStringAsFixed(0)
          : '',
    );
    _perqCtrl = TextEditingController(
      text: s.valueOfPerquisites > 0
          ? s.valueOfPerquisites.toStringAsFixed(0)
          : '',
    );
    _profitCtrl = TextEditingController(
      text: s.profitsInLieuOfSalary > 0
          ? s.profitsInLieuOfSalary.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _grossCtrl.dispose();
    _exemptCtrl.dispose();
    _perqCtrl.dispose();
    _profitCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim()) ?? 0;

  void _persist() {
    final regime = ref.read(itr2FormDataProvider).selectedRegime;
    final stdDed = regime == TaxRegime.newRegime ? 75000.0 : 50000.0;
    final income = SalaryIncome(
      grossSalary: _parse(_grossCtrl),
      allowancesExemptUnderSection10: _parse(_exemptCtrl),
      valueOfPerquisites: _parse(_perqCtrl),
      profitsInLieuOfSalary: _parse(_profitCtrl),
      standardDeduction: stdDed,
    );
    ref.read(itr2FormDataProvider.notifier).updateSalaryIncome(income);
  }

  Widget _numField(String label, TextEditingController ctrl, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? '0',
          prefixText: '\u20b9 ',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _persist(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salary = ref.watch(itr2FormDataProvider).salaryIncome;
    final regime = ref.watch(itr2FormDataProvider).selectedRegime;
    final stdDedAmt = regime == TaxRegime.newRegime ? 75000.0 : 50000.0;
    final netSalary = salary.netSalary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _numField('Gross Salary (as per Form 16)', _grossCtrl),
          _numField('Allowances Exempt u/s 10 (HRA, LTA, etc.)', _exemptCtrl),
          _numField('Value of Perquisites', _perqCtrl),
          _numField('Profits in Lieu of Salary', _profitCtrl),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.neutral600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Standard deduction: '
                    '\u20b9${CurrencyUtils.formatINRCompact(stdDedAmt)} '
                    '(${regime.label})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Taxable Salary',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(netSalary),
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
        ],
      ),
    );
  }
}
