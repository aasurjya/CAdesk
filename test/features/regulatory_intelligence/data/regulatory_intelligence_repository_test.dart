import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_update.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/compliance_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_circular.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/client_impact_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/data/repositories/mock_regulatory_intelligence_repository.dart';

void main() {
  group('MockRegulatoryIntelligenceRepository', () {
    late MockRegulatoryIntelligenceRepository repo;

    setUp(() {
      repo = MockRegulatoryIntelligenceRepository();
    });

    // -------------------------------------------------------------------------
    // RegulatoryUpdate
    // -------------------------------------------------------------------------

    group('RegulatoryUpdates', () {
      test('getUpdates returns at least 3 seed items', () async {
        final updates = await repo.getUpdates();
        expect(updates.length, greaterThanOrEqualTo(3));
      });

      test('getUpdateById returns matching update', () async {
        final all = await repo.getUpdates();
        final first = all.first;
        final found = await repo.getUpdateById(first.updateId);
        expect(found?.updateId, first.updateId);
      });

      test('getUpdateById returns null for unknown id', () async {
        final found = await repo.getUpdateById('no-such-id');
        expect(found, isNull);
      });

      test('getUpdatesBySource filters by source', () async {
        final all = await repo.getUpdates();
        final source = all.first.source;
        final filtered = await repo.getUpdatesBySource(source);
        expect(filtered.every((u) => u.source == source), isTrue);
      });

      test('getUpdatesByImpactLevel filters correctly', () async {
        final updates = await repo.getUpdatesByImpactLevel(ImpactLevel.high);
        expect(updates.every((u) => u.impactLevel == ImpactLevel.high), isTrue);
      });

      test('insertUpdate adds update', () async {
        final update = RegulatoryUpdate(
          updateId: 'update-new-001',
          title: 'New GST Circular',
          summary: 'New circular issued by CBIC',
          source: RegSource.cbic,
          category: UpdateCategory.circular,
          publicationDate: DateTime(2026, 3, 1),
          effectiveDate: DateTime(2026, 4, 1),
          impactLevel: ImpactLevel.medium,
          affectedSections: const ['Section 12'],
          url: 'https://cbic.gov.in/123',
          isRead: false,
        );
        final id = await repo.insertUpdate(update);
        expect(id, update.updateId);
      });

      test('markUpdateAsRead marks update read', () async {
        final all = await repo.getUpdates();
        final unread = all.firstWhere((u) => !u.isRead);
        final success = await repo.markUpdateAsRead(unread.updateId);
        expect(success, isTrue);

        final found = await repo.getUpdateById(unread.updateId);
        expect(found?.isRead, isTrue);
      });

      test('markUpdateAsRead returns false for unknown id', () async {
        final success = await repo.markUpdateAsRead('no-such-id');
        expect(success, isFalse);
      });

      test('deleteUpdate removes update', () async {
        final all = await repo.getUpdates();
        final first = all.first;
        final success = await repo.deleteUpdate(first.updateId);
        expect(success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // ComplianceAlert
    // -------------------------------------------------------------------------

    group('ComplianceAlerts', () {
      test('getAlerts returns at least 3 seed items', () async {
        final alerts = await repo.getAlerts();
        expect(alerts.length, greaterThanOrEqualTo(3));
      });

      test('getAlertById returns matching alert', () async {
        final all = await repo.getAlerts();
        final first = all.first;
        final found = await repo.getAlertById(first.alertId);
        expect(found?.alertId, first.alertId);
      });

      test('getAlertsByPriority filters correctly', () async {
        final alerts = await repo.getAlertsByPriority(AlertPriority.critical);
        expect(
          alerts.every((a) => a.priority == AlertPriority.critical),
          isTrue,
        );
      });

      test('insertAlert adds alert', () async {
        final alert = ComplianceAlert(
          alertId: 'alert-new-001',
          title: 'ITR Filing Deadline',
          description: 'Due date for filing ITR',
          alertType: AlertType.deadlineApproaching,
          dueDate: DateTime(2026, 7, 31),
          daysRemaining: 139,
          applicableTo: const ['Individual'],
          penaltyIfMissed: '₹5,000',
          priority: AlertPriority.high,
        );
        final id = await repo.insertAlert(alert);
        expect(id, alert.alertId);
      });

      test('deleteAlert removes alert', () async {
        final all = await repo.getAlerts();
        final first = all.first;
        final success = await repo.deleteAlert(first.alertId);
        expect(success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // RegulatoryCircular
    // -------------------------------------------------------------------------

    group('RegulatoryCirculars', () {
      test('getCirculars returns at least 3 seed items', () async {
        final circulars = await repo.getCirculars();
        expect(circulars.length, greaterThanOrEqualTo(3));
      });

      test('getCircularById returns matching circular', () async {
        final all = await repo.getCirculars();
        final first = all.first;
        final found = await repo.getCircularById(first.id);
        expect(found?.id, first.id);
      });

      test('insertCircular adds circular', () async {
        final circular = RegulatoryCircular(
          id: 'circular-new-001',
          circularNumber: 'CBDT/2026/001',
          issuingBody: 'CBDT',
          title: 'New circular on advance tax',
          summary: 'Summary of the circular',
          issueDate: '01 Mar 2026',
          effectiveDate: '01 Apr 2026',
          category: 'Income Tax',
          impactLevel: 'High',
          affectedClientsCount: 25,
          keyChanges: const ['Change 1', 'Change 2'],
        );
        final id = await repo.insertCircular(circular);
        expect(id, circular.id);
      });

      test('deleteCircular removes circular', () async {
        final all = await repo.getCirculars();
        final first = all.first;
        final success = await repo.deleteCircular(first.id);
        expect(success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // ClientImpactAlert
    // -------------------------------------------------------------------------

    group('ClientImpactAlerts', () {
      test('getClientImpactAlerts returns at least 3 seed items', () async {
        final alerts = await repo.getClientImpactAlerts();
        expect(alerts.length, greaterThanOrEqualTo(3));
      });

      test('getClientImpactAlertsByCircular filters by circularId', () async {
        final all = await repo.getClientImpactAlerts();
        final circularId = all.first.circularId;
        final filtered = await repo.getClientImpactAlertsByCircular(circularId);
        expect(filtered.every((a) => a.circularId == circularId), isTrue);
      });

      test('insertClientImpactAlert adds alert', () async {
        final alert = ClientImpactAlert(
          id: 'impact-new-001',
          circularId: 'circular-001',
          clientName: 'New Client',
          clientPan: 'ABCDE1234F',
          impactDescription: 'Client affected by new rule',
          actionRequired: 'File amended return',
          dueDate: '31 Mar 2026',
          status: 'New',
          urgency: 'Urgent',
        );
        final id = await repo.insertClientImpactAlert(alert);
        expect(id, alert.id);
      });

      test('updateClientImpactAlertStatus updates status', () async {
        final all = await repo.getClientImpactAlerts();
        final first = all.first;
        final success = await repo.updateClientImpactAlertStatus(
          first.id,
          'Reviewed',
        );
        expect(success, isTrue);
      });

      test(
        'updateClientImpactAlertStatus returns false for unknown id',
        () async {
          final success = await repo.updateClientImpactAlertStatus(
            'no-such-id',
            'Reviewed',
          );
          expect(success, isFalse);
        },
      );
    });
  });
}
