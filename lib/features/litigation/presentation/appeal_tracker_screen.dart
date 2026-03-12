import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/litigation/data/providers/litigation_providers.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';

/// Screen listing all appeal cases with stage timelines using [Stepper].
class AppealTrackerScreen extends ConsumerWidget {
  const AppealTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appeals = ref.watch(appealListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appeal Tracker',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: appeals.isEmpty
          ? Center(
              child: Text(
                'No appeals on record.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: appeals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _AppealCard(appeal: appeals[index]);
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Appeal card with stepper timeline
// ---------------------------------------------------------------------------

class _AppealCard extends StatefulWidget {
  const _AppealCard({required this.appeal});
  final AppealCase appeal;

  @override
  State<_AppealCard> createState() => _AppealCardState();
}

class _AppealCardState extends State<_AppealCard> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appeal = widget.appeal;
    final steps = _buildSteps(appeal, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'PAN: ${appeal.pan}  ·  ${appeal.assessmentYear}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusBadge(status: appeal.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Current Forum: ${_forumLabel(appeal.currentForum)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Original Demand: ${_formatPaise(appeal.originalDemand)}  '
              '·  In Dispute: ${_formatPaise(appeal.amountInDispute)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (appeal.hearingDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next Hearing: ${_fmt(appeal.hearingDate!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Next Action: ${appeal.nextAction}',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 20),

            // Stepper timeline
            Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme,
              ),
              child: Stepper(
                currentStep: _currentStep,
                physics: const NeverScrollableScrollPhysics(),
                steps: steps,
                onStepTapped: (i) => setState(() => _currentStep = i),
                controlsBuilder: (context, details) => const SizedBox.shrink(),
              ),
            ),

            // Add hearing date button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showAddHearingDialog(context),
                icon: const Icon(Icons.calendar_month, size: 16),
                label: const Text('Add Hearing Date'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Step> _buildSteps(AppealCase appeal, ThemeData theme) {
    final steps = <Step>[];

    // Completed stages from history
    for (final stage in appeal.history) {
      steps.add(
        Step(
          title: Text(_forumLabel(stage.forum)),
          subtitle: stage.orderDate != null
              ? Text(_fmt(stage.orderDate!))
              : null,
          content: _StageContent(stage: stage),
          state: _stepState(stage.outcome),
          isActive: true,
        ),
      );
    }

    // Current pending stage
    steps.add(
      Step(
        title: Text(_forumLabel(appeal.currentForum)),
        subtitle: appeal.hearingDate != null
            ? Text('Hearing: ${_fmt(appeal.hearingDate!)}')
            : const Text('Pending'),
        content: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            appeal.nextAction,
            style: theme.textTheme.bodySmall,
          ),
        ),
        state: StepState.indexed,
        isActive: true,
      ),
    );

    return steps;
  }

  StepState _stepState(StageOutcome outcome) {
    return switch (outcome) {
      StageOutcome.allowed || StageOutcome.partiallyAllowed => StepState.complete,
      StageOutcome.dismissed || StageOutcome.withdrawn => StepState.error,
      StageOutcome.pending => StepState.indexed,
    };
  }

  Future<void> _showAddHearingDialog(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hearing date set: ${_fmt(picked)}')),
    );
  }

  static String _forumLabel(AppealForum forum) {
    return switch (forum) {
      AppealForum.ao => 'AO (Assessing Officer)',
      AppealForum.cita => 'CIT(A)',
      AppealForum.itat => 'ITAT',
      AppealForum.highCourt => 'High Court',
      AppealForum.supremeCourt => 'Supreme Court',
    };
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    return '₹${_formatIndian(rupees)}';
  }

  static String _formatIndian(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }
}

class _StageContent extends StatelessWidget {
  const _StageContent({required this.stage});
  final AppealStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stage.orderSummary != null)
            Text(stage.orderSummary!, style: theme.textTheme.bodySmall),
          if (stage.reliefGranted > 0)
            Text(
              'Relief: ${_formatPaise(stage.reliefGranted)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    final s = rupees.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '₹${buf.toString()},$last3';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final AppealStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  static (String, Color, Color) _style(AppealStatus status) {
    return switch (status) {
      AppealStatus.pending => ('Pending', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      AppealStatus.admitted => ('Admitted', const Color(0xFFE3F2FD), const Color(0xFF0D47A1)),
      AppealStatus.partialRelief => ('Partial Relief', const Color(0xFFE8F5E9), const Color(0xFF1B5E20)),
      AppealStatus.fullRelief => ('Full Relief', const Color(0xFFE8F5E9), const Color(0xFF1B5E20)),
      AppealStatus.dismissed => ('Dismissed', const Color(0xFFFFEBEE), const Color(0xFFB71C1C)),
      AppealStatus.withdrawn => ('Withdrawn', const Color(0xFFF3E5F5), const Color(0xFF4A148C)),
    };
  }
}
