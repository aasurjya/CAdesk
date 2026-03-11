import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/industry_playbooks/domain/models/service_bundle.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/vertical_playbook.dart';

// ---------------------------------------------------------------------------
// Static data — all 10 vertical playbooks
// ---------------------------------------------------------------------------

final allPlaybooksProvider = Provider<List<VerticalPlaybook>>((ref) {
  return const [
    VerticalPlaybook(
      id: 'vp-ecommerce',
      vertical: 'e-commerce',
      icon: '🛒',
      description:
          'Flipkart/Amazon sellers — marketplace TDS 194-O, GST reconciliation '
          'across portals, and payment gateway settlement matching.',
      complianceChecklist: [
        'Monthly GSTR-1 & GSTR-3B filing',
        'TDS 194-O deducted by marketplace reconciliation',
        'Annual ITR-3/ITR-4 with business schedule',
        'Payment gateway settlement reconciliation',
      ],
      typicalRisks: [
        'Mismatch between GSTR-2B and marketplace TCS data',
        'Underreported turnover due to return/refund netting',
        'Late TDS 194-O credit claim',
      ],
      activeClients: 38,
      avgRetainerValue: 0.85,
      winRate: 0.72,
      marginPercent: 0.54,
    ),
    VerticalPlaybook(
      id: 'vp-exporters',
      vertical: 'exporters',
      icon: '🚢',
      description:
          'Merchandise & service exporters — LUT/bond filing, IGST refunds, '
          'FEMA remittance compliance, and BRC (Bank Realisation Certificates).',
      complianceChecklist: [
        'Annual LUT filing before first export',
        'IGST refund application within 2 years of export',
        'FEMA Form A2 / FC-GPR / FC-TRS as applicable',
        'Bank Realisation Certificate within 9 months',
      ],
      typicalRisks: [
        'Lapsed LUT leading to blocked IGST input',
        'FEMA non-compliance penalties up to 3× the amount',
        'Delayed BRC resulting in export benefit forfeiture',
      ],
      activeClients: 22,
      avgRetainerValue: 1.20,
      winRate: 0.65,
      marginPercent: 0.61,
    ),
    VerticalPlaybook(
      id: 'vp-doctors',
      vertical: 'doctors',
      icon: '🩺',
      description:
          'Doctors & clinic owners — 44ADA presumptive taxation, medical '
          'equipment depreciation planning, salary structuring for employed staff.',
      complianceChecklist: [
        '44ADA presumptive income declaration (50% of receipts)',
        'Medical equipment depreciation schedule (40% WDV)',
        'Advance tax computation (June/Sept/Dec/March)',
        'Salary TDS for clinic employees',
      ],
      typicalRisks: [
        'Professional receipts exceeding ₹75 L threshold — mandatory audit',
        'Incorrect depreciation rate for diagnostic equipment',
        'GST liability on cosmetic procedures (18%)',
      ],
      activeClients: 45,
      avgRetainerValue: 0.60,
      winRate: 0.80,
      marginPercent: 0.68,
    ),
    VerticalPlaybook(
      id: 'vp-realestate',
      vertical: 'real-estate',
      icon: '🏡',
      description:
          'Property investors & landlords — Sec 54/54F exemptions, TDS 194-IA '
          'on purchases, joint development agreement taxation.',
      complianceChecklist: [
        'TDS 194-IA @ 1% on property purchase > ₹50 L',
        'Capital gain computation with indexation (Sec 48)',
        'Sec 54/54F reinvestment within 2/3 years',
        'JDA revenue recognition under Sec 45(5A)',
      ],
      typicalRisks: [
        'Missed 194-IA TDS leading to buyer penalty + interest',
        'Wrong holding period — STCG vs LTCG classification',
        'JDA stamp duty vs income recognition mismatch',
      ],
      activeClients: 29,
      avgRetainerValue: 1.50,
      winRate: 0.58,
      marginPercent: 0.57,
    ),
    VerticalPlaybook(
      id: 'vp-saas',
      vertical: 'saas',
      icon: '💻',
      description:
          'SaaS & tech startups — Sec 80-IAC tax holiday, ESOP perquisite '
          'taxation, R&D weighted deduction under Sec 35(2AB).',
      complianceChecklist: [
        'DPIIT recognition for Sec 80-IAC eligibility',
        'ESOP valuation by merchant banker at grant date',
        'R&D expenditure approval from Dept of Scientific Research',
        'Angel tax exemption under Sec 56(2)(viib)',
      ],
      typicalRisks: [
        'Angel tax triggered on premium valuation from non-DPIIT investors',
        'ESOP perquisite tax mismatch at exercise vs sale',
        'Overseas subsidiary creating PE risk in India',
      ],
      activeClients: 17,
      avgRetainerValue: 2.00,
      winRate: 0.55,
      marginPercent: 0.52,
    ),
    VerticalPlaybook(
      id: 'vp-creators',
      vertical: 'creators',
      icon: '🎬',
      description:
          'YouTubers, influencers & podcasters — 44ADA presumptive income, '
          'platform TDS reconciliation (194JB), international brand deal FEMA.',
      complianceChecklist: [
        '44ADA presumptive income on professional receipts',
        'TDS 194JB from YouTube / Meta reconciliation',
        'GST registration if receipts > ₹20 L (₹10 L special states)',
        'FEMA compliance for foreign brand sponsorships',
      ],
      typicalRisks: [
        'Under-declared income from barter/gifted products',
        'Missing GST on overseas brand deals (OIDAR services)',
        'Advance tax default if TDS < actual liability',
      ],
      activeClients: 31,
      avgRetainerValue: 0.45,
      winRate: 0.78,
      marginPercent: 0.70,
    ),
    VerticalPlaybook(
      id: 'vp-manufacturing',
      vertical: 'manufacturing',
      icon: '🏭',
      description:
          'SME manufacturers — GST job work provisions, depreciation planning '
          'for plant & machinery, MSME Samadhaan benefits.',
      complianceChecklist: [
        'GST job work challan under Sec 143 within 1/3 years',
        'Plant & machinery depreciation (15% SLM or WDV blocks)',
        'MSME Udyam registration for priority lending benefits',
        'Quarterly GSTR-1 if opted for quarterly scheme',
      ],
      typicalRisks: [
        'Job work goods not returned within time — deemed supply',
        'Excess depreciation on second-hand machinery',
        'MSME delayed payment interest (3× bank rate) if buyer defaults',
      ],
      activeClients: 24,
      avgRetainerValue: 1.10,
      winRate: 0.62,
      marginPercent: 0.59,
    ),
    VerticalPlaybook(
      id: 'vp-hospitality',
      vertical: 'hospitality',
      icon: '🏨',
      description:
          'Hotels, restaurants & tour operators — GST composite scheme, '
          'TCS on tour packages, PF/ESI labour compliance.',
      complianceChecklist: [
        'GST composite scheme (5%) for restaurants < ₹1.5 Cr',
        'TCS @ 5% on tour packages by tour operator',
        'PF/ESI monthly challan for staff > 20 employees',
        'Liquor licence TCS/TDS as applicable by state',
      ],
      typicalRisks: [
        'Incorrect GST rate — 5% vs 12% vs 18% hotel tariff bracket',
        'TCS non-collection on tour packages — penalty exposure',
        'Labour law non-compliance in peak-season hiring',
      ],
      activeClients: 19,
      avgRetainerValue: 0.90,
      winRate: 0.60,
      marginPercent: 0.55,
    ),
    VerticalPlaybook(
      id: 'vp-cafirms',
      vertical: 'ca-firms',
      icon: '⚖️',
      description:
          'Fellow CA firms — UDIN tracking, professional liability management, '
          'peer benchmarking for fee structures and service mix.',
      complianceChecklist: [
        'UDIN generation within 15 days of signing',
        'Form 3CA/3CB audit report filing with UDIN',
        'Professional liability insurance renewal',
        'ICAI CPE hours compliance (30/40 hours per year)',
      ],
      typicalRisks: [
        'UDIN revocation risk for incorrect certification',
        'Malpractice claim without adequate PI cover',
        'Concurrent audit conflict of interest — regulatory risk',
      ],
      activeClients: 12,
      avgRetainerValue: 0.75,
      winRate: 0.50,
      marginPercent: 0.65,
    ),
    VerticalPlaybook(
      id: 'vp-redev',
      vertical: 'real-estate-dev',
      icon: '🏗️',
      description:
          'Real estate developers — project-wise P&L under POC method, '
          'JDA/JV taxation, RERA escrow compliance.',
      complianceChecklist: [
        'Project-wise revenue recognition (Ind AS 115 / POC)',
        'JDA revenue under Sec 45(5A) at possession/completion',
        'RERA project registration and quarterly progress report',
        'TDS 194-IC on JDA development rights payment',
      ],
      typicalRisks: [
        'RERA penalty for construction delay without force majeure',
        'GST on under-construction flats — 1% affordable / 5% regular',
        'JV profit-sharing treated as capital gains vs business income',
      ],
      activeClients: 14,
      avgRetainerValue: 2.50,
      winRate: 0.53,
      marginPercent: 0.48,
    ),
  ];
});

