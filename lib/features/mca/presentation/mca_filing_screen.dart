import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../domain/models/mca_filing.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

// ---------------------------------------------------------------------------
// Wizard state
// ---------------------------------------------------------------------------

enum _McaWizardStep { formSelection, dataEntry, validation, dscSigning, submit }

extension _McaWizardStepX on _McaWizardStep {}

/// MCA form filing wizard screen.
///
/// Route: `/mca/filing`
class McaFilingScreen extends ConsumerStatefulWidget {
  const McaFilingScreen({super.key});

  @override
  ConsumerState<McaFilingScreen> createState() => _McaFilingScreenState();
}

class _McaFilingScreenState extends ConsumerState<McaFilingScreen> {
  _McaWizardStep _currentStep = _McaWizardStep.formSelection;
  McaFormType _selectedForm = McaFormType.aoc4;
  String _selectedCompany = 'Mehta Textiles Pvt Ltd';
  String _selectedFY = '2024-25';
  bool _validating = false;
  bool _signing = false;
  bool _submitted = false;
  String? _srn;
  final List<String> _validationErrors = [];

  int get _currentIndex => _McaWizardStep.values.indexOf(_currentStep);

  void _nextStep() {
    const steps = _McaWizardStep.values;
    if (_currentIndex < steps.length - 1) {
      setState(() => _currentStep = steps[_currentIndex + 1]);
    }
  }

