import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _ComplianceItem {
  const _ComplianceItem({
    required this.name,
    required this.frequency,
    required this.isApplicable,
    required this.nextDue,
  });

  final String name;
  final String frequency;
  final bool isApplicable;
  final String nextDue;
}

class _DueDate {
  const _DueDate({
    required this.description,
    required this.date,
    required this.form,
  });

  final String description;
  final String date;
  final String form;
}

class _TaxTip {
  const _TaxTip({
    required this.title,
    required this.description,
    required this.potentialSaving,
  });

  final String title;
  final String description;
  final String potentialSaving;
}

class _Scheme {
  const _Scheme({
    required this.name,
    required this.authority,
    required this.benefit,
  });

  final String name;
  final String authority;
  final String benefit;
}

class _PlaybookDetail {
  const _PlaybookDetail({
    required this.id,
    required this.industry,
    required this.description,
    required this.complianceItems,
    required this.dueDates,
    required this.taxTips,
    required this.schemes,
  });

  final String id;
  final String industry;
  final String description;
  final List<_ComplianceItem> complianceItems;
  final List<_DueDate> dueDates;
  final List<_TaxTip> taxTips;
  final List<_Scheme> schemes;
}

const _mockPlaybook = _PlaybookDetail(
  id: 'PB-MFG-001',
  industry: 'Manufacturing',
  description:
      'Comprehensive compliance playbook for manufacturing companies including '
      'factories, production units, and industrial enterprises. Covers statutory, '
      'tax, environmental, and labour law compliances.',
  complianceItems: [
    _ComplianceItem(
      name: 'GST Monthly Return (GSTR-3B)',
      frequency: 'Monthly',
      isApplicable: true,
      nextDue: '20 Apr 2026',
    ),
    _ComplianceItem(
      name: 'TDS Return (Form 26Q)',
      frequency: 'Quarterly',
      isApplicable: true,
      nextDue: '31 May 2026',
    ),
    _ComplianceItem(
      name: 'Factories Act Renewal',
      frequency: 'Annual',
      isApplicable: true,
      nextDue: '31 Dec 2026',
    ),
    _ComplianceItem(
      name: 'Pollution Control Board Consent',
      frequency: 'Annual',
      isApplicable: true,
      nextDue: '30 Jun 2026',
    ),
    _ComplianceItem(
      name: 'EPF Return (ECR)',
      frequency: 'Monthly',
      isApplicable: true,
      nextDue: '15 Apr 2026',
    ),
    _ComplianceItem(
      name: 'ESI Return',
      frequency: 'Half-Yearly',
      isApplicable: false,
      nextDue: '-',
    ),
  ],
  dueDates: [
    _DueDate(
      description: 'Advance Tax Q4 Payment',
      date: '15 Mar 2026',
      form: 'Challan 280',
    ),
    _DueDate(
      description: 'GSTR-3B for March',
      date: '20 Apr 2026',
      form: 'GSTR-3B',
    ),
    _DueDate(
      description: 'TDS Q4 Return Filing',
      date: '31 May 2026',
      form: 'Form 26Q',
    ),
    _DueDate(
      description: 'Annual Return Filing',
      date: '31 Jul 2026',
      form: 'ITR-6',
    ),
    _DueDate(
      description: 'Tax Audit Report',
      date: '30 Sep 2026',
      form: 'Form 3CD',
    ),
  ],
  taxTips: [
    _TaxTip(
      title: 'Section 35AD - Capital Expenditure Deduction',
      description:
          'Claim 100% deduction on capex for setting up cold chain, '
          'warehousing, or specified manufacturing facilities.',
      potentialSaving: 'Up to 100% of capex',
    ),
    _TaxTip(
      title: 'Concessional Rate u/s 115BAB',
      description:
          'New manufacturing companies incorporated after Oct 2019 can '
          'opt for 15% tax rate (effective ~17.16% with surcharge).',
      potentialSaving: '8-10% tax rate reduction',
    ),
    _TaxTip(
      title: 'Depreciation on Plant & Machinery',
      description:
          'Additional depreciation of 20% on new P&M for manufacturing. '
          'Ensure assets are put to use before year-end.',
      potentialSaving: '20% additional depreciation',
    ),
  ],
  schemes: [
    _Scheme(
      name: 'Production Linked Incentive (PLI)',
      authority: 'DPIIT',
      benefit: '4-6% incentive on incremental production',
    ),
    _Scheme(
      name: 'MSME Registration Benefits',
      authority: 'MSME Ministry',
      benefit: 'Priority lending, subsidy on patent registration',
    ),
    _Scheme(
      name: 'Technology Upgradation Fund (TUF)',
      authority: 'Ministry of Textiles',
      benefit: '5% interest subsidy on technology upgradation loans',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Industry-specific compliance playbook detail.
///
/// Route: `/industry-playbooks/detail/:playbookId`
class PlaybookDetailScreen extends ConsumerWidget {
  const PlaybookDetailScreen({required this.playbookId, super.key});

  final String playbookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pb = _mockPlaybook;
    final applicable = pb.complianceItems.where((c) => c.isApplicable).length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('${pb.industry} Playbook'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Row(
            children: [
              SummaryCard(
                label: 'Compliances',
                value: '$applicable',
                icon: Icons.checklist_rounded,
                color: AppColors.primary,
              ),
              SummaryCard(
                label: 'Due Dates',
                value: '${pb.dueDates.length}',
                icon: Icons.event_rounded,
                color: AppColors.accent,
              ),
              SummaryCard(
                label: 'Tax Tips',
                value: '${pb.taxTips.length}',
                icon: Icons.lightbulb_outline_rounded,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DescriptionCard(text: pb.description),
          const SizedBox(height: 20),

          // Compliance checklist
          const SectionHeader(
            title: 'Applicable Compliances',
            icon: Icons.checklist_rounded,
          ),
          const SizedBox(height: 8),
          ...pb.complianceItems.map((c) => _ComplianceRow(item: c)),
          const SizedBox(height: 20),

          // Due dates timeline
          const SectionHeader(
            title: 'Key Due Dates',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 8),
          ...pb.dueDates.map((d) => _DueDateRow(dueDate: d)),
          const SizedBox(height: 20),

          // Tax tips
          const SectionHeader(
            title: 'Tax Planning Tips',
            icon: Icons.savings_rounded,
          ),
          const SizedBox(height: 8),
          ...pb.taxTips.map((t) => _TaxTipCard(tip: t)),
          const SizedBox(height: 20),

          // Schemes
          const SectionHeader(
            title: 'Applicable Schemes & Incentives',
            icon: Icons.card_giftcard_rounded,
          ),
          const SizedBox(height: 8),
          ...pb.schemes.map((s) => _SchemeCard(scheme: s)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.text});

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

class _ComplianceRow extends StatelessWidget {
  const _ComplianceRow({required this.item});

  final _ComplianceItem item;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              item.isApplicable
                  ? Icons.check_circle_rounded
                  : Icons.remove_circle_outline_rounded,
              size: 20,
              color: item.isApplicable
                  ? AppColors.success
                  : AppColors.neutral300,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral900,
                    ),
                  ),
                  Text(
                    item.frequency,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isApplicable)
              Text(
                item.nextDue,
                style: const TextStyle(fontSize: 11, color: AppColors.accent),
              ),
          ],
        ),
      ),
    );
  }
}

class _DueDateRow extends StatelessWidget {
  const _DueDateRow({required this.dueDate});

  final _DueDate dueDate;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                dueDate.date,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dueDate.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            StatusBadge(label: dueDate.form, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

class _TaxTipCard extends StatelessWidget {
  const _TaxTipCard({required this.tip});

  final _TaxTip tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.success.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tip.description,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            const SizedBox(height: 6),
            StatusBadge(label: tip.potentialSaving, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.scheme});

  final _Scheme scheme;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    scheme.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                StatusBadge(
                  label: scheme.authority,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              scheme.benefit,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}
