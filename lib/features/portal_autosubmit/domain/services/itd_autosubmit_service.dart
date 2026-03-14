import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the Income Tax Department (ITD) e-Filing portal.
///
/// All methods return a [Stream<SubmissionLog>] so the UI can display
/// live progress. No actual HTTP calls are made — the network layer is
/// stubbed; a real implementation would inject a WebView / Playwright adapter.
class ItdAutosubmitService {
  const ItdAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://eportal.incometax.gov.in';

  static const String _loginScript = '''
    // ITD Login automation
    document.getElementById('pan-input')?.value = '{pan}';
    document.getElementById('password-input')?.value = '{password}';
    document.querySelector('[data-testid="login-btn"]')?.click();
  ''';

  static const String _itrUploadScript = '''
    // ITR XML upload automation
    const fileInput = document.querySelector('input[type="file"]');
    // Set file via DataTransfer (requires WebView bridge)
    document.querySelector('[data-testid="upload-btn"]')?.click();
  ''';

  static const String _evcVerifyScript = '''
    // EVC / Aadhaar OTP verification
    document.getElementById('otp-input')?.value = '{otp}';
    document.querySelector('[data-testid="verify-btn"]')?.click();
  ''';

  static const String _downloadItrvScript = '''
    // Download ITR-V acknowledgement
    document.querySelector('a[href*="ITR-V"]')?.click();
  ''';

  static const String _download26AsScript = '''
    // Download 26AS / AIS from ITD portal
    document.querySelector('[data-testid="download-26as"]')?.click();
  ''';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Logs in to the ITD portal using [credential].
  ///
  /// Emits step-by-step [SubmissionLog] entries. Triggers the OTP dialog
  /// via [otpService] if the portal requires Aadhaar/mobile OTP after login.
  ///
  /// When [webViewController] is provided, real WebView automation is used.
  /// When `null`, the method falls back to the mock stream for testing/preview.
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
    await webViewController.waitForElement('#pan-input, [name="pan"]');

    yield _log(jobId, SubmissionStep.loggingIn, 'Filling PAN...');
    await webViewController.fillField(
      '#pan-input, [name="pan"]',
      credential.username ?? '',
    );

    yield _log(jobId, SubmissionStep.loggingIn, 'Filling password...');
    await webViewController.fillField(
      '#password-input, [name="password"]',
      credential.encryptedPassword ?? '',
    );

    await webViewController.clickElement(
      'button[type="submit"], [data-testid="login-btn"]',
    );

    yield _log(jobId, SubmissionStep.loggingIn, 'Waiting for OTP...');
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.sms,
      portalHint: 'ITD portal',
    );

    await webViewController.fillField('#otp-input, [name="otp"]', otp);
    await webViewController.clickElement(
      '#verify-otp-btn, [data-testid="verify-btn"]',
    );

    await webViewController.waitForNavigation('/dashboard');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login successful');
  }

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to ITD portal');
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering PAN and password');
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Injecting login script: ${_loginScript.trim().split('\n').first}',
    );
    yield _log(jobId, SubmissionStep.loggingIn, 'Waiting for OTP if required');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  /// Uploads an ITR XML file and initiates e-Verification.
  Stream<SubmissionLog> uploadItr({
    required String clientPan,
    required String itrXmlPath,
    required OtpInterceptService otpService,
  }) async* {
    final jobId = 'itd_upload_$clientPan';
    yield _log(jobId, SubmissionStep.filling, 'Navigating to ITR upload page');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Selecting return type from file: $itrXmlPath',
    );
    yield _log(jobId, SubmissionStep.filling, 'Uploading ITR XML file');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Injecting upload script: ${_itrUploadScript.trim().split('\n').first}',
    );
    yield _log(
      jobId,
      SubmissionStep.otp,
      'Awaiting EVC/Aadhaar OTP for e-Verification '
      '(script: ${_evcVerifyScript.trim().split('\n').first})',
    );
    // Stub: real implementation calls otpService.waitForOtp(channel: OtpChannel.aadhaarOtp, ...)
    yield _log(jobId, SubmissionStep.submitting, 'Submitting ITR');
    yield _log(
      jobId,
      SubmissionStep.done,
      'ITR submitted successfully for PAN: $clientPan',
    );
  }

  /// Downloads the ITR-V acknowledgement PDF.
  Stream<SubmissionLog> downloadItrV({
    required String clientPan,
    required String ackNumber,
    required String savePath,
  }) async* {
    final jobId = 'itd_itrv_$clientPan';
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to ITR-V download page',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Searching for ack: $ackNumber',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Injecting download script: ${_downloadItrvScript.trim().split('\n').first}',
    );
    yield _log(jobId, SubmissionStep.downloading, 'Saving ITR-V to: $savePath');
    yield _log(jobId, SubmissionStep.done, 'ITR-V downloaded successfully');
  }

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
      'Triggering download: $_download26AsScript',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      '26AS / AIS downloaded for FY $financialYear',
    );
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

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
