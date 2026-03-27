import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum ExportType { itrJson, gstrJson, fvu, xbrl, form16 }

extension ExportTypeX on ExportType {
  String get label => switch (this) {
    ExportType.itrJson => 'ITR JSON',
    ExportType.gstrJson => 'GSTR JSON',
    ExportType.fvu => 'FVU File',
    ExportType.xbrl => 'XBRL',
    ExportType.form16 => 'Form 16',
  };
}

enum ValidationResult { pass, fail, warning }

extension ValidationResultX on ValidationResult {
  Color get color => switch (this) {
    ValidationResult.pass => AppColors.success,
    ValidationResult.fail => AppColors.error,
    ValidationResult.warning => AppColors.warning,
  };

  IconData get icon => switch (this) {
    ValidationResult.pass => Icons.check_circle_rounded,
    ValidationResult.fail => Icons.cancel_rounded,
    ValidationResult.warning => Icons.warning_rounded,
  };
}

class SchemaCheck {
  const SchemaCheck({
    required this.rule,
    required this.result,
    required this.detail,
  });

  final String rule;
  final ValidationResult result;
  final String detail;
}

class SubmissionRecord {
  const SubmissionRecord({
    required this.portal,
    required this.submittedAt,
    required this.ackNumber,
    required this.status,
  });

  final String portal;
  final DateTime submittedAt;
  final String ackNumber;
  final String status;
}

class ExportDetail {
  const ExportDetail({
    required this.id,
    required this.exportType,
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.createdAt,
    required this.fileSize,
    required this.schemaChecks,
    required this.submissions,
  });

  final String id;
  final ExportType exportType;
  final String clientName;
  final String pan;
  final String assessmentYear;
  final DateTime createdAt;
  final String fileSize;
  final List<SchemaCheck> schemaChecks;
  final List<SubmissionRecord> submissions;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _exportDetailProvider = Provider.family<ExportDetail, String>((
  ref,
  exportId,
) {
  return ExportDetail(
    id: exportId,
    exportType: ExportType.itrJson,
    clientName: 'Priya Sharma',
    pan: 'BPXPS5678G',
    assessmentYear: 'AY 2026-27',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    fileSize: '42.3 KB',
    schemaChecks: const [
      SchemaCheck(
        rule: 'Schema Version',
        result: ValidationResult.pass,
        detail: 'ITR-1 v1.4 (FY 2025-26)',
      ),
      SchemaCheck(
        rule: 'PAN Validation',
        result: ValidationResult.pass,
        detail: 'PAN matches Form 26AS',
      ),
      SchemaCheck(
        rule: 'Income Total',
        result: ValidationResult.pass,
        detail: 'Salary + Other Sources = Gross Total',
      ),
      SchemaCheck(
        rule: 'Deduction Limit',
        result: ValidationResult.warning,
        detail: '80C exceeds 1.5L limit by 2,000',
      ),
      SchemaCheck(
        rule: 'TDS Reconciliation',
        result: ValidationResult.pass,
        detail: 'TDS matches Form 26AS',
      ),
      SchemaCheck(
        rule: 'Bank Account',
        result: ValidationResult.pass,
        detail: 'Pre-validated IFSC + account',
      ),
    ],
    submissions: [
      SubmissionRecord(
        portal: 'Income Tax e-Filing',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ackNumber: 'CPC/2026/ITR1/00234567',
        status: 'Accepted',
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ExportDetailScreen extends ConsumerWidget {
  const ExportDetailScreen({super.key, required this.exportId});

  final String exportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_exportDetailProvider(exportId));
    final theme = Theme.of(context);

    final passCount = detail.schemaChecks
        .where((c) => c.result == ValidationResult.pass)
        .length;
    final failCount = detail.schemaChecks
        .where((c) => c.result == ValidationResult.fail)
        .length;
    final warnCount = detail.schemaChecks
        .where((c) => c.result == ValidationResult.warning)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Detail',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              '${detail.exportType.label} - ${detail.clientName}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {},
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () {},
            tooltip: 'Share',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats
          Row(
            children: [
              _StatCard(
                label: 'Passed',
                value: '$passCount',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Warnings',
                value: '$warnCount',
                icon: Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Failed',
                value: '$failCount',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Export info
          _ExportInfoCard(detail: detail),
          const SizedBox(height: 16),

          // Schema checks
          const _SectionHeader(
            title: 'Schema Compliance',
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 10),
          ...detail.schemaChecks.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SchemaCheckTile(check: c),
            ),
          ),
          const SizedBox(height: 16),

          // Submission history
          if (detail.submissions.isNotEmpty) ...[
            const _SectionHeader(
              title: 'Submission History',
              icon: Icons.history_rounded,
            ),
            const SizedBox(height: 10),
            ...detail.submissions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SubmissionTile(record: s),
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export info card
// ---------------------------------------------------------------------------

class _ExportInfoCard extends StatelessWidget {
  const _ExportInfoCard({required this.detail});

  final ExportDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(label: 'Type', value: detail.exportType.label),
            const Divider(height: 16),
            _InfoRow(label: 'Client', value: detail.clientName),
            const Divider(height: 16),
            _InfoRow(label: 'PAN', value: detail.pan),
            const Divider(height: 16),
            _InfoRow(label: 'AY', value: detail.assessmentYear),
            const Divider(height: 16),
            _InfoRow(label: 'File Size', value: detail.fileSize),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Schema check tile
// ---------------------------------------------------------------------------

class _SchemaCheckTile extends StatelessWidget {
  const _SchemaCheckTile({required this.check});

  final SchemaCheck check;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(check.result.icon, color: check.result.color),
        title: Text(
          check.rule,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          check.detail,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submission tile
// ---------------------------------------------------------------------------

class _SubmissionTile extends StatelessWidget {
  const _SubmissionTile({required this.record});

  final SubmissionRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cloud_done_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  record.portal,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ack: ${record.ackNumber}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
