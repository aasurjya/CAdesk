import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A small (i) icon button that shows contextual help text when tapped.
///
/// Designed to sit alongside field labels in form rows. Uses the built-in
/// [Tooltip] widget with tap-triggered display for accessibility.
class FieldHelpTooltip extends StatelessWidget {
  const FieldHelpTooltip({super.key, required this.helpText});

  /// The help text to display when the user taps the icon.
  final String helpText;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: helpText,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      showDuration: const Duration(seconds: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        height: 1.4,
      ),
      child: const Icon(
        Icons.info_outline,
        size: 18,
        color: AppColors.neutral400,
      ),
    );
  }
}
