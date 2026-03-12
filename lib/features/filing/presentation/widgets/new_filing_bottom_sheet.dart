import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

/// Shows the "New ITR Filing" bottom sheet and returns the created job ID
/// if the user submits, or null if they cancel.
Future<String?> showNewFilingBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NewFilingSheet(),
  );
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _assessmentYears = <String>[
  'AY 2026-27',
  'AY 2025-26',
  'AY 2024-25',
  'AY 2023-24',
];

const _staffMembers = <String>[
  'Self',
  'Rahul (Article)',
  'Neha (Senior)',
  'Vikram (Manager)',
  'Anjali (Article)',
];

// ---------------------------------------------------------------------------
// Bottom sheet widget
// ---------------------------------------------------------------------------

class _NewFilingSheet extends ConsumerStatefulWidget {
  const _NewFilingSheet();

  @override
  ConsumerState<_NewFilingSheet> createState() => _NewFilingSheetState();
}

class _NewFilingSheetState extends ConsumerState<_NewFilingSheet> {
  final _formKey = GlobalKey<FormState>();

  // Client info
  final _clientNameCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Filing details
  ItrType _itrType = ItrType.itr1;
  String _assessmentYear = 'AY 2026-27';
  FilingType _filingType = FilingType.original;
  ResidentialStatus _residentialStatus = ResidentialStatus.resident;
  TaxRegime _taxRegime = TaxRegime.newRegime;

