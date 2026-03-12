import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';

class DeductionsStep extends ConsumerStatefulWidget {
  const DeductionsStep({super.key});

  @override
  ConsumerState<DeductionsStep> createState() => _DeductionsStepState();
}

class _DeductionsStepState extends ConsumerState<DeductionsStep> {
  late final TextEditingController _c80CCtrl;
  late final TextEditingController _c80Ccd1BCtrl;
  late final TextEditingController _c80DSelfCtrl;
  late final TextEditingController _c80DParentsCtrl;
  late final TextEditingController _c80ECtrl;
  late final TextEditingController _c80GCtrl;
  late final TextEditingController _c80TTACtrl;
  late final TextEditingController _c80TTBCtrl;

  @override
  void initState() {
    super.initState();
    final d = ref.read(itr1FormDataProvider).deductions;
    _c80CCtrl = _init(d.section80C);
    _c80Ccd1BCtrl = _init(d.section80CCD1B);
    _c80DSelfCtrl = _init(d.section80DSelf);
    _c80DParentsCtrl = _init(d.section80DParents);
    _c80ECtrl = _init(d.section80E);
    _c80GCtrl = _init(d.section80G);
    _c80TTACtrl = _init(d.section80TTA);
    _c80TTBCtrl = _init(d.section80TTB);
  }

  TextEditingController _init(double val) =>
      TextEditingController(text: val > 0 ? val.toStringAsFixed(0) : '');

  @override
  void dispose() {
    for (final c in [
      _c80CCtrl,
      _c80Ccd1BCtrl,
      _c80DSelfCtrl,
      _c80DParentsCtrl,
      _c80ECtrl,
      _c80GCtrl,
      _c80TTACtrl,
      _c80TTBCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _parse(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim()) ?? 0;

  void _persist() {
    final d = ChapterViaDeductions(
      section80C: _parse(_c80CCtrl),
      section80CCD1B: _parse(_c80Ccd1BCtrl),
      section80DSelf: _parse(_c80DSelfCtrl),
      section80DParents: _parse(_c80DParentsCtrl),
      section80E: _parse(_c80ECtrl),
      section80G: _parse(_c80GCtrl),
      section80TTA: _parse(_c80TTACtrl),
      section80TTB: _parse(_c80TTBCtrl),
    );
    ref.read(itr1FormDataProvider.notifier).updateDeductions(d);
  }

  Widget _deductionField(
    String label,
    TextEditingController ctrl,
    String maxHint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(
          labelText: label,
          hintText: '0',
          helperText: maxHint,
          prefixText: '₹ ',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _persist(),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontSize: 13,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(itr1FormDataProvider);
    final regime = formData.selectedRegime;
    final deductions = formData.deductions;
    final isOldRegime = regime == TaxRegime.oldRegime;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOldRegime)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Most Chapter VI-A deductions are not available under '
                      'New Regime. Switch to Old Regime on the Tax Computation '
                      'step to claim these deductions.',
                      style: TextStyle(fontSize: 12, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          _sectionHeader('Investments & Savings'),
          _deductionField(
            '80C — PPF, ELSS, LIC, NSC, etc.',
            _c80CCtrl,
            'Max ₹1,50,000',
          ),
          _deductionField(
            '80CCD(1B) — NPS Contribution (additional)',
            _c80Ccd1BCtrl,
            'Max ₹50,000',
          ),
          _sectionHeader('Medical Insurance (Section 80D)'),
          _deductionField(
            '80D — Self & Family',
            _c80DSelfCtrl,
            'Max ₹25,000 (₹50,000 if senior citizen)',
          ),
          _deductionField(
            '80D — Parents',
            _c80DParentsCtrl,
            'Max ₹25,000 (₹50,000 if parents are senior citizens)',
          ),
          _sectionHeader('Loan & Donations'),
          _deductionField(
            '80E — Education Loan Interest',
            _c80ECtrl,
            'No limit',
          ),
          _deductionField(
            '80G — Donations to Approved Funds',
            _c80GCtrl,
            'Varies (50%/100% of donation)',
          ),
          _sectionHeader('Savings Interest'),
          _deductionField(
            '80TTA — Savings Account Interest (below 60 yrs)',
            _c80TTACtrl,
            'Max ₹10,000',
          ),
          _deductionField(
            '80TTB — Deposits Interest (senior citizen 60+)',
            _c80TTBCtrl,
            'Max ₹50,000',
          ),
          const SizedBox(height: 8),
          Card(
            color: isOldRegime ? AppColors.primary : AppColors.neutral400,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Deductions (after caps)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(
                      isOldRegime ? deductions.totalDeductions : 0,
                    ),
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
