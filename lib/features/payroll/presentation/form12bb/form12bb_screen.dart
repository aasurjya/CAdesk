import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/form12bb_providers.dart';
import '../../data/providers/payroll_providers.dart';
import 'widgets/deduction_field.dart';
import 'widgets/section_total_chip.dart';

/// Form 12BB investment declaration screen.
///
/// Allows employees to declare HRA, LTA, Chapter VI-A deductions,
/// and home loan interest for TDS computation.
class Form12bbScreen extends ConsumerStatefulWidget {
  const Form12bbScreen({super.key, this.employeeId});

  /// Optional pre-selected employee ID from route parameter.
  final String? employeeId;

  @override
  ConsumerState<Form12bbScreen> createState() => _Form12bbScreenState();
}

class _Form12bbScreenState extends ConsumerState<Form12bbScreen> {
  final _formKey = GlobalKey<FormState>();

  // HRA controllers
  final _rentCtrl = TextEditingController();
  final _landlordNameCtrl = TextEditingController();
  final _landlordPanCtrl = TextEditingController();
  final _landlordAddressCtrl = TextEditingController();

  // LTA controller
  final _ltaCtrl = TextEditingController();

  // Chapter VI-A controllers
  final _s80CCtrl = TextEditingController();
  final _s80CCD1BCtrl = TextEditingController();
  final _s80DCtrl = TextEditingController();
  final _s80ECtrl = TextEditingController();
  final _s80GCtrl = TextEditingController();
  final _s80TTACtrl = TextEditingController();

