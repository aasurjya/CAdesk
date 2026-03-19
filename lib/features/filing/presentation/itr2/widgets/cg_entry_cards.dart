import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';

// ---------------------------------------------------------------------------
// Add asset button
// ---------------------------------------------------------------------------

class CgAddAssetButton extends StatelessWidget {
  const CgAddAssetButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gain / Loss chip
// ---------------------------------------------------------------------------

class CgGainChip extends StatelessWidget {
  const CgGainChip({required this.gain, super.key});

  final double gain;

  @override
  Widget build(BuildContext context) {
    if (gain == 0) return const SizedBox.shrink();
    final isGain = gain > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isGain ? AppColors.success : AppColors.error).withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${isGain ? "Gain" : "Loss"}: ${CurrencyUtils.formatINR(gain.abs())}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isGain ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Equity STCG card (Section 111A)
// ---------------------------------------------------------------------------

class EquityStcgCard extends StatefulWidget {
  const EquityStcgCard({
    required this.index,
    required this.entry,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final int index;
  final EquityStcgEntry entry;
  final ValueChanged<EquityStcgEntry> onUpdate;
  final VoidCallback onRemove;

  @override
  State<EquityStcgCard> createState() => _EquityStcgCardState();
}

class _EquityStcgCardState extends State<EquityStcgCard> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _saleCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _expCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.entry.description);
    _saleCtrl = _numCtrl(widget.entry.salePrice);
    _costCtrl = _numCtrl(widget.entry.costOfAcquisition);
    _expCtrl = _numCtrl(widget.entry.transferExpenses);
  }

