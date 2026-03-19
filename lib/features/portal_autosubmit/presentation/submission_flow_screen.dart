import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';

// ---------------------------------------------------------------------------
// Flow step model
// ---------------------------------------------------------------------------

enum _FlowStatus { waiting, running, paused, done, failed }

class _FlowStep {
  const _FlowStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.status = _FlowStatus.waiting,
    this.detail,
  });

  final SubmissionStep step;
  final String title;
  final String subtitle;
  final IconData icon;
  final _FlowStatus status;
  final String? detail;

  _FlowStep copyWith({_FlowStatus? status, String? detail}) => _FlowStep(
    step: step,
    title: title,
    subtitle: subtitle,
    icon: icon,
    status: status ?? this.status,
    detail: detail ?? this.detail,
  );
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SubmissionFlowScreen extends ConsumerStatefulWidget {
  const SubmissionFlowScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<SubmissionFlowScreen> createState() =>
      _SubmissionFlowScreenState();
}

class _SubmissionFlowScreenState extends ConsumerState<SubmissionFlowScreen> {
  late List<_FlowStep> _steps;
  int _currentIndex = -1;
  bool _isRunning = false;
  bool _awaitingOtp = false;
  bool _awaitingReview = false;
  bool _completed = false;
  bool _failed = false;
  String? _ackNumber;
  final _otpController = TextEditingController();
  final _logs = <String>[];

