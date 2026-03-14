import 'package:ca_app/features/firm_operations/data/datasources/firm_operations_local_source.dart';
import 'package:ca_app/features/firm_operations/data/datasources/firm_operations_remote_source.dart';
import 'package:ca_app/features/firm_operations/data/mappers/firm_operations_mapper.dart';
import 'package:ca_app/features/firm_operations/domain/models/client_assignment.dart';
import 'package:ca_app/features/firm_operations/domain/models/firm_info.dart';
import 'package:ca_app/features/firm_operations/domain/models/team_member.dart';
import 'package:ca_app/features/firm_operations/domain/repositories/firm_operations_repository.dart';

/// Production repository: remote-first with local cache fallback.
class FirmOperationsRepositoryImpl implements FirmOperationsRepository {
  const FirmOperationsRepositoryImpl({
    required this.remote,
    required this.local,
    required this.firmId,
  });

  final FirmOperationsRemoteSource remote;
  final FirmOperationsLocalSource local;
  final String firmId;

  // ---------------------------------------------------------------------------
  // FirmInfo
  // ---------------------------------------------------------------------------

  @override
  Future<FirmInfo?> getFirmInfo() async {
    try {
      final json = await remote.fetchFirmInfo(firmId);
      if (json == null) return local.getFirmInfo();
      final info = FirmOperationsMapper.firmInfoFromJson(json);
      await local.upsertFirmInfo(info);
      return info;
    } catch (_) {
      return local.getFirmInfo();
    }
  }

  @override
  Future<bool> updateFirmInfo(FirmInfo firmInfo) async {
    try {
      await remote.upsertFirmInfo(
        FirmOperationsMapper.firmInfoToJson(firmInfo),
      );
      await local.upsertFirmInfo(firmInfo);
      return true;
    } catch (_) {
      return local.upsertFirmInfo(firmInfo);
    }
  }

  // ---------------------------------------------------------------------------
  // TeamMembers
  // ---------------------------------------------------------------------------

  @override
  Future<String> insertTeamMember(TeamMember member) async {
    try {
      final json = await remote.insertTeamMember(
        FirmOperationsMapper.teamMemberToJson(member),
      );
      final created = FirmOperationsMapper.teamMemberFromJson(json);
      await local.insertTeamMember(created);
      return created.id;
    } catch (_) {
      return local.insertTeamMember(member);
    }
  }

  @override
  Future<List<TeamMember>> getTeamMembers() async {
    try {
      final jsonList = await remote.fetchTeamMembers(firmId);
      final members = jsonList
          .map(FirmOperationsMapper.teamMemberFromJson)
          .toList();
      for (final m in members) {
        await local.insertTeamMember(m);
      }
      return List.unmodifiable(members);
    } catch (_) {
      return local.getTeamMembers(firmId);
    }
  }

  @override
  Future<bool> updateTeamMember(TeamMember member) async {
    try {
      await remote.updateTeamMember(
        member.id,
        FirmOperationsMapper.teamMemberToJson(member),
      );
      await local.updateTeamMember(member);
      return true;
    } catch (_) {
      return local.updateTeamMember(member);
    }
  }

  @override
  Future<bool> deleteTeamMember(String memberId) async {
    try {
      await remote.deleteTeamMember(memberId);
      await local.deleteTeamMember(memberId);
      return true;
    } catch (_) {
      return local.deleteTeamMember(memberId);
    }
  }

  // ---------------------------------------------------------------------------
  // ClientAssignments
  // ---------------------------------------------------------------------------

  @override
  Future<String> assignClient(ClientAssignment assignment) async {
    try {
      final json = await remote.assignClient(
        FirmOperationsMapper.clientAssignmentToJson(assignment),
      );
      final created = FirmOperationsMapper.clientAssignmentFromJson(json);
      await local.assignClient(created);
      return created.id;
    } catch (_) {
      return local.assignClient(assignment);
    }
  }

  @override
  Future<List<ClientAssignment>> getClientsAssignedTo(String memberId) async {
    try {
      final jsonList = await remote.fetchClientsAssignedTo(memberId);
      final assignments = jsonList
          .map(FirmOperationsMapper.clientAssignmentFromJson)
          .toList();
      for (final a in assignments) {
        await local.assignClient(a);
      }
      return List.unmodifiable(assignments);
    } catch (_) {
      return local.getClientsAssignedTo(memberId);
    }
  }
}