  // Assignment & workflow
  String _assignedTo = 'Self';
  FilingPriority _priority = FilingPriority.medium;
  DateTime? _dueDate;
  final _feeQuotedCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default due date: 31 Jul of current AY
    _dueDate = DateTime(2026, 7, 31);
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _panCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _feeQuotedCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _buildSectionLabel('Client Information'),
                      const SizedBox(height: 8),
                      _buildClientNameField(),
                      const SizedBox(height: 12),
                      _buildPanField(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildMobileField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildEmailField()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Filing Details'),
                      const SizedBox(height: 8),
                      _buildItrTypeDropdown(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildAssessmentYearDropdown()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFilingTypeDropdown()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildResidentialStatusDropdown()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTaxRegimeDropdown()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Assignment & Workflow'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildAssignedToDropdown()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildPriorityDropdown()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDueDateField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFeeField()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRemarksField(),
                      const SizedBox(height: 28),
                      _buildSubmitButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Expanded(
            child: Text(
              'New ITR Filing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.neutral400),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Section label
  // -------------------------------------------------------------------------

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Client info fields
  // -------------------------------------------------------------------------

  Widget _buildClientNameField() {
    return TextFormField(
      controller: _clientNameCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Client Name *',
        prefixIcon: Icon(Icons.person_outline, size: 20),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Client name is required' : null,
    );
  }

  Widget _buildPanField() {
    return TextFormField(
      controller: _panCtrl,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        LengthLimitingTextInputFormatter(10),
        _UpperCaseFormatter(),
      ],
      decoration: const InputDecoration(
        labelText: 'PAN *',
        hintText: 'ABCDE1234F',
        prefixIcon: Icon(Icons.badge_outlined, size: 20),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'PAN is required';
        final pan = v.trim().toUpperCase();
        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
          return 'Invalid PAN format';
        }
        return null;
      },
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: _mobileCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: const InputDecoration(
        labelText: 'Mobile',
        prefixIcon: Icon(Icons.phone_outlined, size: 20),
      ),
      validator: (v) {
        if (v != null && v.isNotEmpty && v.length != 10) {
          return 'Enter 10 digits';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined, size: 20),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Filing detail dropdowns
  // -------------------------------------------------------------------------

  Widget _buildItrTypeDropdown() {
    return DropdownButtonFormField<ItrType>(
      initialValue: _itrType,
      decoration: const InputDecoration(
        labelText: 'ITR Type *',
        prefixIcon: Icon(Icons.description_outlined, size: 20),
      ),
      items: ItrType.values.map((t) {
        return DropdownMenuItem(
          value: t,
          child: Text(
            '${t.label} — ${t.description}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _itrType = v);
      },
    );
  }

  Widget _buildAssessmentYearDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _assessmentYear,
      decoration: const InputDecoration(
        labelText: 'Assessment Year *',
        prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
      ),
      items: _assessmentYears
          .map((y) => DropdownMenuItem(value: y, child: Text(y)))
          .toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() {
            _assessmentYear = v;
            _dueDate = _defaultDueDate(v);
          });
        }
      },
    );
  }

  Widget _buildFilingTypeDropdown() {
    return DropdownButtonFormField<FilingType>(
      initialValue: _filingType,
      decoration: const InputDecoration(
        labelText: 'Filing Type *',
        prefixIcon: Icon(Icons.file_present_outlined, size: 20),
      ),
      isExpanded: true,
      items: FilingType.values.map((t) {
        return DropdownMenuItem(
          value: t,
          child: Text(
            t.label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _filingType = v);
      },
    );
  }

  Widget _buildResidentialStatusDropdown() {
    return DropdownButtonFormField<ResidentialStatus>(
      initialValue: _residentialStatus,
      decoration: const InputDecoration(
        labelText: 'Residential Status',
        prefixIcon: Icon(Icons.home_outlined, size: 20),
      ),
      isExpanded: true,
      items: ResidentialStatus.values.map((s) {
        return DropdownMenuItem(
          value: s,
          child: Text(
            s.label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _residentialStatus = v);
      },
    );
  }

  Widget _buildTaxRegimeDropdown() {
    return DropdownButtonFormField<TaxRegime>(
      initialValue: _taxRegime,
      decoration: const InputDecoration(
        labelText: 'Tax Regime *',
        prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
      ),
      items: const [
        DropdownMenuItem(
          value: TaxRegime.newRegime,
          child: Text('New Regime (115BAC)'),
        ),
        DropdownMenuItem(value: TaxRegime.oldRegime, child: Text('Old Regime')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => _taxRegime = v);
      },
    );
  }

  // -------------------------------------------------------------------------
  // Assignment & workflow fields
  // -------------------------------------------------------------------------

  Widget _buildAssignedToDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _assignedTo,
      decoration: const InputDecoration(
        labelText: 'Assigned To',
        prefixIcon: Icon(Icons.person_pin_outlined, size: 20),
      ),
      items: _staffMembers
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _assignedTo = v);
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<FilingPriority>(
      initialValue: _priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        prefixIcon: Icon(Icons.flag_outlined, size: 20),
      ),
      items: FilingPriority.values.map((p) {
        return DropdownMenuItem(
          value: p,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: p.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(p.label),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _priority = v);
      },
    );
  }

  Widget _buildDueDateField() {
    final dateText = _dueDate != null
        ? DateFormat('dd MMM yyyy').format(_dueDate!)
        : 'Select date';

    return GestureDetector(
      onTap: _pickDueDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          prefixIcon: Icon(Icons.event_outlined, size: 20),
        ),
        child: Text(
          dateText,
          style: TextStyle(
            fontSize: 14,
            color: _dueDate != null
                ? AppColors.neutral900
                : AppColors.neutral400,
          ),
        ),
      ),
    );
  }

  Widget _buildFeeField() {
    return TextFormField(
      controller: _feeQuotedCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Fee Quoted (₹)',
        prefixIcon: Icon(Icons.currency_rupee_outlined, size: 20),
      ),
    );
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: _remarksCtrl,
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Remarks / Notes',
        prefixIcon: Icon(Icons.note_outlined, size: 20),
        alignLabelWithHint: true,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Submit
  // -------------------------------------------------------------------------

  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _submit,
      icon: const Icon(Icons.add_circle_outline),
      label: const Text(
        'Create Filing',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final jobId = 'job-${now.millisecondsSinceEpoch}';
    final fee = double.tryParse(_feeQuotedCtrl.text);

    final job = FilingJob(
      id: jobId,
      clientId: 'client-${now.millisecondsSinceEpoch}',
      clientName: _clientNameCtrl.text.trim(),
      pan: _panCtrl.text.trim().toUpperCase(),
      mobile: _mobileCtrl.text.trim().isNotEmpty
          ? _mobileCtrl.text.trim()
          : null,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      assessmentYear: _assessmentYear,
      itrType: _itrType,
      filingType: _filingType,
      residentialStatus: _residentialStatus,
      taxRegime: _taxRegime,
      status: FilingJobStatus.notStarted,
      createdAt: now,
      updatedAt: now,
      dueDate: _dueDate,
      assignedTo: _assignedTo,
      priority: _priority,
      remarks: _remarksCtrl.text.trim().isNotEmpty
          ? _remarksCtrl.text.trim()
          : null,
      feeQuoted: fee,
    );

    ref.read(filingJobsProvider.notifier).add(job);

    Navigator.pop(context, jobId);
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime(2026, 7, 31),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  DateTime _defaultDueDate(String ay) {
    // Extract start year from "AY 2026-27" → 2026, due date is 31 Jul of that year
    final match = RegExp(r'AY (\d{4})').firstMatch(ay);
    if (match != null) {
      final year = int.parse(match.group(1)!);
      return DateTime(year, 7, 31);
    }
    return DateTime(2026, 7, 31);
  }
}

// ---------------------------------------------------------------------------
// Uppercase text formatter
// ---------------------------------------------------------------------------

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
