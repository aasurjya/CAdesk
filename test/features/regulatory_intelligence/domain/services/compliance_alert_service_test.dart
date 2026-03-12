import 'package:ca_app/features/regulatory_intelligence/domain/models/compliance_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/services/compliance_alert_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = ComplianceAlertService.instance;
  final today = DateTime(2025, 6, 1);

  group('ComplianceAlertService.generateAlerts', () {
    test('returns non-empty list for FY 2024-25', () {
      final alerts = service.generateAlerts(2025, today);
      expect(alerts, isNotEmpty);
    });

    test('includes ITR filing alert (Jul 31)', () {
      final alerts = service.generateAlerts(2025, today);
      final itr = alerts.where(
        (a) => a.title.toLowerCase().contains('itr'),
      );
      expect(itr, isNotEmpty);
    });

    test('includes GSTR-9 filing alert (Dec 31)', () {
      final alerts = service.generateAlerts(2025, today);
      final gstr9 = alerts.where(
        (a) => a.title.toLowerCase().contains('gstr-9') ||
            a.title.toLowerCase().contains('gstr9'),
      );
      expect(gstr9, isNotEmpty);
    });

    test('includes Section 43B(h) MSME alert', () {
      final alerts = service.generateAlerts(2025, today);
      final msme = alerts.where(
        (a) => a.title.toLowerCase().contains('msme') ||
            a.description.toLowerCase().contains('43b'),
      );
      expect(msme, isNotEmpty);
    });

    test('includes DIR-3 KYC alert (Sep 30)', () {
      final alerts = service.generateAlerts(2025, today);
      final dir3 = alerts.where(
        (a) => a.title.toLowerCase().contains('dir-3') ||
            a.title.toLowerCase().contains('kyc'),
      );
      expect(dir3, isNotEmpty);
    });

    test('includes Finance Act 2024 TDS rate change alert', () {
      final alerts = service.generateAlerts(2025, today);
      final tds = alerts.where(
        (a) => a.alertType == AlertType.rateChange &&
            (a.title.toLowerCase().contains('stcg') ||
                a.title.toLowerCase().contains('ltcg') ||
                a.description.toLowerCase().contains('finance act 2024')),
      );
      expect(tds, isNotEmpty);
    });

    test('all alerts have non-empty alertId and title', () {
      final alerts = service.generateAlerts(2025, today);
      for (final a in alerts) {
        expect(a.alertId, isNotEmpty);
        expect(a.title, isNotEmpty);
      }
    });
  });

  group('ComplianceAlertService.getPriorityAlerts', () {
    test('returns only critical and high priority alerts', () {
      final alerts = service.generateAlerts(2025, today);
      final priority = service.getPriorityAlerts(alerts);
      for (final a in priority) {
        expect(
          a.priority == AlertPriority.critical ||
              a.priority == AlertPriority.high,
          isTrue,
        );
      }
    });

    test('returns empty if no critical/high alerts', () {
      const lowAlert = ComplianceAlert(
        alertId: 'a1',
        title: 'Low Alert',
        description: 'desc',
        alertType: AlertType.newCompliance,
        dueDate: null,
        daysRemaining: null,
        applicableTo: [],
        penaltyIfMissed: null,
        priority: AlertPriority.low,
      );
      final result = service.getPriorityAlerts([lowAlert]);
      expect(result, isEmpty);
    });

    test('preserves order from input list', () {
      final alerts = service.generateAlerts(2025, today);
      final priority = service.getPriorityAlerts(alerts);
      // priority list is a subset — all items must be in input order
      var lastIndex = -1;
      for (final p in priority) {
        final idx = alerts.indexWhere((a) => a.alertId == p.alertId);
        expect(idx, greaterThan(lastIndex));
        lastIndex = idx;
      }
    });
  });

  group('ComplianceAlertService.filterForEntityType', () {
    test('returns alerts applicable to Individual', () {
      final alerts = service.generateAlerts(2025, today);
      final individual = service.filterForEntityType(alerts, 'Individual');
      for (final a in individual) {
        expect(a.applicableTo, contains('Individual'));
      }
    });

    test('returns alerts applicable to Company', () {
      final alerts = service.generateAlerts(2025, today);
      final company = service.filterForEntityType(alerts, 'Company');
      for (final a in company) {
        expect(a.applicableTo, contains('Company'));
      }
    });

    test('returns empty list for unknown entity type', () {
      final alerts = service.generateAlerts(2025, today);
      final result = service.filterForEntityType(alerts, 'AlienEntity');
      expect(result, isEmpty);
    });
  });

  group('ComplianceAlertService.computeDaysRemaining', () {
    test('returns positive days when due date is in future', () {
      const alert = ComplianceAlert(
        alertId: 'a2',
        title: 'Future Alert',
        description: 'desc',
        alertType: AlertType.deadlineApproaching,
        dueDate: DateTime.utc(2025, 7, 31),
        daysRemaining: null,
        applicableTo: ['Individual'],
        penaltyIfMissed: null,
        priority: AlertPriority.high,
      );
      final days = service.computeDaysRemaining(alert, DateTime(2025, 6, 1));
      expect(days, greaterThan(0));
    });

    test('returns 0 when due date equals today', () {
      const alert = ComplianceAlert(
        alertId: 'a3',
        title: 'Due Today',
        description: 'desc',
        alertType: AlertType.deadlineApproaching,
        dueDate: DateTime.utc(2025, 6, 1),
        daysRemaining: null,
        applicableTo: [],
        penaltyIfMissed: null,
        priority: AlertPriority.critical,
      );
      final days = service.computeDaysRemaining(alert, DateTime(2025, 6, 1));
      expect(days, equals(0));
    });

    test('returns negative when due date is past', () {
      const alert = ComplianceAlert(
        alertId: 'a4',
        title: 'Overdue',
        description: 'desc',
        alertType: AlertType.penaltyRisk,
        dueDate: DateTime.utc(2025, 5, 1),
        daysRemaining: null,
        applicableTo: [],
        penaltyIfMissed: null,
        priority: AlertPriority.critical,
      );
      final days = service.computeDaysRemaining(alert, DateTime(2025, 6, 1));
      expect(days, lessThan(0));
    });

    test('returns null when dueDate is null', () {
      const alert = ComplianceAlert(
        alertId: 'a5',
        title: 'No Due Date',
        description: 'desc',
        alertType: AlertType.rateChange,
        dueDate: null,
        daysRemaining: null,
        applicableTo: [],
        penaltyIfMissed: null,
        priority: AlertPriority.low,
      );
      final days = service.computeDaysRemaining(alert, DateTime(2025, 6, 1));
      expect(days, isNull);
    });
  });

  group('ComplianceAlert model', () {
    const alert = ComplianceAlert(
      alertId: 'test-1',
      title: 'ITR Filing Deadline',
      description: 'File ITR by July 31',
      alertType: AlertType.deadlineApproaching,
      dueDate: DateTime.utc(2025, 7, 31),
      daysRemaining: 60,
      applicableTo: ['Individual', 'HUF'],
      penaltyIfMissed: '₹5,000 under Section 234F',
      priority: AlertPriority.high,
    );

    test('const constructor sets all fields correctly', () {
      expect(alert.alertId, 'test-1');
      expect(alert.title, 'ITR Filing Deadline');
      expect(alert.alertType, AlertType.deadlineApproaching);
      expect(alert.priority, AlertPriority.high);
      expect(alert.applicableTo, ['Individual', 'HUF']);
    });

    test('copyWith returns updated instance', () {
      final copy = alert.copyWith(priority: AlertPriority.critical);
      expect(copy.priority, AlertPriority.critical);
      expect(copy.alertId, 'test-1');
    });

    test('equality holds for identical data', () {
      const other = ComplianceAlert(
        alertId: 'test-1',
        title: 'ITR Filing Deadline',
        description: 'File ITR by July 31',
        alertType: AlertType.deadlineApproaching,
        dueDate: DateTime.utc(2025, 7, 31),
        daysRemaining: 60,
        applicableTo: ['Individual', 'HUF'],
        penaltyIfMissed: '₹5,000 under Section 234F',
        priority: AlertPriority.high,
      );
      expect(alert, equals(other));
    });

    test('hashCode is consistent', () {
      expect(alert.hashCode, equals(alert.hashCode));
    });

    test('toString contains alertId', () {
      expect(alert.toString(), contains('test-1'));
    });
  });
}
