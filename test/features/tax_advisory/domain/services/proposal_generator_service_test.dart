import 'package:ca_app/features/tax_advisory/domain/models/client_profile.dart';
import 'package:ca_app/features/tax_advisory/domain/models/tax_opportunity.dart';
import 'package:ca_app/features/tax_advisory/domain/services/proposal_generator_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ClientProfile sampleProfile = ClientProfile(
    pan: 'ABCDE1234F',
    name: 'Ramesh Kumar',
    clientType: ClientType.individual,
    annualIncome: 100000000, // ₹10L
    taxRegime: TaxRegime.old,
    currentDeductions: 5000000, // ₹50K
    currentTaxPaid: 8000000, // ₹80K
    hasGstRegistration: false,
    hasTdsDeductions: true,
    hasCapitalGains: false,
    hasForeignAssets: false,
    hasBusinessIncome: false,
    ageGroup: AgeGroup.thirties,
  );

  const TaxOpportunity opp1 = TaxOpportunity(
    opportunityId: 'opp-1',
    clientPan: 'ABCDE1234F',
    type: OpportunityType.taxSaving,
    title: '80C Investment',
    description: 'Invest to max 80C',
    potentialSaving: 3000000, // ₹30K
    confidence: 0.9,
    urgency: OpportunityUrgency.thisYear,
    requiredAction: 'Invest in ELSS before March 31',
    estimatedFee: 200000, // ₹2K
    sections: ['80C'],
  );

  const TaxOpportunity opp2 = TaxOpportunity(
    opportunityId: 'opp-2',
    clientPan: 'ABCDE1234F',
    type: OpportunityType.taxSaving,
    title: '80D Health Insurance',
    description: 'Buy health insurance to claim 80D',
    potentialSaving: 2000000, // ₹20K
    confidence: 0.85,
    urgency: OpportunityUrgency.thisYear,
    requiredAction: 'Buy health insurance policy',
    estimatedFee: 150000, // ₹1.5K
    sections: ['80D'],
  );

  const TaxOpportunity opp3 = TaxOpportunity(
    opportunityId: 'opp-3',
    clientPan: 'ABCDE1234F',
    type: OpportunityType.complianceGap,
    title: 'Schedule AL Disclosure',
    description: 'Mandatory wealth disclosure',
    potentialSaving: 0,
    confidence: 1.0,
    urgency: OpportunityUrgency.immediate,
    requiredAction: 'File Schedule AL',
    estimatedFee: 300000, // ₹3K
    sections: ['Schedule AL'],
  );

  // ---------------------------------------------------------------------------
  // rankOpportunities
  // ---------------------------------------------------------------------------

  group('ProposalGeneratorService.rankOpportunities', () {
    test('sorts by potentialSaving × confidence descending', () {
      final ranked = ProposalGeneratorService.instance.rankOpportunities([
        opp2,
        opp3,
        opp1,
      ]);

      // opp1: 30000 * 0.9 = 27000
      // opp2: 20000 * 0.85 = 17000
      // opp3: 0 * 1.0 = 0
      expect(ranked.first.opportunityId, 'opp-1');
      expect(ranked[1].opportunityId, 'opp-2');
      expect(ranked.last.opportunityId, 'opp-3');
    });

    test('returns same length list', () {
      final ranked = ProposalGeneratorService.instance.rankOpportunities([
        opp1,
        opp2,
      ]);
      expect(ranked.length, 2);
    });

    test('empty list returns empty list', () {
      final ranked = ProposalGeneratorService.instance.rankOpportunities([]);
      expect(ranked.isEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // computeProposedFee
  // ---------------------------------------------------------------------------

  group('ProposalGeneratorService.computeProposedFee', () {
    test('base fee ₹5,000 when no potential savings', () {
      // opp3 has 0 savings
      final fee = ProposalGeneratorService.instance.computeProposedFee([opp3]);

      // base = ₹5,000 = 500000 paise
      expect(fee, 500000);
    });

    test('fee = ₹5,000 + 10% of savings, within cap', () {
      // opp1: ₹30K savings → fee = ₹5K + 10% of ₹30K = ₹5K + ₹3K = ₹8K
      final fee = ProposalGeneratorService.instance.computeProposedFee([opp1]);

      // 500000 + (3000000 * 10 / 100) = 500000 + 300000 = 800000
      expect(fee, 800000);
    });

    test('fee is capped at ₹50,000', () {
      // Very large savings: ₹10L → uncapped fee = ₹5K + ₹1L = ₹1.05L
      const bigOpp = TaxOpportunity(
        opportunityId: 'big',
        clientPan: 'ABCDE1234F',
        type: OpportunityType.taxSaving,
        title: 'Big saving',
        description: 'Large deduction',
        potentialSaving: 100000000, // ₹10L
        confidence: 1.0,
        urgency: OpportunityUrgency.thisYear,
        requiredAction: 'Invest',
        estimatedFee: 500000,
        sections: ['80C'],
      );

      final fee = ProposalGeneratorService.instance.computeProposedFee([
        bigOpp,
      ]);

      // cap = ₹50K = 5000000 paise
      expect(fee, 5000000);
    });

    test('fee adds savings from multiple opportunities', () {
      // opp1 ₹30K + opp2 ₹20K = ₹50K savings → 10% = ₹5K → total ₹10K
      final fee = ProposalGeneratorService.instance.computeProposedFee([
        opp1,
        opp2,
      ]);

      // 500000 + ((3000000 + 2000000) * 10 / 100) = 500000 + 500000 = 1000000
      expect(fee, 1000000);
    });
  });

  // ---------------------------------------------------------------------------
  // generate
  // ---------------------------------------------------------------------------

  group('ProposalGeneratorService.generate', () {
    test('returns AdvisoryProposal with correct clientPan', () {
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [opp1, opp2, opp3],
      );

      expect(proposal.clientPan, 'ABCDE1234F');
    });

    test('proposal includes non-empty proposalId', () {
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [opp1],
      );

      expect(proposal.proposalId.isNotEmpty, isTrue);
    });

    test('totalPotentialSaving sums top 5 opportunities', () {
      // Only 2 opps here: opp1 ₹30K + opp2 ₹20K = ₹50K
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [opp1, opp2],
      );

      expect(proposal.totalPotentialSaving, 5000000); // ₹50K in paise
    });

    test('roi = totalPotentialSaving / proposedFee', () {
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [opp1, opp2],
      );

      final expectedRoi = proposal.totalPotentialSaving / proposal.proposedFee;
      expect(proposal.roi, closeTo(expectedRoi, 0.001));
    });

    test('executiveSummary is non-empty', () {
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [opp1, opp2],
      );

      expect(proposal.executiveSummary.isNotEmpty, isTrue);
    });

    test('sections list is non-empty when opportunities provided', () {
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [opp1, opp2, opp3],
      );

      expect(proposal.sections.isNotEmpty, isTrue);
    });

    test('proposal generatedAt is recent', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [opp1],
      );
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(
        proposal.generatedAt.isAfter(before) &&
            proposal.generatedAt.isBefore(after),
        isTrue,
      );
    });

    test('handles empty opportunities list', () {
      final proposal = ProposalGeneratorService.instance.generate(
        sampleProfile,
        [],
      );

      expect(proposal.totalPotentialSaving, 0);
      expect(proposal.opportunities.isEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // generateExecutiveSummary
  // ---------------------------------------------------------------------------

  group('ProposalGeneratorService.generateExecutiveSummary', () {
    test('includes client name in summary', () {
      final summary = ProposalGeneratorService.instance
          .generateExecutiveSummary(sampleProfile, [opp1, opp2, opp3]);

      expect(summary.contains('Ramesh Kumar'), isTrue);
    });

    test('handles fewer than 3 opportunities gracefully', () {
      final summary = ProposalGeneratorService.instance
          .generateExecutiveSummary(sampleProfile, [opp1]);

      expect(summary.isNotEmpty, isTrue);
    });

    test('empty opportunities returns non-empty summary', () {
      final summary = ProposalGeneratorService.instance
          .generateExecutiveSummary(sampleProfile, []);

      expect(summary.isNotEmpty, isTrue);
    });
  });
}
