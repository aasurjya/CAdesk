import 'dart:io';
import 'dart:typed_data';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/data/services/excel_import_models.dart';
import 'package:ca_app/features/portal_autosubmit/data/services/excel_import_service.dart';
import 'package:flutter/material.dart';

/// Screen for importing client data from an .xlsx Excel file.
///
/// Flow:
/// 1. User selects an .xlsx file via a button.
/// 2. The file is parsed and validated by [ExcelImportService].
/// 3. A preview table shows parsed rows with any errors highlighted.
/// 4. User taps "Import" to confirm (only enabled when valid rows exist).
/// 5. Calls [onImport] callback with the valid rows for the caller to persist.
class ExcelImportScreen extends StatefulWidget {
  const ExcelImportScreen({
    super.key,
    required this.encryptPassword,
    required this.onImport,
    this.onPickFile,
  });

  /// Encryption callback injected by the caller.
  final Future<String> Function(String plaintext) encryptPassword;

  /// Called when the user confirms the import with valid rows.
  final Future<void> Function(List<ExcelClientRow> rows) onImport;

  /// Optional callback to pick a file. When null, uses [dart:io] File.
  /// Signature returns file bytes or null if cancelled.
  final Future<Uint8List?> Function()? onPickFile;

  @override
  State<ExcelImportScreen> createState() => ExcelImportScreenState();
}

/// Visible for testing — allows test code to call [parseBytes] directly.
class ExcelImportScreenState extends State<ExcelImportScreen> {
  static const _service = ExcelImportService();

  ExcelImportResult? _result;
  bool _isParsing = false;
  bool _isImporting = false;
  String? _fileName;
  String? _importSuccessMessage;

  /// Parses the given bytes through [ExcelImportService].
  /// Exposed for testing so callers can skip file picking.
  Future<void> parseBytes(Uint8List bytes, {String? fileName}) async {
    setState(() {
      _isParsing = true;
      _result = null;
      _importSuccessMessage = null;
      _fileName = fileName;
    });

    final result = await _service.parseExcelBytes(
      bytes: bytes,
      encryptPassword: widget.encryptPassword,
    );

    if (mounted) {
      setState(() {
        _result = result;
        _isParsing = false;
      });
    }
  }

  Future<void> _pickAndParse() async {
    Uint8List? bytes;
    String? fileName;

    if (widget.onPickFile != null) {
      bytes = await widget.onPickFile!();
      fileName = 'selected_file.xlsx';
    } else {
      // Fallback: show a dialog asking for the file path.
      final path = await _showFilePathDialog();
      if (path == null || path.trim().isEmpty) return;

      final file = File(path.trim());
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('File not found')));
        }
        return;
      }
      bytes = await file.readAsBytes();
      fileName = file.uri.pathSegments.last;
    }

    if (bytes == null) return;
    await parseBytes(bytes, fileName: fileName);
  }

  Future<String?> _showFilePathDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter .xlsx file path'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '/path/to/clients.xlsx'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImport() async {
    final validRows = _result?.validRows;
    if (validRows == null || validRows.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      await widget.onImport(validRows);
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importSuccessMessage =
              'Successfully imported ${validRows.length} client(s).';
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Excel Import'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilePickerSection(),
            if (_isParsing) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildSummaryBar(),
              const SizedBox(height: 12),
              Expanded(child: _buildPreviewTable()),
              const SizedBox(height: 12),
              _buildImportButton(),
            ],
            if (_importSuccessMessage != null) ...[
              const SizedBox(height: 16),
              _buildSuccessMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerSection() {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.upload_file_rounded,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              _fileName ?? 'Select an .xlsx file to import client data',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isParsing ? null : _pickAndParse,
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Select File'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final result = _result!;
    return Row(
      children: [
        _SummaryChip(
          label: 'Total: ${result.totalRows}',
          color: AppColors.neutral600,
          backgroundColor: AppColors.neutral100,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Valid: ${result.validRows.length}',
          color: AppColors.success,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Errors: ${result.errors.length}',
          color: result.hasErrors ? AppColors.error : AppColors.neutral400,
          backgroundColor: result.hasErrors
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.neutral100,
        ),
      ],
    );
  }

  Widget _buildPreviewTable() {
    final result = _result!;
    final allEntries = <_PreviewEntry>[];

    // Add valid rows.
    for (final row in result.validRows) {
      allEntries.add(
        _PreviewEntry(
          rowNumber: row.rowNumber,
          pan: row.pan,
          name: row.name,
          portal: row.portalType.name.toUpperCase(),
          error: null,
        ),
      );
    }

    // Add error rows (grouped by row number).
    final errorsByRow = <int, List<String>>{};
    for (final err in result.errors) {
      errorsByRow.putIfAbsent(err.rowNumber, () => []).add(err.message);
    }
    for (final entry in errorsByRow.entries) {
      allEntries.add(
        _PreviewEntry(
          rowNumber: entry.key,
          pan: '—',
          name: '—',
          portal: '—',
          error: entry.value.join('; '),
        ),
      );
    }

    // Sort by row number.
    allEntries.sort((a, b) => a.rowNumber.compareTo(b.rowNumber));

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        itemCount: allEntries.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.neutral200),
        itemBuilder: (context, index) {
          final entry = allEntries[index];
          final hasError = entry.error != null;
          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: hasError
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              child: Text(
                '${entry.rowNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasError ? AppColors.error : AppColors.success,
                ),
              ),
            ),
            title: Text(
              hasError ? 'Row ${entry.rowNumber}' : entry.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: hasError ? AppColors.error : AppColors.neutral900,
              ),
            ),
            subtitle: Text(
              hasError ? entry.error! : 'PAN: ${entry.pan}  |  ${entry.portal}',
              style: TextStyle(
                fontSize: 13,
                color: hasError ? AppColors.error : AppColors.neutral600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(
              hasError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: hasError ? AppColors.error : AppColors.success,
              size: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildImportButton() {
    final canImport = _result != null && _result!.hasValidRows && !_isImporting;
    return FilledButton(
      onPressed: canImport ? _handleImport : null,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.success,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isImporting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.surface,
              ),
            )
          : Text(
              'Import ${_result?.validRows.length ?? 0} Client(s)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _importSuccessMessage!,
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary chip showing a label with colored background.
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Internal model for the preview table, combining valid rows and error rows.
class _PreviewEntry {
  const _PreviewEntry({
    required this.rowNumber,
    required this.pan,
    required this.name,
    required this.portal,
    required this.error,
  });

  final int rowNumber;
  final String pan;
  final String name;
  final String portal;
  final String? error;
}
