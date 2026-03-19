import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _AffectedClient {
  const _AffectedClient({
    required this.name,
    required this.impactLevel,
    required this.reason,
  });

  final String name;
  final String impactLevel;
  final String reason;
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.dueDate,
    required this.isCompleted,
  });

  final String title;
  final String dueDate;
  final bool isCompleted;
}

class _RelatedRegulation {
  const _RelatedRegulation({required this.title, required this.number});

  final String title;
  final String number;
}

class _RegulationDetail {
  const _RegulationDetail({
    required this.id,
    required this.title,
    required this.type,
    required this.issuedBy,
    required this.number,
    required this.effectiveDate,
    required this.applicableSections,
    required this.fullText,
    required this.affectedClients,
    required this.actionItems,
    required this.relatedRegulations,
  });

  final String id;
  final String title;
  final String type;
  final String issuedBy;
  final String number;
  final String effectiveDate;
  final List<String> applicableSections;
  final String fullText;
  final List<_AffectedClient> affectedClients;
  final List<_ActionItem> actionItems;
  final List<_RelatedRegulation> relatedRegulations;
}

const _mockRegulation = _RegulationDetail(
  id: 'REG-2026-087',
  title: 'Revised TDS Rates for Payments to Non-Residents under Section 195',
  type: 'Circular',
  issuedBy: 'CBDT',
  number: 'Circular No. 08/2026',
  effectiveDate: '01 Apr 2026',
  applicableSections: ['195', '206AA', '90', '90A', '206CCA'],
  fullText:
      'The Central Board of Direct Taxes (CBDT), in exercise of powers conferred '
      'under Section 119 of the Income Tax Act, 1961, hereby clarifies the '
      'applicable rates of TDS on payments to non-residents with effect from '
      'Assessment Year 2027-28.\n\n'
      '1. Where a non-resident has a valid Tax Residency Certificate (TRC) and '
      'Form 10F, the TDS rate shall be as per the applicable DTAA rate or the '
      'rate prescribed under the Act, whichever is lower.\n\n'
      '2. In cases where the non-resident fails to furnish PAN, the TDS shall '
      'be deducted at the rate of 20% or the rate in force, whichever is higher, '
      'as per Section 206AA.\n\n'
      '3. The payer must obtain a Certificate of No Objection from the Assessing '
      'Officer where the payment exceeds INR 50,00,000 in a financial year.\n\n'
      '4. Digital services payments to non-residents shall attract equalisation '
      'levy where applicable, and TDS under Section 195 shall not apply in '
      'such cases to avoid double taxation.',
  affectedClients: [
    _AffectedClient(
      name: 'Sunrise Technologies Pvt Ltd',
      impactLevel: 'High',
      reason: 'Significant foreign vendor payments for SaaS licenses',
    ),
    _AffectedClient(
      name: 'Meridian Steel Industries',
      impactLevel: 'Medium',
      reason: 'Technical consultancy fees to overseas consultants',
    ),
    _AffectedClient(
      name: 'Pinnacle Infotech Solutions',
      impactLevel: 'Low',
      reason: 'Minor software subscription payments',
    ),
  ],
  actionItems: [
    _ActionItem(
      title: 'Review all non-resident vendor contracts',
      dueDate: '15 Mar 2026',
      isCompleted: true,
    ),
    _ActionItem(
      title: 'Collect TRC & Form 10F from applicable vendors',
      dueDate: '31 Mar 2026',
      isCompleted: false,
    ),
    _ActionItem(
      title: 'Update TDS deduction templates for FY 2026-27',
      dueDate: '01 Apr 2026',
      isCompleted: false,
    ),
    _ActionItem(
      title: 'Communicate changes to affected clients',
      dueDate: '20 Mar 2026',
      isCompleted: true,
    ),
  ],
  relatedRegulations: [
    _RelatedRegulation(
      title: 'TDS on foreign remittances via Form 15CA/15CB',
      number: 'Circular No. 03/2025',
    ),
    _RelatedRegulation(
      title: 'Equalisation Levy on digital services',
      number: 'Notification S.O. 1978(E)',
    ),
    _RelatedRegulation(
      title: 'DTAA with USA - Article 12 (Royalties)',
      number: 'DTAA/USA/Art-12',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Regulation/circular detail with full text, impact analysis, and actions.
///
/// Route: `/regulatory-intelligence/detail/:regulationId`
class RegulationDetailScreen extends ConsumerWidget {
  const RegulationDetailScreen({required this.regulationId, super.key});

  final String regulationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = _mockRegulation;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(r.number),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(regulation: r),
          const SizedBox(height: 16),

          // Applicable sections
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: r.applicableSections
                .map(
                  (s) => StatusBadge(label: 'Sec $s', color: AppColors.primary),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // Full text
          const SectionHeader(title: 'Full Text', icon: Icons.article_rounded),
          const SizedBox(height: 8),
          _TextCard(text: r.fullText),
          const SizedBox(height: 20),

          // Impact analysis
          SectionHeader(
            title: 'Impact Analysis',
            icon: Icons.assessment_rounded,
            trailing: Text(
              '${r.affectedClients.length} clients',
              style: const TextStyle(fontSize: 12, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          ...r.affectedClients.map((c) => _ClientImpactCard(client: c)),
          const SizedBox(height: 20),

          // Action items
          const SectionHeader(
            title: 'Action Items',
            icon: Icons.task_alt_rounded,
          ),
          const SizedBox(height: 8),
          ...r.actionItems.map((a) => _ActionRow(action: a)),
          const SizedBox(height: 20),

          // Related regulations
          const SectionHeader(
            title: 'Related Regulations',
            icon: Icons.link_rounded,
          ),
          const SizedBox(height: 8),
          ...r.relatedRegulations.map((rel) => _RelatedRegRow(regulation: rel)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.regulation});

  final _RegulationDetail regulation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Text(
              regulation.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StatusBadge(label: regulation.type, color: AppColors.accent),
                const SizedBox(width: 8),
                StatusBadge(
                  label: regulation.issuedBy,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  size: 14,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Effective: ${regulation.effectiveDate}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.text});

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
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _ClientImpactCard extends StatelessWidget {
  const _ClientImpactCard({required this.client});

  final _AffectedClient client;

  Color get _impactColor => switch (client.impactLevel) {
    'High' => AppColors.error,
    'Medium' => AppColors.warning,
    _ => AppColors.neutral400,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.reason,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(label: client.impactLevel, color: _impactColor),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final _ActionItem action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            action.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: action.isCompleted
                ? AppColors.success
                : AppColors.neutral300,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              action.title,
              style: TextStyle(
                fontSize: 13,
                color: action.isCompleted
                    ? AppColors.neutral400
                    : AppColors.neutral900,
                decoration: action.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          Text(
            action.dueDate,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

class _RelatedRegRow extends StatelessWidget {
  const _RelatedRegRow({required this.regulation});

  final _RelatedRegulation regulation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.article_outlined, color: AppColors.secondary),
        title: Text(
          regulation.title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          regulation.number,
          style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.neutral400,
        ),
      ),
    );
  }
}
