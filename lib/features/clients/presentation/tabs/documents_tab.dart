import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';

/// Immutable data class representing a mock document item.
class _MockDocument {
  const _MockDocument({
    required this.name,
    required this.type,
    required this.uploadDate,
    required this.icon,
  });

  final String name;
  final String type;
  final String uploadDate;
  final IconData icon;
}

/// Placeholder mock documents for the Documents tab.
const _mockDocuments = <_MockDocument>[
  _MockDocument(
    name: 'PAN Card',
    type: 'Identity',
    uploadDate: '15 Jan 2026',
    icon: Icons.credit_card,
  ),
  _MockDocument(
    name: 'Aadhaar Card',
    type: 'Identity',
    uploadDate: '15 Jan 2026',
    icon: Icons.fingerprint,
  ),
  _MockDocument(
    name: 'Form 16',
    type: 'Tax',
    uploadDate: '10 Jun 2025',
    icon: Icons.description,
  ),
  _MockDocument(
    name: 'Bank Statement',
    type: 'Financial',
    uploadDate: '01 Mar 2026',
    icon: Icons.account_balance,
  ),
  _MockDocument(
    name: 'GST Certificate',
    type: 'Registration',
    uploadDate: '20 Aug 2024',
    icon: Icons.verified_user,
  ),
];

/// Documents tab for the Client 360 screen.
///
/// Shows a list of mock documents with type badges and upload dates.
/// Includes an "Upload Document" button at the top.
class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Upload button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload Document'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Document list card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client Documents',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._mockDocuments.map(
                  (doc) => _DocumentRow(document: doc),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual document row
// ---------------------------------------------------------------------------

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document});

  final _MockDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Icon(document.icon, size: 18, color: AppColors.neutral600),
      ),
      title: Text(
        document.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              document.type,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            document.uploadDate,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.download,
          size: 18,
          color: AppColors.neutral400,
        ),
        onPressed: () {},
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
