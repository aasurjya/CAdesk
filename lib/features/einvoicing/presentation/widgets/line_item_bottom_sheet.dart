import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/einvoice_form_providers.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _units = ['NOS', 'KGS', 'MTR', 'LTR', 'PCS', 'SET', 'BOX'];

// ---------------------------------------------------------------------------
// Line item bottom sheet
// ---------------------------------------------------------------------------

/// Bottom sheet for adding or editing a single e-invoice line item.
///
/// Computes CGST/SGST (intra-state) or IGST (inter-state) automatically
/// based on the toggle switch.
class LineItemBottomSheet extends StatefulWidget {
  const LineItemBottomSheet({super.key, this.existing, required this.onSave});

  /// When non-null, the sheet is in edit mode for this item.
  final EinvoiceLineItem? existing;

  /// Callback invoked with the new/updated line item.
  final void Function(EinvoiceLineItem) onSave;

  @override
  State<LineItemBottomSheet> createState() => _LineItemBottomSheetState();
}

class _LineItemBottomSheetState extends State<LineItemBottomSheet> {
  late final TextEditingController _hsnController;
  late final TextEditingController _descController;
  late final TextEditingController _qtyController;
  late final TextEditingController _rateController;
  late final TextEditingController _discountController;
  String _unit = 'NOS';
  bool _isInterState = false;
  double _gstRate = 18;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _hsnController = TextEditingController(text: e?.hsnCode ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _qtyController = TextEditingController(
      text: e != null ? '${e.quantity}' : '1',
    );
    _rateController = TextEditingController(text: e != null ? '${e.rate}' : '');
    _discountController = TextEditingController(
      text: e != null && e.discount > 0 ? '${e.discount}' : '',
    );
    if (e != null) {
      _unit = e.unit;
      _isInterState = e.igstAmount > 0;
      _gstRate = e.igstAmount > 0 ? e.igstRate : (e.cgstRate + e.sgstRate);
    }
  }

  @override
  void dispose() {
    _hsnController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _save() {
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final taxableValue = (qty * rate) - discount;
    final halfRate = _gstRate / 2;

    final item = EinvoiceLineItem(
      id: widget.existing?.id ?? 'li-${DateTime.now().millisecondsSinceEpoch}',
      hsnCode: _hsnController.text,
      description: _descController.text,
      quantity: qty,
      unit: _unit,
      rate: rate,
      discount: discount,
      taxableValue: taxableValue,
      cgstRate: _isInterState ? 0 : halfRate,
      sgstRate: _isInterState ? 0 : halfRate,
      igstRate: _isInterState ? _gstRate : 0,
      cgstAmount: _isInterState ? 0 : taxableValue * halfRate / 100,
      sgstAmount: _isInterState ? 0 : taxableValue * halfRate / 100,
      igstAmount: _isInterState ? taxableValue * _gstRate / 100 : 0,
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing != null ? 'Edit Line Item' : 'Add Line Item',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hsnController,
              decoration: const InputDecoration(
                labelText: 'HSN/SAC Code',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _unit = v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    decoration: const InputDecoration(labelText: 'Rate'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _discountController,
              decoration: const InputDecoration(
                labelText: 'Discount (optional)',
                prefixIcon: Icon(Icons.discount_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Inter-state (IGST)'),
              subtitle: Text(
                _isInterState
                    ? 'IGST will be applied'
                    : 'CGST + SGST will be applied',
                style: const TextStyle(fontSize: 12),
              ),
              value: _isInterState,
              onChanged: (v) => setState(() => _isInterState = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(widget.existing != null ? 'Update Item' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
