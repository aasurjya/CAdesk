import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/webview/js/portal_js_scripts.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/data/services/credential_encryption_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the TRACES portal (TDS Reconciliation Analysis
/// and Correction Enabling System).
///
/// All methods return a [Stream<SubmissionLog>] so the UI can display
/// live progress. When [PortalWebViewController] is provided, real WebView
/// automation is used; otherwise falls back to mock streams.
class TracesAutosubmitService {
  const TracesAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://www.tdscpc.gov.in';

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Logs in to TRACES using TAN and password.
  ///
  /// When [webViewController] is provided, real WebView automation is used.
  /// TRACES requires CAPTCHA on login — automation pauses so the user can
  /// solve it manually in the visible WebView, then resumes.
  Stream<SubmissionLog> login({
    required PortalCredential credential,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'traces_login_${credential.id}';

    if (webViewController == null) {
      yield* _mockLoginStream(jobId);
      return;
    }

    // --- Real WebView automation ---
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Navigating to TRACES portal...',
    );

    yield _log(jobId, SubmissionStep.loggingIn, 'Waiting for login form...');
    await webViewController.waitForElement(
      PortalJsScripts.tracesUserIdSelector,
    );

    // Check for CAPTCHA and pause if present
    final hasCaptcha = await _detectCaptcha(webViewController);
    if (hasCaptcha) {
      yield _log(
        jobId,
        SubmissionStep.loggingIn,
        'CAPTCHA detected — please solve it manually, then automation '
        'will resume.',
      );
      await webViewController.waitForElementDisappearance(
        PortalJsScripts.tracesCaptchaSelector,
      );
      yield _log(
        jobId,
        SubmissionStep.loggingIn,
        'CAPTCHA solved — resuming automation.',
      );
    }

    // Fill TAN
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering TAN...');
    await webViewController.fillField(
      PortalJsScripts.tracesUserIdSelector,
      credential.username ?? '',
    );

    // Fill password (decrypt from OS keychain)
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering password...');
    final plainPassword = credential.encryptedPassword != null
        ? await CredentialEncryptionService.decrypt(
            credential.encryptedPassword!,
          )
        : '';
    await webViewController.fillField(
      PortalJsScripts.tracesPasswordSelector,
      plainPassword,
    );

    // Click login
    yield _log(jobId, SubmissionStep.loggingIn, 'Submitting login...');
    await webViewController.clickElement(
      PortalJsScripts.tracesLoginBtnSelector,
    );

    // Wait for dashboard
    await webViewController.waitForNavigation('/taxpayer/home');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  // ---------------------------------------------------------------------------
  // FVU Upload
  // ---------------------------------------------------------------------------

  /// Uploads an FVU file for the specified [formType] (e.g. '26Q', '24Q').
  ///
  /// When [webViewController] is provided, real WebView automation navigates
  /// to the FVU upload section, selects the form type, uploads the file,
  /// and submits. FVU upload may also trigger CAPTCHA detection.
  ///
  /// If [confirmationGate] is provided, automation pauses after the portal
  /// validates the uploaded file — giving the CA time to review before
  /// final submission.
  Stream<SubmissionLog> uploadFvu({
    required String tan,
    required String fvuFilePath,
    required String formType,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
    ConfirmationGate? confirmationGate,
  }) async* {
    final jobId = 'traces_fvu_$tan';

    if (webViewController == null) {
      yield* _mockUploadFvuStream(jobId, tan, fvuFilePath, formType);
      return;
    }

    // Navigate to FVU upload section
    yield _log(jobId, SubmissionStep.filling, 'Navigating to FVU upload...');
    await webViewController.clickElement(
      PortalJsScripts.tracesFvuUploadNavSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Check for CAPTCHA on the upload page
    final hasCaptcha = await _detectCaptcha(webViewController);
    if (hasCaptcha) {
      yield _log(
        jobId,
        SubmissionStep.filling,
        'CAPTCHA detected on upload page — please solve it manually.',
      );
      await webViewController.waitForElementDisappearance(
        PortalJsScripts.tracesCaptchaSelector,
      );
      yield _log(
        jobId,
        SubmissionStep.filling,
        'CAPTCHA solved — resuming upload.',
      );
    }

    // Select form type (24Q / 26Q / 27Q / 27EQ)
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Selecting form type: $formType...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.tracesFvuFormTypeSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.tracesFvuFormTypeSelector,
      formType,
    );

    // Upload FVU file — handled via onShowFileChooser callback
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading FVU file: $fvuFilePath',
    );
    await webViewController.waitForElement(
      PortalJsScripts.tracesFvuFileInputSelector,
    );
    await webViewController.clickElement(
      PortalJsScripts.tracesFvuFileInputSelector,
    );

    // Wait for portal validation
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Waiting for portal validation...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.tracesFvuSuccessSelector,
      timeout: const Duration(seconds: 60),
    );

    // --- REVIEW GATE ---
    if (confirmationGate != null) {
      yield _log(
        jobId,
        SubmissionStep.reviewing,
        'FVU validated. Please review the data on screen, '
        'then tap "Confirm & Submit" to proceed.',
      );
      await confirmationGate.waitForConfirmation();
      yield _log(
        jobId,
        SubmissionStep.submitting,
        'Confirmed by user. Submitting FVU...',
      );
    }

    // Submit
    yield _log(jobId, SubmissionStep.submitting, 'Submitting FVU to TRACES...');
    await webViewController.clickElement(
      PortalJsScripts.tracesFvuSubmitSelector,
    );

    // Extract token number
    yield _log(jobId, SubmissionStep.submitting, 'Extracting token number...');
    const tokenScript =
        '''
(function() {
  var el = document.querySelector('${PortalJsScripts.tracesFvuTokenSelector}');
  return el ? el.textContent.trim() : '';
})()
''';
    final tokenNumber = await webViewController.evalJs(tokenScript);
    yield _log(
      jobId,
      SubmissionStep.done,
      '$formType FVU submitted for TAN: $tan. '
      'Token: ${tokenNumber ?? 'N/A'}',
    );
  }

  // ---------------------------------------------------------------------------
  // Challan Verification
  // ---------------------------------------------------------------------------

  /// Verifies challan status using BSR code, date, and serial number.
  ///
  /// When [webViewController] is provided, real WebView automation navigates
  /// to the challan verification page, fills in the details, and extracts
  /// the verification status.
  Stream<SubmissionLog> verifyChallan({
    required String tan,
    required String bsrCode,
    required String challanDate,
    required String serialNumber,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'traces_challan_$tan';

    if (webViewController == null) {
      yield* _mockVerifyChallanStream(
        jobId,
        tan,
        bsrCode,
        challanDate,
        serialNumber,
      );
      return;
    }

    // Navigate to challan verification
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to challan verification...',
    );
    await webViewController.clickElement(
      PortalJsScripts.tracesChallanNavSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Fill BSR code
    yield _log(jobId, SubmissionStep.filling, 'Entering BSR code: $bsrCode...');
    await webViewController.waitForElement(
      PortalJsScripts.tracesChallanBsrSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.tracesChallanBsrSelector,
      bsrCode,
    );

    // Fill challan date
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Entering challan date: $challanDate...',
    );
    await webViewController.fillField(
      PortalJsScripts.tracesChallanDateSelector,
      challanDate,
    );

    // Fill serial number
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Entering serial number: $serialNumber...',
    );
    await webViewController.fillField(
      PortalJsScripts.tracesChallanSerialSelector,
      serialNumber,
    );

    // Click verify
    yield _log(jobId, SubmissionStep.submitting, 'Verifying challan...');
    await webViewController.clickElement(
      PortalJsScripts.tracesChallanVerifyBtnSelector,
    );

    // Extract challan status
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Extracting verification status...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.tracesChallanStatusSelector,
      timeout: const Duration(seconds: 30),
    );

    const statusScript =
        '''
(function() {
  var el = document.querySelector('${PortalJsScripts.tracesChallanStatusSelector}');
  return el ? el.textContent.trim() : 'Unknown';
})()
''';
    final status = await webViewController.evalJs(statusScript);
    yield _log(
      jobId,
      SubmissionStep.done,
      'Challan verification completed for TAN: $tan. '
      'Status: ${status ?? 'Unknown'}',
    );
  }

  // ---------------------------------------------------------------------------
  // Form 16 Download
  // ---------------------------------------------------------------------------

  /// Downloads Form 16 / 16A in bulk for [tan] for [financialYear].
  ///
  /// When [webViewController] is provided, real WebView automation navigates
  /// to the Form 16 section, selects the financial year, and triggers the
  /// bulk download.
  Stream<SubmissionLog> downloadForm16({
    required String tan,
    required String financialYear,
    required String savePath,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'traces_form16_$tan';

    if (webViewController == null) {
      yield* _mockDownloadForm16Stream(jobId, tan, financialYear, savePath);
      return;
    }

    // Navigate to Form 16 download section
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to Form 16 download...',
    );
    await webViewController.clickElement(
      PortalJsScripts.tracesForm16NavSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Select financial year
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Selecting FY $financialYear...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.tracesForm16FySelector,
    );
    await webViewController.fillField(
      PortalJsScripts.tracesForm16FySelector,
      financialYear,
    );

    // Trigger bulk download
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Triggering bulk download...',
    );
    await webViewController.clickElement(
      PortalJsScripts.tracesForm16DownloadBtnSelector,
    );

    // Wait for download to be ready
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Waiting for download to complete...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.tracesForm16ReadySelector,
      timeout: const Duration(seconds: 60),
    );

    // File download is handled by WebView's onDownloadStartRequest callback
    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      'Form 16 downloaded for TAN: $tan, FY: $financialYear',
    );
  }

  // ---------------------------------------------------------------------------
  // Justification Report Download
  // ---------------------------------------------------------------------------

  /// Downloads the justification report for a filed TDS return.
  ///
  /// When [webViewController] is provided, real WebView automation navigates
  /// to the JR section, enters the token number, and triggers the download.
  Stream<SubmissionLog> downloadJustificationReport({
    required String tan,
    required String tokenNumber,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'traces_jr_$tan';

    if (webViewController == null) {
      yield* _mockDownloadJrStream(jobId, tan, tokenNumber);
      return;
    }

    // Navigate to justification report section
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to justification report...',
    );
    await webViewController.clickElement(PortalJsScripts.tracesJrNavSelector);
    await Future<void>.delayed(const Duration(seconds: 2));

    // Enter token number
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Entering token number: $tokenNumber...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.tracesJrTokenInputSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.tracesJrTokenInputSelector,
      tokenNumber,
    );

    // Click download
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Downloading justification report...',
    );
    await webViewController.clickElement(
      PortalJsScripts.tracesJrDownloadBtnSelector,
    );

    // Wait for download to be ready
    await webViewController.waitForElement(
      PortalJsScripts.tracesJrReadySelector,
      timeout: const Duration(seconds: 60),
    );

    yield _log(
      jobId,
      SubmissionStep.done,
      'Justification report downloaded for token: $tokenNumber',
    );
  }

  // ---------------------------------------------------------------------------
  // Mock streams (used when WebView controller is null / for testing)
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to TRACES portal');
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering TAN and password');
    yield _log(jobId, SubmissionStep.loggingIn, 'Resolving CAPTCHA (OCR)');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockUploadFvuStream(
    String jobId,
    String tan,
    String fvuFilePath,
    String formType,
  ) async* {
    yield _log(jobId, SubmissionStep.filling, 'Navigating to FVU upload page');
    yield _log(jobId, SubmissionStep.filling, 'Selecting form type: $formType');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading FVU file: $fvuFilePath',
    );
    yield _log(jobId, SubmissionStep.submitting, 'Submitting FVU to TRACES');
    yield _log(
      jobId,
      SubmissionStep.done,
      '$formType FVU submitted for TAN: $tan',
    );
  }

  Stream<SubmissionLog> _mockVerifyChallanStream(
    String jobId,
    String tan,
    String bsrCode,
    String challanDate,
    String serialNumber,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to challan verification',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Entering BSR: $bsrCode, date: $challanDate, serial: $serialNumber',
    );
    yield _log(jobId, SubmissionStep.submitting, 'Verifying challan');
    yield _log(
      jobId,
      SubmissionStep.done,
      'Challan verification completed for TAN: $tan',
    );
  }

  Stream<SubmissionLog> _mockDownloadForm16Stream(
    String jobId,
    String tan,
    String financialYear,
    String savePath,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to Form 16 download section',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Selecting FY $financialYear',
    );
    yield _log(jobId, SubmissionStep.downloading, 'Triggering bulk download');
    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      'Form 16 downloaded for TAN: $tan, FY: $financialYear',
    );
  }

  Stream<SubmissionLog> _mockDownloadJrStream(
    String jobId,
    String tan,
    String tokenNumber,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to justification report',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Entering token number: $tokenNumber',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Downloading justification report',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'Justification report downloaded for token: $tokenNumber',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Detects whether CAPTCHA is visible on the current TRACES page.
  Future<bool> _detectCaptcha(PortalWebViewController ctrl) async {
    try {
      final result = await ctrl.evalJs(
        PortalJsScripts.tracesCaptchaDetectScript,
      );
      return result == 'true' || result == true;
    } catch (_) {
      return false;
    }
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
