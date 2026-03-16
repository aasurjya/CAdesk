import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/billing/data/providers/billing_providers.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';

/// Bottom sheet form to create or edit a GST invoice with live computation.
class NewInvoiceSheet extends ConsumerStatefulWidget {
  const NewInvoiceSheet({super.key, this.existingInvoice});

  /// If provided, the sheet opens in edit mode with fields pre-populated.
  final Invoice? existingInvoice;

  /// Whether this sheet is in edit mode.
  bool get isEditMode => existingInvoice != null;

  /// Opens the invoice sheet. Pass [existingInvoice] to edit.
  static Future<void> show(
    BuildContext context, {
    Invoice? existingInvoice,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewInvoiceSheet(existingInvoice: existingInvoice),
    );
  }

  @override
  ConsumerState<NewInvoiceSheet> createState() => _NewInvoiceSheetState();
}

class _NewInvoiceSheetState extends ConsumerState<NewInvoiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  double _gstRate = 18;
  bool _isInterState = false;
  int _dueDaysOffset = 30;

  static const _gstRates = [5.0, 12.0, 18.0, 28.0];
  static const _dueDayOptions = [7, 15, 30, 45];

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    final existing = widget.existingInvoice;
    if (existing != null) {
      _clientController.text = existing.clientName;
      if (existing.lineItems.isNotEmpty) {
        _descriptionController.text = existing.lineItems.first.description;
        _amountController.text =
            existing.lineItems.first.taxableAmount.toStringAsFixed(2);
        _gstRate = existing.lineItems.first.gstRate;
        _isInterState = existing.lineItems.first.igst > 0;
      }
    }
  }

  @override
  void dispose() {
    _clientController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _taxableValue =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  InvoiceTax get _computedTax => GstInvoiceCalculator.compute(
    taxableValue: _taxableValue,
    gstRatePercent: _gstRate,
    isInterState: _isInterState,
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 1.0,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  children: [
                    Text(
                      widget.isEditMode ? 'Edit Invoice' : 'New Invoice',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClientField(),
                        const SizedBox(height: 14),
                        _buildDescriptionField(),
                        const SizedBox(height: 14),
                        _buildAmountField(),
                        const SizedBox(height: 14),
                        _buildGstRateSelector(context),
                        const SizedBox(height: 14),
                        _buildInterStateToggle(context),
                        const SizedBox(height: 16),
                        _buildLivePreview(context),
                        const SizedBox(height: 16),
                        _buildDueDateSelector(context),
                        const SizedBox(height: 24),
                        _buildSubmitButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildClientField() {
    return TextFormField(
      controller: _clientController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Client Name *',
        hintText: 'e.g. ABC Infra Pvt Ltd',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Client name is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Service Description *',
        hintText: 'e.g. ITR Filing AY 2025-26',
        prefixIcon: Icon(Icons.description_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Service description is required';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Taxable Amount (₹) *',
        hintText: '0.00',
        prefixText: '₹ ',
      ),
      onChanged: (_) => setState(() {}),
      validator: (value) {
        final parsed = double.tryParse(value?.trim() ?? '');
        if (parsed == null || parsed <= 0) {
          return 'Enter a valid taxable amount greater than ₹0';
        }
        return null;
      },
    );
  }

  Widget _buildGstRateSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GST Rate',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _gstRates.map((rate) {
            final isSelected = _gstRate == rate;
            return ChoiceChip(
              label: Text('${rate.toStringAsFixed(0)}%'),
              selected: isSelected,
              selectedColor: AppColors.primary.withAlpha(25),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.neutral600,
              ),
              onSelected: (_) => setState(() {
                _gstRate = rate;
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterStateToggle(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inter-state Supply',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                _isInterState
                    ? 'IGST will be charged'
                    : 'CGST + SGST will be charged',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _isInterState,
          onChanged: (v) => setState(() => _isInterState = v),
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildLivePreview(BuildContext context) {
    final theme = Theme.of(context);
    final tax = _computedTax;
    final taxable = _taxableValue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Computation',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PreviewItem(label: 'Taxable', value: _currency.format(taxable)),
              if (_isInterState) ...[
                _PreviewItem(label: 'IGST', value: _currency.format(tax.igst)),
              ] else ...[
                _PreviewItem(label: 'CGST', value: _currency.format(tax.cgst)),
                _PreviewItem(label: 'SGST', value: _currency.format(tax.sgst)),
              ],
              _PreviewItem(
                label: 'Total',
                value: _currency.format(tax.total),
                highlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateSelector(BuildContext context) {
    final theme = Theme.of(context);
    final invoiceDate = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _dueDayOptions.map((days) {
            final isSelected = _dueDaysOffset == days;
            final dueDate = invoiceDate.add(Duration(days: days));
            return ChoiceChip(
              label: Text(
                '+$days days\n(${DateFormat('dd MMM').format(dueDate)})',
                textAlign: TextAlign.center,
              ),
              selected: isSelected,
              selectedColor: AppColors.secondary.withAlpha(25),
              checkmarkColor: AppColors.secondary,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.secondary : AppColors.neutral600,
              ),
              onSelected: (_) => setState(() => _dueDaysOffset = days),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _submitForm(context),
        icon: Icon(
          widget.isEditMode
              ? Icons.save_rounded
              : Icons.receipt_long_rounded,
        ),
        label: Text(widget.isEditMode ? 'Update Invoice' : 'Create Invoice'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tax = _computedTax;
    final taxable = _taxableValue;
    final now = DateTime.now();
    final dueDate = now.add(Duration(days: _dueDaysOffset));

    final lineItem = LineItem(
      description: _descriptionController.text.trim(),
      hsn: '998221',
      quantity: 1,
      rate: taxable,
      taxableAmount: taxable,
      gstRate: _gstRate,
      cgst: tax.cgst,
      sgst: tax.sgst,
      igst: tax.igst,
      total: tax.total,
    );

    final notifier = ref.read(allInvoicesProvider.notifier);
    final existing = widget.existingInvoice;

    if (existing != null) {
      // Edit mode — update existing invoice
      final updatedInvoice = existing.copyWith(
        clientName: _clientController.text.trim(),
        dueDate: dueDate,
        lineItems: [lineItem],
        subtotal: taxable,
        totalGst: tax.total - taxable,
        grandTotal: tax.total,
        balanceDue: tax.total - existing.paidAmount,
      );

      notifier.updateInvoice(updatedInvoice);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ${existing.invoiceNumber} updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Create mode — new invoice
      final invoices = ref.read(allInvoicesProvider);
      final nextNumber = invoices.length + 1;
      final invoiceNumber =
          'CAD/2025-26/${nextNumber.toString().padLeft(3, '0')}';

      final newInvoice = Invoice(
        id: 'inv_${now.millisecondsSinceEpoch}',
        invoiceNumber: invoiceNumber,
        clientId: 'new_${now.millisecondsSinceEpoch}',
        clientName: _clientController.text.trim(),
        invoiceDate: now,
        dueDate: dueDate,
        lineItems: [lineItem],
        subtotal: taxable,
        totalGst: tax.total - taxable,
        grandTotal: tax.total,
        paidAmount: 0,
        balanceDue: tax.total,
        status: InvoiceStatus.draft,
      );

      notifier.addInvoice(newInvoice);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice $invoiceNumber created.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _PreviewItem extends StatelessWidget {
  const _PreviewItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            color: highlight ? AppColors.primary : AppColors.neutral900,
            fontSize: highlight ? 14 : 12,
          ),
        ),
      ],
    );
  }
}
