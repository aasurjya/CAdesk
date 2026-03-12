import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';

class HousePropertyStep extends ConsumerStatefulWidget {
  const HousePropertyStep({super.key});

  @override
  ConsumerState<HousePropertyStep> createState() => _HousePropertyStepState();
}

class _HousePropertyStepState extends ConsumerState<HousePropertyStep> {
  late final TextEditingController _alvCtrl;
  late final TextEditingController _municipalCtrl;
  late final TextEditingController _interestCtrl;

  @override
  void initState() {
    super.initState();
    final hp = ref.read(itr1FormDataProvider).housePropertyIncome;
    _alvCtrl = TextEditingController(
      text: hp.annualLetableValue > 0
          ? hp.annualLetableValue.toStringAsFixed(0)
          : '',
    );
    _municipalCtrl = TextEditingController(
      text: hp.municipalTaxesPaid > 0
          ? hp.municipalTaxesPaid.toStringAsFixed(0)
          : '',
    );
    _interestCtrl = TextEditingController(
      text: hp.interestOnLoan > 0 ? hp.interestOnLoan.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _alvCtrl.dispose();
    _municipalCtrl.dispose();
    _interestCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim()) ?? 0;

  void _persist() {
    final hp = HousePropertyIncome(
      annualLetableValue: _parse(_alvCtrl),
      municipalTaxesPaid: _parse(_municipalCtrl),
      interestOnLoan: _parse(_interestCtrl),
    );
    ref.read(itr1FormDataProvider.notifier).updateHouseProperty(hp);
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
          prefixText: '₹ ',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _persist(),
      ),
    );
  }

  Widget _computedRow(String label, double value, {bool highlighted = false}) {
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
            CurrencyUtils.formatINR(value),
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

  @override
  Widget build(BuildContext context) {
    final hp = ref.watch(itr1FormDataProvider).housePropertyIncome;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _numField('Annual Letable Value (Gross Rent)', _alvCtrl),
          _numField('Municipal Taxes Paid', _municipalCtrl),
          _numField('Interest on Housing Loan (Sec 24(b))', _interestCtrl),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Computation (Section 24)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(height: 16),
                  _computedRow('Net Annual Value', hp.netAnnualValue),
                  _computedRow(
                    '30% Standard Deduction (Sec 24(a))',
                    -hp.standardDeduction30Percent,
                  ),
                  _computedRow(
                    'Interest on Loan (Sec 24(b))',
                    -hp.interestOnLoan,
                  ),
                  const Divider(height: 12),
                  _computedRow(
                    'Income from House Property',
                    hp.incomeFromHouseProperty,
                    highlighted: true,
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
