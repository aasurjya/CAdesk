import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_compliance_data.dart';
import 'package:ca_app/features/sebi/data/mappers/sebi_mapper.dart';

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

  group('SebiDao', () {
    SebiComplianceData createTestCompliance({
      String? id,
      String? clientId,
      SebiType? complianceType,
      DateTime? dueDate,
      String? status,
      String? description,
      String? penalty,
    }) {
      testCounter++;
      return SebiComplianceData(
        id: id ?? 'sebi-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        complianceType: complianceType ?? SebiType.pit,
        dueDate: dueDate ?? DateTime(2025, 6, 30),
        status: status ?? 'pending',
        description: description,
        penalty: penalty,
      );
    }

    group('insertSebiCompliance', () {
      test('inserts record and returns non-empty ID', () async {
        final compliance = createTestCompliance();
        final id = await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );
        expect(id, isNotEmpty);
      });

      test('stored record has correct clientId', () async {
        final compliance = createTestCompliance(clientId: 'sebi-insert-client');
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );
        final rows = await database.sebiDao.getSebiComplianceByClient(
          'sebi-insert-client',
        );
        expect(rows.any((r) => r.id == compliance.id), isTrue);
      });

      test('stored record has correct complianceType', () async {
        final compliance = createTestCompliance(complianceType: SebiType.lodr);
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );
        final rows = await database.sebiDao.getSebiComplianceByClient(
          compliance.clientId,
        );
        final row = rows.firstWhere((r) => r.id == compliance.id);
        final domain = SebiMapper.fromRow(row);
        expect(domain.complianceType, SebiType.lodr);
      });

      test('stored record has correct status', () async {
        final compliance = createTestCompliance(status: 'filed');
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );
        final rows = await database.sebiDao.getSebiComplianceByClient(
          compliance.clientId,
        );
        final row = rows.firstWhere((r) => r.id == compliance.id);
        expect(row.status, 'filed');
      });

      test('stored record preserves description', () async {
        final compliance = createTestCompliance(
          description: 'Quarterly PIT disclosure',
        );
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );
        final rows = await database.sebiDao.getSebiComplianceByClient(
          compliance.clientId,
        );
        final row = rows.firstWhere((r) => r.id == compliance.id);
        expect(row.description, 'Quarterly PIT disclosure');
      });
    });

    group('getSebiComplianceByClient', () {
      test('returns records for specific client', () async {
        final clientId = 'sebi-by-client-x';
        final c1 = createTestCompliance(clientId: clientId);
        final c2 = createTestCompliance(clientId: clientId);
        await database.sebiDao.insertSebiCompliance(SebiMapper.toCompanion(c1));
        await database.sebiDao.insertSebiCompliance(SebiMapper.toCompanion(c2));

        final results = await database.sebiDao.getSebiComplianceByClient(
          clientId,
        );
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.sebiDao.getSebiComplianceByClient(
          'no-such-client',
        );
        expect(results, isEmpty);
      });

      test('filters records by client correctly', () async {
        final clientA = 'sebi-filter-a';
        final clientB = 'sebi-filter-b';
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(createTestCompliance(clientId: clientA)),
        );
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(createTestCompliance(clientId: clientB)),
        );

        final results = await database.sebiDao.getSebiComplianceByClient(
          clientA,
        );
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getSebiComplianceByType', () {
      test('returns records with matching compliance type', () async {
        final compliance = createTestCompliance(complianceType: SebiType.sast);
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );

        final results = await database.sebiDao.getSebiComplianceByType(
          SebiType.sast.name,
        );
        expect(results.any((r) => r.id == compliance.id), isTrue);
      });

      test('excludes records with different type', () async {
        final compliance = createTestCompliance(
          complianceType: SebiType.takeovers,
        );
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );

        final results = await database.sebiDao.getSebiComplianceByType(
          SebiType.pit.name,
        );
        expect(results.where((r) => r.id == compliance.id), isEmpty);
      });
    });

    group('getOverdueSebiCompliance', () {
      test('returns records past due date with pending status', () async {
        final past = DateTime.now().subtract(const Duration(days: 10));
        final compliance = createTestCompliance(
          dueDate: past,
          status: 'pending',
        );
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );

        final results = await database.sebiDao.getOverdueSebiCompliance();
        expect(results.any((r) => r.id == compliance.id), isTrue);
      });

      test('does not return future-dated records as overdue', () async {
        final future = DateTime.now().add(const Duration(days: 30));
        final compliance = createTestCompliance(
          dueDate: future,
          status: 'pending',
        );
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );

        final results = await database.sebiDao.getOverdueSebiCompliance();
        expect(results.where((r) => r.id == compliance.id), isEmpty);
      });

      test('does not return filed records as overdue', () async {
        final past = DateTime.now().subtract(const Duration(days: 5));
        final compliance = createTestCompliance(dueDate: past, status: 'filed');
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );

        final results = await database.sebiDao.getOverdueSebiCompliance();
        expect(results.where((r) => r.id == compliance.id), isEmpty);
      });

      test('does not return exempted records as overdue', () async {
        final past = DateTime.now().subtract(const Duration(days: 5));
        final compliance = createTestCompliance(
          dueDate: past,
          status: 'exempted',
        );
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );

        final results = await database.sebiDao.getOverdueSebiCompliance();
        expect(results.where((r) => r.id == compliance.id), isEmpty);
      });
    });

    group('updateSebiComplianceStatus', () {
      test('updates status from pending to filed', () async {
        final compliance = createTestCompliance(status: 'pending');
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );

        final success = await database.sebiDao.updateSebiComplianceStatus(
          compliance.id,
          'filed',
        );
        expect(success, isTrue);

        final rows = await database.sebiDao.getSebiComplianceByClient(
          compliance.clientId,
        );
        final updated = rows.firstWhere((r) => r.id == compliance.id);
        expect(updated.status, 'filed');
      });

      test('returns false for non-existent ID', () async {
        final success = await database.sebiDao.updateSebiComplianceStatus(
          'non-existent-id',
          'filed',
        );
        expect(success, isFalse);
      });

      test('updates status to overdue', () async {
        final compliance = createTestCompliance(status: 'pending');
        await database.sebiDao.insertSebiCompliance(
          SebiMapper.toCompanion(compliance),
        );
        await database.sebiDao.updateSebiComplianceStatus(
          compliance.id,
          'overdue',
        );

        final rows = await database.sebiDao.getSebiComplianceByClient(
          compliance.clientId,
        );
        final updated = rows.firstWhere((r) => r.id == compliance.id);
        expect(updated.status, 'overdue');
      });
    });

    group('Immutability', () {
      test('SebiComplianceData has copyWith for immutable updates', () {
        final c1 = createTestCompliance(status: 'pending');
        final c2 = c1.copyWith(status: 'filed');

        expect(c1.status, 'pending');
        expect(c2.status, 'filed');
        expect(c1.id, c2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final c1 = createTestCompliance(
          complianceType: SebiType.insiderTrading,
          description: 'Annual disclosure',
        );
        final c2 = c1.copyWith(status: 'filed');

        expect(c2.clientId, c1.clientId);
        expect(c2.complianceType, SebiType.insiderTrading);
        expect(c2.description, 'Annual disclosure');
      });

      test('SebiType enum round-trips through mapper', () {
        for (final type in SebiType.values) {
          final compliance = createTestCompliance(complianceType: type);
          final companion = SebiMapper.toCompanion(compliance);
          expect(companion.complianceType.value, type.name);
        }
      });
    });
  });
}
