import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Reusable form field for entering a deduction amount in rupees.
///
/// Displays a Rs prefix, optional max-limit helper text, and an
/// info tooltip explaining the section.
class DeductionField extends StatelessWidget {
  const DeductionField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLimitPaise,
    this.maxLimitLabel,
    this.tooltipMessage,
    this.onChanged,
    this.validator,
  });

  /// Field label, e.g. "Section 80C".
  final String label;

  /// Controller bound to rupee amount (user types rupees, not paise).
  final TextEditingController controller;

  /// Optional max limit in paise, shown as helper text.
  final int? maxLimitPaise;

  /// Human-readable max limit, e.g. "Max ₹1,50,000".
  final String? maxLimitLabel;

  /// Tooltip explaining the deduction section.
  final String? tooltipMessage;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Optional field-level validator.
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          helperText: maxLimitLabel,
          helperStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.neutral400,
          ),
          suffixIcon: tooltipMessage != null
              ? Tooltip(
                  message: tooltipMessage!,
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.neutral400,
                  ),
                )
              : null,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
