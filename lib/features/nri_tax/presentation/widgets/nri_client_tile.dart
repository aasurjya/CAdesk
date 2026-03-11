import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/nri_tax/domain/models/nri_client.dart';

/// A card tile displaying a single NRI client with status, country, and DTAA
/// information.
class NriClientTile extends StatelessWidget {
  const NriClientTile({super.key, required this.client});

  final NriClient client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              // Row 1: flag + name + status chip
              Row(
                children: [
                  Text(
                    _flagEmoji(client.countryOfResidence),
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      client.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: client.status),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: residential status badge + country
              Row(
                children: [
                  _ResidentialBadge(status: client.residentialStatus),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.public_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    client.countryOfResidence,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 3: stay days + DTAA badge
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${client.stayDaysIndia} days in India',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.currency_rupee_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'India: ${client.formattedIndianIncome}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (client.dtaaApplicable) const _DtaaBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a country flag emoji for known countries; defaults to globe.
  static String _flagEmoji(String country) {
    const flags = <String, String>{
      'USA': '🇺🇸',
      'UK': '🇬🇧',
      'UAE': '🇦🇪',
      'Canada': '🇨🇦',
      'Singapore': '🇸🇬',
      'Australia': '🇦🇺',
      'Germany': '🇩🇪',
      'India': '🇮🇳',
      'Japan': '🇯🇵',
      'France': '🇫🇷',
      'Netherlands': '🇳🇱',
      'New Zealand': '🇳🇿',
    };
    return flags[country] ?? '🌐';
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final NriClientStatus status;

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
          Icon(status.icon, size: 11, color: status.color),
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

class _ResidentialBadge extends StatelessWidget {
  const _ResidentialBadge({required this.status});

  final ResidentialStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _DtaaBadge extends StatelessWidget {
  const _DtaaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'DTAA',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
