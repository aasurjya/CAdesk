import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data & models
// ---------------------------------------------------------------------------

const _mockClients = [
  'Rajesh Sharma',
  'Priya Patel',
  'Arjun Enterprises Pvt Ltd',
  'Meera Textiles LLP',
  'Vikram & Associates',
];

class _LineItem {
  const _LineItem({
    required this.service,
    required this.hours,
    required this.rate,
  });

  final String service;
  final double hours;
  final double rate;

  double get amount => hours * rate;

  _LineItem copyWith({String? service, double? hours, double? rate}) {
    return _LineItem(
      service: service ?? this.service,
      hours: hours ?? this.hours,
      rate: rate ?? this.rate,
    );
  }
}

class _InvoiceFormState {
  const _InvoiceFormState({
    this.client,
    this.invoiceDate,
    this.dueDate,
    this.lineItems = const [],
    this.discountPercent = 0,
    this.gstPercent = 18,
    this.notes = '',
    this.terms = 'Payment due within 30 days of invoice date.',
  });

  final String? client;
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final List<_LineItem> lineItems;
  final double discountPercent;
  final double gstPercent;
  final String notes;
  final String terms;

  double get subtotal => lineItems.fold(0.0, (sum, item) => sum + item.amount);

  double get discountAmount => subtotal * (discountPercent / 100);

  double get taxableAmount => subtotal - discountAmount;

  double get gstAmount => taxableAmount * (gstPercent / 100);

  double get totalAmount => taxableAmount + gstAmount;

  _InvoiceFormState copyWith({
    String? client,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<_LineItem>? lineItems,
    double? discountPercent,
    double? gstPercent,
    String? notes,
    String? terms,
  }) {
    return _InvoiceFormState(
      client: client ?? this.client,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      lineItems: lineItems ?? this.lineItems,
      discountPercent: discountPercent ?? this.discountPercent,
      gstPercent: gstPercent ?? this.gstPercent,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
    );
  }
}

/// Create/edit invoice form with client selector, line items, tax computation,
/// discount, and preview/save/send actions.
class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({super.key, this.invoiceId});

  final String? invoiceId;

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  _InvoiceFormState _form = _InvoiceFormState(
    invoiceDate: DateTime.now(),
    dueDate: DateTime.now().add(const Duration(days: 30)),
    lineItems: const [
      _LineItem(service: 'ITR Filing', hours: 4, rate: 2500),
      _LineItem(service: 'Tax Planning Advisory', hours: 2, rate: 3000),
    ],
  );

  bool get _isEditing => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    _notesController.text = _form.notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addLineItem() {
    setState(() {
      _form = _form.copyWith(
        lineItems: [
          ..._form.lineItems,
          const _LineItem(service: '', hours: 1, rate: 2500),
        ],
      );
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      final updated = [..._form.lineItems]..removeAt(index);
      _form = _form.copyWith(lineItems: updated);
    });
  }

  void _updateLineItem(int index, _LineItem updated) {
    setState(() {
      final items = [..._form.lineItems];
      items[index] = updated;
      _form = _form.copyWith(lineItems: items);
    });
  }

  void _save({bool send = false}) {
    if (!_formKey.currentState!.validate()) return;
    if (_form.client == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a client')));
      return;
    }
    final action = send ? 'sent to client' : 'saved as draft';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Invoice $action')));
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Invoice' : 'New Invoice'),
        actions: [
          TextButton(onPressed: () => _save(), child: const Text('Save Draft')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Client selector
            const _SectionLabel(
              label: 'Client',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _form.client,
              decoration: const InputDecoration(hintText: 'Select client'),
              items: _mockClients
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _form = _form.copyWith(client: value)),
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Invoice Date',
                    date: _form.invoiceDate ?? DateTime.now(),
                    onChanged: (d) =>
                        setState(() => _form = _form.copyWith(invoiceDate: d)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Due Date',
                    date: _form.dueDate ?? DateTime.now(),
                    onChanged: (d) =>
                        setState(() => _form = _form.copyWith(dueDate: d)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Line items
            const _SectionLabel(
              label: 'Line Items',
              icon: Icons.receipt_long_rounded,
            ),
            const SizedBox(height: 8),
            ..._form.lineItems.asMap().entries.map((entry) {
              return _LineItemRow(
                index: entry.key,
                item: entry.value,
                onUpdate: (updated) => _updateLineItem(entry.key, updated),
                onRemove: () => _removeLineItem(entry.key),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addLineItem,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Line Item'),
            ),
            const SizedBox(height: 20),

            // Discount & GST
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '${_form.discountPercent.toInt()}',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Discount %',
                      suffixText: '%',
                    ),
                    onChanged: (val) {
                      final pct = double.tryParse(val) ?? 0;
                      setState(
                        () => _form = _form.copyWith(discountPercent: pct),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<double>(
                    initialValue: _form.gstPercent,
                    decoration: const InputDecoration(labelText: 'GST Rate'),
                    items: const [
                      DropdownMenuItem(value: 0.0, child: Text('0%')),
                      DropdownMenuItem(value: 5.0, child: Text('5%')),
                      DropdownMenuItem(value: 12.0, child: Text('12%')),
                      DropdownMenuItem(value: 18.0, child: Text('18%')),
                      DropdownMenuItem(value: 28.0, child: Text('28%')),
                    ],
                    onChanged: (val) => setState(
                      () => _form = _form.copyWith(gstPercent: val ?? 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Computation summary
            _ComputationCard(form: _form),
            const SizedBox(height: 16),

            // Notes
            const _SectionLabel(
              label: 'Notes & Terms',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add notes or special instructions',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) =>
                  setState(() => _form = _form.copyWith(notes: val)),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _save(),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => _save(send: true),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send to Client'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Line item row
// ---------------------------------------------------------------------------

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({
    required this.index,
    required this.item,
    required this.onUpdate,
    required this.onRemove,
  });

  final int index;
  final _LineItem item;
  final ValueChanged<_LineItem> onUpdate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item.service,
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      isDense: true,
                    ),
                    onChanged: (val) => onUpdate(item.copyWith(service: val)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: onRemove,
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '${item.hours}',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hours',
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final hours = double.tryParse(val) ?? 0;
                      onUpdate(item.copyWith(hours: hours));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: '${item.rate.toInt()}',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rate (\u20B9)',
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final rate = double.tryParse(val) ?? 0;
                      onUpdate(item.copyWith(rate: rate));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    '\u20B9${item.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Computation card
// ---------------------------------------------------------------------------

class _ComputationCard extends StatelessWidget {
  const _ComputationCard({required this.form});

  final _InvoiceFormState form;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.neutral50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _AmountRow(label: 'Subtotal', amount: form.subtotal, theme: theme),
            if (form.discountPercent > 0)
              _AmountRow(
                label: 'Discount (${form.discountPercent.toStringAsFixed(0)}%)',
                amount: -form.discountAmount,
                theme: theme,
                color: AppColors.error,
              ),
            _AmountRow(
              label: 'GST (${form.gstPercent.toStringAsFixed(0)}%)',
              amount: form.gstAmount,
              theme: theme,
            ),
            const Divider(),
            _AmountRow(
              label: 'Total',
              amount: form.totalAmount,
              theme: theme,
              isBold: true,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    required this.theme,
    this.isBold = false,
    this.color,
  });

  final String label;
  final double amount;
  final ThemeData theme;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.neutral600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: textColor,
            ),
          ),
          Text(
            '\u20B9${amount.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final display =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(display),
      ),
    );
  }
}
