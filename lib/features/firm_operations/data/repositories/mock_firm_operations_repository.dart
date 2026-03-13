import 'package:ca_app/features/firm_operations/domain/models/client_assignment.dart';
import 'package:ca_app/features/firm_operations/domain/models/firm_info.dart';
import 'package:ca_app/features/firm_operations/domain/models/team_member.dart';
import 'package:ca_app/features/firm_operations/domain/repositories/firm_operations_repository.dart';

/// In-memory mock repository for development and testing without a database.
class MockFirmOperationsRepository implements FirmOperationsRepository {
  MockFirmOperationsRepository() {
    _members.addAll(_seedMembers);
    _assignments.addAll(_seedAssignments);
  }

  // ---------------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------------

  static final FirmInfo _seedFirmInfo = FirmInfo(
    id: 'firm-001',
    name: 'Mehta & Associates',
    address: '12, CA Colony, Andheri East',
    panNumber: 'AABFM1234C',
    tanNumber: 'MUMM12345B',
    city: 'Mumbai',
    state: 'Maharashtra',
    pincode: '400069',
    bankAccount: '1234567890',
    registrationDate: DateTime(2005, 4, 1),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  static final List<TeamMember> _seedMembers = [
    TeamMember(
      id: 'tm-001',
      firmId: 'firm-001',
      name: 'CA Rajesh Mehta',
      pan: 'ABCPM1234A',
      role: 'Partner',
      email: 'rajesh@mehtaca.in',
      phone: '9820012345',
      permissions: const ['gst', 'audit', 'tds', 'itr'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    TeamMember(
      id: 'tm-002',
      firmId: 'firm-001',
      name: 'CA Priya Sharma',
      pan: 'BCDPS5678B',
      role: 'Senior',
      email: 'priya@mehtaca.in',
      phone: '9876543210',
      permissions: const ['gst', 'itr'],
      createdAt: DateTime(2024, 3, 15),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  static final List<ClientAssignment> _seedAssignments = [
    ClientAssignment(
      id: 'ca-001',
      clientId: 'client-001',
      assignedToId: 'tm-001',
      startDate: DateTime(2024, 4, 1),
      role: 'Lead',
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    ),
    ClientAssignment(
      id: 'ca-002',
      clientId: 'client-002',
      assignedToId: 'tm-002',
      startDate: DateTime(2024, 7, 1),
      role: 'Associate',
      createdAt: DateTime(2024, 7, 1),
      updatedAt: DateTime(2024, 7, 1),
    ),
  ];

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  FirmInfo _firmInfo = _seedFirmInfo;
  final List<TeamMember> _members = [];
  final List<ClientAssignment> _assignments = [];

  // ---------------------------------------------------------------------------
  // FirmInfo
  // ---------------------------------------------------------------------------

  @override
  Future<FirmInfo?> getFirmInfo() async => _firmInfo;

  @override
  Future<bool> updateFirmInfo(FirmInfo firmInfo) async {
    _firmInfo = firmInfo;
    return true;
  }

  // ---------------------------------------------------------------------------
  // TeamMembers
  // ---------------------------------------------------------------------------

  @override
  Future<String> insertTeamMember(TeamMember member) async {
    _members.add(member);
    return member.id;
  }

  @override
  Future<List<TeamMember>> getTeamMembers() async =>
      List.unmodifiable(_members);

  @override
  Future<bool> updateTeamMember(TeamMember member) async {
    final idx = _members.indexWhere((m) => m.id == member.id);
    if (idx == -1) return false;
    final updated = List<TeamMember>.of(_members);
    updated[idx] = member;
    _members
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteTeamMember(String memberId) async {
    final before = _members.length;
    _members.removeWhere((m) => m.id == memberId);
    return _members.length < before;
  }

  // ---------------------------------------------------------------------------
  // ClientAssignments
  // ---------------------------------------------------------------------------

  @override
  Future<String> assignClient(ClientAssignment assignment) async {
    _assignments.add(assignment);
    return assignment.id;
  }

  @override
  Future<List<ClientAssignment>> getClientsAssignedTo(String memberId) async =>
      List.unmodifiable(
        _assignments.where((a) => a.assignedToId == memberId),
      );
}
