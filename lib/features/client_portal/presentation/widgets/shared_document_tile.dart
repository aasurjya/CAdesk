import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document_ui.dart';

/// Tile widget for displaying a shared document with signature status indicator.
class SharedDocumentTile extends StatelessWidget {
  const SharedDocumentTile({super.key, required this.document, this.onTap});

  final SharedDocument document;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _DocumentIcon(documentType: document.documentType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.documentName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          document.documentType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('d MMM yyyy').format(document.uploadedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            document.uploadedBy,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (document.isSignatureRequired)
                    _SignatureStatusBadge(status: document.signatureStatus),
                  if (document.isExpired) ...[
                    const SizedBox(height: 4),
                    const _ExpiredBadge(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentIcon extends StatelessWidget {
  const _DocumentIcon({required this.documentType});

  final String documentType;

  IconData get _icon {
    final type = documentType.toLowerCase();
    if (type.contains('form 16') || type.contains('itr')) {
      return Icons.receipt_long;
    }
    if (type.contains('gst') || type.contains('return')) {
      return Icons.receipt;
    }
    if (type.contains('audit')) return Icons.verified;
    if (type.contains('tds')) return Icons.description;
    if (type.contains('invoice')) return Icons.payments;
    if (type.contains('corporate') || type.contains('board')) {
      return Icons.gavel;
    }
    if (type.contains('trust')) return Icons.account_balance;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_icon, size: 20, color: AppColors.primary),
    );
  }
}

class _SignatureStatusBadge extends StatelessWidget {
  const _SignatureStatusBadge({required this.status});

  final SignatureStatus status;

  Color get _color {
    switch (status) {
      case SignatureStatus.signed:
        return AppColors.success;
      case SignatureStatus.pending:
        return AppColors.warning;
      case SignatureStatus.rejected:
        return AppColors.error;
      case SignatureStatus.expired:
        return AppColors.neutral400;
      case SignatureStatus.notRequired:
        return AppColors.neutral400;
    }
  }

  IconData get _icon {
    switch (status) {
      case SignatureStatus.signed:
        return Icons.check_circle;
      case SignatureStatus.pending:
        return Icons.pending;
      case SignatureStatus.rejected:
        return Icons.cancel;
      case SignatureStatus.expired:
        return Icons.timer_off;
      case SignatureStatus.notRequired:
        return Icons.remove_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiredBadge extends StatelessWidget {
  const _ExpiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Expired',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
      ),
    );
  }
}
