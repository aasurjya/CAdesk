import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _OcrStatus { queued, processing, completed, failed }

extension _OcrStatusExt on _OcrStatus {
  String get label => switch (this) {
    _OcrStatus.queued => 'Queued',
    _OcrStatus.processing => 'Processing',
    _OcrStatus.completed => 'Completed',
    _OcrStatus.failed => 'Failed',
  };
  Color get color => switch (this) {
    _OcrStatus.queued => AppColors.neutral400,
    _OcrStatus.processing => AppColors.accent,
    _OcrStatus.completed => AppColors.success,
    _OcrStatus.failed => AppColors.error,
  };
}

class _OcrDocument {
  const _OcrDocument({
    required this.id,
    required this.fileName,
    required this.clientName,
    required this.docType,
    required this.status,
    required this.confidence,
    required this.extractedFields,
    required this.uploadedAt,
  });

  final String id;
  final String fileName;
  final String clientName;
  final String docType;
  final _OcrStatus status;
  final double confidence;
  final int extractedFields;
  final String uploadedAt;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockDocuments = <_OcrDocument>[
  const _OcrDocument(
    id: 'OCR-001',
    fileName: 'Form16_Sharma_AY2627.pdf',
    clientName: 'Rajesh Sharma',
    docType: 'Form 16',
    status: _OcrStatus.completed,
    confidence: 0.97,
    extractedFields: 18,
    uploadedAt: '17 Mar, 09:12',
  ),
  const _OcrDocument(
    id: 'OCR-002',
    fileName: 'Bank_Statement_Q3.pdf',
    clientName: 'Priya Traders LLP',
    docType: 'Bank Statement',
    status: _OcrStatus.completed,
    confidence: 0.89,
    extractedFields: 42,
    uploadedAt: '17 Mar, 09:05',
  ),
  const _OcrDocument(
    id: 'OCR-003',
    fileName: 'Invoice_Batch_March.zip',
    clientName: 'AK Enterprises Pvt Ltd',
    docType: 'Invoices',
    status: _OcrStatus.processing,
    confidence: 0.0,
    extractedFields: 0,
    uploadedAt: '17 Mar, 08:55',
  ),
  const _OcrDocument(
    id: 'OCR-004',
    fileName: 'TDS_Certificate_Q4.pdf',
    clientName: 'Meena Gupta',
    docType: 'TDS Certificate',
    status: _OcrStatus.queued,
    confidence: 0.0,
    extractedFields: 0,
    uploadedAt: '17 Mar, 08:50',
  ),
  const _OcrDocument(
    id: 'OCR-005',
    fileName: 'Rent_Agreement.pdf',
    clientName: 'Sunil Kumar',
    docType: 'Rent Agreement',
    status: _OcrStatus.failed,
    confidence: 0.0,
    extractedFields: 0,
    uploadedAt: '16 Mar, 18:30',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// OCR Hub screen for document processing pipeline.
class OcrHubScreen extends ConsumerWidget {
  const OcrHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final completedCount = _mockDocuments
        .where((d) => d.status == _OcrStatus.completed)
        .length;
    final avgConfidence = _averageConfidence();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OCR Hub',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Document processing pipeline',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload dialog coming soon')),
                );
              },
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Upload'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Row(
            children: [
              SummaryCard(
                label: 'Total',
                value: '${_mockDocuments.length}',
                icon: Icons.description_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Completed',
                value: '$completedCount',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Avg Confidence',
                value: avgConfidence,
                icon: Icons.insights_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Batch controls
          _BatchControls(),
          const SizedBox(height: 20),

          // Upload queue
          SectionHeader(title: 'Processing Queue', icon: Icons.queue_rounded),
          const SizedBox(height: 10),
          ..._mockDocuments.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DocumentCard(document: doc),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _averageConfidence() {
    final completed = _mockDocuments.where((d) => d.confidence > 0).toList();
    if (completed.isEmpty) return '--';
    final avg =
        completed.fold<double>(0, (s, d) => s + d.confidence) /
        completed.length;
    return '${(avg * 100).round()}%';
  }
}

// ---------------------------------------------------------------------------
// Batch controls
// ---------------------------------------------------------------------------

class _BatchControls extends StatelessWidget {
  const _BatchControls();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(
              Icons.batch_prediction_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Batch Processing',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Process All'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: BorderSide(color: AppColors.success.withAlpha(60)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry Failed'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: BorderSide(color: AppColors.accent.withAlpha(60)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document card
// ---------------------------------------------------------------------------

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final _OcrDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: document.status.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: document.status.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.fileName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${document.clientName}  •  ${document.docType}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: document.status.label,
                  color: document.status.color,
                ),
              ],
            ),
            if (document.status == _OcrStatus.completed) ...[
              const Divider(height: 16),
              Row(
                children: [
                  _OcrMetric(
                    label: 'Confidence',
                    value: '${(document.confidence * 100).round()}%',
                    color: document.confidence >= 0.9
                        ? AppColors.success
                        : AppColors.accent,
                  ),
                  const SizedBox(width: 20),
                  _OcrMetric(
                    label: 'Fields',
                    value: '${document.extractedFields}',
                    color: AppColors.primary,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View Results'),
                  ),
                ],
              ),
            ],
            if (document.status == _OcrStatus.processing) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

class _OcrMetric extends StatelessWidget {
  const _OcrMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
