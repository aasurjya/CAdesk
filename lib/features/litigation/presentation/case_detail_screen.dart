import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _dateFmt = DateFormat('dd MMM yyyy');
final _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9');

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum LitigationForum {
  citA('CIT(A)', 1),
  itat('ITAT', 2),
  highCourt('High Court', 3),
  supremeCourt('Supreme Court', 4);

  const LitigationForum(this.label, this.level);
  final String label;
  final int level;
}

enum CaseStatus {
  pending('Pending', AppColors.warning, Icons.hourglass_empty_rounded),
  hearingScheduled('Hearing Scheduled', AppColors.primary, Icons.event_rounded),
  partlyAllowed('Partly Allowed', AppColors.secondary, Icons.balance_rounded),
  dismissed('Dismissed', AppColors.error, Icons.cancel_rounded),
  allowed('Allowed', AppColors.success, Icons.check_circle_rounded);

  const CaseStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class _HearingDate {
  const _HearingDate({
    required this.date,
    required this.forum,
    required this.purpose,
    required this.isCompleted,
  });

  final DateTime date;
  final LitigationForum forum;
  final String purpose;
  final bool isCompleted;
}

class _Document {
  const _Document({required this.name, required this.date});

  final String name;
  final DateTime date;
}

class _MockCase {
  const _MockCase({
    required this.id,
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.currentForum,
    required this.status,
    required this.section,
    required this.amountInDispute,
    required this.lawyerName,
    required this.arName,
    required this.outcomeProbability,
    required this.hearings,
    required this.documents,
  });

