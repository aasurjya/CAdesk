import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/cma_providers.dart';
import '../domain/models/cma_report.dart';
import 'widgets/cma_report_tile.dart';
import 'widgets/loan_summary_card.dart';

// ---------------------------------------------------------------------------
// Tab definitions
// ---------------------------------------------------------------------------

enum _CmaTab { reports, loanCalculator }

class CmaScreen extends ConsumerStatefulWidget {
  const CmaScreen({super.key});

  @override
  ConsumerState<CmaScreen> createState() => _CmaScreenState();
}

class _CmaScreenState extends ConsumerState<CmaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _CmaTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(cmaSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('CMA / Financial Projections'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'CMA Reports'),
            Tab(text: 'Loan Calculator'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary strip
          _SummaryStrip(summary: summary),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _CmaReportsTab(),
                _LoanCalculatorTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cma_fab',
        onPressed: () => _showNewCmaSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New CMA'),
      ),
    );
  }

  void _showNewCmaSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NewCmaSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary strip
// ---------------------------------------------------------------------------

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final CmaSummary summary;

  String _crore(double v) => '₹${(v / 10000000).toStringAsFixed(1)}Cr';

  @override
  Widget build(BuildContext context) {
    final emiFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _SummaryCell(
            label: 'Reports',
            value: summary.totalReports.toString(),
            icon: Icons.description_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _SummaryCell(
            label: 'Pending',
            value: summary.pendingReports.toString(),
            icon: Icons.hourglass_empty_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _SummaryCell(
            label: 'Requested',
            value: _crore(summary.totalRequested),
            icon: Icons.request_page_rounded,
            color: AppColors.primaryVariant,
          ),
          const SizedBox(width: 8),
          _SummaryCell(
            label: 'EMI/mo',
            value: emiFormat.format(summary.totalMonthlyEmi),
            icon: Icons.payments_rounded,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CMA Reports tab
// ---------------------------------------------------------------------------

class _CmaReportsTab extends ConsumerWidget {
  const _CmaReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(cmaFilteredReportsProvider);
    final filter = ref.watch(cmaStatusFilterProvider);

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: filter == null,
                onTap: () =>
                    ref.read(cmaStatusFilterProvider.notifier).update(null),
              ),
              const SizedBox(width: 8),
              ...CmaReportStatus.values.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: s.label,
                      selected: filter == s,
                      color: s.color,
                      onTap: () => ref
                          .read(cmaStatusFilterProvider.notifier)
                          .update(s),
                    ),
                  )),
            ],
          ),
        ),

        Expanded(
          child: reports.isEmpty
              ? const _EmptyState(message: 'No CMA reports found')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: reports.length,
                  itemBuilder: (context, index) =>
                      CmaReportTile(report: reports[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loan Calculator tab
// ---------------------------------------------------------------------------

class _LoanCalculatorTab extends ConsumerWidget {
  const _LoanCalculatorTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(loanCalculatorsProvider);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: loans.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _BankwiseSummaryCard(loans: loans);
        return LoanSummaryCard(loan: loans[index - 1]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Bank-wise summary card (top of loan tab)
// ---------------------------------------------------------------------------

class _BankwiseSummaryCard extends StatelessWidget {
  const _BankwiseSummaryCard({required this.loans});

  final List<dynamic> loans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Aggregate totals
    double totalPrincipal = 0;
    double totalEmi = 0;
    double totalInterest = 0;
    for (final l in loans) {
      totalPrincipal += (l.loanAmount as double);
      totalEmi += (l.emi as double);
      totalInterest += (l.totalInterest as double);
    }

    String crore(double v) => '₹${(v / 10000000).toStringAsFixed(2)} Cr';

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Summary',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PortfolioMetric(
                  label: 'Total Principal',
                  value: crore(totalPrincipal),
                ),
                _PortfolioMetric(
                  label: 'Total Interest',
                  value: crore(totalInterest),
                ),
                _PortfolioMetric(
                  label: 'Monthly EMI',
                  value: '₹${(totalEmi / 100000).toStringAsFixed(1)}L',
                ),
                _PortfolioMetric(
                  label: 'Active Loans',
                  value: loans.length.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioMetric extends StatelessWidget {
  const _PortfolioMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final String label;
  final bool selected;
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
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.neutral200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.neutral600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 48,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.neutral400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New CMA bottom sheet
// ---------------------------------------------------------------------------

class _NewCmaSheet extends ConsumerStatefulWidget {
  const _NewCmaSheet();

  @override
  ConsumerState<_NewCmaSheet> createState() => _NewCmaSheetState();
}

class _NewCmaSheetState extends ConsumerState<_NewCmaSheet> {
  final _banks = [
    'State Bank of India',
    'HDFC Bank',
    'Axis Bank',
    'Punjab National Bank',
    'ICICI Bank',
    'Bank of Baroda',
  ];

  String? _selectedBank;
  int _projYears = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 16),
          Text(
            'Prepare New CMA Report',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedBank,
            decoration: const InputDecoration(
              labelText: 'Bank Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_rounded),
            ),
            items: _banks
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() => _selectedBank = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Projection Years:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral600,
                ),
              ),
              const Spacer(),
              ...[3, 5, 7].map((y) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text('$y Y'),
                      selected: _projYears == y,
                      onSelected: (_) => setState(() => _projYears = y),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _projYears == y
                            ? Colors.white
                            : AppColors.neutral600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _selectedBank == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'CMA report initiated for $_selectedBank '
                          '($_projYears year projection)',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            icon: const Icon(Icons.description_rounded),
            label: const Text('Create CMA Report'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
