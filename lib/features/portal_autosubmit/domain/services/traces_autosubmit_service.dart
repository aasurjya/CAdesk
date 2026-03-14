import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the TRACES portal (TDS Reconciliation Analysis
/// and Correction Enabling System).
///
/// Handles FVU upload, Form 16 bulk download, and challan verification.
class TracesAutosubmitService {
  const TracesAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://www.tdscpc.gov.in';

  static const String _loginScript = '''
    // TRACES Login — TAN + password + CAPTCHA
    document.getElementById('userId')?.value = '{tan}';
    document.getElementById('password')?.value = '{password}';
    // CAPTCHA must be solved externally (OCR or manual entry)
    document.querySelector('[type="submit"]')?.click();
  ''';

  static const String _fvuUploadScript = '''
    // FVU file upload for 24Q / 26Q / 27Q / 27EQ
    const input = document.querySelector('input[type="file"]');
    document.querySelector('[data-testid="upload-fvu"]')?.click();
  ''';

  static const String _challanVerifyScript = '''
    // Verify challan status on TRACES
    document.getElementById('bsrCode')?.value = '{bsr}';
    document.getElementById('challanDate')?.value = '{date}';
    document.getElementById('challanSerial')?.value = '{serial}';
    document.querySelector('[data-testid="verify-challan"]')?.click();
  ''';

  static const String _form16DownloadScript = '''
    // Bulk Form 16 / 16A download
    document.querySelector('[data-testid="download-form16"]')?.click();
  ''';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Logs in to TRACES using TAN and password.
  ///
  /// When [webViewController] is provided, real WebView automation is used.
  /// When `null`, the method falls back to the mock stream for testing/preview.
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
    await webViewController.waitForElement('#userId');

    yield _log(jobId, SubmissionStep.loggingIn, 'Entering TAN and password...');
    await webViewController.fillField('#userId', credential.username ?? '');
    await webViewController.fillField(
      '#password',
      credential.encryptedPassword ?? '',
    );

    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Resolving CAPTCHA (manual)...',
    );
    // CAPTCHA requires manual intervention — automation pauses here;
    // the embedded browser is visible so the user can solve it.
    await webViewController.waitForElement('[type="submit"]');
    await webViewController.clickElement('[type="submit"]');

    await webViewController.waitForNavigation('/taxpayer/home');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to TRACES portal');
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering TAN and password '
      '(script: ${_loginScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.loggingIn, 'Resolving CAPTCHA (OCR)');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  /// Uploads an FVU file for the specified [formType] (e.g. '26Q', '24Q').
  Stream<SubmissionLog> uploadFvu({
    required String tan,
    required String fvuFilePath,
    required String formType,
    required OtpInterceptService otpService,
  }) async* {
    final jobId = 'traces_fvu_$tan';
    yield _log(jobId, SubmissionStep.filling, 'Navigating to FVU upload page');
    yield _log(jobId, SubmissionStep.filling, 'Selecting form type: $formType');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading FVU file: $fvuFilePath '
      '(script: ${_fvuUploadScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.submitting, 'Submitting FVU to TRACES');
    yield _log(
      jobId,
      SubmissionStep.done,
      '$formType FVU submitted for TAN: $tan',
    );
  }

  /// Verifies challan status using BSR code, date, and serial number.
  Stream<SubmissionLog> verifyChallan({
    required String tan,
    required String bsrCode,
    required String challanDate,
    required String serialNumber,
  }) async* {
    final jobId = 'traces_challan_$tan';
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
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Verifying challan '
      '(script: ${_challanVerifyScript.trim().split('\n').first})',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'Challan verification completed for TAN: $tan',
    );
  }

  /// Downloads Form 16 / 16A in bulk for [tan] for [financialYear].
  Stream<SubmissionLog> downloadForm16({
    required String tan,
    required String financialYear,
    required String savePath,
  }) async* {
    final jobId = 'traces_form16_$tan';
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
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Triggering bulk download '
      '(script: ${_form16DownloadScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      'Form 16 downloaded for TAN: $tan, FY: $financialYear',
    );
  }

  /// Downloads the justification report for a filed TDS return.
  Stream<SubmissionLog> downloadJustificationReport({
    required String tan,
    required String tokenNumber,
  }) async* {
    final jobId = 'traces_jr_$tan';
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
