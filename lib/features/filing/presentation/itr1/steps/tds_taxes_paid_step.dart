import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/tds_payment_summary.dart';

/// Wizard step for TDS deducted and taxes paid (Step 7 of 8).
///
/// Shows:
/// - TDS on salary (auto-populated from Form 16 if available)
/// - TDS on other income
/// - Advance tax per quarter (Q1–Q4)
/// - Self-assessment tax
/// - Computed: Total TDS + Taxes Paid, Balance Tax / Refund
class TdsTaxesPaidStep extends ConsumerStatefulWidget {
  const TdsTaxesPaidStep({super.key});

  @override
  ConsumerState<TdsTaxesPaidStep> createState() => _TdsTaxesPaidStepState();
}

class _TdsTaxesPaidStepState extends ConsumerState<TdsTaxesPaidStep> {
  late final TextEditingController _tdsOnSalaryCtrl;
  late final TextEditingController _tdsOnOtherCtrl;
  late final TextEditingController _advQ1Ctrl;
  late final TextEditingController _advQ2Ctrl;
  late final TextEditingController _advQ3Ctrl;
  late final TextEditingController _advQ4Ctrl;
  late final TextEditingController _selfAssessmentCtrl;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tdsOnSalaryCtrl = TextEditingController();
    _tdsOnOtherCtrl = TextEditingController();
    _advQ1Ctrl = TextEditingController();
    _advQ2Ctrl = TextEditingController();
    _advQ3Ctrl = TextEditingController();
    _advQ4Ctrl = TextEditingController();
    _selfAssessmentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tdsOnSalaryCtrl.dispose();
    _tdsOnOtherCtrl.dispose();
    _advQ1Ctrl.dispose();
    _advQ2Ctrl.dispose();
    _advQ3Ctrl.dispose();
    _advQ4Ctrl.dispose();
    _selfAssessmentCtrl.dispose();
    super.dispose();
  }

  void _loadFromProvider(TdsPaymentSummary tds) {
    if (_initialized) return;
    _initialized = true;
    _tdsOnSalaryCtrl.text = _fmt(tds.tdsOnSalary);
    _tdsOnOtherCtrl.text = _fmt(tds.tdsOnOtherIncome);
    _advQ1Ctrl.text = _fmt(tds.advanceTaxQ1);
    _advQ2Ctrl.text = _fmt(tds.advanceTaxQ2);
    _advQ3Ctrl.text = _fmt(tds.advanceTaxQ3);
    _advQ4Ctrl.text = _fmt(tds.advanceTaxQ4);
    _selfAssessmentCtrl.text = _fmt(tds.selfAssessmentTax);
  }

  String _fmt(double v) => v == 0 ? '' : v.toStringAsFixed(0);
  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _persistToProvider() {
    final tds = TdsPaymentSummary(
      tdsOnSalary: _parse(_tdsOnSalaryCtrl),
      tdsOnOtherIncome: _parse(_tdsOnOtherCtrl),
      advanceTaxQ1: _parse(_advQ1Ctrl),
      advanceTaxQ2: _parse(_advQ2Ctrl),
      advanceTaxQ3: _parse(_advQ3Ctrl),
      advanceTaxQ4: _parse(_advQ4Ctrl),
      selfAssessmentTax: _parse(_selfAssessmentCtrl),
    );
    ref.read(itr1FormDataProvider.notifier).updateTdsPaymentSummary(tds);
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(itr1FormDataProvider);
    final taxResult = ref.watch(liveTaxComputationProvider);
    _loadFromProvider(formData.tdsPaymentSummary);

    final selectedTax = formData.selectedRegime == TaxRegime.newRegime
        ? taxResult.newRegimeTax
        : taxResult.oldRegimeTax;

    final tds = formData.tdsPaymentSummary;
    final balancePayable = selectedTax - tds.totalTaxesPaid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TDS Section ---
          _sectionHeader('TDS Deducted at Source'),
          const SizedBox(height: 8),
          _buildField(
            'TDS on Salary (Form 16)',
            _tdsOnSalaryCtrl,
            Icons.work_outline,
          ),
          _buildField(
            'TDS on Other Income (26AS)',
            _tdsOnOtherCtrl,
            Icons.receipt_long_outlined,
          ),

          const SizedBox(height: 20),

          // --- Advance Tax Section ---
          _sectionHeader('Advance Tax Paid'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildField('Q1 (15 Jun)', _advQ1Ctrl, null)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('Q2 (15 Sep)', _advQ2Ctrl, null)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildField('Q3 (15 Dec)', _advQ3Ctrl, null)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('Q4 (15 Mar)', _advQ4Ctrl, null)),
            ],
          ),

          const SizedBox(height: 20),

          // --- Self-Assessment Tax ---
          _sectionHeader('Self-Assessment Tax'),
          const SizedBox(height: 8),
          _buildField(
            'Challan 280 Amount',
            _selfAssessmentCtrl,
            Icons.account_balance_outlined,
          ),

          const SizedBox(height: 24),

          // --- Summary Card ---
          _SummaryCard(
            totalTax: selectedTax,
            totalTds: tds.totalTds,
            totalAdvanceTax: tds.totalAdvanceTax,
            selfAssessmentTax: tds.selfAssessmentTax,
            totalTaxesPaid: tds.totalTaxesPaid,
            balancePayable: balancePayable,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData? icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        onChanged: (_) => _persistToProvider(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
          prefixText: '₹ ',
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card showing balance tax / refund
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalTax,
    required this.totalTds,
    required this.totalAdvanceTax,
    required this.selfAssessmentTax,
    required this.totalTaxesPaid,
    required this.balancePayable,
  });

  final double totalTax;
  final double totalTds;
  final double totalAdvanceTax;
  final double selfAssessmentTax;
  final double totalTaxesPaid;
  final double balancePayable;

  @override
  Widget build(BuildContext context) {
    final isRefund = balancePayable < 0;
    final balanceColor = isRefund ? AppColors.success : AppColors.error;
    final balanceLabel = isRefund ? 'Refund Due' : 'Balance Tax Payable';
    final balanceAmount = balancePayable.abs();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.summarize_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Tax Payment Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _row('Total Tax Liability', CurrencyUtils.formatINR(totalTax)),
            _row('TDS Deducted', '− ${CurrencyUtils.formatINR(totalTds)}'),
            _row(
              'Advance Tax Paid',
              '− ${CurrencyUtils.formatINR(totalAdvanceTax)}',
            ),
            _row(
              'Self-Assessment Tax',
              '− ${CurrencyUtils.formatINR(selfAssessmentTax)}',
            ),
            const Divider(height: 16),
            _row(
              'Total Taxes Paid',
              CurrencyUtils.formatINR(totalTaxesPaid),
              bold: true,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: balanceColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: balanceColor.withAlpha(77)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    balanceLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: balanceColor,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(balanceAmount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: balanceColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
