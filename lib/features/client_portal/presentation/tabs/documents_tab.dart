import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document_ui.dart';
import 'package:ca_app/features/client_portal/data/providers/client_portal_providers.dart';
import 'package:ca_app/features/client_portal/presentation/widgets/shared_document_tile.dart';

/// Tab displaying shared documents with signature status filtering.
class DocumentsTab extends ConsumerWidget {
  const DocumentsTab({super.key});

  static const _filters = <SignatureStatus?>[
    null,
    SignatureStatus.pending,
    SignatureStatus.signed,
    SignatureStatus.rejected,
  ];

  static const _filterLabels = <String>['All', 'Pending', 'Signed', 'Rejected'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(filteredDocumentsProvider);
    final activeFilter = ref.watch(documentFilterProvider);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _DocumentsBanner(),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = activeFilter == filter;
              return FilterChip(
                label: Text(
                  _filterLabels[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.neutral600,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => ref
                    .read(documentFilterProvider.notifier)
                    .update(isSelected ? null : filter),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.neutral50,
                checkmarkColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.neutral200,
                ),
              );
            },
          ),
        ),
        // Documents list
        Expanded(
          child: documents.isEmpty
              ? const _EmptyDocuments()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: documents.length,
                  itemBuilder: (context, index) => SharedDocumentTile(
                    document: documents[index],
                    onTap: () =>
                        _showDocumentDetails(context, documents[index]),
                  ),
                ),
        ),
      ],
    );
  }

  void _showDocumentDetails(BuildContext context, SharedDocument document) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _DocumentDetailSheet(document: document),
    );
  }
}

class _DocumentsBanner extends StatelessWidget {
  const _DocumentsBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.folder_shared_outlined,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shared documents',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Filter signature status, review recent uploads, and keep required client actions visible.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDocuments extends StatelessWidget {
  const _EmptyDocuments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              size: 36,
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No documents found',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}

class _DocumentDetailSheet extends StatelessWidget {
  const _DocumentDetailSheet({required this.document});

  final SharedDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            document.documentName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _DetailRow(label: 'Type', value: document.documentType),
          _DetailRow(label: 'Uploaded by', value: document.uploadedBy),
          _DetailRow(
            label: 'Upload date',
            value: _formatDate(document.uploadedAt),
          ),
          if (document.expiresAt != null)
            _DetailRow(
              label: 'Expires',
              value: _formatDate(document.expiresAt!),
            ),
          if (document.isSignatureRequired)
            _DetailRow(
              label: 'Signature',
              value: document.signatureStatus.label,
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.download),
              label: const Text('Download Document'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
          if (document.isSignatureRequired &&
              document.signatureStatus == SignatureStatus.pending) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.draw),
                label: const Text('Sign Document'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: const BorderSide(color: AppColors.success),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
