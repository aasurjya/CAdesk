import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tax_advisory/data/providers/tax_advisory_providers.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_opportunity.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_proposal.dart';

void main() {
  group('Tax Advisory Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // allOpportunitiesProvider
    // -------------------------------------------------------------------------
    group('allOpportunitiesProvider', () {
      test('initial state is non-empty list', () {
        final opps = container.read(allOpportunitiesProvider);
        expect(opps, isNotEmpty);
        expect(opps.length, greaterThanOrEqualTo(5));
      });

      test('all items are AdvisoryOpportunity objects', () {
        final opps = container.read(allOpportunitiesProvider);
        expect(opps, everyElement(isA<AdvisoryOpportunity>()));
      });

      test('list is unmodifiable', () {
        final opps = container.read(allOpportunitiesProvider);
        expect(() => opps.add(opps.first), throwsA(anything));
      });

      test('opportunities span multiple types', () {
        final opps = container.read(allOpportunitiesProvider);
        final types = opps.map((o) => o.opportunityType).toSet();
        expect(types.length, greaterThanOrEqualTo(4));
      });

      test('opportunities span multiple priorities', () {
        final opps = container.read(allOpportunitiesProvider);
        final priorities = opps.map((o) => o.priority).toSet();
        expect(priorities.length, greaterThanOrEqualTo(2));
      });

      test('opportunities span multiple statuses', () {
        final opps = container.read(allOpportunitiesProvider);
        final statuses = opps.map((o) => o.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(3));
      });

      test('all opportunities have non-empty id and clientId', () {
        final opps = container.read(allOpportunitiesProvider);
        for (final opp in opps) {
          expect(opp.id, isNotEmpty);
          expect(opp.clientId, isNotEmpty);
        }
      });

      test('all opportunities have non-empty signals list', () {
        final opps = container.read(allOpportunitiesProvider);
        for (final opp in opps) {
          expect(opp.signals, isNotEmpty);
        }
      });

      test('all estimated fees are positive', () {
        final opps = container.read(allOpportunitiesProvider);
        for (final opp in opps) {
          expect(opp.estimatedFee, greaterThan(0));
        }
      });
    });

    // -------------------------------------------------------------------------
    // allProposalsProvider
    // -------------------------------------------------------------------------
    group('allProposalsProvider', () {
      test('initial state is non-empty list', () {
        final proposals = container.read(allProposalsProvider);
        expect(proposals, isNotEmpty);
        expect(proposals.length, greaterThanOrEqualTo(3));
      });

      test('all items are AdvisoryProposal objects', () {
        final proposals = container.read(allProposalsProvider);
        expect(proposals, everyElement(isA<AdvisoryProposal>()));
      });

      test('list is unmodifiable', () {
        final proposals = container.read(allProposalsProvider);
        expect(() => proposals.add(proposals.first), throwsA(anything));
      });

      test('proposals span multiple statuses', () {
        final proposals = container.read(allProposalsProvider);
        final statuses = proposals.map((p) => p.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(3));
      });

      test('proposals include accepted and sent statuses', () {
        final proposals = container.read(allProposalsProvider);
        expect(
          proposals.any((p) => p.status == ProposalStatus.accepted),
          isTrue,
        );
        expect(
          proposals.any((p) => p.status == ProposalStatus.sent),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // opportunityTypeFilterProvider
    // -------------------------------------------------------------------------
    group('opportunityTypeFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(opportunityTypeFilterProvider), isNull);
      });

      test('can be set to a type', () {
        container
            .read(opportunityTypeFilterProvider.notifier)
            .update(OpportunityType.missingDeductions);
        expect(
          container.read(opportunityTypeFilterProvider),
          OpportunityType.missingDeductions,
        );
      });

      test('can be cleared to null', () {
        container
            .read(opportunityTypeFilterProvider.notifier)
            .update(OpportunityType.gstOptimisation);
        container.read(opportunityTypeFilterProvider.notifier).update(null);
        expect(container.read(opportunityTypeFilterProvider), isNull);
      });

      test('supports all OpportunityType values', () {
        for (final type in OpportunityType.values) {
          container.read(opportunityTypeFilterProvider.notifier).update(type);
          expect(container.read(opportunityTypeFilterProvider), type);
        }
      });
    });

    // -------------------------------------------------------------------------
    // filteredOpportunitiesProvider
    // -------------------------------------------------------------------------
    group('filteredOpportunitiesProvider', () {
      test('returns all opportunities when filter is null', () {
        final all = container.read(allOpportunitiesProvider);
        final filtered = container.read(filteredOpportunitiesProvider);
        expect(filtered.length, all.length);
      });

      test('filters by missingDeductions type', () {
        container
            .read(opportunityTypeFilterProvider.notifier)
            .update(OpportunityType.missingDeductions);
        final filtered = container.read(filteredOpportunitiesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (o) => o.opportunityType == OpportunityType.missingDeductions,
          ),
          isTrue,
        );
      });

      test('filters by regimeOptimisation type', () {
        container
            .read(opportunityTypeFilterProvider.notifier)
            .update(OpportunityType.regimeOptimisation);
        final filtered = container.read(filteredOpportunitiesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (o) => o.opportunityType == OpportunityType.regimeOptimisation,
          ),
          isTrue,
        );
      });

      test('filtered count is subset of total', () {
        container
            .read(opportunityTypeFilterProvider.notifier)
            .update(OpportunityType.capitalGainsHarvesting);
        final all = container.read(allOpportunitiesProvider);
        final filtered = container.read(filteredOpportunitiesProvider);
        expect(filtered.length, lessThanOrEqualTo(all.length));
      });

      test('clearing filter returns all', () {
        container
            .read(opportunityTypeFilterProvider.notifier)
            .update(OpportunityType.tdsPlanning);
        container.read(opportunityTypeFilterProvider.notifier).update(null);
        final all = container.read(allOpportunitiesProvider);
        final filtered = container.read(filteredOpportunitiesProvider);
        expect(filtered.length, all.length);
      });

      test('filter for type not in mock data returns empty list', () {
        // retainerUpsell is not in the mock data
        container
            .read(opportunityTypeFilterProvider.notifier)
            .update(OpportunityType.retainerUpsell);
        final filtered = container.read(filteredOpportunitiesProvider);
        expect(filtered, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // advisorySummaryProvider
    // -------------------------------------------------------------------------
    group('advisorySummaryProvider', () {
      test('returns a non-empty map', () {
        final summary = container.read(advisorySummaryProvider);
        expect(summary, isNotEmpty);
      });

      test('summary contains expected keys', () {
        final summary = container.read(advisorySummaryProvider);
        expect(summary.containsKey('total'), isTrue);
        expect(summary.containsKey('highPriority'), isTrue);
        expect(summary.containsKey('converted'), isTrue);
        expect(summary.containsKey('totalFeesPipeline'), isTrue);
      });

      test('total matches all opportunities count', () {
        final opps = container.read(allOpportunitiesProvider);
        final summary = container.read(advisorySummaryProvider);
        expect(summary['total'], opps.length);
      });

      test('highPriority matches count of high priority opps', () {
        final opps = container.read(allOpportunitiesProvider);
        final expected =
            opps.where((o) => o.priority == OpportunityPriority.high).length;
        final summary = container.read(advisorySummaryProvider);
        expect(summary['highPriority'], expected);
      });

      test('converted matches count of converted opps', () {
        final opps = container.read(allOpportunitiesProvider);
        final expected =
            opps.where((o) => o.status == OpportunityStatus.converted).length;
        final summary = container.read(advisorySummaryProvider);
        expect(summary['converted'], expected);
      });

      test('totalFeesPipeline is a non-empty string', () {
        final summary = container.read(advisorySummaryProvider);
        final feeLabel = summary['totalFeesPipeline'] as String;
        expect(feeLabel, isNotEmpty);
        expect(feeLabel.startsWith('₹'), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // AdvisoryOpportunity computed properties
    // -------------------------------------------------------------------------
    group('AdvisoryOpportunity.formattedFee', () {
      test('formats fee >= 1 lakh with L suffix', () {
        final opp = AdvisoryOpportunity(
          id: 'test',
          clientId: 'c1',
          clientName: 'Test',
          opportunityType: OpportunityType.missingDeductions,
          title: 'Test',
          description: 'Desc',
          estimatedFee: 150000,
          priority: OpportunityPriority.high,
          status: OpportunityStatus.new_,
          detectedAt: DateTime(2026, 3, 1),
          signals: const ['signal1'],
        );
        expect(opp.formattedFee, '₹1.5L');
      });

      test('formats fee 1 lakh exactly as 1L', () {
        final opp = AdvisoryOpportunity(
          id: 'test',
          clientId: 'c1',
          clientName: 'Test',
          opportunityType: OpportunityType.missingDeductions,
          title: 'Test',
          description: 'Desc',
          estimatedFee: 100000,
          priority: OpportunityPriority.high,
          status: OpportunityStatus.new_,
          detectedAt: DateTime(2026, 3, 1),
          signals: const ['signal1'],
        );
        expect(opp.formattedFee, '₹1L');
      });

      test('formats fee >= 1000 with K suffix', () {
        final opp = AdvisoryOpportunity(
          id: 'test',
          clientId: 'c1',
          clientName: 'Test',
          opportunityType: OpportunityType.missingDeductions,
          title: 'Test',
          description: 'Desc',
          estimatedFee: 25000,
          priority: OpportunityPriority.high,
          status: OpportunityStatus.new_,
          detectedAt: DateTime(2026, 3, 1),
          signals: const ['signal1'],
        );
        expect(opp.formattedFee, '₹25K');
      });

      test('formats fee < 1000 as integer', () {
        final opp = AdvisoryOpportunity(
          id: 'test',
          clientId: 'c1',
          clientName: 'Test',
          opportunityType: OpportunityType.missingDeductions,
          title: 'Test',
          description: 'Desc',
          estimatedFee: 500,
          priority: OpportunityPriority.low,
          status: OpportunityStatus.new_,
          detectedAt: DateTime(2026, 3, 1),
          signals: const ['signal1'],
        );
        expect(opp.formattedFee, '₹500');
      });
    });

    // -------------------------------------------------------------------------
    // OpportunityType / OpportunityStatus / OpportunityPriority enums
    // -------------------------------------------------------------------------
    group('Enum labels', () {
      test('all OpportunityType values have non-empty labels', () {
        for (final type in OpportunityType.values) {
          expect(type.label, isNotEmpty);
        }
      });

      test('all OpportunityPriority values have non-empty labels', () {
        for (final priority in OpportunityPriority.values) {
          expect(priority.label, isNotEmpty);
        }
      });

      test('all OpportunityStatus values have non-empty labels', () {
        for (final status in OpportunityStatus.values) {
          expect(status.label, isNotEmpty);
        }
      });

      test('all ProposalStatus values have non-empty labels', () {
        for (final status in ProposalStatus.values) {
          expect(status.label, isNotEmpty);
        }
      });
    });
  });
}
