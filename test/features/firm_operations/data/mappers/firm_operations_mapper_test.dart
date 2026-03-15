import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/firm_operations/data/mappers/firm_operations_mapper.dart';
import 'package:ca_app/features/firm_operations/domain/models/firm_info.dart';
import 'package:ca_app/features/firm_operations/domain/models/team_member.dart';
import 'package:ca_app/features/firm_operations/domain/models/client_assignment.dart';

void main() {
  group('FirmOperationsMapper', () {
    // -------------------------------------------------------------------------
    // FirmInfo
    // -------------------------------------------------------------------------
    group('firmInfoFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'firm-001',
          'name': 'Mehta & Associates',
          'address': '123 MG Road, Mumbai',
          'pan_number': 'METAP1234A',
          'tan_number': 'MUMB12345A',
          'city': 'Mumbai',
          'state': 'Maharashtra',
          'pincode': '400001',
          'bank_account': 'HDFC1234567890',
          'registration_date': '2010-01-15T00:00:00.000Z',
        };

        final info = FirmOperationsMapper.firmInfoFromJson(json);

        expect(info.id, 'firm-001');
        expect(info.name, 'Mehta & Associates');
        expect(info.address, '123 MG Road, Mumbai');
        expect(info.panNumber, 'METAP1234A');
        expect(info.tanNumber, 'MUMB12345A');
        expect(info.city, 'Mumbai');
        expect(info.state, 'Maharashtra');
        expect(info.pincode, '400001');
        expect(info.bankAccount, 'HDFC1234567890');
        expect(info.registrationDate, isNotNull);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'firm-002',
          'name': 'Simple Firm',
          'address': '456 Park Street',
          'pan_number': 'SIMPP1234B',
          'tan_number': 'KOLB12345B',
        };

        final info = FirmOperationsMapper.firmInfoFromJson(json);
        expect(info.city, isNull);
        expect(info.state, isNull);
        expect(info.pincode, isNull);
        expect(info.bankAccount, isNull);
        expect(info.registrationDate, isNull);
      });
    });

    group('firmInfoToJson', () {
      test('includes all fields and round-trips correctly', () {
        const info = FirmInfo(
          id: 'firm-json-001',
          name: 'Sharma & Co',
          address: 'Delhi NCR',
          panNumber: 'SHAMP1234C',
          tanNumber: 'DELH12345C',
          city: 'Delhi',
          state: 'Delhi',
          pincode: '110001',
        );

        final json = FirmOperationsMapper.firmInfoToJson(info);

        expect(json['id'], 'firm-json-001');
        expect(json['name'], 'Sharma & Co');
        expect(json['pan_number'], 'SHAMP1234C');
        expect(json['tan_number'], 'DELH12345C');
        expect(json['city'], 'Delhi');
        expect(json['pincode'], '110001');
        expect(json['registration_date'], isNull);

        final restored = FirmOperationsMapper.firmInfoFromJson(json);
        expect(restored.id, info.id);
        expect(restored.name, info.name);
        expect(restored.panNumber, info.panNumber);
      });
    });

    // -------------------------------------------------------------------------
    // TeamMember
    // -------------------------------------------------------------------------
    group('teamMemberFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'tm-001',
          'firm_id': 'firm-001',
          'name': 'Ankit Sharma',
          'pan': 'ANKTS1234A',
          'role': 'Senior Associate',
          'email': 'ankit@firm.com',
          'phone': '9876543210',
          'permissions': ['gst', 'tds', 'audit'],
        };

        final member = FirmOperationsMapper.teamMemberFromJson(json);

        expect(member.id, 'tm-001');
        expect(member.firmId, 'firm-001');
        expect(member.name, 'Ankit Sharma');
        expect(member.pan, 'ANKTS1234A');
        expect(member.role, 'Senior Associate');
        expect(member.email, 'ankit@firm.com');
        expect(member.phone, '9876543210');
        expect(member.permissions, ['gst', 'tds', 'audit']);
      });

      test('handles null optional fields and empty permissions', () {
        final json = {
          'id': 'tm-002',
          'firm_id': 'firm-001',
          'name': 'Staff Member',
          'pan': 'STAFFP1234B',
        };

        final member = FirmOperationsMapper.teamMemberFromJson(json);
        expect(member.role, isNull);
        expect(member.email, isNull);
        expect(member.phone, isNull);
        expect(member.permissions, isEmpty);
      });

      test('parses JSON-encoded permissions string', () {
        final json = {
          'id': 'tm-003',
          'firm_id': 'firm-001',
          'name': 'Test User',
          'pan': 'TESTP1234C',
          'permissions': '["itr","gst"]',
        };

        final member = FirmOperationsMapper.teamMemberFromJson(json);
        expect(member.permissions, ['itr', 'gst']);
      });
    });

    group('teamMemberToJson', () {
      test('includes all fields and round-trips correctly', () {
        const member = TeamMember(
          id: 'tm-json-001',
          firmId: 'firm-json-001',
          name: 'CA Principal',
          pan: 'CAPRI1234D',
          role: 'Partner',
          email: 'principal@firm.com',
          phone: '9988776655',
          permissions: ['admin', 'all'],
        );

        final json = FirmOperationsMapper.teamMemberToJson(member);

        expect(json['id'], 'tm-json-001');
        expect(json['firm_id'], 'firm-json-001');
        expect(json['name'], 'CA Principal');
        expect(json['pan'], 'CAPRI1234D');
        expect(json['role'], 'Partner');
        expect(json['permissions'], ['admin', 'all']);

        final restored = FirmOperationsMapper.teamMemberFromJson(json);
        expect(restored.id, member.id);
        expect(restored.name, member.name);
        expect(restored.permissions, member.permissions);
      });
    });

    // -------------------------------------------------------------------------
    // ClientAssignment
    // -------------------------------------------------------------------------
    group('clientAssignmentFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'ca-001',
          'client_id': 'client-001',
          'assigned_to_id': 'tm-001',
          'start_date': '2025-04-01T00:00:00.000Z',
          'end_date': '2026-03-31T00:00:00.000Z',
          'role': 'Primary Handler',
        };

        final assignment = FirmOperationsMapper.clientAssignmentFromJson(json);

        expect(assignment.id, 'ca-001');
        expect(assignment.clientId, 'client-001');
        expect(assignment.assignedToId, 'tm-001');
        expect(assignment.startDate, isNotNull);
        expect(assignment.endDate, isNotNull);
        expect(assignment.role, 'Primary Handler');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'ca-002',
          'client_id': 'client-002',
        };

        final assignment = FirmOperationsMapper.clientAssignmentFromJson(json);
        expect(assignment.assignedToId, isNull);
        expect(assignment.startDate, isNull);
        expect(assignment.endDate, isNull);
        expect(assignment.role, isNull);
      });
    });

    group('clientAssignmentToJson', () {
      test('includes all fields and round-trips correctly', () {
        final assignment = ClientAssignment(
          id: 'ca-json-001',
          clientId: 'client-json-001',
          assignedToId: 'tm-json-001',
          startDate: DateTime.utc(2025, 4, 1),
          endDate: DateTime.utc(2026, 3, 31),
          role: 'Audit Handler',
        );

        final json = FirmOperationsMapper.clientAssignmentToJson(assignment);

        expect(json['id'], 'ca-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['assigned_to_id'], 'tm-json-001');
        expect(json['role'], 'Audit Handler');
        expect(json['start_date'], isNotNull);

        final restored = FirmOperationsMapper.clientAssignmentFromJson(json);
        expect(restored.id, assignment.id);
        expect(restored.clientId, assignment.clientId);
        expect(restored.assignedToId, assignment.assignedToId);
      });
    });
  });
}
