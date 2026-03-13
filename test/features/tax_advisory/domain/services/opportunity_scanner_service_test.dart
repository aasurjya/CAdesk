import 'package:ca_app/features/tax_advisory/domain/models/client_profile.dart';
import 'package:ca_app/features/tax_advisory/domain/models/tax_opportunity.dart';
import 'package:ca_app/features/tax_advisory/domain/services/opportunity_scanner_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Base profile helpers
  // ---------------------------------------------------------------------------

  const int fy = 2025;

  /// A salaried individual in old regime with no deductions.
  const ClientProfile baseIndividual = ClientProfile(
    pan: 'ABCDE1234F',
    name: 'Test User',
    clientType: ClientType.individual,
    annualIncome: 80000000, // ₹8,00,000 in paise
    taxRegime: TaxRegime.old,
    currentDeductions: 0,
    currentTaxPaid: 0,
    hasGstRegistration: false,
    hasTdsDeductions: true,
    hasCapitalGains: false,
    hasForeignAssets: false,
    hasBusinessIncome: false,
    ageGroup: AgeGroup.thirties,
  );

  // ---------------------------------------------------------------------------
  // scan — 80C opportunity
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scan — 80C not maxed', () {
    test('returns 80C opportunity when deductions < ₹1.5L', () {
      // ₹50,000 current deductions → gap of ₹1,00,000
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test User',
        clientType: ClientType.individual,
        annualIncome: 80000000,
        taxRegime: TaxRegime.old,
        currentDeductions: 5000000, // ₹50,000
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.thirties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      expect(
        opportunities.any((o) => o.type == OpportunityType.taxSaving),
        isTrue,
      );
    });

    test('does NOT return 80C opportunity when deductions >= ₹1.5L', () {
      // ₹1,50,000 deductions — already maxed
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test User',
        clientType: ClientType.individual,
        annualIncome: 80000000,
        taxRegime: TaxRegime.old,
        currentDeductions: 15000000, // ₹1,50,000
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.thirties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );
      final sec80cOpps = opportunities.where(
        (o) =>
            o.type == OpportunityType.taxSaving && o.sections.contains('80C'),
      );
      expect(sec80cOpps.isEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // scan — 80D health insurance
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scan — 80D health insurance', () {
    test('returns 80D opportunity when no deductions claimed', () {
      final opportunities = OpportunityScannerService.instance.scan(
        baseIndividual,
        fy,
      );

      expect(opportunities.any((o) => o.sections.contains('80D')), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // scan — old regime advantage
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scan — regime switch', () {
    test('suggests switching to old regime when new regime and '
        'deductions > ₹3.75L', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test User',
        clientType: ClientType.individual,
        annualIncome: 150000000, // ₹15L
        taxRegime: TaxRegime.newRegime,
        currentDeductions: 40000000, // ₹4L — more than ₹3.75L break-even
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.thirties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      expect(
        opportunities.any((o) => o.type == OpportunityType.restructuring),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // scan — capital loss harvesting
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scan — capital gains', () {
    test('returns capital gain opportunity when hasCapitalGains = true', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test User',
        clientType: ClientType.individual,
        annualIncome: 80000000,
        taxRegime: TaxRegime.old,
        currentDeductions: 0,
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: true,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.thirties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      expect(
        opportunities.any((o) => o.type == OpportunityType.investmentPlanning),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // scan — business income without GST
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scan — GST registration', () {
    test('returns compliance gap for business income > ₹20L without GST', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test User',
        clientType: ClientType.individual,
        annualIncome: 250000000, // ₹25L business income
        taxRegime: TaxRegime.old,
        currentDeductions: 0,
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: true,
        ageGroup: AgeGroup.thirties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      expect(
        opportunities.any((o) => o.type == OpportunityType.complianceGap),
        isTrue,
      );
    });

    test('no GST compliance gap when already registered', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test User',
        clientType: ClientType.individual,
        annualIncome: 250000000,
        taxRegime: TaxRegime.old,
        currentDeductions: 0,
        currentTaxPaid: 0,
        hasGstRegistration: true,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: true,
        ageGroup: AgeGroup.thirties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      final gstGap = opportunities.where(
        (o) =>
            o.type == OpportunityType.complianceGap &&
            o.sections.contains('GST'),
      );
      expect(gstGap.isEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // scan — senior citizen 80TTB
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scan — senior citizen 80TTB', () {
    test('returns retirement planning opportunity for above60', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Senior User',
        clientType: ClientType.individual,
        annualIncome: 80000000,
        taxRegime: TaxRegime.old,
        currentDeductions: 0,
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: true,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.above60,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      expect(
        opportunities.any((o) => o.type == OpportunityType.retirementPlanning),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // scan — Schedule AL (wealth statement)
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scan — Schedule AL', () {
    test('returns compliance gap for income > ₹50L', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'HNI User',
        clientType: ClientType.individual,
        annualIncome: 600000000, // ₹60L
        taxRegime: TaxRegime.old,
        currentDeductions: 0,
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: true,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.forties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      expect(
        opportunities.any(
          (o) =>
              o.type == OpportunityType.complianceGap &&
              o.sections.contains('Schedule AL'),
        ),
        isTrue,
      );
    });

    test('no Schedule AL gap for income <= ₹50L', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Normal User',
        clientType: ClientType.individual,
        annualIncome: 400000000, // ₹40L
        taxRegime: TaxRegime.old,
        currentDeductions: 0,
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: true,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.forties,
      );

      final opportunities = OpportunityScannerService.instance.scan(
        profile,
        fy,
      );

      final scheduleAl = opportunities.where(
        (o) =>
            o.type == OpportunityType.complianceGap &&
            o.sections.contains('Schedule AL'),
      );
      expect(scheduleAl.isEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // scoreOpportunity
  // ---------------------------------------------------------------------------

  group('OpportunityScannerService.scoreOpportunity', () {
    test('returns value between 0.0 and 1.0', () {
      const opp = TaxOpportunity(
        opportunityId: 'opp-1',
        clientPan: 'ABCDE1234F',
        type: OpportunityType.taxSaving,
        title: 'Invest in PPF',
        description: 'Max out 80C limit',
        potentialSaving: 4500000,
        confidence: 0.9,
        urgency: OpportunityUrgency.thisYear,
        requiredAction: 'Invest ₹1L in PPF before 31 March',
        estimatedFee: 500000,
        sections: ['80C'],
      );

      final score = OpportunityScannerService.instance.scoreOpportunity(
        opp,
        baseIndividual,
      );

      expect(score, greaterThanOrEqualTo(0.0));
      expect(score, lessThanOrEqualTo(1.0));
    });

    test('higher confidence opportunity scores higher', () {
      const highConf = TaxOpportunity(
        opportunityId: 'opp-high',
        clientPan: 'ABCDE1234F',
        type: OpportunityType.taxSaving,
        title: 'High confidence',
        description: 'desc',
        potentialSaving: 4500000,
        confidence: 0.95,
        urgency: OpportunityUrgency.immediate,
        requiredAction: 'Act now',
        estimatedFee: 500000,
        sections: ['80C'],
      );

      const lowConf = TaxOpportunity(
        opportunityId: 'opp-low',
        clientPan: 'ABCDE1234F',
        type: OpportunityType.taxSaving,
        title: 'Low confidence',
        description: 'desc',
        potentialSaving: 4500000,
        confidence: 0.3,
        urgency: OpportunityUrgency.longTerm,
        requiredAction: 'Consider later',
        estimatedFee: 500000,
        sections: ['80C'],
      );

      final highScore = OpportunityScannerService.instance.scoreOpportunity(
        highConf,
        baseIndividual,
      );
      final lowScore = OpportunityScannerService.instance.scoreOpportunity(
        lowConf,
        baseIndividual,
      );

      expect(highScore, greaterThan(lowScore));
    });
  });
}
