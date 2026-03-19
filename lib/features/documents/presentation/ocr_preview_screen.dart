import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';
import 'package:ca_app/features/documents/data/providers/document_viewer_providers.dart';
import 'package:ca_app/features/documents/presentation/widgets/ocr_field_tile.dart';

/// OCR text extraction preview screen.
///
/// Uses [ResponsiveDetailLayout] to show a split view:
/// - Phone: vertical stack (image top, fields bottom)
/// - Tablet/Desktop: horizontal split (image left, fields right)
class OcrPreviewScreen extends ConsumerWidget {
  const OcrPreviewScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(selectedDocumentProvider(documentId));

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('OCR Preview')),
        body: const Center(child: Text('Document not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OCR Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              doc.title,
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
      ),
      body: ResponsiveDetailLayout(
        breakpoint: 700,
        listPane: _DocumentImagePane(documentId: documentId),
        detailPane: _ExtractedFieldsPane(documentId: documentId),
      ),
      bottomNavigationBar: _AcceptBar(documentId: documentId),
    );
  }
}

// ---------------------------------------------------------------------------
// Document image pane (left / top)
// ---------------------------------------------------------------------------

class _DocumentImagePane extends ConsumerWidget {
  const _DocumentImagePane({required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fields = ref.watch(ocrResultProvider);

    return Container(
      color: AppColors.neutral50,
      child: Stack(
        children: [
          // Document image placeholder with bounding-box overlays
          Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutral200),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CustomPaint(
                      painter: _BoundingBoxPainter(fieldCount: fields.length),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.document_scanner_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Document Image',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${fields.length} fields detected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bounding box legend
          Positioned(
            bottom: 24,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(230),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: AppColors.success, label: '>90%'),
                  SizedBox(width: 10),
                  _LegendDot(color: AppColors.warning, label: '70-90%'),
                  SizedBox(width: 10),
                  _LegendDot(color: AppColors.error, label: '<70%'),
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
// Extracted fields pane (right / bottom)
// ---------------------------------------------------------------------------

class _ExtractedFieldsPane extends ConsumerWidget {
  const _ExtractedFieldsPane({required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(ocrResultProvider);

    return Container(
      color: AppColors.neutral50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const SectionHeader(
                  title: 'Extracted Fields',
                  icon: Icons.text_fields_rounded,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${fields.length} fields',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Average confidence
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ConfidenceSummary(fields: fields),
          ),
          const SizedBox(height: 8),

          // Field tiles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
                return OcrFieldTile(
                  field: field,
                  onValueChanged: (newValue) {
                    ref
                        .read(ocrResultProvider.notifier)
                        .updateField(index, newValue);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confidence summary bar
// ---------------------------------------------------------------------------

class _ConfidenceSummary extends StatelessWidget {
  const _ConfidenceSummary({required this.fields});

  final List<OcrField> fields;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) return const SizedBox.shrink();

    final avg =
        fields.fold<double>(0, (sum, f) => sum + f.confidence) / fields.length;
    final avgPercent = (avg * 100).toStringAsFixed(0);
    final color = _confidenceColor(avg);

    final highCount = fields.where((f) => f.confidence >= 0.9).length;
    final medCount = fields
        .where((f) => f.confidence >= 0.7 && f.confidence < 0.9)
        .length;
    final lowCount = fields.where((f) => f.confidence < 0.7).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            'Avg. confidence: $avgPercent%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Spacer(),
          _ConfidenceCount(
            count: highCount,
            color: AppColors.success,
            label: 'High',
          ),
          const SizedBox(width: 8),
          _ConfidenceCount(
            count: medCount,
            color: AppColors.warning,
            label: 'Med',
          ),
          const SizedBox(width: 8),
          _ConfidenceCount(
            count: lowCount,
            color: AppColors.error,
            label: 'Low',
          ),
        ],
      ),
    );
  }

  static Color _confidenceColor(double confidence) {
    if (confidence >= 0.9) return AppColors.success;
    if (confidence >= 0.7) return AppColors.warning;
    return AppColors.error;
  }
}

class _ConfidenceCount extends StatelessWidget {
  const _ConfidenceCount({
    required this.count,
    required this.color,
    required this.label,
  });

  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Accept & Save bottom bar
// ---------------------------------------------------------------------------

class _AcceptBar extends ConsumerWidget {
  const _AcceptBar({required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(ocrResultProvider);
    final lowConfidence = fields.where((f) => f.confidence < 0.7).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (lowConfidence > 0)
              Expanded(
                child: Text(
                  '$lowConfidence field${lowConfidence > 1 ? 's' : ''} with low confidence',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (lowConfidence == 0) const Spacer(),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OCR data saved successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Accept & Save'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bounding box painter (mock visual overlay)
// ---------------------------------------------------------------------------

class _BoundingBoxPainter extends CustomPainter {
  _BoundingBoxPainter({required this.fieldCount});

  final int fieldCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final highPaint = Paint()
      ..color = AppColors.success.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final medPaint = Paint()
      ..color = AppColors.warning.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final lowPaint = Paint()
      ..color = AppColors.error.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw mock bounding boxes distributed across the "document"
    final boxHeight = size.height * 0.06;
    final margin = size.width * 0.08;
    final usableWidth = size.width - margin * 2;

    for (int i = 0; i < fieldCount && i < 7; i++) {
      final y = margin + i * (boxHeight + 12);
      final width = usableWidth * (0.4 + (i % 3) * 0.15);
      final paint = i < 4 ? highPaint : (i < 6 ? medPaint : lowPaint);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(margin, y, width, boxHeight),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoundingBoxPainter oldDelegate) =>
      oldDelegate.fieldCount != fieldCount;
}

// ---------------------------------------------------------------------------
// Legend dot
// ---------------------------------------------------------------------------

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
        ),
      ],
    );
  }
}
