import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ca_app/features/litigation/domain/models/response_template.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/services/response_template_service.dart';

/// Screen for drafting a response to a [TaxNotice].
///
/// Receives the notice via GoRouter extra.
class ResponseDraftScreen extends StatefulWidget {
  const ResponseDraftScreen({required this.notice, super.key});

  final TaxNotice notice;

  @override
  State<ResponseDraftScreen> createState() =>
      _ResponseDraftScreenState();
}

class _ResponseDraftScreenState extends State<ResponseDraftScreen> {
  late ResponseTemplate _selectedTemplate;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = ResponseTemplateService.getTemplate(
      widget.notice.noticeType,
    );
    _controller = TextEditingController(
      text: _filledText(_selectedTemplate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _filledText(ResponseTemplate template) {
    return ResponseTemplateService.fillTemplate(template, _facts());
  }

  Map<String, String> _facts() {
    final d = widget.notice;
    return {
      'pan': d.pan,
      'assessmentYear': d.assessmentYear,
      'issuedBy': d.issuedBy,
      'noticeId': d.noticeId,
      'issuedDate': _fmt(d.issuedDate),
      'responseDate': _fmt(DateTime.now()),
      'demandAmount': d.demandAmount != null
          ? _formatPaise(d.demandAmount!)
          : '0',
      'assesseeName': '[Assessee Name]',
      'section': d.section,
    };
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    return _formatIndian(rupees);
  }

  static String _formatIndian(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _controller.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Only one template per notice type — show the current one as selectable chip.
    // Future: multiple variant templates.
    final charCount = _controller.text.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Draft Response',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Template selector
          Container(
            color: theme.colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Template',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _TemplateChip(
                    template: _selectedTemplate,
                    isSelected: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Success rate: ${(_selectedTemplate.successRate * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Editable draft area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  hintText: 'Response text...',
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Character count + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Text(
                  '$charCount characters',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('Export PDF'),
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
// Template chip widget
// ---------------------------------------------------------------------------

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final ResponseTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          template.title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
