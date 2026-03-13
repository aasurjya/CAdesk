import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/firm_operations/data/mappers/firm_operations_mapper.dart';
import 'package:ca_app/features/firm_operations/domain/models/client_assignment.dart';
import 'package:ca_app/features/firm_operations/domain/models/firm_info.dart';
import 'package:ca_app/features/firm_operations/domain/models/team_member.dart';

/// Local SQLite data source for firm operations via Drift.
class FirmOperationsLocalSource {
  const FirmOperationsLocalSource(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // FirmInfo
  // ---------------------------------------------------------------------------

  Future<FirmInfo?> getFirmInfo() async {
    final row = await _db.firmOperationsDao.getFirmInfo();
    return row != null ? FirmOperationsMapper.firmInfoFromRow(row) : null;
  }

  Future<bool> upsertFirmInfo(FirmInfo info) async {
    await _db.firmOperationsDao.upsertFirmInfo(
      FirmOperationsMapper.firmInfoToCompanion(info),
    );
    return true;
  }

  // ---------------------------------------------------------------------------
  // TeamMembers
  // ---------------------------------------------------------------------------

  Future<String> insertTeamMember(TeamMember member) =>
      _db.firmOperationsDao.insertTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(member),
      );

  Future<List<TeamMember>> getTeamMembers(String firmId) async {
    final rows = await _db.firmOperationsDao.getTeamMembers(firmId);
    return rows.map(FirmOperationsMapper.teamMemberFromRow).toList();
  }

  Future<bool> updateTeamMember(TeamMember member) =>
      _db.firmOperationsDao.updateTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(member),
      );

  Future<bool> deleteTeamMember(String memberId) =>
      _db.firmOperationsDao.deleteTeamMember(memberId);

  // ---------------------------------------------------------------------------
  // ClientAssignments
  // ---------------------------------------------------------------------------

  Future<String> assignClient(ClientAssignment assignment) =>
      _db.firmOperationsDao.assignClient(
        FirmOperationsMapper.clientAssignmentToCompanion(assignment),
      );

  Future<List<ClientAssignment>> getClientsAssignedTo(String memberId) async {
    final rows = await _db.firmOperationsDao.getClientsAssignedTo(memberId);
    return rows.map(FirmOperationsMapper.clientAssignmentFromRow).toList();
  }
}
