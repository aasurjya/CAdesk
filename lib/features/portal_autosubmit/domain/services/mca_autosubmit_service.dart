import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/webview/js/portal_js_scripts.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/data/services/credential_encryption_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the Ministry of Corporate Affairs (MCA) portal.
///
/// Handles e-Form upload, DSC signing, company master data lookups, and
/// certificate downloads. All methods return a [Stream<SubmissionLog>] so
/// the UI can display live progress.
///
/// When [PortalWebViewController] is provided, real WebView automation is
/// used; otherwise falls back to mock streams for testing/preview.
class McaAutosubmitService {
  const McaAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://www.mca.gov.in';

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Logs in to the MCA portal using [credential].
  ///
  /// MCA uses email OTP after username/password. When [webViewController] is
  /// provided, real WebView automation is used. When `null`, falls back to
  /// mock stream.
  Stream<SubmissionLog> login({
    required PortalCredential credential,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'mca_login_${credential.id}';

    if (webViewController == null) {
      yield* _mockLoginStream(jobId);
      return;
    }

    // --- Real WebView automation ---
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to MCA portal...');
    await webViewController.waitForElement(PortalJsScripts.mcaUsernameSelector);

    yield _log(jobId, SubmissionStep.loggingIn, 'Entering MCA credentials...');
    await webViewController.fillField(
      PortalJsScripts.mcaUsernameSelector,
      credential.username ?? '',
    );
    final plainPassword = credential.encryptedPassword != null
        ? await CredentialEncryptionService.decrypt(
            credential.encryptedPassword!,
          )
        : '';
    await webViewController.fillField(
      PortalJsScripts.mcaPasswordSelector,
      plainPassword,
    );
    await webViewController.clickElement(PortalJsScripts.mcaLoginBtnSelector);

    // MCA always requires email OTP
    yield _log(jobId, SubmissionStep.otp, 'Awaiting email OTP for MCA...');
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.email,
      portalHint: 'MCA portal',
    );

    await webViewController.fillField(PortalJsScripts.mcaOtpSelector, otp);
    await webViewController.clickElement(
      PortalJsScripts.mcaOtpVerifyBtnSelector,
    );
    await webViewController.waitForNavigation('/home');

    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  // ---------------------------------------------------------------------------
  // e-Form Upload
  // ---------------------------------------------------------------------------

  /// Uploads an MCA e-Form (e.g. MGT-7, AOC-4, INC-20A, DIR-3 KYC).
  ///
  /// When [webViewController] is provided, navigates to the e-Form filing
  /// section, enters the CIN, selects the form type, uploads the file,
  /// waits for validation, optionally pauses for CA review via
  /// [confirmationGate], then submits with DSC signing.
  Stream<SubmissionLog> uploadEform({
    required String cin,
    required String formType,
    required String formFilePath,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
    ConfirmationGate? confirmationGate,
  }) async* {
    final jobId = 'mca_eform_$cin';

    if (webViewController == null) {
      yield* _mockUploadEformStream(jobId, cin, formType, formFilePath);
      return;
    }

    // Navigate to e-Form section
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to $formType upload page...',
    );
    await webViewController.clickElement(PortalJsScripts.mcaEformMenuSelector);
    await Future<void>.delayed(const Duration(seconds: 2));

    // Select form type
    yield _log(jobId, SubmissionStep.filling, 'Selecting form: $formType...');
    await webViewController.waitForElement(PortalJsScripts.mcaFormTypeSelector);
    await webViewController.fillField(
      PortalJsScripts.mcaFormTypeSelector,
      formType,
    );

    // Enter CIN
    yield _log(jobId, SubmissionStep.filling, 'Entering CIN: $cin...');
    await webViewController.fillField(PortalJsScripts.mcaCinInputSelector, cin);

    // Upload form file via WebView file chooser callback
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading form file: $formFilePath',
    );
    await webViewController.waitForElement(
      PortalJsScripts.mcaFileUploadSelector,
    );
    await webViewController.clickElement(PortalJsScripts.mcaUploadBtnSelector);

    // Wait for portal validation
    yield _log(jobId, SubmissionStep.filling, 'Waiting for validation...');
    await webViewController.waitForElement(
      PortalJsScripts.mcaValidationSuccessSelector,
      timeout: const Duration(seconds: 60),
    );

