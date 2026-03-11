import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';

/// A list-tile card for a single [DscCertificate].
///
/// Displays cert icon, client name, issuer, formatted expiry date,
/// a days-to-expiry badge, and a token-type chip as trailing.
class DscCertificateTile extends StatelessWidget {
  const DscCertificateTile({super.key, required this.certificate});

  final DscCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon with status color
              _CertIcon(status: certificate.status),
              const SizedBox(width: 12),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: client name + days badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            certificate.clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DaysToExpiryBadge(certificate: certificate),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Row 2: cert holder name
                    Text(
                      certificate.certHolder,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Row 3: issuer + expiry + token type chip
                    Row(
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          certificate.issuedBy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.event_rounded,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(certificate.expiryDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        _TokenTypeChip(tokenType: certificate.tokenType),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _CertIcon extends StatelessWidget {
  const _CertIcon({required this.status});

  final DscStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.verified_user_rounded, size: 22, color: status.color),
    );
  }
}

class _DaysToExpiryBadge extends StatelessWidget {
  const _DaysToExpiryBadge({required this.certificate});

  final DscCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final String label;

    if (certificate.isExpired) {
      badgeColor = AppColors.error;
      label = 'Expired';
    } else if (certificate.isExpiringSoon) {
      final days = certificate.daysToExpiry;
      badgeColor = AppColors.warning;
      label = '${days}d left';
    } else {
      badgeColor = AppColors.success;
      final days = certificate.daysToExpiry;
      label = '${days}d';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _TokenTypeChip extends StatelessWidget {
  const _TokenTypeChip({required this.tokenType});

  final DscTokenType tokenType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tokenType.icon, size: 11, color: AppColors.primaryVariant),
          const SizedBox(width: 4),
          Text(
            tokenType.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primaryVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
