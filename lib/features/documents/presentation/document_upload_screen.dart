import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';
import 'package:ca_app/features/documents/data/providers/document_viewer_providers.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';
import 'package:ca_app/features/documents/presentation/widgets/upload_drop_zone.dart';

/// Document upload flow screen.
///
/// Provides a drop zone, file selection, progress indicators,
/// auto-categorization suggestions, client assignment, tags, and folder
/// selection.
class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final _tagsController = TextEditingController();
  DocumentCategory? _selectedCategory;
  String? _selectedClientId;
  String? _selectedFolder;
  bool _isUploading = false;

  // Mock selected files
  final List<_MockFile> _selectedFiles = [];

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  void _onPickFiles() {
    // Simulate file picker result
    setState(() {
      _selectedFiles.addAll([
        const _MockFile(name: 'ITR-2_AY2026.pdf', size: 1245184),
        const _MockFile(name: 'Form16_2025.pdf', size: 512000),
      ]);
      // Auto-categorize based on filename
      _selectedCategory ??= _suggestCategory(_selectedFiles.first.name);
    });
  }

  void _onUpload() {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);

    final files = _selectedFiles
        .map((f) => UploadFileState(fileName: f.name, fileSize: f.size))
        .toList();
    ref.read(uploadProgressProvider.notifier).addFiles(files);

    // Simulate upload progress
    _simulateUpload();
  }

  Future<void> _simulateUpload() async {
    final notifier = ref.read(uploadProgressProvider.notifier);
    final count = _selectedFiles.length;

    for (int step = 1; step <= 10; step++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      for (int i = 0; i < count; i++) {
        notifier.updateProgress(i, step / 10);
      }
    }

    if (mounted) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload complete'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Upload Documents'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Drop zone
          UploadDropZone(
            onTap: _onPickFiles,
            selectedCount: _selectedFiles.length,
          ),
          const SizedBox(height: 20),

          // Selected files list
          if (_selectedFiles.isNotEmpty) ...[
            const SectionHeader(
              title: 'Selected Files',
              icon: Icons.attach_file_rounded,
            ),
            const SizedBox(height: 8),
            ..._selectedFiles.asMap().entries.map(
              (entry) => _SelectedFileTile(
                file: entry.value,
                progress: uploadState.length > entry.key
                    ? uploadState[entry.key].progress
                    : null,
                onRemove: _isUploading
                    ? null
                    : () => setState(() => _selectedFiles.removeAt(entry.key)),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Auto-categorization
          const SectionHeader(
            title: 'Categorize',
            icon: Icons.category_rounded,
          ),
          const SizedBox(height: 8),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),

          // Client assignment
          const SectionHeader(
            title: 'Assign to Client',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 8),
          _buildClientDropdown(),
          const SizedBox(height: 16),

          // Tags
          const SectionHeader(title: 'Tags', icon: Icons.label_outline_rounded),
          const SizedBox(height: 8),
          _buildTagsInput(),
          const SizedBox(height: 16),

          // Folder selector
          const SectionHeader(title: 'Folder', icon: Icons.folder_outlined),
          const SizedBox(height: 8),
          _buildFolderDropdown(),
          const SizedBox(height: 24),

          // Upload button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _selectedFiles.isEmpty || _isUploading
                  ? null
                  : _onUpload,
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_rounded, size: 20),
              label: Text(_isUploading ? 'Uploading...' : 'Upload'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DocumentCategory>(
          value: _selectedCategory,
          isExpanded: true,
          hint: const Text('Select category'),
          items: DocumentCategory.values
              .map(
                (cat) => DropdownMenuItem(value: cat, child: Text(cat.label)),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClientId,
          isExpanded: true,
          hint: const Text('Select client'),
          items: _mockClients
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (value) => setState(() => _selectedClientId = value),
        ),
      ),
    );
  }

  Widget _buildTagsInput() {
    return TextField(
      controller: _tagsController,
      decoration: InputDecoration(
        hintText: 'Comma-separated tags (e.g. ITR, AY2026)',
        hintStyle: const TextStyle(color: AppColors.neutral400, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
      ),
    );
  }

  Widget _buildFolderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFolder,
          isExpanded: true,
          hint: const Text('Select folder (optional)'),
          items: _mockFolderNames
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (value) => setState(() => _selectedFolder = value),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selected file tile with progress
// ---------------------------------------------------------------------------

class _SelectedFileTile extends StatelessWidget {
  const _SelectedFileTile({required this.file, this.progress, this.onRemove});

  final _MockFile file;
  final double? progress;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUploading = progress != null && progress! < 1.0;
    final isComplete = progress != null && progress! >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insert_drive_file_rounded,
                size: 20,
                color: isComplete ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _fileSizeLabel(file.size),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  color: AppColors.neutral400,
                ),
              if (isComplete)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
            ],
          ),
          if (isUploading) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.neutral100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress! * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _fileSizeLabel(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// ---------------------------------------------------------------------------
// Auto-categorization helper
// ---------------------------------------------------------------------------

DocumentCategory _suggestCategory(String filename) {
  final lower = filename.toLowerCase();
  if (lower.contains('itr') || lower.contains('return')) {
    return DocumentCategory.taxReturns;
  }
  if (lower.contains('gst')) return DocumentCategory.gstReturns;
  if (lower.contains('form16') || lower.contains('tds')) {
    return DocumentCategory.tdsCertificates;
  }
  if (lower.contains('audit')) return DocumentCategory.auditReports;
  if (lower.contains('balance') || lower.contains('financial')) {
    return DocumentCategory.financialStatements;
  }
  if (lower.contains('agreement') || lower.contains('deed')) {
    return DocumentCategory.agreements;
  }
  if (lower.contains('pan') || lower.contains('aadhaar')) {
    return DocumentCategory.identity;
  }
  if (lower.contains('bank')) return DocumentCategory.bankStatements;
  if (lower.contains('notice')) return DocumentCategory.notices;
  return DocumentCategory.miscellaneous;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _MockFile {
  const _MockFile({required this.name, required this.size});

  final String name;
  final int size;
}

class _MockClient {
  const _MockClient({required this.id, required this.name});

  final String id;
  final String name;
}

const _mockClients = [
  _MockClient(id: '1', name: 'Rajesh Kumar Sharma'),
  _MockClient(id: '2', name: 'Priya Mehta'),
  _MockClient(id: '3', name: 'ABC Infra Pvt Ltd'),
  _MockClient(id: '4', name: 'Mehta & Sons'),
  _MockClient(id: '6', name: 'TechVista Solutions LLP'),
  _MockClient(id: '8', name: 'Bharat Electronics Ltd'),
  _MockClient(id: '9', name: 'Deepak Patel'),
  _MockClient(id: '13', name: 'GreenLeaf Organics LLP'),
];

const _mockFolderNames = [
  'Tax Returns',
  'GST Returns',
  'Audit Documents',
  'TDS Certificates',
  'Agreements & Deeds',
  'KYC Documents',
  'Notices',
  'Miscellaneous',
];
