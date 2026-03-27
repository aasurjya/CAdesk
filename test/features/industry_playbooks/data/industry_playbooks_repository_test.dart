import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/vertical_playbook.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/service_bundle.dart';
import 'package:ca_app/features/industry_playbooks/data/repositories/mock_industry_playbooks_repository.dart';

void main() {
  group('MockIndustryPlaybooksRepository', () {
    late MockIndustryPlaybooksRepository repo;

    setUp(() {
      repo = MockIndustryPlaybooksRepository();
    });

    // -----------------------------------------------------------------------
    // VerticalPlaybook tests
    // -----------------------------------------------------------------------

    group('getPlaybooks', () {
      test('returns seeded playbooks', () async {
        final results = await repo.getPlaybooks();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getPlaybooks();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getPlaybookById', () {
      test('returns playbook for known id', () async {
        final all = await repo.getPlaybooks();
        final id = all.first.id;
        final result = await repo.getPlaybookById(id);
        expect(result, isNotNull);
        expect(result!.id, equals(id));
      });

      test('returns null for unknown id', () async {
        final result = await repo.getPlaybookById('no-such-id');
        expect(result, isNull);
      });
    });

    group('searchPlaybooks', () {
      test('returns results for partial vertical name match', () async {
        final all = await repo.getPlaybooks();
        final query = all.first.vertical.substring(0, 3).toLowerCase();
        final results = await repo.searchPlaybooks(query);
        expect(results, isNotEmpty);
      });

      test('returns empty for non-matching query', () async {
        final results = await repo.searchPlaybooks('zzznomatchzzz');
        expect(results, isEmpty);
      });
    });

    group('insertPlaybook', () {
      test('inserts and returns id', () async {
        const playbook = VerticalPlaybook(
          id: 'test-pb-001',
          vertical: 'Startups',
          icon: '🚀',
          description: 'Tax profile for early-stage startups.',
          complianceChecklist: ['DPIIT registration', 'Angel tax compliance'],
          typicalRisks: ['Section 56(2)(viib) — angel tax'],
          activeClients: 5,
          avgRetainerValue: 2.5,
          winRate: 0.6,
          marginPercent: 0.35,
        );
        final id = await repo.insertPlaybook(playbook);
        expect(id, equals('test-pb-001'));
      });

      test('inserted playbook is retrievable', () async {
        const playbook = VerticalPlaybook(
          id: 'test-pb-002',
          vertical: 'Textile',
          icon: '🧵',
          description: 'Tax profile for textile manufacturers.',
          complianceChecklist: ['GST e-invoicing', 'TCS on exports'],
          typicalRisks: ['ITC reversal on exempt goods'],
          activeClients: 12,
          avgRetainerValue: 4.0,
          winRate: 0.7,
          marginPercent: 0.4,
        );
        await repo.insertPlaybook(playbook);
        final result = await repo.getPlaybookById('test-pb-002');
        expect(result, isNotNull);
      });
    });

    group('updatePlaybook', () {
      test('updates activeClients and returns true', () async {
        final all = await repo.getPlaybooks();
        final original = all.first;
        final updated = original.copyWith(activeClients: 999);
        final success = await repo.updatePlaybook(updated);
        expect(success, isTrue);

        final after = await repo.getPlaybookById(original.id);
        expect(after?.activeClients, 999);
      });

      test('returns false for non-existent id', () async {
        const ghost = VerticalPlaybook(
          id: 'no-such-id',
          vertical: 'Ghost',
          icon: '👻',
          description: 'Ghost playbook',
          complianceChecklist: [],
          typicalRisks: [],
          activeClients: 0,
          avgRetainerValue: 0,
          winRate: 0,
          marginPercent: 0,
        );
        final success = await repo.updatePlaybook(ghost);
        expect(success, isFalse);
      });
    });

    group('deletePlaybook', () {
      test('deletes seeded playbook and returns true', () async {
        final all = await repo.getPlaybooks();
        final id = all.first.id;
        final success = await repo.deletePlaybook(id);
        expect(success, isTrue);

        final after = await repo.getPlaybookById(id);
        expect(after, isNull);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deletePlaybook('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // ServiceBundle tests
    // -----------------------------------------------------------------------

    group('getBundlesByVertical', () {
      test('returns bundles for known vertical', () async {
        final allPlaybooks = await repo.getPlaybooks();
        final verticalId = allPlaybooks.first.id;
        final results = await repo.getBundlesByVertical(verticalId);
        expect(results.every((b) => b.verticalId == verticalId), isTrue);
      });

      test('returns empty for unknown vertical', () async {
        final results = await repo.getBundlesByVertical('no-such-vertical');
        expect(results, isEmpty);
      });
    });

    group('insertBundle', () {
      test('inserts and returns id', () async {
        const bundle = ServiceBundle(
          id: 'test-bundle-001',
          verticalId: 'vp-001',
          name: 'Basic GST Bundle',
          description: 'Monthly GST compliance',
          inclusions: ['GST returns', 'Reconciliation'],
          pricePerMonth: 3000,
          turnaroundDays: 3,
          slaLabel: 'T+3 days',
          isPopular: false,
        );
        final id = await repo.insertBundle(bundle);
        expect(id, equals('test-bundle-001'));
      });
    });

    group('updateBundle', () {
      test('updates pricePerMonth and returns true', () async {
        final all = await repo.getPlaybooks();
        final verticalId = all.first.id;
        final bundles = await repo.getBundlesByVertical(verticalId);
        if (bundles.isEmpty) return;

        final original = bundles.first;
        final updated = original.copyWith(pricePerMonth: 99999);
        final success = await repo.updateBundle(updated);
        expect(success, isTrue);

        final afterBundles = await repo.getBundlesByVertical(verticalId);
        final found = afterBundles.firstWhere((b) => b.id == original.id);
        expect(found.pricePerMonth, 99999);
      });

      test('returns false for non-existent id', () async {
        const ghost = ServiceBundle(
          id: 'no-such-bundle',
          verticalId: 'x',
          name: 'Ghost',
          description: 'Ghost bundle',
          inclusions: [],
          pricePerMonth: 0,
          turnaroundDays: 0,
          slaLabel: 'N/A',
          isPopular: false,
        );
        final success = await repo.updateBundle(ghost);
        expect(success, isFalse);
      });
    });
  });
}
