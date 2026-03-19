import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';
import 'package:ca_app/features/documents/data/providers/document_viewer_providers.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

/// Full-screen document viewer.
///
/// Switches body content by file type: PDF placeholder, InteractiveViewer for
/// images, metadata+open for Excel/Word, scrollable text view, etc.
class DocumentViewerScreen extends ConsumerStatefulWidget {
  const DocumentViewerScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  int _currentPage = 1;
  final int _totalPages = 5; // mock
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    final doc = ref.watch(selectedDocumentProvider(widget.documentId));

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: const Center(child: Text('Document not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: _buildAppBar(doc),
      body: Column(
        children: [
          // Document body
          Expanded(child: _buildDocumentBody(doc)),

          // Bottom bar: page nav + zoom
          if (doc.fileType == DocumentFileType.pdf ||
              doc.fileType == DocumentFileType.image)
            _BottomControls(
              currentPage: _currentPage,
              totalPages: _totalPages,
              zoomLevel: _zoomLevel,
              showPageNav: doc.fileType == DocumentFileType.pdf,
              onPageChanged: (page) => setState(() => _currentPage = page),
              onZoomChanged: (zoom) => setState(() => _zoomLevel = zoom),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'document_viewer_ocr',
        onPressed: () => context.push('/documents/ocr/${doc.id}'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        tooltip: 'OCR Extract',
        child: const Icon(Icons.document_scanner_rounded),
      ),
    );
  }

  AppBar _buildAppBar(Document doc) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doc.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            doc.clientName,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      centerTitle: false,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.neutral900,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, size: 20),
          tooltip: 'Share',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.download_rounded, size: 20),
          tooltip: 'Download',
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          onSelected: (value) {},
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'rename', child: Text('Rename')),
            PopupMenuItem(value: 'move', child: Text('Move to folder')),
            PopupMenuItem(value: 'tags', child: Text('Edit tags')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentBody(Document doc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Primary content area
        _buildContentArea(doc),
        const SizedBox(height: 20),

        // Metadata section
        _MetadataSection(document: doc),
        const SizedBox(height: 16),

        // Version history
        _VersionHistorySection(documentId: widget.documentId),
      ],
    );
  }

  Widget _buildContentArea(Document doc) {
    switch (doc.fileType) {
      case DocumentFileType.pdf:
        return _PdfPlaceholder(
          currentPage: _currentPage,
          totalPages: _totalPages,
        );
      case DocumentFileType.image:
        return _ImageViewer(zoomLevel: _zoomLevel);
      case DocumentFileType.excel:
      case DocumentFileType.word:
        return _OfficeDocPlaceholder(document: doc);
      case DocumentFileType.zip:
        return _OfficeDocPlaceholder(document: doc);
    }
  }
}

// ---------------------------------------------------------------------------
// PDF placeholder
// ---------------------------------------------------------------------------

class _PdfPlaceholder extends StatelessWidget {
  const _PdfPlaceholder({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Color(0xFFC62828),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PDF Viewer',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Page $currentPage of $totalPages',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add a PDF rendering package\nto enable inline viewing.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image viewer with zoom
// ---------------------------------------------------------------------------

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.zoomLevel});

  final double zoomLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A).withAlpha(18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_rounded,
                    color: Color(0xFF6A1B9A),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Image Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pinch to zoom / Scroll to pan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Office doc placeholder (Excel / Word / ZIP)
// ---------------------------------------------------------------------------

class _OfficeDocPlaceholder extends StatelessWidget {
  const _OfficeDocPlaceholder({required this.document});

  final Document document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _fileTypeColor(document.fileType);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: typeColor.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _fileTypeIcon(document.fileType),
              color: typeColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            document.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${document.fileType.label} file  ·  ${document.fileSizeLabel}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Open in...'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metadata section
// ---------------------------------------------------------------------------

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.document});

  final Document document;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Details',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 12),
          _MetaRow(label: 'File Size', value: document.fileSizeLabel),
          _MetaRow(
            label: 'Uploaded',
            value: _dateFormat.format(document.uploadedAt),
          ),
          _MetaRow(label: 'Uploaded By', value: document.uploadedBy),
          _MetaRow(label: 'Client', value: document.clientName),
          _MetaRow(label: 'Category', value: document.category.label),
          _MetaRow(label: 'Version', value: 'v${document.version}'),
          _MetaRow(
            label: 'Downloads',
            value: document.downloadCount.toString(),
          ),
          if (document.remarks != null)
            _MetaRow(label: 'Remarks', value: document.remarks!),
          if (document.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: document.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.primary.withAlpha(12),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Version history section
// ---------------------------------------------------------------------------

class _VersionHistorySection extends ConsumerWidget {
  const _VersionHistorySection({required this.documentId});

  final String documentId;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versions = ref.watch(documentVersionsProvider(documentId));
    if (versions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Version History',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 12),
          ...versions.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  StatusBadge(label: 'v${v.version}', color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.uploadedBy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          _dateFormat.format(v.uploadedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (v.remarks != null)
                    Tooltip(
                      message: v.remarks!,
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.neutral400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom controls bar
// ---------------------------------------------------------------------------

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.zoomLevel,
    required this.showPageNav,
    required this.onPageChanged,
    required this.onZoomChanged,
  });

  final int currentPage;
  final int totalPages;
  final double zoomLevel;
  final bool showPageNav;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<double> onZoomChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showPageNav) ...[
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                visualDensity: VisualDensity.compact,
              ),
              Text(
                '$currentPage / $totalPages',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 16),
            ],
            IconButton(
              icon: const Icon(Icons.zoom_out_rounded, size: 22),
              onPressed: zoomLevel > 0.5
                  ? () => onZoomChanged((zoomLevel - 0.25).clamp(0.5, 4.0))
                  : null,
              visualDensity: VisualDensity.compact,
            ),
            Text(
              '${(zoomLevel * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in_rounded, size: 22),
              onPressed: zoomLevel < 4.0
                  ? () => onZoomChanged((zoomLevel + 0.25).clamp(0.5, 4.0))
                  : null,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File type helpers
// ---------------------------------------------------------------------------

Color _fileTypeColor(DocumentFileType type) {
  switch (type) {
    case DocumentFileType.pdf:
      return const Color(0xFFC62828);
    case DocumentFileType.excel:
      return const Color(0xFF1A7A3A);
    case DocumentFileType.word:
      return const Color(0xFF1565C0);
    case DocumentFileType.image:
      return const Color(0xFF6A1B9A);
    case DocumentFileType.zip:
      return const Color(0xFF4A5568);
  }
}

IconData _fileTypeIcon(DocumentFileType type) {
  switch (type) {
    case DocumentFileType.pdf:
      return Icons.picture_as_pdf_rounded;
    case DocumentFileType.excel:
      return Icons.table_chart_rounded;
    case DocumentFileType.word:
      return Icons.description_rounded;
    case DocumentFileType.image:
      return Icons.image_rounded;
    case DocumentFileType.zip:
      return Icons.folder_zip_rounded;
  }
}
