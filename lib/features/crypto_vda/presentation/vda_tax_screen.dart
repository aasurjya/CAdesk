import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9');
final _dateFmt = DateFormat('dd MMM yyyy');

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum VdaTxnType {
  buy('Buy', AppColors.success, Icons.arrow_downward_rounded),
  sell('Sell', AppColors.error, Icons.arrow_upward_rounded),
  transfer('Transfer', AppColors.warning, Icons.swap_horiz_rounded);

  const VdaTxnType(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class _VdaTransaction {
  const _VdaTransaction({
    required this.asset,
    required this.type,
    required this.date,
    required this.quantity,
    required this.costBasis,
    required this.saleValue,
  });

  final String asset;
  final VdaTxnType type;
  final DateTime date;
  final double quantity;
  final double costBasis;
  final double saleValue;

  double get gain => saleValue - costBasis;
  double get tax => gain > 0 ? gain * 0.30 : 0;
  double get tds194s => saleValue * 0.01;
}

class _MockVdaTax {
  const _MockVdaTax({
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.transactions,
    required this.totalTdsDeducted,
  });

  final String clientName;
  final String pan;
  final String assessmentYear;
  final List<_VdaTransaction> transactions;
  final double totalTdsDeducted;

  double get totalGains =>
      transactions.fold(0.0, (sum, t) => sum + (t.gain > 0 ? t.gain : 0));
  double get totalLosses =>
      transactions.fold(0.0, (sum, t) => sum + (t.gain < 0 ? t.gain.abs() : 0));
  double get taxPayable => totalGains * 0.30;
  double get totalTds194s =>
      transactions.fold(0.0, (sum, t) => sum + t.tds194s);
}

final _mockData = _MockVdaTax(
  clientName: 'Arjun Sharma',
  pan: 'ABCPS1234K',
  assessmentYear: 'AY 2026-27',
  totalTdsDeducted: 42500,
  transactions: [
    _VdaTransaction(
      asset: 'Bitcoin (BTC)',
      type: VdaTxnType.sell,
      date: DateTime(2025, 8, 15),
      quantity: 0.5,
      costBasis: 1200000,
      saleValue: 1850000,
    ),
    _VdaTransaction(
      asset: 'Ethereum (ETH)',
      type: VdaTxnType.sell,
      date: DateTime(2025, 10, 3),
      quantity: 5.0,
      costBasis: 750000,
      saleValue: 620000,
    ),
    _VdaTransaction(
      asset: 'Solana (SOL)',
      type: VdaTxnType.buy,
      date: DateTime(2025, 11, 20),
      quantity: 100,
      costBasis: 450000,
      saleValue: 450000,
    ),
    _VdaTransaction(
      asset: 'Bitcoin (BTC)',
      type: VdaTxnType.transfer,
      date: DateTime(2026, 1, 5),
      quantity: 0.25,
      costBasis: 600000,
      saleValue: 600000,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// VDA (Virtual Digital Asset) tax computation screen.
///
/// Route: `/crypto-vda/tax/:clientId`
class VdaTaxScreen extends ConsumerWidget {
  const VdaTaxScreen({required this.clientId, super.key});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = _mockData;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'VDA Tax — ${data.clientName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TaxSummaryCard(data: data),
            const SizedBox(height: 16),
            _NoLossSetOffBanner(),
            const SizedBox(height: 16),
            _TransactionList(transactions: data.transactions),
            const SizedBox(height: 16),
            _TdsTrackerCard(data: data),
            const SizedBox(height: 16),
            _ScheduleVdaCard(data: data),
            const SizedBox(height: 24),
            _ActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax summary
// ---------------------------------------------------------------------------

class _TaxSummaryCard extends StatelessWidget {
  const _TaxSummaryCard({required this.data});

  final _MockVdaTax data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section 115BBH — Flat 30% Tax',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${data.clientName} | ${data.pan} | ${data.assessmentYear}',
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _AmountBox(
                  label: 'Total Gains',
                  amount: data.totalGains,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _AmountBox(
                  label: 'Total Losses',
                  amount: data.totalLosses,
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _AmountBox(
                  label: 'Tax @ 30%',
                  amount: data.taxPayable,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _AmountBox(
                  label: 'TDS Deducted',
                  amount: data.totalTdsDeducted,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
            const SizedBox(height: 2),
            Text(
              _currencyFmt.format(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// No loss set-off banner
// ---------------------------------------------------------------------------

class _NoLossSetOffBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.error),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'VDA losses cannot be set off against any other income. '
              'Losses also cannot be carried forward to subsequent years.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction list
// ---------------------------------------------------------------------------

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<_VdaTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...transactions.map(
              (txn) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(txn.type.icon, size: 16, color: txn.type.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${txn.asset} — ${txn.type.label}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _dateFmt.format(txn.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _TxnDetail(
                          label: 'Qty',
                          value: txn.quantity.toString(),
                        ),
                        _TxnDetail(
                          label: 'Cost',
                          value: _currencyFmt.format(txn.costBasis),
                        ),
                        _TxnDetail(
                          label: 'Sale',
                          value: _currencyFmt.format(txn.saleValue),
                        ),
                      ],
                    ),
                    if (txn.type == VdaTxnType.sell) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            txn.gain >= 0
                                ? 'Gain: ${_currencyFmt.format(txn.gain)}'
                                : 'Loss: ${_currencyFmt.format(txn.gain.abs())}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: txn.gain >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Tax: ${_currencyFmt.format(txn.tax)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxnDetail extends StatelessWidget {
  const _TxnDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TDS tracker
// ---------------------------------------------------------------------------

class _TdsTrackerCard extends StatelessWidget {
  const _TdsTrackerCard({required this.data});

  final _MockVdaTax data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1% TDS — Section 194S',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Total TDS (194S)',
              value: _currencyFmt.format(data.totalTds194s),
            ),
            _DetailRow(
              label: 'TDS Deducted',
              value: _currencyFmt.format(data.totalTdsDeducted),
            ),
            _DetailRow(
              label: 'TDS Shortfall',
              value: _currencyFmt.format(
                (data.totalTds194s - data.totalTdsDeducted).clamp(
                  0,
                  double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Schedule VDA card
// ---------------------------------------------------------------------------

class _ScheduleVdaCard extends StatelessWidget {
  const _ScheduleVdaCard({required this.data});

  final _MockVdaTax data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.accent.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.table_chart_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule VDA for ITR',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Report all VDA transactions in Schedule VDA of your ITR. '
              'Each transaction must include date of transfer, head of income, '
              'cost of acquisition, and consideration received.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showSnack(context, 'Schedule VDA exported'),
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('Export Schedule VDA'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'PDF computation generated'),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('Download Computation'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryVariant,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
