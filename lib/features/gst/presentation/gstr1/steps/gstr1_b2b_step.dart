import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr1_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';

/// Step 1: B2B Invoices (Table 4A) -- list with add/edit/delete.
class Gstr1B2bStep extends ConsumerWidget {
  const Gstr1B2bStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(gstr1FormDataProvider);
    final invoices = formData.b2bInvoices;

    return Stack(
      children: [
        if (invoices.isEmpty)
          _EmptyState()
        else
          _InvoiceList(invoices: invoices),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'gstr1_b2b_fab',
            onPressed: () => _showAddInvoiceSheet(context, ref),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Invoice'),
          ),
        ),
      ],
    );
  }

  void _showAddInvoiceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _B2bInvoiceForm(),
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
            Icons.receipt_long_rounded,
            size: 48,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 12),
          Text(
            'No B2B invoices added',
            style: TextStyle(
              color: AppColors.neutral400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the button below to add invoices',
            style: TextStyle(color: AppColors.neutral300, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice list with summary
// ---------------------------------------------------------------------------

class _InvoiceList extends ConsumerWidget {
  const _InvoiceList({required this.invoices});

  final List<Gstr1B2bInvoice> invoices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTaxable = invoices.fold(0.0, (s, i) => s + i.taxableValue);
    final totalTax = invoices.fold(0.0, (s, i) => s + i.totalTax);

    return Column(
      children: [
        // Summary bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.primary.withValues(alpha: 0.06),
          child: Row(
            children: [
              _SummaryChip(label: 'Invoices', value: '${invoices.length}'),
              const SizedBox(width: 16),
              _SummaryChip(
                label: 'Taxable',
                value: CurrencyUtils.formatINRCompact(totalTaxable),
              ),
              const SizedBox(width: 16),
              _SummaryChip(
                label: 'Tax',
                value: CurrencyUtils.formatINRCompact(totalTax),
              ),
            ],
          ),
        ),
        // Invoice list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: invoices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final inv = invoices[index];
              return _B2bInvoiceTile(
                invoice: inv,
                onDelete: () {
                  ref
                      .read(gstr1FormDataProvider.notifier)
                      .removeB2bInvoice(index);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary chip
// ---------------------------------------------------------------------------

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.neutral400,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice tile
// ---------------------------------------------------------------------------

class _B2bInvoiceTile extends StatelessWidget {
  const _B2bInvoiceTile({required this.invoice, required this.onDelete});

  final Gstr1B2bInvoice invoice;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(invoice.invoiceDate);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invoice.recipientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.neutral900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppColors.error,
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${invoice.invoiceNumber}  •  $dateStr  •  GSTIN: ${invoice.recipientGstin}',
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ValueLabel(
                label: 'Taxable',
                value: CurrencyUtils.formatINR(invoice.taxableValue),
              ),
              const SizedBox(width: 12),
              if (invoice.isInterState)
                _ValueLabel(
                  label: 'IGST',
                  value: CurrencyUtils.formatINR(invoice.igst),
                )
              else ...[
                _ValueLabel(
                  label: 'CGST',
                  value: CurrencyUtils.formatINR(invoice.cgst),
                ),
                const SizedBox(width: 12),
                _ValueLabel(
                  label: 'SGST',
                  value: CurrencyUtils.formatINR(invoice.sgst),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${invoice.gstRate}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Value + label pair
// ---------------------------------------------------------------------------

class _ValueLabel extends StatelessWidget {
  const _ValueLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add invoice bottom sheet form
// ---------------------------------------------------------------------------

class _B2bInvoiceForm extends ConsumerStatefulWidget {
  const _B2bInvoiceForm();

  @override
  ConsumerState<_B2bInvoiceForm> createState() => _B2bInvoiceFormState();
}

class _B2bInvoiceFormState extends ConsumerState<_B2bInvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberCtrl = TextEditingController();
  final _recipientGstinCtrl = TextEditingController();
  final _recipientNameCtrl = TextEditingController();
  final _taxableValueCtrl = TextEditingController();
  final _gstRateCtrl = TextEditingController(text: '18');
  bool _isInterState = false;
  final DateTime _invoiceDate = DateTime.now();

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _recipientGstinCtrl.dispose();
    _recipientNameCtrl.dispose();
    _taxableValueCtrl.dispose();
    _gstRateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final taxable = double.tryParse(_taxableValueCtrl.text) ?? 0;
    final rate = double.tryParse(_gstRateCtrl.text) ?? 18;
    final taxAmount = taxable * rate / 100;

    final invoice = Gstr1B2bInvoice(
      invoiceNumber: _invoiceNumberCtrl.text.trim(),
      invoiceDate: _invoiceDate,
      recipientGstin: _recipientGstinCtrl.text.trim(),
      recipientName: _recipientNameCtrl.text.trim(),
      placeOfSupply: _recipientGstinCtrl.text.length >= 2
          ? _recipientGstinCtrl.text.substring(0, 2)
          : '',
      isInterState: _isInterState,
      taxableValue: taxable,
      igst: _isInterState ? taxAmount : 0,
      cgst: _isInterState ? 0 : taxAmount / 2,
      sgst: _isInterState ? 0 : taxAmount / 2,
      cess: 0,
      gstRate: rate,
      invoiceType: 'Regular',
      reverseCharge: false,
    );

    ref.read(gstr1FormDataProvider.notifier).addB2bInvoice(invoice);
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
              'Add B2B Invoice',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 20),
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
              controller: _recipientGstinCtrl,
              decoration: const InputDecoration(
                labelText: 'Recipient GSTIN',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().length != 15) ? '15 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _recipientNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Recipient Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _taxableValueCtrl,
              decoration: const InputDecoration(
                labelText: 'Taxable Value',
                border: OutlineInputBorder(),
                prefixText: '\u20B9 ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gstRateCtrl,
              decoration: const InputDecoration(
                labelText: 'GST Rate (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              title: const Text('Inter-state supply'),
              subtitle: Text(_isInterState ? 'IGST' : 'CGST + SGST'),
              value: _isInterState,
              onChanged: (v) => setState(() => _isInterState = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Invoice'),
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
