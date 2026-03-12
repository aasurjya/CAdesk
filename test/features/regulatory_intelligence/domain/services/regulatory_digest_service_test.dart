import 'package:ca_app/features/regulatory_intelligence/domain/models/compliance_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/rate_change.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_digest.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_update.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/services/regulatory_digest_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = RegulatoryDigestService.instance;
  final testDate = DateTime(2025, 3, 12);

  group('RegulatoryDigestService.generateDailyDigest', () {
    test('returns digest with given date', () {
      final digest = service.generateDailyDigest(testDate);
      expect(digest.digestDate, equals(testDate));
    });

    test('digest has non-empty updates list', () {
      final digest = service.generateDailyDigest(testDate);
      expect(digest.updates, isNotEmpty);
    });

    test('digest has non-empty alerts list', () {
      final digest = service.generateDailyDigest(testDate);
      expect(digest.alerts, isNotEmpty);
    });

    test('digest has non-empty rateChanges list', () {
      final digest = service.generateDailyDigest(testDate);
      expect(digest.rateChanges, isNotEmpty);
    });

    test('totalItems equals sum of updates + alerts + rateChanges', () {
      final digest = service.generateDailyDigest(testDate);
      final expected =
          digest.updates.length + digest.alerts.length + digest.rateChanges.length;
      expect(digest.totalItems, equals(expected));
    });

    test('highPriorityCount counts critical and high alerts', () {
      final digest = service.generateDailyDigest(testDate);
      final criticalAndHigh = digest.alerts.where(
        (a) =>
            a.priority == AlertPriority.critical ||
            a.priority == AlertPriority.high,
      );
      // Also count high impact updates
      final highImpactUpdates = digest.updates.where(
        (u) => u.impactLevel == ImpactLevel.high,
      );
      expect(
        digest.highPriorityCount,
        equals(criticalAndHigh.length + highImpactUpdates.length),
      );
    });
  });

  group('RegulatoryDigestService.generateWeeklySummary', () {
    test('returns digest with weekStart as date', () {
      final weekStart = DateTime(2025, 3, 10); // Monday
      final digest = service.generateWeeklySummary(weekStart);
      expect(digest.digestDate, equals(weekStart));
    });

    test('weekly summary contains updates', () {
      final weekStart = DateTime(2025, 3, 10);
      final digest = service.generateWeeklySummary(weekStart);
      expect(digest.updates, isNotEmpty);
    });

    test('totalItems is correctly computed', () {
      final weekStart = DateTime(2025, 3, 10);
      final digest = service.generateWeeklySummary(weekStart);
      final expected =
          digest.updates.length + digest.alerts.length + digest.rateChanges.length;
      expect(digest.totalItems, equals(expected));
    });
  });

  group('RegulatoryDigestService.getUnreadCount', () {
    test('returns 0 when all updates are read', () {
      final update = RegulatoryUpdate(
        updateId: 'u1',
        title: 'Read Update',
        summary: 'Summary',
        source: RegSource.cbdt,
        category: UpdateCategory.circular,
        publicationDate: DateTime.utc(2025, 3, 1),
        effectiveDate: null,
        impactLevel: ImpactLevel.medium,
        affectedSections: const [],
        url: null,
        isRead: true,
      );
      final count = service.getUnreadCount([update]);
      expect(count, equals(0));
    });

    test('returns count of unread updates', () {
      final u1 = RegulatoryUpdate(
        updateId: 'u1',
        title: 'Unread 1',
        summary: 'Summary',
        source: RegSource.cbic,
        category: UpdateCategory.notification,
        publicationDate: DateTime.utc(2025, 3, 1),
        effectiveDate: null,
        impactLevel: ImpactLevel.low,
        affectedSections: const [],
        url: null,
        isRead: false,
      );
      final u2 = RegulatoryUpdate(
        updateId: 'u2',
        title: 'Read 2',
        summary: 'Summary',
        source: RegSource.mca,
        category: UpdateCategory.circular,
        publicationDate: DateTime.utc(2025, 3, 2),
        effectiveDate: null,
        impactLevel: ImpactLevel.medium,
        affectedSections: const [],
        url: null,
        isRead: true,
      );
      final count = service.getUnreadCount([u1, u2]);
      expect(count, equals(1));
    });

    test('returns 0 for empty list', () {
      final count = service.getUnreadCount([]);
      expect(count, equals(0));
    });
  });

  group('RegulatoryDigest model', () {
    final update = RegulatoryUpdate(
      updateId: 'u1',
      title: 'Update 1',
      summary: 'Summary',
      source: RegSource.cbdt,
      category: UpdateCategory.amendment,
      publicationDate: DateTime.utc(2025, 3, 1),
      effectiveDate: null,
      impactLevel: ImpactLevel.high,
      affectedSections: const [],
      url: null,
      isRead: false,
    );

    const alert = ComplianceAlert(
      alertId: 'a1',
      title: 'Alert 1',
      description: 'Desc',
      alertType: AlertType.deadlineApproaching,
      dueDate: null,
      daysRemaining: null,
      applicableTo: [],
      penaltyIfMissed: null,
      priority: AlertPriority.critical,
    );

    final rateChange = RateChange(
      effectiveDate: DateTime.utc(2024, 7, 23),
      category: RateCategory.incomeTax,
      description: 'STCG rate increase',
      oldValue: '15%',
      newValue: '20%',
      circularReference: 'Finance Act 2024',
      affectedAssessees: const [],
    );

    late RegulatoryDigest digest;
    setUp(() {
      digest = RegulatoryDigest(
        digestDate: DateTime(2025, 3, 12),
        updates: [update],
        alerts: const [alert],
        rateChanges: [rateChange],
      );
    });

    test('totalItems is computed as 3', () {
      expect(digest.totalItems, equals(3));
    });

    test('highPriorityCount counts critical alert and high impact update', () {
      // 1 critical alert + 1 high impact update = 2
      expect(digest.highPriorityCount, equals(2));
    });

    test('copyWith returns updated instance', () {
      final copy = digest.copyWith(digestDate: DateTime(2025, 4, 1));
      expect(copy.digestDate, equals(DateTime(2025, 4, 1)));
      expect(copy.updates.length, equals(1));
    });

    test('equality holds for identical data', () {
      final other = RegulatoryDigest(
        digestDate: DateTime(2025, 3, 12),
        updates: [update],
        alerts: const [alert],
        rateChanges: [rateChange],
      );
      expect(digest, equals(other));
    });

    test('hashCode is consistent', () {
      expect(digest.hashCode, equals(digest.hashCode));
    });

    test('toString contains digestDate', () {
      expect(digest.toString(), contains('2025'));
    });
  });
}
