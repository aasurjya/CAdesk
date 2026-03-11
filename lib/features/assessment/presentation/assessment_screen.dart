import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../data/providers/assessment_providers.dart';
import '../domain/models/assessment_order.dart';
import 'widgets/assessment_detail_sheet.dart';
import 'widgets/assessment_order_tile.dart';
import 'widgets/interest_calculation_tile.dart';

/// Main screen for Module 6: Assessment Order Checker.
class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen>
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

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(assessmentSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Assessment Order Checker'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Interest Checks'),
          ],
        ),
      ),
      body: Column(
        children: [
          _ErrorSummaryBanner(summary: summary),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _OrdersTab(),
                _InterestTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error summary banner
// ---------------------------------------------------------------------------

class _ErrorSummaryBanner extends StatelessWidget {
  const _ErrorSummaryBanner({required this.summary});

  final AssessmentSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Order Errors',
            value: summary.ordersWithErrors.toString(),
            icon: Icons.error_outline_rounded,
            color: summary.ordersWithErrors > 0
                ? AppColors.error
                : AppColors.success,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Pending',
            value: summary.pendingVerification.toString(),
            icon: Icons.hourglass_empty_rounded,
            color: summary.pendingVerification > 0
                ? AppColors.warning
                : AppColors.success,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Int. Errors',
            value: summary.interestErrors.toString(),
            icon: Icons.calculate_rounded,
            color: summary.interestErrors > 0
                ? AppColors.error
                : AppColors.success,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Total Demand',
            value: CurrencyUtils.formatINRCompact(summary.totalDemand),
            icon: Icons.account_balance_rounded,
            color: summary.totalDemand > 0
                ? AppColors.warning
                : AppColors.success,
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withValues(alpha: 0.25)),
        ),
        color: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
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
// Orders tab
// ---------------------------------------------------------------------------

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionFilter = ref.watch(assessmentSectionFilterProvider);
    final statusFilter = ref.watch(assessmentStatusFilterProvider);
    final orders = ref.watch(filteredOrdersProvider);
    final allOrders = ref.watch(assessmentOrdersProvider);

    final currentAY = 'AY 2023-24';
    final ordersThisAY =
        allOrders.where((o) => o.assessmentYear == currentAY).length;
    final totalDemand = allOrders.fold<double>(
      0,
      (sum, o) => sum + o.demandAmount,
    );
    // Orders with zero demand and zero tax assessed are treated as refund orders.
    final totalRefundPending = allOrders
        .where((o) => o.demandAmount == 0 && o.taxAssessed > 0)
        .length;

    return Column(
      children: [
        _AySummaryCard(
          totalDemand: totalDemand,
          totalRefundPending: totalRefundPending,
          ordersThisAY: ordersThisAY,
          currentAY: currentAY,
        ),
        _OrderFilterRow(
          sectionFilter: sectionFilter,
          statusFilter: statusFilter,
          onSectionChanged: (v) =>
              ref.read(assessmentSectionFilterProvider.notifier).update(v),
          onStatusChanged: (v) =>
              ref.read(assessmentStatusFilterProvider.notifier).update(v),
        ),
        Expanded(
          child: orders.isEmpty
              ? _buildEmpty(context, 'No orders found')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => AssessmentOrderTile(
                    order: orders[i],
                    onTap: () => AssessmentDetailSheet.show(
                      context,
                      orders[i],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AY summary header card
// ---------------------------------------------------------------------------

class _AySummaryCard extends StatelessWidget {
  const _AySummaryCard({
    required this.totalDemand,
    required this.totalRefundPending,
    required this.ordersThisAY,
    required this.currentAY,
  });

  final double totalDemand;
  final int totalRefundPending;
  final int ordersThisAY;
  final String currentAY;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primaryVariant.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _AyStat(
                theme: theme,
                icon: Icons.warning_amber_rounded,
                label: 'Demand Outstanding',
                value: CurrencyUtils.formatINRCompact(totalDemand),
                color: AppColors.error,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.neutral200,
            ),
            Expanded(
              child: _AyStat(
                theme: theme,
                icon: Icons.savings_rounded,
                label: 'Refunds Pending',
                value: totalRefundPending.toString(),
                color: AppColors.success,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.neutral200,
            ),
            Expanded(
              child: _AyStat(
                theme: theme,
                icon: Icons.folder_open_rounded,
                label: 'Orders ($currentAY)',
                value: ordersThisAY.toString(),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyStat extends StatelessWidget {
  const _AyStat({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interest checks tab
// ---------------------------------------------------------------------------

class _InterestTab extends ConsumerWidget {
  const _InterestTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcs = ref.watch(interestCalculationsProvider);

    if (calcs.isEmpty) {
      return _buildEmpty(context, 'No interest calculations found');
    }

    // Sort: incorrect ones first for immediate attention.
    final sorted = [...calcs]..sort((a, b) {
        if (a.isCorrect == b.isCorrect) return 0;
        return a.isCorrect ? 1 : -1;
      });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: sorted.length,
      itemBuilder: (_, i) => InterestCalculationTile(calc: sorted[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter row for orders
// ---------------------------------------------------------------------------

class _OrderFilterRow extends StatelessWidget {
  const _OrderFilterRow({
    required this.sectionFilter,
    required this.statusFilter,
    required this.onSectionChanged,
    required this.onStatusChanged,
  });

  final AssessmentSection? sectionFilter;
  final VerificationStatus? statusFilter;
  final ValueChanged<AssessmentSection?> onSectionChanged;
  final ValueChanged<VerificationStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(
              context,
              label: 'All',
              isSelected: sectionFilter == null && statusFilter == null,
              onTap: () {
                onSectionChanged(null);
                onStatusChanged(null);
              },
            ),
            const SizedBox(width: 6),
            ...AssessmentSection.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  context,
                  label: 'Sec ${s.label}',
                  isSelected: sectionFilter == s,
                  onTap: () =>
                      onSectionChanged(sectionFilter == s ? null : s),
                ),
              ),
            ),
            ...VerificationStatus.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  context,
                  label: s.label,
                  isSelected: statusFilter == s,
                  onTap: () =>
                      onStatusChanged(statusFilter == s ? null : s),
                ),
              ),
            ),
          ],
        ),
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
// Shared empty state
// ---------------------------------------------------------------------------

Widget _buildEmpty(BuildContext context, String message) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_rounded, size: 64, color: AppColors.neutral400),
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
