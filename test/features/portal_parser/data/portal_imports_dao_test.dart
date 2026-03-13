import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';
import 'package:ca_app/features/portal_parser/data/mappers/portal_import_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  late int testCounter;

  setUpAll(() async {
    database = _createTestDatabase();
    testCounter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  group('PortalImportsDao', () {
    PortalImport createTestImport({
      String? id,
      String? clientId,
      ImportType? importType,
      DateTime? importDate,
      String? rawData,
      int? parsedRecords,
      ImportStatus? status,
      String? errorMessage,
      DateTime? createdAt,
    }) {
      testCounter++;
      return PortalImport(
        id: id ?? 'pi-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        importType: importType ?? ImportType.form26as,
        importDate: importDate ?? DateTime(2025, 7, 1),
        rawData: rawData,
        parsedRecords: parsedRecords,
        status: status ?? ImportStatus.pending,
        errorMessage: errorMessage,
        createdAt: createdAt ?? DateTime(2025, 7, 1),
      );
    }

    group('insertImport', () {
      test('inserts import and returns non-empty ID', () async {
        final import = createTestImport();
        final companion = PortalImportMapper.toCompanion(import);
        final id = await database.portalImportsDao.insertImport(companion);
        expect(id, isNotEmpty);
      });

      test('stored import has correct clientId', () async {
        final import = createTestImport();
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );
        final retrieved = await database.portalImportsDao.getById(import.id);
        expect(retrieved?.clientId, import.clientId);
      });

      test('stored import has correct importType', () async {
        final import = createTestImport(importType: ImportType.ais);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );
        final retrieved = await database.portalImportsDao.getById(import.id);
        final domain =
            retrieved != null ? PortalImportMapper.fromRow(retrieved) : null;
        expect(domain?.importType, ImportType.ais);
      });

      test('stored import has correct status', () async {
        final import = createTestImport(status: ImportStatus.completed);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );
        final retrieved = await database.portalImportsDao.getById(import.id);
        final domain =
            retrieved != null ? PortalImportMapper.fromRow(retrieved) : null;
        expect(domain?.status, ImportStatus.completed);
      });

      test('stored import preserves parsedRecords', () async {
        final import = createTestImport(parsedRecords: 42);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );
        final retrieved = await database.portalImportsDao.getById(import.id);
        expect(retrieved?.parsedRecords, 42);
      });

      test('stored import preserves errorMessage', () async {
        final import = createTestImport(
          status: ImportStatus.failed,
          errorMessage: 'Parse error: malformed JSON',
        );
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );
        final retrieved = await database.portalImportsDao.getById(import.id);
        expect(retrieved?.errorMessage, 'Parse error: malformed JSON');
      });
    });

    group('getByClient', () {
      test('returns imports for specific client', () async {
        final clientId = 'portal-client-a';
        final i1 = createTestImport(clientId: clientId);
        final i2 = createTestImport(clientId: clientId);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i1),
        );
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i2),
        );

        final results = await database.portalImportsDao.getByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.portalImportsDao.getByClient(
          'non-existent-portal-client',
        );
        expect(results, isEmpty);
      });

      test('filters imports by client correctly', () async {
        final clientA = 'portal-filter-ca-1';
        final clientB = 'portal-filter-cb-1';
        final i1 = createTestImport(clientId: clientA);
        final i2 = createTestImport(clientId: clientB);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i1),
        );
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i2),
        );

        final results = await database.portalImportsDao.getByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getByType', () {
      test('returns imports of specific type', () async {
        final i1 = createTestImport(importType: ImportType.tis);
        final i2 = createTestImport(importType: ImportType.tis);
        final i3 = createTestImport(importType: ImportType.bankStatement);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i1),
        );
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i2),
        );
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i3),
        );

        final results =
            await database.portalImportsDao.getByType(ImportType.tis.name);
        expect(results.length, greaterThanOrEqualTo(2));
        expect(
          results.every((r) => r.importType == ImportType.tis.name),
          isTrue,
        );
      });

      test('returns empty list for type with no imports', () async {
        final results = await database.portalImportsDao.getByType(
          ImportType.tracesStatement.name,
        );
        expect(results, isEmpty);
      });
    });

    group('getLatest', () {
      test('returns the most recent import for client and type', () async {
        final clientId = 'portal-latest-client-1';
        final i1 = createTestImport(
          clientId: clientId,
          importType: ImportType.form26as,
          importDate: DateTime(2025, 1, 1),
        );
        final i2 = createTestImport(
          clientId: clientId,
          importType: ImportType.form26as,
          importDate: DateTime(2025, 7, 1),
        );
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i1),
        );
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(i2),
        );

        final latest = await database.portalImportsDao.getLatest(
          clientId,
          ImportType.form26as.name,
        );
        expect(latest != null, isTrue);
        expect(latest?.id, i2.id);
      });

      test('returns null for non-existent client/type combination', () async {
        final latest = await database.portalImportsDao.getLatest(
          'non-existent-client',
          ImportType.ais.name,
        );
        expect(latest == null, isTrue);
      });
    });

    group('updateStatus', () {
      test('updates status from pending to completed', () async {
        final import = createTestImport(status: ImportStatus.pending);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );

        final success = await database.portalImportsDao.updateStatus(
          import.id,
          ImportStatus.completed.name,
          parsedRecords: 55,
        );
        expect(success, isTrue);

        final retrieved = await database.portalImportsDao.getById(import.id);
        final domain =
            retrieved != null ? PortalImportMapper.fromRow(retrieved) : null;
        expect(domain?.status, ImportStatus.completed);
        expect(domain?.parsedRecords, 55);
      });

      test('updates status to failed with errorMessage', () async {
        final import = createTestImport(status: ImportStatus.parsing);
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );

        await database.portalImportsDao.updateStatus(
          import.id,
          ImportStatus.failed.name,
          errorMessage: 'Invalid XML structure',
        );

        final retrieved = await database.portalImportsDao.getById(import.id);
        final domain =
            retrieved != null ? PortalImportMapper.fromRow(retrieved) : null;
        expect(domain?.status, ImportStatus.failed);
        expect(domain?.errorMessage, 'Invalid XML structure');
      });

      test('returns false for non-existent ID', () async {
        final success = await database.portalImportsDao.updateStatus(
          'non-existent-pi-id',
          ImportStatus.completed.name,
        );
        expect(success, isFalse);
      });
    });

    group('getById', () {
      test('retrieves import by ID', () async {
        final import = createTestImport();
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );

        final retrieved = await database.portalImportsDao.getById(import.id);
        expect(retrieved != null, isTrue);
        expect(retrieved?.id, import.id);
      });

      test('returns null for non-existent ID', () async {
        final retrieved =
            await database.portalImportsDao.getById('non-existent-portal-id');
        expect(retrieved == null, isTrue);
      });
    });

    group('watchByClient', () {
      test('emits imports for client on watch', () async {
        final import = createTestImport();
        await database.portalImportsDao.insertImport(
          PortalImportMapper.toCompanion(import),
        );

        final stream = database.portalImportsDao.watchByClient(import.clientId);
        expect(
          stream,
          emits(
            isA<List<PortalImportRow>>().having(
              (rows) => rows.isNotEmpty,
              'has imports',
              true,
            ),
          ),
        );
      });
    });

    group('Immutability', () {
      test('PortalImport has copyWith for immutable updates', () {
        final i1 = createTestImport();
        final i2 = i1.copyWith(status: ImportStatus.completed);

        expect(i1.status, ImportStatus.pending);
        expect(i2.status, ImportStatus.completed);
        expect(i1.id, i2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final i1 = createTestImport(
          importType: ImportType.ais,
          parsedRecords: 30,
        );
        final i2 = i1.copyWith(status: ImportStatus.parsing);

        expect(i2.clientId, i1.clientId);
        expect(i2.importType, ImportType.ais);
        expect(i2.parsedRecords, 30);
      });

      test('PortalImport equality is based on id', () {
        testCounter++;
        final i1 = PortalImport(
          id: 'same-pi-id',
          clientId: 'c1',
          importType: ImportType.form26as,
          importDate: DateTime(2025),
          status: ImportStatus.pending,
          createdAt: DateTime(2025),
        );
        final i2 = PortalImport(
          id: 'same-pi-id',
          clientId: 'c2',
          importType: ImportType.ais,
          importDate: DateTime(2024),
          status: ImportStatus.completed,
          createdAt: DateTime(2024),
        );
        expect(i1, equals(i2));
        expect(i1.hashCode, equals(i2.hashCode));
      });
    });
  });
}
