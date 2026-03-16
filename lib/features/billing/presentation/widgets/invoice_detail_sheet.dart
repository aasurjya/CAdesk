import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/billing/data/providers/billing_providers.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';
import 'package:ca_app/features/billing/presentation/widgets/new_invoice_sheet.dart';

/// Shows full invoice detail in a bottom sheet when an invoice tile is tapped.
class InvoiceDetailSheet extends ConsumerStatefulWidget {
  const InvoiceDetailSheet({super.key, required this.invoice});

  final Invoice invoice;

  /// Opens the detail sheet for [invoice] using [showModalBottomSheet].
  static Future<void> show(BuildContext context, Invoice invoice) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvoiceDetailSheet(invoice: invoice),
    );
  }

  @override
  ConsumerState<InvoiceDetailSheet> createState() => _InvoiceDetailSheetState();
}

class _InvoiceDetailSheetState extends ConsumerState<InvoiceDetailSheet> {
  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 2,
  );
  static final _currencyInt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final payments = ref
        .watch(allPaymentRecordsProvider)
        .where((p) => p.invoiceId == invoice.id)
        .toList();

    final now = DateTime.now();
    final daysOverdue = invoice.status == InvoiceStatus.overdue
        ? now.difference(invoice.dueDate).inDays.clamp(0, 9999)
        : 0;
    final interest = daysOverdue > 0
        ? GstInvoiceCalculator.latePaymentInterest(
            amount: invoice.balanceDue,
            daysOverdue: daysOverdue,
          )
        : 0.0;

    return DraggableScrollableSheet(
      minChildSize: 0.5,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    _buildHeader(context, invoice),
                    const SizedBox(height: 16),
                    _buildLineItemsTable(context, invoice),
                    const SizedBox(height: 16),
                    _buildTotalsSection(context, invoice),
                    const SizedBox(height: 16),
                    _buildPaymentSection(
                      context,
                      invoice,
                      payments,
                      daysOverdue,
                      interest,
                    ),
                    const SizedBox(height: 24),
                    _buildActions(context, invoice),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Invoice invoice) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(invoice.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoice.clientName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(status: invoice.status, color: statusColor),
        ],
      ),
    );
  }

  Widget _buildLineItemsTable(BuildContext context, Invoice invoice) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Line Items',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildTableHeader(theme.textTheme),
              const Divider(height: 1, color: AppColors.neutral200),
              ...invoice.lineItems.map((item) {
                return Column(
                  children: [
                    _buildTableRow(theme.textTheme, item),
                    if (item != invoice.lineItems.last)
                      const Divider(height: 1, color: AppColors.neutral100),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(TextTheme theme) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppColors.neutral400,
    );

    return Container(
      color: AppColors.neutral50,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text('Description', style: style)),
          const _HeaderCell('Taxable'),
          const _HeaderCell('GST%'),
          const _HeaderCell('CGST'),
          const _HeaderCell('SGST'),
          const _HeaderCell('IGST'),
          const _HeaderCell('Total'),
        ],
      ),
    );
  }

  Widget _buildTableRow(TextTheme theme, LineItem item) {
    final tax = GstInvoiceCalculator.compute(
      taxableValue: item.taxableAmount,
      gstRatePercent: item.gstRate,
      isInterState: item.igst > 0,
    );

    const valueStyle = TextStyle(fontSize: 10, color: AppColors.neutral600);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.description,
              style: theme.bodySmall?.copyWith(
                color: AppColors.neutral900,
                fontSize: 11,
              ),
            ),
          ),
          _ValueCell(_currencyInt.format(item.taxableAmount), valueStyle),
          _ValueCell('${item.gstRate.toStringAsFixed(0)}%', valueStyle),
          _ValueCell(_currencyInt.format(tax.cgst), valueStyle),
          _ValueCell(_currencyInt.format(tax.sgst), valueStyle),
          _ValueCell(_currencyInt.format(tax.igst), valueStyle),
          _ValueCell(
            _currencyInt.format(tax.total),
            valueStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection(BuildContext context, Invoice invoice) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'Sub-total',
            value: _currencyInt.format(invoice.subtotal),
            theme: textTheme,
          ),
          const SizedBox(height: 4),
          _TotalRow(
            label: 'Total GST',
            value: _currencyInt.format(invoice.totalGst),
            theme: textTheme,
          ),
          const Divider(color: AppColors.neutral300, height: 16),
          _TotalRow(
            label: 'Grand Total',
            value: _currencyInt.format(invoice.grandTotal),
            theme: textTheme,
            isGrand: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(
    BuildContext context,
    Invoice invoice,
    List<PaymentRecord> payments,
    int daysOverdue,
    double interest,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Status',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount Paid',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    _currencyInt.format(invoice.paidAmount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount Due',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    _currencyInt.format(invoice.balanceDue),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: invoice.balanceDue > 0
                          ? AppColors.error
                          : AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              if (daysOverdue > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Late Interest ($daysOverdue days @ 18% p.a.)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _currency.format(interest),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (payments.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Payment History',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 6),
          ...payments.map((p) => _PaymentRecordTile(record: p)),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, Invoice invoice) {
    final canMarkPaid =
        invoice.status == InvoiceStatus.sent ||
        invoice.status == InvoiceStatus.partial ||
        invoice.status == InvoiceStatus.overdue;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionButton(
          icon: Icons.add_circle_outline_rounded,
          label: 'Record Payment',
          color: AppColors.primary,
          onTap: () => _showRecordPaymentDialog(context, invoice),
        ),
        _ActionButton(
          icon: Icons.edit_outlined,
          label: 'Edit Invoice',
          color: AppColors.secondary,
          onTap: () => _editInvoice(context, invoice),
        ),
        _ActionButton(
          icon: Icons.notifications_outlined,
          label: 'Send Reminder',
          color: AppColors.secondary,
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Reminder sent to ${invoice.clientName.toLowerCase().replaceAll(' ', '.')}@example.com',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _ActionButton(
          icon: Icons.picture_as_pdf_outlined,
          label: 'Download PDF',
          color: AppColors.accent,
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF download started…'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        if (canMarkPaid)
          _ActionButton(
            icon: Icons.check_circle_outline_rounded,
            label: 'Mark as Paid',
            color: AppColors.success,
            onTap: () => _markAsPaid(context, invoice),
          ),
        _ActionButton(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AppColors.error,
          onTap: () => _confirmDelete(context, invoice),
        ),
      ],
    );
  }

  void _showRecordPaymentDialog(BuildContext context, Invoice invoice) {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    String selectedMode = 'NEFT';
    const modes = ['NEFT', 'RTGS', 'UPI', 'Cheque', 'Cash'];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Record Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Mode'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMode,
                        isDense: true,
                        items: modes
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedMode = v);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference / UTR',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final rawAmount = amountController.text.trim();
                    final amount = double.tryParse(rawAmount) ?? 0;
                    if (amount <= 0) {
                      return;
                    }
                    final now = DateTime.now();
                    final dateStr = DateFormat('dd MMM yyyy').format(now);
                    final record = PaymentRecord(
                      id: 'pr_${now.millisecondsSinceEpoch}',
                      invoiceId: invoice.id,
                      clientName: invoice.clientName,
                      amount: amount,
                      paymentDate: dateStr,
                      mode: selectedMode,
                      reference: referenceController.text.trim(),
                      notes: '',
                    );
                    ref
                        .read(allPaymentRecordsProvider.notifier)
                        .addRecord(record);
                    _applyPaymentToInvoice(invoice, amount);
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Payment of \u20B9${amount.toStringAsFixed(0)} recorded.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyPaymentToInvoice(Invoice invoice, double amount) {
    final invoices = ref.read(allInvoicesProvider);
    final newPaid = (invoice.paidAmount + amount).clamp(
      0.0,
      invoice.grandTotal,
    );
    final newBalance = invoice.grandTotal - newPaid;
    final newStatus = newBalance <= 0
        ? InvoiceStatus.paid
        : InvoiceStatus.partial;

    final updated = invoices.map((inv) {
      if (inv.id != invoice.id) {
        return inv;
      }
      return inv.copyWith(
        paidAmount: newPaid,
        balanceDue: newBalance,
        status: newStatus,
      );
    }).toList();
    ref.read(allInvoicesProvider.notifier).update(updated);
  }

  void _markAsPaid(BuildContext context, Invoice invoice) {
    final invoices = ref.read(allInvoicesProvider);
    final updated = invoices.map((inv) {
      if (inv.id != invoice.id) {
        return inv;
      }
      return inv.copyWith(
        paidAmount: inv.grandTotal,
        balanceDue: 0,
        status: InvoiceStatus.paid,
        paymentDate: DateTime.now(),
      );
    }).toList();
    ref.read(allInvoicesProvider.notifier).update(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${invoice.invoiceNumber} marked as paid.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editInvoice(BuildContext context, Invoice invoice) {
    Navigator.pop(context);
    NewInvoiceSheet.show(context, existingInvoice: invoice);
  }

  Future<void> _confirmDelete(BuildContext context, Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text(
          'Are you sure you want to delete invoice ${invoice.invoiceNumber}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(allInvoicesProvider.notifier).deleteInvoice(invoice.id);
    if (!context.mounted) return;
    Navigator.pop(context);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${invoice.invoiceNumber} deleted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final InvoiceStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral400,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell(this.text, this.style);

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isGrand = false,
  });

  final String label;
  final String value;
  final TextTheme theme;
  final bool isGrand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isGrand
              ? theme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                )
              : theme.bodySmall?.copyWith(color: AppColors.neutral600),
        ),
        Text(
          value,
          style: isGrand
              ? theme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                )
              : theme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
        ),
      ],
    );
  }
}

class _PaymentRecordTile extends StatelessWidget {
  const _PaymentRecordTile({required this.record});

  final PaymentRecord record;

  static final _currencyInt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.success.withAlpha(40)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.mode} · ${record.paymentDate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                if (record.reference.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    record.reference,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            _currencyInt.format(record.amount),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withAlpha(76)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

Color _statusColor(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return AppColors.neutral600;
    case InvoiceStatus.sent:
      return AppColors.primaryVariant;
    case InvoiceStatus.partial:
      return AppColors.warning;
    case InvoiceStatus.paid:
      return AppColors.success;
    case InvoiceStatus.overdue:
      return AppColors.error;
    case InvoiceStatus.cancelled:
      return AppColors.neutral400;
  }
}
