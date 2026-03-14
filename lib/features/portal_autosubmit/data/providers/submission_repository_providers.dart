import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/portal_autosubmit/data/repositories/mock_submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/repositories/submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/epfo_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/gstn_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/itd_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/mca_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/traces_autosubmit_service.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';

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
