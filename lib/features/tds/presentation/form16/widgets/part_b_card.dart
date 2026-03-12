import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/presentation/form16/form16_currency.dart';

/// Expandable card displaying Form 16 Part B — salary income computation,
/// deductions under Chapter VI-A, and tax computation.
class PartBCard extends StatelessWidget {
  const PartBCard({super.key, required this.partB});

  final Form16PartB partB;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calculate_rounded,
              size: 20,
              color: AppColors.secondary,
            ),
          ),
          title: Text(
            'Part B — Income & Tax Computation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          children: [
            _SalarySection(salary: partB.salaryBreakup),
            const Divider(height: 24),
            _GrossTotalSection(partB: partB),
            const Divider(height: 24),
            _DeductionsSection(deductions: partB.deductions),
            const Divider(height: 24),
            _TaxComputationSection(tax: partB.taxComputation),
            const SizedBox(height: 12),
            _BalanceSection(
              tdsDeducted: partB.taxComputation.netTaxPayable,
              netTaxPayable: partB.taxComputation.netTaxPayable,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Salary breakdown
// ---------------------------------------------------------------------------

class _SalarySection extends StatelessWidget {
  const _SalarySection({required this.salary});

  final SalaryBreakup salary;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Income Under Head Salary',
      rows: [
        _AmountRow('Gross Salary', salary.grossSalary),
        _AmountRow('  Salary u/s 17(1)', salary.salaryAsPerSection17_1),
        _AmountRow(
          '  Value of Perquisites u/s 17(2)',
          salary.valueOfPerquisites17_2,
        ),
        _AmountRow(
          '  Profits in lieu of Salary u/s 17(3)',
          salary.profitsInLieuOfSalary17_3,
        ),
        _AmountRow(
          'Less: Allowances Exempt u/s 10',
          salary.exemptAllowances,
          isDeduction: true,
        ),
        _AmountRow('Net Salary', salary.netSalary, isBold: true),
        _AmountRow(
          'Less: Standard Deduction',
          salary.standardDeduction,
          isDeduction: true,
        ),
        _AmountRow(
          'Less: Professional Tax',
          salary.professionalTax,
          isDeduction: true,
        ),
        _AmountRow(
          'Income from Salary',
          salary.incomeFromSalary,
          isBold: true,
          isHighlight: true,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gross total income
// ---------------------------------------------------------------------------

class _GrossTotalSection extends StatelessWidget {
  const _GrossTotalSection({required this.partB});

  final Form16PartB partB;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Gross Total Income',
      rows: [
        _AmountRow('Income from Salary', partB.salaryBreakup.incomeFromSalary),
        _AmountRow('Income from House Property', partB.incomeFromHouseProperty),
        _AmountRow('Income from Other Sources', partB.incomeFromOtherSources),
        _AmountRow(
          'Gross Total Income',
          partB.grossTotalIncome,
          isBold: true,
          isHighlight: true,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chapter VI-A deductions
// ---------------------------------------------------------------------------

class _DeductionsSection extends StatelessWidget {
  const _DeductionsSection({required this.deductions});

  final ChapterVIADeductions deductions;

  @override
  Widget build(BuildContext context) {
    // Only show non-zero deductions
    final rows = <_AmountRow>[
      if (deductions.section80C > 0)
        _AmountRow('Section 80C', deductions.section80C),
      if (deductions.section80CCC > 0)
        _AmountRow('Section 80CCC', deductions.section80CCC),
      if (deductions.section80CCD1 > 0)
        _AmountRow('Section 80CCD(1)', deductions.section80CCD1),
      if (deductions.section80CCD1B > 0)
        _AmountRow('Section 80CCD(1B)', deductions.section80CCD1B),
      if (deductions.section80CCD2 > 0)
        _AmountRow('Section 80CCD(2)', deductions.section80CCD2),
      if (deductions.section80D > 0)
        _AmountRow('Section 80D', deductions.section80D),
      if (deductions.section80DD > 0)
        _AmountRow('Section 80DD', deductions.section80DD),
      if (deductions.section80DDB > 0)
        _AmountRow('Section 80DDB', deductions.section80DDB),
      if (deductions.section80E > 0)
        _AmountRow('Section 80E', deductions.section80E),
      if (deductions.section80EE > 0)
        _AmountRow('Section 80EE', deductions.section80EE),
      if (deductions.section80EEA > 0)
        _AmountRow('Section 80EEA', deductions.section80EEA),
      if (deductions.section80G > 0)
        _AmountRow('Section 80G', deductions.section80G),
      if (deductions.section80GG > 0)
        _AmountRow('Section 80GG', deductions.section80GG),
      if (deductions.section80TTA > 0)
        _AmountRow('Section 80TTA', deductions.section80TTA),
      if (deductions.section80TTB > 0)
        _AmountRow('Section 80TTB', deductions.section80TTB),
      if (deductions.section80U > 0)
        _AmountRow('Section 80U', deductions.section80U),
      _AmountRow(
        'Total Deductions under Chapter VI-A',
        deductions.total,
        isBold: true,
        isHighlight: true,
      ),
    ];

    return _Section(title: 'Deductions under Chapter VI-A', rows: rows);
  }
}

// ---------------------------------------------------------------------------
// Tax computation
// ---------------------------------------------------------------------------

class _TaxComputationSection extends StatelessWidget {
  const _TaxComputationSection({required this.tax});

  final TaxComputation tax;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Tax Computation (${tax.taxRegime} Regime)',
      rows: [
        _AmountRow('Total Taxable Income', tax.totalTaxableIncome),
        _AmountRow('Tax on Total Income', tax.taxOnTotalIncome),
        if (tax.rebate87A > 0)
          _AmountRow('Less: Rebate u/s 87A', tax.rebate87A, isDeduction: true),
        _AmountRow('Surcharge', tax.surcharge),
        _AmountRow('Education Cess (4%)', tax.educationCess),
        _AmountRow('Total Tax Payable', tax.totalTaxPayable, isBold: true),
        if (tax.reliefSection89 > 0)
          _AmountRow(
            'Less: Relief u/s 89',
            tax.reliefSection89,
            isDeduction: true,
          ),
        _AmountRow(
          'Net Tax Payable',
          tax.netTaxPayable,
          isBold: true,
          isHighlight: true,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Balance section
// ---------------------------------------------------------------------------

class _BalanceSection extends StatelessWidget {
  const _BalanceSection({
    required this.tdsDeducted,
    required this.netTaxPayable,
  });

  final double tdsDeducted;
  final double netTaxPayable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = netTaxPayable - tdsDeducted;
    final isRefund = balance < 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRefund
            ? AppColors.success.withAlpha(10)
            : AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isRefund ? 'Refund Due' : 'Balance Tax',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          Text(
            formatPaise(balance.abs()),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isRefund ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable section + amount row
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_AmountRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(
    this.label,
    this.amount, {
    this.isBold = false,
    this.isDeduction = false,
    this.isHighlight = false,
  });

  final String label;
  final double amount;
  final bool isBold;
  final bool isDeduction;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayAmount = isDeduction
        ? '(${formatPaise(amount)})'
        : formatPaise(amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isHighlight ? AppColors.primary : AppColors.neutral900,
              ),
            ),
          ),
          Text(
            displayAmount,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight
                  ? AppColors.primary
                  : isDeduction
                  ? AppColors.error
                  : AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
