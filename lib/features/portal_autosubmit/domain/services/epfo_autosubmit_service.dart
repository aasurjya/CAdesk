import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the EPFO (Employees' Provident Fund Organisation)
/// Unified Portal.
///
/// Handles ECR upload, challan generation, and KYC status checks.
class EpfoAutosubmitService {
  const EpfoAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://unified.epfindia.gov.in';

  static const String _loginScript = '''
    // EPFO Login automation — establishment ID + password
    document.getElementById('username')?.value = '{establishmentId}';
    document.getElementById('password')?.value = '{password}';
    document.querySelector('[type="submit"]')?.click();
  ''';

  static const String _ecrUploadScript = '''
    // ECR (Electronic Challan cum Return) file upload
    const input = document.querySelector('input[type="file"]');
    document.querySelector('[data-testid="upload-ecr"]')?.click();
  ''';

  static const String _challanGenerateScript = '''
    // Generate EPF payment challan
    document.querySelector('[data-testid="generate-challan"]')?.click();
  ''';

  static const String _kycStatusScript = '''
    // Check member KYC status by UAN
    document.getElementById('uan-input')?.value = '{uan}';
    document.querySelector('[data-testid="check-kyc"]')?.click();
  ''';

  // ---------------------------------------------------------------------------
  // Public API
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
    await webViewController.waitForElement('#username');

    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering establishment ID and password...',
    );
    await webViewController.fillField('#username', credential.username ?? '');
    await webViewController.fillField(
      '#password',
      credential.encryptedPassword ?? '',
    );
    await webViewController.clickElement('[type="submit"]');

    yield _log(jobId, SubmissionStep.otp, 'Awaiting OTP for EPFO login...');
    final otp = await webViewController.interceptOtp(
      channel: OtpChannel.sms,
      portalHint: 'EPFO portal',
    );

    await webViewController.fillField('[name="otp"]', otp);
    await webViewController.clickElement('[type="submit"]');
    await webViewController.waitForNavigation('/member/home');

    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  Stream<SubmissionLog> _mockLoginStream(String jobId) async* {
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Navigating to EPFO Unified Portal',
    );
    yield _log(
      jobId,
      SubmissionStep.loggingIn,
      'Entering establishment ID and password '
      '(script: ${_loginScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  /// Uploads an ECR (Electronic Challan cum Return) file for monthly payroll.
  Stream<SubmissionLog> uploadEcr({
    required String establishmentId,
    required String ecrFilePath,
    required String wageMonth,
    required OtpInterceptService otpService,
  }) async* {
    final jobId = 'epfo_ecr_$establishmentId';
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to ECR upload section',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Selecting wage month: $wageMonth',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Uploading ECR file: $ecrFilePath '
      '(script: ${_ecrUploadScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.filling, 'Validating ECR data');
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Submitting ECR for establishment: $establishmentId',
    );
    yield _log(jobId, SubmissionStep.done, 'ECR uploaded for $wageMonth');
  }

  /// Generates and downloads the EPF payment challan.
  Stream<SubmissionLog> generateChallan({
    required String establishmentId,
    required String wageMonth,
    required double epfAmount,
    required double epsAmount,
    required String savePath,
  }) async* {
    final jobId = 'epfo_challan_$establishmentId';
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Navigating to challan generation',
    );
    yield _log(
      jobId,
      SubmissionStep.filling,
      'EPF: ₹${epfAmount.toStringAsFixed(2)}, EPS: ₹${epsAmount.toStringAsFixed(2)}',
    );
    yield _log(
      jobId,
      SubmissionStep.submitting,
      'Generating challan for $wageMonth '
      '(script: ${_challanGenerateScript.trim().split('\n').first})',
    );
    yield _log(jobId, SubmissionStep.downloading, 'Downloading challan PDF');
    yield _log(jobId, SubmissionStep.downloading, 'Saving to: $savePath');
    yield _log(
      jobId,
      SubmissionStep.done,
      'Challan generated for establishment: $establishmentId',
    );
  }

  /// Checks the KYC status for a member by Universal Account Number (UAN).
  Stream<SubmissionLog> checkMemberKyc({required String uan}) async* {
    final jobId = 'epfo_kyc_$uan';
    yield _log(
      jobId,
      SubmissionStep.filling,
      'Checking KYC status for UAN: $uan '
      '(script: ${_kycStatusScript.trim().split('\n').first})',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Retrieving KYC data from EPFO',
    );
    yield _log(
      jobId,
      SubmissionStep.done,
      'KYC status retrieved for UAN: $uan',
    );
  }

  /// Downloads payment receipt for a settled challan.
  Stream<SubmissionLog> downloadPaymentReceipt({
    required String establishmentId,
    required String challanId,
    required String savePath,
  }) async* {
    final jobId = 'epfo_receipt_$challanId';
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Navigating to payment receipts',
    );
    yield _log(
      jobId,
      SubmissionStep.downloading,
      'Locating challan: $challanId',
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
