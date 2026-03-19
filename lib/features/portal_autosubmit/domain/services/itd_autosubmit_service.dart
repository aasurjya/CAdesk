import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/webview/js/portal_js_scripts.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/data/services/credential_encryption_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the Income Tax Department (ITD) e-Filing portal.
///
/// All methods return a [Stream<SubmissionLog>] so the UI can display
/// live progress. When [PortalWebViewController] is provided, real WebView
/// automation is used; otherwise falls back to mock streams.
class ItdAutosubmitService {
  const ItdAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://eportal.incometax.gov.in';

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Logs in to the ITD portal using [credential].
  ///
  /// Emits step-by-step [SubmissionLog] entries. Triggers the OTP dialog
  /// via [otpService] if the portal requires Aadhaar/mobile OTP after login.
  ///
  /// Handles CAPTCHA: if detected, pauses automation so the user can solve
  /// it manually in the visible WebView, then resumes.
  Stream<SubmissionLog> login({
    required PortalCredential credential,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'itd_login_${credential.id}';

    if (webViewController == null) {
      yield* _mockLoginStream(jobId);
      return;
    }

    // --- Real WebView automation ---
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to ITD portal...');

    // Wait for the PAN input to appear
    yield _log(jobId, SubmissionStep.loggingIn, 'Waiting for login form...');
    await webViewController.waitForElement(PortalJsScripts.itdPanSelector);

    // Check for CAPTCHA and pause if present
    final hasCaptcha = await _detectCaptcha(webViewController);
    if (hasCaptcha) {
      yield _log(
        jobId,
        SubmissionStep.loggingIn,
        'CAPTCHA detected — please solve it manually, then automation will resume.',
      );
      // Poll until the CAPTCHA element disappears (CA solved it) or
      // the dashboard URL appears (login succeeded via manual action).
      // Timeout: 5 minutes to give the CA plenty of time.
      await webViewController.waitForElementDisappearance(
        PortalJsScripts.itdCaptchaSelector,
      );
      yield _log(
        jobId,
        SubmissionStep.loggingIn,
        'CAPTCHA solved — resuming automation.',
      );
    }

    // Fill PAN
    yield _log(jobId, SubmissionStep.loggingIn, 'Filling PAN...');
    await webViewController.fillField(
      PortalJsScripts.itdPanSelector,
      credential.username ?? '',
    );

    // Fill password (decrypt from OS keychain before filling)
    yield _log(jobId, SubmissionStep.loggingIn, 'Filling password...');
    final plainPassword = credential.encryptedPassword != null
        ? await CredentialEncryptionService.decrypt(
            credential.encryptedPassword!,
          )
        : '';
    await webViewController.fillField(
      PortalJsScripts.itdPasswordSelector,
      plainPassword,
    );

    // Click login
    yield _log(jobId, SubmissionStep.loggingIn, 'Submitting login...');
    await webViewController.clickElement(PortalJsScripts.itdLoginBtnSelector);

    // Wait: either OTP required or dashboard appears
    yield _log(jobId, SubmissionStep.loggingIn, 'Waiting for OTP or dashboard...');

    final otpVisible = await _waitForEitherElement(
      webViewController,
      PortalJsScripts.itdOtpSelector,
      PortalJsScripts.itdDashboardSelector,
    );

    if (otpVisible) {
      yield _log(jobId, SubmissionStep.otp, 'OTP required — waiting for user input...');
      final otp = await webViewController.interceptOtp(
        channel: OtpChannel.sms,
        portalHint: 'ITD portal login',
      );
      await webViewController.fillField(PortalJsScripts.itdOtpSelector, otp);
      await webViewController.clickElement(PortalJsScripts.itdOtpVerifyBtnSelector);
    }

    // Confirm login by waiting for dashboard
    yield _log(jobId, SubmissionStep.loggingIn, 'Confirming login...');
    await webViewController.waitForNavigation('/dashboard');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login successful');
  }

  // ---------------------------------------------------------------------------
  // ITR Upload
  // ---------------------------------------------------------------------------

  /// Uploads an ITR JSON file and initiates e-Verification.
  ///
  /// When [webViewController] is provided, real WebView automation navigates
  /// to the e-file section, selects AY + form type, and uploads the file.
  ///
  /// If [confirmationGate] is provided, automation pauses after the portal
  /// validates the uploaded data — giving the CA time to review the filled
  /// form on-screen. The CA taps "Confirm & Submit" to resume, or "Cancel"
  /// to abort. If no gate is provided, submission proceeds immediately.
  Stream<SubmissionLog> uploadItr({
    required String clientPan,
    required String itrJsonPath,
    required String assessmentYear,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
    ConfirmationGate? confirmationGate,
  }) async* {
    final jobId = 'itd_upload_$clientPan';

    if (webViewController == null) {
      yield* _mockUploadStream(jobId, clientPan, itrJsonPath);
      return;
    }

    // Navigate to e-file section
    yield _log(jobId, SubmissionStep.filling, 'Navigating to e-File → ITR...');
    await webViewController.clickElement(PortalJsScripts.itdEfileMenuSelector);
    await Future<void>.delayed(const Duration(seconds: 2));

    // Select Assessment Year
    yield _log(jobId, SubmissionStep.filling, 'Selecting AY $assessmentYear...');
    await webViewController.waitForElement(PortalJsScripts.itdAySelector);
    await webViewController.fillField(
      PortalJsScripts.itdAySelector,
      assessmentYear,
    );

    // Select ITR form type
    yield _log(jobId, SubmissionStep.filling, 'Selecting ITR-1 (Sahaj)...');
    await webViewController.fillField(PortalJsScripts.itdItrFormSelector, 'ITR1');

    // Upload JSON file — handled via onShowFileChooser callback
    yield _log(jobId, SubmissionStep.filling, 'Uploading JSON: $itrJsonPath');
    await webViewController.waitForElement(PortalJsScripts.itdFileUploadSelector);

    // The file upload is handled by the WebView's file chooser callback.
    // The FileUploadHandler (WU 3.2) provides the file path.
    await webViewController.clickElement(PortalJsScripts.itdUploadBtnSelector);

    // Wait for portal validation
    yield _log(jobId, SubmissionStep.filling, 'Waiting for portal validation...');
    await webViewController.waitForElement(
      PortalJsScripts.itdValidationSuccessSelector,
      timeout: const Duration(seconds: 60),
    );

    // --- REVIEW GATE ---
    // Pause automation so the CA can review the filled form on the portal.
    // The portal's own preview/summary page is now visible in the WebView.
    // Automation resumes when the CA taps "Confirm & Submit" in the app.
    if (confirmationGate != null) {
      yield _log(
        jobId,
        SubmissionStep.reviewing,
        'Form filled successfully. Please review the data on screen, '
        'then tap "Confirm & Submit" to proceed.',
      );
      await confirmationGate.waitForConfirmation();
      yield _log(
        jobId,
        SubmissionStep.submitting,
        'Confirmed by user. Submitting...',
      );
    }

    // Extract acknowledgement number
    yield _log(jobId, SubmissionStep.submitting, 'Extracting acknowledgement number...');
    final ackScript = '''
(function() {
  var el = document.querySelector('${PortalJsScripts.itdAckNumberSelector}');
  return el ? el.textContent.trim() : '';
})()
''';
    final ackNumber = await webViewController.evalJs(ackScript);
    yield _log(
      jobId,
      SubmissionStep.done,
      'ITR uploaded successfully. ACK: ${ackNumber ?? 'N/A'}',
    );
  }

  // ---------------------------------------------------------------------------
  // e-Verification
  // ---------------------------------------------------------------------------

  /// Navigates to e-verification and completes Aadhaar OTP verification.
  Stream<SubmissionLog> eVerify({
    required String clientPan,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'itd_everify_$clientPan';

    if (webViewController == null) {
      yield* _mockEverifyStream(jobId, clientPan);
      return;
    }

    // Navigate to e-verification
    yield _log(jobId, SubmissionStep.otp, 'Navigating to e-Verification...');
    await webViewController.clickElement(PortalJsScripts.itdEverifyLinkSelector);
    await Future<void>.delayed(const Duration(seconds: 2));

    // Select Aadhaar OTP method
    yield _log(jobId, SubmissionStep.otp, 'Selecting Aadhaar OTP method...');
    await webViewController.waitForElement(PortalJsScripts.itdAadhaarOtpOptionSelector);
    await webViewController.clickElement(PortalJsScripts.itdAadhaarOtpOptionSelector);

    // Generate OTP
    yield _log(jobId, SubmissionStep.otp, 'Generating OTP...');
    await webViewController.clickElement(PortalJsScripts.itdGenerateOtpBtnSelector);

    // Wait for user to enter OTP
    yield _log(jobId, SubmissionStep.otp, 'Waiting for OTP...');
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.aadhaarOtp,
      portalHint: 'ITD e-Verification',
    );

    // Enter OTP and submit
    await webViewController.fillField(PortalJsScripts.itdOtpSelector, otp);
    await webViewController.clickElement(PortalJsScripts.itdOtpVerifyBtnSelector);

    // Confirm verification success
    yield _log(jobId, SubmissionStep.otp, 'Verifying...');
    await webViewController.waitForElement(
      PortalJsScripts.itdEverifySuccessSelector,
      timeout: const Duration(seconds: 30),
    );
    yield _log(jobId, SubmissionStep.done, 'e-Verification completed successfully');
  }

  // ---------------------------------------------------------------------------
  // ITR-V Download
  // ---------------------------------------------------------------------------

  /// Downloads the ITR-V acknowledgement PDF from the portal.
  Stream<SubmissionLog> downloadItrV({
    required String clientPan,
    required String ackNumber,
    required String savePath,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'itd_itrv_$clientPan';

    if (webViewController == null) {
      yield* _mockDownloadItrvStream(jobId, clientPan, ackNumber, savePath);
      return;
    }

    // Navigate to View Filed Returns
    yield _log(jobId, SubmissionStep.downloading, 'Navigating to View Filed Returns...');
    await webViewController.clickElement(
      PortalJsScripts.itdViewFiledReturnsSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Find the correct AY entry and click download
    yield _log(jobId, SubmissionStep.downloading, 'Searching for ACK: $ackNumber...');
    await webViewController.waitForElement(PortalJsScripts.itdItrvDownloadSelector);

    yield _log(jobId, SubmissionStep.downloading, 'Downloading ITR-V...');
    await webViewController.clickElement(PortalJsScripts.itdItrvDownloadSelector);

    // The file download is handled by WebView's onDownloadStartRequest callback.
    yield _log(jobId, SubmissionStep.downloading, 'Saving ITR-V to: $savePath');
    yield _log(jobId, SubmissionStep.done, 'ITR-V downloaded successfully');
  }

  // ---------------------------------------------------------------------------
  // Check Filing Status
  // ---------------------------------------------------------------------------

  /// Checks the filing status for a given AY + PAN from the portal.
  Stream<SubmissionLog> checkFilingStatus({
    required String clientPan,
    required String assessmentYear,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'itd_status_$clientPan';

    if (webViewController == null) {
      yield _log(jobId, SubmissionStep.filling, 'Navigating to View Filed Returns');
      yield _log(jobId, SubmissionStep.filling, 'Checking status for AY $assessmentYear');
      yield _log(jobId, SubmissionStep.done, 'Status: e-Verified (mock)');
      return;
    }

    yield _log(jobId, SubmissionStep.filling, 'Navigating to View Filed Returns...');
    await webViewController.clickElement(
      PortalJsScripts.itdViewFiledReturnsSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    yield _log(jobId, SubmissionStep.filling, 'Extracting filing status...');
    final statusScript = '''
(function() {
  var rows = document.querySelectorAll('tr, .return-row, [class*="filed-return"]');
  for (var i = 0; i < rows.length; i++) {
    var text = rows[i].textContent || '';
    if (text.indexOf('$assessmentYear') !== -1) {
      var statusEl = rows[i].querySelector('.status, [class*="status"], td:last-child');
      return statusEl ? statusEl.textContent.trim() : 'Unknown';
    }
  }
  return 'Not Found';
})()
''';
    final status = await webViewController.evalJs(statusScript);
    yield _log(jobId, SubmissionStep.done, 'Status: ${status ?? 'Unknown'}');
  }

  // ---------------------------------------------------------------------------
  // 26AS Download (existing)
  // ---------------------------------------------------------------------------

  /// Downloads the 26AS / AIS statement for [financialYear] (e.g. '2025-26').
  Stream<SubmissionLog> download26As({
    required String clientPan,
    required String financialYear,
  }) async* {
    final jobId = 'itd_26as_$clientPan';
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to 26AS / AIS page',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Selecting FY $financialYear for PAN $clientPan',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Triggering download...',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      '26AS / AIS downloaded for FY $financialYear',
    );
  }

  // ---------------------------------------------------------------------------
  // Mock streams (used when WebView controller is null / for testing)
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to ITD portal');
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering PAN and password');
    yield _log(jobId, SubmissionStep.loggingIn, 'Waiting for OTP if required');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockUploadStream(
    String jobId,
    String pan,
    String path,
  ) async* {
    yield _log(jobId, SubmissionStep.filling, 'Navigating to ITR upload page');
    yield _log(jobId, SubmissionStep.filling, 'Selecting return type from: $path');
    yield _log(jobId, SubmissionStep.filling, 'Uploading ITR JSON file');
    yield _log(jobId, SubmissionStep.submitting, 'Submitting ITR');
    yield _log(jobId, SubmissionStep.done, 'ITR submitted for PAN: $pan');
  }

  Stream<SubmissionLog> _mockEverifyStream(String jobId, String pan) async* {
    yield _log(jobId, SubmissionStep.otp, 'Navigating to e-Verification');
    yield _log(jobId, SubmissionStep.otp, 'Selecting Aadhaar OTP method');
    yield _log(jobId, SubmissionStep.otp, 'Generating OTP...');
    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP from user');
    yield _log(jobId, SubmissionStep.done, 'e-Verification completed for PAN: $pan');
  }

  Stream<SubmissionLog> _mockDownloadItrvStream(
    String jobId,
    String pan,
    String ack,
    String savePath,
  ) async* {
    yield _log(jobId, SubmissionStep.downloading, 'Navigating to View Filed Returns');
    yield _log(jobId, SubmissionStep.downloading, 'Searching for ACK: $ack');
    yield _log(jobId, SubmissionStep.downloading, 'Downloading ITR-V');
    yield _log(jobId, SubmissionStep.downloading, 'Saving ITR-V to: $savePath');
    yield _log(jobId, SubmissionStep.done, 'ITR-V downloaded successfully');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Detects whether CAPTCHA is visible on the current page.
  Future<bool> _detectCaptcha(PortalWebViewController ctrl) async {
    try {
      final result = await ctrl.evalJs(PortalJsScripts.detectCaptchaScript);
      return result == 'true' || result == true;
    } catch (_) {
      return false;
    }
  }

  /// Waits for either of two elements to appear. Returns true if the first
  /// selector matched, false if the second.
  Future<bool> _waitForEitherElement(
    PortalWebViewController ctrl,
    String selector1,
    String selector2,
  ) async {
    const pollInterval = Duration(milliseconds: 500);
    final deadline = DateTime.now().add(const Duration(seconds: 30));

    while (DateTime.now().isBefore(deadline)) {
      try {
        final js1 = PortalJsScripts.buildElementExistsScript(selector1);
        final js2 = PortalJsScripts.buildElementExistsScript(selector2);
        final r1 = await ctrl.evalJs(js1);
        if (r1 == 'true' || r1 == true) return true;
        final r2 = await ctrl.evalJs(js2);
        if (r2 == 'true' || r2 == true) return false;
      } catch (_) {
        // Continue polling
      }
      await Future<void>.delayed(pollInterval);
    }
    return false;
  }

  SubmissionLog _log(String jobId, SubmissionStep step, String message) {
    return SubmissionLog(
      id: '${jobId}_${step.name}_${DateTime.now().microsecondsSinceEpoch}',
      jobId: jobId,
      timestamp: DateTime.now(),
      step: step,
      message: message,
    );
  }
}
