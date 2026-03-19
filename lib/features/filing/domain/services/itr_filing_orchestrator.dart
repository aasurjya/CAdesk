import 'dart:async';

import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/itd_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Orchestrates the full ITR filing flow via the ITD portal.
///
/// Coordinates: export JSON → validate → prompt for portal credentials →
/// open WebView → login → upload → e-verify → download ITR-V → update status.
///
/// Returns a [Stream<SubmissionLog>] for real-time progress UI.
class ItrFilingOrchestrator {
  const ItrFilingOrchestrator({
    required this.autosubmitService,
    required this.otpService,
  });

  final ItdAutosubmitService autosubmitService;
  final OtpInterceptService otpService;

  /// Runs the full portal filing flow.
  ///
  /// Steps:
  /// 1. Login to ITD portal
  /// 2. Upload ITR JSON
  /// 3. e-Verify via Aadhaar OTP
  /// 4. Download ITR-V acknowledgement
  ///
  /// [credential] — ITD portal login credentials
  /// [itrJsonPath] — path to the exported ITR-1 JSON file
  /// [assessmentYear] — e.g. "2026-27"
  /// [clientPan] — PAN of the client
  /// [savePath] — where to save the downloaded ITR-V PDF
  /// [webViewController] — optional; if null, mock streams are used
  Stream<SubmissionLog> fileOnPortal({
    required PortalCredential credential,
    required String itrJsonPath,
    required String assessmentYear,
    required String clientPan,
    required String savePath,
    PortalWebViewController? webViewController,
  }) async* {
    // Step 1: Login
    yield* autosubmitService.login(
      credential: credential,
      otpService: otpService,
      webViewController: webViewController,
    );

    // Step 2: Upload ITR
    yield* autosubmitService.uploadItr(
      clientPan: clientPan,
      itrJsonPath: itrJsonPath,
      assessmentYear: assessmentYear,
      otpService: otpService,
      webViewController: webViewController,
    );

    // Step 3: e-Verify
    yield* autosubmitService.eVerify(
      clientPan: clientPan,
      otpService: otpService,
      webViewController: webViewController,
    );

    // Step 4: Download ITR-V
    yield* autosubmitService.downloadItrV(
      clientPan: clientPan,
      ackNumber: '', // Extracted during upload step
      savePath: savePath,
      webViewController: webViewController,
    );
  }
}