    // --- REVIEW GATE ---
    if (confirmationGate != null) {
      yield _log(
        jobId,
        SubmissionStep.reviewing,
        'Form validated. Please review the data on screen, '
        'then tap "Confirm & Submit" to proceed.',
      );
      await confirmationGate.waitForConfirmation();
      yield _log(
        jobId,
        SubmissionStep.submitting,
        'Confirmed by user. Initiating DSC signing...',
      );
    }

    // DSC signing step (MCA requires DSC for most e-Forms)
    yield _log(jobId, SubmissionStep.otp, 'Awaiting DSC signing...');
    await webViewController.clickElement(PortalJsScripts.mcaDscSignBtnSelector);
    await webViewController.waitForElement(
      PortalJsScripts.mcaDscSuccessSelector,
      timeout: const Duration(seconds: 60),
    );

    // Submit
    yield _log(jobId, SubmissionStep.submitting, 'Submitting $formType...');
    await webViewController.clickElement(PortalJsScripts.mcaSubmitBtnSelector);

    // Extract SRN
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Extracting Service Request Number...',
    );
    const srnScript =
        '''
(function() {
  var el = document.querySelector('${PortalJsScripts.mcaSrnSelector}');
  return el ? el.textContent.trim() : '';
})()
''';
    final srn = await webViewController.evalJs(srnScript);
    yield _log(
      jobId,
      SubmissionStep.done,
      '$formType submitted for CIN: $cin. SRN: ${srn ?? 'N/A'}',
    );
  }

  // ---------------------------------------------------------------------------
  // DSC Signing
  // ---------------------------------------------------------------------------

  /// Triggers DSC-based digital signing for a document via the native bridge.
  ///
  /// When [webViewController] is provided, invokes `window.CADeskDSC.sign()`
  /// via JS and waits for the signing result. Falls back to mock when null.
  Stream<SubmissionLog> signWithDsc({
    required String documentHash,
    required String dscSerialNumber,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'mca_dsc_$dscSerialNumber';

    if (webViewController == null) {
      yield* _mockSignDscStream(jobId, documentHash, dscSerialNumber);
      return;
    }

    // --- Real WebView automation ---
    yield _log(jobId, SubmissionStep.otp, 'Connecting to DSC token...');

    // Click the DSC sign button to trigger the signing dialog
    yield _log(
      jobId,
      SubmissionStep.otp,
      'Requesting PIN for DSC: $dscSerialNumber',
    );
    await webViewController.clickElement(PortalJsScripts.mcaDscSignBtnSelector);

    // Wait for PIN dialog to appear
    await webViewController.waitForElement(
      PortalJsScripts.mcaDscPinInputSelector,
      timeout: const Duration(seconds: 30),
    );

    // Invoke native DSC bridge via JS
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Signing document hash: ${documentHash.substring(0, 8)}...',
    );
    final dscScript = PortalJsScripts.buildDscBridgeScript(documentHash);
    final result = await webViewController.evalJs(dscScript);

    if (result == 'DSC_BRIDGE_NOT_AVAILABLE') {
      yield _log(
        jobId,
        SubmissionStep.failed,
        'DSC bridge not available. Ensure DSC plugin is installed.',
      );
      return;
    }

    // Wait for signing success indicator
    await webViewController.waitForElement(
      PortalJsScripts.mcaDscSuccessSelector,
      timeout: const Duration(seconds: 60),
    );

    yield _log(jobId, SubmissionStep.done, 'DSC signing completed');
  }

  // ---------------------------------------------------------------------------
  // Company Lookup
  // ---------------------------------------------------------------------------

  /// Looks up company master data by CIN from the MCA portal.
  ///
  /// When [webViewController] is provided, navigates to the company search
  /// page, enters the CIN, triggers search, and extracts the result table
  /// data as JSON. Falls back to mock when null.
  Stream<SubmissionLog> lookupCompany({
    required String cin,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'mca_lookup_$cin';

    if (webViewController == null) {
      yield* _mockLookupCompanyStream(jobId, cin);
      return;
    }

    // --- Real WebView automation ---
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to company search...',
    );
    await webViewController.clickElement(
      PortalJsScripts.mcaCompanySearchMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Enter CIN
    yield _log(jobId, SubmissionStep.filling, 'Entering CIN: $cin...');
    await webViewController.waitForElement(
      PortalJsScripts.mcaSearchCinInputSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.mcaSearchCinInputSelector,
      cin,
    );

    // Click search
    yield _log(jobId, SubmissionStep.filling, 'Searching...');
    await webViewController.clickElement(PortalJsScripts.mcaSearchBtnSelector);

    // Wait for result table
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Waiting for company master data...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.mcaCompanyResultTableSelector,
      timeout: const Duration(seconds: 30),
    );

    // Extract master data as JSON
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Extracting company master data...',
    );
    final companyData = await webViewController.evalJs(
      PortalJsScripts.mcaExtractCompanyDataScript,
    );

    yield _log(
      jobId,
      SubmissionStep.done,
      'Company data retrieved for CIN: $cin '
      '(${companyData ?? 'no data'})',
    );
  }

  // ---------------------------------------------------------------------------
  // Certificate Download
  // ---------------------------------------------------------------------------

  /// Downloads a certificate (e.g. Certificate of Incorporation, charge
  /// certificate) from the MCA portal.
  ///
  /// When [webViewController] is provided, navigates to the certificates
  /// section, selects the type, and triggers download. Falls back to mock
  /// when null.
  Stream<SubmissionLog> downloadCertificate({
    required String cin,
    required String certificateType,
    required String savePath,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'mca_cert_$cin';

    if (webViewController == null) {
      yield* _mockDownloadCertificateStream(
        jobId,
        cin,
        certificateType,
        savePath,
      );
      return;
    }

    // --- Real WebView automation ---
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to certificate section...',
    );
    await webViewController.clickElement(
      PortalJsScripts.mcaCertificateMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Select certificate type
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Selecting $certificateType for CIN: $cin...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.mcaCertificateTypeSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.mcaCertificateTypeSelector,
      certificateType,
    );

    // Trigger download
    yield _log(jobId, SubmissionStep.downloading, 'Downloading...');
    await webViewController.clickElement(
      PortalJsScripts.mcaCertificateDownloadBtnSelector,
    );

    // The file download is handled by WebView's onDownloadStartRequest callback
    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      '$certificateType downloaded for CIN: $cin',
    );
  }

  // ---------------------------------------------------------------------------
  // Mock streams (used when WebView controller is null / for testing)
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to MCA portal');
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering MCA credentials');
    yield _log(jobId, SubmissionStep.otp, 'Awaiting email OTP');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockUploadEformStream(
    String jobId,
    String cin,
    String formType,
    String formFilePath,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to $formType upload page',
    );
    yield _log(jobId, SubmissionStep.filling, 'Entering CIN: $cin');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading form file: $formFilePath',
    );
    yield _log(jobId, SubmissionStep.filling, 'Validating form data');
    yield _log(jobId, SubmissionStep.otp, 'Awaiting DSC signing');
    yield _log(jobId, SubmissionStep.submitting, 'Submitting $formType to MCA');
    yield _log(jobId, SubmissionStep.done, '$formType submitted for CIN: $cin');
  }

  Stream<SubmissionLog> _mockSignDscStream(
    String jobId,
    String documentHash,
    String dscSerialNumber,
  ) async* {
    yield _log(jobId, SubmissionStep.otp, 'Connecting to DSC token');
    yield _log(
      jobId,
      SubmissionStep.otp,
      'Requesting PIN for DSC: $dscSerialNumber',
    );
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Signing document hash: ${documentHash.substring(0, 8)}...',
    );
    yield _log(jobId, SubmissionStep.done, 'DSC signing completed');
  }

  Stream<SubmissionLog> _mockLookupCompanyStream(
    String jobId,
    String cin,
  ) async* {
    yield _log(jobId, SubmissionStep.filling, 'Searching company by CIN: $cin');
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Retrieving company master data',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'Company data retrieved for CIN: $cin',
    );
  }

  Stream<SubmissionLog> _mockDownloadCertificateStream(
    String jobId,
    String cin,
    String certificateType,
    String savePath,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to certificate download',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Requesting $certificateType for CIN: $cin',
    );
    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      '$certificateType downloaded for CIN: $cin',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
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
