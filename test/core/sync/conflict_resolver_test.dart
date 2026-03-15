import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = const ConflictResolver();
    });

    group('resolve — server-wins strategy', () {
      test('returns server payload when local and server differ', () {
        final local = {'id': '1', 'name': 'Local Name', 'updatedAt': '2026-01-01'};
        final server = {'id': '1', 'name': 'Server Name', 'updatedAt': '2026-01-02'};

        final result = resolver.resolve(
          localPayload: local,
          serverPayload: server,
        );

        expect(result.resolvedPayload, equals(server));
        expect(result.strategy, ResolutionStrategy.serverWins);
      });

      test('returns server payload even when local is newer by convention', () {
        final local = {
          'id': 'abc',
          'value': 'local-only',
          'updatedAt': '2026-03-15',
        };
        final server = {
          'id': 'abc',
          'value': 'server-value',
          'updatedAt': '2025-12-31',
        };

        final result = resolver.resolve(
          localPayload: local,
          serverPayload: server,
        );

        expect(result.resolvedPayload, equals(server));
        expect(result.resolvedPayload['value'], 'server-value');
      });

      test('resolved payload is identical to server payload reference', () {
        final server = {'key': 'value'};

        final result = resolver.resolve(
          localPayload: {'key': 'other'},
          serverPayload: server,
        );

        expect(result.resolvedPayload, same(server));
      });

      test('handles empty payloads without throwing', () {
        final result = resolver.resolve(
          localPayload: {},
          serverPayload: {},
        );

        expect(result.resolvedPayload, isEmpty);
        expect(result.strategy, ResolutionStrategy.serverWins);
      });

      test('handles nested payloads — server wins entire structure', () {
        final local = {
          'id': '99',
          'data': {'nested': 'local'},
        };
        final server = {
          'id': '99',
          'data': {'nested': 'server'},
        };

        final result = resolver.resolve(
          localPayload: local,
          serverPayload: server,
        );

        expect((result.resolvedPayload['data'] as Map)['nested'], 'server');
      });

      test('strategy is always serverWins (not localWins or manual)', () {
        final result = resolver.resolve(
          localPayload: {'a': 1},
          serverPayload: {'a': 2},
        );

        expect(result.strategy, isNot(ResolutionStrategy.localWins));
        expect(result.strategy, isNot(ResolutionStrategy.manual));
      });
    });
  });

  group('ConflictResolution', () {
    test('stores resolved payload and strategy immutably', () {
      const resolution = ConflictResolution(
        resolvedPayload: {'id': '1'},
        strategy: ResolutionStrategy.serverWins,
      );

      expect(resolution.resolvedPayload, {'id': '1'});
      expect(resolution.strategy, ResolutionStrategy.serverWins);
    });

    test('const constructor works with all strategy values', () {
      for (final strategy in ResolutionStrategy.values) {
        final r = ConflictResolution(
          resolvedPayload: const {},
          strategy: strategy,
        );
        expect(r.strategy, strategy);
      }
    });
  });

  group('ResolutionStrategy enum', () {
    test('contains exactly three values', () {
      expect(ResolutionStrategy.values.length, 3);
    });

    test('all expected strategies are present', () {
      expect(ResolutionStrategy.values, contains(ResolutionStrategy.serverWins));
      expect(ResolutionStrategy.values, contains(ResolutionStrategy.localWins));
      expect(ResolutionStrategy.values, contains(ResolutionStrategy.manual));
    });
  });
}
