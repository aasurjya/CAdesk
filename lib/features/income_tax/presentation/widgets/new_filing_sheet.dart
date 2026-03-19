import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/income_tax/data/providers/income_tax_providers.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

/// Bottom sheet form for adding a new ITR filing.
/// Shows a live tax preview card as the user types total income.
class NewFilingSheet extends ConsumerStatefulWidget {
  const NewFilingSheet({super.key});

  @override
  ConsumerState<NewFilingSheet> createState() => _NewFilingSheetState();
}

class _NewFilingSheetState extends ConsumerState<NewFilingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();

  ItrType _itrType = ItrType.itr1;
  String _assessmentYear = 'AY 2026-27';
  TaxRegimeComparison? _liveComparison;

  static const _assessmentYears = [
    'AY 2026-27',
    'AY 2025-26',
    'AY 2024-25',
    'AY 2023-24',
  ];

  static final _currencyFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _panCtrl.dispose();
    _incomeCtrl.dispose();
    super.dispose();
  }

  void _onIncomeChanged(String raw) {
    final value = double.tryParse(raw.replaceAll(',', ''));
    if (value != null && value > 0) {
      setState(() {
        _liveComparison = TaxComputationService.compare(value);
      });
    } else {
      setState(() {
        _liveComparison = null;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final income = double.tryParse(_incomeCtrl.text.replaceAll(',', '')) ?? 0.0;
    final comparison = TaxComputationService.compare(income);
    final recommendedTax = comparison.recommendedRegime == 'New'
        ? comparison.newRegimeTax
        : comparison.oldRegimeTax;

    final newClient = ItrClient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      pan: _panCtrl.text.trim().toUpperCase(),
      aadhaar: '',
      email: '',
      phone: '',
      itrType: _itrType,
      assessmentYear: _assessmentYear,
      filingStatus: FilingStatus.pending,
      totalIncome: income,
      taxPayable: recommendedTax,
      refundDue: 0,
    );

    ref.read(itrClientsProvider.notifier).add(newClient);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filing added for ${newClient.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'New ITR Filing',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.neutral600,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _nameCtrl,
                          label: 'Client Name',
                          hint: 'e.g. Rajesh Kumar Sharma',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _panCtrl,
                          label: 'PAN',
                          hint: 'e.g. ABCDE1234F',
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp('[A-Za-z0-9]'),
                            ),
                            UpperCaseTextFormatter(),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'PAN is required';
                            }
                            final pan = v.trim().toUpperCase();
                            final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                            if (!panRegex.hasMatch(pan)) {
                              return 'Enter a valid 10-character PAN';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField<ItrType>(
                          label: 'ITR Type',
                          value: _itrType,
                          items: const [
                            ItrType.itr1,
                            ItrType.itr2,
                            ItrType.itr3,
                            ItrType.itr4,
                          ],
                          itemLabel: (t) => '${t.label} — ${t.description}',
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _itrType = v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField<String>(
                          label: 'Assessment Year',
                          value: _assessmentYear,
                          items: _assessmentYears,
                          itemLabel: (y) => y,
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _assessmentYear = v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _incomeCtrl,
                          label: 'Total Income (₹)',
                          hint: 'e.g. 1200000',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: _onIncomeChanged,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Income is required';
                            }
                            final val = double.tryParse(v);
                            if (val == null || val <= 0) {
                              return 'Enter a valid positive amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_liveComparison != null)
                          _LiveTaxPreviewCard(
                            comparison: _liveComparison!,
                            currencyFmt: _currencyFmt,
                          ),
                        if (_liveComparison != null) const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Add Filing',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Live tax preview card
// ---------------------------------------------------------------------------

class _LiveTaxPreviewCard extends StatelessWidget {
  const _LiveTaxPreviewCard({
    required this.comparison,
    required this.currencyFmt,
  });

  final TaxRegimeComparison comparison;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Live Tax Preview',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RegimeSummary(
                  regime: 'Old Regime',
                  tax: comparison.oldRegimeTax,
                  isRecommended: comparison.recommendedRegime == 'Old',
                  currencyFmt: currencyFmt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RegimeSummary(
                  regime: 'New Regime',
                  tax: comparison.newRegimeTax,
                  isRecommended: comparison.recommendedRegime == 'New',
                  currencyFmt: currencyFmt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Recommended: ${comparison.recommendedRegime} Regime '
            '(save ${currencyFmt.format(comparison.savings)})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegimeSummary extends StatelessWidget {
  const _RegimeSummary({
    required this.regime,
    required this.tax,
    required this.isRecommended,
    required this.currencyFmt,
  });

  final String regime;
  final double tax;
  final bool isRecommended;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isRecommended
            ? AppColors.success.withAlpha(20)
            : AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRecommended
              ? AppColors.success.withAlpha(102)
              : AppColors.neutral200,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            regime,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isRecommended ? AppColors.success : AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFmt.format(tax),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isRecommended ? AppColors.success : AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Converts typed characters to uppercase automatically.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
