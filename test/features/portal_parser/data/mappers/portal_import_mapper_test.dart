import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_parser/data/mappers/portal_import_mapper.dart';
import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';

void main() {
  group('PortalImportMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'pi-001',
          'client_id': 'client-001',
          'import_type': 'form26as',
          'import_date': '2025-09-01T10:00:00.000Z',
          'raw_data': '<xml>form26as data</xml>',
          'parsed_records': 152,
          'status': 'completed',
          'error_message': null,
          'created_at': '2025-09-01T10:00:00.000Z',
        };

        final portalImport = PortalImportMapper.fromJson(json);

        expect(portalImport.id, 'pi-001');
        expect(portalImport.clientId, 'client-001');
        expect(portalImport.importType, ImportType.form26as);
        expect(portalImport.rawData, '<xml>form26as data</xml>');
        expect(portalImport.parsedRecords, 152);
        expect(portalImport.status, ImportStatus.completed);
        expect(portalImport.errorMessage, isNull);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'pi-002',
          'client_id': 'client-002',
          'import_type': 'ais',
          'import_date': '2025-09-01T10:00:00.000Z',
          'status': 'pending',
          'created_at': '2025-09-01T10:00:00.000Z',
        };

        final portalImport = PortalImportMapper.fromJson(json);
        expect(portalImport.rawData, isNull);
        expect(portalImport.parsedRecords, isNull);
        expect(portalImport.errorMessage, isNull);
      });

      test('handles failed import with error message', () {
        final json = {
          'id': 'pi-003',
          'client_id': 'c1',
          'import_type': 'tracesStatement',
          'import_date': '2025-09-01T10:00:00.000Z',
          'status': 'failed',
          'error_message': 'Invalid file format',
          'created_at': '2025-09-01T10:00:00.000Z',
        };

        final portalImport = PortalImportMapper.fromJson(json);
        expect(portalImport.status, ImportStatus.failed);
        expect(portalImport.errorMessage, 'Invalid file format');
      });

      test('defaults import_type to form26as for unknown value', () {
        final json = {
          'id': 'pi-004',
          'client_id': 'c1',
          'import_type': 'unknownType',
          'import_date': '2025-09-01T10:00:00.000Z',
          'status': 'pending',
          'created_at': '2025-09-01T10:00:00.000Z',
        };

        final portalImport = PortalImportMapper.fromJson(json);
        expect(portalImport.importType, ImportType.form26as);
      });

      test('defaults status to pending for unknown value', () {
        final json = {
          'id': 'pi-005',
          'client_id': 'c1',
          'import_type': 'ais',
          'import_date': '2025-09-01T10:00:00.000Z',
          'status': 'unknownStatus',
          'created_at': '2025-09-01T10:00:00.000Z',
        };

        final portalImport = PortalImportMapper.fromJson(json);
        expect(portalImport.status, ImportStatus.pending);
      });

      test('handles all ImportType values', () {
        for (final importType in ImportType.values) {
          final json = {
            'id': 'pi-type-${importType.name}',
            'client_id': 'c1',
            'import_type': importType.name,
            'import_date': '2025-09-01T10:00:00.000Z',
            'status': 'pending',
            'created_at': '2025-09-01T10:00:00.000Z',
          };
          final portalImport = PortalImportMapper.fromJson(json);
          expect(portalImport.importType, importType);
        }
      });

      test('handles all ImportStatus values', () {
        for (final status in ImportStatus.values) {
          final json = {
            'id': 'pi-status-${status.name}',
            'client_id': 'c1',
            'import_type': 'ais',
            'import_date': '2025-09-01T10:00:00.000Z',
            'status': status.name,
            'created_at': '2025-09-01T10:00:00.000Z',
          };
          final portalImport = PortalImportMapper.fromJson(json);
          expect(portalImport.status, status);
        }
      });
    });

    group('toJson', () {
      late PortalImport sampleImport;

      setUp(() {
        sampleImport = PortalImport(
          id: 'pi-json-001',
          clientId: 'client-json-001',
          importType: ImportType.tis,
          importDate: DateTime(2025, 9, 5),
          rawData: '<xml>tis data</xml>',
          parsedRecords: 87,
          status: ImportStatus.completed,
          createdAt: DateTime(2025, 9, 5),
        );
      });

      test('includes all fields', () {
        final json = PortalImportMapper.toJson(sampleImport);

        expect(json['id'], 'pi-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['import_type'], 'tis');
        expect(json['raw_data'], '<xml>tis data</xml>');
        expect(json['parsed_records'], 87);
        expect(json['status'], 'completed');
        expect(json['error_message'], isNull);
      });

      test('serializes import_date as ISO string', () {
        final json = PortalImportMapper.toJson(sampleImport);
        expect(json['import_date'], startsWith('2025-09-05'));
      });

      test('serializes null raw_data and error_message as null', () {
        final pendingImport = PortalImport(
          id: 'pi-pending',
          clientId: 'c1',
          importType: ImportType.bankStatement,
          importDate: DateTime(2025, 9, 1),
          status: ImportStatus.pending,
          createdAt: DateTime(2025, 9, 1),
        );
        final json = PortalImportMapper.toJson(pendingImport);
        expect(json['raw_data'], isNull);
        expect(json['parsed_records'], isNull);
        expect(json['error_message'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = PortalImportMapper.toJson(sampleImport);
        json['created_at'] = sampleImport.createdAt.toIso8601String();

        final restored = PortalImportMapper.fromJson(json);

        expect(restored.id, sampleImport.id);
        expect(restored.clientId, sampleImport.clientId);
        expect(restored.importType, sampleImport.importType);
        expect(restored.rawData, sampleImport.rawData);
        expect(restored.parsedRecords, sampleImport.parsedRecords);
        expect(restored.status, sampleImport.status);
      });

      test('handles zero parsed_records', () {
        final emptyImport = sampleImport.copyWith(parsedRecords: 0);
        final json = PortalImportMapper.toJson(emptyImport);
        expect(json['parsed_records'], 0);
      });
    });
  });
}
