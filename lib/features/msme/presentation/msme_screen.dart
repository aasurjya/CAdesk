import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/msme/data/providers/msme_providers.dart';
import 'package:ca_app/features/msme/domain/models/msme_vendor.dart';
import 'package:ca_app/features/msme/domain/models/msme_payment.dart';
import 'package:ca_app/features/msme/presentation/widgets/msme_payment_tile.dart';
import 'package:ca_app/features/msme/presentation/widgets/msme_summary_card.dart';
import 'package:ca_app/features/msme/presentation/widgets/msme_vendor_tile.dart';
import 'package:ca_app/features/msme/presentation/widgets/payment_tracker_sheet.dart';
import 'package:ca_app/features/msme/presentation/widgets/section_43bh_alert.dart';

/// Main screen for Module 29: MSME Compliance.
class MsmeScreen extends ConsumerWidget {
  const MsmeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MSME Compliance'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Vendors'),
              Tab(text: 'Payments'),
              Tab(text: '43B(h) Alerts'),
            ],
          ),
        ),
        body: Column(
          children: [
            _SummaryRow(),
            MsmeSummaryCard(
              onViewDetails: () {
                DefaultTabController.of(context).animateTo(2);
              },
            ),
            const Expanded(
              child: TabBarView(
                children: [_VendorsTab(), _PaymentsTab(), _AlertsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends ConsumerWidget {
  static final _currencyFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 1,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(msmeSummaryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Vendors',
            value: summary.totalVendors.toString(),
            icon: Icons.business,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Outstanding',
            value: _currencyFormat.format(summary.totalOutstanding),
            icon: Icons.account_balance_wallet,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'At Risk',
            value: summary.atRiskDeductions.toString(),
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Overdue',
            value: summary.overduePayments.toString(),
            icon: Icons.schedule,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vendors tab
// ---------------------------------------------------------------------------

class _VendorsTab extends ConsumerWidget {
  const _VendorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClassification = ref.watch(msmeClassificationFilterProvider);
    final vendors = ref.watch(filteredMsmeVendorsProvider);

    return Column(
      children: [
        _ClassificationChips(
          selected: selectedClassification,
          onSelected: (value) {
            ref.read(msmeClassificationFilterProvider.notifier).update(value);
          },
        ),
        Expanded(
          child: vendors.isEmpty
              ? _buildEmpty(context, 'No vendors found')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: vendors.length,
                  itemBuilder: (ctx, index) {
                    final vendor = vendors[index];
                    return MsmeVendorTile(
                      vendor: vendor,
                      onTap: () => showPaymentTrackerSheet(
                        ctx,
                        vendor.clientId,
                        _clientName(vendor.clientId),
                      ),
                    );
                  },
                ),
        ),
      ],
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
    final selectedStatus = ref.watch(msmePaymentStatusFilterProvider);
    final payments = ref.watch(filteredMsmePaymentsProvider);

    return Column(
      children: [
        _PaymentStatusChips(
          selected: selectedStatus,
          onSelected: (value) {
            ref.read(msmePaymentStatusFilterProvider.notifier).update(value);
          },
        ),
        Expanded(
          child: payments.isEmpty
              ? _buildEmpty(context, 'No payments found')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: payments.length,
                  itemBuilder: (_, index) =>
                      MsmePaymentTile(payment: payments[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 43B(h) alerts tab
// ---------------------------------------------------------------------------

class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(section43BhAlertsProvider);

    if (alerts.isEmpty) {
      return _buildEmpty(context, 'No 43B(h) risks detected');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: alerts.length,
      itemBuilder: (ctx, index) {
        final vendor = alerts[index];
        return Section43BhAlert(
          vendor: vendor,
          onTap: () => showPaymentTrackerSheet(
            ctx,
            vendor.clientId,
            _clientName(vendor.clientId),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip rows
// ---------------------------------------------------------------------------

class _ClassificationChips extends StatelessWidget {
  const _ClassificationChips({
    required this.selected,
    required this.onSelected,
  });

  final MsmeClassification? selected;
  final ValueChanged<MsmeClassification?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('All', selected == null, () => onSelected(null)),
            ...MsmeClassification.values.map(
              (c) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _chip(
                  c.label,
                  selected == c,
                  () => onSelected(selected == c ? null : c),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.secondary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.secondary : AppColors.neutral600,
      ),
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PaymentStatusChips extends StatelessWidget {
  const _PaymentStatusChips({required this.selected, required this.onSelected});

  final MsmePaymentStatus? selected;
  final ValueChanged<MsmePaymentStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('All', selected == null, () => onSelected(null)),
            ...MsmePaymentStatus.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _chip(
                  s.label,
                  selected == s,
                  () => onSelected(selected == s ? null : s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.secondary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.secondary : AppColors.neutral600,
      ),
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

// ---------------------------------------------------------------------------
// Client name lookup
// ---------------------------------------------------------------------------

/// Returns a display name for a known client ID.
/// In production this would come from a clients provider.
String _clientName(String clientId) {
  const names = <String, String>{
    'c1': 'Arjun Enterprises Pvt Ltd',
    'c2': 'Sunrise Industries Ltd',
    'c3': 'Deccan Traders Co',
    'c4': 'Northern Metals Pvt Ltd',
    'c5': 'Sagar Technologies',
  };
  return names[clientId] ?? clientId;
}

// ---------------------------------------------------------------------------
// Shared empty state
// ---------------------------------------------------------------------------

Widget _buildEmpty(BuildContext context, String message) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 64, color: AppColors.neutral400),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.neutral400),
        ),
      ],
    ),
  );
}
