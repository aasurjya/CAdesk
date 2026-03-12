import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr4_form_data_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr4/business_income_44ad.dart';

class BusinessIncomeStep extends ConsumerStatefulWidget {
  const BusinessIncomeStep({super.key});

  @override
  ConsumerState<BusinessIncomeStep> createState() => _BusinessIncomeStepState();
}

class _BusinessIncomeStepState extends ConsumerState<BusinessIncomeStep> {
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _tradeNameCtrl;
  late final TextEditingController _cashTurnoverCtrl;
  late final TextEditingController _nonCashTurnoverCtrl;

  @override
  void initState() {
    super.initState();
    final bi = ref.read(itr4FormDataProvider).businessIncome44AD;
    _businessNameCtrl = TextEditingController(text: bi.natureOfBusiness);
    _tradeNameCtrl = TextEditingController(text: bi.tradeName);
    _cashTurnoverCtrl = _numInit(bi.cashTurnover);
    _nonCashTurnoverCtrl = _numInit(bi.nonCashTurnover);
  }

  TextEditingController _numInit(double val) =>
      TextEditingController(text: val > 0 ? val.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _tradeNameCtrl.dispose();
    _cashTurnoverCtrl.dispose();
    _nonCashTurnoverCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim()) ?? 0;

  void _persist() {
    final cash = _parse(_cashTurnoverCtrl);
    final nonCash = _parse(_nonCashTurnoverCtrl);
    final bi = BusinessIncome44AD(
      natureOfBusiness: _businessNameCtrl.text.trim(),
      tradeName: _tradeNameCtrl.text.trim(),
      cashTurnover: cash,
      nonCashTurnover: nonCash,
    );
    ref.read(itr4FormDataProvider.notifier).updateBusinessIncome(bi);
  }

  Widget _numField(String label, TextEditingController ctrl, {String? helper}) {
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
          helperText: helper,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _persist(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bi = ref.watch(itr4FormDataProvider).businessIncome44AD;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Section 44AD — Presumptive Business Income',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'For businesses with turnover ≤ ₹3 Cr. Income is deemed at '
            '8% of cash turnover and 6% of digital turnover.',
            style: TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextFormField(
              controller: _businessNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nature of Business',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _persist(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextFormField(
              controller: _tradeNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Trade Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _persist(),
            ),
          ),
          _numField(
            'Cash Turnover',
            _cashTurnoverCtrl,
            helper: 'Presumptive rate: 8%',
          ),
          _numField(
            'Digital / Non-Cash Turnover',
            _nonCashTurnoverCtrl,
            helper: 'Presumptive rate: 6%',
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _row('Total Turnover', CurrencyUtils.formatINR(bi.turnover)),
                  _row(
                    'Presumptive Income (44AD)',
                    CurrencyUtils.formatINR(bi.presumptiveIncome),
                    highlighted: true,
                  ),
                ],
              ),
            ),
          ),
          if (bi.turnover > 30000000)
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
                      'Turnover exceeds ₹3 Cr limit for Section 44AD. '
                      'Consider filing ITR-3 instead.',
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

  Widget _row(String label, String value, {bool highlighted = false}) {
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
