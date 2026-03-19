import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _ChecklistItem {
  const _ChecklistItem({required this.title, required this.isCompleted});

  final String title;
  final bool isCompleted;
}

class _AuditFinding {
  const _AuditFinding({
    required this.title,
    required this.severity,
    required this.area,
    required this.description,
  });

  final String title;
  final String severity;
  final String area;
  final String description;
}

class _EngagementDetail {
  const _EngagementDetail({
    required this.id,
    required this.clientName,
    required this.auditType,
    required this.status,
    required this.period,
    required this.scope,
    required this.engagementTerms,
    required this.completionPct,
    required this.checklist,
    required this.findings,
    required this.managementLetterDraft,
  });

  final String id;
  final String clientName;
  final String auditType;
  final String status;
  final String period;
  final String scope;
  final String engagementTerms;
  final double completionPct;
  final List<_ChecklistItem> checklist;
  final List<_AuditFinding> findings;
  final String managementLetterDraft;
}

const _mockEngagement = _EngagementDetail(
  id: 'AE-2026-014',
  clientName: 'Meridian Steel Industries Ltd',
  auditType: 'Statutory Audit',
  status: 'In Progress',
  period: 'FY 2025-26',
  scope:
      'Complete statutory audit under Companies Act 2013 including CARO 2020 '
      'reporting, tax audit u/s 44AB, and transfer pricing certification.',
  engagementTerms:
      'Engagement period: 01-Apr-2025 to 30-Sep-2026. Fee: INR 4,50,000 '
      '(exclusive of GST). Access to books, records, and management required. '
      'Reporting to Audit Committee quarterly.',
  completionPct: 0.65,
  checklist: [
    _ChecklistItem(title: 'Planning & risk assessment', isCompleted: true),
    _ChecklistItem(title: 'Internal controls evaluation', isCompleted: true),
    _ChecklistItem(title: 'Revenue recognition testing', isCompleted: true),
    _ChecklistItem(title: 'Fixed assets verification', isCompleted: true),
    _ChecklistItem(title: 'Inventory observation', isCompleted: false),
    _ChecklistItem(title: 'Debtors confirmation', isCompleted: false),
    _ChecklistItem(title: 'Related party transactions', isCompleted: false),
    _ChecklistItem(title: 'Going concern assessment', isCompleted: false),
    _ChecklistItem(title: 'CARO 2020 reporting', isCompleted: false),
    _ChecklistItem(title: 'Final review & sign-off', isCompleted: false),
  ],
  findings: [
    _AuditFinding(
      title: 'Inadequate provision for doubtful debts',
      severity: 'High',
      area: 'Trade Receivables',
      description:
          'Provision of only 2% maintained against debtors outstanding > 180 days '
          'amounting to INR 1.2 Cr. ECL model not applied per Ind AS 109.',
    ),
    _AuditFinding(
      title: 'Related party disclosure gaps',
      severity: 'Critical',
      area: 'Related Parties',
      description:
          'Transactions with 3 related entities totalling INR 85L not disclosed '
          'in the draft financial statements. Violates Ind AS 24.',
    ),
    _AuditFinding(
      title: 'Depreciation rate variance',
      severity: 'Medium',
      area: 'Fixed Assets',
      description:
          'Plant & machinery depreciation at 10% SLM instead of 15% per '
          'Schedule II for continuous process plants.',
    ),
    _AuditFinding(
      title: 'Minor GST input credit mismatch',
      severity: 'Low',
      area: 'GST Compliance',
      description: 'ITC difference of INR 12,450 between GSTR-2B and books.',
    ),
  ],
  managementLetterDraft:
      'Dear Board of Directors,\n\n'
      'During the course of our audit for FY 2025-26, we observed certain matters '
      'that require your attention for improving internal controls and financial '
      'reporting accuracy.\n\n'
      '1. The Expected Credit Loss (ECL) model should be implemented for trade '
      'receivables as required under Ind AS 109.\n\n'
      '2. A comprehensive related party transaction register should be maintained '
      'with quarterly review by the Audit Committee.\n\n'
      '3. Fixed asset useful lives should be reassessed to align with Schedule II '
      'categories for continuous process industries.\n\n'
      'We request management to provide their response within 15 days.',
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Audit engagement detail screen with checklist, findings, and letter draft.
///
/// Route: `/advanced-audit/engagement/:engagementId`
class AuditEngagementScreen extends ConsumerWidget {
  const AuditEngagementScreen({required this.engagementId, super.key});

  final String engagementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const e = _mockEngagement;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(e.id),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const _EngagementHeader(engagement: e),
          const SizedBox(height: 16),

          // Engagement terms
          const SectionHeader(
            title: 'Engagement Terms',
            icon: Icons.handshake_rounded,
          ),
          const SizedBox(height: 8),
          _ContentCard(text: e.engagementTerms),
          const SizedBox(height: 20),

          // Scope
          const SectionHeader(title: 'Audit Scope', icon: Icons.rule_rounded),
          const SizedBox(height: 8),
          _ContentCard(text: e.scope),
          const SizedBox(height: 20),

          // Checklist
          SectionHeader(
            title: 'Audit Checklist',
            icon: Icons.checklist_rounded,
            trailing: Text(
              '${(e.completionPct * 100).toInt()}%',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _ProgressBar(value: e.completionPct),
          const SizedBox(height: 8),
          ...e.checklist.map((item) => _ChecklistRow(item: item)),
          const SizedBox(height: 20),

          // Findings
          SectionHeader(
            title: 'Findings',
            icon: Icons.bug_report_rounded,
            trailing: Text(
              '${e.findings.length} issues',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...e.findings.map((f) => _FindingCard(finding: f)),
          const SizedBox(height: 20),

          // Management letter
          const SectionHeader(
            title: 'Management Letter Draft',
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 8),
          _ContentCard(text: e.managementLetterDraft),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _EngagementHeader extends StatelessWidget {
  const _EngagementHeader({required this.engagement});

  final _EngagementDetail engagement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (engagement.status) {
      'Completed' => AppColors.success,
      'In Progress' => AppColors.accent,
      _ => AppColors.neutral400,
    };

    return Card(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    engagement.clientName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                StatusBadge(label: engagement.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(
                  label: engagement.auditType,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: engagement.period,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.neutral600,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: AppColors.neutral200,
        valueColor: AlwaysStoppedAnimation<Color>(
          value >= 0.8 ? AppColors.success : AppColors.primary,
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final _ChecklistItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            item.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: item.isCompleted ? AppColors.success : AppColors.neutral300,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 13,
                color: item.isCompleted
                    ? AppColors.neutral400
                    : AppColors.neutral900,
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({required this.finding});

  final _AuditFinding finding;

  Color get _severityColor => switch (finding.severity) {
    'Critical' => AppColors.error,
    'High' => const Color(0xFFE65100),
    'Medium' => AppColors.warning,
    _ => AppColors.neutral400,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: _severityColor.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(label: finding.severity, color: _severityColor),
                const SizedBox(width: 8),
                StatusBadge(label: finding.area, color: AppColors.secondary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              finding.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              finding.description,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}
