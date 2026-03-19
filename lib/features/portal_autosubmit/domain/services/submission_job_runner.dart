import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/epfo_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/gstn_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/itd_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/mca_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/traces_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_screen.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

/// Bridges the submission queue with the WebView automation layer.
///
/// Given a [SubmissionJob], resolves the correct portal service and credential,
/// builds an [AutomationRunner] callback, and provides the portal URL for the
/// [PortalWebViewScreen] to navigate to.
///
/// Usage:
/// ```dart
/// final runner = SubmissionJobRunner(
///   orchestrator: orchestrator,
///   credentialRepo: credentialRepo,
///   otpService: otpService,
/// );
/// final result = await runner.prepare(job);
/// // Navigate to PortalWebViewScreen with result.portalUrl and result.runner
/// ```
class SubmissionJobRunner {
  const SubmissionJobRunner({
    required SubmissionOrchestrator orchestrator,
    required PortalCredentialRepository credentialRepo,
    required OtpInterceptService otpService,
  }) : _orchestrator = orchestrator,
       _credentialRepo = credentialRepo,
       _otpService = otpService;

  final SubmissionOrchestrator _orchestrator;
  final PortalCredentialRepository _credentialRepo;
  final OtpInterceptService _otpService;

  // Portal service singletons (stateless, so safe to share)
  static const _itdService = ItdAutosubmitService();
  static const _gstnService = GstnAutosubmitService();
  static const _tracesService = TracesAutosubmitService();
  static const _mcaService = McaAutosubmitService();
  static const _epfoService = EpfoAutosubmitService();

  /// Prepares the automation runner for [job].
  ///
  /// Looks up the stored credential for [job.portalType], validates it exists,
  /// and returns a [PreparedRun] containing the portal URL, an
  /// [AutomationRunner] callback, and a [ConfirmationGate] for the review
  /// pause — all ready to be passed to [PortalWebViewScreen].
  ///
  /// Throws [SubmissionRunnerException] if the credential is missing.
  Future<PreparedRun> prepare(SubmissionJob job) async {
    final credential = await _credentialRepo.getCredential(job.portalType);
    if (credential == null) {
      throw SubmissionRunnerException(
        'No stored credential for ${job.portalType.label}. '
        'Please add portal credentials before filing.',
      );
    }

    final portalUrl = _portalUrlFor(job.portalType);
    final confirmationGate = ConfirmationGate();

    return PreparedRun(
      portalUrl: portalUrl,
      confirmationGate: confirmationGate,
      runner: (PortalWebViewController controller) =>
          _runAutomation(job, credential, controller, confirmationGate),
    );
  }

  /// Executes the full automation sequence for [job].
  ///
  /// Yields [SubmissionLog] entries for each step. Catches errors at the top
  /// level and marks the job as failed via the orchestrator.
  Stream<SubmissionLog> _runAutomation(
    SubmissionJob job,
    PortalCredential credential,
    PortalWebViewController controller,
    ConfirmationGate confirmationGate,
  ) async* {
    try {
      // Clear cookies to isolate this client's session
      await CookieManager.instance().deleteAllCookies();

      // Update orchestrator: job is now running
      await _orchestrator.updateStep(
        job.id,
        SubmissionStep.loggingIn,
        message: 'Starting automation for ${job.clientName}...',
      );

      // Step 1: Login
      yield* _loginFor(job.portalType, credential, controller);

      // Step 2: Portal-specific automation after login
      await _orchestrator.updateStep(
        job.id,
        SubmissionStep.filling,
        message: 'Logged in. Starting ${job.returnType} automation...',
      );

      yield* _fillAndSubmitFor(job, controller, confirmationGate);
    } on Exception catch (e) {
      await _orchestrator.markFailed(job.id, e.toString());
      yield SubmissionLog(
        id: '${job.id}_error_${DateTime.now().microsecondsSinceEpoch}',
        jobId: job.id,
        timestamp: DateTime.now(),
        step: SubmissionStep.failed,
        message: 'Automation failed: $e',
        isError: true,
      );
    }
  }

