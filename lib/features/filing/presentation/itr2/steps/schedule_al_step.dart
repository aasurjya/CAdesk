import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_al.dart';

/// Income threshold above which Schedule AL is mandatory (50 lakhs).
const double _kScheduleAlThreshold = 5000000.0;

/// Schedule AL step — Assets and Liabilities.
///
/// Mandatory when total income exceeds 50 lakhs. Captures:
/// - Immovable property value
/// - Movable property value (vehicles, jewellery, art)
/// - Financial asset value (shares, MF, deposits)
/// - Total liabilities (loans taken)
/// - Net worth computation
class ScheduleAlStep extends ConsumerStatefulWidget {
  const ScheduleAlStep({super.key});

  @override
  ConsumerState<ScheduleAlStep> createState() => _ScheduleAlStepState();
}

class _ScheduleAlStepState extends ConsumerState<ScheduleAlStep> {
  late final TextEditingController _immovableCtrl;
  late final TextEditingController _movableCtrl;
  late final TextEditingController _financialCtrl;
  late final TextEditingController _liabilitiesCtrl;

  @override
  void initState() {
    super.initState();
    final al = ref.read(itr2FormDataProvider).scheduleAl ?? ScheduleAl.empty();
    _immovableCtrl = _init(al.immovablePropertyValue);
    _movableCtrl = _init(al.movablePropertyValue);
    _financialCtrl = _init(al.financialAssetValue);
    _liabilitiesCtrl = _init(al.totalLiabilities);
  }

  TextEditingController _init(double val) =>
      TextEditingController(text: val > 0 ? val.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _immovableCtrl.dispose();
    _movableCtrl.dispose();
    _financialCtrl.dispose();
    _liabilitiesCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim()) ?? 0;

  void _persist() {
    final al = ScheduleAl(
      immovablePropertyValue: _parse(_immovableCtrl),
      movablePropertyValue: _parse(_movableCtrl),
      financialAssetValue: _parse(_financialCtrl),
      totalLiabilities: _parse(_liabilitiesCtrl),
    );
    ref.read(itr2FormDataProvider.notifier).updateScheduleAl(al);
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
          helperText: helper,
          prefixText: '\u20b9 ',
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

  Widget _computedRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? AppColors.primary : AppColors.neutral600,
            ),
          ),
          Text(
            CurrencyUtils.formatINR(value),
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

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(itr2FormDataProvider);
    final isRequired = formData.grossTotalIncome > _kScheduleAlThreshold;
    final al = formData.scheduleAl ?? ScheduleAl.empty();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eligibility banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRequired
                  ? AppColors.warning.withAlpha(25)
                  : AppColors.success.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isRequired ? AppColors.warning : AppColors.success,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isRequired
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  size: 16,
                  color: isRequired ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isRequired
                        ? 'Schedule AL is MANDATORY — your total income '
                              '(${CurrencyUtils.formatINRCompact(formData.grossTotalIncome)}) '
                              'exceeds \u20b950 lakhs.'
                        : 'Schedule AL is not required — total income is '
                              'below \u20b950 lakhs. You may still fill it '
                              'optionally.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRequired ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Assets section
          _sectionHeader('Assets (as on 31 March)'),
          _numField(
            'Immovable Property',
            _immovableCtrl,
            helper: 'Land, buildings, flats — cost or stamp duty value',
          ),
          _numField(
            'Movable Property',
            _movableCtrl,
            helper: 'Vehicles, jewellery, art, other high-value items',
          ),
          _numField(
            'Financial Assets',
            _financialCtrl,
            helper: 'Shares, MF units, FDs, bonds, bank balances',
          ),

          // Liabilities section
          _sectionHeader('Liabilities'),
          _numField(
            'Total Liabilities',
            _liabilitiesCtrl,
            helper: 'Housing loans, vehicle loans, personal loans',
          ),

          const SizedBox(height: 8),

          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule AL Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(height: 12),
                  _computedRow('Immovable Property', al.immovablePropertyValue),
                  _computedRow('Movable Property', al.movablePropertyValue),
                  _computedRow('Financial Assets', al.financialAssetValue),
                  _computedRow('Total Assets', al.totalAssets, bold: true),
                  const Divider(height: 10),
                  _computedRow('Total Liabilities', al.totalLiabilities),
                  const Divider(height: 10),
                  _computedRow('Net Worth', al.netWorth, bold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
