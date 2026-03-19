import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/fema/domain/models/fdi_transaction.dart';

/// A card tile displaying a single FDI transaction with country and sector info.
class FdiTransactionTile extends StatelessWidget {
  const FdiTransactionTile({super.key, required this.transaction});

  final FdiTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: transaction.currency == 'USD' ? '\$' : '\u20B9',
      decimalDigits: 1,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: entity name and amount
              Row(
                children: [
                  Expanded(
                    child: Text(
                      transaction.entityName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amountFormat.format(transaction.amount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Investor info with country flag placeholder
              Row(
                children: [
                  _CountryPlaceholder(country: transaction.investorCountry),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.investorName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          transaction.investorCountry,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: transaction.status),
                ],
              ),
              const SizedBox(height: 8),

              // Sector info row
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.pie_chart_outline_rounded,
                    label:
                        'Equity: ${transaction.equityPercentage.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.shield_outlined,
                    label:
                        'Sector Cap: ${transaction.sectorCap.toStringAsFixed(0)}%',
                  ),
                  const SizedBox(width: 8),
                  _ApprovalRouteBadge(route: transaction.approvalRoute),
                ],
              ),
              const SizedBox(height: 6),

              // Date row
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(transaction.transactionDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
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

/// Circular country flag placeholder with initials.
class _CountryPlaceholder extends StatelessWidget {
  const _CountryPlaceholder({required this.country});

  final String country;

  @override
  Widget build(BuildContext context) {
    final initials = country.length >= 2
        ? country.substring(0, 2).toUpperCase()
        : country.toUpperCase();

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primaryVariant.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryVariant,
        ),
      ),
    );
  }
}

/// Small info chip with icon and label.
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral200.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.neutral600),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge for approval route.
class _ApprovalRouteBadge extends StatelessWidget {
  const _ApprovalRouteBadge({required this.route});

  final FdiApprovalRoute route;

  @override
  Widget build(BuildContext context) {
    final isGovernment = route == FdiApprovalRoute.government;
    final color = isGovernment ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        route.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Status badge for FDI transaction.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final FdiTransactionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
