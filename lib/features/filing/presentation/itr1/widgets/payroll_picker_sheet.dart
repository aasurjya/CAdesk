import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/payroll_prefill_provider.dart';
import 'package:ca_app/features/payroll/data/providers/payroll_providers.dart';
import 'package:ca_app/features/payroll/domain/models/employee.dart';

// ---------------------------------------------------------------------------
// Public API — show the bottom sheet
// ---------------------------------------------------------------------------

/// Shows the "Prefill from Payroll" bottom sheet.
///
/// Returns a [PayrollPrefillResult] if the user confirms, or `null` if
/// they dismiss the sheet.
Future<PayrollPrefillResult?> showPayrollPickerSheet(BuildContext context) {
  return showModalBottomSheet<PayrollPrefillResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _PayrollPickerSheet(),
  );
}

// ---------------------------------------------------------------------------
// Bottom sheet widget
// ---------------------------------------------------------------------------

class _PayrollPickerSheet extends ConsumerStatefulWidget {
  const _PayrollPickerSheet();

  @override
  ConsumerState<_PayrollPickerSheet> createState() =>
      _PayrollPickerSheetState();
}

class _PayrollPickerSheetState extends ConsumerState<_PayrollPickerSheet> {
  String? _selectedEmployeeId;
  int? _selectedFY;

  @override
  void initState() {
    super.initState();
    // Pre-select the first active employee and latest FY
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final employees = ref.read(employeesProvider);
      final fys = ref.read(payrollAvailableFYsProvider);

      setState(() {
        if (employees.isNotEmpty) {
          final active = employees.where((e) => e.isActive);
          _selectedEmployeeId = active.isNotEmpty
              ? active.first.id
              : employees.first.id;
        }
        if (fys.isNotEmpty) {
          _selectedFY = fys.first;
        }
      });
    });
  }

  PayrollPrefillResult? get _currentResult {
    if (_selectedEmployeeId == null || _selectedFY == null) return null;
    return ref.read(
      payrollAnnualSummaryProvider((
        employeeId: _selectedEmployeeId!,
        financialYear: _selectedFY!,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employees = ref.watch(employeesProvider);
    final availableFYs = ref.watch(payrollAvailableFYsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Prefill from Payroll',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Import annual salary data from payroll records',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 20),

          // Employee dropdown
          _buildEmployeeDropdown(theme, employees),
          const SizedBox(height: 16),

          // FY selector
          _buildFYDropdown(theme, availableFYs),
          const SizedBox(height: 20),

          // Preview card
          _buildPreviewCard(theme),
          const SizedBox(height: 20),

          // Action button
          _buildUseDataButton(theme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sub-widgets
  // -------------------------------------------------------------------------

  Widget _buildEmployeeDropdown(ThemeData theme, List<Employee> employees) {
    final activeEmployees = employees.where((e) => e.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedEmployeeId,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          isExpanded: true,
          items: activeEmployees
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(
                    '${e.name} (${e.employeeCode})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedEmployeeId = value);
          },
        ),
      ],
    );
  }

  Widget _buildFYDropdown(ThemeData theme, List<int> availableFYs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Year',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: _selectedFY,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: availableFYs
              .map(
                (fy) => DropdownMenuItem<int>(
                  value: fy,
                  child: Text('FY $fy-${(fy + 1) % 100}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedFY = value);
          },
        ),
      ],
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    final result = _currentResult;

    if (result == null) {
      return Card(
        color: AppColors.neutral100,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('Select an employee and financial year to preview'),
          ),
        ),
      );
    }

    if (result.monthCount == 0) {
      return Card(
        color: AppColors.neutral100,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 32),
              const SizedBox(height: 8),
              Text(
                'No payroll records found for this period',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final salary = result.salaryIncome;

    return Card(
      color: AppColors.neutral50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Preview (${result.monthCount} months)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _previewRow(
              theme,
              'Gross Salary',
              CurrencyUtils.formatINR(salary.grossSalary),
            ),
            _previewRow(
              theme,
              'Standard Deduction',
              CurrencyUtils.formatINR(salary.standardDeduction),
            ),
            _previewRow(
              theme,
              'TDS Deducted',
              CurrencyUtils.formatINR(result.tdsDeducted),
            ),
            _previewRow(
              theme,
              'Employer PF (80C)',
              CurrencyUtils.formatINR(result.employerPfContribution),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(
    ThemeData theme,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseDataButton(ThemeData theme) {
    final result = _currentResult;
    final isEnabled = result != null && result.monthCount > 0;

    return FilledButton.icon(
      onPressed: isEnabled ? () => Navigator.pop(context, result) : null,
      icon: const Icon(Icons.check_circle_outline, size: 20),
      label: const Text('Use This Data'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