  /// Dispatches to the correct portal service's fill-and-submit flow.
  ///
  /// Each portal has its own automation sequence after login.
  Stream<SubmissionLog> _fillAndSubmitFor(
    SubmissionJob job,
    PortalWebViewController controller,
    ConfirmationGate confirmationGate,
  ) async* {
    switch (job.portalType) {
      case PortalType.itd:
        yield* _runItdAutomation(job, controller, confirmationGate);

      case PortalType.gstn:
        yield* _runGstnAutomation(job, controller, confirmationGate);

      case PortalType.epfo:
        yield* _runEpfoAutomation(job, controller, confirmationGate);

      case PortalType.traces:
        yield* _runTracesAutomation(job, controller, confirmationGate);

      case PortalType.mca:
        yield* _runMcaAutomation(job, controller, confirmationGate);
    }
  }

  // ---------------------------------------------------------------------------
  // ITD automation
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _runItdAutomation(
    SubmissionJob job,
    PortalWebViewController controller,
    ConfirmationGate confirmationGate,
  ) async* {
    if (job.itrJsonPath != null && job.assessmentYear != null) {
      yield* _itdService.uploadItr(
        clientPan: job.clientId,
        itrJsonPath: job.itrJsonPath!,
        assessmentYear: job.assessmentYear!,
        otpService: _otpService,
        webViewController: controller,
        confirmationGate: confirmationGate,
      );

      await _orchestrator.updateStep(
        job.id,
        SubmissionStep.otp,
        message: 'Starting e-Verification...',
      );
      yield* _itdService.eVerify(
        clientPan: job.clientId,
        otpService: _otpService,
        webViewController: controller,
      );

      await _orchestrator.updateStep(
        job.id,
        SubmissionStep.downloading,
        message: 'Downloading ITR-V acknowledgement...',
      );
      yield* _itdService.downloadItrV(
        clientPan: job.clientId,
        ackNumber: '',
        savePath: '',
        webViewController: controller,
      );

      await _orchestrator.markDone(
        job.id,
        ackNumber: 'pending-extraction',
        filedAt: DateTime.now(),
      );
    } else {
      yield _manualFallbackLog(job);
    }
  }

  // ---------------------------------------------------------------------------
  // GSTN automation
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _runGstnAutomation(
    SubmissionJob job,
    PortalWebViewController controller,
    ConfirmationGate confirmationGate,
  ) async* {
    if (job.itrJsonPath != null) {
      // GSTR-1 upload flow
      yield* _gstnService.uploadGstr1(
        gstin: job.clientId,
        jsonFilePath: job.itrJsonPath!,
        taxPeriod: job.assessmentYear ?? '',
        otpService: _otpService,
        webViewController: controller,
        confirmationGate: confirmationGate,
      );

      await _orchestrator.markDone(
        job.id,
        ackNumber: 'pending-extraction',
        filedAt: DateTime.now(),
      );
    } else {
      yield _manualFallbackLog(job);
    }
  }

  // ---------------------------------------------------------------------------
  // EPFO automation
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _runEpfoAutomation(
    SubmissionJob job,
    PortalWebViewController controller,
    ConfirmationGate confirmationGate,
  ) async* {
    if (job.itrJsonPath != null) {
      // ECR upload flow
      yield* _epfoService.uploadEcr(
        establishmentId: job.clientId,
        ecrFilePath: job.itrJsonPath!,
        wageMonth: job.assessmentYear ?? '',
        otpService: _otpService,
        webViewController: controller,
        confirmationGate: confirmationGate,
      );

      await _orchestrator.markDone(
        job.id,
        ackNumber: 'pending-extraction',
        filedAt: DateTime.now(),
      );
    } else {
      yield _manualFallbackLog(job);
    }
  }

