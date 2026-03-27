import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/advance_tax_providers.dart';
import 'widgets/advance_tax_form_widgets.dart';
import 'widgets/installment_card.dart';
import 'widgets/interest_calculation_card.dart';

/// Interactive advance tax calculator with income estimation,
/// installment tracking, and interest computation.
class AdvanceTaxCalculatorScreen extends ConsumerStatefulWidget {
  const AdvanceTaxCalculatorScreen({super.key});

  @override
  ConsumerState<AdvanceTaxCalculatorScreen> createState() =>
      _AdvanceTaxCalculatorScreenState();
}

class _AdvanceTaxCalculatorScreenState
    extends ConsumerState<AdvanceTaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showEstimationForm = true;

  late final TextEditingController _salaryCtrl;
  late final TextEditingController _businessCtrl;
  late final TextEditingController _capitalGainsCtrl;
  late final TextEditingController _otherSourcesCtrl;
  late final TextEditingController _tdsCtrl;

  @override
  void initState() {
    super.initState();
    final estimate = ref.read(advanceTaxIncomeEstimateProvider);
    _salaryCtrl = TextEditingController(
      text: estimate.salary > 0 ? estimate.salary.toStringAsFixed(0) : '',
    );
    _businessCtrl = TextEditingController(
      text: estimate.businessIncome > 0
          ? estimate.businessIncome.toStringAsFixed(0)
          : '',
    );
    _capitalGainsCtrl = TextEditingController(
      text: estimate.capitalGains > 0
          ? estimate.capitalGains.toStringAsFixed(0)
          : '',
    );
    _otherSourcesCtrl = TextEditingController(
      text: estimate.otherSources > 0
          ? estimate.otherSources.toStringAsFixed(0)
          : '',
    );
    _tdsCtrl = TextEditingController(
      text: estimate.tdsAlreadyDeducted > 0
          ? estimate.tdsAlreadyDeducted.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _salaryCtrl.dispose();
    _businessCtrl.dispose();
    _capitalGainsCtrl.dispose();
    _otherSourcesCtrl.dispose();
    _tdsCtrl.dispose();
    super.dispose();
  }

  void _computeTax() {
    if (!_formKey.currentState!.validate()) return;

    final estimate = IncomeEstimate(
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
      businessIncome: double.tryParse(_businessCtrl.text) ?? 0,
      capitalGains: double.tryParse(_capitalGainsCtrl.text) ?? 0,
      otherSources: double.tryParse(_otherSourcesCtrl.text) ?? 0,
      tdsAlreadyDeducted: double.tryParse(_tdsCtrl.text) ?? 0,
    );

    ref.read(advanceTaxIncomeEstimateProvider.notifier).update(estimate);
    setState(() => _showEstimationForm = false);
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(advanceTaxScheduleProvider);
    final payments = ref.watch(advanceTaxPaymentsProvider);
    final interest = ref.watch(advanceTaxInterestProvider);
    final summary = ref.watch(advanceTaxSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Advance Tax Calculator',
          style: TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, size: 20),
            onPressed: _saveDraft,
            tooltip: 'Save Draft',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdvanceTaxSummaryCard(summary: summary),
            const SizedBox(height: 16),

            AdvanceTaxSectionHeader(
              title: 'Income Estimation',
              icon: Icons.calculate_rounded,
              trailing: TextButton.icon(
                onPressed: () {
                  setState(() => _showEstimationForm = !_showEstimationForm);
                },
                icon: Icon(
                  _showEstimationForm ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                ),
                label: Text(_showEstimationForm ? 'Collapse' : 'Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontSize: 11),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),

            if (_showEstimationForm) ...[
              const SizedBox(height: 8),
              IncomeEstimationForm(
                formKey: _formKey,
                salaryCtrl: _salaryCtrl,
                businessCtrl: _businessCtrl,
                capitalGainsCtrl: _capitalGainsCtrl,
                otherSourcesCtrl: _otherSourcesCtrl,
                tdsCtrl: _tdsCtrl,
                onCompute: _computeTax,
              ),
            ],

            const SizedBox(height: 20),

            const AdvanceTaxSectionHeader(
              title: 'FY 2025-26 Installments',
              icon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 8),

            for (int i = 0; i < schedule.installments.length; i++)
              InstallmentCard(
                installment: schedule.installments[i],
                quarterIndex: i,
                paidAmount: payments[i].paid,
                challanNumber: payments[i].challan,
                interestAmount: interest.quarterlyDetails[i],
                onPaidChanged: (amount) {
                  ref
                      .read(advanceTaxPaymentsProvider.notifier)
                      .updatePayment(i, paid: amount);
                },
                onChallanChanged: (challan) {
                  ref
                      .read(advanceTaxPaymentsProvider.notifier)
                      .updatePayment(i, challan: challan);
                },
                onGenerateChallan: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generating challan for Q${i + 1}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

            const AdvanceTaxSectionHeader(
              title: 'Interest Computation',
              icon: Icons.percent_rounded,
            ),
            const SizedBox(height: 8),

            InterestCalculationCard(
              interest: interest,
              totalLiability: summary.totalLiability,
              totalPaid: summary.totalPaid,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'advance_tax_save',
        onPressed: _saveDraft,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save_rounded),
        label: const Text('Save Draft'),
      ),
    );
  }
}
