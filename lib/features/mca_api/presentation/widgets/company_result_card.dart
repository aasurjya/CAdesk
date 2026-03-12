import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';

/// Card displaying MCA company lookup results with status badge.
class CompanyResultCard extends StatelessWidget {
  const CompanyResultCard({super.key, required this.company});

  final McaCompanyLookup company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    company.companyName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                _CompanyStatusBadge(status: company.status),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'CIN', value: company.cin),
            const SizedBox(height: 6),
            _DetailRow(
              label: 'Incorporation',
              value: _formatDate(company.dateOfIncorporation),
            ),
            const SizedBox(height: 6),
            _DetailRow(label: 'State', value: company.state),
            const SizedBox(height: 6),
            _DetailRow(label: 'Category', value: company.companyCategory),
            const SizedBox(height: 6),
            _DetailRow(
              label: 'Sub-Category',
              value: company.companySubCategory,
            ),
            const SizedBox(height: 6),
            _DetailRow(label: 'RoC', value: company.roc),
            const SizedBox(height: 6),
            _DetailRow(
              label: 'Auth. Capital',
              value: _formatPaise(company.authorizedCapital),
            ),
            const SizedBox(height: 6),
            _DetailRow(
              label: 'Paid-up Capital',
              value: _formatPaise(company.paidUpCapital),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _CompanyStatusBadge extends StatelessWidget {
  const _CompanyStatusBadge({required this.status});

  final McaCompanyStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _badgeLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _badgeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String get _badgeLabel {
    switch (status) {
      case McaCompanyStatus.active:
        return 'Active';
      case McaCompanyStatus.dormant:
        return 'Dormant';
      case McaCompanyStatus.strikedOff:
        return 'Struck Off';
      case McaCompanyStatus.underLiquidation:
        return 'Liquidation';
      case McaCompanyStatus.amalgamated:
        return 'Amalgamated';
    }
  }

  Color get _badgeColor {
    switch (status) {
      case McaCompanyStatus.active:
        return AppColors.success;
      case McaCompanyStatus.dormant:
        return AppColors.warning;
      case McaCompanyStatus.strikedOff:
        return AppColors.error;
      case McaCompanyStatus.underLiquidation:
        return AppColors.error;
      case McaCompanyStatus.amalgamated:
        return AppColors.neutral400;
    }
  }
}

// ---------------------------------------------------------------------------
// Detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

/// Format paise to INR with Indian grouping.
String _formatPaise(int paise) {
  final rupees = paise ~/ 100;
  final paisePart = (paise % 100).toString().padLeft(2, '0');
  final formatted = _indianGrouping(rupees);
  return '\u20B9$formatted.$paisePart';
}

String _indianGrouping(int value) {
  if (value < 0) return '-${_indianGrouping(-value)}';
  final str = value.toString();
  if (str.length <= 3) return str;

  final lastThree = str.substring(str.length - 3);
  var remaining = str.substring(0, str.length - 3);
  final parts = <String>[];

  while (remaining.length > 2) {
    parts.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) {
    parts.insert(0, remaining);
  }

  return '${parts.join(',')},$lastThree';
}
