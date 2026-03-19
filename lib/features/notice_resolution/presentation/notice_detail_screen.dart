import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/notice_resolution_providers.dart';
import '../domain/models/notice_case.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

/// Full notice detail view with timeline and response preparation.
///
/// Route: `/notice-resolution/detail/:noticeId`
class NoticeDetailScreen extends ConsumerWidget {
  const NoticeDetailScreen({required this.noticeId, super.key});

  final String noticeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(allNoticeCasesProvider);
    final notice = notices.where((n) => n.id == noticeId).firstOrNull;

    if (notice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notice Detail')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: 16),
              const Text('Notice not found'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: notice.severity.color,
        foregroundColor: Colors.white,
        title: Text(
          'Notice — ${notice.clientName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notice header
            _NoticeHeaderCard(notice: notice),
            const SizedBox(height: 16),

            // Date & amount info
            _NoticeInfoCard(notice: notice),
            const SizedBox(height: 16),

            // Status timeline
            _StatusTimeline(notice: notice),
            const SizedBox(height: 16),

            // Response preparation
            _ResponseSection(notice: notice),
            const SizedBox(height: 16),

            // AI suggestion
            _AiSuggestionCard(notice: notice),
            const SizedBox(height: 24),

            // Action buttons
            _ActionButtons(notice: notice),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notice header card
// ---------------------------------------------------------------------------

class _NoticeHeaderCard extends StatelessWidget {
  const _NoticeHeaderCard({required this.notice});

  final NoticeCase notice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = notice.daysLeft;

    return Card(
      elevation: 0,
      color: notice.severity.color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: notice.severity.color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(notice.status.icon, color: notice.status.color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notice.noticeType.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _SeverityBadge(severity: notice.severity),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notice.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusChip(status: notice.status),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _daysColor(daysLeft).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysLeft >= 0
                        ? '$daysLeft days to respond'
                        : '${daysLeft.abs()} days overdue',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _daysColor(daysLeft),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _daysColor(int days) {
    if (days < 0) return AppColors.error;
    if (days <= 3) return AppColors.error;
    if (days <= 7) return AppColors.warning;
    return AppColors.success;
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final NoticeSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: severity.color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final NoticeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notice info card
// ---------------------------------------------------------------------------

class _NoticeInfoCard extends StatelessWidget {
  const _NoticeInfoCard({required this.notice});

  final NoticeCase notice;

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
            _DetailRow(label: 'Client', value: notice.clientName),
            _DetailRow(label: 'Section', value: notice.section),
            _DetailRow(label: 'Notice Type', value: notice.noticeType.label),
            _DetailRow(
              label: 'Received',
              value: _dateFmt.format(notice.receivedDate),
            ),
            _DetailRow(
              label: 'Response Due',
              value: _dateFmt.format(notice.dueDate),
            ),
            _DetailRow(
              label: 'Amount in Dispute',
              value: notice.formattedAmount,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status timeline
// ---------------------------------------------------------------------------

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.notice});

  final NoticeCase notice;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statusIndex(notice.status);
    final steps = [
      _TimelineStep(
        title: 'Received',
        subtitle: _dateFmt.format(notice.receivedDate),
      ),
      const _TimelineStep(
        title: 'Under Review',
        subtitle: 'Analysis in progress',
      ),
      const _TimelineStep(
        title: 'Response Drafted',
        subtitle: 'Draft prepared',
      ),
      const _TimelineStep(title: 'Submitted', subtitle: 'Response filed'),
      const _TimelineStep(title: 'Resolved', subtitle: 'Notice resolved'),
    ];

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
            const Text(
              'Resolution Timeline',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              final isCompleted = index < currentIndex;
              final isActive = index == currentIndex;
              final color = isCompleted
                  ? AppColors.success
                  : isActive
                  ? AppColors.primary
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
                              color: isCompleted || isActive
                                  ? color
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 2),
                            ),
                            child: isCompleted
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
                                color: isCompleted
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
                                color: isCompleted || isActive
                                    ? AppColors.neutral900
                                    : AppColors.neutral400,
                              ),
                            ),
                            Text(
                              step.subtitle,
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

  int _statusIndex(NoticeStatus status) {
    switch (status) {
      case NoticeStatus.pendingReview:
        return 1;
      case NoticeStatus.draftReady:
        return 2;
      case NoticeStatus.submitted:
        return 3;
      case NoticeStatus.closed:
        return 4;
      case NoticeStatus.escalated:
        return 1;
    }
  }
}

class _TimelineStep {
  const _TimelineStep({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

// ---------------------------------------------------------------------------
// Response preparation section
// ---------------------------------------------------------------------------

class _ResponseSection extends StatelessWidget {
  const _ResponseSection({required this.notice});

  final NoticeCase notice;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Response Preparation',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Draft your response here...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document picker opened'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.attach_file_rounded, size: 16),
                    label: const Text('Attach Documents'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Response saved as draft'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral600,
                    ),
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
// AI suggestion card
// ---------------------------------------------------------------------------

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({required this.notice});

  final NoticeCase notice;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.accent.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI Response Suggestion',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Get an AI-generated draft response based on the notice type, '
              'applicable sections, and similar past cases in your practice.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI is generating a response draft...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Generate AI Draft'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
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
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.notice});

  final NoticeCase notice;

  @override
  Widget build(BuildContext context) {
    if (notice.status == NoticeStatus.closed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text(
              'This notice has been resolved',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () =>
              _showSnack(context, 'Response submitted successfully'),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Submit Response'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'Escalated to senior partner'),
          icon: const Icon(Icons.arrow_upward_rounded, size: 18),
          label: const Text('Escalate'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
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
            width: 120,
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
