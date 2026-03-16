import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';
import 'package:ca_app/features/it_act_transition/domain/models/section_mapping.dart';

/// Bidirectional section mapper between IT Act 1961 and IT Act 2025.
///
/// All lookups are O(1) via pre-built hash maps.
/// Sources: CBDT official mapping tool, KDK 1961-vs-2025 mapper,
/// Income-tax Act 2025 as enacted (536 sections, 23 chapters).
class SectionMapperService {
  SectionMapperService._();

  static final Map<String, SectionMapping> _by1961 = {
    for (final m in _mappings) m.section1961: m,
  };

  static final Map<String, SectionMapping> _by2025 = {
    for (final m in _mappings) m.section2025: m,
  };

  static List<SectionMapping> get allMappings => List.unmodifiable(_mappings);

  static SectionMapping? from1961(String section) => _by1961[section];

  static SectionMapping? from2025(String section) => _by2025[section];

  static String displaySection({
    required String section1961,
    required ActMode mode,
  }) {
    if (mode == ActMode.act2025) {
      final mapping = from1961(section1961);
      if (mapping != null) return mapping.displaySection2025;
    }
    return 'Section $section1961';
  }

  static String dualDisplay(String section1961) {
    final mapping = from1961(section1961);
    return mapping?.dualDisplay ?? 'Section $section1961';
  }

  static List<SectionMapping> searchByDescription(String query) {
    final lower = query.toLowerCase();
    return _mappings
        .where((m) => m.description.toLowerCase().contains(lower))
        .toList();
  }

  static List<SectionMapping> byCategory(SectionCategory category) =>
      _mappings.where((m) => m.category == category).toList();

