import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ca_gpt/domain/models/tax_query.dart';
import 'package:ca_app/features/ca_gpt/data/repositories/mock_ca_gpt_repository.dart';

void main() {
  group('MockCaGptRepository', () {
    late MockCaGptRepository repo;

    setUp(() {
      repo = MockCaGptRepository();
    });

    group('getAllQueries', () {
      test('returns seeded queries', () async {
        final all = await repo.getAllQueries();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAllQueries();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });

    group('getQueryById', () {
      test('returns query for valid ID', () async {
        final query = await repo.getQueryById('mock-query-001');
        expect(query, isNotNull);
        expect(query!.queryId, 'mock-query-001');
      });

      test('returns null for unknown ID', () async {
        final query = await repo.getQueryById('no-such-query');
        expect(query, isNull);
      });
    });

    group('getQueriesByType', () {
      test('returns only queries with the given type', () async {
        final sectionLookups = await repo.getQueriesByType(
          QueryType.sectionLookup,
        );
        expect(
          sectionLookups.every((q) => q.queryType == QueryType.sectionLookup),
          isTrue,
        );
      });

      test('returns empty list if no queries match type', () async {
        final results = await repo.getQueriesByType(QueryType.deadlineQuery);
        expect(results, isEmpty);
      });
    });

    group('insertQuery', () {
      test('inserts and returns new query ID', () async {
        final newQuery = TaxQuery(
          queryId: 'new-query-001',
          question: 'What is the TDS rate on professional fees?',
          queryType: QueryType.rateQuery,
          timestamp: DateTime(2026, 3, 10),
          financialYear: 2024,
        );
        final id = await repo.insertQuery(newQuery);
        expect(id, 'new-query-001');

        final fetched = await repo.getQueryById('new-query-001');
        expect(fetched, isNotNull);
        expect(fetched!.question, 'What is the TDS rate on professional fees?');
      });
    });

    group('updateQuery', () {
      test('updates existing query and returns true', () async {
        final existing = await repo.getQueryById('mock-query-001');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(question: 'Updated question text');
        final success = await repo.updateQuery(updated);
        expect(success, isTrue);

        final fetched = await repo.getQueryById('mock-query-001');
        expect(fetched!.question, 'Updated question text');
      });

      test('returns false for non-existent query', () async {
        final ghost = TaxQuery(
          queryId: 'ghost-query',
          question: 'Ghost question?',
          queryType: QueryType.complianceCheck,
          timestamp: DateTime(2026, 1, 1),
        );
        final success = await repo.updateQuery(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteQuery', () {
      test('deletes query and returns true', () async {
        final id = await repo.insertQuery(
          TaxQuery(
            queryId: 'to-delete-query',
            question: 'Delete me?',
            queryType: QueryType.noticeResponse,
            timestamp: DateTime(2026, 3, 1),
          ),
        );

        final success = await repo.deleteQuery(id);
        expect(success, isTrue);

        final fetched = await repo.getQueryById(id);
        expect(fetched, isNull);
      });

      test('returns false for non-existent query ID', () async {
        final success = await repo.deleteQuery('no-such-query');
        expect(success, isFalse);
      });
    });
  });
}
