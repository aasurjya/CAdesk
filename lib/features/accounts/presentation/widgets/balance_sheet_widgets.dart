import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Company header for balance sheet.
class BalanceSheetCompanyHeader extends StatelessWidget {
  const BalanceSheetCompanyHeader({
    super.key,
    required this.companyName,
    required this.pan,
    required this.financialYear,
  });

  final String companyName;
  final String pan;
  final String financialYear;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PAN: $pan | $financialYear',
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
            const SizedBox(height: 2),
            const Text(
              'Balance Sheet as per Schedule III of Companies Act, 2013',
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Balance check banner indicating whether assets = equity + liabilities.
class BalanceCheckBanner extends StatelessWidget {
  const BalanceCheckBanner({super.key, required this.isBalanced});

  final bool isBalanced;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isBalanced
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBalanced
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isBalanced ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 16,
            color: isBalanced ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              isBalanced
                  ? 'Balance Sheet is balanced (Assets = Equity + Liabilities)'
                  : 'WARNING: Balance Sheet is not balanced!',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isBalanced ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Column headers for balance sheet table.
class BalanceSheetColumnHeaders extends StatelessWidget {
  const BalanceSheetColumnHeaders({super.key, required this.hasPreviousYear});

  final bool hasPreviousYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: Text(
              'Particulars',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral600,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Current Year',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral600,
              ),
            ),
          ),
          if (hasPreviousYear)
            const Expanded(
              flex: 3,
              child: Text(
                'Previous Year',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section title for balance sheet (ASSETS, EQUITY & LIABILITIES).
class BalanceSheetSectionTitle extends StatelessWidget {
  const BalanceSheetSectionTitle({
    super.key,
    required this.title,
    required this.color,
  });

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: color.withValues(alpha: 0.06),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Export PDF/Excel button row.
class BalanceSheetExportButtons extends StatelessWidget {
  const BalanceSheetExportButtons({
    super.key,
    required this.onPdf,
    required this.onExcel,
  });

  final VoidCallback onPdf;
  final VoidCallback onExcel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onExcel,
            icon: const Icon(Icons.table_chart_rounded, size: 16),
            label: const Text('Export Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: const BorderSide(color: AppColors.success),
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