// ---------------------------------------------------------------------------
// Static data — 8 service bundles
// ---------------------------------------------------------------------------

final allServiceBundlesProvider = Provider<List<ServiceBundle>>((ref) {
  return const [
    ServiceBundle(
      id: 'sb-ecom-starter',
      verticalId: 'vp-ecommerce',
      name: 'Marketplace Starter Pack',
      description:
          'Monthly GST filings + TDS 194-O reconciliation for single-platform sellers.',
      inclusions: [
        'GSTR-1 & GSTR-3B monthly filing',
        'TDS 194-O credit reconciliation',
        'Payment gateway settlement matching',
        'Quarterly ITR advance tax computation',
      ],
      pricePerMonth: 8000,
      turnaroundDays: 3,
      slaLabel: 'T+3 days',
      isPopular: false,
    ),
    ServiceBundle(
      id: 'sb-ecom-pro',
      verticalId: 'vp-ecommerce',
      name: 'Multi-Platform Growth Pack',
      description:
          'Full compliance for sellers active on 3+ marketplaces with annual ITR.',
      inclusions: [
        'GSTR-1, GSTR-3B & GSTR-9 annual',
        'Multi-platform TDS 194-O reconciliation',
        'GSTR-2B vs purchase register reconciliation',
        'Annual ITR-3 filing with P&L',
        'Notices handling — GST scrutiny',
      ],
      pricePerMonth: 18000,
      turnaroundDays: 2,
      slaLabel: 'T+2 days',
      isPopular: true,
    ),
    ServiceBundle(
      id: 'sb-export-igst',
      verticalId: 'vp-exporters',
      name: 'Export Refund Pack',
      description:
          'LUT filing, IGST refund applications, and BRC follow-up for exporters.',
      inclusions: [
        'Annual LUT filing on GST portal',
        'IGST refund application (RFD-01)',
        'Shipping bill reconciliation with GST returns',
        'Bank Realisation Certificate tracking',
        'FEMA Form A2 for service exports',
      ],
      pricePerMonth: 22000,
      turnaroundDays: 5,
      slaLabel: 'T+5 days',
      isPopular: true,
    ),
    ServiceBundle(
      id: 'sb-doctor-essentials',
      verticalId: 'vp-doctors',
      name: 'Clinic Essentials',
      description:
          'Annual ITR, advance tax, and staff TDS for individual doctors and clinics.',
      inclusions: [
        '44ADA income computation',
        'Advance tax quarterly challans',
        'Salary TDS for 1–10 clinic staff',
        'Medical equipment depreciation schedule',
      ],
      pricePerMonth: 7000,
      turnaroundDays: 2,
      slaLabel: 'T+2 days',
      isPopular: true,
    ),
    ServiceBundle(
      id: 'sb-saas-startup',
      verticalId: 'vp-saas',
      name: 'Startup Tax Shield',
      description:
          'DPIIT registration, Sec 80-IAC filing, ESOP perquisite tax management.',
      inclusions: [
        'DPIIT recognition application support',
        'Sec 80-IAC Form-1 filing',
        'ESOP perquisite computation at exercise',
        'Angel tax exemption Form 56F',
        'Quarterly advance tax and TDS',
      ],
      pricePerMonth: 35000,
      turnaroundDays: 7,
      slaLabel: 'T+7 days',
      isPopular: false,
    ),
    ServiceBundle(
      id: 'sb-creator-basic',
      verticalId: 'vp-creators',
      name: 'Creator Compliance Basic',
      description:
          'GST registration, 44ADA ITR, and platform TDS reconciliation for creators.',
      inclusions: [
        'GST registration & monthly GSTR-1/3B',
        '44ADA ITR-4 annual filing',
        'YouTube / Meta TDS 194JB reconciliation',
        'FEMA compliance for foreign brand deals',
      ],
      pricePerMonth: 5000,
      turnaroundDays: 2,
      slaLabel: 'T+2 days',
      isPopular: true,
    ),
    ServiceBundle(
      id: 'sb-mfg-gst',
      verticalId: 'vp-manufacturing',
      name: 'Manufacturing GST + Compliance',
      description:
          'End-to-end GST compliance including job work tracking and MSME registration.',
      inclusions: [
        'Monthly GSTR-1 & GSTR-3B filing',
        'Job work challan tracking (Sec 143)',
        'MSME Udyam registration support',
        'ITC reconciliation with purchase register',
        'Annual GSTR-9 & GSTR-9C',
      ],
      pricePerMonth: 15000,
      turnaroundDays: 3,
      slaLabel: 'T+3 days',
      isPopular: false,
    ),
    ServiceBundle(
      id: 'sb-redev-full',
      verticalId: 'vp-redev',
      name: 'Developer Full Compliance',
      description:
          'Project-wise accounts, RERA filings, JDA taxation, and GST for developers.',
      inclusions: [
        'Project-wise P&L under Ind AS 115 / POC',
        'RERA quarterly progress report filing',
        'JDA Sec 45(5A) tax computation',
        'GST on under-construction units (1%/5%)',
        'TDS 194-IC on JDA development rights',
      ],
      pricePerMonth: 50000,
      turnaroundDays: 7,
      slaLabel: 'T+7 days',
      isPopular: true,
    ),
  ];
});

// ---------------------------------------------------------------------------
// Filter state — using NotifierProvider for Riverpod v3 compatibility
// ---------------------------------------------------------------------------

final selectedVerticalProvider =
    NotifierProvider<SelectedVerticalNotifier, String?>(
      SelectedVerticalNotifier.new,
    );

class SelectedVerticalNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? vertical) {
    state = vertical;
  }
}

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

final filteredPlaybooksProvider = Provider<List<VerticalPlaybook>>((ref) {
  final all = ref.watch(allPlaybooksProvider);
  final selected = ref.watch(selectedVerticalProvider);
  if (selected == null) {
    return all;
  }
  return all.where((p) => p.vertical == selected).toList();
});

final bundlesForVerticalProvider = Provider.family<List<ServiceBundle>, String>(
  (ref, verticalId) {
    return ref
        .watch(allServiceBundlesProvider)
        .where((b) => b.verticalId == verticalId)
        .toList();
  },
);
