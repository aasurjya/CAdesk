import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ocr/data/providers/ocr_providers.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_document.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_extracted_data.dart';
import 'package:ca_app/features/ocr/presentation/widgets/confidence_chip.dart';
import 'package:ca_app/features/ocr/presentation/widgets/extracted_field_tile.dart';

/// Displays the structured extraction result for a completed OCR job.
///
/// Receives an [OcrJob] via GoRouter [extra] parameter.
class OcrResultScreen extends ConsumerStatefulWidget {
  const OcrResultScreen({super.key, required this.job});

  final OcrJob job;

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.job.result;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Extraction Result',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _editMode = !_editMode),
            icon: Icon(_editMode ? Icons.check_rounded : Icons.edit_outlined),
            tooltip: _editMode ? 'Done editing' : 'Edit fields',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final bodyWidth = isWide ? 680.0 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: bodyWidth,
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _DocumentHeader(
                            job: widget.job,
                            editMode: _editMode,
                          ),
                        ),
                        if (result != null &&
                            result.validationErrors.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _ValidationWarnings(
                              errors: result.validationErrors,
                            ),
                          ),
                        if (result != null)
                          SliverToBoxAdapter(
                            child: _ExtractedFieldsSection(
                              extractedData: result.extractedData,
                              editMode: _editMode,
                            ),
                          )
                        else
                          const SliverFillRemaining(
                            child: Center(
                              child: Text('No extraction result available.'),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ),
                  ),
                  _ActionBar(job: widget.job),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DocumentHeader
// ---------------------------------------------------------------------------

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader({required this.job, required this.editMode});

  final OcrJob job;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.fileName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _docTypeLabel(job.document.documentType),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${job.document.pageCount} page${job.document.pageCount == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          ConfidenceChip(confidence: job.confidence),
        ],
      ),
    );
  }

  String _docTypeLabel(DocumentType type) {
    return switch (type) {
      DocumentType.form16 => 'Form 16',
      DocumentType.form16a => 'Form 16A',
      DocumentType.form26as => 'Form 26AS',
      DocumentType.bankStatement => 'Bank Statement',
      DocumentType.invoice => 'Tax Invoice',
      DocumentType.panCard => 'PAN Card',
      DocumentType.aadhaarCard => 'Aadhaar Card',
      DocumentType.salarySlip => 'Salary Slip',
      DocumentType.gstCertificate => 'GST Certificate',
    };
  }
}

// ---------------------------------------------------------------------------
// _ValidationWarnings
// ---------------------------------------------------------------------------

class _ValidationWarnings extends StatelessWidget {
  const _ValidationWarnings({required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validation Warnings',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                ...errors.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '• $e',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ExtractedFieldsSection
// ---------------------------------------------------------------------------

class _ExtractedFieldsSection extends StatelessWidget {
  const _ExtractedFieldsSection({
    required this.extractedData,
    required this.editMode,
  });

  final OcrExtractedData extractedData;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fields = _fieldsFor(extractedData);

    if (fields.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No structured fields extracted for this document type.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral400,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'Extracted Fields',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const Divider(height: 1),
          ...fields.map(
            (f) => ExtractedFieldTile(
              fieldName: f.name,
              value: f.value,
              confidence: f.confidence,
              editMode: editMode,
            ),
          ),
        ],
      ),
    );
  }

  List<_FieldEntry> _fieldsFor(OcrExtractedData data) {
    return switch (data) {
      Form16ExtractedData(:final data) => [
        _FieldEntry(
          'Employee PAN',
          data.employeePan,
          data.employeePan.isNotEmpty ? 0.95 : 0.4,
        ),
        _FieldEntry(
          'Employer TAN',
          data.employerTan,
          data.employerTan.isNotEmpty ? 0.93 : 0.4,
        ),
        _FieldEntry('Employer Name', data.employerName, 0.88),
        _FieldEntry('Assessment Year', data.assessmentYear, 0.96),
        _FieldEntry(
          'Gross Salary',
          '₹${_formatPaise(data.grossSalary)}',
          data.grossSalary > 0 ? 0.92 : 0.5,
        ),
        _FieldEntry(
          'Standard Deduction',
          '₹${_formatPaise(data.standardDeduction)}',
          0.90,
        ),
        _FieldEntry(
          'Taxable Income',
          '₹${_formatPaise(data.taxableIncome)}',
          data.taxableIncome > 0 ? 0.91 : 0.5,
        ),
        _FieldEntry(
          'TDS Deducted',
          '₹${_formatPaise(data.tdsDeducted)}',
          data.tdsDeducted > 0 ? 0.89 : 0.45,
        ),
      ],
      BankStatementExtractedData(:final data) => [
        _FieldEntry('Account Number', data.accountNumber, 0.92),
        _FieldEntry('Bank Name', data.bankName, 0.90),
        _FieldEntry('IFSC Code', data.ifscCode, 0.91),
        _FieldEntry('Period', data.period, 0.85),
        _FieldEntry(
          'Opening Balance',
          '₹${_formatPaise(data.openingBalance)}',
          0.88,
        ),
        _FieldEntry(
          'Closing Balance',
          '₹${_formatPaise(data.closingBalance)}',
          0.88,
        ),
        _FieldEntry(
          'Transactions',
          '${data.transactions.length} entries',
          0.85,
        ),
      ],
      InvoiceExtractedData(:final data) => [
        _FieldEntry('Invoice Number', data.invoiceNumber, 0.91),
        _FieldEntry(
          'Invoice Date',
          data.invoiceDate != null
              ? '${data.invoiceDate!.day.toString().padLeft(2, '0')}-'
                    '${data.invoiceDate!.month.toString().padLeft(2, '0')}-'
                    '${data.invoiceDate!.year}'
              : '',
          data.invoiceDate != null ? 0.87 : 0.4,
        ),
        _FieldEntry('Seller Name', data.sellerName, 0.88),
        _FieldEntry('Seller GSTIN', data.sellerGstin ?? '', 0.82),
        _FieldEntry('Buyer Name', data.buyerName, 0.86),
        _FieldEntry('Buyer GSTIN', data.buyerGstin ?? '', 0.82),
        _FieldEntry(
          'Total Amount',
          '₹${_formatPaise(data.totalAmount)}',
          data.totalAmount > 0 ? 0.90 : 0.4,
        ),
        _FieldEntry(
          'GST Amount',
          '₹${_formatPaise(data.gstAmount)}',
          data.gstAmount > 0 ? 0.88 : 0.45,
        ),
      ],
      UnknownExtractedData() => const [],
    };
  }

  String _formatPaise(int paise) {
    final inr = paise / 100;
    // Format with Indian comma system up to 2 decimal places
    final intPart = inr.truncate();
    final formatted = _indianFormat(intPart);
    final decPart = ((inr - intPart) * 100).round();
    return '$formatted.${decPart.toString().padLeft(2, '0')}';
  }

  String _indianFormat(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buffer = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i != 0 && (rest.length - i) % 2 == 0) buffer.write(',');
      buffer.write(rest[i]);
    }
    return '${buffer.toString()},$last3';
  }
}

class _FieldEntry {
  const _FieldEntry(this.name, this.value, this.confidence);

  final String name;
  final String value;
  final double confidence;
}

// ---------------------------------------------------------------------------
// _ActionBar
// ---------------------------------------------------------------------------

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.job});

  final OcrJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Re-process'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data confirmed and ready for use.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.pop();
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text(
                'Confirm & Use',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
