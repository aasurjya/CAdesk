import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/staff_monitoring/domain/models/activity_log.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/access_restriction.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/security_alert.dart';
import 'package:ca_app/features/staff_monitoring/data/providers/mock_data.dart';

// ---------------------------------------------------------------------------
// Activity log provider
// ---------------------------------------------------------------------------

final allActivityLogsProvider =
    NotifierProvider<AllActivityLogsNotifier, List<ActivityLog>>(
      AllActivityLogsNotifier.new,
    );

class AllActivityLogsNotifier extends Notifier<List<ActivityLog>> {
  @override
  List<ActivityLog> build() => mockActivityLogs;

  void update(List<ActivityLog> value) => state = List.unmodifiable(value);
}

// ---------------------------------------------------------------------------
// Restrictions provider
// ---------------------------------------------------------------------------

final allRestrictionsProvider =
    NotifierProvider<AllRestrictionsNotifier, List<AccessRestriction>>(
      AllRestrictionsNotifier.new,
    );

class AllRestrictionsNotifier extends Notifier<List<AccessRestriction>> {
  @override
  List<AccessRestriction> build() => mockRestrictions;

  void toggleActive(String restrictionId) {
    final updated = state.map((r) {
      if (r.id != restrictionId) return r;
      return r.copyWith(isActive: !r.isActive);
    }).toList();
    state = List.unmodifiable(updated);
  }

  void update(List<AccessRestriction> value) =>
      state = List.unmodifiable(value);
}

// ---------------------------------------------------------------------------
// Alerts provider
// ---------------------------------------------------------------------------

final allAlertsProvider =
    NotifierProvider<AllAlertsNotifier, List<SecurityAlert>>(
      AllAlertsNotifier.new,
    );

class AllAlertsNotifier extends Notifier<List<SecurityAlert>> {
  @override
  List<SecurityAlert> build() => mockAlerts;

  void resolve(String alertId, String resolvedBy) {
    final now = DateTime.now();
    final updated = state.map((a) {
      if (a.id != alertId) return a;
      return a.copyWith(
        isResolved: true,
        resolvedBy: resolvedBy,
        resolvedAt: now,
      );
    }).toList();
    state = List.unmodifiable(updated);
  }

  void update(List<SecurityAlert> value) => state = List.unmodifiable(value);
}

// ---------------------------------------------------------------------------
// Filter providers
// ---------------------------------------------------------------------------

final activityTypeFilterProvider =
    NotifierProvider<ActivityTypeFilterNotifier, ActivityType?>(
      ActivityTypeFilterNotifier.new,
    );

class ActivityTypeFilterNotifier extends Notifier<ActivityType?> {
  @override
  ActivityType? build() => null;

  void update(ActivityType? value) => state = value;
}

final alertSeverityFilterProvider =
    NotifierProvider<AlertSeverityFilterNotifier, AlertSeverity?>(
      AlertSeverityFilterNotifier.new,
    );

class AlertSeverityFilterNotifier extends Notifier<AlertSeverity?> {
  @override
  AlertSeverity? build() => null;

  void update(AlertSeverity? value) => state = value;
}

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

final filteredActivityLogsProvider = Provider<List<ActivityLog>>((ref) {
  final logs = ref.watch(allActivityLogsProvider);
  final typeFilter = ref.watch(activityTypeFilterProvider);

  if (typeFilter == null) return logs;
  return List.unmodifiable(
    logs.where((l) => l.activityType == typeFilter).toList(),
  );
});

final filteredAlertsProvider = Provider<List<SecurityAlert>>((ref) {
  final alerts = ref.watch(allAlertsProvider);
  final severityFilter = ref.watch(alertSeverityFilterProvider);

  if (severityFilter == null) return alerts;
  return List.unmodifiable(
    alerts.where((a) => a.severity == severityFilter).toList(),
  );
});

final unresolvedAlertCountProvider = Provider<int>((ref) {
  return ref.watch(allAlertsProvider).where((a) => !a.isResolved).length;
});
