import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr1_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_at.dart';

/// Step 5: Advance Tax (Table 11) -- Advance payments received.
class Gstr1AdvanceStep extends ConsumerWidget {
  const Gstr1AdvanceStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advances = ref.watch(gstr1FormDataProvider).advanceTax;

    return Stack(
      children: [
        if (advances.isEmpty)
          _EmptyState()
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: advances.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final at = advances[index];
              return _AdvanceTile(
                advance: at,
                onDelete: () => ref
                    .read(gstr1FormDataProvider.notifier)
                    .removeAdvanceTax(index),
              );
            },
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'gstr1_at_fab',
            onPressed: () => _showAddSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Advance'),
          ),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AdvanceForm(),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_rounded, size: 48, color: AppColors.neutral200),
          const SizedBox(height: 12),
          Text(
            'No advance payments recorded',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Skip if no advances received this period',
            style: TextStyle(color: AppColors.neutral300, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Advance tile
// ---------------------------------------------------------------------------

class _AdvanceTile extends StatelessWidget {
  const _AdvanceTile({required this.advance, required this.onDelete});

  final Gstr1At advance;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(advance.receiptDate);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advance.receiptVoucherNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr  •  POS: ${advance.placeOfSupply}  •  ${advance.gstRate}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Advance: ${CurrencyUtils.formatINR(advance.advanceAmount)}  •  Tax: ${CurrencyUtils.formatINR(advance.totalTax)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add advance form
// ---------------------------------------------------------------------------

class _AdvanceForm extends ConsumerStatefulWidget {
  const _AdvanceForm();

  @override
  ConsumerState<_AdvanceForm> createState() => _AdvanceFormState();
}

class _AdvanceFormState extends ConsumerState<_AdvanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _voucherCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _posCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '18');
  bool _isInterState = false;

  @override
  void dispose() {
    _voucherCtrl.dispose();
    _amountCtrl.dispose();
    _posCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 18;
    final tax = amount * rate / 100;

    final advance = Gstr1At(
      receiptVoucherNumber: _voucherCtrl.text.trim(),
      receiptDate: DateTime.now(),
      placeOfSupply: _posCtrl.text.trim(),
      isInterState: _isInterState,
      advanceAmount: amount,
      igst: _isInterState ? tax : 0,
      cgst: _isInterState ? 0 : tax / 2,
      sgst: _isInterState ? 0 : tax / 2,
      cess: 0,
      gstRate: rate,
    );

    ref.read(gstr1FormDataProvider.notifier).addAdvanceTax(advance);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
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
              'Add Advance Payment',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _voucherCtrl,
              decoration: const InputDecoration(
                labelText: 'Receipt Voucher Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Advance Amount',
                border: OutlineInputBorder(),
                prefixText: '\u20B9 ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _posCtrl,
              decoration: const InputDecoration(
                labelText: 'Place of Supply (State Code)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateCtrl,
              decoration: const InputDecoration(
                labelText: 'GST Rate (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              title: const Text('Inter-state'),
              value: _isInterState,
              onChanged: (v) => setState(() => _isInterState = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Advance'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
