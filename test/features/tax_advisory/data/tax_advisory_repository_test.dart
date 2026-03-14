import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tax_advisory/data/repositories/mock_tax_advisory_repository.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_opportunity.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_proposal.dart';

void main() {
  group('MockTaxAdvisoryRepository', () {
    late MockTaxAdvisoryRepository repo;

    setUp(() {
      repo = MockTaxAdvisoryRepository();
    });

    // ── Opportunities ────────────────────────────────────────────────────────

    group('getAllOpportunities', () {
      test('returns seeded opportunities', () async {
        final result = await repo.getAllOpportunities();
        expect(result, isNotEmpty);
      });

      test('returns a list', () async {
        final result = await repo.getAllOpportunities();
        expect(result, isA<List<AdvisoryOpportunity>>());
      });
    });

    group('getOpportunitiesByClient', () {
      test('filters by clientId', () async {
        final result = await repo.getOpportunitiesByClient('client-101');
        expect(result, isNotEmpty);
        for (final o in result) {
          expect(o.clientId, 'client-101');
        }
      });

      test('returns empty for unknown client', () async {
        final result = await repo.getOpportunitiesByClient('client-unknown');
        expect(result, isEmpty);
      });
    });

    group('insertOpportunity', () {
      test('inserts and returns id', () async {
        final opp = AdvisoryOpportunity(
          id: 'opp-new-001',
          clientId: 'client-200',
          clientName: 'Test Client',
          opportunityType: OpportunityType.tdsPlanning,
          title: 'TDS Planning',
          description: 'Test description',
          estimatedFee: 10000,
          priority: OpportunityPriority.medium,
          status: OpportunityStatus.new_,
          detectedAt: DateTime(2026, 3, 14),
          signals: const ['Signal 1'],
        );
        final id = await repo.insertOpportunity(opp);
        expect(id, 'opp-new-001');

        final all = await repo.getAllOpportunities();
        expect(all.any((o) => o.id == 'opp-new-001'), isTrue);
      });
    });

    group('updateOpportunity', () {
      test('updates existing opportunity', () async {
        final all = await repo.getAllOpportunities();
        final existing = all.first;
        final updated = existing.copyWith(status: OpportunityStatus.reviewed);

        final result = await repo.updateOpportunity(updated);
        expect(result, isTrue);

        final fetched = await repo.getAllOpportunities();
        final found = fetched.firstWhere((o) => o.id == existing.id);
        expect(found.status, OpportunityStatus.reviewed);
      });

      test('returns false for unknown opportunity', () async {
        final opp = AdvisoryOpportunity(
          id: 'opp-does-not-exist',
          clientId: 'c',
          clientName: 'C',
          opportunityType: OpportunityType.tdsPlanning,
          title: 'T',
          description: 'D',
          estimatedFee: 0,
          priority: OpportunityPriority.low,
          status: OpportunityStatus.new_,
          detectedAt: DateTime(2026),
          signals: const [],
        );
        final result = await repo.updateOpportunity(opp);
        expect(result, isFalse);
      });
    });

    // ── Proposals ────────────────────────────────────────────────────────────

    group('getAllProposals', () {
      test('returns seeded proposals', () async {
        final result = await repo.getAllProposals();
        expect(result, isNotEmpty);
      });
    });

    group('getProposalsByOpportunity', () {
      test('filters by opportunityId', () async {
        final result = await repo.getProposalsByOpportunity('opp-mock-002');
        expect(result, isNotEmpty);
        for (final p in result) {
          expect(p.opportunityId, 'opp-mock-002');
        }
      });

      test('returns empty for unknown opportunity', () async {
        final result = await repo.getProposalsByOpportunity(
          'opp-does-not-exist',
        );
        expect(result, isEmpty);
      });
    });

    group('insertProposal', () {
      test('inserts and returns id', () async {
        final proposal = AdvisoryProposal(
          id: 'prop-new-001',
          opportunityId: 'opp-mock-001',
          clientName: 'Ramesh Agarwal',
          proposedFee: 25000,
          scope: 'HRA claim filing',
          sentAt: DateTime(2026, 3, 14),
          status: ProposalStatus.draft,
        );
        final id = await repo.insertProposal(proposal);
        expect(id, 'prop-new-001');

        final all = await repo.getAllProposals();
        expect(all.any((p) => p.id == 'prop-new-001'), isTrue);
      });
    });

    group('updateProposal', () {
      test('updates existing proposal', () async {
        final all = await repo.getAllProposals();
        final existing = all.first;
        final updated = existing.copyWith(status: ProposalStatus.accepted);

        final result = await repo.updateProposal(updated);
        expect(result, isTrue);

        final fetched = await repo.getAllProposals();
        final found = fetched.firstWhere((p) => p.id == existing.id);
        expect(found.status, ProposalStatus.accepted);
      });

      test('returns false for unknown proposal', () async {
        final proposal = AdvisoryProposal(
          id: 'prop-does-not-exist',
          opportunityId: 'opp-x',
          clientName: 'X',
          proposedFee: 0,
          scope: 'S',
          sentAt: DateTime(2026),
          status: ProposalStatus.draft,
        );
        final result = await repo.updateProposal(proposal);
        expect(result, isFalse);
      });
    });
  });
}
