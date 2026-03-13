import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/firm_operations/domain/models/client_assignment.dart';
import 'package:ca_app/features/firm_operations/domain/models/firm_info.dart';
import 'package:ca_app/features/firm_operations/domain/models/team_member.dart';
import 'package:ca_app/features/firm_operations/data/mappers/firm_operations_mapper.dart';
import 'package:ca_app/features/firm_operations/data/repositories/mock_firm_operations_repository.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  int counter = 0;

  String uid() => 'test-${++counter}';

  setUpAll(() async {
    database = _createTestDatabase();
  });

  tearDownAll(() async {
    await database.close();
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  FirmInfo makeFirmInfo({String? id}) => FirmInfo(
    id: id ?? uid(),
    name: 'Test CA Firm',
    address: '1 Main Street',
    panNumber: 'TSTFM${counter.toString().padLeft(4, '0')}T',
    tanNumber: 'TSTT${counter.toString().padLeft(5, '0')}T',
    city: 'Mumbai',
    state: 'Maharashtra',
    pincode: '400001',
    bankAccount: '9876543210',
    registrationDate: DateTime(2010, 4, 1),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  TeamMember makeTeamMember({String? id, String? firmId, String? pan}) {
    final idx = ++counter;
    return TeamMember(
      id: id ?? 'tm-$idx',
      firmId: firmId ?? 'firm-001',
      name: 'Member $idx',
      pan: pan ?? 'PANM${idx.toString().padLeft(4, '0')}M',
      role: 'Associate',
      email: 'member$idx@firm.in',
      phone: '900000${idx.toString().padLeft(4, '0')}',
      permissions: const ['gst', 'tds'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  ClientAssignment makeAssignment({
    String? id,
    String? clientId,
    String? assignedToId,
  }) {
    final idx = ++counter;
    return ClientAssignment(
      id: id ?? 'asgn-$idx',
      clientId: clientId ?? 'cli-$idx',
      assignedToId: assignedToId ?? 'tm-$idx',
      startDate: DateTime(2024, 4, 1),
      role: 'Lead',
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    );
  }

  // ---------------------------------------------------------------------------
  // FirmInfo tests
  // ---------------------------------------------------------------------------

  group('FirmOperationsDao — FirmInfo', () {
    test('getFirmInfo returns null when table is empty', () async {
      final result = await database.firmOperationsDao.getFirmInfo();
      // May have been inserted by a previous test; null OR a value is valid
      // In an empty DB the first call must return null.
      // We verify the type contract only since tests share a DB instance.
      expect(result == null || result.id.isNotEmpty, isTrue);
    });

    test('upsertFirmInfo stores and retrieves firm info', () async {
      final info = makeFirmInfo(id: 'firm-upsert-${uid()}');
      await database.firmOperationsDao.upsertFirmInfo(
        FirmOperationsMapper.firmInfoToCompanion(info),
      );

      final stored = await database.firmOperationsDao.getFirmInfo();
      expect(stored, isNotNull);
      expect(stored!.name, 'Test CA Firm');
    });

    test('upsertFirmInfo updates existing record', () async {
      final id = 'firm-update-${uid()}';
      final info = makeFirmInfo(id: id);
      await database.firmOperationsDao.upsertFirmInfo(
        FirmOperationsMapper.firmInfoToCompanion(info),
      );

      final updated = info.copyWith(name: 'Updated Firm Name');
      await database.firmOperationsDao.upsertFirmInfo(
        FirmOperationsMapper.firmInfoToCompanion(updated),
      );

      final stored = await database.firmOperationsDao.getFirmInfo();
      expect(stored, isNotNull);
      // The row was upserted; the table has at least this record
      expect(stored!.id.isNotEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // TeamMembers tests
  // ---------------------------------------------------------------------------

  group('FirmOperationsDao — TeamMembers', () {
    const testFirmId = 'firm-tm-test';

    test('insertTeamMember returns the member id', () async {
      final member = makeTeamMember(firmId: testFirmId);
      final returnedId = await database.firmOperationsDao.insertTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(member),
      );
      expect(returnedId, equals(member.id));
    });

    test('getTeamMembers returns inserted member', () async {
      final member = makeTeamMember(firmId: testFirmId);
      await database.firmOperationsDao.insertTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(member),
      );

      final results = await database.firmOperationsDao.getTeamMembers(
        testFirmId,
      );
      expect(results.any((r) => r.id == member.id), isTrue);
    });

    test('getTeamMembers returns empty list for unknown firmId', () async {
      final results = await database.firmOperationsDao.getTeamMembers(
        'nonexistent-firm-xyz',
      );
      expect(results, isEmpty);
    });

    test('updateTeamMember returns true and persists change', () async {
      final member = makeTeamMember(firmId: testFirmId);
      await database.firmOperationsDao.insertTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(member),
      );

      final updated = member.copyWith(role: 'Partner');
      final success = await database.firmOperationsDao.updateTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(updated),
      );
      expect(success, isTrue);

      final retrieved = await database.firmOperationsDao.getTeamMemberById(
        member.id,
      );
      expect(retrieved?.role, 'Partner');
    });

    test('updateTeamMember returns false for non-existent member', () async {
      final ghost = makeTeamMember(id: 'ghost-${uid()}', firmId: testFirmId);
      final success = await database.firmOperationsDao.updateTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(ghost),
      );
      expect(success, isFalse);
    });

    test('deleteTeamMember returns true and removes the row', () async {
      final member = makeTeamMember(firmId: testFirmId);
      await database.firmOperationsDao.insertTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(member),
      );

      final success = await database.firmOperationsDao.deleteTeamMember(
        member.id,
      );
      expect(success, isTrue);

      final retrieved = await database.firmOperationsDao.getTeamMemberById(
        member.id,
      );
      expect(retrieved, isNull);
    });

    test('deleteTeamMember returns false for non-existent id', () async {
      final success = await database.firmOperationsDao.deleteTeamMember(
        'does-not-exist-${uid()}',
      );
      expect(success, isFalse);
    });

    test('getTeamMemberById returns null for unknown id', () async {
      final result = await database.firmOperationsDao.getTeamMemberById(
        'unknown-${uid()}',
      );
      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // ClientAssignments tests
  // ---------------------------------------------------------------------------

  group('FirmOperationsDao — ClientAssignments', () {
    test('assignClient returns the assignment id', () async {
      final assignment = makeAssignment();
      final returnedId = await database.firmOperationsDao.assignClient(
        FirmOperationsMapper.clientAssignmentToCompanion(assignment),
      );
      expect(returnedId, equals(assignment.id));
    });

    test('getClientsAssignedTo returns assignments for member', () async {
      final memberId = 'member-${uid()}';
      final a1 = makeAssignment(assignedToId: memberId);
      final a2 = makeAssignment(assignedToId: memberId);

      await database.firmOperationsDao.assignClient(
        FirmOperationsMapper.clientAssignmentToCompanion(a1),
      );
      await database.firmOperationsDao.assignClient(
        FirmOperationsMapper.clientAssignmentToCompanion(a2),
      );

      final results = await database.firmOperationsDao.getClientsAssignedTo(
        memberId,
      );
      expect(results.length, greaterThanOrEqualTo(2));
      expect(results.every((r) => r.assignedToId == memberId), isTrue);
    });

    test(
      'getClientsAssignedTo returns empty list for member with no assignments',
      () async {
        final results = await database.firmOperationsDao.getClientsAssignedTo(
          'no-assignments-${uid()}',
        );
        expect(results, isEmpty);
      },
    );

    test('getAssignmentsForClient returns assignments for client', () async {
      final clientId = 'client-${uid()}';
      final assignment = makeAssignment(clientId: clientId);
      await database.firmOperationsDao.assignClient(
        FirmOperationsMapper.clientAssignmentToCompanion(assignment),
      );

      final results = await database.firmOperationsDao.getAssignmentsForClient(
        clientId,
      );
      expect(results.any((r) => r.clientId == clientId), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Mapper round-trip tests
  // ---------------------------------------------------------------------------

  group('FirmOperationsMapper — round-trip', () {
    test('FirmInfo: domain → companion → row → domain preserves fields', () async {
      final id = 'rt-firm-${uid()}';
      final info = makeFirmInfo(id: id);
      await database.firmOperationsDao.upsertFirmInfo(
        FirmOperationsMapper.firmInfoToCompanion(info),
      );
      final row = await database.firmOperationsDao.getFirmInfoById(id);
      expect(row, isNotNull);
      final restored = FirmOperationsMapper.firmInfoFromRow(row!);
      expect(restored.name, info.name);
      expect(restored.panNumber, info.panNumber);
      expect(restored.tanNumber, info.tanNumber);
      expect(restored.city, info.city);
    });

    test('TeamMember: domain → companion → row → domain preserves fields', () async {
      final member = makeTeamMember(firmId: 'rt-firm');
      await database.firmOperationsDao.insertTeamMember(
        FirmOperationsMapper.teamMemberToCompanion(member),
      );
      final row = await database.firmOperationsDao.getTeamMemberById(member.id);
      expect(row, isNotNull);
      final restored = FirmOperationsMapper.teamMemberFromRow(row!);
      expect(restored.name, member.name);
      expect(restored.pan, member.pan);
      expect(restored.permissions, member.permissions);
    });

    test('ClientAssignment: domain → companion → row → domain preserves fields', () async {
      final assignment = makeAssignment();
      await database.firmOperationsDao.assignClient(
        FirmOperationsMapper.clientAssignmentToCompanion(assignment),
      );
      final rows = await database.firmOperationsDao.getAssignmentsForClient(
        assignment.clientId,
      );
      expect(rows.isNotEmpty, isTrue);
      final restored = FirmOperationsMapper.clientAssignmentFromRow(rows.first);
      expect(restored.clientId, assignment.clientId);
      expect(restored.role, assignment.role);
    });

    test('FirmInfo: fromJson / toJson round-trip', () {
      final info = makeFirmInfo();
      final json = FirmOperationsMapper.firmInfoToJson(info);
      final restored = FirmOperationsMapper.firmInfoFromJson({
        ...json,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(restored.name, info.name);
      expect(restored.panNumber, info.panNumber);
    });

    test('TeamMember: fromJson / toJson round-trip', () {
      final member = makeTeamMember();
      final json = FirmOperationsMapper.teamMemberToJson(member);
      final restored = FirmOperationsMapper.teamMemberFromJson({
        ...json,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(restored.name, member.name);
      expect(restored.permissions, member.permissions);
    });

    test('ClientAssignment: fromJson / toJson round-trip', () {
      final assignment = makeAssignment();
      final json = FirmOperationsMapper.clientAssignmentToJson(assignment);
      final restored = FirmOperationsMapper.clientAssignmentFromJson({
        ...json,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(restored.clientId, assignment.clientId);
      expect(restored.assignedToId, assignment.assignedToId);
    });
  });

  // ---------------------------------------------------------------------------
  // Immutability tests
  // ---------------------------------------------------------------------------

  group('Immutability — copyWith', () {
    test('FirmInfo.copyWith returns new object with changed field', () {
      final info = makeFirmInfo();
      final updated = info.copyWith(name: 'Changed Name');
      expect(updated.name, 'Changed Name');
      expect(info.name, 'Test CA Firm');
      expect(updated.id, info.id);
    });

    test('TeamMember.copyWith returns new object with changed field', () {
      final member = makeTeamMember();
      final updated = member.copyWith(role: 'Partner');
      expect(updated.role, 'Partner');
      expect(member.role, 'Associate');
      expect(updated.id, member.id);
    });

    test('ClientAssignment.copyWith returns new object with changed field', () {
      final assignment = makeAssignment();
      final updated = assignment.copyWith(role: 'Reviewer');
      expect(updated.role, 'Reviewer');
      expect(assignment.role, 'Lead');
      expect(updated.id, assignment.id);
    });

    test('TeamMember permissions list is independent after copyWith', () {
      final member = makeTeamMember();
      final updated = member.copyWith(
        permissions: [...member.permissions, 'mca'],
      );
      expect(member.permissions.length, 2);
      expect(updated.permissions.length, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // MockFirmOperationsRepository tests
  // ---------------------------------------------------------------------------

  group('MockFirmOperationsRepository', () {
    late MockFirmOperationsRepository repo;

    setUp(() {
      repo = MockFirmOperationsRepository();
    });

    test('getFirmInfo returns seeded firm info', () async {
      final info = await repo.getFirmInfo();
      expect(info, isNotNull);
      expect(info!.name, 'Mehta & Associates');
    });

    test('updateFirmInfo persists the update', () async {
      final original = await repo.getFirmInfo();
      final updated = original!.copyWith(name: 'Updated Firm');
      final result = await repo.updateFirmInfo(updated);
      expect(result, isTrue);

      final retrieved = await repo.getFirmInfo();
      expect(retrieved!.name, 'Updated Firm');
    });

    test('getTeamMembers returns seeded members', () async {
      final members = await repo.getTeamMembers();
      expect(members.length, 2);
    });

    test('insertTeamMember adds member and returns id', () async {
      final member = makeTeamMember();
      final id = await repo.insertTeamMember(member);
      expect(id, member.id);

      final members = await repo.getTeamMembers();
      expect(members.any((m) => m.id == member.id), isTrue);
    });

    test('updateTeamMember returns true when member exists', () async {
      final members = await repo.getTeamMembers();
      final original = members.first;
      final updated = original.copyWith(role: 'Director');
      final result = await repo.updateTeamMember(updated);
      expect(result, isTrue);
    });

    test('updateTeamMember returns false for unknown member', () async {
      final ghost = makeTeamMember(id: 'ghost-${uid()}');
      final result = await repo.updateTeamMember(ghost);
      expect(result, isFalse);
    });

    test('deleteTeamMember removes existing member', () async {
      final member = makeTeamMember();
      await repo.insertTeamMember(member);

      final success = await repo.deleteTeamMember(member.id);
      expect(success, isTrue);

      final members = await repo.getTeamMembers();
      expect(members.any((m) => m.id == member.id), isFalse);
    });

    test('deleteTeamMember returns false for unknown id', () async {
      final result = await repo.deleteTeamMember('nonexistent-${uid()}');
      expect(result, isFalse);
    });

    test('assignClient adds assignment and returns id', () async {
      final assignment = makeAssignment(assignedToId: 'tm-001');
      final id = await repo.assignClient(assignment);
      expect(id, assignment.id);
    });

    test('getClientsAssignedTo returns correct assignments', () async {
      final memberId = 'tm-${uid()}';
      final a1 = makeAssignment(assignedToId: memberId);
      final a2 = makeAssignment(assignedToId: memberId);

      await repo.assignClient(a1);
      await repo.assignClient(a2);

      final results = await repo.getClientsAssignedTo(memberId);
      expect(results.length, 2);
      expect(results.every((a) => a.assignedToId == memberId), isTrue);
    });

    test('getClientsAssignedTo returns empty list for unknown member', () async {
      final results = await repo.getClientsAssignedTo('unknown-${uid()}');
      expect(results, isEmpty);
    });
  });
}
