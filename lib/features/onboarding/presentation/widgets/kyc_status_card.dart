import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';

/// Displays a KYC record card with verification badges for Aadhaar and PAN.
class KycStatusCard extends StatelessWidget {
  const KycStatusCard({super.key, required this.record});

  final KycRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: name and status chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.clientName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _KycStatusChip(status: record.kycStatus),
              ],
            ),
            const SizedBox(height: 12),
            // Verification badges
            Row(
              children: [
                _VerificationBadge(
                  label: 'Aadhaar',
                  isVerified: record.aadhaarVerified,
                  icon: Icons.fingerprint_rounded,
                ),
                const SizedBox(width: 12),
                _VerificationBadge(
                  label: 'PAN',
                  isVerified: record.panVerified,
                  icon: Icons.credit_card_rounded,
                ),
                const SizedBox(width: 12),
                if (record.ckycKin.isNotEmpty)
                  _VerificationBadge(
                    label: 'CKYC',
                    isVerified: true,
                    icon: Icons.verified_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Remarks
            if (record.remarks.isNotEmpty)
              Text(
                record.remarks,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            // Footer: dates
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Submitted: ${_formatDate(record.submittedAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                if (record.verifiedAt != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.check_circle_outline,
                    size: 12,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verified: ${_formatDate(record.verifiedAt!)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
                if (record.expiryDate != null) ...[
                  const Spacer(),
                  Icon(
                    Icons.event_outlined,
                    size: 12,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${_formatDate(record.expiryDate!)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Status chip with color coding for KYC status.
class _KycStatusChip extends StatelessWidget {
  const _KycStatusChip({required this.status});

  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(KycStatus status) {
    switch (status) {
      case KycStatus.pending:
        return AppColors.neutral400;
      case KycStatus.documentsSubmitted:
        return AppColors.accent;
      case KycStatus.underVerification:
        return AppColors.warning;
      case KycStatus.verified:
        return AppColors.success;
      case KycStatus.rejected:
        return AppColors.error;
      case KycStatus.expired:
        return AppColors.error;
    }
  }
}

/// Badge showing verification status for a document type.
class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({
    required this.label,
    required this.isVerified,
    required this.icon,
  });

  final String label;
  final bool isVerified;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isVerified ? AppColors.success : AppColors.neutral400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel_outlined,
            size: 14,
            color: color,
          ),
        ],
      ),
    );
  }
}
