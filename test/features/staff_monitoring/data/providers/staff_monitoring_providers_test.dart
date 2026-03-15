import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/staff_monitoring/data/providers/staff_monitoring_providers.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/activity_log.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/security_alert.dart';

void main() {
  group('allActivityLogsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 20 mock activity logs', () {
      final logs = container.read(allActivityLogsProvider);
      expect(logs.length, 20);
    });

    test('all logs have non-empty ids', () {
      final logs = container.read(allActivityLogsProvider);
      expect(logs.every((l) => l.id.isNotEmpty), isTrue);
    });
  });

  group('allRestrictionsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 8 mock access restrictions', () {
      final restrictions = container.read(allRestrictionsProvider);
      expect(restrictions.length, 8);
    });

    test('all restrictions have non-empty ids', () {
      final restrictions = container.read(allRestrictionsProvider);
      expect(restrictions.every((r) => r.id.isNotEmpty), isTrue);
    });

    test('toggleActive flips isActive for matching id', () {
      final original = container.read(allRestrictionsProvider).first;
      final originalActive = original.isActive;
      container.read(allRestrictionsProvider.notifier).toggleActive(original.id);
      final updated = container
          .read(allRestrictionsProvider)
          .firstWhere((r) => r.id == original.id);
      expect(updated.isActive, !originalActive);
    });
  });

  group('allAlertsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 8 mock security alerts', () {
      final alerts = container.read(allAlertsProvider);
      expect(alerts.length, 8);
    });

    test('all alerts have non-empty ids', () {
      final alerts = container.read(allAlertsProvider);
      expect(alerts.every((a) => a.id.isNotEmpty), isTrue);
    });

    test('resolve marks alert as resolved', () {
      final unresolved = container
          .read(allAlertsProvider)
          .firstWhere((a) => !a.isResolved);
      container.read(allAlertsProvider.notifier).resolve(unresolved.id, 'admin');
      final updated = container
          .read(allAlertsProvider)
          .firstWhere((a) => a.id == unresolved.id);
      expect(updated.isResolved, isTrue);
      expect(updated.resolvedBy, 'admin');
    });
  });

  group('ActivityTypeFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(activityTypeFilterProvider), isNull);
    });

    test('can be set to login', () {
      container
          .read(activityTypeFilterProvider.notifier)
          .update(ActivityType.login);
      expect(container.read(activityTypeFilterProvider), ActivityType.login);
    });

    test('can be reset to null', () {
      container
          .read(activityTypeFilterProvider.notifier)
          .update(ActivityType.login);
      container.read(activityTypeFilterProvider.notifier).update(null);
      expect(container.read(activityTypeFilterProvider), isNull);
    });
  });

  group('AlertSeverityFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(alertSeverityFilterProvider), isNull);
    });

    test('can be set to critical', () {
      container
          .read(alertSeverityFilterProvider.notifier)
          .update(AlertSeverity.critical);
      expect(
        container.read(alertSeverityFilterProvider),
        AlertSeverity.critical,
      );
    });
  });

  group('filteredActivityLogsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all logs when no filter', () {
      final all = container.read(allActivityLogsProvider);
      final filtered = container.read(filteredActivityLogsProvider);
      expect(filtered.length, all.length);
    });

    test('login filter returns only login logs', () {
      container
          .read(activityTypeFilterProvider.notifier)
          .update(ActivityType.login);
      final filtered = container.read(filteredActivityLogsProvider);
      expect(
        filtered.every((l) => l.activityType == ActivityType.login),
        isTrue,
      );
    });
  });

  group('filteredAlertsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all alerts when no filter', () {
      final all = container.read(allAlertsProvider);
      final filtered = container.read(filteredAlertsProvider);
      expect(filtered.length, all.length);
    });
  });

  group('unresolvedAlertCountProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('count is non-negative', () {
      final count = container.read(unresolvedAlertCountProvider);
      expect(count, greaterThanOrEqualTo(0));
    });

    test('count equals number of unresolved alerts', () {
      final alerts = container.read(allAlertsProvider);
      final expected = alerts.where((a) => !a.isResolved).length;
      final count = container.read(unresolvedAlertCountProvider);
      expect(count, expected);
    });
  });
}
