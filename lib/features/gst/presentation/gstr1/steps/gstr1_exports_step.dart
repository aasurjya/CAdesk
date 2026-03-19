import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr1_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';

/// Step 4: Exports (Table 6A) -- Export invoices.
class Gstr1ExportsStep extends ConsumerWidget {
  const Gstr1ExportsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exports = ref.watch(gstr1FormDataProvider).exports;

    return Stack(
      children: [
        if (exports.isEmpty)
          _EmptyState()
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: exports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final exp = exports[index];
              return _ExportTile(
                export: exp,
                onDelete: () => ref
                    .read(gstr1FormDataProvider.notifier)
                    .removeExport(index),
              );
            },
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'gstr1_exp_fab',
            onPressed: () => _showAddSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Export'),
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
      builder: (_) => const _ExportForm(),
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
          Icon(
            Icons.flight_takeoff_rounded,
            size: 48,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 12),
          Text(
            'No export invoices added',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Skip this step if not applicable',
            style: TextStyle(color: AppColors.neutral300, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export tile
// ---------------------------------------------------------------------------

class _ExportTile extends StatelessWidget {
  const _ExportTile({required this.export, required this.onDelete});

  final Gstr1Exp export;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(export.invoiceDate);

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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: export.isZeroRated
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        export.exportType.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: export.isZeroRated
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      export.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateStr  •  ${export.currencyCode}  •  ${CurrencyUtils.formatINR(export.foreignCurrencyValue)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Taxable: ${CurrencyUtils.formatINR(export.taxableValue)}  •  IGST: ${CurrencyUtils.formatINR(export.igst)}',
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
// Add export form
// ---------------------------------------------------------------------------

class _ExportForm extends ConsumerStatefulWidget {
  const _ExportForm();

  @override
  ConsumerState<_ExportForm> createState() => _ExportFormState();
}

class _ExportFormState extends ConsumerState<_ExportForm> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberCtrl = TextEditingController();
  final _taxableCtrl = TextEditingController();
  final _foreignValueCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'USD');
  ExportType _exportType = ExportType.withPayment;

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _taxableCtrl.dispose();
    _foreignValueCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final taxable = double.tryParse(_taxableCtrl.text) ?? 0;
    final foreignVal = double.tryParse(_foreignValueCtrl.text) ?? taxable;
    final isWithPayment =
        _exportType == ExportType.withPayment ||
        _exportType == ExportType.sezWithPayment;
    final igst = isWithPayment ? taxable * 0.18 : 0.0;

    final exp = Gstr1Exp(
      invoiceNumber: _invoiceNumberCtrl.text.trim(),
      invoiceDate: DateTime.now(),
      exportType: _exportType,
      currencyCode: _currencyCtrl.text.trim().toUpperCase(),
      foreignCurrencyValue: foreignVal,
      taxableValue: taxable,
      igst: igst,
      cess: 0,
      gstRate: isWithPayment ? 18 : 0,
    );

    ref.read(gstr1FormDataProvider.notifier).addExport(exp);
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
              'Add Export Invoice',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportType>(
              initialValue: _exportType,
              decoration: const InputDecoration(
                labelText: 'Export Type',
                border: OutlineInputBorder(),
              ),
              items: ExportType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _exportType = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _invoiceNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _taxableCtrl,
              decoration: const InputDecoration(
                labelText: 'Taxable Value (INR)',
                border: OutlineInputBorder(),
                prefixText: '\u20B9 ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _foreignValueCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Foreign Currency Value',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _currencyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Export'),
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
