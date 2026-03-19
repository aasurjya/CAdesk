import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/data/repositories/mock_submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/repositories/submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/epfo_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/gstn_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/itd_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/mca_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_job_runner.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/traces_autosubmit_service.dart';
import 'package:ca_app/features/portal_connector/data/providers/portal_connector_repository_providers.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Provides the active [SubmissionRepository] implementation.
///
/// Swap [MockSubmissionRepository] for a real SQLite-backed implementation
/// in the production binding without changing any consumer code.
final submissionRepositoryProvider = Provider<SubmissionRepository>(
  (_) => MockSubmissionRepository(),
);

// ---------------------------------------------------------------------------
// Orchestrator
// ---------------------------------------------------------------------------

/// Provides the shared [SubmissionOrchestrator] instance.
final submissionOrchestratorProvider = Provider<SubmissionOrchestrator>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  return SubmissionOrchestrator(repository: repo);
});

// ---------------------------------------------------------------------------
// OTP service (one per session — shared across portals)
// ---------------------------------------------------------------------------

/// Provides a single [OtpInterceptService] for the current app session.
final otpInterceptServiceProvider = Provider<OtpInterceptService>(
  (_) => OtpInterceptService(),
);

// ---------------------------------------------------------------------------
// Portal services
// ---------------------------------------------------------------------------

final itdAutosubmitServiceProvider = Provider<ItdAutosubmitService>(
  (_) => const ItdAutosubmitService(),
);

final gstnAutosubmitServiceProvider = Provider<GstnAutosubmitService>(
  (_) => const GstnAutosubmitService(),
);

final tracesAutosubmitServiceProvider = Provider<TracesAutosubmitService>(
  (_) => const TracesAutosubmitService(),
);

final mcaAutosubmitServiceProvider = Provider<McaAutosubmitService>(
  (_) => const McaAutosubmitService(),
);

final epfoAutosubmitServiceProvider = Provider<EpfoAutosubmitService>(
  (_) => const EpfoAutosubmitService(),
);

// ---------------------------------------------------------------------------
// Credential lookup
// ---------------------------------------------------------------------------

/// Re-exports [portalCredentialRepositoryProvider] so autosubmit consumers
/// only need to import this single providers file.
///
/// Returns the [PortalCredentialRepository] (mock or real depending on flags).
final autosubmitCredentialRepositoryProvider =
    Provider<PortalCredentialRepository>((ref) {
      return ref.watch(portalCredentialRepositoryProvider);
    });

/// Async provider that resolves the [PortalCredential] for a given
/// [PortalType] from the credential repository.
///
/// Returns `null` when no credential has been stored for [portalType].
///
/// Usage:
/// ```dart
/// final credAsync = ref.watch(credentialForPortalProvider(PortalType.itd));
/// ```
final credentialForPortalProvider =
    FutureProvider.family<PortalCredential?, PortalType>((ref, portalType) {
      final repo = ref.watch(autosubmitCredentialRepositoryProvider);
      return repo.getCredential(portalType);
    });

// ---------------------------------------------------------------------------
// Job runner
// ---------------------------------------------------------------------------

/// Provides a [SubmissionJobRunner] wired to the orchestrator, credential
/// repository, and OTP service.
final submissionJobRunnerProvider = Provider<SubmissionJobRunner>((ref) {
  return SubmissionJobRunner(
    orchestrator: ref.watch(submissionOrchestratorProvider),
    credentialRepo: ref.watch(autosubmitCredentialRepositoryProvider),
    otpService: ref.watch(otpInterceptServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Live job streams
// ---------------------------------------------------------------------------

/// Emits the full list of [SubmissionJob]s whenever any job is added or
/// updated.  Consumers (e.g. AutosubmitQueueScreen) watch this to get
/// real-time queue state.
final submissionJobsStreamProvider =
    StreamProvider<List<SubmissionJob>>((ref) {
      final repo = ref.watch(submissionRepositoryProvider);
      return repo.watchAll();
    });