  TextEditingController _numCtrl(double v) =>
      TextEditingController(text: v > 0 ? v.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _descCtrl.dispose();
    _saleCtrl.dispose();
    _costCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _persist() {
    widget.onUpdate(
      EquityStcgEntry(
        description: _descCtrl.text.trim(),
        salePrice: _p(_saleCtrl),
        costOfAcquisition: _p(_costCtrl),
        transferExpenses: _p(_expCtrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CgAssetCardShell(
      label: 'Asset #${widget.index + 1}',
      onRemove: widget.onRemove,
      gain: widget.entry.gain,
      children: [
        _CgTextField(
          label: 'Description',
          ctrl: _descCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Sale Consideration',
          ctrl: _saleCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Cost of Acquisition',
          ctrl: _costCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Transfer Expenses',
          ctrl: _expCtrl,
          onChanged: _persist,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Equity LTCG card (Section 112A)
// ---------------------------------------------------------------------------

class EquityLtcgCard extends StatefulWidget {
  const EquityLtcgCard({
    required this.index,
    required this.entry,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final int index;
  final EquityLtcgEntry entry;
  final ValueChanged<EquityLtcgEntry> onUpdate;
  final VoidCallback onRemove;

  @override
  State<EquityLtcgCard> createState() => _EquityLtcgCardState();
}

class _EquityLtcgCardState extends State<EquityLtcgCard> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _saleCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _fmvCtrl;
  late final TextEditingController _expCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.entry.description);
    _saleCtrl = _numCtrl(widget.entry.salePrice);
    _costCtrl = _numCtrl(widget.entry.costOfAcquisition);
    _fmvCtrl = _numCtrl(widget.entry.fmvOn31Jan2018);
    _expCtrl = _numCtrl(widget.entry.transferExpenses);
  }

  TextEditingController _numCtrl(double v) =>
      TextEditingController(text: v > 0 ? v.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _descCtrl.dispose();
    _saleCtrl.dispose();
    _costCtrl.dispose();
    _fmvCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _persist() {
    widget.onUpdate(
      EquityLtcgEntry(
        description: _descCtrl.text.trim(),
        salePrice: _p(_saleCtrl),
        costOfAcquisition: _p(_costCtrl),
        fmvOn31Jan2018: _p(_fmvCtrl),
        transferExpenses: _p(_expCtrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CgAssetCardShell(
      label: 'Asset #${widget.index + 1}',
      onRemove: widget.onRemove,
      gain: widget.entry.gain,
      children: [
        _CgTextField(
          label: 'Description',
          ctrl: _descCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Sale Consideration',
          ctrl: _saleCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Cost of Acquisition',
          ctrl: _costCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'FMV on 31-Jan-2018',
          ctrl: _fmvCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Transfer Expenses',
          ctrl: _expCtrl,
          onChanged: _persist,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Other STCG card (slab rate)
// ---------------------------------------------------------------------------

class OtherStcgCard extends StatefulWidget {
  const OtherStcgCard({
    required this.index,
    required this.entry,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final int index;
  final OtherStcgEntry entry;
  final ValueChanged<OtherStcgEntry> onUpdate;
  final VoidCallback onRemove;

  @override
  State<OtherStcgCard> createState() => _OtherStcgCardState();
}

class _OtherStcgCardState extends State<OtherStcgCard> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _saleCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _expCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.entry.description);
    _saleCtrl = _numCtrl(widget.entry.salePrice);
    _costCtrl = _numCtrl(widget.entry.costOfAcquisition);
    _expCtrl = _numCtrl(widget.entry.transferExpenses);
  }

  TextEditingController _numCtrl(double v) =>
      TextEditingController(text: v > 0 ? v.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _descCtrl.dispose();
    _saleCtrl.dispose();
    _costCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _persist() {
    widget.onUpdate(
      OtherStcgEntry(
        description: _descCtrl.text.trim(),
        salePrice: _p(_saleCtrl),
        costOfAcquisition: _p(_costCtrl),
        transferExpenses: _p(_expCtrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CgAssetCardShell(
      label: 'Asset #${widget.index + 1}',
      onRemove: widget.onRemove,
      gain: widget.entry.gain,
      children: [
        _CgTextField(
          label: 'Description',
          ctrl: _descCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Sale Consideration',
          ctrl: _saleCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Cost of Acquisition',
          ctrl: _costCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Transfer Expenses',
          ctrl: _expCtrl,
          onChanged: _persist,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Property LTCG card (Section 112)
// ---------------------------------------------------------------------------

class PropertyLtcgCard extends StatefulWidget {
  const PropertyLtcgCard({
    required this.index,
    required this.entry,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final int index;
  final PropertyLtcgEntry entry;
  final ValueChanged<PropertyLtcgEntry> onUpdate;
  final VoidCallback onRemove;

  @override
  State<PropertyLtcgCard> createState() => _PropertyLtcgCardState();
}

class _PropertyLtcgCardState extends State<PropertyLtcgCard> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _saleCtrl;
  late final TextEditingController _indexedCostCtrl;
  late final TextEditingController _improvementCtrl;
  late final TextEditingController _expCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.entry.description);
    _saleCtrl = _numCtrl(widget.entry.salePrice);
    _indexedCostCtrl = _numCtrl(widget.entry.indexedCostOfAcquisition);
    _improvementCtrl = _numCtrl(widget.entry.improvementCost);
    _expCtrl = _numCtrl(widget.entry.transferExpenses);
  }

  TextEditingController _numCtrl(double v) =>
      TextEditingController(text: v > 0 ? v.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _descCtrl.dispose();
    _saleCtrl.dispose();
    _indexedCostCtrl.dispose();
    _improvementCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _persist() {
    widget.onUpdate(
      PropertyLtcgEntry(
        description: _descCtrl.text.trim(),
        salePrice: _p(_saleCtrl),
        indexedCostOfAcquisition: _p(_indexedCostCtrl),
        improvementCost: _p(_improvementCtrl),
        transferExpenses: _p(_expCtrl),
        acquisitionDate: widget.entry.acquisitionDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CgAssetCardShell(
      label: 'Property #${widget.index + 1}',
      onRemove: widget.onRemove,
      gain: widget.entry.gain,
      children: [
        _CgTextField(
          label: 'Description (e.g., Flat in Mumbai)',
          ctrl: _descCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Sale Consideration',
          ctrl: _saleCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Indexed Cost of Acquisition',
          ctrl: _indexedCostCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Improvement Cost',
          ctrl: _improvementCtrl,
          onChanged: _persist,
        ),
        _CgAmountField(
          label: 'Transfer Expenses',
          ctrl: _expCtrl,
          onChanged: _persist,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card shell
// ---------------------------------------------------------------------------

class _CgAssetCardShell extends StatelessWidget {
  const _CgAssetCardShell({
    required this.label,
    required this.onRemove,
    required this.gain,
    required this.children,
  });

  final String label;
  final VoidCallback onRemove;
  final double gain;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
            CgGainChip(gain: gain),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared text field
// ---------------------------------------------------------------------------

class _CgTextField extends StatelessWidget {
  const _CgTextField({
    required this.label,
    required this.ctrl,
    required this.onChanged,
  });

  final String label;
  final TextEditingController ctrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared amount field
// ---------------------------------------------------------------------------

class _CgAmountField extends StatelessWidget {
  const _CgAmountField({
    required this.label,
    required this.ctrl,
    required this.onChanged,
  });

  final String label;
  final TextEditingController ctrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(
          labelText: label,
          prefixText: '\u20b9 ',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}