  void _prevStep() {
    if (_currentIndex > 0) {
      setState(() {
        _currentStep = _McaWizardStep.values[_currentIndex - 1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('MCA Filing Wizard', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          _StepIndicator(
            steps: _McaWizardStep.values,
            currentIndex: _currentIndex,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case _McaWizardStep.formSelection:
        return _FormSelectionStep(
          selectedForm: _selectedForm,
          selectedCompany: _selectedCompany,
          selectedFY: _selectedFY,
          onFormChanged: (v) => setState(() => _selectedForm = v),
          onCompanyChanged: (v) => setState(() => _selectedCompany = v),
          onFYChanged: (v) => setState(() => _selectedFY = v),
          onNext: _nextStep,
        );
      case _McaWizardStep.dataEntry:
        return _DataEntryStep(
          formType: _selectedForm,
          onNext: _nextStep,
          onBack: _prevStep,
        );
      case _McaWizardStep.validation:
        return _ValidationStep(
          validating: _validating,
          errors: _validationErrors,
          onValidate: _runValidation,
          onNext: _nextStep,
          onBack: _prevStep,
        );
      case _McaWizardStep.dscSigning:
        return _DscSigningStep(
          signing: _signing,
          onSign: _signDsc,
          onNext: _nextStep,
          onBack: _prevStep,
        );
      case _McaWizardStep.submit:
        return _SubmitStep(
          submitted: _submitted,
          srn: _srn,
          formType: _selectedForm,
          company: _selectedCompany,
          onSubmit: _submitFiling,
        );
    }
  }

  Future<void> _runValidation() async {
    setState(() {
      _validating = true;
      _validationErrors.clear();
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _validating = false;
      // Simulated: no errors for demo
    });
  }

  Future<void> _signDsc() async {
    setState(() => _signing = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() => _signing = false);
    _nextStep();
  }

  Future<void> _submitFiling() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _submitted = true;
      _srn =
          'SRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    });
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.currentIndex});

  final List<_McaWizardStep> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final isActive = index == currentIndex;
          final isCompleted = index < currentIndex;
          final color = isCompleted
              ? AppColors.success
              : isActive
              ? AppColors.primary
              : AppColors.neutral300;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive ? color : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white : color,
                            ),
                          ),
                        ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.neutral200,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1: Form selection
// ---------------------------------------------------------------------------

class _FormSelectionStep extends StatelessWidget {
  const _FormSelectionStep({
    required this.selectedForm,
    required this.selectedCompany,
    required this.selectedFY,
    required this.onFormChanged,
    required this.onCompanyChanged,
    required this.onFYChanged,
    required this.onNext,
  });

  final McaFormType selectedForm;
  final String selectedCompany;
  final String selectedFY;
  final ValueChanged<McaFormType> onFormChanged;
  final ValueChanged<String> onCompanyChanged;
  final ValueChanged<String> onFYChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeader(title: 'Select Form & Company'),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedCompany,
          decoration: const InputDecoration(
            labelText: 'Company',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business_rounded),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Mehta Textiles Pvt Ltd',
              child: Text('Mehta Textiles Pvt Ltd'),
            ),
            DropdownMenuItem(
              value: 'Joshi Electronics Pvt Ltd',
              child: Text('Joshi Electronics Pvt Ltd'),
            ),
            DropdownMenuItem(
              value: 'Gupta Steel Industries',
              child: Text('Gupta Steel Industries'),
            ),
          ],
          onChanged: (v) {
            if (v != null) onCompanyChanged(v);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedFY,
          decoration: const InputDecoration(
            labelText: 'Financial Year',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today_rounded),
          ),
          items: const [
            DropdownMenuItem(value: '2024-25', child: Text('2024-25')),
            DropdownMenuItem(value: '2023-24', child: Text('2023-24')),
          ],
          onChanged: (v) {
            if (v != null) onFYChanged(v);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Form Type',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: McaFormType.values.map((form) {
            final isSelected = form == selectedForm;
            return ChoiceChip(
              label: Text('${form.label} — ${form.description}'),
              selected: isSelected,
              selectedColor: form.color.withValues(alpha: 0.15),
              onSelected: (_) => onFormChanged(form),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? form.color : AppColors.neutral600,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onNext,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Next: Data Entry'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: Data entry
// ---------------------------------------------------------------------------

class _DataEntryStep extends StatelessWidget {
  const _DataEntryStep({
    required this.formType,
    required this.onNext,
    required this.onBack,
  });

  final McaFormType formType;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(title: 'Data Entry — ${formType.label}'),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Authorised Capital',
            hintText: '10,00,000',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee_rounded),
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Paid-up Capital',
            hintText: '5,00,000',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee_rounded),
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Turnover (FY)',
            hintText: '50,00,000',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up_rounded),
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Number of Members',
            hintText: '25',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.people_rounded),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _NavigationRow(
          onBack: onBack,
          onNext: onNext,
          nextLabel: 'Next: Validate',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: Validation
// ---------------------------------------------------------------------------

class _ValidationStep extends StatelessWidget {
  const _ValidationStep({
    required this.validating,
    required this.errors,
    required this.onValidate,
    required this.onNext,
    required this.onBack,
  });

  final bool validating;
  final List<String> errors;
  final VoidCallback onValidate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeader(title: 'Pre-Scrutiny Validation'),
        const SizedBox(height: 16),
        if (validating)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Running validation checks...'),
                ],
              ),
            ),
          )
        else if (errors.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: AppColors.success,
                ),
                SizedBox(height: 12),
                Text(
                  'All Checks Passed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No validation errors found. Ready for DSC signing.',
                  style: TextStyle(fontSize: 13, color: AppColors.neutral600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (!validating && errors.isEmpty)
          OutlinedButton.icon(
            onPressed: onValidate,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Re-run Validation'),
          ),
        if (!validating && errors.isNotEmpty)
          FilledButton.icon(
            onPressed: onValidate,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Re-validate'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
          ),
        const SizedBox(height: 24),
        _NavigationRow(
          onBack: onBack,
          onNext: errors.isEmpty && !validating ? onNext : onValidate,
          nextLabel: errors.isEmpty && !validating
              ? 'Next: DSC Signing'
              : 'Run Validation',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4: DSC signing
// ---------------------------------------------------------------------------

class _DscSigningStep extends StatelessWidget {
  const _DscSigningStep({
    required this.signing,
    required this.onSign,
    required this.onNext,
    required this.onBack,
  });

  final bool signing;
  final VoidCallback onSign;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeader(title: 'Digital Signature (DSC)'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryVariant.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.key_rounded,
                size: 48,
                color: AppColors.primaryVariant,
              ),
              const SizedBox(height: 12),
              const Text(
                'Attach Digital Signature',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the authorized signatory DSC token to digitally sign this form before submission.',
                style: TextStyle(fontSize: 13, color: AppColors.neutral600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: signing ? null : onSign,
                  icon: signing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.verified_rounded, size: 18),
                  label: Text(signing ? 'Signing...' : 'Sign with DSC'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryVariant,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(onPressed: onBack, child: const Text('Back')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 5: Submit
// ---------------------------------------------------------------------------

class _SubmitStep extends StatelessWidget {
  const _SubmitStep({
    required this.submitted,
    required this.srn,
    required this.formType,
    required this.company,
    required this.onSubmit,
  });

  final bool submitted;
  final String? srn;
  final McaFormType formType;
  final String company;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (submitted && srn != null) {
      return _SubmissionSuccess(
        srn: srn!,
        formType: formType,
        company: company,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeader(title: 'Review & Submit'),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.neutral200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewRow(label: 'Company', value: company),
                _ReviewRow(
                  label: 'Form',
                  value: '${formType.label} — ${formType.description}',
                ),
                const _ReviewRow(label: 'DSC', value: 'Signed'),
                const _ReviewRow(
                  label: 'Validation',
                  value: 'All checks passed',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('Submit to MCA'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _SubmissionSuccess extends StatelessWidget {
  const _SubmissionSuccess({
    required this.srn,
    required this.formType,
    required this.company,
  });

  final String srn;
  final McaFormType formType;
  final String company;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          const Text(
            'Filing Submitted Successfully',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          _ReviewRow(label: 'SRN', value: srn),
          _ReviewRow(label: 'Form', value: formType.label),
          _ReviewRow(label: 'Company', value: company),
          _ReviewRow(
            label: 'Submitted',
            value: _dateFmt.format(DateTime.now()),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  const _NavigationRow({
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: onBack, child: const Text('Back')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(nextLabel),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
