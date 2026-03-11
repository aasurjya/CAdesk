import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/billing/data/providers/billing_providers.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/presentation/widgets/invoice_detail_sheet.dart';
import 'package:ca_app/features/billing/presentation/widgets/invoice_tile.dart';
import 'package:ca_app/features/billing/presentation/widgets/new_invoice_sheet.dart';
import 'package:ca_app/features/billing/presentation/widgets/payment_receipt_tile.dart';

/// Module 14 — Billing screen.
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(billingSearchQueryProvider.notifier).update(value);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(billingSearchQueryProvider.notifier).update('');
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(billingSummaryProvider);
    final invoices = ref.watch(allInvoicesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Invoices, collections, and cash visibility',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Invoices'),
                  Tab(text: 'Payments'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const _BillingBanner(),
            _BillingSummaryRow(summary: summary),
            _AgingSummaryCard(invoices: invoices),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search invoices, clients…',
                  hintStyle: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.neutral400,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index != 0) return const SizedBox.shrink();
                return const _InvoiceStatusChips();
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _InvoicesTab(),
                  _PaymentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'billing_fab',
        onPressed: () => NewInvoiceSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Invoice'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _BillingBanner extends StatelessWidget {
  const _BillingBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay on top of collections',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review billed value, outstanding dues, and payment activity from one calmer billing workspace.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillingSummaryRow extends StatelessWidget {
  const _BillingSummaryRow({required this.summary});

  final ({
    double totalBilled,
    double totalCollected,
    double outstanding,
    int overdueCount
  }) summary;

  static final _compact = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _BillingCard(
            label: 'Billed',
            value: _compact.format(summary.totalBilled),
            icon: Icons.receipt_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _BillingCard(
            label: 'Collected',
            value: _compact.format(summary.totalCollected),
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _BillingCard(
            label: 'Outstanding',
            value: _compact.format(summary.outstanding),
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _BillingCard(
            label: 'Overdue',
            value: summary.overdueCount.toString(),
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _BillingCard extends StatelessWidget {
  const _BillingCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.neutral200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 5),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice status filter chips
// ---------------------------------------------------------------------------

class _InvoiceStatusChips extends ConsumerWidget {
  const _InvoiceStatusChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(invoiceStatusFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            context,
            label: 'All',
            isSelected: selected == null,
            onTap: () =>
                ref.read(invoiceStatusFilterProvider.notifier).update(null),
          ),
          ...InvoiceStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _chip(
                  context,
                  label: s.label,
                  isSelected: selected == s,
                  onTap: () => ref
                      .read(invoiceStatusFilterProvider.notifier)
                      .update(selected == s ? null : s),
                ),
              )),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.primary : AppColors.neutral600,
      ),
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

// ---------------------------------------------------------------------------
// Invoices tab
// ---------------------------------------------------------------------------

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(filteredInvoicesProvider);

    if (invoices.isEmpty) {
      return _buildEmpty(context, 'No invoices found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: invoices.length,
      itemBuilder: (_, index) => InvoiceTile(
        invoice: invoices[index],
        onTap: () => InvoiceDetailSheet.show(context, invoices[index]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payments tab
// ---------------------------------------------------------------------------

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(allReceiptsProvider);

    if (receipts.isEmpty) {
      return _buildEmpty(context, 'No payment receipts found');
    }

    // Sort by most recent first.
    final sorted = [...receipts]
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: sorted.length,
      itemBuilder: (_, index) =>
          PaymentReceiptTile(receipt: sorted[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Aging summary card
// ---------------------------------------------------------------------------

class _AgingSummaryCard extends StatelessWidget {
  const _AgingSummaryCard({required this.invoices});

  final List<Invoice> invoices;

  static final _compact = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 1,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    double current = 0;
    double overdue31to60 = 0;
    double overdue61to90 = 0;
    double overdueAbove90 = 0;

    for (final inv in invoices) {
      if (inv.balanceDue <= 0) {
        continue;
      }
      final daysOverdue = now.difference(inv.dueDate).inDays;
      if (daysOverdue <= 0) {
        current += inv.balanceDue;
      } else if (daysOverdue <= 30) {
        current += inv.balanceDue;
      } else if (daysOverdue <= 60) {
        overdue31to60 += inv.balanceDue;
      } else if (daysOverdue <= 90) {
        overdue61to90 += inv.balanceDue;
      } else {
        overdueAbove90 += inv.balanceDue;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aging Summary',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _AgingBucket(
                  label: 'Current\n(0-30d)',
                  value: _compact.format(current),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _AgingBucket(
                  label: 'Overdue\n31-60d',
                  value: _compact.format(overdue31to60),
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _AgingBucket(
                  label: 'Overdue\n61-90d',
                  value: _compact.format(overdue61to90),
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                _AgingBucket(
                  label: 'Overdue\n90d+',
                  value: _compact.format(overdueAbove90),
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgingBucket extends StatelessWidget {
  const _AgingBucket({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: AppColors.neutral400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared empty state
// ---------------------------------------------------------------------------

Widget _buildEmpty(BuildContext context, String message) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.receipt_long_rounded,
          size: 64,
          color: AppColors.neutral200,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.neutral400,
              ),
        ),
      ],
    ),
  );
}
