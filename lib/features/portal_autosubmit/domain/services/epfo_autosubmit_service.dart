import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/webview/js/portal_js_scripts.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/data/services/credential_encryption_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the EPFO (Employees' Provident Fund Organisation)
/// Unified Portal.
///
/// All methods return a [Stream<SubmissionLog>] so the UI can display live
/// progress. When [PortalWebViewController] is provided, real WebView
/// automation is used; otherwise falls back to mock streams.
class EpfoAutosubmitService {
  const EpfoAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://unified.epfindia.gov.in';

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Logs in to the EPFO Unified Portal.
  ///
  /// When [webViewController] is provided, real WebView automation is used.
  /// When `null`, the method falls back to the mock stream for testing/preview.
  Stream<SubmissionLog> login({
    required PortalCredential credential,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'epfo_login_${credential.id}';

    if (webViewController == null) {
      yield* _mockLoginStream(jobId);
      return;
    }

    // --- Real WebView automation ---
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Navigating to EPFO Unified Portal...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoUsernameSelector,
    );

    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering establishment ID and password...',
    );
    await webViewController.fillField(
      PortalJsScripts.epfoUsernameSelector,
      credential.username ?? '',
    );
    final plainPassword = credential.encryptedPassword != null
        ? await CredentialEncryptionService.decrypt(
            credential.encryptedPassword!,
          )
        : '';
    await webViewController.fillField(
      PortalJsScripts.epfoPasswordSelector,
      plainPassword,
    );
    await webViewController.clickElement(
      PortalJsScripts.epfoLoginBtnSelector,
    );

    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for EPFO login...');
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.sms,
      portalHint: 'EPFO portal',
    );

    await webViewController.fillField(PortalJsScripts.epfoOtpSelector, otp);
    await webViewController.clickElement(
      PortalJsScripts.epfoLoginBtnSelector,
    );
    await webViewController.waitForNavigation('/member/home');

    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  // ---------------------------------------------------------------------------
  // ECR Upload
  // ---------------------------------------------------------------------------

  /// Uploads an ECR (Electronic Challan cum Return) file for monthly payroll.
  ///
  /// When [webViewController] is provided, navigates to the ECR section,
  /// selects wage month, uploads the file, validates, and submits.
  /// If [confirmationGate] is provided, pauses after validation for CA review.
  Stream<SubmissionLog> uploadEcr({
    required String establishmentId,
    required String ecrFilePath,
    required String wageMonth,
    required OtpInterceptService otpService,
    PortalWebViewController? webViewController,
    ConfirmationGate? confirmationGate,
  }) async* {
    final jobId = 'epfo_ecr_$establishmentId';

    if (webViewController == null) {
      yield* _mockUploadEcrStream(jobId, establishmentId, ecrFilePath,
          wageMonth);
      return;
    }

    // --- Real WebView automation ---

    // Navigate to ECR section
    yield _log(jobId, SubmissionStep.filling, 'Navigating to ECR upload...');
    await webViewController.clickElement(PortalJsScripts.epfoEcrMenuSelector);
    await Future<void>.delayed(const Duration(seconds: 2));

    // Select wage month
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Selecting wage month: $wageMonth',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoWageMonthSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.epfoWageMonthSelector,
      wageMonth,
    );

    // Upload ECR file
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading ECR file: $ecrFilePath',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoEcrFileUploadSelector,
    );
    // The file upload is handled by the WebView's file chooser callback.
    await webViewController.clickElement(
      PortalJsScripts.epfoEcrUploadBtnSelector,
    );

    // Wait for portal validation
    yield _log(jobId, SubmissionStep.filling, 'Validating ECR data...');
    await webViewController.waitForElement(
      PortalJsScripts.epfoEcrValidationSuccessSelector,
      timeout: const Duration(seconds: 60),
    );

    // --- REVIEW GATE ---
    if (confirmationGate != null) {
      yield _log(
        jobId,
        SubmissionStep.reviewing,
        'ECR validated. Please review the data on screen, '
        'then tap "Confirm & Submit" to proceed.',
      );
      await confirmationGate.waitForConfirmation();
      yield _log(
        jobId,
        SubmissionStep.submitting,
        'Confirmed by user. Submitting ECR...',
      );
    }

    // Submit ECR
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Submitting ECR for establishment: $establishmentId',
    );
    await webViewController.clickElement(
      PortalJsScripts.epfoEcrSubmitBtnSelector,
    );

    // Wait for confirmation
    await webViewController.waitForElement(
      PortalJsScripts.epfoEcrSubmissionConfirmSelector,
      timeout: const Duration(seconds: 30),
    );
    yield _log(jobId, SubmissionStep.done, 'ECR uploaded for $wageMonth');
  }

  // ---------------------------------------------------------------------------
  // Challan Generation
  // ---------------------------------------------------------------------------

  /// Generates and downloads the EPF payment challan.
  ///
  /// When [webViewController] is provided, navigates to the challan section,
  /// fills EPF/EPS amounts, generates the challan, and downloads the PDF.
  Stream<SubmissionLog> generateChallan({
    required String establishmentId,
    required String wageMonth,
    required double epfAmount,
    required double epsAmount,
    required String savePath,
    PortalWebViewController? webViewController,
    ConfirmationGate? confirmationGate,
  }) async* {
    final jobId = 'epfo_challan_$establishmentId';

    if (webViewController == null) {
      yield* _mockGenerateChallanStream(
        jobId, establishmentId, wageMonth, epfAmount, epsAmount, savePath,
      );
      return;
    }

    // --- Real WebView automation ---

    // Navigate to challan section
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to challan generation...',
    );
    await webViewController.clickElement(
      PortalJsScripts.epfoChallanMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Fill EPF amount
    yield _log(
      jobId,
      SubmissionStep.filling,
      'EPF: \u20b9${epfAmount.toStringAsFixed(2)}, '
      'EPS: \u20b9${epsAmount.toStringAsFixed(2)}',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoEpfAmountSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.epfoEpfAmountSelector,
      epfAmount.toStringAsFixed(2),
    );
    await webViewController.fillField(
      PortalJsScripts.epfoEpsAmountSelector,
      epsAmount.toStringAsFixed(2),
    );

    // --- REVIEW GATE ---
    if (confirmationGate != null) {
      yield _log(
        jobId,
        SubmissionStep.reviewing,
        'Amounts filled. Please review, then tap "Confirm & Submit".',
      );
      await confirmationGate.waitForConfirmation();
      yield _log(
        jobId,
        SubmissionStep.submitting,
        'Confirmed by user. Generating challan...',
      );
    }

    // Generate challan
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Generating challan for $wageMonth...',
    );
    await webViewController.clickElement(
      PortalJsScripts.epfoGenerateChallanBtnSelector,
    );

    // Wait for success
    await webViewController.waitForElement(
      PortalJsScripts.epfoChallanSuccessSelector,
      timeout: const Duration(seconds: 30),
    );

    // Download challan PDF
    yield _log(jobId, SubmissionStep.downloading, 'Downloading challan PDF...');
    await webViewController.clickElement(
      PortalJsScripts.epfoChallanDownloadSelector,
    );

    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      'Challan generated for establishment: $establishmentId',
    );
  }

  // ---------------------------------------------------------------------------
  // KYC Status Check
  // ---------------------------------------------------------------------------

  /// Checks the KYC status for a member by Universal Account Number (UAN).
  ///
  /// When [webViewController] is provided, navigates to the KYC section,
  /// enters the UAN, and extracts the status result.
  Stream<SubmissionLog> checkMemberKyc({
    required String uan,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'epfo_kyc_$uan';

    if (webViewController == null) {
      yield* _mockCheckKycStream(jobId, uan);
      return;
    }

    // --- Real WebView automation ---

    // Navigate to KYC section
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to KYC status page...',
    );
    await webViewController.clickElement(PortalJsScripts.epfoKycMenuSelector);
    await Future<void>.delayed(const Duration(seconds: 2));

    // Enter UAN
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Entering UAN: $uan',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoUanInputSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.epfoUanInputSelector,
      uan,
    );

    // Click check/search
    await webViewController.clickElement(
      PortalJsScripts.epfoKycCheckBtnSelector,
    );

    // Wait for result
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Retrieving KYC data from EPFO...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoKycStatusResultSelector,
      timeout: const Duration(seconds: 30),
    );

    // Extract KYC status text
    final kycStatus = await webViewController.evalJs(
      PortalJsScripts.epfoExtractKycStatusScript,
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'KYC status for UAN $uan: ${kycStatus ?? 'Unknown'}',
    );
  }

  // ---------------------------------------------------------------------------
  // Payment Receipt Download
  // ---------------------------------------------------------------------------

  /// Downloads payment receipt for a settled challan.
  ///
  /// When [webViewController] is provided, navigates to the receipts section,
  /// searches for the challan by ID, and triggers download.
  Stream<SubmissionLog> downloadPaymentReceipt({
    required String establishmentId,
    required String challanId,
    required String savePath,
    PortalWebViewController? webViewController,
  }) async* {
    final jobId = 'epfo_receipt_$challanId';

    if (webViewController == null) {
      yield* _mockDownloadReceiptStream(
        jobId, establishmentId, challanId, savePath,
      );
      return;
    }

    // --- Real WebView automation ---

    // Navigate to payment receipts
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to payment receipts...',
    );
    await webViewController.clickElement(
      PortalJsScripts.epfoReceiptMenuSelector,
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    // Search for challan
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Searching for challan: $challanId',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoChallanSearchSelector,
    );
    await webViewController.fillField(
      PortalJsScripts.epfoChallanSearchSelector,
      challanId,
    );
    await webViewController.clickElement(
      PortalJsScripts.epfoReceiptSearchBtnSelector,
    );

    // Wait for results and download
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Downloading receipt...',
    );
    await webViewController.waitForElement(
      PortalJsScripts.epfoReceiptDownloadSelector,
      timeout: const Duration(seconds: 30),
    );
    await webViewController.clickElement(
      PortalJsScripts.epfoReceiptDownloadSelector,
    );

    // The file download is handled by WebView's onDownloadStartRequest callback.
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Saving receipt to: $savePath',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'Receipt downloaded for challan: $challanId',
    );
  }

  // ---------------------------------------------------------------------------
  // Mock streams (used when WebView controller is null / for testing)
  // ---------------------------------------------------------------------------

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Navigating to EPFO Unified Portal',
    );
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering establishment ID and password',
    );
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockUploadEcrStream(
    String jobId,
    String establishmentId,
    String ecrFilePath,
    String wageMonth,
  ) async* {
    yield _log(jobId, SubmissionStep.filling, 'Navigating to ECR upload');
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Selecting wage month: $wageMonth',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading ECR file: $ecrFilePath',
    );
    yield _log(jobId, SubmissionStep.filling, 'Validating ECR data');
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Submitting ECR for establishment: $establishmentId',
    );
    yield _log(jobId, SubmissionStep.done, 'ECR uploaded for $wageMonth');
  }

  Stream<SubmissionLog> _mockGenerateChallanStream(
    String jobId,
    String establishmentId,
    String wageMonth,
    double epfAmount,
    double epsAmount,
    String savePath,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to challan generation',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'EPF: \u20b9${epfAmount.toStringAsFixed(2)}, '
      'EPS: \u20b9${epsAmount.toStringAsFixed(2)}',
    );
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Generating challan for $wageMonth',
    );
    yield _log(jobId, SubmissionStep.downloading, 'Downloading challan PDF');
    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      'Challan generated for establishment: $establishmentId',
    );
  }

  Stream<SubmissionLog> _mockCheckKycStream(
    String jobId,
    String uan,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to KYC status page',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Entering UAN: $uan',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Retrieving KYC data from EPFO',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'KYC status for UAN $uan: Verified (mock)',
    );
  }

  Stream<SubmissionLog> _mockDownloadReceiptStream(
    String jobId,
    String establishmentId,
    String challanId,
    String savePath,
  ) async* {
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to payment receipts',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Searching for challan: $challanId',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Downloading receipt to: $savePath',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'Receipt downloaded for challan: $challanId',
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
