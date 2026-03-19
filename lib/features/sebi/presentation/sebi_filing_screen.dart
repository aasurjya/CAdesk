import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum SebiRegulation {
  lodr('LODR'),
  insiderTrading('Insider Trading'),
  takeover('Takeover Code'),
  buyback('Buyback Regulations');

  const SebiRegulation(this.label);
  final String label;
}

enum SebiFilingStatus {
  draft('Draft', AppColors.neutral400, Icons.edit_note_rounded),
  pendingReview(
    'Pending Review',
    AppColors.warning,
    Icons.hourglass_empty_rounded,
  ),
  submitted('Submitted', AppColors.primary, Icons.send_rounded),
  acknowledged('Acknowledged', AppColors.success, Icons.check_circle_rounded),
  rejected('Rejected', AppColors.error, Icons.cancel_rounded);

  const SebiFilingStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class _MockFiling {
  const _MockFiling({
    required this.id,
    required this.companyName,
    required this.regulation,
    required this.regulationRef,
    required this.formType,
    required this.deadline,
    required this.status,
    required this.description,
    required this.documents,
    required this.timeline,
  });

  final String id;
  final String companyName;
  final SebiRegulation regulation;
  final String regulationRef;
  final String formType;
  final DateTime deadline;
  final SebiFilingStatus status;
  final String description;
  final List<String> documents;
  final List<_TimelineEntry> timeline;
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.title,
    required this.date,
    required this.isCompleted,
  });

  final String title;
  final DateTime date;
  final bool isCompleted;
}

final _mockFiling = _MockFiling(
  id: 'sebi-fil-001',
  companyName: 'InfraBuild Ltd',
  regulation: SebiRegulation.lodr,
  regulationRef: 'Regulation 33 — Financial Results',
  formType: 'Quarterly Financial Results',
  deadline: DateTime(2026, 4, 14),
  status: SebiFilingStatus.pendingReview,
  description:
      'Quarterly standalone and consolidated financial results for Q4 FY 2025-26 '
      'along with limited review report from statutory auditors.',
  documents: [
    'Q4 FY26 Standalone Results.pdf',
    'Q4 FY26 Consolidated Results.pdf',
    'Limited Review Report.pdf',
    'Board Resolution.pdf',
  ],
  timeline: [
    _TimelineEntry(
      title: 'Board meeting approved results',
      date: DateTime(2026, 3, 28),
      isCompleted: true,
    ),
    _TimelineEntry(
      title: 'Limited review report received',
      date: DateTime(2026, 3, 30),
      isCompleted: true,
    ),
    _TimelineEntry(
      title: 'Draft filing prepared',
      date: DateTime(2026, 4, 2),
      isCompleted: true,
    ),
    _TimelineEntry(
      title: 'Review by Compliance Officer',
      date: DateTime(2026, 4, 5),
      isCompleted: false,
    ),
    _TimelineEntry(
      title: 'Submit to BSE/NSE',
      date: DateTime(2026, 4, 14),
      isCompleted: false,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// SEBI compliance filing detail screen.
///
/// Route: `/sebi/filing/:filingId`
class SebiFilingScreen extends ConsumerWidget {
  const SebiFilingScreen({required this.filingId, super.key});

  final String filingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filing = _mockFiling;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'SEBI — ${filing.companyName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FilingHeaderCard(filing: filing),
            const SizedBox(height: 16),
            _FilingInfoCard(filing: filing),
            const SizedBox(height: 16),
            _DocumentsCard(documents: filing.documents),
            const SizedBox(height: 16),
            _SubmissionTimeline(timeline: filing.timeline),
            const SizedBox(height: 24),
            _ActionButtons(filing: filing),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filing header
// ---------------------------------------------------------------------------

class _FilingHeaderCard extends StatelessWidget {
  const _FilingHeaderCard({required this.filing});

  final _MockFiling filing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = filing.deadline.difference(DateTime.now()).inDays;

    return Card(
      elevation: 0,
      color: filing.status.color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: filing.status.color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(filing.status.icon, color: filing.status.color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    filing.regulation.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: filing.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    filing.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: filing.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              filing.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _deadlineColor(daysLeft).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                daysLeft >= 0
                    ? '$daysLeft days to deadline'
                    : '${daysLeft.abs()} days overdue',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _deadlineColor(daysLeft),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _deadlineColor(int days) {
    if (days < 0) return AppColors.error;
    if (days <= 3) return AppColors.error;
    if (days <= 7) return AppColors.warning;
    return AppColors.success;
  }
}

// ---------------------------------------------------------------------------
// Filing info
// ---------------------------------------------------------------------------

class _FilingInfoCard extends StatelessWidget {
  const _FilingInfoCard({required this.filing});

  final _MockFiling filing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'Company', value: filing.companyName),
            _DetailRow(label: 'Regulation', value: filing.regulationRef),
            _DetailRow(label: 'Form Type', value: filing.formType),
            _DetailRow(
              label: 'Deadline',
              value: _dateFmt.format(filing.deadline),
            ),
            _DetailRow(label: 'Status', value: filing.status.label),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Documents card
// ---------------------------------------------------------------------------

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.documents});

  final List<String> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
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
                  Icons.attach_file_rounded,
                  size: 18,
                  color: AppColors.primaryVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Documents (${documents.length})',
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
                        doc,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.download_rounded,
                      size: 16,
                      color: AppColors.primaryVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document picker opened'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Document'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submission timeline
// ---------------------------------------------------------------------------

class _SubmissionTimeline extends StatelessWidget {
  const _SubmissionTimeline({required this.timeline});

  final List<_TimelineEntry> timeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submission Timeline',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...timeline.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == timeline.length - 1;
              final color = step.isCompleted
                  ? AppColors.success
                  : AppColors.neutral300;

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
                              color: step.isCompleted
                                  ? color
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 2),
                            ),
                            child: step.isCompleted
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
                                color: step.isCompleted
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
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: step.isCompleted
                                    ? AppColors.neutral900
                                    : AppColors.neutral400,
                              ),
                            ),
                            Text(
                              _dateFmt.format(step.date),
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
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.filing});

  final _MockFiling filing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showSnack(context, 'Filing submitted to BSE/NSE'),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Submit Filing'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'Filing saved as draft'),
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Save Draft'),
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
            width: 100,
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
