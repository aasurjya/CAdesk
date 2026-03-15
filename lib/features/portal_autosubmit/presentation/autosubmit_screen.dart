import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/epfo_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/gstn_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/itd_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/mca_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/traces_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/widgets/portal_login_sheet.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/widgets/submission_progress_card.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_screen.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Streams all submission jobs for the live list.
final _allJobsStreamProvider = StreamProvider<List<SubmissionJob>>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  return repo.watchAll();
});

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

/// Auto-Submit Engine screen.
///
/// Shows all pending and completed submission jobs. A FAB opens the
/// [PortalLoginSheet] to queue a new job.
class AutosubmitScreen extends ConsumerWidget {
  const AutosubmitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(_allJobsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Auto-Submit Engine'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: jobsAsync.when(
        data: (jobs) =>
            jobs.isEmpty ? const _EmptyState() : _JobList(jobs: jobs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error loading jobs: $err',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewSubmissionSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Submission'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _openNewSubmissionSheet(BuildContext context, WidgetRef ref) {
    PortalLoginSheet.show(
      context,
      onSubmit:
          ({
            required String clientId,
            required String clientName,
            required PortalType portalType,
            required String returnType,
          }) {
            final orchestrator = ref.read(submissionOrchestratorProvider);
            final job = SubmissionJob(
              id: 'job_${DateTime.now().millisecondsSinceEpoch}',
              clientId: clientId,
              clientName: clientName,
              portalType: portalType,
              returnType: returnType,
              currentStep: SubmissionStep.pending,
              retryCount: 0,
              createdAt: DateTime.now(),
            );
            orchestrator.enqueue(job);
          },
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Placeholder — filter UI can be expanded in future iterations.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filter coming soon')));
  }
}

// ---------------------------------------------------------------------------
// Job list
// ---------------------------------------------------------------------------

class _JobList extends ConsumerWidget {
  const _JobList({required this.jobs});

  final List<SubmissionJob> jobs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return SubmissionProgressCard(
          job: job,
          onTap: () {
            if (job.currentStep == SubmissionStep.pending) {
              _startWebViewAutomation(context, ref, job);
            } else {
              _openDetail(context, job);
            }
          },
          onRetry: job.canRetry ? () => _retryJob(context, ref, job) : null,
        );
      },
    );
  }

