import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/company.dart';

/// Formats a CIN with dash separators for readability:
/// U74999MH2018PTC123456 → U74999-MH-2018-PTC-123456
String _formatCin(String cin) {
  if (cin.length != 21) return cin;
  return '${cin.substring(0, 6)}-${cin.substring(6, 8)}-'
      '${cin.substring(8, 12)}-${cin.substring(12, 15)}-${cin.substring(15)}';
}

final _currencyFmt = NumberFormat.compactCurrency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 1,
);

/// Card tile for a single [Company] showing CIN, category badge, director
/// count, and capital details.
class CompanyTile extends StatelessWidget {
  const CompanyTile({
    super.key,
    required this.company,
    this.onTap,
  });

  final Company company;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: name + status dot
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      company.companyName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusDot(status: company.status),
                ],
              ),

              const SizedBox(height: 4),

              // CIN mono
              Text(
                _formatCin(company.cin),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontFamily: 'monospace',
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 10),

              // Category badge + ROC
              Row(
                children: [
                  _CategoryBadge(category: company.category),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      company.rocJurisdiction,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Capital + directors row
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.account_balance_rounded,
                    label: 'Paid-up',
                    value: _currencyFmt.format(company.paidUpCapital),
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.people_rounded,
                    label: 'Directors',
                    value: '${company.activeDirectorCount}',
                  ),
                  const Spacer(),
                  Text(
                    'Inc. ${DateFormat('dd MMM yyyy').format(company.incorporationDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final CompanyStatus status;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: status.label,
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          color: status.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final CompanyCategory category;

  Color get _badgeColor {
    switch (category) {
      case CompanyCategory.publicLimited:
        return AppColors.primary;
      case CompanyCategory.privateLimited:
        return AppColors.primaryVariant;
      case CompanyCategory.opc:
        return AppColors.secondary;
      case CompanyCategory.section8:
        return AppColors.success;
      case CompanyCategory.producer:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _badgeColor,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}
