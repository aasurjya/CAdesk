import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

// ---------------------------------------------------------------------------
// Demand status model
// ---------------------------------------------------------------------------

enum _DemandStatus {
  outstanding('Outstanding', AppColors.error, Icons.warning_rounded),
  partiallyPaid('Partially Paid', AppColors.warning, Icons.pie_chart_rounded),
  underDispute('Under Dispute', AppColors.primaryVariant, Icons.gavel_rounded),
  resolved('Resolved', AppColors.success, Icons.check_circle_rounded);

  const _DemandStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

class _DemandRecord {
  const _DemandRecord({
    required this.id,
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.section,
    required this.demandAmount,
    required this.paidAmount,
    required this.status,
    required this.demandDate,
    required this.dueDate,
    required this.communications,
  });

  final String id;
  final String clientName;
  final String pan;
  final String assessmentYear;
  final String section;
  final double demandAmount;
  final double paidAmount;
  final _DemandStatus status;
  final DateTime demandDate;
  final DateTime dueDate;
  final List<_Communication> communications;

  double get outstandingAmount => demandAmount - paidAmount;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

class _Communication {
  const _Communication({
    required this.date,
    required this.type,
    required this.description,
  });

  final DateTime date;
  final String type;
  final String description;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final List<_DemandRecord> _mockDemands = [
  _DemandRecord(
    id: 'dem-001',
    clientName: 'Mehta Textiles Pvt Ltd',
    pan: 'AABCM4521F',
    assessmentYear: 'AY 2022-23',
    section: 'Section 143(3)',
    demandAmount: 1850000,
    paidAmount: 500000,
    status: _DemandStatus.partiallyPaid,
    demandDate: DateTime(2025, 1, 15),
    dueDate: DateTime(2026, 4, 15),
    communications: [
      _Communication(
        date: DateTime(2025, 1, 15),
        type: 'Demand Notice',
        description: 'Intimation u/s 143(3) received',
      ),
      _Communication(
        date: DateTime(2025, 2, 10),
        type: 'Response',
        description: 'Rectification request filed u/s 154',
      ),
      _Communication(
        date: DateTime(2025, 3, 5),
        type: 'Part Payment',
        description: 'Part payment of 5,00,000 made via challan',
      ),
    ],
  ),
  _DemandRecord(
    id: 'dem-002',
    clientName: 'Gupta Steel Industries',
    pan: 'AACPG8901G',
    assessmentYear: 'AY 2021-22',
    section: 'Section 147',
    demandAmount: 3400000,
    paidAmount: 0,
    status: _DemandStatus.underDispute,
    demandDate: DateTime(2024, 9, 20),
    dueDate: DateTime(2026, 3, 31),
    communications: [
      _Communication(
        date: DateTime(2024, 9, 20),
        type: 'Demand Notice',
        description: 'Reassessment order demand received',
      ),
      _Communication(
        date: DateTime(2024, 10, 15),
        type: 'Appeal Filed',
        description: 'Appeal filed before CIT(A)',
      ),
      _Communication(
        date: DateTime(2025, 1, 20),
        type: 'Stay Granted',
        description: 'Stay on demand granted pending appeal',
      ),
    ],
  ),
  _DemandRecord(
    id: 'dem-003',
    clientName: 'Patel & Sons HUF',
    pan: 'AAFPH6543H',
    assessmentYear: 'AY 2022-23',
    section: 'Section 143(3)',
    demandAmount: 620000,
    paidAmount: 620000,
    status: _DemandStatus.resolved,
    demandDate: DateTime(2025, 1, 18),
    dueDate: DateTime(2025, 3, 18),
    communications: [
      _Communication(
        date: DateTime(2025, 1, 18),
        type: 'Demand Notice',
        description: 'Scrutiny demand raised',
      ),
      _Communication(
        date: DateTime(2025, 2, 5),
        type: 'Payment',
        description: 'Full payment made under protest',
      ),
      _Communication(
        date: DateTime(2025, 3, 1),
        type: 'Receipt',
        description: 'Payment acknowledged by CPC',
      ),
    ],
  ),
  _DemandRecord(
    id: 'dem-004',
    clientName: 'Banerjee Exports LLP',
    pan: 'AABCB3456L',
    assessmentYear: 'AY 2022-23',
    section: 'Section 153A',
    demandAmount: 4800000,
    paidAmount: 0,
    status: _DemandStatus.outstanding,
    demandDate: DateTime(2024, 11, 30),
    dueDate: DateTime(2026, 5, 30),
    communications: [
      _Communication(
        date: DateTime(2024, 11, 30),
        type: 'Demand Notice',
        description: 'Post-search assessment demand',
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _demandFilterProvider =
    NotifierProvider<_DemandFilterNotifier, _DemandStatus?>(
      _DemandFilterNotifier.new,
    );

class _DemandFilterNotifier extends Notifier<_DemandStatus?> {
  @override
  _DemandStatus? build() => null;

  void update(_DemandStatus? value) => state = value;
}

final _filteredDemandsProvider = Provider<List<_DemandRecord>>((ref) {
  final filter = ref.watch(_demandFilterProvider);
  if (filter == null) return _mockDemands;
  return _mockDemands.where((d) => d.status == filter).toList();
});

/// Demand tracker screen for post-filing tax demands.
///
/// Route: `/post-filing/demands`
class DemandTrackerScreen extends ConsumerWidget {
  const DemandTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demands = ref.watch(_filteredDemandsProvider);
    final filter = ref.watch(_demandFilterProvider);
    final theme = Theme.of(context);

    final totalDemand = _mockDemands.fold<double>(
      0,
      (s, d) => s + d.demandAmount,
    );
    final totalPaid = _mockDemands.fold<double>(0, (s, d) => s + d.paidAmount);
    final totalOutstanding = totalDemand - totalPaid;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demand Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Monitor outstanding tax demands',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary row
            _SummaryRow(
              totalDemand: totalDemand,
              totalPaid: totalPaid,
              totalOutstanding: totalOutstanding,
            ),
            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: filter == null,
                    onTap: () =>
                        ref.read(_demandFilterProvider.notifier).update(null),
                  ),
                  ..._DemandStatus.values.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _FilterChip(
                        label: s.label,
                        isSelected: filter == s,
                        color: s.color,
                        onTap: () =>
                            ref.read(_demandFilterProvider.notifier).update(s),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Demand cards
            if (demands.isEmpty)
              _EmptyState()
            else
              ...demands.map(
                (demand) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DemandCard(demand: demand),
                ),
              ),
            const SizedBox(height: 24),
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
    required this.totalDemand,
    required this.totalPaid,
    required this.totalOutstanding,
  });

  final double totalDemand;
  final double totalPaid;
  final double totalOutstanding;

  String _compact(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 0,
    ).format(v);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Total Demand',
            value: '₹${_compact(totalDemand)}',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Paid',
            value: '₹${_compact(totalPaid)}',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Outstanding',
            value: '₹${_compact(totalOutstanding)}',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.neutral200),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.neutral600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Demand card
// ---------------------------------------------------------------------------

class _DemandCard extends StatelessWidget {
  const _DemandCard({required this.demand});

  final _DemandRecord demand;

  String _compact(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    return '₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(v)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: demand.status.color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(demand.status.icon, size: 20, color: demand.status.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    demand.clientName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: demand.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    demand.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: demand.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Info rows
            _SmallRow(label: 'PAN', value: demand.pan),
            _SmallRow(label: 'AY', value: demand.assessmentYear),
            _SmallRow(label: 'Section', value: demand.section),
            const SizedBox(height: 8),

            // Amounts
            Row(
              children: [
                _AmountPill(
                  label: 'Demand',
                  amount: _compact(demand.demandAmount),
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _AmountPill(
                  label: 'Paid',
                  amount: _compact(demand.paidAmount),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _AmountPill(
                  label: 'Balance',
                  amount: _compact(demand.outstandingAmount),
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Communication history
            if (demand.communications.isNotEmpty) ...[
              const Text(
                'Communication History',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 6),
              ...demand.communications.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dateFmt.format(c.date),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          c.type,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmallRow extends StatelessWidget {
  const _SmallRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  const _AmountPill({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              amount,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral300),
            const SizedBox(height: 12),
            Text(
              'No demands match the current filter',
              style: TextStyle(color: AppColors.neutral400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
