import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/itr_u_filing.dart';

/// Abstract contract for faceless assessment data operations.
///
/// Covers e-proceedings (NfAC), hearing schedules, and ITR-U filings.
abstract class FacelessAssessmentRepository {
  // -------------------------------------------------------------------------
  // EProceeding operations
  // -------------------------------------------------------------------------

  /// Retrieve all e-proceedings.
  Future<List<EProceeding>> getProceedings();

  /// Retrieve all e-proceedings for a specific [clientId].
  Future<List<EProceeding>> getProceedingsByClient(String clientId);

  /// Insert a new [EProceeding] and return its ID.
  Future<String> insertProceeding(EProceeding proceeding);

  /// Update an existing [EProceeding]. Returns true on success.
  Future<bool> updateProceeding(EProceeding proceeding);

  /// Delete the e-proceeding identified by [id]. Returns true on success.
  Future<bool> deleteProceeding(String id);

  // -------------------------------------------------------------------------
  // HearingSchedule operations
  // -------------------------------------------------------------------------

  /// Retrieve all hearing schedules.
  Future<List<HearingSchedule>> getHearings();

  /// Retrieve hearing schedules for a specific [proceedingId].
  Future<List<HearingSchedule>> getHearingsByProceeding(String proceedingId);

  /// Insert a new [HearingSchedule] and return its ID.
  Future<String> insertHearing(HearingSchedule hearing);

  /// Update an existing [HearingSchedule]. Returns true on success.
  Future<bool> updateHearing(HearingSchedule hearing);

  /// Delete the hearing identified by [id]. Returns true on success.
  Future<bool> deleteHearing(String id);

  // -------------------------------------------------------------------------
  // ItrUFiling operations
  // -------------------------------------------------------------------------

  /// Retrieve all ITR-U filings.
  Future<List<ItrUFiling>> getItrUFilings();

  /// Retrieve ITR-U filings for a specific [clientId].
  Future<List<ItrUFiling>> getItrUFilingsByClient(String clientId);

  /// Insert a new [ItrUFiling] and return its ID.
  Future<String> insertItrUFiling(ItrUFiling filing);

  /// Update an existing [ItrUFiling]. Returns true on success.
  Future<bool> updateItrUFiling(ItrUFiling filing);

  /// Delete the ITR-U filing identified by [id]. Returns true on success.
  Future<bool> deleteItrUFiling(String id);
}