  // =========================================================================
  // MASTER DATA — 200+ mappings
  // =========================================================================
  static const List<SectionMapping> _mappings = [
    // --- GENERAL & DEFINITIONS ---
    SectionMapping(
      section1961: '2(14)',
      section2025: '2(11)',
      description: 'Definition of capital asset',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '2(22)',
      section2025: '2(16)',
      description: 'Definition of dividend',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '2(24)',
      section2025: '2(18)',
      description: 'Definition of income',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '2(31)',
      section2025: '2(24)',
      description: 'Definition of person',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '2(42A)',
      section2025: '2(35)',
      description: 'Definition of short-term capital asset',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '2(47)',
      section2025: '2(38)',
      description: 'Definition of transfer',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '3',
      section2025: '3',
      description: 'Previous year / Tax year',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '4',
      section2025: '4',
      description: 'Charge of income tax',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '5',
      section2025: '5',
      description: 'Scope of total income',
      category: SectionCategory.general,
    ),

    // --- RESIDENTIAL STATUS ---
    SectionMapping(
      section1961: '6',
      section2025: '6',
      description:
          'Residence in India — resident, NRI, not ordinarily resident',
      category: SectionCategory.residentialStatus,
    ),
    SectionMapping(
      section1961: '6(1)',
      section2025: '6(1)',
      description: 'Basic conditions for individual residence (182/60 days)',
      category: SectionCategory.residentialStatus,
    ),
    SectionMapping(
      section1961: '6(6)',
      section2025: '6(6)',
      description: 'Deemed resident — Indian income exceeds ₹15 lakh',
      category: SectionCategory.residentialStatus,
    ),

    // --- EXEMPT INCOME ---
    SectionMapping(
      section1961: '10',
      section2025: '11',
      description: 'Incomes not included in total income',
      category: SectionCategory.exemptIncome,
    ),
    SectionMapping(
      section1961: '10(1)',
      section2025: '11(1)',
      description: 'Agricultural income',
      category: SectionCategory.exemptIncome,
    ),
    SectionMapping(
      section1961: '10(10D)',
      section2025: '11(T3)',
      description: 'Life insurance maturity exempt',
      category: SectionCategory.exemptIncome,
    ),
    SectionMapping(
      section1961: '10(13A)',
      section2025: '19',
      description: 'House rent allowance exemption',
      category: SectionCategory.exemptIncome,
    ),
    SectionMapping(
      section1961: '10(14)',
      section2025: '20',
      description: 'Special allowances prescribed',
      category: SectionCategory.exemptIncome,
    ),
    SectionMapping(
      section1961: '10(23C)',
      section2025: '350',
      description: 'Income of educational/medical institutions',
      category: SectionCategory.trust,
    ),
    SectionMapping(
      section1961: '10(34A)',
      section2025: '11(T)',
      description: 'Dividend from domestic company',
      category: SectionCategory.exemptIncome,
    ),
    SectionMapping(
      section1961: '10(38)',
      section2025: '11(T)',
      description: 'LTCG on equity (pre-2018)',
      category: SectionCategory.exemptIncome,
    ),

    // --- SALARY ---
    SectionMapping(
      section1961: '15',
      section2025: '15',
      description: 'Salary income chargeable',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '16',
      section2025: '16',
      description: 'Deductions from salary — standard deduction',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '17(1)',
      section2025: '17(1)',
      description: 'Value of perquisites',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '17(2)',
      section2025: '17(2)',
      description: 'Perquisite valuation rules',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '17(3)',
      section2025: '17(3)',
      description: 'Profits in lieu of salary',
      category: SectionCategory.general,
    ),

    // --- HOUSE PROPERTY ---
    SectionMapping(
      section1961: '22',
      section2025: '22',
      description: 'Income from house property',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '23',
      section2025: '23',
      description: 'Annual value of property',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '24',
      section2025: '24',
      description: 'Deductions from house property income',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '24(b)',
      section2025: '24(b)',
      description: 'Deduction for housing loan interest (₹2L cap)',
      category: SectionCategory.general,
    ),

    // --- BUSINESS / PROFESSION ---
    SectionMapping(
      section1961: '28',
      section2025: '28',
      description: 'Profits and gains of business or profession',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '32',
      section2025: '32',
      description: 'Depreciation',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '35',
      section2025: '35',
      description: 'Expenditure on scientific research',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '36',
      section2025: '36',
      description: 'Other deductions from business income',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '37',
      section2025: '37',
      description: 'General deduction for business expenditure',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '40(a)(ia)',
      section2025: '40(a)(ia)',
      description: 'Disallowance for non-deduction of TDS',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '43B',
      section2025: '43B',
      description: 'Deductions on actual payment basis',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '43B(h)',
      section2025: '43B(h)',
      description: 'MSME payment within 45 days disallowance',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '44AB',
      section2025: '44AB',
      description: 'Mandatory audit if turnover > threshold',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '44AD',
      section2025: '58',
      description: 'Presumptive taxation for business',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '44ADA',
      section2025: '59',
      description: 'Presumptive taxation for professionals',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '44AE',
      section2025: '60',
      description: 'Presumptive income for goods carriers',
      category: SectionCategory.general,
    ),

    // --- CAPITAL GAINS ---
    SectionMapping(
      section1961: '45',
      section2025: '67',
      description: 'Capital gains — charging section',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '45(5)',
      section2025: '67(5)',
      description: 'Capital gains from joint development agreement',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '46',
      section2025: '68',
      description: 'Capital gains on distribution of assets on liquidation',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '47',
      section2025: '69',
      description: 'Transactions not regarded as transfer',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '48',
      section2025: '72',
      description: 'Mode of computation of capital gains',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '49',
      section2025: '73',
      description: 'Cost with reference to certain modes of acquisition',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '50',
      section2025: '74',
      description: 'Cost of depreciable assets',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '50C',
      section2025: '76',
      description: 'Fair market value for land/building',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '50CA',
      section2025: '77',
      description: 'Fair market value for unquoted shares',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '50D',
      section2025: '78',
      description: 'Fair market value deemed full consideration',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '54',
      section2025: '82',
      description: 'Exemption on sale of residential property',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '54B',
      section2025: '83',
      description: 'Exemption on sale of agricultural land',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '54D',
      section2025: '84',
      description: 'Exemption on compulsory acquisition of industrial land',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '54EC',
      section2025: '85',
      description: 'Exemption for investment in specified bonds',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '54F',
      section2025: '86',
      description: 'Exemption on sale of any asset — invest in house',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '54G',
      section2025: '87',
      description: 'Exemption on shifting of industrial undertaking',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '54GA',
      section2025: '88',
      description: 'Capital gains on shifting to SEZ',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '55',
      section2025: '79',
      description: 'Cost of improvement and acquisition',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '111A',
      section2025: '196',
      description: 'STCG on listed equity — 20%',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '112',
      section2025: '197',
      description: 'LTCG — 12.5% without indexation',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '112A',
      section2025: '198',
      description: 'LTCG on equity/units — 12.5% above ₹1.25L',
      category: SectionCategory.capitalGains,
    ),
    SectionMapping(
      section1961: '115AD(1)(b)(iii)',
      section2025: '191(b)',
      description: 'LTCG of specified fund at 12.5%',
      category: SectionCategory.capitalGains,
    ),

    // --- OTHER SOURCES ---
    SectionMapping(
      section1961: '56',
      section2025: '61',
      description: 'Income from other sources',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '56(2)(viib)',
      section2025: '61(T)',
      description: 'Angel tax / share premium above fair value',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '57',
      section2025: '62',
      description: 'Deductions from other source income',
      category: SectionCategory.general,
    ),

    // --- SET-OFF & CARRY-FORWARD ---
    SectionMapping(
      section1961: '70',
      section2025: '93',
      description: 'Set-off within same head',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '71',
      section2025: '94',
      description: 'Set-off across heads',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '72',
      section2025: '95',
      description: 'Carry forward of business loss (8 years)',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '73',
      section2025: '96',
      description: 'Losses in speculation business',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '74',
      section2025: '97',
      description: 'Carry forward of capital losses (8 years)',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '79',
      section2025: '102',
      description: 'Carry forward on change of shareholding',
      category: SectionCategory.general,
    ),

    // --- DEDUCTIONS (CHAPTER VI-A) ---
    SectionMapping(
      section1961: '80C',
      section2025: '123',
      description:
          'Deduction for life insurance, provident fund, tuition fees, ELSS',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80CCC',
      section2025: '124',
      description: 'Deduction for pension fund contribution',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80CCD(1)',
      section2025: '125(1)',
      description: 'Employee contribution to NPS',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80CCD(1B)',
      section2025: '125(1B)',
      description: 'Additional NPS contribution (₹50,000)',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80CCD(2)',
      section2025: '125(2)',
      description: 'Employer contribution to NPS (14%)',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80D',
      section2025: '126',
      description: 'Health insurance premium deduction',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80DD',
      section2025: '127',
      description: 'Maintenance of dependent with disability',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80DDB',
      section2025: '128',
      description: 'Medical treatment for specified diseases',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80E',
      section2025: '129',
      description: 'Interest on education loan',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80EE',
      section2025: '130',
      description: 'Interest on housing loan (first-time buyers)',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80EEA',
      section2025: '131',
      description: 'Interest on affordable housing loan',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80EEB',
      section2025: '132',
      description: 'Interest on electric vehicle loan',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80G',
      section2025: '133',
      description: 'Donations to charitable funds/institutions',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80GG',
      section2025: '134',
      description: 'Rent paid deduction (no HRA)',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80GGA',
      section2025: '134A',
      description: 'Donations for scientific research',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80GGC',
      section2025: '135',
      description: 'Contributions to political parties',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80IAC',
      section2025: '147',
      description: 'Startup deduction — 3-year tax holiday',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80IBA',
      section2025: '148',
      description: 'Affordable housing projects deduction',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80JJAA',
      section2025: '146',
      description: 'Employment of new employees deduction',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80LA',
      section2025: '145',
      description: 'IFSC units deduction',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80P',
      section2025: '143',
      description: 'Cooperative societies deduction',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80QQB',
      section2025: '140',
      description: 'Royalty income of authors',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80RRB',
      section2025: '141',
      description: 'Royalty on patents',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80TTA',
      section2025: '136',
      description: 'Interest on savings account (₹10,000)',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80TTB',
      section2025: '137',
      description: 'Senior citizen interest income (₹50,000)',
      category: SectionCategory.deductions,
    ),
    SectionMapping(
      section1961: '80U',
      section2025: '149',
      description: 'Person with disability deduction',
      category: SectionCategory.deductions,
    ),

    // --- TAX REBATE & RELIEF ---
    SectionMapping(
      section1961: '87A',
      section2025: '156',
      description: 'Rebate for individuals up to ₹7L/₹5L',
      category: SectionCategory.taxComputation,
    ),
    SectionMapping(
      section1961: '89',
      section2025: '157',
      description: 'Relief for salary arrears',
      category: SectionCategory.taxComputation,
    ),
    SectionMapping(
      section1961: '89(1)',
      section2025: '157(1)',
      description: 'Relief under Form 10E',
      category: SectionCategory.taxComputation,
    ),

    // --- TAX COMPUTATION — SPECIAL RATES ---
    SectionMapping(
      section1961: '115BAC',
      section2025: '202',
      description: 'New tax regime for individuals, HUF, AOP, BOI',
      category: SectionCategory.taxComputation,
    ),
    SectionMapping(
      section1961: '115BAA',
      section2025: '200',
      description: 'Concessional rate for domestic companies (22%)',
      category: SectionCategory.taxComputation,
    ),
    SectionMapping(
      section1961: '115BAB',
      section2025: '201',
      description: 'New manufacturing companies (15%)',
      category: SectionCategory.taxComputation,
    ),
    SectionMapping(
      section1961: '115BBH',
      section2025: '199',
      description: 'Tax on VDA — 30% flat',
      category: SectionCategory.vda,
    ),
    SectionMapping(
      section1961: '115BBE',
      section2025: '195',
      description: 'Tax on unexplained income (60%)',
      category: SectionCategory.taxComputation,
    ),
    SectionMapping(
      section1961: '115JB',
      section2025: '206',
      description: 'Minimum Alternate Tax (MAT)',
      category: SectionCategory.taxComputation,
    ),
    SectionMapping(
      section1961: '115JC',
      section2025: '207',
      description: 'Alternate Minimum Tax (AMT)',
      category: SectionCategory.taxComputation,
    ),

    // --- DTAA & INTERNATIONAL ---
    SectionMapping(
      section1961: '90',
      section2025: '160',
      description: 'DTAA — avoidance of double taxation',
      category: SectionCategory.dtaa,
    ),
    SectionMapping(
      section1961: '90(4)',
      section2025: '160(4)',
      description: 'DTAA — TRC requirement',
      category: SectionCategory.dtaa,
    ),
    SectionMapping(
      section1961: '91',
      section2025: '161',
      description: 'Unilateral relief — no DTAA',
      category: SectionCategory.dtaa,
    ),
    SectionMapping(
      section1961: '115A',
      section2025: '190',
      description: 'Tax on NRI income (interest, royalty, FTS)',
      category: SectionCategory.dtaa,
    ),
    SectionMapping(
      section1961: '115AD',
      section2025: '191',
      description: 'Tax on income of FIIs',
      category: SectionCategory.dtaa,
    ),
    SectionMapping(
      section1961: '115E',
      section2025: '193',
      description: 'Tax on NRI investment income',
      category: SectionCategory.dtaa,
    ),

    // --- TRANSFER PRICING ---
    SectionMapping(
      section1961: '92',
      section2025: '162',
      description: 'International transactions at arms length',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92C',
      section2025: '164',
      description: 'ALP computation methods',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92CA',
      section2025: '165',
      description: 'Reference to TPO',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92D',
      section2025: '166',
      description: 'TP documentation (Master/Local file)',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92E',
      section2025: '167',
      description: 'Form 3CEB for TP',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92CB',
      section2025: '168',
      description: 'Safe harbour rules',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92CC',
      section2025: '169',
      description: 'Advance Pricing Agreement (APA)',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92CD',
      section2025: '170',
      description: 'Modified return for APA',
      category: SectionCategory.transferPricing,
    ),
    SectionMapping(
      section1961: '92CE',
      section2025: '171',
      description: 'Secondary adjustment for TP',
      category: SectionCategory.transferPricing,
    ),

    // --- TRUSTS ---
    SectionMapping(
      section1961: '11',
      section2025: '350',
      description: 'Income of charitable/religious trusts',
      category: SectionCategory.trust,
    ),
    SectionMapping(
      section1961: '12',
      section2025: '351',
      description: 'Trust voluntary contributions',
      category: SectionCategory.trust,
    ),
    SectionMapping(
      section1961: '12A',
      section2025: '353',
      description: 'Registration of charitable trust',
      category: SectionCategory.trust,
    ),
    SectionMapping(
      section1961: '12AB',
      section2025: '355',
      description: 'Registration procedure — new/provisional/renewal',
      category: SectionCategory.trust,
    ),
    SectionMapping(
      section1961: '13',
      section2025: '356',
      description: 'Trust income exclusions and conditions',
      category: SectionCategory.trust,
    ),

    // --- RETURN FILING & ASSESSMENT ---
    SectionMapping(
      section1961: '139',
      section2025: '263',
      description: 'Return of income filing',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '139(1)',
      section2025: '263(1)',
      description: 'Mandatory return filing',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '139(4)',
      section2025: '263(4)',
      description: 'Belated return',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '139(5)',
      section2025: '263(5)',
      description: 'Revised return',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '139(8A)',
      section2025: '263(8A)',
      description: 'Updated return (ITR-U)',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '140A',
      section2025: '266',
      description: 'Self-assessment tax',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '140B',
      section2025: '267',
      description: 'Additional tax on updated return',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '142',
      section2025: '268',
      description: 'Inquiry before assessment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '142(1)',
      section2025: '268(1)',
      description: 'Notice to furnish return/evidence',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '143',
      section2025: '270',
      description: 'Assessment — processing and scrutiny',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '143(1)',
      section2025: '270(1)',
      description: 'CPC intimation — prima facie adjustment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '143(2)',
      section2025: '270(2)',
      description: 'Notice for scrutiny assessment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '143(3)',
      section2025: '270(3)',
      description: 'Scrutiny assessment order',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '144',
      section2025: '271',
      description: 'Best judgment assessment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '144B',
      section2025: '272',
      description: 'Faceless assessment scheme',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '144C',
      section2025: '273',
      description: 'Reference to DRP',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '145',
      section2025: '291',
      description: 'Method of accounting',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '145A',
      section2025: '292',
      description: 'Inventory valuation',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '147',
      section2025: '279',
      description: 'Income escaping assessment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '148',
      section2025: '280',
      description: 'Notice for reassessment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '148A',
      section2025: '281',
      description: 'Inquiry before reassessment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '149',
      section2025: '282',
      description: 'Time limit for reassessment (3/10 years)',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '150',
      section2025: '283',
      description: 'Extension for reassessment — court order',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '153A',
      section2025: '284',
      description: 'Assessment for search cases',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '153B',
      section2025: '285',
      description: 'Time limit for search assessments',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '153C',
      section2025: '286',
      description: 'Assessment of other persons (search)',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '154',
      section2025: '287',
      description: 'Rectification of mistake',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '155',
      section2025: '288',
      description: 'Other amendments to assessment',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '156',
      section2025: '289',
      description: 'Notice of demand',
      category: SectionCategory.assessment,
    ),

    // --- APPEALS ---
    SectionMapping(
      section1961: '246A',
      section2025: '357',
      description: 'Appealable orders before CIT(A)',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '250',
      section2025: '360',
      description: 'CIT(A) procedure',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '253',
      section2025: '363',
      description: 'Appeal to ITAT',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '254',
      section2025: '364',
      description: 'ITAT orders',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '260A',
      section2025: '370',
      description: 'Appeal to High Court',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '263',
      section2025: '373',
      description: 'Revision by PCIT — suo motu',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '264',
      section2025: '374',
      description: 'Revision by PCIT — assessee application',
      category: SectionCategory.assessment,
    ),

    // --- SEARCH & SEIZURE ---
    SectionMapping(
      section1961: '132',
      section2025: '247',
      description: 'Search and seizure',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '132A',
      section2025: '248',
      description: 'Requisition of books',
      category: SectionCategory.assessment,
    ),
    SectionMapping(
      section1961: '133',
      section2025: '249',
      description: 'Power to call for information',
      category: SectionCategory.assessment,
    ),

    // --- TDS ---
    SectionMapping(
      section1961: '192',
      section2025: '392',
      description: 'TDS on salary',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '193',
      section2025: '393(1-1)',
      description: 'TDS on interest on securities',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194',
      section2025: '393(1-2)',
      description: 'TDS on dividend',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194A',
      section2025: '393(1-3)',
      description: 'TDS on interest (other than securities)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194B',
      section2025: '393(1-4)',
      description: 'TDS on lottery/crossword winnings',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194BB',
      section2025: '393(1-5)',
      description: 'TDS on horse race winnings',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194C',
      section2025: '393(1-6)',
      description: 'TDS on contractor payments',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194D',
      section2025: '393(1-7)',
      description: 'TDS on insurance commission',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194DA',
      section2025: '393(1-8)',
      description: 'TDS on life insurance maturity',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194E',
      section2025: '393(1-9)',
      description: 'TDS on non-resident sportsmen',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194EE',
      section2025: '393(1-10)',
      description: 'TDS on NSS deposits',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194G',
      section2025: '393(1-11)',
      description: 'TDS on lottery commission',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194H',
      section2025: '393(1-12)',
      description: 'TDS on commission/brokerage',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194I(a)',
      section2025: '393(1-13a)',
      description: 'TDS on rent — plant/machinery (2%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194I(b)',
      section2025: '393(1-13b)',
      description: 'TDS on rent — land/building (10%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194IA',
      section2025: '393(1-14)',
      description: 'TDS on immovable property (1%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194IB',
      section2025: '393(1-15)',
      description: 'TDS on rent by individual/HUF (5%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194J(a)',
      section2025: '393(1-16a)',
      description: 'TDS on professional fees — call centre (2%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194J(b)',
      section2025: '393(1-16b)',
      description: 'TDS on professional fees — other (10%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194JB',
      section2025: '393(1-JB)',
      description: 'TDS on digital influencer payments',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194K',
      section2025: '393(1-17)',
      description: 'TDS on mutual fund income',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194LA',
      section2025: '393(1-18)',
      description: 'TDS on compulsory acquisition compensation',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194LBC',
      section2025: '393(1-19)',
      description: 'TDS on securitization trust income',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194M',
      section2025: '393(1-20)',
      description: 'TDS on individual/HUF contractor payments',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194N',
      section2025: '393(1-21)',
      description: 'TDS on cash withdrawal',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194O',
      section2025: '393(1-22)',
      description: 'TDS on e-commerce payments',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194P',
      section2025: '393(1-P)',
      description: 'TDS on senior citizen (75+) pension/interest',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194Q',
      section2025: '393(1-23)',
      description: 'TDS on purchase of goods (0.1%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194R',
      section2025: '393(1-24)',
      description: 'TDS on business perquisites (10%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '194S',
      section2025: '393(1-25)',
      description: 'TDS on VDA transfer — 1%',
      category: SectionCategory.vda,
    ),
    SectionMapping(
      section1961: '194T',
      section2025: '393(1-26)',
      description: 'TDS on partner remuneration (10%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '195',
      section2025: '393(2)',
      description: 'TDS on payments to non-residents',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '196A',
      section2025: '393(2-A)',
      description: 'TDS on non-resident unit income',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '196B',
      section2025: '393(2-B)',
      description: 'TDS on offshore fund income',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '196C',
      section2025: '393(2-C)',
      description: 'TDS on foreign currency bond income',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '196D',
      section2025: '393(2-D)',
      description: 'TDS on FII income',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '197',
      section2025: '395',
      description: 'Lower/nil TDS certificate',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '197A',
      section2025: '396',
      description: 'No deduction — Form 15G/15H',
      category: SectionCategory.tds,
    ),

    // --- TCS ---
    SectionMapping(
      section1961: '206C',
      section2025: '394',
      description: 'Tax collection at source',
      category: SectionCategory.tcs,
    ),
    SectionMapping(
      section1961: '206C(1H)',
      section2025: '394(1H)',
      description: 'TCS on sale of goods >₹50L',
      category: SectionCategory.tcs,
    ),
    SectionMapping(
      section1961: '206AA',
      section2025: '398',
      description: 'Higher TDS if PAN not available (20%)',
      category: SectionCategory.tds,
    ),
    SectionMapping(
      section1961: '206AB',
      section2025: '399',
      description: 'Higher TDS/TCS for non-filers',
      category: SectionCategory.tds,
    ),

    // --- ADVANCE TAX ---
    SectionMapping(
      section1961: '207',
      section2025: '400',
      description: 'Liability for advance tax',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '208',
      section2025: '401',
      description: 'Advance tax threshold (₹10,000)',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '209',
      section2025: '402',
      description: 'Computation of advance tax',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '210',
      section2025: '403',
      description: 'Advance tax installment dates',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '211',
      section2025: '404',
      description: 'Advance tax installment percentages',
      category: SectionCategory.general,
    ),

    // --- INTEREST ---
    SectionMapping(
      section1961: '220(2)',
      section2025: '420(2)',
      description: 'Interest on demand not paid — 1%/month',
      category: SectionCategory.interest,
    ),
    SectionMapping(
      section1961: '234A',
      section2025: '461',
      description: 'Interest for late filing — 1%/month',
      category: SectionCategory.interest,
    ),
    SectionMapping(
      section1961: '234B',
      section2025: '462',
      description: 'Interest for advance tax shortfall — 1%/month',
      category: SectionCategory.interest,
    ),
    SectionMapping(
      section1961: '234C',
      section2025: '463',
      description: 'Interest for deferment of advance tax',
      category: SectionCategory.interest,
    ),
    SectionMapping(
      section1961: '234D',
      section2025: '464',
      description: 'Interest on excess refund',
      category: SectionCategory.interest,
    ),
    SectionMapping(
      section1961: '234E',
      section2025: '465',
      description: 'Fee for late TDS/TCS statement (₹200/day)',
      category: SectionCategory.interest,
    ),
    SectionMapping(
      section1961: '234F',
      section2025: '466',
      description: 'Fee for late return filing',
      category: SectionCategory.interest,
    ),
    SectionMapping(
      section1961: '244A',
      section2025: '467',
      description: 'Interest on refund — 0.5%/month',
      category: SectionCategory.interest,
    ),

    // --- PENALTIES ---
    SectionMapping(
      section1961: '270A',
      section2025: '441',
      description: 'Penalty for under-reporting (50%) / misreporting (200%)',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '270AA',
      section2025: '442',
      description: 'Immunity from penalty',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271(1)(b)',
      section2025: '443',
      description: 'Penalty for non-compliance with notices',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271(1)(c)',
      section2025: '444',
      description: 'Penalty for concealment',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271AAB',
      section2025: '445',
      description: 'Penalty for undisclosed income in search',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271B',
      section2025: '446',
      description: 'Penalty for failure to get audit',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271BA',
      section2025: '447',
      description: 'Penalty for failure to file TP report',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271D',
      section2025: '448',
      description: 'Penalty for cash receipt >₹20,000',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271E',
      section2025: '449',
      description: 'Penalty for cash repayment >₹20,000',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271F',
      section2025: '450',
      description: 'Penalty for late filing',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271FA',
      section2025: '451',
      description: 'Penalty for failure to furnish SFT',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271H',
      section2025: '452',
      description: 'Penalty for late TDS/TCS statement',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '271J',
      section2025: '453',
      description: 'Penalty on professional for incorrect certificate',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '276B',
      section2025: '475',
      description: 'Prosecution for failure to pay TDS',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '276C',
      section2025: '476',
      description: 'Prosecution for wilful evasion',
      category: SectionCategory.penalty,
    ),
    SectionMapping(
      section1961: '276CC',
      section2025: '477',
      description: 'Prosecution for failure to file return',
      category: SectionCategory.penalty,
    ),

    // --- MISCELLANEOUS ---
    SectionMapping(
      section1961: '269SS',
      section2025: '240',
      description: 'Restriction on cash loans >₹20,000',
      category: SectionCategory.general,
    ),
    SectionMapping(
      section1961: '269T',
      section2025: '241',
      description: 'Restriction on cash repayment >₹20,000',
      category: SectionCategory.general,
    ),
  ];
}
