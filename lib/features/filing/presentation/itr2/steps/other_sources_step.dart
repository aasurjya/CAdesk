import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';

/// ITR-2 other sources step — same as ITR-1 (savings interest, FD interest,
/// dividends, family pension, other income).
class Itr2OtherSourcesStep extends ConsumerStatefulWidget {
  const Itr2OtherSourcesStep({super.key});

  @override
  ConsumerState<Itr2OtherSourcesStep> createState() =>
      _Itr2OtherSourcesStepState();
}

class _Itr2OtherSourcesStepState extends ConsumerState<Itr2OtherSourcesStep> {
  late final TextEditingController _savingsCtrl;
  late final TextEditingController _fdCtrl;
  late final TextEditingController _dividendCtrl;
  late final TextEditingController _pensionCtrl;
  late final TextEditingController _otherCtrl;

  @override
  void initState() {
    super.initState();
    final os = ref.read(itr2FormDataProvider).otherSourceIncome;
    _savingsCtrl = _init(os.savingsAccountInterest);
    _fdCtrl = _init(os.fixedDepositInterest);
    _dividendCtrl = _init(os.dividendIncome);
    _pensionCtrl = _init(os.familyPension);
    _otherCtrl = _init(os.otherIncome);
  }

  TextEditingController _init(double val) =>
      TextEditingController(text: val > 0 ? val.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _savingsCtrl.dispose();
    _fdCtrl.dispose();
    _dividendCtrl.dispose();
    _pensionCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim()) ?? 0;

  void _persist() {
    final os = OtherSourceIncome(
      savingsAccountInterest: _parse(_savingsCtrl),
      fixedDepositInterest: _parse(_fdCtrl),
      dividendIncome: _parse(_dividendCtrl),
      familyPension: _parse(_pensionCtrl),
      otherIncome: _parse(_otherCtrl),
    );
    ref.read(itr2FormDataProvider.notifier).updateOtherSources(os);
  }

  Widget _numField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(
          labelText: label,
          hintText: '0',
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
    final os = ref.watch(itr2FormDataProvider).otherSourceIncome;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _numField('Savings Account Interest', _savingsCtrl),
          _numField('Fixed Deposit (FD) Interest', _fdCtrl),
          _numField('Dividend Income', _dividendCtrl),
          _numField('Family Pension', _pensionCtrl),
          _numField('Any Other Income', _otherCtrl),
          const SizedBox(height: 8),
          Card(
            color: AppColors.secondary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Other Sources',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(os.total),
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
