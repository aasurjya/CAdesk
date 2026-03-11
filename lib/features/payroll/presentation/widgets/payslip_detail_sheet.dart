import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/payroll_providers.dart';
import '../../domain/models/employee.dart';

final _inr = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// Shows a full payslip for [employee] in [month]/[year] as a bottom sheet.
///
/// Uses [SalaryCalculator.compute] to derive all deductions from the
/// employee's salary components.
class PayslipDetailSheet extends StatefulWidget {
  const PayslipDetailSheet({
    super.key,
    required this.employee,
    required this.month,
    required this.year,
    this.companyName = 'CADesk Technologies Pvt Ltd',
  });

  final Employee employee;
  final int month;
  final int year;
  final String companyName;

  /// Convenience method to show the sheet from any [BuildContext].
  static void show(
    BuildContext context, {
    required Employee employee,
    required int month,
    required int year,
    String companyName = 'CADesk Technologies Pvt Ltd',
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayslipDetailSheet(
        employee: employee,
        month: month,
        year: year,
        companyName: companyName,
      ),
    );
  }

  @override
  State<PayslipDetailSheet> createState() => _PayslipDetailSheetState();
}

class _PayslipDetailSheetState extends State<PayslipDetailSheet> {
  bool _showEmployerContributions = false;

  String get _monthLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[widget.month - 1]} ${widget.year}';
  }

  NetPayResult get _result {
    final emp = widget.employee;
    final otherAllowances = emp.da + emp.conveyance + emp.medicalAllowance;
    return SalaryCalculator.compute(
      basicSalary: emp.basicSalary,
      hra: emp.hra,
      specialAllowance: emp.specialAllowance,
      otherAllowances: otherAllowances,
      isFeb: widget.month == 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    // Header
                    _PayslipHeader(
                      employee: widget.employee,
                      monthLabel: _monthLabel,
                      companyName: widget.companyName,
                    ),

                    const SizedBox(height: 20),

                    // Earnings
                    _SectionHeader(title: 'Earnings'),
                    const SizedBox(height: 8),
                    _PayslipRow(
                      label: 'Basic Salary',
                      amount: result.basicSalary,
                    ),
                    _PayslipRow(label: 'HRA', amount: result.hra),
                    _PayslipRow(
                      label: 'Special Allowance',
                      amount: result.specialAllowance,
                    ),
                    _PayslipRow(
                      label: 'Other Allowances',
                      amount: result.otherAllowances,
                    ),
                    const _Divider(),
                    _PayslipRow(
                      label: 'Gross Salary',
                      amount: result.gross,
                      isBold: true,
                    ),

                    const SizedBox(height: 20),

                    // Deductions
                    _SectionHeader(title: 'Deductions'),
                    const SizedBox(height: 8),
                    _PayslipRow(
                      label: 'Employee PF (12%)',
                      amount: result.employeePf,
                      isDeduction: true,
                    ),
                    _PayslipRow(
                      label: 'Employee ESI (0.75%)',
                      amount: result.employeeEsi,
                      isDeduction: true,
                    ),
                    _PayslipRow(
                      label: 'Professional Tax',
                      amount: result.professionalTax,
                      isDeduction: true,
                    ),
                    _PayslipRow(
                      label: 'TDS (Sec 192)',
                      amount: result.tds,
                      isDeduction: true,
                    ),
                    const _Divider(),
                    _PayslipRow(
                      label: 'Total Deductions',
                      amount: result.totalDeductions,
                      isBold: true,
                      isDeduction: true,
                    ),

                    const SizedBox(height: 20),

                    // Net Pay highlight card
                    _NetPayCard(netPay: result.netPay),

                    const SizedBox(height: 20),

                    // Employer contributions (collapsible)
                    _EmployerContributionsSection(
                      result: result,
                      expanded: _showEmployerContributions,
                      onToggle: () => setState(
                        () => _showEmployerContributions =
                            !_showEmployerContributions,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showSnackBar(
                              context,
                              'Payslip PDF download initiated',
                            ),
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Download PDF'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _showSnackBar(
                              context,
                              'Payslip sent to ${widget.employee.name}',
                            ),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Send to Employee'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _PayslipHeader extends StatelessWidget {
  const _PayslipHeader({
    required this.employee,
    required this.monthLabel,
    required this.companyName,
  });

  final Employee employee;
  final String monthLabel;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  _initials(employee.name),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      employee.designation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.neutral200),
          const SizedBox(height: 10),
          Text(
            companyName,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${employee.employeeCode}  •  ${employee.department}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral400,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _PayslipRow extends StatelessWidget {
  const _PayslipRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.isDeduction = false,
  });

  final String label;
  final double amount;
  final bool isBold;
  final bool isDeduction;

  @override
  Widget build(BuildContext context) {
    final Color amountColor;
    if (isBold && isDeduction) {
      amountColor = AppColors.error;
    } else if (isDeduction) {
      amountColor = AppColors.neutral600;
    } else if (isBold) {
      amountColor = AppColors.primary;
    } else {
      amountColor = AppColors.neutral900;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: isBold ? AppColors.neutral900 : AppColors.neutral600,
              ),
            ),
          ),
          Text(
            _inr.format(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, color: AppColors.neutral200),
    );
  }
}

class _NetPayCard extends StatelessWidget {
  const _NetPayCard({required this.netPay});

  final double netPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'NET PAY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _inr.format(netPay),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployerContributionsSection extends StatelessWidget {
  const _EmployerContributionsSection({
    required this.result,
    required this.expanded,
    required this.onToggle,
  });

  final NetPayResult result;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Employer Contributions & CTC',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: AppColors.neutral200),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                children: [
                  _PayslipRow(
                    label: 'Employer PF (12%)',
                    amount: result.employerPf,
                  ),
                  _PayslipRow(
                    label: 'Employer ESI (3.25%)',
                    amount: result.employerEsi,
                  ),
                  const _Divider(),
                  _PayslipRow(
                    label: 'CTC (Annual)',
                    amount: result.ctc * 12,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
