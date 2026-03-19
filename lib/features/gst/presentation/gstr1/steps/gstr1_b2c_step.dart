import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr1_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';

/// Step 2: B2C Invoices (Table 5/7) -- Large B2C & Small B2C.
class Gstr1B2cStep extends ConsumerWidget {
  const Gstr1B2cStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(gstr1FormDataProvider);
    final invoices = formData.b2cInvoices;
    final largeB2c = invoices
        .where((i) => i.category == B2cCategory.large)
        .toList();
    final smallB2c = invoices
        .where((i) => i.category == B2cCategory.small)
        .toList();

    return Stack(
      children: [
        if (invoices.isEmpty)
          _EmptyState()
        else
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              if (largeB2c.isNotEmpty) ...[
                _SectionHeader(
                  title: 'B2CL — Large (> \u20B92.5L, Inter-state)',
                  count: largeB2c.length,
                ),
                const SizedBox(height: 8),
                ...largeB2c.map(
                  (inv) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _B2cTile(
                      invoice: inv,
                      onDelete: () {
                        final idx = invoices.indexOf(inv);
                        ref
                            .read(gstr1FormDataProvider.notifier)
                            .removeB2cInvoice(idx);
                      },
                    ),
                  ),
                ),
              ],
              if (smallB2c.isNotEmpty) ...[
                _SectionHeader(
                  title: 'B2CS — Small (Consolidated)',
                  count: smallB2c.length,
                ),
                const SizedBox(height: 8),
                ...smallB2c.map(
                  (inv) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _B2cTile(
                      invoice: inv,
                      onDelete: () {
                        final idx = invoices.indexOf(inv);
                        ref
                            .read(gstr1FormDataProvider.notifier)
                            .removeB2cInvoice(idx);
                      },
                    ),
                  ),
                ),
              ],
              // Summary row
              _B2cSummaryBar(invoices: invoices),
            ],
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'gstr1_b2c_fab',
            onPressed: () => _showAddSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add B2C'),
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
      builder: (_) => const _B2cInvoiceForm(),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_rounded, size: 48, color: AppColors.neutral200),
          SizedBox(height: 12),
          Text(
            'No B2C invoices added',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// B2C tile
// ---------------------------------------------------------------------------

class _B2cTile extends StatelessWidget {
  const _B2cTile({required this.invoice, required this.onDelete});

  final Gstr1B2cInvoice invoice;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(invoice.invoiceDate);
    final isLarge = invoice.category == B2cCategory.large;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isLarge
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  invoice.category.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLarge ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  invoice.invoiceNumber ?? 'Consolidated',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.neutral900,
                  ),
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
            '$dateStr  •  POS: ${invoice.placeOfSupply}  •  ${invoice.gstRate}%',
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Taxable: ${CurrencyUtils.formatINR(invoice.taxableValue)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              const Spacer(),
              Text(
                'Tax: ${CurrencyUtils.formatINR(invoice.totalTax)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
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
// Summary bar
// ---------------------------------------------------------------------------

class _B2cSummaryBar extends StatelessWidget {
  const _B2cSummaryBar({required this.invoices});

  final List<Gstr1B2cInvoice> invoices;

  @override
  Widget build(BuildContext context) {
    final totalTaxable = invoices.fold(0.0, (s, i) => s + i.taxableValue);
    final totalTax = invoices.fold(0.0, (s, i) => s + i.totalTax);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: 'Total Invoices', value: '${invoices.length}'),
          _SummaryItem(
            label: 'Taxable Value',
            value: CurrencyUtils.formatINRCompact(totalTaxable),
          ),
          _SummaryItem(
            label: 'Total Tax',
            value: CurrencyUtils.formatINRCompact(totalTax),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add B2C invoice form
// ---------------------------------------------------------------------------

class _B2cInvoiceForm extends ConsumerStatefulWidget {
  const _B2cInvoiceForm();

  @override
  ConsumerState<_B2cInvoiceForm> createState() => _B2cInvoiceFormState();
}

class _B2cInvoiceFormState extends ConsumerState<_B2cInvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _taxableValueCtrl = TextEditingController();
  final _gstRateCtrl = TextEditingController(text: '18');
  final _posCtrl = TextEditingController();
  B2cCategory _category = B2cCategory.small;
  bool _isInterState = false;

  @override
  void dispose() {
    _taxableValueCtrl.dispose();
    _gstRateCtrl.dispose();
    _posCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final taxable = double.tryParse(_taxableValueCtrl.text) ?? 0;
    final rate = double.tryParse(_gstRateCtrl.text) ?? 18;
    final tax = taxable * rate / 100;

    final invoice = Gstr1B2cInvoice(
      invoiceDate: DateTime.now(),
      placeOfSupply: _posCtrl.text.trim(),
      isInterState: _isInterState,
      taxableValue: taxable,
      igst: _isInterState ? tax : 0,
      cgst: _isInterState ? 0 : tax / 2,
      sgst: _isInterState ? 0 : tax / 2,
      cess: 0,
      gstRate: rate,
      category: _category,
    );

    ref.read(gstr1FormDataProvider.notifier).addB2cInvoice(invoice);
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
              'Add B2C Invoice',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SegmentedButton<B2cCategory>(
              segments: const [
                ButtonSegment(
                  value: B2cCategory.large,
                  label: Text('B2CL (> 2.5L)'),
                ),
                ButtonSegment(
                  value: B2cCategory.small,
                  label: Text('B2CS (Small)'),
                ),
              ],
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
            ),
            const SizedBox(height: 16),
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
              value: _isInterState,
              onChanged: (v) => setState(() => _isInterState = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add B2C Invoice'),
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