  // ---------------------------------------------------------------------------
  // TRACES automation
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _runTracesAutomation(
    SubmissionJob job,
    PortalWebViewController controller,
    ConfirmationGate confirmationGate,
  ) async* {
    if (job.itrJsonPath != null) {
      // FVU upload flow
      yield* _tracesService.uploadFvu(
        tan: job.clientId,
        fvuFilePath: job.itrJsonPath!,
        formType: job.returnType,
        otpService: _otpService,
        webViewController: controller,
        confirmationGate: confirmationGate,
      );

      await _orchestrator.markDone(
        job.id,
        ackNumber: 'pending-extraction',
        filedAt: DateTime.now(),
      );
    } else {
      yield _manualFallbackLog(job);
    }
  }

  // ---------------------------------------------------------------------------
  // MCA automation
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _runMcaAutomation(
    SubmissionJob job,
    PortalWebViewController controller,
    ConfirmationGate confirmationGate,
  ) async* {
    if (job.itrJsonPath != null) {
      // e-Form upload flow
      yield* _mcaService.uploadEform(
        cin: job.clientId,
        formType: job.returnType,
        formFilePath: job.itrJsonPath!,
        otpService: _otpService,
        webViewController: controller,
        confirmationGate: confirmationGate,
      );

      await _orchestrator.markDone(
        job.id,
        ackNumber: 'pending-extraction',
        filedAt: DateTime.now(),
      );
    } else {
      yield _manualFallbackLog(job);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  SubmissionLog _manualFallbackLog(SubmissionJob job) {
    return SubmissionLog(
      id: '${job.id}_fill_${DateTime.now().microsecondsSinceEpoch}',
      jobId: job.id,
      timestamp: DateTime.now(),
      step: SubmissionStep.filling,
      message:
          'Login successful. No file path set — continue manually in the portal.',
    );
  }

  /// Dispatches to the correct portal service's login method.
  Stream<SubmissionLog> _loginFor(
    PortalType portalType,
    PortalCredential credential,
    PortalWebViewController controller,
  ) {
    switch (portalType) {
      case PortalType.itd:
        return _itdService.login(
          credential: credential,
          otpService: _otpService,
          webViewController: controller,
        );
      case PortalType.gstn:
        return _gstnService.login(
          credential: credential,
          otpService: _otpService,
          webViewController: controller,
        );
      case PortalType.traces:
        return _tracesService.login(
          credential: credential,
          otpService: _otpService,
          webViewController: controller,
        );
      case PortalType.mca:
        return _mcaService.login(
          credential: credential,
          otpService: _otpService,
          webViewController: controller,
        );
      case PortalType.epfo:
        return _epfoService.login(
          credential: credential,
          otpService: _otpService,
          webViewController: controller,
        );
    }
  }

  /// Returns the base URL for the given portal.
  static String _portalUrlFor(PortalType portalType) {
    switch (portalType) {
      case PortalType.itd:
        return ItdAutosubmitService.portalUrl;
      case PortalType.gstn:
        return GstnAutosubmitService.portalUrl;
      case PortalType.traces:
        return TracesAutosubmitService.portalUrl;
      case PortalType.mca:
        return McaAutosubmitService.portalUrl;
      case PortalType.epfo:
        return EpfoAutosubmitService.portalUrl;
    }
  }
}

/// Result of [SubmissionJobRunner.prepare].
///
/// Contains the portal URL to navigate to and the [AutomationRunner] callback
/// for [PortalWebViewScreen].
class PreparedRun {
  const PreparedRun({
    required this.portalUrl,
    required this.runner,
    required this.confirmationGate,
  });

  /// Base URL of the target government portal.
  final String portalUrl;

  /// Callback for [PortalWebViewScreen] that runs the automation sequence.
  final AutomationRunner runner;

  /// Gate for the review pause. Pass this to [PortalWebViewScreen] so its
  /// "Confirm & Submit" button can resume the automation.
  final ConfirmationGate confirmationGate;
}

/// Thrown when [SubmissionJobRunner] cannot prepare a run.
class SubmissionRunnerException implements Exception {
  const SubmissionRunnerException(this.message);

  final String message;

  @override
  String toString() => 'SubmissionRunnerException: $message';
}
