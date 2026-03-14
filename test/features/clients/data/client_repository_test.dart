import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/clients/data/repositories/mock_client_repository.dart';

void main() {
  group('MockClientRepository', () {
    late MockClientRepository repo;

    setUp(() {
      repo = MockClientRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    group('getAll', () {
      test('returns all seeded clients', () async {
        final all = await repo.getAll();
        expect(all.length, greaterThanOrEqualTo(5));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAll();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });

    group('getById', () {
      test('returns client for valid ID', () async {
        final client = await repo.getById('1');
        expect(client, isNotNull);
        expect(client!.id, '1');
        expect(client.name, 'Rajesh Kumar Sharma');
      });

      test('returns null for unknown ID', () async {
        final client = await repo.getById('no-such-id');
        expect(client, isNull);
      });
    });

    group('create', () {
      test('creates client and returns it', () async {
        final newClient = Client(
          id: 'new-client-001',
          name: 'New Test Client',
          pan: 'ZZZZZ9999Z',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime(2026, 3, 1),
          updatedAt: DateTime(2026, 3, 1),
        );

        final created = await repo.create(newClient);
        expect(created.id, 'new-client-001');
        expect(created.name, 'New Test Client');

        final fetched = await repo.getById('new-client-001');
        expect(fetched, isNotNull);
        expect(fetched!.pan, 'ZZZZZ9999Z');
      });
    });

    group('update', () {
      test('updates existing client and returns updated client', () async {
        final existing = await repo.getById('1');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(status: ClientStatus.inactive);
        final result = await repo.update(updated);
        expect(result.status, ClientStatus.inactive);

        final fetched = await repo.getById('1');
        expect(fetched!.status, ClientStatus.inactive);
      });

      test('throws StateError for non-existent client', () async {
        final ghost = Client(
          id: 'ghost-client',
          name: 'Ghost',
          pan: 'GHOST1234G',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        expect(() => repo.update(ghost), throwsA(isA<StateError>()));
      });
    });

    group('delete', () {
      test('deletes client so it no longer appears in getById', () async {
        final created = await repo.create(
          Client(
            id: 'client-to-delete',
            name: 'Delete Me',
            pan: 'DELET1234D',
            clientType: ClientType.individual,
            status: ClientStatus.active,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

        await repo.delete(created.id);
        final fetched = await repo.getById('client-to-delete');
        expect(fetched, isNull);
      });

      test('delete on non-existent ID does not throw', () async {
        await expectLater(repo.delete('no-such-client'), completes);
      });
    });

    group('search', () {
      test('finds client by name substring (case-insensitive)', () async {
        final results = await repo.search('rajesh');
        expect(results, isNotEmpty);
        expect(
          results.any((c) => c.name.toLowerCase().contains('rajesh')),
          isTrue,
        );
      });

      test('finds client by PAN substring', () async {
        final results = await repo.search('ABCPS1234A');
        expect(results, isNotEmpty);
        expect(results.first.pan, 'ABCPS1234A');
      });

      test('finds client by email substring', () async {
        final results = await repo.search('priya.mehta');
        expect(results, isNotEmpty);
        expect(
          results.any((c) => c.email?.contains('priya.mehta') ?? false),
          isTrue,
        );
      });

      test('returns empty list for unknown query', () async {
        final results = await repo.search('xyznonexistent12345');
        expect(results, isEmpty);
      });
    });

    group('watchAll', () {
      test('emits a list after create', () async {
        final stream = repo.watchAll();
        final future = stream.first;

        await repo.create(
          Client(
            id: 'client-stream-test',
            name: 'Stream Client',
            pan: 'STREA1234S',
            clientType: ClientType.company,
            status: ClientStatus.active,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

        final emitted = await future;
        expect(emitted.any((c) => c.id == 'client-stream-test'), isTrue);
      });

      test('emits a list after delete', () async {
        final stream = repo.watchAll();
        final future = stream.first;

        await repo.delete('1');

        final emitted = await future;
        expect(emitted.any((c) => c.id == '1'), isFalse);
      });
    });
  });
}