  void _openDetail(BuildContext context, SubmissionJob job) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => _JobDetailScreen(job: job)));
  }

  /// Navigates to the embedded [PortalWebViewScreen] to run real automation.
  ///
  /// Fetches the stored credential for the job's portal type from the
  /// credential repository, then opens the WebView with an [AutomationRunner]
  /// that calls the correct portal service.
  ///
  /// Falls back to a mock credential when none is stored (offline/dev mode).
  Future<void> _startWebViewAutomation(
    BuildContext context,
    WidgetRef ref,
    SubmissionJob job,
  ) async {
    // Fetch the real credential; fall back to an empty mock for dev/offline.
    final credRepo = ref.read(autosubmitCredentialRepositoryProvider);
    final storedCredential = await credRepo.getCredential(job.portalType);
    final credential =
        storedCredential ??
        PortalCredential(
          id: 'cred_${job.clientId}',
          portalType: job.portalType,
          username: '',
        );

    final orchestrator = ref.read(submissionOrchestratorProvider);
    final otpService = ref.read(otpInterceptServiceProvider);

    // Build the automation runner: receives the WebView controller when ready
    // and returns the correct portal service's login stream.
    AutomationRunner runner = _buildAutomationRunner(
      job: job,
      credential: credential,
      otpService: otpService,
    );

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PortalWebViewScreen(
          job: job,
          credential: credential,
          automationRunner: runner,
          onLog: (log) {
            // Forward each log entry to the orchestrator for persistence.
            orchestrator.appendLog(log);
          },
        ),
      ),
    );
  }

  /// Returns the correct [AutomationRunner] for [job.portalType].
  ///
  /// Each runner calls the portal service's [login] method with the live
  /// [PortalWebViewController], yielding [SubmissionLog] entries that drive
  /// the progress banner and are persisted by the orchestrator.
  AutomationRunner _buildAutomationRunner({
    required SubmissionJob job,
    required PortalCredential credential,
    required OtpInterceptService otpService,
  }) {
    return (PortalWebViewController controller) {
      return switch (job.portalType) {
        PortalType.itd => const ItdAutosubmitService().login(
          credential: credential,
          otpService: otpService,
          webViewController: controller,
        ),
        PortalType.gstn => const GstnAutosubmitService().login(
          credential: credential,
          otpService: otpService,
          webViewController: controller,
        ),
        PortalType.traces => const TracesAutosubmitService().login(
          credential: credential,
          otpService: otpService,
          webViewController: controller,
        ),
        PortalType.mca => const McaAutosubmitService().login(
          credential: credential,
          otpService: otpService,
          webViewController: controller,
        ),
        PortalType.epfo => const EpfoAutosubmitService().login(
          credential: credential,
          otpService: otpService,
          webViewController: controller,
        ),
      };
    };
  }

  void _retryJob(BuildContext context, WidgetRef ref, SubmissionJob job) {
    final orchestrator = ref.read(submissionOrchestratorProvider);
    // Reset to pending for retry
    orchestrator.updateStep(
      job.id,
      SubmissionStep.pending,
      message: 'Retrying job',
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.send_rounded, size: 56, color: AppColors.neutral200),
          const SizedBox(height: 16),
          Text(
            'No submissions yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + New Submission to queue a portal filing.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Job detail screen (live log stream)
// ---------------------------------------------------------------------------

class _JobDetailScreen extends ConsumerWidget {
  const _JobDetailScreen({required this.job});

  final SubmissionJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.watch(submissionRepositoryProvider);
    final jobStream = repo.watchJob(job.id);
    final logStream = repo.watchLogs(job.id);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('${job.clientName} — ${job.returnType}'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Live job card
          StreamBuilder<SubmissionJob>(
            stream: jobStream,
            initialData: job,
            builder: (context, snapshot) {
              final liveJob = snapshot.data ?? job;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SubmissionProgressCard(job: liveJob),
              );
            },
          ),
          // Log title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 6),
                Text(
                  'Activity Log',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.neutral400,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Live log stream
          Expanded(
            child: StreamBuilder<List<SubmissionLog>>(
              stream: logStream,
              builder: (context, snapshot) {
                final newLogs = snapshot.data ?? const [];
                return _LogListView(newLogs: newLogs);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Log list (accumulates new entries)
// ---------------------------------------------------------------------------

class _LogListView extends StatefulWidget {
  const _LogListView({required this.newLogs});

  final List<SubmissionLog> newLogs;

  @override
  State<_LogListView> createState() => _LogListViewState();
}

class _LogListViewState extends State<_LogListView> {
  final List<SubmissionLog> _accumulated = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_LogListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.newLogs.isNotEmpty) {
      setState(() => _accumulated.addAll(widget.newLogs));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_accumulated.isEmpty) {
      return const Center(
        child: Text(
          'Waiting for activity...',
          style: TextStyle(color: AppColors.neutral400, fontSize: 13),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: _accumulated.length,
      itemBuilder: (context, index) => _LogEntryTile(log: _accumulated[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Single log entry tile
// ---------------------------------------------------------------------------

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.log});

  final SubmissionLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr =
        '${log.timestamp.hour.toString().padLeft(2, '0')}:'
        '${log.timestamp.minute.toString().padLeft(2, '0')}:'
        '${log.timestamp.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeStr,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            log.isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 14,
            color: log.isError ? AppColors.error : AppColors.success,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              log.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: log.isError ? AppColors.error : AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
