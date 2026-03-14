import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/data/repositories/mock_advanced_audit_repository.dart';

void main() {
  group('MockAdvancedAuditRepository', () {
    late MockAdvancedAuditRepository repo;

    setUp(() {
      repo = MockAdvancedAuditRepository();
    });

    group('getEngagementsByClient', () {
      test('returns seeded engagements for mock-client-001', () async {
        final results = await repo.getEngagementsByClient('mock-client-001');
        expect(results, isNotEmpty);
        expect(results.every((e) => e.clientId == 'mock-client-001'), isTrue);
      });

      test('returns empty list for unknown client', () async {
        final results = await repo.getEngagementsByClient('unknown-client');
        expect(results, isEmpty);
      });
    });

    group('getEngagementById', () {
      test('returns engagement for valid ID', () async {
        final engagement = await repo.getEngagementById('mock-audit-001');
        expect(engagement, isNotNull);
        expect(engagement!.id, 'mock-audit-001');
      });

      test('returns null for unknown ID', () async {
        final engagement = await repo.getEngagementById('no-such-id');
        expect(engagement, isNull);
      });
    });

    group('insertEngagement', () {
      test('inserts and returns new engagement ID', () async {
        final newEngagement = AuditEngagement(
          id: 'new-audit-001',
          clientId: 'client-y',
          clientName: 'Client Y',
          auditType: AuditType.internal,
          financialYear: 'FY 2025-26',
          assignedPartner: 'CA Singh',
          teamMembers: const ['Raj', 'Priya'],
          status: AuditStatus.planning,
          startDate: DateTime(2026, 1, 1),
          reportDueDate: DateTime(2026, 6, 30),
          workpaperCount: 0,
          findingsCount: 0,
          riskLevel: AuditRiskLevel.low,
        );
        final id = await repo.insertEngagement(newEngagement);
        expect(id, 'new-audit-001');

        final fetched = await repo.getEngagementById('new-audit-001');
        expect(fetched, isNotNull);
        expect(fetched!.clientName, 'Client Y');
      });
    });

    group('updateEngagement', () {
      test('updates existing engagement and returns true', () async {
        final existing = await repo.getEngagementById('mock-audit-001');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(status: AuditStatus.completed);
        final success = await repo.updateEngagement(updated);
        expect(success, isTrue);

        final fetched = await repo.getEngagementById('mock-audit-001');
        expect(fetched!.status, AuditStatus.completed);
      });

      test('returns false for non-existent engagement', () async {
        final ghost = AuditEngagement(
          id: 'ghost-audit',
          clientId: 'c',
          clientName: 'Ghost',
          auditType: AuditType.statutory,
          financialYear: 'FY 2024-25',
          assignedPartner: 'CA X',
          teamMembers: const [],
          status: AuditStatus.planning,
          startDate: DateTime(2026, 1, 1),
          reportDueDate: DateTime(2026, 6, 30),
          workpaperCount: 0,
          findingsCount: 0,
          riskLevel: AuditRiskLevel.low,
        );
        final success = await repo.updateEngagement(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteEngagement', () {
      test('deletes engagement and returns true', () async {
        final id = await repo.insertEngagement(
          AuditEngagement(
            id: 'to-delete-audit',
            clientId: 'client-del',
            clientName: 'Del Client',
            auditType: AuditType.stock,
            financialYear: 'FY 2023-24',
            assignedPartner: 'CA Del',
            teamMembers: const [],
            status: AuditStatus.planning,
            startDate: DateTime(2025, 1, 1),
            reportDueDate: DateTime(2025, 6, 30),
            workpaperCount: 0,
            findingsCount: 0,
            riskLevel: AuditRiskLevel.medium,
          ),
        );

        final success = await repo.deleteEngagement(id);
        expect(success, isTrue);

        final fetched = await repo.getEngagementById(id);
        expect(fetched, isNull);
      });

      test('returns false for non-existent engagement ID', () async {
        final success = await repo.deleteEngagement('no-such-audit');
        expect(success, isFalse);
      });
    });

    group('getAllEngagements', () {
      test('returns all seeded engagements', () async {
        final all = await repo.getAllEngagements();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAllEngagements();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });
  });
}
