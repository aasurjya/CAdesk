import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';

/// Card displaying a startup entity with DPIIT badge,
/// 80-IAC status, turnover gauge, and investment rounds.
class StartupCard extends StatelessWidget {
  const StartupCard({super.key, required this.startup});

  final StartupEntity startup;

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
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup.entityName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _DpiitBadge(number: startup.dpiitNumber),
                          const SizedBox(width: 8),
                          _RecognitionBadge(status: startup.recognitionStatus),
                        ],
                      ),
                    ],
                  ),
                ),
                _Section80IACBadge(status: startup.section80IACStatus),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Info row
            Row(
              children: [
                _InfoChip(icon: Icons.category_rounded, label: startup.sector),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: dateFormat.format(startup.incorporationDate),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Turnover gauge
            _TurnoverGauge(
              turnover: startup.turnover,
              isBelow100Cr: startup.isBelow100Cr,
              currencyFormat: currencyFormat,
            ),
            // Tax holiday info
            if (startup.taxHolidayStartYear != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tax Holiday: ${startup.taxHolidayStartYear} - '
                      '${startup.taxHolidayEndYear}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Investment rounds
            if (startup.investmentRounds.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Funding Rounds',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 4),
              ...startup.investmentRounds.map(
                (round) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${round.roundName}: '
                        '${currencyFormat.format(round.amount)} '
                        '(${round.investor})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small DPIIT number badge.
class _DpiitBadge extends StatelessWidget {
  const _DpiitBadge({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        number,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Recognition status badge.
class _RecognitionBadge extends StatelessWidget {
  const _RecognitionBadge({required this.status});

  final RecognitionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 10, color: status.color),
          const SizedBox(width: 3),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 80-IAC status badge.
class _Section80IACBadge extends StatelessWidget {
  const _Section80IACBadge({required this.status});

  final Section80IACStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(status.icon, size: 16, color: status.color),
          const SizedBox(height: 2),
          Text(
            '80-IAC',
            style: TextStyle(
              color: status.color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            status.label,
            style: TextStyle(color: status.color, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

/// Small icon + label chip for info display.
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

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
          style: const TextStyle(color: AppColors.neutral600, fontSize: 12),
        ),
      ],
    );
  }
}

/// Visual turnover gauge with 100 Cr threshold indicator.
class _TurnoverGauge extends StatelessWidget {
  const _TurnoverGauge({
    required this.turnover,
    required this.isBelow100Cr,
    required this.currencyFormat,
  });

  final double turnover;
  final bool isBelow100Cr;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (turnover / 1000000000).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Turnover: ${currencyFormat.format(turnover)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              isBelow100Cr ? 'Below 100 Cr' : 'Above 100 Cr',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isBelow100Cr ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isBelow100Cr ? AppColors.success : AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}
