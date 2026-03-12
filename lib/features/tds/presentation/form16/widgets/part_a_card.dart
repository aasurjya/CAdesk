import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/presentation/form16/form16_currency.dart';
import 'package:ca_app/features/tds/presentation/form16/widgets/tds_quarter_row.dart';

/// Expandable card displaying Form 16 Part A — employer info and quarterly
/// TDS breakdown.
class PartACard extends StatelessWidget {
  const PartACard({
    super.key,
    required this.partA,
    required this.employerName,
    required this.employerTan,
    required this.employerAddress,
  });

  final Form16PartA partA;
  final String employerName;
  final String employerTan;
  final String employerAddress;

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
              color: AppColors.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          title: Text(
            'Part A — TDS Summary',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          children: [
            _EmployerInfoSection(
              employerName: employerName,
              employerTan: employerTan,
              employerAddress: employerAddress,
            ),
            const Divider(height: 24),
            _QuarterlyTable(partA: partA),
            const SizedBox(height: 12),
            _TotalRow(partA: partA),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Employer info
// ---------------------------------------------------------------------------

class _EmployerInfoSection extends StatelessWidget {
  const _EmployerInfoSection({
    required this.employerName,
    required this.employerTan,
    required this.employerAddress,
  });

  final String employerName;
  final String employerTan;
  final String employerAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(label: 'Employer', value: employerName),
        const SizedBox(height: 4),
        _InfoRow(label: 'TAN', value: employerTan),
        const SizedBox(height: 4),
        _InfoRow(label: 'Address', value: employerAddress),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quarterly table
// ---------------------------------------------------------------------------

class _QuarterlyTable extends StatelessWidget {
  const _QuarterlyTable({required this.partA});

  final Form16PartA partA;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quarterly TDS Breakdown',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        // Header
        Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                'Qtr',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Receipt No.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'TDS Deposited',
                textAlign: TextAlign.right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: Text(
                'Date',
                textAlign: TextAlign.right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 8),
        ...partA.quarterlyDetails.map(
          (detail) => TdsQuarterRow(detail: detail),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Total row
// ---------------------------------------------------------------------------

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.partA});

  final Form16PartA partA;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total TDS Deposited',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          Text(
            formatPaise(partA.totalTaxDeposited),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