  @override
  void initState() {
    super.initState();
    _steps = [
      const _FlowStep(
        step: SubmissionStep.loggingIn,
        title: 'Portal Login',
        subtitle: 'Logging into incometax.gov.in with PAN & password',
        icon: Icons.login_rounded,
      ),
      const _FlowStep(
        step: SubmissionStep.filling,
        title: 'Form Fill',
        subtitle: 'Uploading ITR-1 JSON and filling form fields',
        icon: Icons.edit_document,
      ),
      const _FlowStep(
        step: SubmissionStep.otp,
        title: 'OTP Verification',
        subtitle: 'Enter the OTP sent to registered mobile',
        icon: Icons.sms_rounded,
      ),
      const _FlowStep(
        step: SubmissionStep.reviewing,
        title: 'Review & Confirm',
        subtitle: 'Verify all details before final submission',
        icon: Icons.fact_check_rounded,
      ),
      const _FlowStep(
        step: SubmissionStep.submitting,
        title: 'Submit Return',
        subtitle: 'Submitting ITR-1 to Income Tax Department',
        icon: Icons.cloud_upload_rounded,
      ),
      const _FlowStep(
        step: SubmissionStep.downloading,
        title: 'Download Acknowledgement',
        subtitle: 'Downloading ITR-V and acknowledgement receipt',
        icon: Icons.download_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    final time = TimeOfDay.now().format(context);
    setState(() => _logs.add('[$time] $message'));
  }

  // ---------------------------------------------------------------------------
  // Automation simulation
  // ---------------------------------------------------------------------------

  Future<void> _startAutomation() async {
    setState(() => _isRunning = true);
    _addLog('Starting portal automation...');

    final orchestrator = ref.read(submissionOrchestratorProvider);

    for (var i = 0; i < _steps.length; i++) {
      if (!mounted || _failed) break;

      _currentIndex = i;
      setState(() {
        _steps = [
          for (var j = 0; j < _steps.length; j++)
            if (j == i)
              _steps[j].copyWith(status: _FlowStatus.running)
            else if (j < i)
              _steps[j].copyWith(status: _FlowStatus.done)
            else
              _steps[j],
        ];
      });

      // Update orchestrator
      orchestrator.updateStep(
        widget.jobId,
        _steps[i].step,
        message: _steps[i].title,
      );
      _addLog(_steps[i].title);

      switch (_steps[i].step) {
        case SubmissionStep.loggingIn:
          await _simulateLogin();

        case SubmissionStep.filling:
          await _simulateFormFill();

        case SubmissionStep.otp:
          await _waitForOtp();

        case SubmissionStep.reviewing:
          await _waitForReview();

        case SubmissionStep.submitting:
          await _simulateSubmit();

        case SubmissionStep.downloading:
          await _simulateDownload();

        default:
          break;
      }

      if (_failed) break;

      // Mark step done
      if (mounted) {
        setState(() {
          _steps = [
            for (var j = 0; j < _steps.length; j++)
              if (j == i)
                _steps[j].copyWith(status: _FlowStatus.done)
              else
                _steps[j],
          ];
        });
      }
    }

    if (mounted && !_failed) {
      _ackNumber = 'ACK${DateTime.now().millisecondsSinceEpoch}';
      orchestrator.markDone(
        widget.jobId,
        ackNumber: _ackNumber!,
        filedAt: DateTime.now(),
      );
      _addLog('Filing complete! Ack: $_ackNumber');
      setState(() {
        _isRunning = false;
        _completed = true;
      });
    }
  }

  Future<void> _simulateLogin() async {
    _addLog('Navigating to incometax.gov.in...');
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _addLog('Entering PAN and password...');
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _addLog('Solving CAPTCHA...');
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _addLog('Login successful');
  }

  Future<void> _simulateFormFill() async {
    _addLog('Navigating to e-File > ITR-1...');
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _addLog('Uploading JSON payload...');
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _addLog('Validating uploaded data...');
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _addLog('Form fields populated successfully');
  }

  Future<void> _waitForOtp() async {
    _addLog('OTP sent to registered mobile. Waiting for input...');
    setState(() {
      _awaitingOtp = true;
      _steps = [
        for (var j = 0; j < _steps.length; j++)
          if (j == _currentIndex)
            _steps[j].copyWith(
              status: _FlowStatus.paused,
              detail: 'Enter OTP from your mobile',
            )
          else
            _steps[j],
      ];
    });

    // Wait until OTP is submitted
    while (_awaitingOtp && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;
    _addLog('OTP verified successfully');
  }

  void _submitOtp() {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    _addLog('Submitting OTP: ${otp.substring(0, 3)}***');
    _otpController.clear();
    setState(() => _awaitingOtp = false);
  }

  Future<void> _waitForReview() async {
    _addLog('Automation paused — please review details before submission');
    setState(() {
      _awaitingReview = true;
      _steps = [
        for (var j = 0; j < _steps.length; j++)
          if (j == _currentIndex)
            _steps[j].copyWith(
              status: _FlowStatus.paused,
              detail: 'Confirm details to proceed with submission',
            )
          else
            _steps[j],
      ];
    });

    while (_awaitingReview && mounted && !_failed) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  void _confirmReview() {
    _addLog('CA confirmed — proceeding with submission');
    setState(() => _awaitingReview = false);
  }

  void _rejectReview() {
    _addLog('CA rejected — aborting submission');
    final orchestrator = ref.read(submissionOrchestratorProvider);
    orchestrator.markFailed(widget.jobId, 'Rejected by CA at review step');
    setState(() {
      _awaitingReview = false;
      _failed = true;
      _isRunning = false;
      _steps = [
        for (var j = 0; j < _steps.length; j++)
          if (j == _currentIndex)
            _steps[j].copyWith(status: _FlowStatus.failed)
          else
            _steps[j],
      ];
    });
  }

  Future<void> _simulateSubmit() async {
    _addLog('Clicking "Submit" on ITD portal...');
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _addLog('Return submitted successfully');
  }

  Future<void> _simulateDownload() async {
    _addLog('Downloading ITR-V acknowledgement...');
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _addLog('ITR-V saved to documents');
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Filing Automation', style: TextStyle(fontSize: 16)),
        leading: BackButton(
          onPressed: () {
            if (_isRunning && !_awaitingOtp && !_awaitingReview) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cannot go back while automation is running'),
                  backgroundColor: AppColors.warning,
                ),
              );
              return;
            }
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Status banner
          _StatusBanner(
            completed: _completed,
            failed: _failed,
            isRunning: _isRunning,
            ackNumber: _ackNumber,
          ),

          // Steps timeline
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < _steps.length; i++) ...[
                  _StepTile(step: _steps[i], isLast: i == _steps.length - 1),

                  // OTP input inline
                  if (i == _currentIndex && _awaitingOtp)
                    _OtpInputCard(
                      controller: _otpController,
                      onSubmit: _submitOtp,
                    ),

                  // Review confirmation inline
                  if (i == _currentIndex && _awaitingReview)
                    _ReviewConfirmCard(
                      onConfirm: _confirmReview,
                      onReject: _rejectReview,
                    ),
                ],

                const SizedBox(height: 16),

                // Activity log
                _ActivityLog(logs: _logs),
              ],
            ),
          ),

