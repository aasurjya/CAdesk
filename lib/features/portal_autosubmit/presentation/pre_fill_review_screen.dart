import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_job_runner.dart';
import 'package:ca_app/features/portal_autosubmit/webview/file_upload_handler.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Pre-filing review screen shown before automation starts.
///
/// Displays the client's details, portal information, and credential status
/// so the CA can verify everything before tapping "Start Filing".
class PreFillReviewScreen extends ConsumerWidget {
  const PreFillReviewScreen({super.key, required this.job});

  final SubmissionJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentialAsync = ref.watch(
      credentialForPortalProvider(job.portalType),
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(
          'Review Before Filing',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Client info
            _SectionCard(
              title: 'Client Details',
              icon: Icons.person_rounded,
              children: [
                _InfoRow(label: 'Name', value: job.clientName),
                _InfoRow(label: 'Client ID', value: job.clientId),
              ],
            ),
            const SizedBox(height: 12),

            // Portal info
            _SectionCard(
              title: 'Portal Information',
              icon: Icons.language_rounded,
              children: [
                _InfoRow(label: 'Portal', value: job.portalType.label),
                _InfoRow(label: 'Return Type', value: job.returnType),
                _InfoRow(label: 'Status', value: job.currentStep.label),
              ],
            ),
            const SizedBox(height: 12),

            // Credential check
            _CredentialCard(
              credentialAsync: credentialAsync,
              portalType: job.portalType,
            ),
            const SizedBox(height: 24),

            // Start Filing button
            _StartFilingButton(job: job, credentialAsync: credentialAsync),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Credential card
// ---------------------------------------------------------------------------

class _CredentialCard extends StatelessWidget {
  const _CredentialCard({
    required this.credentialAsync,
    required this.portalType,
  });

  final AsyncValue<PortalCredential?> credentialAsync;
  final PortalType portalType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.vpn_key_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Credential Check',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            credentialAsync.when(
              loading: () => const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Checking credentials...',
                    style: TextStyle(fontSize: 13, color: AppColors.neutral400),
                  ),
                ],
              ),
              error: (error, _) => _CredentialStatus(
                hasCredential: false,
                message: 'Error loading credentials: $error',
              ),
              data: (credential) => _CredentialStatus(
                hasCredential: credential != null,
                message: credential != null
                    ? 'Credentials found for ${portalType.label}'
                          '${credential.username != null ? ' (${credential.username})' : ''}'
                    : 'No credentials stored for ${portalType.label}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Credential status row
// ---------------------------------------------------------------------------

class _CredentialStatus extends StatelessWidget {
  const _CredentialStatus({required this.hasCredential, required this.message});

  final bool hasCredential;
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = hasCredential ? AppColors.success : AppColors.error;
    final iconData = hasCredential
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return Row(
      children: [
        Icon(iconData, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Start Filing button
// ---------------------------------------------------------------------------

class _StartFilingButton extends ConsumerStatefulWidget {
  const _StartFilingButton({required this.job, required this.credentialAsync});

  final SubmissionJob job;
  final AsyncValue<PortalCredential?> credentialAsync;

  @override
  ConsumerState<_StartFilingButton> createState() => _StartFilingButtonState();
}

class _StartFilingButtonState extends ConsumerState<_StartFilingButton> {
  bool _isLoading = false;

  /// Whether the credential has loaded and is non-null.
  bool get _hasCredential {
    final async = widget.credentialAsync;
    if (async is AsyncData<PortalCredential?>) {
      return async.value != null;
    }
    return false;
  }

  bool get _canStart =>
      !_isLoading &&
      _hasCredential &&
      widget.job.currentStep == SubmissionStep.pending;

  Future<void> _startFiling() async {
    if (!_canStart) return;

    setState(() => _isLoading = true);

    try {
      final runner = ref.read(submissionJobRunnerProvider);
      final preparedRun = await runner.prepare(widget.job);

      if (!mounted) return;

      // Resolve the credential for the WebView screen.
      final credentialRepo = ref.read(autosubmitCredentialRepositoryProvider);
      final credential = await credentialRepo.getCredential(
        widget.job.portalType,
      );
      if (credential == null || !mounted) return;

      // Build file upload handler from the job's file path (if any).
      final filePath = widget.job.itrJsonPath;
      final fileHandler = filePath != null
          ? FileUploadHandler(filePath: filePath)
          : null;

      // Navigate to the PortalWebViewScreen with the prepared run.
      context.push(
        '/portal-autosubmit/webview/${widget.job.id}',
        extra: <String, dynamic>{
          'job': widget.job,
          'credential': credential,
          'runner': preparedRun.runner,
          'gate': preparedRun.confirmationGate,
          'fileUploadHandler': fileHandler,
        },
      );
    } on SubmissionRunnerException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to prepare filing: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: _canStart ? _startFiling : null,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded),
        label: Text(_isLoading ? 'Preparing...' : 'Start Filing'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral300,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