  final String id;
  final String clientName;
  final String pan;
  final String assessmentYear;
  final LitigationForum currentForum;
  final CaseStatus status;
  final String section;
  final double amountInDispute;
  final String lawyerName;
  final String arName;
  final double outcomeProbability;
  final List<_HearingDate> hearings;
  final List<_Document> documents;
}

final _mockCase = _MockCase(
  id: 'lit-001',
  clientName: 'Bharat Industries Ltd',
  pan: 'AAACB1234F',
  assessmentYear: 'AY 2022-23',
  currentForum: LitigationForum.itat,
  status: CaseStatus.hearingScheduled,
  section: 'Section 68 — Unexplained Cash Credits',
  amountInDispute: 45000000,
  lawyerName: 'Adv. Suresh Patel',
  arName: 'CA Meena Agarwal',
  outcomeProbability: 72,
  hearings: [
    _HearingDate(
      date: DateTime(2024, 11, 15),
      forum: LitigationForum.citA,
      purpose: 'First hearing',
      isCompleted: true,
    ),
    _HearingDate(
      date: DateTime(2025, 3, 20),
      forum: LitigationForum.citA,
      purpose: 'Order passed — appeal filed',
      isCompleted: true,
    ),
    _HearingDate(
      date: DateTime(2025, 9, 10),
      forum: LitigationForum.itat,
      purpose: 'Admission hearing',
      isCompleted: true,
    ),
    _HearingDate(
      date: DateTime(2026, 4, 15),
      forum: LitigationForum.itat,
      purpose: 'Final hearing',
      isCompleted: false,
    ),
  ],
  documents: [
    _Document(name: 'Assessment Order u/s 143(3)', date: DateTime(2024, 8, 10)),
    _Document(name: 'CIT(A) Order', date: DateTime(2025, 3, 20)),
    _Document(name: 'ITAT Appeal Memo', date: DateTime(2025, 6, 15)),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Tax litigation case detail screen with forum hierarchy and hearing tracking.
///
/// Route: `/litigation/case/:caseId`
class CaseDetailScreen extends ConsumerWidget {
  const CaseDetailScreen({required this.caseId, super.key});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseData = _mockCase;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: caseData.status.color,
        foregroundColor: Colors.white,
        title: Text(
          'Case — ${caseData.clientName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CaseHeaderCard(caseData: caseData),
            const SizedBox(height: 16),
            _ForumHierarchyCard(currentForum: caseData.currentForum),
            const SizedBox(height: 16),
            _CaseInfoCard(caseData: caseData),
            const SizedBox(height: 16),
            _HearingTimeline(hearings: caseData.hearings),
            const SizedBox(height: 16),
            _DocumentTrailCard(documents: caseData.documents),
            const SizedBox(height: 16),
            _OutcomeProbabilityCard(probability: caseData.outcomeProbability),
            const SizedBox(height: 24),
            _ActionButtons(caseData: caseData),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Case header
// ---------------------------------------------------------------------------

class _CaseHeaderCard extends StatelessWidget {
  const _CaseHeaderCard({required this.caseData});

  final _MockCase caseData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: caseData.status.color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: caseData.status.color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  caseData.status.icon,
                  color: caseData.status.color,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    caseData.section,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: caseData.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    caseData.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: caseData.status.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'At ${caseData.currentForum.label}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _currencyFmt.format(caseData.amountInDispute),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
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

// ---------------------------------------------------------------------------
// Forum hierarchy
// ---------------------------------------------------------------------------

class _ForumHierarchyCard extends StatelessWidget {
  const _ForumHierarchyCard({required this.currentForum});

  final LitigationForum currentForum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const forums = LitigationForum.values;

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
              'Forum Hierarchy',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: forums.map((forum) {
                final isActive = forum == currentForum;
                final isPast = forum.level < currentForum.level;
                final color = isActive
                    ? AppColors.primary
                    : isPast
                    ? AppColors.success
                    : AppColors.neutral300;

                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isActive || isPast ? color : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: isPast
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : isActive
                            ? const Icon(
                                Icons.gavel,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        forum.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive || isPast
                              ? AppColors.neutral900
                              : AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Case info
// ---------------------------------------------------------------------------

class _CaseInfoCard extends StatelessWidget {
  const _CaseInfoCard({required this.caseData});

  final _MockCase caseData;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'Client', value: caseData.clientName),
            _DetailRow(label: 'PAN', value: caseData.pan),
            _DetailRow(label: 'AY', value: caseData.assessmentYear),
            _DetailRow(
              label: 'Amount',
              value: _currencyFmt.format(caseData.amountInDispute),
            ),
            _DetailRow(label: 'Lawyer', value: caseData.lawyerName),
            _DetailRow(label: 'AR', value: caseData.arName),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hearing timeline
// ---------------------------------------------------------------------------

class _HearingTimeline extends StatelessWidget {
  const _HearingTimeline({required this.hearings});

  final List<_HearingDate> hearings;

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
              'Hearing Dates',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...hearings.asMap().entries.map((entry) {
              final index = entry.key;
              final hearing = entry.value;
              final isLast = index == hearings.length - 1;
              final color = hearing.isCompleted
                  ? AppColors.success
                  : AppColors.primary;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: hearing.isCompleted
                                  ? color
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 2),
                            ),
                            child: hearing.isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: hearing.isCompleted
                                    ? AppColors.success
                                    : AppColors.neutral200,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _dateFmt.format(hearing.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: hearing.isCompleted
                                        ? AppColors.neutral900
                                        : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    hearing.forum.label,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              hearing.purpose,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document trail
// ---------------------------------------------------------------------------

class _DocumentTrailCard extends StatelessWidget {
  const _DocumentTrailCard({required this.documents});

  final List<_Document> documents;

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
            Row(
              children: [
                const Icon(
                  Icons.folder_rounded,
                  size: 18,
                  color: AppColors.primaryVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Document Trail (${documents.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...documents.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_rounded,
                      size: 16,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        doc.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      _dateFmt.format(doc.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Outcome probability
// ---------------------------------------------------------------------------

class _OutcomeProbabilityCard extends StatelessWidget {
  const _OutcomeProbabilityCard({required this.probability});

  final double probability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = probability >= 70
        ? AppColors.success
        : probability >= 40
        ? AppColors.warning
        : AppColors.error;
    final label = probability >= 70
        ? 'Favorable'
        : probability >= 40
        ? 'Moderate'
        : 'Unfavorable';

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: probability / 100,
                    strokeWidth: 5,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Text(
                    '${probability.round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outcome Probability',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$label — based on precedent analysis',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.caseData});

  final _MockCase caseData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showSnack(context, 'Hearing brief prepared'),
          icon: const Icon(Icons.description_rounded, size: 18),
          label: const Text('Prepare Hearing Brief'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'Appeal memo generated'),
          icon: const Icon(Icons.gavel_rounded, size: 18),
          label: const Text('File Next Appeal'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryVariant,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
