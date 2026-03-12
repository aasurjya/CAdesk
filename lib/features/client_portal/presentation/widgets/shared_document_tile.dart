import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document_ui.dart';

/// Tile widget for displaying a shared document with e-sign and status badges.
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
                      document.title,
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
                          document.documentType.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('d MMM yyyy').format(document.sharedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: document.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (document.requiresESign)
                    _ESignBadge(signed: document.eSigned),
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

  final DocumentType documentType;

  IconData get _icon {
    switch (documentType) {
      case DocumentType.itrV:
        return Icons.receipt_long;
      case DocumentType.form16:
        return Icons.receipt_long;
      case DocumentType.gstCertificate:
        return Icons.receipt;
      case DocumentType.auditReport:
        return Icons.verified;
      case DocumentType.invoice:
        return Icons.payments;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DocumentStatus status;

  Color get _color {
    switch (status) {
      case DocumentStatus.shared:
        return AppColors.neutral400;
      case DocumentStatus.viewed:
        return AppColors.primary;
      case DocumentStatus.downloaded:
        return AppColors.secondary;
      case DocumentStatus.eSigned:
        return AppColors.success;
      case DocumentStatus.expired:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      status.label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: _color,
      ),
    );
  }
}

class _ESignBadge extends StatelessWidget {
  const _ESignBadge({required this.signed});

  final bool signed;

  @override
  Widget build(BuildContext context) {
    final color = signed ? AppColors.success : AppColors.warning;
    final label = signed ? 'Signed' : 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            signed ? Icons.check_circle : Icons.pending,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


