import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/clients/data/mappers/client_mapper.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';

void main() {
  group('ClientMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'client-001',
          'name': 'Rajesh Kumar Sharma',
          'pan': 'ABCPS1234A',
          'email': 'rajesh@example.com',
          'phone': '+91-9876543210',
          'alternate_phone': '+91-9876543211',
          'client_type': 'individual',
          'date_of_birth': '1985-03-15',
          'address': '123 Main Street',
          'city': 'Mumbai',
          'state': 'Maharashtra',
          'pincode': '400001',
          'gstin': '27ABCPS1234A1Z5',
          'tan': 'MUMR12345A',
          'services_availed': ['itrFiling', 'gstFiling'],
          'status': 'active',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2026-03-01T00:00:00.000Z',
          'notes': 'Priority client',
        };
        final client = ClientMapper.fromJson(json);

        expect(client.id, 'client-001');
        expect(client.name, 'Rajesh Kumar Sharma');
        expect(client.pan, 'ABCPS1234A');
        expect(client.email, 'rajesh@example.com');
        expect(client.phone, '+91-9876543210');
        expect(client.alternatePhone, '+91-9876543211');
        expect(client.clientType, ClientType.individual);
        expect(client.dateOfBirth, DateTime(1985, 3, 15));
        expect(client.address, '123 Main Street');
        expect(client.city, 'Mumbai');
        expect(client.state, 'Maharashtra');
        expect(client.pincode, '400001');
        expect(client.gstin, '27ABCPS1234A1Z5');
        expect(client.tan, 'MUMR12345A');
        expect(
          client.servicesAvailed,
          containsAll([ServiceType.itrFiling, ServiceType.gstFiling]),
        );
        expect(client.status, ClientStatus.active);
        expect(client.notes, 'Priority client');
      });

      test('handles nullable fields as null', () {
        final json = {
          'id': 'client-002',
          'name': 'Mehta & Sons',
          'pan': 'AABFM3456H',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2026-03-01T00:00:00.000Z',
        };
        final client = ClientMapper.fromJson(json);

        expect(client.email, isNull);
        expect(client.phone, isNull);
        expect(client.alternatePhone, isNull);
        expect(client.dateOfBirth, isNull);
        expect(client.dateOfIncorporation, isNull);
        expect(client.address, isNull);
        expect(client.city, isNull);
        expect(client.state, isNull);
        expect(client.pincode, isNull);
        expect(client.gstin, isNull);
        expect(client.tan, isNull);
        expect(client.notes, isNull);
      });

      test('defaults client_type to individual for unknown value', () {
        final json = {
          'id': 'client-003',
          'name': 'Unknown Type Client',
          'pan': 'XXXXX1234X',
          'client_type': 'unknownType',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };
        final client = ClientMapper.fromJson(json);
        expect(client.clientType, ClientType.individual);
      });

      test('defaults status to active for unknown value', () {
        final json = {
          'id': 'client-004',
          'name': 'Test',
          'pan': 'XXXXX1234X',
          'status': 'unknownStatus',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };
        final client = ClientMapper.fromJson(json);
        expect(client.status, ClientStatus.active);
      });

      test('ignores unknown service types gracefully', () {
        final json = {
          'id': 'client-005',
          'name': 'Test',
          'pan': 'XXXXX1234X',
          'services_availed': ['itrFiling', 'unknownService', 'audit'],
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };
        final client = ClientMapper.fromJson(json);
        expect(client.servicesAvailed.length, 2);
        expect(
          client.servicesAvailed,
          containsAll([ServiceType.itrFiling, ServiceType.audit]),
        );
      });

      test('handles null services_availed as empty list', () {
        final json = {
          'id': 'client-006',
          'name': 'Test',
          'pan': 'XXXXX1234X',
          'services_availed': null,
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };
        final client = ClientMapper.fromJson(json);
        expect(client.servicesAvailed, isEmpty);
      });

      test('handles services_availed as non-List gracefully', () {
        final json = {
          'id': 'client-007',
          'name': 'Test',
          'pan': 'XXXXX1234X',
          'services_availed': 'notAList',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };
        final client = ClientMapper.fromJson(json);
        expect(client.servicesAvailed, isEmpty);
      });

      test('parses date_of_incorporation for companies', () {
        final json = {
          'id': 'client-008',
          'name': 'ABC Pvt Ltd',
          'pan': 'AABCA1234B',
          'client_type': 'company',
          'date_of_incorporation': '2010-06-15',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };
        final client = ClientMapper.fromJson(json);
        expect(client.dateOfIncorporation, DateTime(2010, 6, 15));
        expect(client.clientType, ClientType.company);
      });

      test('handles all ClientType values', () {
        for (final type in ClientType.values) {
          final json = {
            'id': 'client-type-${type.name}',
            'name': 'Test',
            'pan': 'XXXXX1234X',
            'client_type': type.name,
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          };
          final client = ClientMapper.fromJson(json);
          expect(client.clientType, type);
        }
      });

      test('handles all ClientStatus values', () {
        for (final status in ClientStatus.values) {
          final json = {
            'id': 'client-status-${status.name}',
            'name': 'Test',
            'pan': 'XXXXX1234X',
            'status': status.name,
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          };
          final client = ClientMapper.fromJson(json);
          expect(client.status, status);
        }
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late Client sampleClient;

      setUp(() {
        sampleClient = Client(
          id: 'client-json-001',
          name: 'Priya Nair',
          pan: 'CNPPN5678P',
          email: 'priya@example.com',
          phone: '+91-9123456789',
          clientType: ClientType.individual,
          dateOfBirth: DateTime(1990, 5, 20),
          address: '456 Park Avenue',
          city: 'Bangalore',
          state: 'Karnataka',
          pincode: '560001',
          gstin: null,
          tan: null,
          servicesAvailed: const [ServiceType.itrFiling, ServiceType.tds],
          status: ClientStatus.active,
          createdAt: DateTime(2025, 6, 1),
          updatedAt: DateTime(2026, 3, 1),
          notes: 'New client',
        );
      });

      test('includes all core fields', () {
        final json = ClientMapper.toJson(sampleClient);
        expect(json['id'], 'client-json-001');
        expect(json['name'], 'Priya Nair');
        expect(json['pan'], 'CNPPN5678P');
        expect(json['email'], 'priya@example.com');
        expect(json['phone'], '+91-9123456789');
        expect(json['client_type'], 'individual');
        expect(json['status'], 'active');
      });

      test('serializes services_availed as list of strings', () {
        final json = ClientMapper.toJson(sampleClient);
        expect(json['services_availed'], containsAll(['itrFiling', 'tds']));
      });

      test('serializes date_of_birth as ISO string', () {
        final json = ClientMapper.toJson(sampleClient);
        expect(json['date_of_birth'], startsWith('1990-05-20'));
      });

      test('serializes null fields as null', () {
        final json = ClientMapper.toJson(sampleClient);
        expect(json['gstin'], isNull);
        expect(json['tan'], isNull);
        expect(json['alternate_phone'], isNull);
      });

      test('does not include aadhaar_hash when aadhaar is null', () {
        final json = ClientMapper.toJson(sampleClient);
        expect(json.containsKey('aadhaar_hash'), isFalse);
      });

      test('includes aadhaar_hash when aadhaar is provided', () {
        final clientWithAadhaar = sampleClient.copyWith(
          aadhaar: '9999 8888 7777',
        );
        final json = ClientMapper.toJson(clientWithAadhaar);
        expect(json.containsKey('aadhaar_hash'), isTrue);
        expect(json['aadhaar_hash'], isA<String>());
        // Hash should be 64 chars (SHA-256 hex)
        expect(json['aadhaar_hash'].toString().length, 64);
      });

      test('aadhaar hash strips spaces before hashing', () {
        final client1 = sampleClient.copyWith(aadhaar: '9999 8888 7777');
        final client2 = sampleClient.copyWith(aadhaar: '999988887777');
        final json1 = ClientMapper.toJson(client1);
        final json2 = ClientMapper.toJson(client2);
        // Both should produce the same hash
        expect(json1['aadhaar_hash'], json2['aadhaar_hash']);
      });
    });

    // -------------------------------------------------------------------------
    // Client model computed properties
    // -------------------------------------------------------------------------
    group('Client model computed properties', () {
      test('initials returns first two letters of single-word name', () {
        final client = Client(
          id: 'c1',
          name: 'Priya',
          pan: 'XXXXX1234X',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(client.initials, 'PR');
      });

      test('initials returns first letter of first and last name', () {
        final client = Client(
          id: 'c2',
          name: 'Rajesh Kumar Sharma',
          pan: 'XXXXX1234X',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(client.initials, 'RS');
      });

      test('fullAddress concatenates non-null address parts', () {
        final client = Client(
          id: 'c3',
          name: 'Test',
          pan: 'XXXXX1234X',
          address: '123 Main St',
          city: 'Mumbai',
          state: 'Maharashtra',
          pincode: '400001',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(client.fullAddress, '123 Main St, Mumbai, Maharashtra, 400001');
      });

      test('fullAddress skips null parts', () {
        final client = Client(
          id: 'c4',
          name: 'Test',
          pan: 'XXXXX1234X',
          city: 'Delhi',
          state: 'Delhi',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(client.fullAddress, 'Delhi, Delhi');
      });

      test('equality is based on id', () {
        final a = Client(
          id: 'same-id',
          name: 'Client A',
          pan: 'XXXXX1234X',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final b = a.copyWith(name: 'Client B');
        expect(a, equals(b));
      });

      test('hashCode is based on id', () {
        final client = Client(
          id: 'hash-id',
          name: 'Test',
          pan: 'XXXXX1234X',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(client.hashCode, 'hash-id'.hashCode);
      });
    });
  });
}
