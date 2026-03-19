import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/core/widgets/widgets.dart';
import '../data/providers/einvoice_form_providers.dart';
import '../data/providers/einvoicing_providers.dart';
import '../domain/models/einvoice_record.dart';
import 'widgets/einvoice_line_item_card.dart';
import 'widgets/einvoice_status_timeline.dart';

// ---------------------------------------------------------------------------
// Mock line items for detail view
// ---------------------------------------------------------------------------

const _mockLineItems = <EinvoiceLineItem>[
  EinvoiceLineItem(
    id: 'li-001',
    hsnCode: '84713010',
    description: 'Laptop Computer - Dell Latitude 5540',
    quantity: 25,
    unit: 'NOS',
    rate: 45000,
    discount: 12500,
    taxableValue: 1112500,
    cgstRate: 9,
    sgstRate: 9,
    cgstAmount: 100125,
    sgstAmount: 100125,
    igstAmount: 0,
  ),
  EinvoiceLineItem(
    id: 'li-002',
    hsnCode: '85176290',
    description: 'Wireless Mouse + Keyboard Combo',
    quantity: 50,
    unit: 'NOS',
    rate: 2500,
    discount: 0,
    taxableValue: 125000,
    cgstRate: 9,
    sgstRate: 9,
    cgstAmount: 11250,
    sgstAmount: 11250,
    igstAmount: 0,
  ),
  EinvoiceLineItem(
    id: 'li-003',
    hsnCode: '99831',
    description: 'Annual Software License - MS Office 365',
    quantity: 25,
    unit: 'NOS',
    rate: 5200,
    discount: 5000,
    taxableValue: 125000,
    igstRate: 18,
    cgstRate: 0,
    sgstRate: 0,
    cgstAmount: 0,
    sgstAmount: 0,
    igstAmount: 22500,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Detail view for a single e-invoice record.
///
/// Shows invoice header, buyer/seller details, line items, totals,
/// IRN details, status timeline, and action buttons.
class EinvoiceDetailScreen extends ConsumerWidget {
  const EinvoiceDetailScreen({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRecords = ref.watch(allEinvoiceRecordsProvider);
    final record = allRecords.where((r) => r.id == invoiceId).firstOrNull;

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Not Found')),
        body: const EmptyState(
          message: 'Invoice not found',
          subtitle: 'The requested invoice could not be located.',
          icon: Icons.search_off_rounded,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          record.invoiceNumber,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'json', child: Text('Download JSON')),
              PopupMenuItem(value: 'print', child: Text('Print Invoice')),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Status timeline
                EinvoiceStatusTimeline(
                  status: record.status,
                  createdDate: record.invoiceDate,
                  validatedDate: record.status != 'Pending'
                      ? record.invoiceDate
                      : null,
                  irnGeneratedDate: record.status == 'Generated'
                      ? record.invoiceDate
                      : null,
                  cancelledDate: record.status == 'Cancelled'
                      ? record.invoiceDate
                      : null,
                ),
                const SizedBox(height: 12),
                // Invoice header
                _InvoiceHeaderCard(record: record),
                const SizedBox(height: 8),
                // Buyer / Seller
                _PartyDetailsCard(record: record),
                const SizedBox(height: 8),
                // IRN details
                if (record.status == 'Generated' ||
                    record.status == 'Cancelled')
                  _IrnDetailsCard(record: record),
                // Section: Line Items
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SectionHeader(
                    title: 'Line Items',
                    icon: Icons.list_alt_rounded,
                    trailing: Text(
                      '${_mockLineItems.length} items',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Line items list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => EinvoiceLineItemCard(
                item: _mockLineItems[index],
                readOnly: true,
              ),
              childCount: _mockLineItems.length,
            ),
          ),
          // Totals
          const SliverToBoxAdapter(
            child: _TotalsCard(lineItems: _mockLineItems),
          ),
          // Action buttons
          SliverToBoxAdapter(child: _ActionButtons(record: record)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    final message = action == 'json'
        ? 'JSON download started'
        : 'Preparing print preview...';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice header card
// ---------------------------------------------------------------------------

class _InvoiceHeaderCard extends StatelessWidget {
  const _InvoiceHeaderCard({required this.record});

  final EinvoiceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  record.invoiceNumber,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                StatusBadge(
                  label: record.status,
                  color: _statusColor(record.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _DetailRow(label: 'Date', value: record.invoiceDate),
            const _DetailRow(label: 'Type', value: 'Tax Invoice'),
            _DetailRow(
              label: 'Value',
              value: CurrencyUtils.formatINR(record.invoiceValue),
            ),
            _DetailRow(
              label: 'GST',
              value: CurrencyUtils.formatINR(record.gstAmount),
            ),
            _DetailRow(
              label: 'Window',
              value: '${record.windowType} compliance window',
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Generated':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.neutral400;
      case 'Overdue':
        return AppColors.error;
      case 'Pending':
      default:
        return AppColors.warning;
    }
  }
}

// ---------------------------------------------------------------------------
// Party details card
// ---------------------------------------------------------------------------

class _PartyDetailsCard extends StatelessWidget {
  const _PartyDetailsCard({required this.record});

  final EinvoiceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parties',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            _PartyRow(
              role: 'Seller',
              name: record.clientName,
              gstin: '27AABCT1234A1ZV',
              address: 'Mumbai, Maharashtra',
            ),
            const Divider(height: 16),
            _PartyRow(
              role: 'Buyer',
              name: record.buyerName,
              gstin: '29AABCI5678B1ZW',
              address: 'Bengaluru, Karnataka',
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({
    required this.role,
    required this.name,
    required this.gstin,
    required this.address,
  });

  final String role;
  final String name;
  final String gstin;
  final String address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(13),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            role,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                gstin,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                address,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// IRN details card
// ---------------------------------------------------------------------------

class _IrnDetailsCard extends StatelessWidget {
  const _IrnDetailsCard({required this.record});

  final EinvoiceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.success.withAlpha(77)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.fingerprint_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'IRN Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _DetailRow(label: 'IRN', value: record.irn, mono: true),
            _DetailRow(label: 'Generated', value: record.invoiceDate),
            if (record.qrGenerated)
              Row(
                children: [
                  const SizedBox(width: 60),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'QR Code Generated',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
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
// Totals card
// ---------------------------------------------------------------------------

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.lineItems});

  final List<EinvoiceLineItem> lineItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subTotal = lineItems.fold(
      0.0,
      (sum, item) => sum + item.taxableValue,
    );
    final totalTax = lineItems.fold(
      0.0,
      (sum, item) => sum + item.cgstAmount + item.sgstAmount + item.igstAmount,
    );
    final grandTotal = subTotal + totalTax;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _TotalRow(
              label: 'Sub-Total',
              value: CurrencyUtils.formatINR(subTotal),
              theme: theme,
            ),
            _TotalRow(
              label: 'Total Tax',
              value: CurrencyUtils.formatINR(totalTax),
              theme: theme,
            ),
            const Divider(height: 16),
            _TotalRow(
              label: 'Grand Total',
              value: CurrencyUtils.formatINR(grandTotal),
              theme: theme,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.theme,
    this.bold = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: bold ? AppColors.neutral900 : AppColors.neutral600,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: bold ? AppColors.primary : AppColors.neutral900,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 15 : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.record});

  final EinvoiceRecord record;

  @override
  Widget build(BuildContext context) {
    final isPending = record.status == 'Pending' || record.status == 'Overdue';
    final isGenerated = record.status == 'Generated';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPending)
            FilledButton.icon(
              onPressed: () => _showSnackBar(context, 'Generating IRN...'),
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Generate IRN'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          if (isGenerated) ...[
            OutlinedButton.icon(
              onPressed: () =>
                  _showSnackBar(context, 'Cancel IRN request submitted.'),
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              label: const Text(
                'Cancel IRN',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
                fontFamily: mono ? 'monospace' : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
