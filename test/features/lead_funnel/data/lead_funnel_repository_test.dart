import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/lead_funnel/domain/models/lead.dart';
import 'package:ca_app/features/lead_funnel/domain/models/campaign.dart';
import 'package:ca_app/features/lead_funnel/data/repositories/mock_lead_funnel_repository.dart';

void main() {
  group('MockLeadFunnelRepository', () {
    late MockLeadFunnelRepository repo;

    setUp(() {
      repo = MockLeadFunnelRepository();
    });

    // -----------------------------------------------------------------------
    // Lead tests
    // -----------------------------------------------------------------------

    group('getLeads', () {
      test('returns seeded leads', () async {
        final results = await repo.getLeads();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getLeads();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getLeadsByStage', () {
      test('returns only leads of matching stage', () async {
        final all = await repo.getLeads();
        final stage = all.first.stage;
        final results = await repo.getLeadsByStage(stage);
        expect(results.every((l) => l.stage == stage), isTrue);
      });
    });

    group('getLeadsBySource', () {
      test('returns only leads of matching source', () async {
        final all = await repo.getLeads();
        final source = all.first.source;
        final results = await repo.getLeadsBySource(source);
        expect(results.every((l) => l.source == source), isTrue);
      });
    });

    group('getLeadById', () {
      test('returns lead for known id', () async {
        final all = await repo.getLeads();
        final id = all.first.id;
        final result = await repo.getLeadById(id);
        expect(result, isNotNull);
        expect(result!.id, equals(id));
      });

      test('returns null for unknown id', () async {
        final result = await repo.getLeadById('no-such-id');
        expect(result, isNull);
      });
    });

    group('insertLead', () {
      test('inserts and returns id', () async {
        final lead = Lead(
          id: 'test-lead-001',
          name: 'Test Lead',
          phone: '9876543210',
          source: LeadSource.referral,
          stage: LeadStage.newLead,
          estimatedValue: 15000,
          assignedTo: 'CA Test',
          createdAt: DateTime(2026, 3, 1),
          notes: 'Test lead notes',
        );
        final id = await repo.insertLead(lead);
        expect(id, equals('test-lead-001'));
      });

      test('inserted lead is retrievable', () async {
        final lead = Lead(
          id: 'test-lead-002',
          name: 'Retrievable Lead',
          phone: '9123456789',
          source: LeadSource.website,
          stage: LeadStage.contacted,
          estimatedValue: 25000,
          assignedTo: 'CA Another',
          createdAt: DateTime(2026, 3, 5),
          notes: 'Website inquiry',
        );
        await repo.insertLead(lead);
        final result = await repo.getLeadById('test-lead-002');
        expect(result, isNotNull);
      });
    });

    group('updateLead', () {
      test('updates stage and returns true', () async {
        final all = await repo.getLeads();
        final original = all.first;
        final updated = original.copyWith(stage: LeadStage.won);
        final success = await repo.updateLead(updated);
        expect(success, isTrue);

        final after = await repo.getLeadById(original.id);
        expect(after?.stage, LeadStage.won);
      });

      test('returns false for non-existent id', () async {
        final ghost = Lead(
          id: 'no-such-id',
          name: 'Ghost',
          phone: '0000000000',
          source: LeadSource.walkin,
          stage: LeadStage.newLead,
          estimatedValue: 0,
          assignedTo: 'Nobody',
          createdAt: DateTime(2026, 1, 1),
          notes: '',
        );
        final success = await repo.updateLead(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteLead', () {
      test('deletes seeded lead and returns true', () async {
        final all = await repo.getLeads();
        final id = all.first.id;
        final success = await repo.deleteLead(id);
        expect(success, isTrue);

        final after = await repo.getLeadById(id);
        expect(after, isNull);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteLead('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Campaign tests
    // -----------------------------------------------------------------------

    group('getCampaigns', () {
      test('returns seeded campaigns', () async {
        final results = await repo.getCampaigns();
        expect(results, isNotEmpty);
      });
    });

    group('getCampaignsByStatus', () {
      test('returns only campaigns with matching status', () async {
        final all = await repo.getCampaigns();
        final status = all.first.status;
        final results = await repo.getCampaignsByStatus(status);
        expect(results.every((c) => c.status == status), isTrue);
      });
    });

    group('insertCampaign', () {
      test('inserts and returns id', () async {
        final campaign = Campaign(
          id: 'test-campaign-001',
          title: 'ITR Season Push',
          type: CampaignType.itrSeason,
          status: CampaignStatus.planning,
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 31),
          budget: 10000,
          leadsGenerated: 0,
          conversions: 0,
          targetService: 'ITR Filing',
        );
        final id = await repo.insertCampaign(campaign);
        expect(id, equals('test-campaign-001'));
      });
    });

    group('updateCampaign', () {
      test('updates status and returns true', () async {
        final all = await repo.getCampaigns();
        final original = all.first;
        final updated = original.copyWith(status: CampaignStatus.completed);
        final success = await repo.updateCampaign(updated);
        expect(success, isTrue);

        final after = await repo.getCampaigns();
        final found = after.firstWhere((c) => c.id == original.id);
        expect(found.status, CampaignStatus.completed);
      });

      test('returns false for non-existent id', () async {
        final ghost = Campaign(
          id: 'no-such-campaign',
          title: 'Ghost',
          type: CampaignType.newBusiness,
          status: CampaignStatus.planning,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 2, 1),
          budget: 0,
          leadsGenerated: 0,
          conversions: 0,
          targetService: 'None',
        );
        final success = await repo.updateCampaign(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteCampaign', () {
      test('deletes seeded campaign and returns true', () async {
        final all = await repo.getCampaigns();
        final id = all.first.id;
        final success = await repo.deleteCampaign(id);
        expect(success, isTrue);

        final after = await repo.getCampaigns();
        expect(after.any((c) => c.id == id), isFalse);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteCampaign('no-such-id-xyz');
        expect(success, isFalse);
      });
    });
  });
}
