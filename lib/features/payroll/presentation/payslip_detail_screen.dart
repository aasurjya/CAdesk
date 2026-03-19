import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/payroll_providers.dart';
import '../domain/models/employee.dart';
import 'widgets/payslip_sections.dart';
import 'widgets/salary_breakdown_chart.dart';

/// Full payslip detail screen for a single employee / month.
class PayslipDetailScreen extends ConsumerWidget {
  const PayslipDetailScreen({super.key, required this.payslipId});

  final String payslipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(payrollMonthsProvider);
    final record = records.where((r) => r.id == payslipId).firstOrNull;

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payslip')),
        body: const Center(child: Text('Payslip not found')),
      );
    }

    final employees = ref.watch(employeesProvider).asData?.value ?? [];
    final employee = employees
        .where((e) => e.id == record.employeeId)
        .firstOrNull;

    final monthName = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(record.year, record.month));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Payslip - $monthName',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            onPressed: () => _showAction(context, 'Share'),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 20),
            onPressed: () => _showAction(context, 'Download PDF'),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee != null) PayslipEmployeeHeader(employee: employee),

            const SizedBox(height: 14),

            SalaryBreakdownChart(
              basic: record.basicPaid,
              hra: employee?.hra ?? 0,
              allowances: record.allowancesPaid - (employee?.hra ?? 0),
              deductions: record.totalDeductions,
            ),

            const SizedBox(height: 14),

            PayslipSection(
              title: 'Earnings',
              icon: Icons.add_circle_outline_rounded,
              color: AppColors.success,
              items: _buildEarnings(record, employee),
              total: record.grossPaid,
              totalLabel: 'Gross Earnings',
            ),

            const SizedBox(height: 12),

            PayslipSection(
              title: 'Deductions',
              icon: Icons.remove_circle_outline_rounded,
              color: AppColors.error,
              items: _buildDeductions(record),
              total: record.totalDeductions,
              totalLabel: 'Total Deductions',
            ),

            const SizedBox(height: 12),

            if (employee != null) ...[
              PayslipSection(
                title: 'Employer Contributions',
                icon: Icons.business_rounded,
                color: AppColors.secondary,
                items: _buildEmployerContributions(employee),
                total: _employerTotal(employee),
                totalLabel: 'Total Employer Cost',
              ),
              const SizedBox(height: 12),
            ],

            PayslipNetPayCard(netPay: record.netPaid),

            const SizedBox(height: 14),

            PayslipYtdSection(
              grossPaid: record.grossPaid,
              pfDeducted: record.pfDeducted,
              tdsDeducted: record.tdsDeducted,
              netPaid: record.netPaid,
              month: record.month,
            ),

            const SizedBox(height: 14),

            PayslipActionRow(
              onForm16: () => _showAction(context, 'Form 16 preview'),
              onDownload: () => _showAction(context, 'Download PDF'),
              onShare: () => _showAction(context, 'Share payslip'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  List<PayslipLineItem> _buildEarnings(dynamic record, Employee? employee) {
    return [
      PayslipLineItem('Basic Salary', record.basicPaid as double),
      if (employee != null) PayslipLineItem('HRA', employee.hra),
      PayslipLineItem('Special Allowance', employee?.specialAllowance ?? 0),
      PayslipLineItem('DA', employee?.da ?? 0),
      PayslipLineItem('Conveyance', employee?.conveyance ?? 0),
      PayslipLineItem('Medical Allowance', employee?.medicalAllowance ?? 0),
    ].where((item) => item.amount > 0).toList();
  }

  List<PayslipLineItem> _buildDeductions(dynamic record) {
    return [
      PayslipLineItem('PF Employee', record.pfDeducted as double),
      PayslipLineItem('ESI Employee', record.esiDeducted as double),
      PayslipLineItem('TDS (Sec 192)', record.tdsDeducted as double),
      PayslipLineItem('Other Deductions', record.otherDeductions as double),
    ].where((item) => item.amount > 0).toList();
  }

  List<PayslipLineItem> _buildEmployerContributions(Employee employee) {
    final employerPf = SalaryCalculator.employerPf(employee.basicSalary);
    final employerEsi = SalaryCalculator.employerEsi(employee.grossSalary);
    return [
      PayslipLineItem('PF Employer', employerPf),
      PayslipLineItem('ESI Employer', employerEsi),
    ].where((item) => item.amount > 0).toList();
  }

  double _employerTotal(Employee employee) {
    return SalaryCalculator.employerPf(employee.basicSalary) +
        SalaryCalculator.employerEsi(employee.grossSalary);
  }

  void _showAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action initiated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
