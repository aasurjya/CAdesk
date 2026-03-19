import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/faceless_assessment_providers.dart';
import '../domain/models/hearing_schedule.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

/// E-proceeding hearing management screen.
///
/// Route: `/faceless-assessment/hearing/:hearingId`
class HearingScreen extends ConsumerStatefulWidget {
  const HearingScreen({required this.hearingId, super.key});

  final String hearingId;

  @override
  ConsumerState<HearingScreen> createState() => _HearingScreenState();
}

class _HearingScreenState extends ConsumerState<HearingScreen> {
  final _notesController = TextEditingController();
  bool _adjournmentRequested = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hearings = ref.watch(hearingSchedulesProvider);
    final hearing = hearings.where((h) => h.id == widget.hearingId).firstOrNull;

    if (hearing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hearing Detail')),
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
              const Text('Hearing not found'),
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

    final daysUntil = hearing.daysUntilHearing;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: hearing.status.color,
        foregroundColor: Colors.white,
        title: Text(
          'Hearing — ${hearing.clientName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Countdown banner
            _CountdownBanner(daysUntil: daysUntil, hearing: hearing),
            const SizedBox(height: 16),

            // Hearing details
            _HearingInfoCard(hearing: hearing),
            const SizedBox(height: 16),

            // Documents section
            _DocumentsSection(hearing: hearing),
            const SizedBox(height: 16),

            // Hearing notes
            _NotesSection(
              controller: _notesController,
              existingNotes: hearing.notes,
            ),
            const SizedBox(height: 16),

            // Adjournment request
            if (!_adjournmentRequested &&
                hearing.status == HearingStatus.scheduled) ...[
              _AdjournmentCard(
                onRequest: () {
                  setState(() => _adjournmentRequested = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Adjournment request submitted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ] else if (_adjournmentRequested) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.pause_circle_rounded,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Adjournment request has been submitted',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            _ActionButtons(hearing: hearing),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Countdown banner
// ---------------------------------------------------------------------------

class _CountdownBanner extends StatelessWidget {
  const _CountdownBanner({required this.daysUntil, required this.hearing});

  final int daysUntil;
  final HearingSchedule hearing;

  @override
  Widget build(BuildContext context) {
    final isCompleted = hearing.status == HearingStatus.completed;
    final isAdjourned = hearing.status == HearingStatus.adjourned;
    final isCancelled = hearing.status == HearingStatus.cancelled;

    if (isCompleted || isAdjourned || isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hearing.status.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hearing.status.color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(hearing.status.icon, size: 32, color: hearing.status.color),
            const SizedBox(width: 12),
            Text(
              'Hearing ${hearing.status.label}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: hearing.status.color,
              ),
            ),
          ],
        ),
      );
    }

    final color = daysUntil <= 1
        ? AppColors.error
        : daysUntil <= 3
        ? AppColors.warning
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                daysUntil >= 0 ? '$daysUntil' : '0',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  daysUntil == 0
                      ? 'Hearing is Today'
                      : daysUntil == 1
                      ? 'Hearing Tomorrow'
                      : daysUntil < 0
                      ? 'Hearing Overdue'
                      : '$daysUntil Days Until Hearing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  '${_dateFmt.format(hearing.hearingDate)} at ${hearing.hearingTime}',
                  style: const TextStyle(
                    fontSize: 13,
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
}

// ---------------------------------------------------------------------------
// Hearing info card
// ---------------------------------------------------------------------------

class _HearingInfoCard extends StatelessWidget {
  const _HearingInfoCard({required this.hearing});

  final HearingSchedule hearing;

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
            _InfoRow(label: 'Client', value: hearing.clientName),
            _InfoRow(
              label: 'Hearing Date',
              value: _dateFmt.format(hearing.hearingDate),
            ),
            _InfoRow(label: 'Time', value: hearing.hearingTime),
            _InfoRow(label: 'Platform', value: hearing.platform.label),
            _InfoRow(
              label: 'Representative',
              value: hearing.representativeName,
            ),
            _InfoRow(label: 'Status', value: hearing.status.label),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 110,
                  child: Text(
                    'Agenda',
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ),
                Expanded(
                  child: Text(
                    hearing.agenda,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
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
// Documents section
// ---------------------------------------------------------------------------

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.hearing});

  final HearingSchedule hearing;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents to Submit',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (hearing.documentsToSubmit.isEmpty)
              const Text(
                'No documents required',
                style: TextStyle(fontSize: 13, color: AppColors.neutral400),
              )
            else
              ...hearing.documentsToSubmit.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_rounded,
                        size: 18,
                        color: AppColors.primaryVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(doc, style: const TextStyle(fontSize: 13)),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.upload_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Uploading "$doc"...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        tooltip: 'Upload',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File picker opened'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Document'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
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
// Notes section
// ---------------------------------------------------------------------------

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.controller, required this.existingNotes});

  final TextEditingController controller;
  final String? existingNotes;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hearing Notes / Minutes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            if (existingNotes != null && existingNotes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  existingNotes!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add notes from the hearing...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notes saved'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Adjournment card
// ---------------------------------------------------------------------------

class _AdjournmentCard extends StatelessWidget {
  const _AdjournmentCard({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.warning.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pause_circle_outline_rounded,
                  size: 20,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Text(
                  'Request Adjournment',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'If you need more time to prepare, request an adjournment. '
              'Provide a valid reason for the NfAC.',
              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRequest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(color: AppColors.warning),
                ),
                child: const Text('Request Adjournment'),
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
  const _ActionButtons({required this.hearing});

  final HearingSchedule hearing;

  @override
  Widget build(BuildContext context) {
    if (hearing.status == HearingStatus.completed) {
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
              'Hearing completed',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return FilledButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hearing marked as attended'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      },
      icon: const Icon(Icons.video_call_rounded, size: 18),
      label: const Text('Mark as Attended'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared info row
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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
