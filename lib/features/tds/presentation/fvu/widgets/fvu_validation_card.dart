import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/domain/services/fvu_pre_scrutiny_service.dart';

/// Card displaying pre-scrutiny validation results for FVU file generation.
///
/// Shows an overall pass/fail status with an icon, a list of validation
/// errors and warnings, with color-coded severity indicators.
class FvuValidationCard extends StatelessWidget {
  const FvuValidationCard({super.key, required this.issues});

  final List<ScrutinyIssue> issues;

  bool get _passed =>
      !issues.any((i) => i.severity == ScrutinyIssueSeverity.error);

  int get _errorCount =>
      issues.where((i) => i.severity == ScrutinyIssueSeverity.error).length;

  int get _warningCount =>
      issues.where((i) => i.severity == ScrutinyIssueSeverity.warning).length;

  int get _infoCount =>
      issues.where((i) => i.severity == ScrutinyIssueSeverity.info).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _passed
              ? AppColors.success.withAlpha(77)
              : AppColors.error.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStatus(theme),
          if (issues.isNotEmpty) ...[
            const Divider(height: 1),
            _buildSeveritySummary(theme),
            const Divider(height: 1),
            _buildIssueList(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallStatus(ThemeData theme) {
    final color = _passed ? AppColors.success : AppColors.error;
    final icon = _passed ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = _passed ? 'Pre-Scrutiny Passed' : 'Pre-Scrutiny Failed';
    final subtitle = _passed
        ? 'All validations passed successfully. File is ready for generation.'
        : '$_errorCount error${_errorCount != 1 ? 's' : ''} found. '
              'Fix all errors before generating the FVU file.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (_errorCount > 0)
            _SeverityChip(
              count: _errorCount,
              label: 'Errors',
              color: AppColors.error,
            ),
          if (_warningCount > 0) ...[
            if (_errorCount > 0) const SizedBox(width: 8),
            _SeverityChip(
              count: _warningCount,
              label: 'Warnings',
              color: AppColors.warning,
            ),
          ],
          if (_infoCount > 0) ...[
            if (_errorCount > 0 || _warningCount > 0) const SizedBox(width: 8),
            _SeverityChip(
              count: _infoCount,
              label: 'Info',
              color: AppColors.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIssueList(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: issues.map((issue) => _IssueRow(issue: issue)).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _IssueRow extends StatelessWidget {
  const _IssueRow({required this.issue});

  final ScrutinyIssue issue;

  Color get _color {
    switch (issue.severity) {
      case ScrutinyIssueSeverity.error:
        return AppColors.error;
      case ScrutinyIssueSeverity.warning:
        return AppColors.warning;
      case ScrutinyIssueSeverity.info:
        return AppColors.secondary;
    }
  }

  IconData get _icon {
    switch (issue.severity) {
      case ScrutinyIssueSeverity.error:
        return Icons.error_rounded;
      case ScrutinyIssueSeverity.warning:
        return Icons.warning_amber_rounded;
      case ScrutinyIssueSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  String get _categoryLabel {
    switch (issue.type) {
      case ScrutinyIssueType.invalidPan:
        return 'PAN Mismatch';
      case ScrutinyIssueType.invalidTan:
        return 'TAN Error';
      case ScrutinyIssueType.panNotAvailable:
        return 'Missing PAN';
      case ScrutinyIssueType.challanShortfall:
        return 'Amount Mismatch';
      case ScrutinyIssueType.rateVariance:
        return 'Rate Variance';
      case ScrutinyIssueType.dateSequenceError:
        return 'Date Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(_icon, size: 16, color: _color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _color.withAlpha(15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _categoryLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _color,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  issue.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  issue.fieldReference,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