          // Bottom action bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: _completed
                    ? FilledButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Done — Return to Queue'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      )
                    : _failed
                    ? OutlinedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Queue'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      )
                    : !_isRunning
                    ? FilledButton.icon(
                        onPressed: _startAutomation,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Filing Automation'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status banner
// ---------------------------------------------------------------------------

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.completed,
    required this.failed,
    required this.isRunning,
    this.ackNumber,
  });

  final bool completed;
  final bool failed;
  final bool isRunning;
  final String? ackNumber;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Container(
        width: double.infinity,
        color: AppColors.success.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Return Filed Successfully',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  if (ackNumber != null)
                    Text(
                      'Ack: $ackNumber',
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
      );
    }

    if (failed) {
      return Container(
        width: double.infinity,
        color: AppColors.error.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            Icon(Icons.error_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text(
              'Submission aborted',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    if (isRunning) {
      return Container(
        width: double.infinity,
        color: AppColors.secondary.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Automation in progress...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: AppColors.neutral100,
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.neutral600),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Review the steps below, then tap "Start" to begin '
              'automated filing on the IT portal.',
              style: TextStyle(fontSize: 13, color: AppColors.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step tile
// ---------------------------------------------------------------------------

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.isLast});

  final _FlowStep step;
  final bool isLast;

  Color get _lineColor => switch (step.status) {
    _FlowStatus.done => AppColors.success,
    _FlowStatus.running || _FlowStatus.paused => AppColors.secondary,
    _FlowStatus.failed => AppColors.error,
    _FlowStatus.waiting => AppColors.neutral200,
  };

  Color get _iconBgColor => switch (step.status) {
    _FlowStatus.done => AppColors.success,
    _FlowStatus.running => AppColors.secondary,
    _FlowStatus.paused => AppColors.warning,
    _FlowStatus.failed => AppColors.error,
    _FlowStatus.waiting => AppColors.neutral200,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: step.status == _FlowStatus.running
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          step.status == _FlowStatus.done
                              ? Icons.check_rounded
                              : step.status == _FlowStatus.failed
                              ? Icons.close_rounded
                              : step.icon,
                          size: 16,
                          color: step.status == _FlowStatus.waiting
                              ? AppColors.neutral400
                              : Colors.white,
                        ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: _lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: step.status == _FlowStatus.waiting
                          ? AppColors.neutral400
                          : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.detail ?? step.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: step.status == _FlowStatus.paused
                          ? AppColors.warning
                          : AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OTP input card
// ---------------------------------------------------------------------------

class _OtpInputCard extends StatelessWidget {
  const _OtpInputCard({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 52, bottom: 16),
      color: AppColors.warning.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'An OTP has been sent to the registered mobile number. '
              'Enter it below to continue.',
              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      hintText: '6-digit OTP',
                      counterText: '',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                  ),
                  child: const Text('Verify'),
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
// Review confirmation card
// ---------------------------------------------------------------------------

class _ReviewConfirmCard extends StatelessWidget {
  const _ReviewConfirmCard({required this.onConfirm, required this.onReject});

  final VoidCallback onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 52, bottom: 16),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm Submission',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'The form has been filled and validated. Please review the '
              'details on the portal and confirm to proceed with final '
              'submission.',
              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Reject & Abort'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Confirm & Submit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
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
// Activity log
// ---------------------------------------------------------------------------

class _ActivityLog extends StatelessWidget {
  const _ActivityLog({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Activity Log',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.neutral600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final log in logs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      log,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF4EC9B0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
