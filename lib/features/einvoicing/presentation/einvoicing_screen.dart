import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/einvoicing_providers.dart';
import '../domain/models/einvoice_record.dart';
import 'widgets/einvoice_tile.dart';
import 'widgets/irn_batch_card.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const double _penaltyPerInvoice = 25000;

const List<String?> _filterOptions = [
  null,
  'Generated',
  'Pending',
  'Overdue',
  'Cancelled',
];

const List<String> _filterLabels = [
  'All',
  'Generated',
  'Pending',
  'Overdue',
  'Cancelled',
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Main screen for the E-Invoicing Compliance Hub module.
///
/// Provides an overview of e-invoice status, compliance urgency, and
/// batch IRN processing jobs for the logged-in CA firm.
class EinvoicingScreen extends ConsumerStatefulWidget {
  const EinvoicingScreen({super.key});

  @override
  ConsumerState<EinvoicingScreen> createState() => _EinvoicingScreenState();
}

class _EinvoicingScreenState extends ConsumerState<EinvoicingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(allEinvoiceRecordsProvider);
    final filteredRecords = ref.watch(filteredEinvoiceRecordsProvider);
    final batches = ref.watch(allIrnBatchesProvider);
    final selectedStatus = ref.watch(selectedInvoiceStatusProvider);

    final overdueRecords = allRecords
        .where((r) => r.daysRemaining < 0)
        .toList();
    final overdueCount = overdueRecords.length;
    final penaltyExposure = overdueCount * _penaltyPerInvoice;

    final generatedCount = allRecords
        .where((r) => r.status == 'Generated')
        .length;
    final pendingCount = allRecords.where((r) => r.status == 'Pending').length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.primary),
        title: const Text(
          'E-Invoicing Hub',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral400,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'E-Invoices'),
                Tab(text: 'Batches'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EinvoicesTab(
            allRecords: allRecords,
            filteredRecords: filteredRecords,
            overdueCount: overdueCount,
            penaltyExposure: penaltyExposure,
            generatedCount: generatedCount,
            pendingCount: pendingCount,
            selectedStatus: selectedStatus,
            onStatusSelected: (status) {
              ref.read(selectedInvoiceStatusProvider.notifier).select(status);
            },
          ),
          _BatchesTab(batches: batches),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// E-Invoices tab
// ---------------------------------------------------------------------------

class _EinvoicesTab extends StatelessWidget {
  const _EinvoicesTab({
    required this.allRecords,
    required this.filteredRecords,
    required this.overdueCount,
    required this.penaltyExposure,
    required this.generatedCount,
    required this.pendingCount,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final List<EinvoiceRecord> allRecords;
  final List<EinvoiceRecord> filteredRecords;
  final int overdueCount;
  final double penaltyExposure;
  final int generatedCount;
  final int pendingCount;
  final String? selectedStatus;
  final void Function(String? status) onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 12),
              if (overdueCount > 0)
                _ComplianceBanner(
                  overdueCount: overdueCount,
                  penaltyExposure: penaltyExposure,
                ),
              const SizedBox(height: 12),
              _SummaryRow(
                total: allRecords.length,
                generated: generatedCount,
                pending: pendingCount,
                overdue: overdueCount,
              ),
              const SizedBox(height: 12),
              _FilterChipRow(
                selectedStatus: selectedStatus,
                onSelected: onStatusSelected,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        if (filteredRecords.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'No invoices match this filter.',
                style: TextStyle(color: AppColors.neutral400),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => EinvoiceTile(record: filteredRecords[index]),
              childCount: filteredRecords.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Batches tab
// ---------------------------------------------------------------------------

class _BatchesTab extends StatelessWidget {
  const _BatchesTab({required this.batches});

  final List<dynamic> batches;

  @override
  Widget build(BuildContext context) {
    if (batches.isEmpty) {
      return const Center(
        child: Text(
          'No batches found.',
          style: TextStyle(color: AppColors.neutral400),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: batches.length,
      itemBuilder: (context, index) => IrnBatchCard(batch: batches[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Compliance banner
// ---------------------------------------------------------------------------

class _ComplianceBanner extends StatelessWidget {
  const _ComplianceBanner({
    required this.overdueCount,
    required this.penaltyExposure,
  });

  final int overdueCount;
  final double penaltyExposure;

  String _formatPenalty(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withAlpha(77)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$overdueCount invoice${overdueCount > 1 ? 's' : ''} overdue — '
                    'Action required',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Penalty exposure: ${_formatPenalty(penaltyExposure)} '
                    '(₹25,000/invoice)',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.error.withAlpha(204),
                    ),
                  ),
                ],
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.total,
    required this.generated,
    required this.pending,
    required this.overdue,
  });

  final int total;
  final int generated;
  final int pending;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SummaryItem(
            label: 'Total',
            value: '$total',
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _SummaryItem(
            label: 'Generated',
            value: '$generated',
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _SummaryItem(
            label: 'Pending',
            value: '$pending',
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _SummaryItem(
            label: 'Overdue',
            value: '$overdue',
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip row
// ---------------------------------------------------------------------------

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.selectedStatus,
    required this.onSelected,
  });

  final String? selectedStatus;
  final void Function(String? status) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        separatorBuilder: (_, separatorIndex) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final label = _filterLabels[index];
          final isSelected = selectedStatus == option;

          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.neutral300,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.surface : AppColors.neutral600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
