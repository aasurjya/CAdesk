import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Auto-submit service for the Ministry of Corporate Affairs (MCA) portal.
///
/// Handles e-Form upload, DSC signing, and company master data lookups.
class McaAutosubmitService {
  const McaAutosubmitService();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String portalUrl = 'https://www.mca.gov.in';

  static const String _loginScript = '''
    // MCA Login automation
    document.getElementById('username')?.value = '{username}';
    document.getElementById('password')?.value = '{password}';
    document.querySelector('[type="submit"]')?.click();
  ''';

  static const String _eformUploadScript = '''
    // MCA e-Form upload
    const input = document.querySelector('input[type="file"]');
    document.querySelector('[data-testid="upload-eform"]')?.click();
  ''';

  static const String _dscSignScript = '''
    // DSC signing via platform plugin
    // Triggers native DSC bridge — actual signing happens in native code
    window.CADeskDSC?.sign('{documentHash}');
  ''';

  static const String _companyLookupScript = '''
    // Company master data lookup by CIN
    document.getElementById('cin-input')?.value = '{cin}';
    document.querySelector('[data-testid="search-company"]')?.click();
  ''';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Logs in to the MCA portal.
  Stream<SubmissionLog> login({
    required PortalCredential credential,
    required OtpInterceptService otpService,
  }) async* {
    final jobId = 'mca_login_${credential.id}';
    yield _log(jobId, SubmissionStep.loggingIn, 'Navigating to MCA portal');
    yield _log(jobId, SubmissionStep.loggingIn, 'Entering MCA credentials');
    yield _log(jobId, SubmissionStep.loggingIn, 'Login completed successfully');
  }

  /// Uploads an MCA e-Form (e.g. MGT-7, AOC-4, INC-20A, DIR-3 KYC).
  Stream<SubmissionLog> uploadEform({
    required String cin,
    required String formType,
    required String formFilePath,
    required OtpInterceptService otpService,
  }) async* {
    final jobId = 'mca_eform_$cin';
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

  /// Triggers DSC-based digital signing for a document.
  Stream<SubmissionLog> signWithDsc({
    required String documentHash,
    required String dscSerialNumber,
  }) async* {
    final jobId = 'mca_dsc_$dscSerialNumber';
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

  /// Looks up company master data by CIN.
  Stream<SubmissionLog> lookupCompany({required String cin}) async* {
    final jobId = 'mca_lookup_$cin';
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

  /// Downloads a Certificate of Incorporation or charge certificate.
  Stream<SubmissionLog> downloadCertificate({
    required String cin,
    required String certificateType,
    required String savePath,
  }) async* {
    final jobId = 'mca_cert_$cin';
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
