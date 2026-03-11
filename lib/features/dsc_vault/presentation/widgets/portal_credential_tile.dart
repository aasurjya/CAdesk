import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';

/// A list-tile card for a single [PortalCredential].
///
/// Displays portal icon, portal name, client name, masked user ID,
/// consent status badge, and last-updated relative time.
class PortalCredentialTile extends StatelessWidget {
  const PortalCredentialTile({super.key, required this.credential});

  final PortalCredential credential;

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading portal icon
              _PortalIcon(portalName: credential.portalName),
              const SizedBox(width: 12),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: portal name + status chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            credential.portalName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(status: credential.status),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Row 2: client name
                    Text(
                      credential.clientName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Row 3: masked user ID + consent + last updated
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          credential.maskedUserId,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ConsentBadge(credential: credential),
                        const Spacer(),
                        Icon(
                          Icons.update_rounded,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _agoText(credential.lastUpdatedAt),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a human-readable "X ago" string relative to now.
  String _agoText(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '${years}y ago';
    }
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _PortalIcon extends StatelessWidget {
  const _PortalIcon({required this.portalName});

  final String portalName;

  IconData get _icon {
    final name = portalName.toLowerCase();
    if (name.contains('income tax') || name.contains('it portal')) {
      return Icons.account_balance_rounded;
    }
    if (name.contains('gst')) return Icons.receipt_long_rounded;
    if (name.contains('mca')) return Icons.domain_rounded;
    if (name.contains('traces')) return Icons.find_in_page_rounded;
    return Icons.language_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_icon, size: 22, color: AppColors.secondary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PortalCredStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 10, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentBadge extends StatelessWidget {
  const _ConsentBadge({required this.credential});

  final PortalCredential credential;

  @override
  Widget build(BuildContext context) {
    final isActive = credential.isConsentActive;
    final color = isActive ? AppColors.success : AppColors.neutral400;
    final label = isActive ? 'Consent ✓' : 'No Consent';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
