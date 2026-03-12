import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';

/// Abstract repository for all TRACES portal operations.
///
/// The domain layer depends only on this interface. Concrete implementations
/// can be:
/// - [MockTracesRepository] — deterministic in-memory mock for tests / dev
/// - A real HTTP implementation that calls the TRACES API (future work)
///
/// **No real HTTP calls are made through this interface directly.**
abstract class TracesRepository {
  /// Verify the validity and status of a [pan] with the TRACES / ITD API.
  ///
  /// Returns a [TracesPanVerification] describing the PAN status.
  /// Throws [ArgumentError] if [pan] is syntactically invalid (length != 10).
  Future<TracesPanVerification> verifyPan(String pan);

  /// Fetch the booking / matching status of a specific TDS challan.
  ///
  /// Parameters:
  /// - [bsrCode]      — 7-digit BSR code of the bank branch
  /// - [date]         — Date the challan was deposited
  /// - [serial]       — 5-digit challan serial number assigned by the bank
  /// - [tan]          — TAN of the deductor who deposited the challan
  Future<TracesChallanStatus> getChallanStatus(
    String bsrCode,
    DateTime date,
    String serial,
    String tan,
  );

  /// Submit a Form 16 / 16A download request to TRACES for a single deductee.
  ///
  /// - [tan]           — TAN of the deductor
  /// - [pan]           — PAN of the deductee
  /// - [financialYear] — Financial year (e.g. 2024 for FY 2024-25)
  Future<TracesForm16Request> requestForm16(
    String tan,
    String pan,
    int financialYear,
  );

  /// Submit a bulk Form 16 download request covering multiple deductees.
  ///
  /// TRACES allows up to 50 PANs per request; chunking is the caller's
  /// responsibility (see [TracesBatchProcessor]).
  ///
  /// - [tan]           — TAN of the deductor
  /// - [financialYear] — Financial year
  /// - [pans]          — List of deductee PANs (up to 50 per call)
  Future<List<TracesForm16Request>> requestBulkForm16(
    String tan,
    int financialYear,
    List<String> pans,
  );

  /// Fetch the justification report for a TAN / quarter.
  ///
  /// - [tan]           — TAN of the deductor
  /// - [financialYear] — Financial year
  /// - [quarter]       — Quarter number: 1 = Q1 (Apr-Jun), …, 4 = Q4 (Jan-Mar)
  Future<TracesJustificationReport> getJustificationReport(
    String tan,
    int financialYear,
    int quarter,
  );

  /// Fetch all challans deposited by a [tan] in the given [financialYear].
  Future<List<TracesChallanStatus>> getAllChallans(
    String tan,
    int financialYear,
  );
}
