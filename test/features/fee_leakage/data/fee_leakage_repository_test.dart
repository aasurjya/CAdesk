import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/fee_leakage/domain/models/engagement.dart';
import 'package:ca_app/features/fee_leakage/domain/models/scope_item.dart';
import 'package:ca_app/features/fee_leakage/data/repositories/mock_fee_leakage_repository.dart';

void main() {
  group('MockFeeLeakageRepository', () {
    late MockFeeLeakageRepository repo;

    setUp(() {
      repo = MockFeeLeakageRepository();
    });

    // -----------------------------------------------------------------------
    // Engagement tests
    // -----------------------------------------------------------------------

    group('getEngagements', () {
      test('returns seeded engagements', () async {
        final results = await repo.getEngagements();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getEngagements();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getEngagementsByClient', () {
      test('returns engagements for mock-client-001', () async {
        final results = await repo.getEngagementsByClient('mock-client-001');
        expect(results.every((e) => e.clientId == 'mock-client-001'), isTrue);
      });

      test('returns empty for unknown client', () async {
        final results = await repo.getEngagementsByClient('no-such-client');
        expect(results, isEmpty);
      });
    });

    group('getEngagementsByStatus', () {
      test('returns only engagements of matching status', () async {
        final results = await repo.getEngagementsByStatus(
          EngagementStatus.overScope,
        );
        expect(
          results.every((e) => e.status == EngagementStatus.overScope),
          isTrue,
        );
      });
    });

    group('insertEngagement', () {
      test('inserts and returns id', () async {
        final engagement = Engagement(
          id: 'test-eng-001',
          clientId: 'new-client',
          clientName: 'Test Client',
          serviceType: 'GST Return',
          agreedFee: 5000,
          billedAmount: 4000,
          actualHours: 10,
          budgetHours: 8,
          status: EngagementStatus.overScope,
        );
        final id = await repo.insertEngagement(engagement);
        expect(id, equals('test-eng-001'));
      });

      test('inserted engagement is retrievable', () async {
        final engagement = Engagement(
          id: 'test-eng-002',
          clientId: 'insert-client',
          clientName: 'Insert Client',
          serviceType: 'Audit',
          agreedFee: 20000,
          billedAmount: 20000,
          actualHours: 40,
          budgetHours: 40,
          status: EngagementStatus.onTrack,
        );
        await repo.insertEngagement(engagement);
        final results = await repo.getEngagementsByClient('insert-client');
        expect(results.any((e) => e.id == 'test-eng-002'), isTrue);
      });
    });

    group('updateEngagement', () {
      test('updates status and returns true', () async {
        final all = await repo.getEngagements();
        final original = all.first;
        final updated = original.copyWith(status: EngagementStatus.disputed);
        final success = await repo.updateEngagement(updated);
        expect(success, isTrue);

        final after = await repo.getEngagements();
        final found = after.firstWhere((e) => e.id == original.id);
        expect(found.status, EngagementStatus.disputed);
      });

      test('returns false for non-existent id', () async {
        final ghost = Engagement(
          id: 'no-such-id',
          clientId: 'x',
          clientName: 'X',
          serviceType: 'X',
          agreedFee: 0,
          billedAmount: 0,
          actualHours: 0,
          budgetHours: 0,
          status: EngagementStatus.onTrack,
        );
        final success = await repo.updateEngagement(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteEngagement', () {
      test('deletes seeded engagement and returns true', () async {
        final all = await repo.getEngagements();
        final id = all.first.id;
        final success = await repo.deleteEngagement(id);
        expect(success, isTrue);

        final after = await repo.getEngagements();
        expect(after.any((e) => e.id == id), isFalse);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteEngagement('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // ScopeItem tests
    // -----------------------------------------------------------------------

    group('getScopeItems', () {
      test('returns seeded scope items', () async {
        final results = await repo.getScopeItems();
        expect(results, isNotEmpty);
      });
    });

    group('getScopeItemsByEngagement', () {
      test('returns items for known engagement', () async {
        final allItems = await repo.getScopeItems();
        final engId = allItems.first.engagementId;
        final results = await repo.getScopeItemsByEngagement(engId);
        expect(results.every((s) => s.engagementId == engId), isTrue);
      });

      test('returns empty for unknown engagement', () async {
        final results = await repo.getScopeItemsByEngagement(
          'no-such-engagement',
        );
        expect(results, isEmpty);
      });
    });

    group('insertScopeItem', () {
      test('inserts and returns id', () async {
        final item = ScopeItem(
          id: 'test-scope-001',
          engagementId: 'test-eng-001',
          description: 'Additional reconciliation',
          isInScope: false,
          addedAt: DateTime(2026, 3, 1),
          billedExtra: true,
        );
        final id = await repo.insertScopeItem(item);
        expect(id, equals('test-scope-001'));
      });
    });

    group('updateScopeItem', () {
      test('updates billedExtra and returns true', () async {
        final all = await repo.getScopeItems();
        final original = all.first;
        final updated = original.copyWith(billedExtra: true);
        final success = await repo.updateScopeItem(updated);
        expect(success, isTrue);

        final after = await repo.getScopeItems();
        final found = after.firstWhere((s) => s.id == original.id);
        expect(found.billedExtra, isTrue);
      });

      test('returns false for non-existent id', () async {
        final ghost = ScopeItem(
          id: 'no-such-scope',
          engagementId: 'x',
          description: 'Ghost',
          isInScope: false,
          addedAt: DateTime(2026, 1, 1),
          billedExtra: false,
        );
        final success = await repo.updateScopeItem(ghost);
        expect(success, isFalse);
      });
    });
  });
}
