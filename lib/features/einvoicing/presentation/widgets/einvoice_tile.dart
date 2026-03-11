import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/einvoice_record.dart';

/// List tile that renders a single [EinvoiceRecord] in the E-Invoices tab.
///
/// Displays invoice identity, compliance window badge, countdown urgency,
/// financial figures, status chip, QR indicator, and truncated IRN.
class EinvoiceTile extends StatelessWidget {
  const EinvoiceTile({super.key, required this.record});

  final EinvoiceRecord record;

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Color _windowColor() {
    return record.windowType == '3-day'
        ? AppColors.error
        : AppColors.warning;
  }

  Color _daysColor() {
    if (record.daysRemaining < 0) {
      return AppColors.error;
    }
    if (record.daysRemaining <= 7) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  String _daysLabel() {
    final days = record.daysRemaining;
    if (days < 0) {
      return '${days.abs()}d overdue';
    }
    if (days == 0) {
      return 'Due today';
    }
    return '${days}d left';
  }

  Color _statusColor() {
    switch (record.status) {
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

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    }
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _truncatedIrn() {
    if (record.irn.length <= 8) {
      return record.irn;
    }
    return '${record.irn.substring(0, 8)}...';
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(textTheme),
            const SizedBox(height: 6),
            _buildBuyerRow(textTheme),
            const SizedBox(height: 8),
            _buildFinancialRow(textTheme),
            const SizedBox(height: 8),
            _buildFooterRow(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.invoiceNumber,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                record.clientName,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _WindowBadge(windowType: record.windowType, color: _windowColor()),
        const SizedBox(width: 6),
        _DaysChip(label: _daysLabel(), color: _daysColor()),
      ],
    );
  }

  Widget _buildBuyerRow(TextTheme textTheme) {
    return Row(
      children: [
        const Icon(Icons.business_outlined, size: 13, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            record.buyerName,
            style: textTheme.bodySmall?.copyWith(color: AppColors.neutral600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          record.invoiceDate,
          style: textTheme.labelSmall?.copyWith(color: AppColors.neutral400),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(TextTheme textTheme) {
    return Row(
      children: [
        _FinancialItem(
          label: 'Value',
          value: _formatCurrency(record.invoiceValue),
          textTheme: textTheme,
        ),
        const SizedBox(width: 16),
        _FinancialItem(
          label: 'GST',
          value: _formatCurrency(record.gstAmount),
          textTheme: textTheme,
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.fingerprint_rounded, size: 13, color: AppColors.neutral400),
            const SizedBox(width: 3),
            Text(
              _truncatedIrn(),
              style: textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterRow(TextTheme textTheme) {
    return Row(
      children: [
        _StatusChip(label: record.status, color: _statusColor()),
        const Spacer(),
        if (record.qrGenerated) ...[
          const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'QR',
            style: textTheme.labelSmall?.copyWith(color: AppColors.success),
          ),
        ] else ...[
          Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.neutral300),
          const SizedBox(width: 4),
          Text(
            'No QR',
            style: textTheme.labelSmall?.copyWith(color: AppColors.neutral300),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _WindowBadge extends StatelessWidget {
  const _WindowBadge({required this.windowType, required this.color});

  final String windowType;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        windowType,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _DaysChip extends StatelessWidget {
  const _DaysChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  const _FinancialItem({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: AppColors.neutral400),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
