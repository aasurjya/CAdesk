import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Pre-submission readiness checklist card.
///
/// Shows a list of checks that must all pass before the Submit button is
/// enabled. Each check is an async boolean result provided by the caller.
class PreflightChecklistCard extends StatelessWidget {
  const PreflightChecklistCard({
    super.key,
    required this.portalType,
    required this.isDataComplete,
    required this.hasCredentials,
    required this.isDscValid,
    required this.isNetworkAvailable,
    required this.onSubmit,
  });

  final PortalType portalType;

  /// True when all required form fields are filled.
  final bool isDataComplete;

  /// True when the DSC vault has saved credentials for [portalType].
  final bool hasCredentials;

  /// True when the DSC certificate is present and not expired.
  final bool isDscValid;

  /// True when the device has network connectivity.
  final bool isNetworkAvailable;

  /// Called when the Submit button is tapped (all checks pass).
  final VoidCallback? onSubmit;

  bool get _allPassed =>
      isDataComplete && hasCredentials && isDscValid && isNetworkAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pre-flight Checklist',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _CheckItem(
              label: 'Data complete (all required fields filled)',
              passed: isDataComplete,
            ),
            _CheckItem(
              label:
                  'Credentials saved (${portalType.label} login in DSC vault)',
              passed: hasCredentials,
            ),
            _CheckItem(
              label: 'DSC valid (certificate present & not expired)',
              passed: isDscValid,
            ),
            _CheckItem(label: 'Network available', passed: isNetworkAvailable),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _allPassed ? onSubmit : null,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Auto-Submit'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.neutral200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (!_allPassed) ...[
              const SizedBox(height: 8),
              Text(
                'Resolve all checks above before submitting.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single check item row
// ---------------------------------------------------------------------------

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.label, required this.passed});

  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: passed ? AppColors.success : AppColors.neutral300,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: passed ? AppColors.neutral900 : AppColors.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
