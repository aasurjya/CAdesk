import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/feature_flags/flag_cache.dart';

void main() {
  group('FlagCache', () {
    group('isStale', () {
      test('is stale when never fetched', () {
        final cache = FlagCache();
        expect(cache.isStale, isTrue);
      });

      test('is not stale immediately after update', () {
        final cache = FlagCache();
        cache.update({'featureA': true});
        expect(cache.isStale, isFalse);
      });

      test('is stale after TTL expires', () async {
        final cache = FlagCache(ttl: const Duration(milliseconds: 50));
        cache.update({'featureA': true});
        expect(cache.isStale, isFalse);
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(cache.isStale, isTrue);
      });

      test('is stale after invalidate is called', () {
        final cache = FlagCache();
        cache.update({'featureA': true});
        expect(cache.isStale, isFalse);
        cache.invalidate();
        expect(cache.isStale, isTrue);
      });
    });

    group('update', () {
      test('stores flags and makes them retrievable', () {
        final cache = FlagCache();
        cache.update({'featureA': true, 'featureB': false});
        expect(cache.isEnabled('featureA'), isTrue);
        expect(cache.isEnabled('featureB'), isFalse);
      });

      test('replaces all flags on subsequent update', () {
        final cache = FlagCache();
        cache.update({'old': true, 'other': true});
        cache.update({'new': true});
        // old flag is gone
        expect(cache.isEnabled('old'), isFalse);
        expect(cache.isEnabled('new'), isTrue);
      });

      test('flags map is unmodifiable', () {
        final cache = FlagCache();
        cache.update({'x': true});
        expect(
          () => cache.flags['y'] = false,
          throwsA(isA<Error>()),
        );
      });

      test('empty update clears previous flags', () {
        final cache = FlagCache();
        cache.update({'featureA': true});
        cache.update({});
        expect(cache.flags, isEmpty);
      });
    });

    group('isEnabled', () {
      test('returns false for unknown flag', () {
        final cache = FlagCache();
        expect(cache.isEnabled('unknown'), isFalse);
      });

      test('returns true for enabled flag', () {
        final cache = FlagCache();
        cache.update({'featureA': true});
        expect(cache.isEnabled('featureA'), isTrue);
      });

      test('returns false for disabled flag', () {
        final cache = FlagCache();
        cache.update({'featureA': false});
        expect(cache.isEnabled('featureA'), isFalse);
      });
    });

    group('flags getter', () {
      test('returns copy of internal flags map', () {
        final cache = FlagCache();
        cache.update({'a': true, 'b': false});
        expect(cache.flags, {'a': true, 'b': false});
      });

      test('returns empty map when never updated', () {
        final cache = FlagCache();
        expect(cache.flags, isEmpty);
      });
    });

    group('invalidate', () {
      test('calling invalidate twice does not throw', () {
        final cache = FlagCache();
        cache.update({'x': true});
        cache.invalidate();
        expect(() => cache.invalidate(), returnsNormally);
      });

      test('flags remain accessible after invalidate', () {
        final cache = FlagCache();
        cache.update({'featureA': true});
        cache.invalidate();
        // Data is still accessible, only freshness is reset
        expect(cache.isEnabled('featureA'), isTrue);
        expect(cache.isStale, isTrue);
      });
    });

    group('custom TTL', () {
      test('uses provided TTL', () async {
        final cache = FlagCache(ttl: const Duration(milliseconds: 100));
        cache.update({'x': true});
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cache.isStale, isFalse);
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(cache.isStale, isTrue);
      });
    });
  });
}
