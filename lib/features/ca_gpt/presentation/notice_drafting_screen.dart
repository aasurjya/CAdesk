import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/data/providers/ca_gpt_providers.dart';
import 'package:ca_app/features/ca_gpt/domain/models/notice_draft.dart';
import 'package:ca_app/features/ca_gpt/domain/services/notice_drafting_service.dart';

/// Screen for generating notice draft replies via the knowledge engine.
class NoticeDraftingScreen extends ConsumerStatefulWidget {
  const NoticeDraftingScreen({super.key});

  @override
  ConsumerState<NoticeDraftingScreen> createState() =>
      _NoticeDraftingScreenState();
}

class _NoticeDraftingScreenState extends ConsumerState<NoticeDraftingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partyNameController = TextEditingController();
  final _panController = TextEditingController();
  final _assessmentYearController = TextEditingController(text: '2025-26');
  final _summaryController = TextEditingController();

  String _selectedNoticeType = '143_1';

  static const _noticeTypeOptions = <_NoticeOption>[
    _NoticeOption(key: '143_1', label: 'Reply to 143(1) Intimation'),
    _NoticeOption(key: '143_3', label: 'Reply to 143(3) Assessment'),
    _NoticeOption(key: 'appeal', label: 'Memorandum of Appeal'),
    _NoticeOption(key: 'rectification', label: 'Rectification u/s 154'),
    _NoticeOption(key: 'condonation', label: 'Condonation of Delay'),
    _NoticeOption(key: 'penalty', label: 'Reply to Penalty Notice'),
    _NoticeOption(key: 'revision', label: 'Revision u/s 264'),
  ];

  @override
  void dispose() {
    _partyNameController.dispose();
    _panController.dispose();
    _assessmentYearController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _generateDraft() {
    if (!_formKey.currentState!.validate()) return;

    final facts = {
      'taxpayerName': _partyNameController.text.trim(),
      'pan': _panController.text.trim().toUpperCase(),
      'assessmentYear': _assessmentYearController.text.trim(),
      'groundsOfAppeal': _summaryController.text.trim(),
      'reliefSought':
          'The taxpayer humbly requests appropriate relief as detailed above.',
    };

    final draft = NoticeDraftingService.draftReply(_selectedNoticeType, facts);
    ref.read(noticeDraftProvider.notifier).update(draft);
  }

  void _clearDraft() {
    ref.read(noticeDraftProvider.notifier).update(null);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(noticeDraftProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.edit_document,
            title: 'Notice Draft Generator',
            subtitle: 'Fill the form below to generate a formal reply',
            theme: theme,
          ),
          const SizedBox(height: 16),
          _DraftForm(
            formKey: _formKey,
            noticeTypeOptions: _noticeTypeOptions,
            selectedNoticeType: _selectedNoticeType,
            onNoticeTypeChanged: (val) {
              if (val != null) setState(() => _selectedNoticeType = val);
            },
            partyNameController: _partyNameController,
            panController: _panController,
            assessmentYearController: _assessmentYearController,
            summaryController: _summaryController,
            theme: theme,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generateDraft,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Draft'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (draft != null) ...[
            const SizedBox(height: 24),
            _DraftResult(draft: draft, onClear: _clearDraft, theme: theme),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DraftForm extends StatelessWidget {
  const _DraftForm({
    required this.formKey,
    required this.noticeTypeOptions,
    required this.selectedNoticeType,
    required this.onNoticeTypeChanged,
    required this.partyNameController,
    required this.panController,
    required this.assessmentYearController,
    required this.summaryController,
    required this.theme,
  });

  final GlobalKey<FormState> formKey;
  final List<_NoticeOption> noticeTypeOptions;
  final String selectedNoticeType;
  final ValueChanged<String?> onNoticeTypeChanged;
  final TextEditingController partyNameController;
  final TextEditingController panController;
  final TextEditingController assessmentYearController;
  final TextEditingController summaryController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: 'Notice Type', theme: theme),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedNoticeType,
            decoration: _inputDecoration('Select notice type'),
            items: noticeTypeOptions.map((opt) {
              return DropdownMenuItem(value: opt.key, child: Text(opt.label));
            }).toList(),
            onChanged: onNoticeTypeChanged,
          ),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Party Name', theme: theme),
          const SizedBox(height: 6),
          TextFormField(
            controller: partyNameController,
            decoration: _inputDecoration('Full name of taxpayer'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          _FieldLabel(label: 'PAN', theme: theme),
          const SizedBox(height: 6),
          TextFormField(
            controller: panController,
            decoration: _inputDecoration('ABCDE1234F'),
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final pan = v.trim().toUpperCase();
              if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
                return 'Invalid PAN format';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Assessment Year', theme: theme),
          const SizedBox(height: 6),
          TextFormField(
            controller: assessmentYearController,
            decoration: _inputDecoration('e.g. 2025-26'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Issue Summary / Grounds', theme: theme),
          const SizedBox(height: 6),
          TextFormField(
            controller: summaryController,
            decoration: _inputDecoration(
              'Describe the issue or grounds of appeal…',
            ),
            maxLines: 4,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.neutral400, fontSize: 13),
      filled: true,
      fillColor: AppColors.neutral50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.neutral600,
      ),
    );
  }
}

class _DraftResult extends StatelessWidget {
  const _DraftResult({
    required this.draft,
    required this.onClear,
    required this.theme,
  });

  final NoticeDraft draft;
  final VoidCallback onClear;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Generated Draft',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: draft.draftText));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draft copied to clipboard')),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.neutral400,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: SelectableText(
            draft.draftText,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: AppColors.neutral900,
              height: 1.6,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AY ${draft.assessmentYear} · ${draft.taxpayerName} · PAN ${draft.pan}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

class _NoticeOption {
  const _NoticeOption({required this.key, required this.label});

  final String key;
  final String label;
}
