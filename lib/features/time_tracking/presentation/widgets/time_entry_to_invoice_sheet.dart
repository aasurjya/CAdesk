import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/billing/data/providers/billing_providers.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/time_tracking/data/providers/time_tracking_providers.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

/// Sheet that groups time entries by client and lets the user generate an invoice.
class TimeEntryToInvoiceSheet extends ConsumerStatefulWidget {
  const TimeEntryToInvoiceSheet({super.key});

  @override
  ConsumerState<TimeEntryToInvoiceSheet> createState() =>
      _TimeEntryToInvoiceSheetState();
}

class _TimeEntryToInvoiceSheetState
    extends ConsumerState<TimeEntryToInvoiceSheet> {
  double _gstRate = 18;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(timeEntriesProvider);
    final billableEntries = entries.where((e) => e.isBillable).toList();
    final grouped = _groupByClient(billableEntries);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 10),
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Generate Invoice',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Client groups
                    ...grouped.entries.map((entry) {
                      return _ClientGroup(
                        clientName: entry.key,
                        entries: entry.value,
                        theme: theme,
                      );
                    }),
                    const Divider(height: 32),
                    // GST rate selector
                    _GstSelector(
                      gstRate: _gstRate,
                      onChanged: (rate) => setState(() => _gstRate = rate),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    // Invoice totals
                    _InvoiceTotals(
                      entries: billableEntries,
                      gstRate: _gstRate,
                      theme: theme,
                    ),
                    const SizedBox(height: 24),
                    // Create Invoice button
                    _CreateInvoiceButton(
                      entries: billableEntries,
                      gstRate: _gstRate,
                      grouped: grouped,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<TimeEntry>> _groupByClient(List<TimeEntry> entries) {
    final result = <String, List<TimeEntry>>{};
    for (final entry in entries) {
      (result[entry.clientName] ??= []).add(entry);
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Client group section
// ---------------------------------------------------------------------------

class _ClientGroup extends StatelessWidget {
  const _ClientGroup({
    required this.clientName,
    required this.entries,
    required this.theme,
  });

  final String clientName;
  final List<TimeEntry> entries;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final totalHours = entries.fold<double>(
      0,
      (sum, e) => sum + e.durationMinutes / 60.0,
    );
    final totalAmount = entries.fold<double>(
      0,
      (sum, e) => sum + e.billedAmount,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    clientName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  '${totalHours.toStringAsFixed(1)}h  •  ₹${totalAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Entry rows
          ...entries.map((e) {
            final hours = e.durationMinutes / 60.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.taskDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${hours.toStringAsFixed(1)}h',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '₹${e.billedAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GST rate selector
// ---------------------------------------------------------------------------

class _GstSelector extends StatelessWidget {
  const _GstSelector({
    required this.gstRate,
    required this.onChanged,
    required this.theme,
  });

  final double gstRate;
  final ValueChanged<double> onChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    const rates = <double>[0, 5, 12, 18, 28];

    return Row(
      children: [
        Text(
          'GST Rate:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(width: 12),
        ...rates.map((rate) {
          final isSelected = gstRate == rate;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text('${rate.toStringAsFixed(0)}%'),
              selected: isSelected,
              onSelected: (_) => onChanged(rate),
              selectedColor: AppColors.primary.withAlpha(26),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.neutral600,
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice totals block
// ---------------------------------------------------------------------------

class _InvoiceTotals extends StatelessWidget {
  const _InvoiceTotals({
    required this.entries,
    required this.gstRate,
    required this.theme,
  });

  final List<TimeEntry> entries;
  final double gstRate;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final subtotal = entries.fold<double>(0, (sum, e) => sum + e.billedAmount);
    final totalHours = entries.fold<double>(
      0,
      (sum, e) => sum + e.durationMinutes / 60.0,
    );
    final cgst = subtotal * gstRate / 200; // half of GST
    final sgst = cgst;
    final invoiceTotal = subtotal + cgst + sgst;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'Total Hours',
            value: '${totalHours.toStringAsFixed(1)} hrs',
            theme: theme,
          ),
          _TotalRow(
            label: 'Subtotal',
            value: '₹${subtotal.toStringAsFixed(2)}',
            theme: theme,
          ),
          if (gstRate > 0) ...[
            _TotalRow(
              label: 'CGST (${(gstRate / 2).toStringAsFixed(1)}%)',
              value: '₹${cgst.toStringAsFixed(2)}',
              theme: theme,
              valueColor: AppColors.neutral600,
            ),
            _TotalRow(
              label: 'SGST (${(gstRate / 2).toStringAsFixed(1)}%)',
              value: '₹${sgst.toStringAsFixed(2)}',
              theme: theme,
              valueColor: AppColors.neutral600,
            ),
          ],
          const Divider(height: 20),
          _TotalRow(
            label: 'Invoice Total',
            value: '₹${invoiceTotal.toStringAsFixed(2)}',
            theme: theme,
            isBold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Create Invoice button
// ---------------------------------------------------------------------------

class _CreateInvoiceButton extends ConsumerWidget {
  const _CreateInvoiceButton({
    required this.entries,
    required this.gstRate,
    required this.grouped,
  });

  final List<TimeEntry> entries;
  final double gstRate;
  final Map<String, List<TimeEntry>> grouped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = entries.fold<double>(0, (sum, e) => sum + e.billedAmount);
    final tax = subtotal * gstRate / 100;
    final invoiceTotal = subtotal + tax;

    // Determine primary client (most entries or alphabetically first)
    final primaryClient = grouped.isNotEmpty ? grouped.keys.first : 'Client';

    final formattedTotal = invoiceTotal >= 100000
        ? '₹${(invoiceTotal / 100000).toStringAsFixed(1)}L'
        : invoiceTotal >= 1000
        ? '₹${(invoiceTotal / 1000).toStringAsFixed(1)}K'
        : '₹${invoiceTotal.toStringAsFixed(0)}';

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _createInvoice(context, ref, formattedTotal, primaryClient),
        icon: const Icon(Icons.receipt_long_rounded),
        label: const Text('Create Invoice'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _createInvoice(
    BuildContext context,
    WidgetRef ref,
    String formattedTotal,
    String clientName,
  ) {
    if (!context.mounted) return;

    final subtotal = entries.fold<double>(0, (sum, e) => sum + e.billedAmount);
    final tax = subtotal * gstRate / 100;
    final invoiceTotal = subtotal + tax;
    final now = DateTime.now();

    // Build line items from time entries grouped by client
    final lineItems = entries.map((e) {
      final hours = e.durationMinutes / 60.0;
      final entryGst = e.billedAmount * gstRate / 100;
      return LineItem(
        description: '${e.taskDescription} (${hours.toStringAsFixed(1)}h × ₹${e.hourlyRate.toStringAsFixed(0)}/hr)',
        hsn: '998221',
        quantity: hours,
        rate: e.hourlyRate,
        taxableAmount: e.billedAmount,
        gstRate: gstRate,
        cgst: entryGst / 2,
        sgst: entryGst / 2,
        igst: 0,
        total: e.billedAmount + entryGst,
      );
    }).toList();

    // Generate invoice number
    final existingInvoices = ref.read(allInvoicesProvider);
    final nextNumber = existingInvoices.length + 1;
    final invoiceNumber =
        'CAD/2025-26/${nextNumber.toString().padLeft(3, '0')}';

    final newInvoice = Invoice(
      id: 'inv_tt_${now.millisecondsSinceEpoch}',
      invoiceNumber: invoiceNumber,
      clientId: 'tt_${clientName.hashCode}',
      clientName: clientName,
      invoiceDate: now,
      dueDate: now.add(const Duration(days: 30)),
      lineItems: lineItems,
      subtotal: subtotal,
      totalGst: tax,
      grandTotal: invoiceTotal,
      paidAmount: 0,
      balanceDue: invoiceTotal,
      status: InvoiceStatus.draft,
    );

    ref.read(allInvoicesProvider.notifier).addInvoice(newInvoice);

    Navigator.of(context).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice $invoiceNumber ($formattedTotal) created for $clientName',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
