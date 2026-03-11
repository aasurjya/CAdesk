import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/payroll_providers.dart';
import '../domain/models/employee.dart';
import '../domain/models/payroll_month.dart';
import 'widgets/employee_tile.dart';
import 'widgets/payroll_month_tile.dart';
import 'widgets/payroll_summary_widget.dart';
import 'widgets/payslip_detail_sheet.dart';
import 'widgets/statutory_return_tile.dart';

enum _PayrollTab { employees, monthly, statutory }

class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _PayrollTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickPeriod() async {
    final current = ref.read(payrollSelectedPeriodProvider);
    final initialDate = DateTime(current.year, current.month);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select payroll period',
    );

    if (picked != null) {
      ref.read(payrollSelectedPeriodProvider.notifier).update((
        month: picked.month,
        year: picked.year,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(payrollSummaryProvider);
    final period = ref.watch(payrollSelectedPeriodProvider);
    final periodLabel = DateFormat(
      'MMM yyyy',
    ).format(DateTime(period.year, period.month));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Payroll'),
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
            Tab(text: 'Employees'),
            Tab(text: 'Monthly Payroll'),
            Tab(text: 'Statutory Returns'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Total payroll card
          _TotalPayrollCard(summary: summary),

          // Detailed payroll summary widget
          const PayrollSummaryWidget(),

          // Period selector (shown on Monthly tab logic handled in tab)
          _PeriodSelector(label: periodLabel, onTap: _pickPeriod),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _EmployeesTab(),
                _MonthlyPayrollTab(),
                _StatutoryReturnsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'payroll_fab',
        onPressed: () => _showRunPayrollSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Run Payroll'),
      ),
    );
  }

  void _showRunPayrollSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _RunPayrollSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Total payroll card
// ---------------------------------------------------------------------------

class _TotalPayrollCard extends StatelessWidget {
  const _TotalPayrollCard({required this.summary});

  final PayrollSummary summary;

  @override
  Widget build(BuildContext context) {
    final inr = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _SummaryTile(
            label: 'Employees',
            value: summary.totalEmployees.toString(),
            icon: Icons.people_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _SummaryTile(
            label: 'Gross Payout',
            value:
                '₹${(summary.totalGrossPayout / 100000).toStringAsFixed(1)}L',
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primaryVariant,
          ),
          const SizedBox(width: 8),
          _SummaryTile(
            label: 'Net Payout',
            value: '₹${(summary.totalNetPayout / 100000).toStringAsFixed(1)}L',
            icon: Icons.payments_rounded,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _SummaryTile(
            label: 'PF Total',
            value: inr.format(summary.totalPfContribution),
            icon: Icons.shield_rounded,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
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
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period selector bar
// ---------------------------------------------------------------------------

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.surface,
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Payroll Period: $label',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Employees tab
// ---------------------------------------------------------------------------

class _EmployeesTab extends ConsumerWidget {
  const _EmployeesTab();

  void _openPayslip(
    BuildContext context,
    Employee employee,
    ({int month, int year}) period,
  ) {
    PayslipDetailSheet.show(
      context,
      employee: employee,
      month: period.month,
      year: period.year,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider);
    final period = ref.watch(payrollSelectedPeriodProvider);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return EmployeeTile(
          employee: employee,
          onTap: () => _openPayslip(context, employee, period),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly Payroll tab
// ---------------------------------------------------------------------------

class _MonthlyPayrollTab extends ConsumerWidget {
  const _MonthlyPayrollTab();

  void _openPayslipForRecord(
    BuildContext context,
    WidgetRef ref,
    PayrollMonth record,
  ) {
    final employees = ref.read(employeesProvider);
    final employee = employees
        .where((e) => e.id == record.employeeId)
        .firstOrNull;
    if (employee == null) {
      return;
    }
    PayslipDetailSheet.show(
      context,
      employee: employee,
      month: record.month,
      year: record.year,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(filteredPayrollMonthsProvider);

    if (records.isEmpty) {
      return const _EmptyState(message: 'No payroll records for this period');
    }

    // Group by status for quick overview
    final statusCounts = <PayrollStatus, int>{};
    for (final r in records) {
      statusCounts[r.status] = (statusCounts[r.status] ?? 0) + 1;
    }

    return Column(
      children: [
        // Status summary chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: PayrollStatus.values.map((s) {
              final count = statusCounts[s] ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: s.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, size: 12, color: s.color),
                      const SizedBox(width: 4),
                      Text(
                        '${s.label}: $count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: s.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return PayrollMonthTile(
                record: record,
                onTap: () => _openPayslipForRecord(context, ref, record),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Statutory Returns tab
// ---------------------------------------------------------------------------

class _StatutoryReturnsTab extends ConsumerWidget {
  const _StatutoryReturnsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(statutoryReturnsProvider);

    final overdue = returns.where((r) => r.isOverdue).length;

    return Column(
      children: [
        if (overdue > 0)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  '$overdue return(s) overdue — file immediately',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: returns.length,
            itemBuilder: (context, index) =>
                StatutoryReturnTile(returnRecord: returns[index]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

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
            style: const TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Run payroll sheet
// ---------------------------------------------------------------------------

class _RunPayrollSheet extends ConsumerStatefulWidget {
  const _RunPayrollSheet();

  @override
  ConsumerState<_RunPayrollSheet> createState() => _RunPayrollSheetState();
}

class _RunPayrollSheetState extends ConsumerState<_RunPayrollSheet> {
  bool _includeBonus = false;
  bool _generateChallan = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = ref.watch(payrollSelectedPeriodProvider);
    final periodLabel = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(period.year, period.month));

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
            'Run Payroll',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Period: $periodLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile.adaptive(
            value: _includeBonus,
            onChanged: (v) => setState(() => _includeBonus = v),
            title: const Text('Include Performance Bonus'),
            subtitle: const Text('Add discretionary bonus to gross salary'),
            activeTrackColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile.adaptive(
            value: _generateChallan,
            onChanged: (v) => setState(() => _generateChallan = v),
            title: const Text('Auto-generate PF/ESI Challan'),
            subtitle: const Text(
              'Generate statutory challans after processing',
            ),
            activeTrackColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payroll for $periodLabel initiated successfully',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Process Payroll'),
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
