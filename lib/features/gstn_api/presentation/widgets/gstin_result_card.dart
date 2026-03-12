import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';

/// Card displaying GSTIN verification results with status badge.
class GstinResultCard extends StatelessWidget {
  const GstinResultCard({super.key, required this.result});

  final GstnVerificationResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.tradeName ?? result.legalName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                      if (result.tradeName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          result.legalName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusBadge(status: result.status),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'GSTIN', value: result.gstin),
            const SizedBox(height: 6),
            _DetailRow(
              label: 'State',
              value: _stateNameFromCode(result.stateCode),
            ),
            const SizedBox(height: 6),
            _DetailRow(label: 'Type', value: result.constitutionType),
            const SizedBox(height: 6),
            _DetailRow(
              label: 'Registration',
              value: _formatDate(result.registrationDate),
            ),
            const SizedBox(height: 6),
            _DetailRow(
              label: 'Filing Frequency',
              value:
                  result.returnFilingFrequency == ReturnFilingFrequency.monthly
                  ? 'Monthly'
                  : 'Quarterly',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final GstnRegistrationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _badgeLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _badgeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String get _badgeLabel {
    switch (status) {
      case GstnRegistrationStatus.active:
        return 'Active';
      case GstnRegistrationStatus.cancelled:
        return 'Cancelled';
      case GstnRegistrationStatus.suspended:
        return 'Suspended';
    }
  }

  Color get _badgeColor {
    switch (status) {
      case GstnRegistrationStatus.active:
        return AppColors.success;
      case GstnRegistrationStatus.cancelled:
        return AppColors.error;
      case GstnRegistrationStatus.suspended:
        return AppColors.warning;
    }
  }
}

// ---------------------------------------------------------------------------
// Detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

String _stateNameFromCode(String code) {
  const stateMap = {
    '01': 'Jammu & Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '18': 'Assam',
    '19': 'West Bengal',
    '21': 'Odisha',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '27': 'Maharashtra',
    '29': 'Karnataka',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '36': 'Telangana',
    '37': 'Andhra Pradesh',
  };
  return stateMap[code] ?? 'State ($code)';
}
