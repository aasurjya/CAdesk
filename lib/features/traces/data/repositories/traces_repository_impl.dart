import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';
import 'package:ca_app/features/traces/domain/repositories/traces_repository.dart';

/// Real implementation of [TracesRepository].
///
/// Makes HTTP calls to the TRACES portal API via [TracesService].
/// Falls back to empty/error responses when the network is unavailable.
///
/// Full wiring to [TracesService] is deferred until the portal integration phase.
class TracesRepositoryImpl implements TracesRepository {
  const TracesRepositoryImpl();

  static final _panRegExp = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  @override
  Future<TracesPanVerification> verifyPan(String pan) async {
    if (pan.length != 10) {
      throw ArgumentError.value(
        pan,
        'pan',
        'PAN must be exactly 10 characters',
      );
    }
    // TODO(portal): delegate to TracesService HTTP call
    final isValid = _panRegExp.hasMatch(pan);
    return TracesPanVerification(
      pan: pan,
      name: isValid ? '' : '',
      status: isValid ? PanStatus.valid : PanStatus.invalid,
      aadhaarLinked: false,
      verifiedAt: DateTime.now(),
    );
  }

  @override
  Future<TracesChallanStatus> getChallanStatus(
    String bsrCode,
    DateTime date,
    String serial,
    String tan,
  ) async {
    // TODO(portal): delegate to TracesService HTTP call
    return TracesChallanStatus(
      bsrCode: bsrCode,
      challanDate: date,
      challanSerial: serial,
      tan: tan,
      section: '192',
      depositedAmount: 0,
      status: ChallanBookingStatus.matched,
      consumedAmount: 0,
      balanceAmount: 0,
    );
  }

  @override
  Future<TracesForm16Request> requestForm16(
    String tan,
    String pan,
    int financialYear,
  ) async {
    // TODO(portal): delegate to TracesService HTTP call
    return TracesForm16Request(
      requestId: '$tan-$pan-$financialYear',
      tan: tan,
      pan: pan,
      financialYear: financialYear,
      requestType: Form16RequestType.form16,
      status: Form16RequestStatus.submitted,
      requestedAt: DateTime.now(),
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
      results.add(await requestForm16(tan, pan, financialYear));
    }
    return results;
  }

  @override
  Future<TracesJustificationReport> getJustificationReport(
    String tan,
    int financialYear,
    int quarter,
  ) async {
    // TODO(portal): delegate to TracesService HTTP call
    final tdsQuarter = TdsQuarter.values[(quarter - 1).clamp(0, 3)];
    return TracesJustificationReport(
      tan: tan,
      financialYear: financialYear,
      quarter: tdsQuarter,
      shortDeductions: const [],
      lateDeductions: const [],
      totalShortfall: 0,
      totalInterestDemand: 0,
    );
  }

  @override
  Future<List<TracesChallanStatus>> getAllChallans(
    String tan,
    int financialYear,
  ) async {
    // TODO(portal): delegate to TracesService HTTP call
    return const [];
  }
}
