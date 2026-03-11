import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_disclosure.dart';

/// A card tile displaying a single SEBI disclosure with exchange badge.
class DisclosureTile extends StatelessWidget {
  const DisclosureTile({super.key, required this.disclosure});

  final SebiDisclosure disclosure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final now = DateTime(2026, 3, 10);
    final daysUntilDue = disclosure.dueDate.difference(now).inDays;

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
              // Top row: company name and deadline countdown
              Row(
                children: [
                  Expanded(
                    child: Text(
                      disclosure.companyName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DeadlineCountdown(
                    daysUntilDue: daysUntilDue,
                    isFiled: disclosure.status == DisclosureStatus.filed,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Middle row: type badge, exchange badge, status badge
              Row(
                children: [
                  _DisclosureTypeBadge(type: disclosure.disclosureType),
                  const SizedBox(width: 8),
                  _ExchangeBadge(exchange: disclosure.exchange),
                  const Spacer(),
                  _StatusBadge(status: disclosure.status),
                ],
              ),
              const SizedBox(height: 8),

              // Bottom row: dates and period
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${dateFormat.format(disclosure.dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: disclosure.status == DisclosureStatus.overdue
                          ? AppColors.error
                          : AppColors.neutral400,
                      fontWeight:
                          disclosure.status == DisclosureStatus.overdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                  ),
                  if (disclosure.filedDate != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filed: ${dateFormat.format(disclosure.filedDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (disclosure.period != null)
                    Text(
                      disclosure.period!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

              // Remarks if present
              if (disclosure.remarks != null) ...[
                const SizedBox(height: 6),
                Text(
                  disclosure.remarks!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Deadline countdown chip.
class _DeadlineCountdown extends StatelessWidget {
  const _DeadlineCountdown({
    required this.daysUntilDue,
    required this.isFiled,
  });

  final int daysUntilDue;
  final bool isFiled;

  @override
  Widget build(BuildContext context) {
    if (isFiled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Filed',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    final Color color;
    final String label;

    if (daysUntilDue < 0) {
      color = AppColors.error;
      label = '${-daysUntilDue}d overdue';
    } else if (daysUntilDue <= 7) {
      color = AppColors.warning;
      label = '${daysUntilDue}d left';
    } else {
      color = AppColors.neutral400;
      label = '${daysUntilDue}d left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Badge for disclosure type.
class _DisclosureTypeBadge extends StatelessWidget {
  const _DisclosureTypeBadge({required this.type});

  final DisclosureType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}

/// Badge showing stock exchange.
class _ExchangeBadge extends StatelessWidget {
  const _ExchangeBadge({required this.exchange});

  final StockExchange exchange;

  @override
  Widget build(BuildContext context) {
    final color = switch (exchange) {
      StockExchange.bse => const Color(0xFF1565C0),
      StockExchange.nse => const Color(0xFF0D7C7C),
      StockExchange.both => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        exchange.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}

/// Status badge.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DisclosureStatus status;

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
