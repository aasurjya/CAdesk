import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/lead_funnel/data/providers/lead_funnel_providers.dart';
import 'package:ca_app/features/lead_funnel/domain/models/lead.dart';
import 'package:ca_app/features/lead_funnel/domain/models/campaign.dart';

void main() {
  group('Lead Funnel Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // allLeadsProvider
    // -------------------------------------------------------------------------
    group('allLeadsProvider', () {
      test('initial state is non-empty list', () {
        final leads = container.read(allLeadsProvider);
        expect(leads, isNotEmpty);
        expect(leads.length, greaterThanOrEqualTo(5));
      });

      test('all items are Lead objects', () {
        final leads = container.read(allLeadsProvider);
        expect(leads, everyElement(isA<Lead>()));
      });

      test('leads span multiple stages', () {
        final leads = container.read(allLeadsProvider);
        final stages = leads.map((l) => l.stage).toSet();
        expect(stages.length, greaterThanOrEqualTo(3));
      });

      test('updateLead() replaces lead with matching id', () {
        final leads = container.read(allLeadsProvider);
        final original = leads.first;
        final updated = original.copyWith(stage: LeadStage.won);
        container.read(allLeadsProvider.notifier).updateLead(updated);
        final result = container.read(allLeadsProvider);
        final found = result.firstWhere((l) => l.id == original.id);
        expect(found.stage, LeadStage.won);
      });
    });

    // -------------------------------------------------------------------------
    // leadStageFilterProvider
    // -------------------------------------------------------------------------
    group('leadStageFilterProvider', () {
      test('initial state is null (show all)', () {
        expect(container.read(leadStageFilterProvider), isNull);
      });

      test('can be set to a specific stage', () {
        container
            .read(leadStageFilterProvider.notifier)
            .update(LeadStage.qualified);
        expect(container.read(leadStageFilterProvider), LeadStage.qualified);
      });

      test('can be cleared to null', () {
        container
            .read(leadStageFilterProvider.notifier)
            .update(LeadStage.negotiation);
        container.read(leadStageFilterProvider.notifier).update(null);
        expect(container.read(leadStageFilterProvider), isNull);
      });

      test('supports all LeadStage values', () {
        for (final stage in LeadStage.values) {
          container.read(leadStageFilterProvider.notifier).update(stage);
          expect(container.read(leadStageFilterProvider), stage);
        }
      });
    });

    // -------------------------------------------------------------------------
    // filteredLeadsProvider
    // -------------------------------------------------------------------------
    group('filteredLeadsProvider', () {
      test('returns all leads when filter is null', () {
        final all = container.read(allLeadsProvider);
        final filtered = container.read(filteredLeadsProvider);
        expect(filtered.length, all.length);
      });

      test('filters leads by stage', () {
        container
            .read(leadStageFilterProvider.notifier)
            .update(LeadStage.newLead);
        final filtered = container.read(filteredLeadsProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((l) => l.stage == LeadStage.newLead), isTrue);
      });

      test('filters leads by lost stage', () {
        container.read(leadStageFilterProvider.notifier).update(LeadStage.lost);
        final filtered = container.read(filteredLeadsProvider);
        // All filtered results should match the filter
        expect(filtered.every((l) => l.stage == LeadStage.lost), isTrue);
      });

      test('clearing filter returns all leads', () {
        container
            .read(leadStageFilterProvider.notifier)
            .update(LeadStage.contacted);
        container.read(leadStageFilterProvider.notifier).update(null);
        final all = container.read(allLeadsProvider);
        final filtered = container.read(filteredLeadsProvider);
        expect(filtered.length, all.length);
      });
    });

    // -------------------------------------------------------------------------
    // allCampaignsProvider
    // -------------------------------------------------------------------------
    group('allCampaignsProvider', () {
      test('initial state is non-empty list', () {
        final campaigns = container.read(allCampaignsProvider);
        expect(campaigns, isNotEmpty);
      });

      test('all items are Campaign objects', () {
        final campaigns = container.read(allCampaignsProvider);
        expect(campaigns, everyElement(isA<Campaign>()));
      });

      test('updateCampaign() replaces campaign with matching id', () {
        final campaigns = container.read(allCampaignsProvider);
        final original = campaigns.first;
        final updated = original.copyWith(leadsGenerated: 999);
        container.read(allCampaignsProvider.notifier).updateCampaign(updated);
        final result = container.read(allCampaignsProvider);
        final found = result.firstWhere((c) => c.id == original.id);
        expect(found.leadsGenerated, 999);
      });
    });

    // -------------------------------------------------------------------------
    // leadFunnelSummaryProvider
    // -------------------------------------------------------------------------
    group('leadFunnelSummaryProvider', () {
      test('returns a non-empty map', () {
        final summary = container.read(leadFunnelSummaryProvider);
        expect(summary, isNotEmpty);
      });

      test('summary contains totalLeads key', () {
        final summary = container.read(leadFunnelSummaryProvider);
        expect(summary.containsKey('totalLeads'), isTrue);
      });

      test('totalLeads matches all leads count', () {
        final leads = container.read(allLeadsProvider);
        final summary = container.read(leadFunnelSummaryProvider);
        expect(summary['totalLeads'], leads.length);
      });
    });
  });
}
