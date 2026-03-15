import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/regulatory_trust/data/providers/regulatory_trust_providers.dart';
import 'package:ca_app/features/regulatory_trust/domain/models/security_control.dart';

void main() {
  group('regulatoryControlsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 8 mock security controls', () {
      final controls = container.read(regulatoryControlsProvider);
      expect(controls.length, 8);
    });

    test('all controls have non-empty ids', () {
      final controls = container.read(regulatoryControlsProvider);
      expect(controls.every((c) => c.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final controls = container.read(regulatoryControlsProvider);
      expect(() => (controls as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('vaptScansProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 4 VAPT scans', () {
      final scans = container.read(vaptScansProvider);
      expect(scans.length, 4);
    });

    test('all scans have non-empty ids', () {
      final scans = container.read(vaptScansProvider);
      expect(scans.every((s) => s.id.isNotEmpty), isTrue);
    });
  });

  group('ControlStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(controlStatusFilterProvider), isNull);
    });

    test('can be set to compliant', () {
      container
          .read(controlStatusFilterProvider.notifier)
          .update(SecurityControlStatus.compliant);
      expect(
        container.read(controlStatusFilterProvider),
        SecurityControlStatus.compliant,
      );
    });

    test('can be reset to null', () {
      container
          .read(controlStatusFilterProvider.notifier)
          .update(SecurityControlStatus.nonCompliant);
      container.read(controlStatusFilterProvider.notifier).update(null);
      expect(container.read(controlStatusFilterProvider), isNull);
    });
  });

  group('filteredControlsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all controls when no filter', () {
      final all = container.read(regulatoryControlsProvider);
      final filtered = container.read(filteredControlsProvider);
      expect(filtered.length, all.length);
    });

    test('compliant filter returns only compliant controls', () {
      container
          .read(controlStatusFilterProvider.notifier)
          .update(SecurityControlStatus.compliant);
      final filtered = container.read(filteredControlsProvider);
      expect(
        filtered.every((c) => c.status == SecurityControlStatus.compliant),
        isTrue,
      );
    });

    test('filtered is subset of all', () {
      container
          .read(controlStatusFilterProvider.notifier)
          .update(SecurityControlStatus.inReview);
      final all = container.read(regulatoryControlsProvider);
      final filtered = container.read(filteredControlsProvider);
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });
  });

  group('regulatoryTrustSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalControls matches controls count', () {
      final controls = container.read(regulatoryControlsProvider);
      final summary = container.read(regulatoryTrustSummaryProvider);
      expect(summary.totalControls, controls.length);
    });

    test('compliant and nonCompliant counts are non-negative', () {
      final summary = container.read(regulatoryTrustSummaryProvider);
      expect(summary.compliantControls, greaterThanOrEqualTo(0));
      expect(summary.nonCompliantControls, greaterThanOrEqualTo(0));
    });

    test('compliant + nonCompliant does not exceed total', () {
      final summary = container.read(regulatoryTrustSummaryProvider);
      expect(
        summary.compliantControls + summary.nonCompliantControls,
        lessThanOrEqualTo(summary.totalControls),
      );
    });

    test('upcomingVapts is non-negative', () {
      final summary = container.read(regulatoryTrustSummaryProvider);
      expect(summary.upcomingVapts, greaterThanOrEqualTo(0));
    });
  });
}
