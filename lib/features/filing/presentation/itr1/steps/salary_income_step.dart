import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/data/providers/form16_prefill_provider.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/presentation/itr1/widgets/form16_picker_sheet.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_extracted_data.dart';
import 'package:ca_app/features/ocr/data/providers/ocr_providers.dart';

class SalaryIncomeStep extends ConsumerStatefulWidget {
  const SalaryIncomeStep({super.key});

  @override
  ConsumerState<SalaryIncomeStep> createState() => _SalaryIncomeStepState();
}

class _SalaryIncomeStepState extends ConsumerState<SalaryIncomeStep> {
  late final TextEditingController _grossCtrl;
  late final TextEditingController _exemptCtrl;
  late final TextEditingController _perqCtrl;
  late final TextEditingController _profitCtrl;

  bool _isPrefilled = false;
  String _prefillSource = '';

  @override
  void initState() {
    super.initState();
    final s = ref.read(itr1FormDataProvider).salaryIncome;
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
    final regime = ref.read(itr1FormDataProvider).selectedRegime;
    final stdDed = regime == TaxRegime.newRegime ? 75000.0 : 50000.0;
    final income = SalaryIncome(
      grossSalary: _parse(_grossCtrl),
      allowancesExemptUnderSection10: _parse(_exemptCtrl),
      valueOfPerquisites: _parse(_perqCtrl),
      profitsInLieuOfSalary: _parse(_profitCtrl),
      standardDeduction: stdDed,
    );
    ref.read(itr1FormDataProvider.notifier).updateSalaryIncome(income);
  }

  // -----------------------------------------------------------------------
  // Prefill application
  // -----------------------------------------------------------------------

  void _applyPrefill(Form16PrefillResult result) {
    final sal = result.salaryIncome;
    _grossCtrl.text = sal.grossSalary > 0
        ? sal.grossSalary.toStringAsFixed(0)
        : '';
    _exemptCtrl.text = sal.allowancesExemptUnderSection10 > 0
        ? sal.allowancesExemptUnderSection10.toStringAsFixed(0)
        : '';
    _perqCtrl.text = sal.valueOfPerquisites > 0
        ? sal.valueOfPerquisites.toStringAsFixed(0)
        : '';
    _profitCtrl.text = sal.profitsInLieuOfSalary > 0
        ? sal.profitsInLieuOfSalary.toStringAsFixed(0)
        : '';

    setState(() {
      _isPrefilled = true;
      _prefillSource = result.source;
    });

    _persist();
  }

  // -----------------------------------------------------------------------
  // OCR import flow
  // -----------------------------------------------------------------------

  Future<void> _importFromOcr() async {
    // Navigate to OCR upload screen. The OCR screen is expected to push its
    // result back via Navigator.pop. If the route is not yet wired, fall
    // back to picking the most recent completed Form 16 OCR job.
    final jobs = ref.read(ocrJobListProvider);
    final form16Jobs = jobs.where((j) {
      if (j.status != OcrJobStatus.completed || j.result == null) return false;
      return j.result!.extractedData is Form16ExtractedData;
    }).toList();

    if (form16Jobs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No scanned Form 16 found. '
            'Upload a Form 16 via the OCR module first.',
          ),
        ),
      );
      return;
    }

    // Use the most recent completed Form 16 OCR job.
    final latestJob = form16Jobs.first;
    final extractedData =
        latestJob.result!.extractedData as Form16ExtractedData;
    final result = prefillFromOcr(extractedData.data);
    _applyPrefill(result);
  }

  // -----------------------------------------------------------------------
  // Existing Form 16 import flow
  // -----------------------------------------------------------------------

  Future<void> _importFromExistingForm16() async {
    final selected = await Form16PickerSheet.show(context);
    if (selected == null || !mounted) return;

    final result = prefillFromForm16Data(selected);
    _applyPrefill(result);
  }

  // -----------------------------------------------------------------------
  // Shared field builder
  // -----------------------------------------------------------------------

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

  // -----------------------------------------------------------------------
  // Prefill source card
  // -----------------------------------------------------------------------

  Widget _buildPrefillSourceCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import from Form 16',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _importFromOcr,
                    icon: const Icon(Icons.document_scanner, size: 18),
                    label: const Text('Scan (OCR)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _importFromExistingForm16,
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Existing'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefillChip() {
    if (!_isPrefilled) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Chip(
        avatar: Icon(
          Icons.check_circle,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text('Prefilled from $_prefillSource'),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () => setState(() {
          _isPrefilled = false;
          _prefillSource = '';
        }),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final salary = ref.watch(itr1FormDataProvider).salaryIncome;
    final regime = ref.watch(itr1FormDataProvider).selectedRegime;
    final stdDedAmt = regime == TaxRegime.newRegime ? 75000.0 : 50000.0;
    final netSalary = salary.netSalary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrefillSourceCard(),
          _buildPrefillChip(),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
