import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ocr/data/providers/ocr_providers.dart';
import 'package:ca_app/features/ocr/presentation/widgets/confidence_chip.dart';

/// Card representing a single OCR document job in the queue or history.
///
/// Tapping a completed job navigates to the result screen.
class DocumentJobCard extends StatelessWidget {
  const DocumentJobCard({super.key, required this.job});

  final OcrJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      color: cs.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: job.status == OcrJobStatus.completed
            ? () => context.push('/ocr/result', extra: job)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DocumentIcon(documentType: job.document.documentType.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _DocumentTypeBadge(
                          label: _docTypeLabel(job.document.documentType.name),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(status: job.status),
                      ],
                    ),
                    if (job.status == OcrJobStatus.failed &&
                        job.errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        job.errorMessage!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (job.status == OcrJobStatus.completed) ...[
                const SizedBox(width: 8),
                ConfidenceChip(confidence: job.confidence),
              ],
              if (job.status == OcrJobStatus.processing) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _docTypeLabel(String name) {
    return switch (name) {
      'form16' => 'Form 16',
      'form16a' => 'Form 16A',
      'form26as' => 'Form 26AS',
      'bankStatement' => 'Bank Statement',
      'invoice' => 'Invoice',
      'panCard' => 'PAN Card',
      'aadhaarCard' => 'Aadhaar',
      'salarySlip' => 'Salary Slip',
      'gstCertificate' => 'GST Certificate',
      _ => name,
    };
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _DocumentIcon extends StatelessWidget {
  const _DocumentIcon({required this.documentType});

  final String documentType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_icon(documentType), color: AppColors.primary, size: 22),
    );
  }

  IconData _icon(String type) {
    return switch (type) {
      'bankStatement' => Icons.account_balance_outlined,
      'invoice' => Icons.receipt_long_outlined,
      'panCard' || 'aadhaarCard' => Icons.badge_outlined,
      'salarySlip' => Icons.payments_outlined,
      'gstCertificate' => Icons.verified_outlined,
      _ => Icons.description_outlined,
    };
  }
}

class _DocumentTypeBadge extends StatelessWidget {
  const _DocumentTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // blue-50
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF1D4ED8), // blue-700
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OcrJobStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _attrs(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String label, Color bg, Color fg) _attrs(OcrJobStatus status) {
    return switch (status) {
      OcrJobStatus.queued => (
        'Queued',
        const Color(0xFFF3F4F6),
        AppColors.neutral600,
      ),
      OcrJobStatus.processing => (
        'Processing',
        const Color(0xFFEFF6FF),
        const Color(0xFF1D4ED8),
      ),
      OcrJobStatus.completed => (
        'Completed',
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
      OcrJobStatus.failed => (
        'Failed',
        const Color(0xFFFEE2E2),
        const Color(0xFF991B1B),
      ),
    };
  }
}
