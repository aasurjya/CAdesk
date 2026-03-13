import 'package:ca_app/features/firm_operations/domain/models/client_assignment.dart';
import 'package:ca_app/features/firm_operations/domain/models/firm_info.dart';
import 'package:ca_app/features/firm_operations/domain/models/team_member.dart';

/// Repository interface for CA firm operational data.
///
/// Covers firm settings, team members, and client-to-member assignments.
abstract class FirmOperationsRepository {
  /// Returns the firm's info record, or null if not yet set up.
  Future<FirmInfo?> getFirmInfo();

  /// Persists the firm info. Returns true on success.
  Future<bool> updateFirmInfo(FirmInfo firmInfo);

  /// Inserts a new team member and returns the generated id.
  Future<String> insertTeamMember(TeamMember member);

  /// Returns all team members for this firm.
  Future<List<TeamMember>> getTeamMembers();

  /// Updates an existing team member. Returns true on success.
  Future<bool> updateTeamMember(TeamMember member);

  /// Deletes a team member by id. Returns true on success.
  Future<bool> deleteTeamMember(String memberId);

  /// Creates a client assignment record and returns the generated id.
  Future<String> assignClient(ClientAssignment assignment);

  /// Returns all client assignments for a given team member.
  Future<List<ClientAssignment>> getClientsAssignedTo(String memberId);
}
