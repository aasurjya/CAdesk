import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr1_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnur.dart';

/// Step 3: Credit/Debit Notes (Table 9) -- CDNR and CDNUR entries.
class Gstr1CdnrStep extends ConsumerWidget {
  const Gstr1CdnrStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(gstr1FormDataProvider);
    final cdnr = formData.creditDebitNotes;
    final cdnur = formData.creditDebitNotesUnregistered;
    final isEmpty = cdnr.isEmpty && cdnur.isEmpty;

    return Stack(
      children: [
        if (isEmpty)
          _EmptyState()
        else
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              if (cdnr.isNotEmpty) ...[
                _Header(
                  title: 'CDNR -- Registered Recipients',
                  count: cdnr.length,
                ),
                const SizedBox(height: 8),
                ...List.generate(cdnr.length, (i) {
                  final note = cdnr[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CdnrTile(
                      note: note,
                      onDelete: () => ref
                          .read(gstr1FormDataProvider.notifier)
                          .removeCdnr(i),
                    ),
                  );
                }),
              ],
              if (cdnur.isNotEmpty) ...[
                const SizedBox(height: 8),
                _Header(
                  title: 'CDNUR -- Unregistered Recipients',
                  count: cdnur.length,
                ),
                const SizedBox(height: 8),
                ...List.generate(cdnur.length, (i) {
                  final note = cdnur[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CdnurTile(
                      note: note,
                      onDelete: () => ref
                          .read(gstr1FormDataProvider.notifier)
                          .removeCdnur(i),
                    ),
                  );
                }),
              ],
            ],
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'gstr1_cdnr_fab',
            onPressed: () => _showAddSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Note'),
          ),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CdnrForm(),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_rounded, size: 48, color: AppColors.neutral200),
          SizedBox(height: 12),
          Text(
            'No credit/debit notes added',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.neutral600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CDNR tile
// ---------------------------------------------------------------------------

class _CdnrTile extends StatelessWidget {
  const _CdnrTile({required this.note, required this.onDelete});

  final Gstr1Cdnr note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yy').format(note.noteDate);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${note.noteType.label}: ${note.noteNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${note.recipientName} (${note.recipientGstin}) • $dateStr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Value: ${CurrencyUtils.formatINR(note.noteValue)}  •  Tax: ${CurrencyUtils.formatINR(note.totalTax)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CDNUR tile
// ---------------------------------------------------------------------------

class _CdnurTile extends StatelessWidget {
  const _CdnurTile({required this.note, required this.onDelete});

  final Gstr1Cdnur note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yy').format(note.noteDate);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${note.noteType.label}: ${note.noteNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'POS: ${note.placeOfSupply}  •  $dateStr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Value: ${CurrencyUtils.formatINR(note.noteValue)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add CDNR form
// ---------------------------------------------------------------------------

class _CdnrForm extends ConsumerStatefulWidget {
  const _CdnrForm();

  @override
  ConsumerState<_CdnrForm> createState() => _CdnrFormState();
}

class _CdnrFormState extends ConsumerState<_CdnrForm> {
  final _formKey = GlobalKey<FormState>();
  final _noteNumberCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _origInvCtrl = TextEditingController();
  final _taxableCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '18');
  CdnrNoteType _noteType = CdnrNoteType.creditNote;
  bool _isInterState = false;

  @override
  void dispose() {
    _noteNumberCtrl.dispose();
    _gstinCtrl.dispose();
    _nameCtrl.dispose();
    _origInvCtrl.dispose();
    _taxableCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final taxable = double.tryParse(_taxableCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 18;
    final tax = taxable * rate / 100;
    final now = DateTime.now();

    final note = Gstr1Cdnr(
      noteNumber: _noteNumberCtrl.text.trim(),
      noteDate: now,
      noteType: _noteType,
      recipientGstin: _gstinCtrl.text.trim(),
      recipientName: _nameCtrl.text.trim(),
      originalInvoiceNumber: _origInvCtrl.text.trim(),
      originalInvoiceDate: now,
      placeOfSupply: _gstinCtrl.text.length >= 2
          ? _gstinCtrl.text.substring(0, 2)
          : '',
      isInterState: _isInterState,
      taxableValue: taxable,
      igst: _isInterState ? tax : 0,
      cgst: _isInterState ? 0 : tax / 2,
      sgst: _isInterState ? 0 : tax / 2,
      cess: 0,
      gstRate: rate,
    );

    ref.read(gstr1FormDataProvider.notifier).addCdnr(note);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Credit/Debit Note',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SegmentedButton<CdnrNoteType>(
              segments: const [
                ButtonSegment(
                  value: CdnrNoteType.creditNote,
                  label: Text('Credit Note'),
                ),
                ButtonSegment(
                  value: CdnrNoteType.debitNote,
                  label: Text('Debit Note'),
                ),
              ],
              selected: {_noteType},
              onSelectionChanged: (s) => setState(() => _noteType = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Note Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gstinCtrl,
              decoration: const InputDecoration(
                labelText: 'Recipient GSTIN',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length != 15)
                  ? '15 characters required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Recipient Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _origInvCtrl,
              decoration: const InputDecoration(
                labelText: 'Original Invoice Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _taxableCtrl,
              decoration: const InputDecoration(
                labelText: 'Taxable Value',
                border: OutlineInputBorder(),
                prefixText: '\u20B9 ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateCtrl,
              decoration: const InputDecoration(
                labelText: 'GST Rate (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              title: const Text('Inter-state'),
              value: _isInterState,
              onChanged: (v) => setState(() => _isInterState = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Note'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
