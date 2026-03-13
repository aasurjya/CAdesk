import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ocr/data/providers/ocr_providers.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_document.dart';

/// Document type option shown in the selector.
class _DocTypeOption {
  const _DocTypeOption({
    required this.label,
    required this.documentType,
    required this.icon,
  });

  final String label;
  final DocumentType documentType;
  final IconData icon;
}

const _docTypeOptions = <_DocTypeOption>[
  _DocTypeOption(
    label: 'Form 16',
    documentType: DocumentType.form16,
    icon: Icons.description_outlined,
  ),
  _DocTypeOption(
    label: 'Form 26AS',
    documentType: DocumentType.form26as,
    icon: Icons.account_tree_outlined,
  ),
  _DocTypeOption(
    label: 'Bank Statement',
    documentType: DocumentType.bankStatement,
    icon: Icons.account_balance_outlined,
  ),
  _DocTypeOption(
    label: 'Invoice',
    documentType: DocumentType.invoice,
    icon: Icons.receipt_long_outlined,
  ),
  _DocTypeOption(
    label: 'Salary Slip',
    documentType: DocumentType.salarySlip,
    icon: Icons.payments_outlined,
  ),
];

/// Upload / submit screen for a new OCR job.
class OcrUploadScreen extends ConsumerStatefulWidget {
  const OcrUploadScreen({super.key});

  @override
  ConsumerState<OcrUploadScreen> createState() => _OcrUploadScreenState();
}

class _OcrUploadScreenState extends ConsumerState<OcrUploadScreen> {
  DocumentType _selectedType = DocumentType.form16;
  final _fileNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _submitDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final doc = OcrDocument(
      documentId: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      documentType: _selectedType,
      rawText: _mockRawText(_selectedType),
      confidence: 0.87,
      extractedAt: DateTime.now(),
      pageCount: 1,
      processingStatus: ProcessingStatus.pending,
    );

    await ref
        .read(ocrJobListProvider.notifier)
        .submitJob(doc, _fileNameController.text.trim());

    if (mounted) {
      setState(() => _isProcessing = false);
      context.pop();
    }
  }

  /// Returns minimal mock raw text so the pipeline can run extraction.
  String _mockRawText(DocumentType type) {
    return switch (type) {
      DocumentType.form16 || DocumentType.form16a =>
        'FORM NO. 16\n'
            'Name and address of the Employer: Mock Employer Ltd\n'
            'Assessment Year: 2025-26\n'
            'TAN of Deductor: ABCDE1234F\n'
            'PAN of Employee: FGHIJ5678K\n'
            'Gross Salary: 800000\n'
            'Standard Deduction: 50000\n'
            'Taxable Income: 750000\n'
            'Tax Deducted: 62500',
      DocumentType.bankStatement =>
        'STATEMENT OF ACCOUNT\n'
            'Account Number: XXXXXX9876\n'
            'IFSC: SBIN0001001\n'
            'Opening Balance: 50000.00\n'
            'Closing Balance: 48250.75',
      DocumentType.invoice || DocumentType.gstCertificate =>
        'TAX INVOICE\n'
            'Invoice No.: INV-MOCK-001\n'
            'Invoice Date: 12-03-2026\n'
            'Seller: Mock Seller Co.\n'
            'Buyer: Mock Buyer Ltd\n'
            'Total Amount: 118000\n'
            'GST Amount: 18000',
      DocumentType.form26as =>
        'FORM 26AS\nTAX CREDIT STATEMENT\nAssessment Year: 2025-26',
      DocumentType.panCard =>
        'INCOME TAX DEPARTMENT\nPERMANENT ACCOUNT NUMBER CARD',
      DocumentType.aadhaarCard => 'UNIQUE IDENTIFICATION AUTHORITY OF INDIA',
      DocumentType.salarySlip =>
        'SALARY SLIP\nBasic: 40000\nHRA: 16000\nNet Pay: 52000',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Document',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final bodyWidth = isWide ? 560.0 : constraints.maxWidth;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: bodyWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Document Type',
                        subtitle: 'Select the type of document to process.',
                      ),
                      const SizedBox(height: 12),
                      _DocumentTypeSelector(
                        selected: _selectedType,
                        onChanged: (type) =>
                            setState(() => _selectedType = type),
                      ),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: 'File Name',
                        subtitle:
                            'Enter the file name (demo — no real file picker).',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fileNameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Form16_Rajesh_AY2026.pdf',
                          prefixIcon: const Icon(
                            Icons.insert_drive_file_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.neutral50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a file name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isProcessing ? null : _submitDocument,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.scanner_outlined),
                          label: Text(
                            _isProcessing ? 'Processing…' : 'Process Document',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SectionHeader
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _DocumentTypeSelector — wrapping ChoiceChip row
// ---------------------------------------------------------------------------

class _DocumentTypeSelector extends StatelessWidget {
  const _DocumentTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final DocumentType selected;
  final ValueChanged<DocumentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _docTypeOptions.map((option) {
        final isSelected = selected == option.documentType;
        return ChoiceChip(
          avatar: Icon(
            option.icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.neutral600,
          ),
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onChanged(option.documentType),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.neutral200,
            ),
          ),
          backgroundColor: AppColors.surface,
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
