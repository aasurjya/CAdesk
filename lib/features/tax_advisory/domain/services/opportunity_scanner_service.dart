import 'package:ca_app/features/tax_advisory/domain/models/client_profile.dart';
import 'package:ca_app/features/tax_advisory/domain/models/tax_opportunity.dart';

/// Stateless singleton service that scans a [ClientProfile] for tax advisory
/// opportunities using rule-based detection (FY 2024-25 rules).
///
/// All monetary thresholds use paise (1 ₹ = 100 paise).
class OpportunityScannerService {
  OpportunityScannerService._();

  static final OpportunityScannerService instance =
      OpportunityScannerService._();

  // ---------------------------------------------------------------------------
  // Constants (paise)
  // ---------------------------------------------------------------------------

  static const int _section80cLimit = 15000000; // ₹1,50,000
  static const int _section80dSelfFamily = 2500000; // ₹25,000
  static const int _section80ttbSenior = 5000000; // ₹50,000
  static const int _gstThreshold = 2000000000; // ₹20,00,000 = 20L in paise

  // ₹3.75L — break-even deductions for old vs new regime
  static const int _regimeBreakevenDeductions = 37500000;

  static const int _scheduleAlThreshold = 5000000000; // ₹50L in paise

  // Urgency score weights for scoring
  static const Map<OpportunityUrgency, double> _urgencyWeights = {
    OpportunityUrgency.immediate: 1.0,
    OpportunityUrgency.thisYear: 0.8,
    OpportunityUrgency.nextYear: 0.5,
    OpportunityUrgency.longTerm: 0.3,
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Scans [profile] for all applicable tax saving / compliance opportunities
  /// for [financialYear] (e.g. 2025 for FY 2024-25).
  ///
  /// Returns an unordered list; use [ProposalGeneratorService.rankOpportunities]
  /// to sort them.
  List<TaxOpportunity> scan(ClientProfile profile, int financialYear) {
    final opportunities = <TaxOpportunity>[];

    opportunities.addAll(_check80c(profile));
    opportunities.addAll(_check80d(profile));
    opportunities.addAll(_checkRegimeSwitch(profile));
    opportunities.addAll(_checkCapitalGains(profile));
    opportunities.addAll(_checkGstRegistration(profile));
    opportunities.addAll(_checkSeniorCitizen80ttb(profile));
    opportunities.addAll(_checkScheduleAl(profile));

    return List.unmodifiable(opportunities);
  }

  /// Scores an [opportunity] for relevance to [profile].
  ///
  /// Returns a value in [0.0, 1.0] combining confidence and urgency weight.
  double scoreOpportunity(TaxOpportunity opp, ClientProfile profile) {
    final urgencyWeight =
        _urgencyWeights[opp.urgency] ?? 0.5;

    // Weighted combination: 70% confidence, 30% urgency
    final raw = (opp.confidence * 0.7) + (urgencyWeight * 0.3);

    return raw.clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------------
  // Rule: Section 80C not maxed
  // ---------------------------------------------------------------------------

  List<TaxOpportunity> _check80c(ClientProfile profile) {
    // 80C only applies to old regime and individuals / HUF
    if (profile.taxRegime != TaxRegime.old) return const [];
    if (profile.clientType != ClientType.individual &&
        profile.clientType != ClientType.huf) {
      return const [];
    }

    final gap = _section80cLimit - profile.currentDeductions;
    if (gap <= 0) return const [];

    // Estimate saving: gap × marginal rate (approx 20% for typical income)
    final marginalRate = _marginalRate(profile.annualIncome);
    final saving = (gap * marginalRate).round();

    return [
      TaxOpportunity(
        opportunityId: '${profile.pan}_80C_${DateTime.now().year}',
        clientPan: profile.pan,
        type: OpportunityType.taxSaving,
        title: 'Maximise Section 80C Deductions',
        description:
            'Invest ₹${_paiseToCrore(gap)} in PPF, ELSS, LIC, NSC or '
            'home loan principal to claim full 80C deduction of ₹1.5L.',
        potentialSaving: saving,
        confidence: 0.9,
        urgency: OpportunityUrgency.thisYear,
        requiredAction:
            'Invest ₹${_paise(gap)} before 31 March in eligible 80C instruments.',
        estimatedFee: 200000, // ₹2,000
        sections: const ['80C'],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Rule: Section 80D (health insurance)
  // ---------------------------------------------------------------------------

  List<TaxOpportunity> _check80d(ClientProfile profile) {
    if (profile.taxRegime != TaxRegime.old) return const [];

    // Assume 80D not claimed if currentDeductions don't cover it
    // (rough heuristic: if total deductions < 80D self limit, likely not claimed)
    if (profile.currentDeductions >= _section80dSelfFamily) return const [];

    final isSenior = profile.ageGroup == AgeGroup.above60;
    final selfLimit = isSenior ? 5000000 : _section80dSelfFamily; // ₹50K or ₹25K
    final marginalRate = _marginalRate(profile.annualIncome);
    final saving = (selfLimit * marginalRate).round();

    return [
      TaxOpportunity(
        opportunityId: '${profile.pan}_80D_${DateTime.now().year}',
        clientPan: profile.pan,
        type: OpportunityType.taxSaving,
        title: 'Claim Section 80D Health Insurance Premium',
        description:
            'Health insurance premium up to ₹${_paise(selfLimit)} for self '
            'and family is deductible under Section 80D.',
        potentialSaving: saving,
        confidence: 0.85,
        urgency: OpportunityUrgency.thisYear,
        requiredAction:
            'Purchase health insurance policy and keep premium receipts.',
        estimatedFee: 150000, // ₹1,500
        sections: const ['80D'],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Rule: Regime switch — old regime advantageous
  // ---------------------------------------------------------------------------

  List<TaxOpportunity> _checkRegimeSwitch(ClientProfile profile) {
    if (profile.taxRegime != TaxRegime.newRegime) return const [];

    if (profile.currentDeductions <= _regimeBreakevenDeductions) {
      return const [];
    }

    // Rough saving: extra deductions × marginal rate
    final extraDeductions =
        profile.currentDeductions - _regimeBreakevenDeductions;
    final marginalRate = _marginalRate(profile.annualIncome);
    final saving = (extraDeductions * marginalRate).round();

    return [
      TaxOpportunity(
        opportunityId: '${profile.pan}_REGIME_${DateTime.now().year}',
        clientPan: profile.pan,
        type: OpportunityType.restructuring,
        title: 'Switch to Old Tax Regime',
        description:
            'Your total deductions (₹${_paise(profile.currentDeductions)}) '
            'exceed the break-even point of ₹3.75L. The old regime is likely '
            'more beneficial.',
        potentialSaving: saving,
        confidence: 0.8,
        urgency: OpportunityUrgency.thisYear,
        requiredAction:
            'Opt for old regime when filing ITR or with your employer.',
        estimatedFee: 300000, // ₹3,000
        sections: const ['Old Regime', 'New Regime'],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Rule: Capital gains — loss harvesting opportunity
  // ---------------------------------------------------------------------------

  List<TaxOpportunity> _checkCapitalGains(ClientProfile profile) {
    if (!profile.hasCapitalGains) return const [];

    return [
      TaxOpportunity(
        opportunityId: '${profile.pan}_CAPGAIN_${DateTime.now().year}',
        clientPan: profile.pan,
        type: OpportunityType.investmentPlanning,
        title: 'Capital Loss Harvesting',
        description:
            'Sell loss-making positions before 31 March to offset capital gains '
            'and reduce tax liability.',
        potentialSaving: 1500000, // conservative ₹15K estimate
        confidence: 0.7,
        urgency: OpportunityUrgency.immediate,
        requiredAction:
            'Review portfolio for unrealised losses and sell before year-end.',
        estimatedFee: 250000, // ₹2,500
        sections: const ['Capital Gains', 'LTCG', 'STCG'],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Rule: Business income without GST registration
  // ---------------------------------------------------------------------------

  List<TaxOpportunity> _checkGstRegistration(ClientProfile profile) {
    if (!profile.hasBusinessIncome) return const [];
    if (profile.hasGstRegistration) return const [];
    if (profile.annualIncome <= _gstThreshold) return const [];

    return [
      TaxOpportunity(
        opportunityId: '${profile.pan}_GST_${DateTime.now().year}',
        clientPan: profile.pan,
        type: OpportunityType.complianceGap,
        title: 'GST Registration Required',
        description:
            'Business turnover exceeds ₹20L threshold. GST registration is '
            'mandatory and non-compliance attracts penalties.',
        potentialSaving: 0,
        confidence: 0.95,
        urgency: OpportunityUrgency.immediate,
        requiredAction: 'Apply for GST registration immediately.',
        estimatedFee: 500000, // ₹5,000
        sections: const ['GST'],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Rule: Senior citizen — Section 80TTB vs 80TTA
  // ---------------------------------------------------------------------------

  List<TaxOpportunity> _checkSeniorCitizen80ttb(ClientProfile profile) {
    if (profile.ageGroup != AgeGroup.above60) return const [];
    if (profile.taxRegime != TaxRegime.old) return const [];
    if (!profile.hasTdsDeductions) return const [];

    // 80TTB allows ₹50K for seniors vs ₹10K (80TTA) for others
    final additionalDeduction = _section80ttbSenior - 1000000; // ₹40K gap
    final marginalRate = _marginalRate(profile.annualIncome);
    final saving = (additionalDeduction * marginalRate).round();

    return [
      TaxOpportunity(
        opportunityId: '${profile.pan}_80TTB_${DateTime.now().year}',
        clientPan: profile.pan,
        type: OpportunityType.retirementPlanning,
        title: 'Senior Citizen Interest Deduction (80TTB)',
        description:
            'As a senior citizen (60+), you can claim ₹50,000 deduction on '
            'interest income from banks and post offices under Section 80TTB '
            '(vs ₹10,000 under 80TTA).',
        potentialSaving: saving,
        confidence: 0.9,
        urgency: OpportunityUrgency.thisYear,
        requiredAction:
            'Ensure interest income from savings accounts and FDs is declared '
            'and 80TTB is claimed in ITR.',
        estimatedFee: 200000, // ₹2,000
        sections: const ['80TTB', '80TTA'],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Rule: Income > ₹50L — Schedule AL mandatory
  // ---------------------------------------------------------------------------

  List<TaxOpportunity> _checkScheduleAl(ClientProfile profile) {
    if (profile.annualIncome <= _scheduleAlThreshold) return const [];

    return [
      TaxOpportunity(
        opportunityId: '${profile.pan}_SCHEDAL_${DateTime.now().year}',
        clientPan: profile.pan,
        type: OpportunityType.complianceGap,
        title: 'Schedule AL — Wealth Statement Mandatory',
        description:
            'Income exceeds ₹50L. Schedule AL (Assets and Liabilities) '
            'disclosure is mandatory in ITR. Non-compliance attracts ₹5,000 penalty.',
        potentialSaving: 0,
        confidence: 1.0,
        urgency: OpportunityUrgency.immediate,
        requiredAction:
            'Disclose all assets and liabilities in Schedule AL of your ITR.',
        estimatedFee: 300000, // ₹3,000
        sections: const ['Schedule AL'],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Approximate marginal tax rate based on taxable income (old regime slabs).
  double _marginalRate(int annualIncomePaise) {
    // Income in rupees
    final incomeRs = annualIncomePaise / 100;

    if (incomeRs <= 250000) return 0.0;
    if (incomeRs <= 500000) return 0.05;
    if (incomeRs <= 1000000) return 0.20;
    return 0.30;
  }

  /// Formats paise to short rupee string (e.g. "₹1.5L").
  String _paise(int paise) {
    final rupees = paise / 100;
    if (rupees >= 100000) {
      final lakhs = rupees / 100000;
      return '₹${lakhs.toStringAsFixed(1)}L';
    }
    return '₹${rupees.toStringAsFixed(0)}';
  }

  /// Alias for rare crore-scale display — delegates to [_paise].
  String _paiseToCrore(int paise) => _paise(paise);
}
