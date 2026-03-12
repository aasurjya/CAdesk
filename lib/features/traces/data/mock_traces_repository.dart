import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';
import 'package:ca_app/features/traces/domain/repositories/traces_repository.dart';

/// In-memory mock implementation of [TracesRepository].
///
/// All responses are deterministic and synchronous (wrapped in
/// [Future.value]).  No network calls are made.
///
/// Behaviour contract:
/// - [verifyPan]: valid status for any PAN matching `[A-Z]{5}[0-9]{4}[A-Z]`;
///   [PanStatus.invalid] otherwise.
/// - [getChallanStatus]: always returns [ChallanBookingStatus.matched] with
///   consumedAmount == depositedAmount and balanceAmount == 0.
/// - [requestForm16]: always returns [Form16RequestStatus.available] with a
///   mock download URL.
/// - [getJustificationReport]: always returns an empty report (no demand).
/// - [getAllChallans]: returns a small list of sample challans for the TAN.
class MockTracesRepository implements TracesRepository {
  /// RegExp for a syntactically valid PAN: 5 letters, 4 digits, 1 letter.
  static final _panRegExp = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  // ── PAN Verification ────────────────────────────────────────────────────

  @override
  Future<TracesPanVerification> verifyPan(String pan) {
    final isValid = _panRegExp.hasMatch(pan);
    return Future.value(
      TracesPanVerification(
        pan: pan,
        name: isValid ? 'Mock Holder' : '',
        status: isValid ? PanStatus.valid : PanStatus.invalid,
        aadhaarLinked: isValid,
        verifiedAt: DateTime.now(),
      ),
    );
  }

  // ── Challan Status ───────────────────────────────────────────────────────

  @override
  Future<TracesChallanStatus> getChallanStatus(
    String bsrCode,
    DateTime date,
    String serial,
    String tan,
  ) {
    const depositedAmount = 50000;
    return Future.value(
      TracesChallanStatus(
        bsrCode: bsrCode,
        challanDate: date,
        challanSerial: serial,
        tan: tan,
        section: '192',
        depositedAmount: depositedAmount,
        status: ChallanBookingStatus.matched,
        consumedAmount: depositedAmount,
        balanceAmount: 0,
      ),
    );
  }

  // ── Form 16 Requests ────────────────────────────────────────────────────

  @override
  Future<TracesForm16Request> requestForm16(
    String tan,
    String pan,
    int financialYear,
  ) {
    final requestId = 'MOCK-$tan-$financialYear-$pan';
    return Future.value(
      TracesForm16Request(
        requestId: requestId,
        tan: tan,
        pan: pan,
        financialYear: financialYear,
        requestType: Form16RequestType.form16,
        status: Form16RequestStatus.available,
        downloadUrl: 'https://traces.gov.in/mock/download/$requestId',
        requestedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<TracesForm16Request>> requestBulkForm16(
    String tan,
    int financialYear,
    List<String> pans,
  ) async {
    final results = <TracesForm16Request>[];
    for (final pan in pans) {
      final req = await requestForm16(tan, pan, financialYear);
      results.add(req);
    }
    return results;
  }

  // ── Justification Report ─────────────────────────────────────────────────

  @override
  Future<TracesJustificationReport> getJustificationReport(
    String tan,
    int financialYear,
    int quarter,
  ) {
    final tdsQuarter = TdsQuarter.values[quarter - 1];
    return Future.value(
      TracesJustificationReport(
        tan: tan,
        financialYear: financialYear,
        quarter: tdsQuarter,
        shortDeductions: const [],
        lateDeductions: const [],
        totalShortfall: 0,
        totalInterestDemand: 0,
      ),
    );
  }

  // ── All Challans ─────────────────────────────────────────────────────────

  @override
  Future<List<TracesChallanStatus>> getAllChallans(
    String tan,
    int financialYear,
  ) {
    final challans = [
      TracesChallanStatus(
        bsrCode: '0001234',
        challanDate: DateTime(financialYear, 4, 7),
        challanSerial: '00001',
        tan: tan,
        section: '192',
        depositedAmount: 100000,
        status: ChallanBookingStatus.matched,
        consumedAmount: 100000,
        balanceAmount: 0,
      ),
      TracesChallanStatus(
        bsrCode: '0001234',
        challanDate: DateTime(financialYear, 7, 7),
        challanSerial: '00002',
        tan: tan,
        section: '194C',
        depositedAmount: 50000,
        status: ChallanBookingStatus.matched,
        consumedAmount: 50000,
        balanceAmount: 0,
      ),
      TracesChallanStatus(
        bsrCode: '0001234',
        challanDate: DateTime(financialYear, 10, 7),
        challanSerial: '00003',
        tan: tan,
        section: '194J',
        depositedAmount: 75000,
        status: ChallanBookingStatus.bookingConfirmed,
        consumedAmount: 0,
        balanceAmount: 75000,
      ),
    ];
    return Future.value(challans);
  }
}