  // Home loan controllers
  final _homeLoanCtrl = TextEditingController();
  final _lenderNameCtrl = TextEditingController();
  final _lenderPanCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employeeId != null) {
      // Schedule after build to access ref
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(activeForm12bbProvider.notifier)
            .setEmployee(widget.employeeId!);
      });
    }
  }

  @override
  void dispose() {
    _rentCtrl.dispose();
    _landlordNameCtrl.dispose();
    _landlordPanCtrl.dispose();
    _landlordAddressCtrl.dispose();
    _ltaCtrl.dispose();
    _s80CCtrl.dispose();
    _s80CCD1BCtrl.dispose();
    _s80DCtrl.dispose();
    _s80ECtrl.dispose();
    _s80GCtrl.dispose();
    _s80TTACtrl.dispose();
    _homeLoanCtrl.dispose();
    _lenderNameCtrl.dispose();
    _lenderPanCtrl.dispose();
    super.dispose();
  }

  /// Parses a text field value to paise (user enters rupees).
  int _toPaise(String text) {
    final rupees = int.tryParse(text) ?? 0;
    return rupees * 100;
  }

  void _syncToProvider() {
    final notifier = ref.read(activeForm12bbProvider.notifier);
    notifier.updateHra(
      annualRentPaid: _toPaise(_rentCtrl.text),
      landlordName: _landlordNameCtrl.text,
      landlordPan: _landlordPanCtrl.text,
      landlordAddress: _landlordAddressCtrl.text,
    );
    notifier.updateLta(ltaClaimedAmount: _toPaise(_ltaCtrl.text));
    notifier.updateChapterVIA(
      section80C: _toPaise(_s80CCtrl.text),
      section80CCD1B: _toPaise(_s80CCD1BCtrl.text),
      section80D: _toPaise(_s80DCtrl.text),
      section80E: _toPaise(_s80ECtrl.text),
      section80G: _toPaise(_s80GCtrl.text),
      section80TTA: _toPaise(_s80TTACtrl.text),
    );
    notifier.updateHomeLoan(
      homeLoanInterest: _toPaise(_homeLoanCtrl.text),
      lenderName: _lenderNameCtrl.text,
      lenderPan: _lenderPanCtrl.text,
    );
  }

  void _submit() {
    _syncToProvider();
    final declaration = ref.read(activeForm12bbProvider);
    final errors = validateForm12bb(declaration);
    if (!_formKey.currentState!.validate() || errors.isNotEmpty) {
      final message = errors.isNotEmpty
          ? errors.first
          : 'Please fix the errors above';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    // Submit to list
    ref.read(form12bbListProvider.notifier).add(declaration);
    ref.read(activeForm12bbProvider.notifier).reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form 12BB declaration submitted successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalPaise = ref.watch(form12bbTotalDeductionsProvider);
    final employees = ref.watch(employeesProvider).asData?.value ?? [];
    final declaration = ref.watch(activeForm12bbProvider);
    final selectedEmployee = employees
        .where((e) => e.id == declaration.employeeId)
        .firstOrNull;

    final inr = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Form 12BB — Investment Declaration'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Employee + FY header
          _HeaderBar(
            employeeName: selectedEmployee?.name ?? 'Select Employee',
            financialYear:
                'FY ${declaration.financialYear}-'
                '${(declaration.financialYear + 1) % 100}',
          ),
          // Form body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  // Employee selector (if not pre-selected)
                  if (widget.employeeId == null) ...[
                    _EmployeeDropdown(
                      employees: employees,
                      selectedId: declaration.employeeId,
                      onChanged: (id) {
                        if (id != null) {
                          ref
                              .read(activeForm12bbProvider.notifier)
                              .setEmployee(id);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Section 1: HRA
                  _buildHraSection(),
                  // Section 2: LTA
                  _buildLtaSection(),
                  // Section 3: Chapter VI-A
                  _buildChapterVIASection(),
                  // Section 4: Home Loan
                  _buildHomeLoanSection(),
                ],
              ),
            ),
          ),
          // Bottom total bar
          _TotalBar(
            totalLabel: inr.format(totalPaise ~/ 100),
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildHraSection() {
    return _SectionTile(
      title: 'HRA Exemption',
      icon: Icons.home_rounded,
      trailing: SectionTotalChip(
        label: 'HRA',
        amountPaise: _toPaise(_rentCtrl.text),
      ),
      children: [
        DeductionField(
          label: 'Annual Rent Paid',
          controller: _rentCtrl,
          tooltipMessage: 'Total rent paid during the financial year',
          onChanged: (_) => _syncToProvider(),
        ),
        TextFormField(
          controller: _landlordNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Landlord Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _landlordPanCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Landlord PAN',
            helperText: 'Required if rent > ₹1,00,000/year',
            helperStyle: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral400,
            ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            final rent = _toPaise(_rentCtrl.text);
            if (rent > Form12bbLimits.landlordPanThreshold) {
              if (value == null || value.isEmpty) {
                return 'PAN required when rent > ₹1,00,000';
              }
              if (!panRegex.hasMatch(value)) {
                return 'Invalid PAN format (e.g. ABCDE1234F)';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _landlordAddressCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Landlord Address',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLtaSection() {
    return _SectionTile(
      title: 'Leave Travel Allowance',
      icon: Icons.flight_takeoff_rounded,
      trailing: SectionTotalChip(
        label: 'LTA',
        amountPaise: _toPaise(_ltaCtrl.text),
      ),
      children: [
        DeductionField(
          label: 'LTA Amount Claimed',
          controller: _ltaCtrl,
          tooltipMessage: 'Travel expenditure for LTA exemption',
          onChanged: (_) => _syncToProvider(),
        ),
      ],
    );
  }

  Widget _buildChapterVIASection() {
    return _SectionTile(
      title: 'Chapter VI-A Deductions',
      icon: Icons.account_balance_rounded,
      trailing: SectionTotalChip(
        label: 'VI-A',
        amountPaise:
            _toPaise(_s80CCtrl.text) +
            _toPaise(_s80CCD1BCtrl.text) +
            _toPaise(_s80DCtrl.text) +
            _toPaise(_s80ECtrl.text) +
            _toPaise(_s80GCtrl.text) +
            _toPaise(_s80TTACtrl.text),
      ),
      children: [
        // 80C breakdown chips
        const Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _InfoChip(label: 'PPF'),
            _InfoChip(label: 'ELSS'),
            _InfoChip(label: 'LIC'),
            _InfoChip(label: 'NSC'),
            _InfoChip(label: 'Tuition'),
            _InfoChip(label: 'Home Loan Principal'),
          ],
        ),
        const SizedBox(height: 8),
        DeductionField(
          label: 'Section 80C',
          controller: _s80CCtrl,
          maxLimitPaise: Form12bbLimits.section80C,
          maxLimitLabel: 'Max ₹1,50,000',
          tooltipMessage:
              'PPF, ELSS, LIC, NSC, SCSS, Sukanya, tuition fees, '
              'stamp duty, home loan principal repayment',
          onChanged: (_) => _syncToProvider(),
        ),
        DeductionField(
          label: 'Section 80CCD(1B) — NPS',
          controller: _s80CCD1BCtrl,
          maxLimitPaise: Form12bbLimits.section80CCD1B,
          maxLimitLabel: 'Max ₹50,000',
          tooltipMessage: 'Additional NPS contribution over and above 80C',
          onChanged: (_) => _syncToProvider(),
        ),
        DeductionField(
          label: 'Section 80D — Health Insurance',
          controller: _s80DCtrl,
          maxLimitLabel: 'Self ₹25K / ₹50K senior; Parents ₹25K / ₹50K',
          tooltipMessage:
              'Medical insurance premium for self, spouse, children '
              'and parents. Higher limit for senior citizens.',
          onChanged: (_) => _syncToProvider(),
        ),
        DeductionField(
          label: 'Section 80E — Education Loan Interest',
          controller: _s80ECtrl,
          tooltipMessage:
              'Interest on loan for higher education. No max limit.',
          onChanged: (_) => _syncToProvider(),
        ),
        DeductionField(
          label: 'Section 80G — Donations',
          controller: _s80GCtrl,
          tooltipMessage: 'Donations to approved funds/charities under 80G',
          onChanged: (_) => _syncToProvider(),
        ),
        DeductionField(
          label: 'Section 80TTA — Savings Interest',
          controller: _s80TTACtrl,
          maxLimitPaise: Form12bbLimits.section80TTA,
          maxLimitLabel: 'Max ₹10,000',
          tooltipMessage:
              'Interest on savings account (not FD/RD). '
              '80TTB for senior citizens up to ₹50,000.',
          onChanged: (_) => _syncToProvider(),
        ),
      ],
    );
  }

  Widget _buildHomeLoanSection() {
    return _SectionTile(
      title: 'Home Loan Interest — Sec 24(b)',
      icon: Icons.real_estate_agent_rounded,
      trailing: SectionTotalChip(
        label: 'Sec 24(b)',
        amountPaise: _toPaise(_homeLoanCtrl.text),
      ),
      children: [
        DeductionField(
          label: 'Home Loan Interest',
          controller: _homeLoanCtrl,
          maxLimitPaise: Form12bbLimits.homeLoanInterest,
          maxLimitLabel: 'Max ₹2,00,000',
          tooltipMessage:
              'Interest paid on housing loan for self-occupied property',
          onChanged: (_) => _syncToProvider(),
        ),
        TextFormField(
          controller: _lenderNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Lender Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lenderPanCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Lender PAN',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                !panRegex.hasMatch(value)) {
              return 'Invalid PAN format (e.g. ABCDE1234F)';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.employeeName, required this.financialYear});

  final String employeeName;
  final String financialYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          const Icon(Icons.person_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              employeeName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.neutral900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              financialYear,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeDropdown extends StatelessWidget {
  const _EmployeeDropdown({
    required this.employees,
    required this.selectedId,
    required this.onChanged,
  });

  final List<dynamic> employees;
  final String selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId.isEmpty ? null : selectedId,
      decoration: const InputDecoration(
        labelText: 'Select Employee',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: employees
          .map(
            (e) => DropdownMenuItem(
              value: e.id as String,
              child: Text('${e.name} (${e.employeeCode})'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: ExpansionTile(
        leading: Icon(icon, size: 20, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.neutral900,
          ),
        ),
        trailing: trailing,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: children,
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.totalLabel, required this.onSubmit});

  final String totalLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Deductions',
                    style: TextStyle(fontSize: 11, color: AppColors.neutral400),
                  ),
                  Text(
                    totalLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Submit Declaration'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 10, color: AppColors.neutral600),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.neutral100,
      side: BorderSide.none,
    );
  }
}
