import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/traces/data/providers/traces_providers.dart';
import 'package:ca_app/features/traces/domain/models/traces_request.dart';

void main() {
  group('tracesRequestsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 5 mock TRACES requests', () {
      final requests = container.read(tracesRequestsProvider);
      expect(requests.length, 5);
    });

    test('all requests have non-empty ids', () {
      final requests = container.read(tracesRequestsProvider);
      expect(requests.every((r) => r.id.isNotEmpty), isTrue);
    });
  });

  group('challanStatusesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-empty challan statuses', () {
      final challans = container.read(challanStatusesProvider);
      expect(challans, isNotEmpty);
    });

    test('all challans have non-empty BSR codes', () {
      final challans = container.read(challanStatusesProvider);
      expect(challans.every((c) => c.bsrCode.isNotEmpty), isTrue);
    });
  });

  group('tdsDefaultsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-empty TDS defaults', () {
      final defaults = container.read(tdsDefaultsProvider);
      expect(defaults, isNotEmpty);
    });
  });

  group('form16RequestsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns only Form 16 / 16A requests', () {
      final form16 = container.read(form16RequestsProvider);
      expect(
        form16.every(
          (r) =>
              r.type == TracesRequestType.form16 ||
              r.type == TracesRequestType.form16A,
        ),
        isTrue,
      );
    });

    test('form16 requests are a subset of all requests', () {
      final all = container.read(tracesRequestsProvider);
      final form16 = container.read(form16RequestsProvider);
      expect(form16.length, lessThanOrEqualTo(all.length));
    });
  });

  group('unresolvedDefaultsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns only unresolved defaults', () {
      final unresolved = container.read(unresolvedDefaultsProvider);
      expect(unresolved.every((d) => !d.isResolved), isTrue);
    });
  });

  group('totalUnresolvedDemandProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-negative demand', () {
      final demand = container.read(totalUnresolvedDemandProvider);
      expect(demand, greaterThanOrEqualTo(0));
    });

    test('equals sum of unresolved default demands', () {
      final unresolved = container.read(unresolvedDefaultsProvider);
      final expected = unresolved.fold<int>(
        0,
        (s, d) => s + d.totalDemandPaise,
      );
      final actual = container.read(totalUnresolvedDemandProvider);
      expect(actual, expected);
    });
  });

  group('unverifiedChallanCountProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('count is non-negative', () {
      final count = container.read(unverifiedChallanCountProvider);
      expect(count, greaterThanOrEqualTo(0));
    });
  });
}
