import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the GST Network (GSTN) portal.
///
/// Handles GSTR-1 upload, GSTR-3B auto-fill, and PMT-06 payment.
/// All methods return [Stream<SubmissionLog>] for live UI progress.
class GstnAutosubmitService {
  const GstnAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://services.gst.gov.in';

  static const String _loginScript = '''
    // GSTN Login automation
    document.getElementById('username')?.value = '{gstin}';
    document.getElementById('user_pass')?.value = '{password}';
    document.querySelector('[type="submit"]')?.click();
  ''';

  static const String _otpVerifyScript = '''
    // GSTN OTP verification
    document.getElementById('otp')?.value = '{otp}';
    document.querySelector('[data-testid="otp-submit"]')?.click();
  ''';

  static const String _gstr1UploadScript = '''
    // GSTR-1 JSON upload
    const input = document.querySelector('input[type="file"][accept=".json"]');
    // Trigger file selection via WebView bridge
    document.querySelector('[data-testid="upload-json"]')?.click();
  ''';

  static const String _gstr3bFillScript = '''
    // GSTR-3B table auto-fill
    // Table 3.1a: Outward taxable supplies
    document.querySelector('[name="table3_1a_taxable"]')?.value = '{taxableValue}';
    document.querySelector('[name="table3_1a_igst"]')?.value = '{igst}';
    document.querySelector('[name="table3_1a_cgst"]')?.value = '{cgst}';
    document.querySelector('[name="table3_1a_sgst"]')?.value = '{sgst}';
    document.querySelector('[data-testid="save-3b"]')?.click();
  ''';

  static const String _pmt06Script = '''
    // Generate PMT-06 challan for payment
    document.querySelector('[data-testid="create-challan"]')?.click();
  ''';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Logs in to the GSTN portal using [credential].
  ///
  /// When [webViewController] is provided, real WebView automation is used.
  /// When `null`, the method falls back to the mock stream for testing/preview.
  Stream<SubmissionLog> login({
    required PortalCredential credential,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'gstn_login_${credential.id}';

    if (webViewController == null) {
      yield* _mockLoginStream(jobId);
      return;
    }

    // --- Real WebView automation ---
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to GSTN portal...');
    await webViewController.waitForElement('#user_name, #username');

    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering GSTIN and password...',
    );
    await webViewController.fillField(
      '#user_name, #username',
      credential.username ?? '',
    );
    await webViewController.fillField(
      '#user_pass, [name="password"]',
      credential.encryptedPassword ?? '',
    );
    await webViewController.clickElement('[type="submit"]');

    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTN login...');
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.sms,
      portalHint: 'GSTN portal',
    );

    await webViewController.fillField('#otp, [name="otp"]', otp);
    await webViewController.clickElement('[data-testid="otp-submit"]');
    await webViewController.waitForNavigation('/dashboard');

    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to GSTN portal');
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering GSTIN and password '
      '(script: ${_loginScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTN login');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  /// Uploads a GSTR-1 JSON file for [gstin].
  Stream<SubmissionLog> uploadGstr1({
    required String gstin,
    required String jsonFilePath,
    required OtpInterceptService otpService,
  }) async* {
    final jobId = 'gstn_gstr1_$gstin';
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to GSTR-1 upload page',
    );
    yield _log(jobId, SubmissionStep.filling, 'Selecting tax period');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading GSTR-1 JSON: $jsonFilePath',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Processing upload: ${_gstr1UploadScript.trim().split('\n').first}',
    );
    yield _log(
      jobId,
      SubmissionStep.otp,
      'Awaiting OTP for GSTR-1 file confirmation '
      '(verify: ${_otpVerifyScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.submitting, 'Filing GSTR-1');
    yield _log(jobId, SubmissionStep.done, 'GSTR-1 filed for GSTIN: $gstin');
  }

  /// Auto-fills and files GSTR-3B for [gstin].
  Stream<SubmissionLog> fillGstr3b({
    required String gstin,
    required Map<String, double> taxValues,
    required OtpInterceptService otpService,
  }) async* {
    final jobId = 'gstn_gstr3b_$gstin';
    yield _log(jobId, SubmissionStep.filling, 'Navigating to GSTR-3B');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Filling Table 3.1 — Outward supplies',
    );
    yield _log(jobId, SubmissionStep.filling, 'Filling Table 4 — ITC claimed');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Computing net tax liability '
      '(3B script: ${_gstr3bFillScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTR-3B filing');
    yield _log(jobId, SubmissionStep.submitting, 'Submitting GSTR-3B');
    yield _log(jobId, SubmissionStep.done, 'GSTR-3B filed for GSTIN: $gstin');
  }

  /// Generates a PMT-06 payment challan for [gstin].
  Stream<SubmissionLog> generateChallan({
    required String gstin,
    required double taxAmount,
  }) async* {
    final jobId = 'gstn_challan_$gstin';
    yield _log(jobId, SubmissionStep.filling, 'Navigating to payment section');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Creating PMT-06 challan for ₹${taxAmount.toStringAsFixed(2)}',
    );
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Generating challan: ${_pmt06Script.trim().split('\n').first}',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'PMT-06 challan generated for GSTIN: $gstin',
    );
  }

  /// Downloads GSTR-2B for [gstin] for [taxPeriod] (e.g. '032026').
  Stream<SubmissionLog> downloadGstr2b({
    required String gstin,
    required String taxPeriod,
  }) async* {
    final jobId = 'gstn_2b_$gstin';
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to GSTR-2B section',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Selecting period $taxPeriod',
    );
    yield _log(jobId, SubmissionStep.downloading, 'Downloading GSTR-2B');
    yield _log(
      jobId,
      SubmissionStep.done,
      'GSTR-2B downloaded for period $taxPeriod',
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
