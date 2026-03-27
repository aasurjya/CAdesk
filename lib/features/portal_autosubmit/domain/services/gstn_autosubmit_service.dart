import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/webview/js/portal_js_scripts.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/data/services/credential_encryption_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the GST Network (GSTN) portal.
///
/// Handles GSTR-1 upload, GSTR-3B auto-fill, PMT-06 challan generation,
/// and GSTR-2B download. All methods return [Stream<SubmissionLog>] for
/// live UI progress.
///
/// When [PortalWebViewController] is provided, real WebView automation is
/// used; otherwise falls back to mock streams for testing/preview.
class GstnAutosubmitService {
  const GstnAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://services.gst.gov.in';

  // ---------------------------------------------------------------------------
  // Login
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
    await webViewController.waitForElement(
      PortalJsScripts.gstnUsernameSelector,
    );

    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering GSTIN and password...',
    );
    await webViewController.fillField(
      PortalJsScripts.gstnUsernameSelector,
      credential.username ?? '',
    );
    final plainPassword = credential.encryptedPassword != null
        ? await CredentialEncryptionService.decrypt(
            credential.encryptedPassword!,
          )
        : '';
    await webViewController.fillField(
      PortalJsScripts.gstnPasswordSelector,
      plainPassword,
    );
    await webViewController.clickElement(PortalJsScripts.gstnLoginBtnSelector);

    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTN login...');
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.sms,
      portalHint: 'GSTN portal',
    );

    await webViewController.fillField(PortalJsScripts.gstnOtpSelector, otp);
    await webViewController.clickElement(
      PortalJsScripts.gstnOtpVerifyBtnSelector,
    );
    await webViewController.waitForNavigation('/dashboard');

    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  // ---------------------------------------------------------------------------
  // GSTR-1 Upload
  // ---------------------------------------------------------------------------

  /// Uploads a GSTR-1 JSON file for [gstin].
  ///
  /// Navigates to the GSTR-1 page, selects [taxPeriod], uploads the JSON file,
  /// waits for validation, pauses at the [confirmationGate] for CA review,
  /// then submits with OTP via [otpService].
  Stream<SubmissionLog> uploadGstr1({
    required String gstin,
    required String jsonFilePath,
    required String taxPeriod,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
    ConfirmationGate? confirmationGate,
  }) async* {
    final jobId = 'gstn_gstr1_$gstin';

    if (webViewController == null) {
      yield* _mockUploadGstr1Stream(jobId, gstin, jsonFilePath);
      return;
    }

    // --- Real WebView automation ---
    // Navigate to Returns → GSTR-1
    yield _log(jobId, SubmissionStep.filling, 'Navigating to GSTR-1 page...');
    await webViewController.clickElement(
      PortalJsScripts.gstnReturnsMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr1TileSelector,
    );
    await webViewController.clickElement(PortalJsScripts.gstnGstr1TileSelector);

    // Select tax period
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Selecting tax period $taxPeriod...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnTaxPeriodSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTaxPeriodSelector,
      taxPeriod,
    );

    // Upload JSON file
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading GSTR-1 JSON: $jsonFilePath',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr1FileUploadSelector,
    );
    await webViewController.clickElement(
      PortalJsScripts.gstnGstr1UploadBtnSelector,
    );

    // Wait for portal validation
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Waiting for portal validation...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr1ValidationSelector,
      timeout: const Duration(seconds: 60),
    );

    // --- REVIEW GATE ---
    if (confirmationGate != null) {
      yield _log(
        jobId,
        SubmissionStep.reviewing,
        'GSTR-1 data uploaded successfully. Please review the data on screen, '
        'then tap "Confirm & Submit" to proceed.',
      );
      await confirmationGate.waitForConfirmation();
      yield _log(
        jobId,
        SubmissionStep.submitting,
        'Confirmed by user. Filing GSTR-1...',
      );
    }

    // Submit with OTP
    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTR-1 filing...');
    await webViewController.clickElement(
      PortalJsScripts.gstnGstr1SubmitBtnSelector,
    );
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.sms,
      portalHint: 'GSTN GSTR-1 filing',
    );
    await webViewController.fillField(PortalJsScripts.gstnOtpSelector, otp);
    await webViewController.clickElement(
      PortalJsScripts.gstnOtpVerifyBtnSelector,
    );

    // Extract ARN
    yield _log(jobId, SubmissionStep.submitting, 'Extracting ARN...');
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr1ArnSelector,
      timeout: const Duration(seconds: 30),
    );
    const arnScript =
        '''
(function() {
  var el = document.querySelector('${PortalJsScripts.gstnGstr1ArnSelector}');
  return el ? el.textContent.trim() : '';
})()
''';
    final arn = await webViewController.evalJs(arnScript);
    yield _log(
      jobId,
      SubmissionStep.done,
      'GSTR-1 filed for GSTIN: $gstin. ARN: ${arn ?? 'N/A'}',
    );
  }

  // ---------------------------------------------------------------------------
  // GSTR-3B Fill & File
  // ---------------------------------------------------------------------------

  /// Auto-fills and files GSTR-3B for [gstin].
  ///
  /// Navigates to GSTR-3B, fills Table 3.1 (outward supplies) and Table 4
  /// (ITC) from [taxValues], saves the draft, pauses at the
  /// [confirmationGate] for CA review, then submits with OTP.
  ///
  /// Expected [taxValues] keys: `taxableValue`, `igst`, `cgst`, `sgst`,
  /// `itcIgst`, `itcCgst`, `itcSgst`.
  Stream<SubmissionLog> fillGstr3b({
    required String gstin,
    required String taxPeriod,
    required Map<String, double> taxValues,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
    ConfirmationGate? confirmationGate,
  }) async* {
    final jobId = 'gstn_gstr3b_$gstin';

    if (webViewController == null) {
      yield* _mockFillGstr3bStream(jobId, gstin);
      return;
    }

    // --- Real WebView automation ---
    // Navigate to Returns → GSTR-3B
    yield _log(jobId, SubmissionStep.filling, 'Navigating to GSTR-3B...');
    await webViewController.clickElement(
      PortalJsScripts.gstnReturnsMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr3bTileSelector,
    );
    await webViewController.clickElement(
      PortalJsScripts.gstnGstr3bTileSelector,
    );

    // Select tax period
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Selecting tax period $taxPeriod...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnTaxPeriodSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTaxPeriodSelector,
      taxPeriod,
    );

    // Fill Table 3.1(a) — Outward taxable supplies
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Filling Table 3.1 — Outward supplies...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnTable31aTaxableSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTable31aTaxableSelector,
      _formatAmount(taxValues['taxableValue']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTable31aIgstSelector,
      _formatAmount(taxValues['igst']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTable31aCgstSelector,
      _formatAmount(taxValues['cgst']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTable31aSgstSelector,
      _formatAmount(taxValues['sgst']),
    );

    // Fill Table 4 — ITC claimed
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Filling Table 4 — ITC claimed...',
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTable4ItcIgstSelector,
      _formatAmount(taxValues['itcIgst']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTable4ItcCgstSelector,
      _formatAmount(taxValues['itcCgst']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTable4ItcSgstSelector,
      _formatAmount(taxValues['itcSgst']),
    );

    // Save draft
    yield _log(jobId, SubmissionStep.filling, 'Saving GSTR-3B draft...');
    await webViewController.clickElement(
      PortalJsScripts.gstnGstr3bSaveBtnSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // --- REVIEW GATE ---
    if (confirmationGate != null) {
      yield _log(
        jobId,
        SubmissionStep.reviewing,
        'GSTR-3B filled successfully. Please review the data on screen, '
        'then tap "Confirm & Submit" to proceed.',
      );
      await confirmationGate.waitForConfirmation();
      yield _log(
        jobId,
        SubmissionStep.submitting,
        'Confirmed by user. Submitting GSTR-3B...',
      );
    }

    // Submit with OTP
    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTR-3B filing...');
    await webViewController.clickElement(
      PortalJsScripts.gstnGstr3bSubmitBtnSelector,
    );
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.sms,
      portalHint: 'GSTN GSTR-3B filing',
    );
    await webViewController.fillField(PortalJsScripts.gstnOtpSelector, otp);
    await webViewController.clickElement(
      PortalJsScripts.gstnOtpVerifyBtnSelector,
    );

    // Extract ARN
    yield _log(jobId, SubmissionStep.submitting, 'Extracting ARN...');
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr3bArnSelector,
      timeout: const Duration(seconds: 30),
    );
    const arnScript =
        '''
(function() {
  var el = document.querySelector('${PortalJsScripts.gstnGstr3bArnSelector}');
  return el ? el.textContent.trim() : '';
})()
''';
    final arn = await webViewController.evalJs(arnScript);
    yield _log(
      jobId,
      SubmissionStep.done,
      'GSTR-3B filed for GSTIN: $gstin. ARN: ${arn ?? 'N/A'}',
    );
  }

  // ---------------------------------------------------------------------------
  // PMT-06 Challan Generation
  // ---------------------------------------------------------------------------

  /// Generates a PMT-06 payment challan for [gstin].
  ///
  /// Navigates to Payments, fills the challan form with amounts from
  /// [taxBreakdown], and generates the challan. Returns the CPIN.
  ///
  /// Expected [taxBreakdown] keys: `igst`, `cgst`, `sgst`, `cess`.
  Stream<SubmissionLog> generateChallan({
    required String gstin,
    required double taxAmount,
    Map<String, double>? taxBreakdown,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'gstn_challan_$gstin';

    if (webViewController == null) {
      yield* _mockGenerateChallanStream(jobId, gstin, taxAmount);
      return;
    }

    // --- Real WebView automation ---
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to payment section...',
    );
    await webViewController.clickElement(
      PortalJsScripts.gstnPaymentsMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Click Create Challan
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Creating PMT-06 challan for total amount...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnCreateChallanBtnSelector,
    );
    await webViewController.clickElement(
      PortalJsScripts.gstnCreateChallanBtnSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Fill challan amounts
    final breakdown = taxBreakdown ?? _defaultBreakdown(taxAmount);
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Filling challan amounts — total: ${taxAmount.toStringAsFixed(2)}...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnChallanIgstSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.gstnChallanIgstSelector,
      _formatAmount(breakdown['igst']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnChallanCgstSelector,
      _formatAmount(breakdown['cgst']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnChallanSgstSelector,
      _formatAmount(breakdown['sgst']),
    );
    await webViewController.fillField(
      PortalJsScripts.gstnChallanCessSelector,
      _formatAmount(breakdown['cess']),
    );

    // Generate challan
    yield _log(jobId, SubmissionStep.submitting, 'Generating challan...');
    await webViewController.clickElement(
      PortalJsScripts.gstnGenerateChallanBtnSelector,
    );

    // Extract CPIN
    await webViewController.waitForElement(
      PortalJsScripts.gstnChallanCpinSelector,
      timeout: const Duration(seconds: 30),
    );
    const cpinScript =
        '''
(function() {
  var el = document.querySelector('${PortalJsScripts.gstnChallanCpinSelector}');
  return el ? el.textContent.trim() : '';
})()
''';
    final cpin = await webViewController.evalJs(cpinScript);
    yield _log(
      jobId,
      SubmissionStep.done,
      'PMT-06 challan generated for GSTIN: $gstin. CPIN: ${cpin ?? 'N/A'}',
    );
  }

  // ---------------------------------------------------------------------------
  // GSTR-2B Download
  // ---------------------------------------------------------------------------

  /// Downloads GSTR-2B for [gstin] for [taxPeriod] (e.g. '032026').
  ///
  /// Navigates to Returns, selects GSTR-2B, picks the period, and triggers
  /// the download.
  Stream<SubmissionLog> downloadGstr2b({
    required String gstin,
    required String taxPeriod,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'gstn_2b_$gstin';

    if (webViewController == null) {
      yield* _mockDownloadGstr2bStream(jobId, gstin, taxPeriod);
      return;
    }

    // --- Real WebView automation ---
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to GSTR-2B section...',
    );
    await webViewController.clickElement(
      PortalJsScripts.gstnReturnsMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr2bTileSelector,
    );
    await webViewController.clickElement(
      PortalJsScripts.gstnGstr2bTileSelector,
    );

    // Select tax period
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Selecting period $taxPeriod...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.gstnTaxPeriodSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.gstnTaxPeriodSelector,
      taxPeriod,
    );

    // Trigger download
    yield _log(jobId, SubmissionStep.downloading, 'Downloading GSTR-2B...');
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr2bDownloadBtnSelector,
    );
    await webViewController.clickElement(
      PortalJsScripts.gstnGstr2bDownloadBtnSelector,
    );

    // Wait for download success indicator
    await webViewController.waitForElement(
      PortalJsScripts.gstnGstr2bSuccessSelector,
      timeout: const Duration(seconds: 30),
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'GSTR-2B downloaded for period $taxPeriod',
    );
  }

  // ---------------------------------------------------------------------------
  // Mock streams (used when WebView controller is null / for testing)
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to GSTN portal');
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering GSTIN and password');
    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTN login');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockUploadGstr1Stream(
    String jobId,
    String gstin,
    String jsonFilePath,
  ) async* {
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
    yield _log(jobId, SubmissionStep.filling, 'Waiting for portal validation');
    yield _log(
      jobId,
      SubmissionStep.otp,
      'Awaiting OTP for GSTR-1 file confirmation',
    );
    yield _log(jobId, SubmissionStep.submitting, 'Filing GSTR-1');
    yield _log(jobId, SubmissionStep.done, 'GSTR-1 filed for GSTIN: $gstin');
  }

  Stream<SubmissionLog> _mockFillGstr3bStream(
    String jobId,
    String gstin,
  ) async* {
    yield _log(jobId, SubmissionStep.filling, 'Navigating to GSTR-3B');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Filling Table 3.1 — Outward supplies',
    );
    yield _log(jobId, SubmissionStep.filling, 'Filling Table 4 — ITC claimed');
    yield _log(jobId, SubmissionStep.filling, 'Saving GSTR-3B draft');
    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for GSTR-3B filing');
    yield _log(jobId, SubmissionStep.submitting, 'Submitting GSTR-3B');
    yield _log(jobId, SubmissionStep.done, 'GSTR-3B filed for GSTIN: $gstin');
  }

  Stream<SubmissionLog> _mockGenerateChallanStream(
    String jobId,
    String gstin,
    double taxAmount,
  ) async* {
    yield _log(jobId, SubmissionStep.filling, 'Navigating to payment section');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Creating PMT-06 challan for total amount',
    );
    yield _log(jobId, SubmissionStep.submitting, 'Generating challan');
    yield _log(
      jobId,
      SubmissionStep.done,
      'PMT-06 challan generated for GSTIN: $gstin',
    );
  }

  Stream<SubmissionLog> _mockDownloadGstr2bStream(
    String jobId,
    String gstin,
    String taxPeriod,
  ) async* {
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
  // Helpers
  // ---------------------------------------------------------------------------

  /// Formats a nullable double as a string suitable for form fields.
  static String _formatAmount(double? value) {
    return (value ?? 0).toStringAsFixed(2);
  }

  /// Creates a default even CGST/SGST split when no breakdown is provided.
  static Map<String, double> _defaultBreakdown(double totalAmount) {
    final halfAmount = totalAmount / 2;
    return {'igst': 0, 'cgst': halfAmount, 'sgst': halfAmount, 'cess': 0};
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
