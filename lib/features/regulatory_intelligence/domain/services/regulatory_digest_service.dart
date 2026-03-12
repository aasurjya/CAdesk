import '../models/regulatory_digest.dart';
import '../models/regulatory_update.dart';
import 'circular_tracker_service.dart';
import 'compliance_alert_service.dart';
import 'rate_change_tracker_service.dart';

/// Stateless singleton service that assembles [RegulatoryDigest]s by
/// aggregating data from the circular tracker, compliance alert, and rate
/// change tracker services.
class RegulatoryDigestService {
  RegulatoryDigestService._();

  /// Singleton instance.
  static final RegulatoryDigestService instance = RegulatoryDigestService._();

  final CircularTrackerService _circularTracker =
      CircularTrackerService.instance;
  final ComplianceAlertService _alertService = ComplianceAlertService.instance;
  final RateChangeTrackerService _rateTracker =
      RateChangeTrackerService.instance;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a daily digest for [date].
  ///
  /// The financial year is inferred from [date]: if month >= 4, the FY ending
  /// year is [date.year + 1]; otherwise it is [date.year].
  RegulatoryDigest generateDailyDigest(DateTime date) {
    final fyEndYear = date.month >= 4 ? date.year + 1 : date.year;
    final updates = _circularTracker.getLatestUpdates(limit: 10);
    final alerts = _alertService.generateAlerts(fyEndYear, date);
    final rateChanges = _rateTracker.getRecentChanges(limit: 5);

    return RegulatoryDigest(
      digestDate: date,
      updates: updates,
      alerts: alerts,
      rateChanges: rateChanges,
    );
  }

  /// Generates a weekly summary digest starting at [weekStart].
  ///
  /// Pulls a broader set of updates (up to 20) to reflect a week's worth of
  /// regulatory activity.
  RegulatoryDigest generateWeeklySummary(DateTime weekStart) {
    final fyEndYear =
        weekStart.month >= 4 ? weekStart.year + 1 : weekStart.year;
    final updates = _circularTracker.getLatestUpdates(limit: 20);
    final alerts = _alertService.generateAlerts(fyEndYear, weekStart);
    final rateChanges = _rateTracker.getRecentChanges(limit: 10);

    return RegulatoryDigest(
      digestDate: weekStart,
      updates: updates,
      alerts: alerts,
      rateChanges: rateChanges,
    );
  }

  /// Returns the count of [updates] that have not been read yet.
  int getUnreadCount(List<RegulatoryUpdate> updates) {
    return updates.where((u) => !u.isRead).length;
  }
}
