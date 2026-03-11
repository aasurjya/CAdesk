import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_entity.dart';

/// Card displaying an LLP entity with audit status badge,
/// partner count, turnover, and partner details.
class LLPEntityCard extends StatelessWidget {
  const LLPEntityCard({super.key, required this.entity});

  final LLPEntity entity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: name + audit badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.llpName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _LLPINBadge(llpin: entity.llpin),
                          const SizedBox(width: 8),
                          _AuditBadge(
                            isRequired: entity.isAuditRequired,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Partner count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entity.totalPartnerCount}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Partners',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Info row
            Row(
              children: [
                _InfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Inc. ${dateFormat.format(entity.incorporationDate)}',
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.location_on_rounded,
                  label: entity.rocJurisdiction,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Financial details
            Row(
              children: [
                _FinancialChip(
                  label: 'Turnover',
                  value: currencyFormat.format(entity.turnover),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _FinancialChip(
                  label: 'Capital',
                  value: currencyFormat.format(entity.capitalContribution),
                  color: AppColors.secondary,
                ),
              ],
            ),
            // Audit threshold warning
            if (entity.isAuditRequired) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gavel_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Audit required: Turnover > \u20B940L '
                        'or Capital > \u20B925L',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Designated partners
            const SizedBox(height: 10),
            Text(
              'Designated Partners',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: 4),
            ...entity.designatedPartners
                .where((p) => p.isDesignated)
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${p.name} (DIN: ${p.din})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _LLPINBadge extends StatelessWidget {
  const _LLPINBadge({required this.llpin});

  final String llpin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'LLPIN: $llpin',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AuditBadge extends StatelessWidget {
  const _AuditBadge({required this.isRequired});

  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final color = isRequired ? AppColors.warning : AppColors.success;
    final label = isRequired ? 'Audit Req.' : 'No Audit';
    final icon = isRequired
        ? Icons.gavel_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.neutral600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FinancialChip extends StatelessWidget {
  const _FinancialChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
