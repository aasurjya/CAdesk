import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr2/foreign_asset_schedule.dart';

/// Schedule FA step — foreign assets held outside India.
///
/// Shows a list of foreign assets with add/remove. Each asset captures:
/// country, nature (bank, equity, property, etc.), description,
/// value in foreign currency, exchange rate, income derived, income offered.
class ForeignAssetsStep extends ConsumerStatefulWidget {
  const ForeignAssetsStep({super.key});

  @override
  ConsumerState<ForeignAssetsStep> createState() => _ForeignAssetsStepState();
}

class _ForeignAssetsStepState extends ConsumerState<ForeignAssetsStep> {
  void _addAsset() {
    final fa = ref.read(itr2FormDataProvider).foreignAssetSchedule;
    final updated = fa.copyWith(
      assets: [
        ...fa.assets,
        const ForeignAsset(
          countryCode: '',
          countryName: '',
          assetType: ForeignAssetType.bankAccount,
          description: '',
          valueInForeignCurrency: 0,
          exchangeRate: 0,
          acquisitionDate: '',
          incomeDerived: 0,
          incomeOffered: 0,
        ),
      ],
    );
    ref.read(itr2FormDataProvider.notifier).updateForeignAssets(updated);
  }

  void _removeAsset(int index) {
    final fa = ref.read(itr2FormDataProvider).foreignAssetSchedule;
    final list = [...fa.assets]..removeAt(index);
    ref
        .read(itr2FormDataProvider.notifier)
        .updateForeignAssets(fa.copyWith(assets: list));
  }

  void _updateAsset(int index, ForeignAsset asset) {
    final fa = ref.read(itr2FormDataProvider).foreignAssetSchedule;
    final list = [...fa.assets]..[index] = asset;
    ref
        .read(itr2FormDataProvider.notifier)
        .updateForeignAssets(fa.copyWith(assets: list));
  }

  @override
  Widget build(BuildContext context) {
    final fa = ref.watch(itr2FormDataProvider).foreignAssetSchedule;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.neutral600),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Schedule FA is mandatory for residents who hold any '
                    'asset outside India or have signing authority in any '
                    'foreign account.',
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < fa.assets.length; i++)
            _ForeignAssetCard(
              index: i,
              asset: fa.assets[i],
              onUpdate: (a) => _updateAsset(i, a),
              onRemove: () => _removeAsset(i),
            ),
          OutlinedButton.icon(
            onPressed: _addAsset,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Foreign Asset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule FA Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(height: 12),
                  _summaryRow(
                    'Total Foreign Asset Value (INR)',
                    fa.totalValueInINR,
                  ),
                  _summaryRow('Total Income Derived', fa.totalIncomeDerived),
                  _summaryRow(
                    'Total Income Offered to Tax',
                    fa.totalIncomeOffered,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: bold ? AppColors.primary : AppColors.neutral600,
              ),
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
}

// ---------------------------------------------------------------------------
// Foreign asset entry card
// ---------------------------------------------------------------------------

class _ForeignAssetCard extends StatefulWidget {
  const _ForeignAssetCard({
    required this.index,
    required this.asset,
    required this.onUpdate,
    required this.onRemove,
  });

  final int index;
  final ForeignAsset asset;
  final ValueChanged<ForeignAsset> onUpdate;
  final VoidCallback onRemove;

  @override
  State<_ForeignAssetCard> createState() => _ForeignAssetCardState();
}

class _ForeignAssetCardState extends State<_ForeignAssetCard> {
  late final TextEditingController _countryCodeCtrl;
  late final TextEditingController _countryNameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _foreignValueCtrl;
  late final TextEditingController _exchangeRateCtrl;
  late final TextEditingController _acquisitionDateCtrl;
  late final TextEditingController _incomeDerivedCtrl;
  late final TextEditingController _incomeOfferedCtrl;

  late ForeignAssetType _selectedType;

  @override
  void initState() {
    super.initState();
    _countryCodeCtrl = TextEditingController(text: widget.asset.countryCode);
    _countryNameCtrl = TextEditingController(text: widget.asset.countryName);
    _descCtrl = TextEditingController(text: widget.asset.description);
    _foreignValueCtrl = _numCtrl(widget.asset.valueInForeignCurrency);
    _exchangeRateCtrl = _numCtrl(widget.asset.exchangeRate);
    _acquisitionDateCtrl = TextEditingController(
      text: widget.asset.acquisitionDate,
    );
    _incomeDerivedCtrl = _numCtrl(widget.asset.incomeDerived);
    _incomeOfferedCtrl = _numCtrl(widget.asset.incomeOffered);
    _selectedType = widget.asset.assetType;
  }

  TextEditingController _numCtrl(double v) =>
      TextEditingController(text: v > 0 ? v.toStringAsFixed(2) : '');

  @override
  void dispose() {
    _countryCodeCtrl.dispose();
    _countryNameCtrl.dispose();
    _descCtrl.dispose();
    _foreignValueCtrl.dispose();
    _exchangeRateCtrl.dispose();
    _acquisitionDateCtrl.dispose();
    _incomeDerivedCtrl.dispose();
    _incomeOfferedCtrl.dispose();
    super.dispose();
  }

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _persist() {
    widget.onUpdate(
      ForeignAsset(
        countryCode: _countryCodeCtrl.text.trim().toUpperCase(),
        countryName: _countryNameCtrl.text.trim(),
        assetType: _selectedType,
        description: _descCtrl.text.trim(),
        valueInForeignCurrency: _p(_foreignValueCtrl),
        exchangeRate: _p(_exchangeRateCtrl),
        acquisitionDate: _acquisitionDateCtrl.text.trim(),
        incomeDerived: _p(_incomeDerivedCtrl),
        incomeOffered: _p(_incomeOfferedCtrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Foreign Asset #${widget.index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: _textField('Code', _countryCodeCtrl, hint: 'US'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _textField(
                    'Country Name',
                    _countryNameCtrl,
                    hint: 'United States',
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DropdownButtonFormField<ForeignAssetType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Asset Type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: ForeignAssetType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedType = val);
                    _persist();
                  }
                },
              ),
            ),
            _textField('Description', _descCtrl, hint: 'Account or address'),
            _textField(
              'Acquisition Date',
              _acquisitionDateCtrl,
              hint: '2020-06-01',
            ),
            _amountField(
              'Value (Foreign Currency)',
              _foreignValueCtrl,
              prefix: '',
            ),
            _amountField(
              'Exchange Rate (to INR)',
              _exchangeRateCtrl,
              prefix: '',
            ),
            _amountField('Income Derived (INR)', _incomeDerivedCtrl),
            _amountField('Income Offered to Tax (INR)', _incomeOfferedCtrl),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _persist(),
      ),
    );
  }

  Widget _amountField(
    String label,
    TextEditingController ctrl, {
    String prefix = '\u20b9 ',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix.isNotEmpty ? prefix : null,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _persist(),
      ),
    );
  }
}
