import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Card showing the current state of a [SubmissionJob].
///
/// Displays portal type badge, return type, client name, and a step-by-step
/// progress indicator. Shows an error state with a retry button on failure.
class SubmissionProgressCard extends StatelessWidget {
  const SubmissionProgressCard({
    super.key,
    required this.job,
    this.onTap,
    this.onRetry,
  });

  final SubmissionJob job;

  /// Called when the card is tapped (to open detail view).
  final VoidCallback? onTap;

  /// Called when the retry button is pressed on a failed job.
  final VoidCallback? onRetry;

  // Steps shown in the progress indicator (excludes pending and done edges).
  static const _steps = [
    SubmissionStep.loggingIn,
    SubmissionStep.filling,
    SubmissionStep.otp,
    SubmissionStep.submitting,
    SubmissionStep.downloading,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: job.isFailed
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.neutral200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(job: job),
              const SizedBox(height: 12),
              _StepIndicator(job: job, steps: _steps),
              if (job.isFailed) ...[
                const SizedBox(height: 10),
                _ErrorRow(job: job, onRetry: onRetry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: portal badge + client info + status
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.job});

  final SubmissionJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _PortalBadge(portalType: job.portalType),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.clientName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                job.returnType,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(step: job.currentStep),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Portal colour badge
// ---------------------------------------------------------------------------

class _PortalBadge extends StatelessWidget {
  const _PortalBadge({required this.portalType});

  final PortalType portalType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        _abbrev,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color get _color => switch (portalType) {
    PortalType.itd => AppColors.primary,
    PortalType.gstn => const Color(0xFF1B7A2C),
    PortalType.traces => const Color(0xFF0D5E8C),
    PortalType.mca => const Color(0xFF7B2D8C),
    PortalType.epfo => const Color(0xFFB85C00),
  };

  String get _abbrev => switch (portalType) {
    PortalType.itd => 'ITD',
    PortalType.gstn => 'GST',
    PortalType.traces => 'TDS',
    PortalType.mca => 'MCA',
    PortalType.epfo => 'PF',
  };
}

// ---------------------------------------------------------------------------
// Status badge chip
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.step});

  final SubmissionStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        step.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _bgColor => switch (step) {
    SubmissionStep.done => AppColors.success.withValues(alpha: 0.12),
    SubmissionStep.failed => AppColors.error.withValues(alpha: 0.12),
    SubmissionStep.pending => AppColors.neutral200,
    _ => AppColors.primary.withValues(alpha: 0.1),
  };

  Color get _textColor => switch (step) {
    SubmissionStep.done => AppColors.success,
    SubmissionStep.failed => AppColors.error,
    SubmissionStep.pending => AppColors.neutral400,
    _ => AppColors.primary,
  };
}

// ---------------------------------------------------------------------------
// Step progress indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.job, required this.steps});

  final SubmissionJob job;
  final List<SubmissionStep> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepDot(step: steps[i], job: job),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: _connectorColor(steps[i], steps[i + 1]),
              ),
            ),
        ],
      ],
    );
  }

  Color _connectorColor(SubmissionStep a, SubmissionStep b) {
    final aIdx = SubmissionStep.values.indexOf(a);
    final curIdx = SubmissionStep.values.indexOf(job.currentStep);
    if (job.isCompleted || aIdx < curIdx) return AppColors.primary;
    return AppColors.neutral200;
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.step, required this.job});

  final SubmissionStep step;
  final SubmissionJob job;

  @override
  Widget build(BuildContext context) {
    final stepIdx = SubmissionStep.values.indexOf(step);
    final curIdx = SubmissionStep.values.indexOf(job.currentStep);
    final isCurrent = step == job.currentStep;
    final isPast = job.isCompleted || stepIdx < curIdx;
    final isFailed = job.isFailed && isCurrent;

    Color dotColor;
    Widget child;

    if (isFailed) {
      dotColor = AppColors.error;
      child = const Icon(Icons.close, size: 10, color: Colors.white);
    } else if (isPast) {
      dotColor = AppColors.primary;
      child = const Icon(Icons.check, size: 10, color: Colors.white);
    } else if (isCurrent) {
      dotColor = AppColors.primary;
      child = const SizedBox(
        width: 8,
        height: 8,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    } else {
      dotColor = AppColors.neutral200;
      child = const SizedBox.shrink();
    }

    return Tooltip(
      message: step.label,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error row
// ---------------------------------------------------------------------------

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.job, this.onRetry});

  final SubmissionJob job;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Icon(Icons.error_outline, size: 14, color: AppColors.error),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            job.errorMessage ?? 'An error occurred',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (job.canRetry && onRetry != null) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ],
    );
  }
}
