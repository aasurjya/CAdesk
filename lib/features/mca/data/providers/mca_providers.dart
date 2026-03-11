import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/company.dart';
import '../../domain/models/mca_filing.dart';

// ---------------------------------------------------------------------------
// Mock companies (mix of Pvt Ltd, OPC, Public)
// ---------------------------------------------------------------------------

final List<Company> _mockCompanies = [
  Company(
    id: 'co-001',
    cin: 'U74999MH2018PTC312456',
    companyName: 'Meridian Tech Solutions Private Limited',
    incorporationDate: DateTime(2018, 6, 14),
    category: CompanyCategory.privateLimited,
    paidUpCapital: 5000000,
    authorisedCapital: 10000000,
    registeredAddress:
        '401, Lotus Corporate Park, Goregaon East, Mumbai 400063',
    rocJurisdiction: 'ROC Mumbai',
    status: CompanyStatus.active,
    directors: [
      Director(
        din: '08123456',
        name: 'Rajesh Kumar Sharma',
        designation: 'Managing Director',
        appointmentDate: DateTime.utc(2018, 6, 14),
      ),
      Director(
        din: '08234567',
        name: 'Priya Venkataraman',
        designation: 'Director',
        appointmentDate: DateTime.utc(2019, 4, 1),
      ),
      Director(
        din: '08345678',
        name: 'Amit Desai',
        designation: 'Independent Director',
        appointmentDate: DateTime.utc(2020, 10, 15),
      ),
    ],
  ),
  Company(
    id: 'co-002',
    cin: 'U72200KA2020OPC456789',
    companyName: 'Naveen Innovations OPC Private Limited',
    incorporationDate: DateTime(2020, 3, 20),
    category: CompanyCategory.opc,
    paidUpCapital: 1000000,
    authorisedCapital: 2500000,
    registeredAddress: '12, Brigade Road, Bengaluru 560001',
    rocJurisdiction: 'ROC Bengaluru',
    status: CompanyStatus.active,
    directors: [
      Director(
        din: '09112233',
        name: 'Naveen Pillai',
        designation: 'Director',
        appointmentDate: DateTime.utc(2020, 3, 20),
      ),
    ],
  ),
  Company(
    id: 'co-003',
    cin: 'L65910DL1995PLC234567',
    companyName: 'Bharat Infrastructure & Projects Limited',
    incorporationDate: DateTime(1995, 11, 8),
    category: CompanyCategory.publicLimited,
    paidUpCapital: 250000000,
    authorisedCapital: 500000000,
    registeredAddress: 'Plot 7, Connaught Place, New Delhi 110001',
    rocJurisdiction: 'ROC Delhi',
    status: CompanyStatus.active,
    directors: [
      Director(
        din: '00234567',
        name: 'Suresh Nair',
        designation: 'Chairman & MD',
        appointmentDate: DateTime.utc(2010, 5, 1),
      ),
      Director(
        din: '00345678',
        name: 'Kavita Agarwal',
        designation: 'Executive Director',
        appointmentDate: DateTime.utc(2015, 9, 1),
      ),
      Director(
        din: '00456789',
        name: 'Dr. Mohan Iyer',
        designation: 'Independent Director',
        appointmentDate: DateTime.utc(2019, 7, 12),
      ),
      Director(
        din: '00567890',
        name: 'Sunita Mehrotra',
        designation: 'Independent Director',
        appointmentDate: DateTime.utc(2021, 1, 1),
      ),
    ],
  ),
  Company(
    id: 'co-004',
    cin: 'U85100GJ2016PTC789012',
    companyName: 'Sunshine Agro Processing Private Limited',
    incorporationDate: DateTime(2016, 7, 22),
    category: CompanyCategory.privateLimited,
    paidUpCapital: 3000000,
    authorisedCapital: 5000000,
    registeredAddress: '22-A, GIDC Estate, Anand, Gujarat 388001',
    rocJurisdiction: 'ROC Ahmedabad',
    status: CompanyStatus.active,
    directors: [
      Director(
        din: '07456789',
        name: 'Dhruv Patel',
        designation: 'Director',
        appointmentDate: DateTime.utc(2016, 7, 22),
      ),
      Director(
        din: '07567890',
        name: 'Hetal Patel',
        designation: 'Director',
        appointmentDate: DateTime.utc(2016, 7, 22),
      ),
    ],
  ),
  Company(
    id: 'co-005',
    cin: 'U85300TN2019OPC567890',
    companyName: 'Anand Wellness OPC Private Limited',
    incorporationDate: DateTime(2019, 1, 10),
    category: CompanyCategory.opc,
    paidUpCapital: 500000,
    authorisedCapital: 1000000,
    registeredAddress: '45, Anna Nagar, Chennai 600040',
    rocJurisdiction: 'ROC Chennai',
    status: CompanyStatus.active,
    directors: [
      Director(
        din: '09678901',
        name: 'Anand Krishnaswamy',
        designation: 'Director',
        appointmentDate: DateTime.utc(2019, 1, 10),
      ),
    ],
  ),
  Company(
    id: 'co-006',
    cin: 'U74120MH2010PTC345678',
    companyName: 'Horizon Media & Entertainment Private Limited',
    incorporationDate: DateTime(2010, 9, 5),
    category: CompanyCategory.privateLimited,
    paidUpCapital: 20000000,
    authorisedCapital: 50000000,
    registeredAddress: '501, Bandra Kurla Complex, Mumbai 400051',
    rocJurisdiction: 'ROC Mumbai',
    status: CompanyStatus.active,
    directors: [
      Director(
        din: '06234567',
        name: 'Vikram Malhotra',
        designation: 'Managing Director',
        appointmentDate: DateTime.utc(2010, 9, 5),
      ),
      Director(
        din: '06345678',
        name: 'Pooja Sethi',
        designation: 'Whole-Time Director',
        appointmentDate: DateTime.utc(2013, 3, 1),
      ),
      Director(
        din: '06456789',
        name: 'Ravi Chandrasekhar',
        designation: 'Independent Director',
        appointmentDate: DateTime.utc(2018, 4, 15),
      ),
    ],
  ),
  Company(
    id: 'co-007',
    cin: 'U74110WB2005PTC678901',
    companyName: 'Eastern Logistics Private Limited',
    incorporationDate: DateTime(2005, 4, 18),
    category: CompanyCategory.privateLimited,
    paidUpCapital: 8000000,
    authorisedCapital: 15000000,
    registeredAddress: '33, Park Street, Kolkata 700016',
    rocJurisdiction: 'ROC Kolkata',
    status: CompanyStatus.struckOff,
    directors: [
      Director(
        din: '05123456',
        name: 'Subrata Banerjee',
        designation: 'Director',
        appointmentDate: DateTime.utc(2005, 4, 18),
        isActive: false,
      ),
      Director(
        din: '05234567',
        name: 'Dipankar Ghosh',
        designation: 'Director',
        appointmentDate: DateTime.utc(2005, 4, 18),
        isActive: false,
      ),
    ],
  ),
  Company(
    id: 'co-008',
    cin: 'U85400RJ2022PTC890123',
    companyName: 'Rajputana Foods & Beverages Private Limited',
    incorporationDate: DateTime(2022, 8, 30),
    category: CompanyCategory.privateLimited,
    paidUpCapital: 2000000,
    authorisedCapital: 5000000,
    registeredAddress: '10, MI Road, Jaipur 302001',
    rocJurisdiction: 'ROC Jaipur',
    status: CompanyStatus.active,
    directors: [
      Director(
        din: '10123456',
        name: 'Arjun Singh Rathore',
        designation: 'Managing Director',
        appointmentDate: DateTime.utc(2022, 8, 30),
      ),
      Director(
        din: '10234567',
        name: 'Lata Kumari',
        designation: 'Director',
        appointmentDate: DateTime.utc(2022, 8, 30),
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock filings (20 filings covering various forms and statuses)
// ---------------------------------------------------------------------------

final List<McaFiling> _mockFilings = [
  // co-001: Meridian Tech
  McaFiling(
    id: 'mca-001',
    companyId: 'co-001',
    companyName: 'Meridian Tech Solutions Private Limited',
    cin: 'U74999MH2018PTC312456',
    formType: McaFormType.mgt7,
    dueDate: DateTime(2025, 11, 29),
    filedDate: DateTime(2025, 11, 20),
    srn: 'G12345678',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 600,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Ramesh Gupta (M.No. 123456)',
  ),
  McaFiling(
    id: 'mca-002',
    companyId: 'co-001',
    companyName: 'Meridian Tech Solutions Private Limited',
    cin: 'U74999MH2018PTC312456',
    formType: McaFormType.aoc4,
    dueDate: DateTime(2025, 10, 29),
    filedDate: DateTime(2025, 10, 25),
    srn: 'G23456789',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 400,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Ramesh Gupta (M.No. 123456)',
  ),
  McaFiling(
    id: 'mca-003',
    companyId: 'co-001',
    companyName: 'Meridian Tech Solutions Private Limited',
    cin: 'U74999MH2018PTC312456',
    formType: McaFormType.dir3kyc,
    dueDate: DateTime(2026, 9, 30),
    status: McaFilingStatus.pending,
    financialYear: '2025-26',
    fees: 500,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Ramesh Gupta (M.No. 123456)',
  ),

  // co-002: Naveen Innovations OPC
  McaFiling(
    id: 'mca-004',
    companyId: 'co-002',
    companyName: 'Naveen Innovations OPC Private Limited',
    cin: 'U72200KA2020OPC456789',
    formType: McaFormType.mgt7,
    dueDate: DateTime(2025, 11, 29),
    status: McaFilingStatus.draft,
    financialYear: '2024-25',
    fees: 600,
    penaltyAmount: 0,
  ),
  McaFiling(
    id: 'mca-005',
    companyId: 'co-002',
    companyName: 'Naveen Innovations OPC Private Limited',
    cin: 'U72200KA2020OPC456789',
    formType: McaFormType.aoc4,
    dueDate: DateTime(2025, 9, 27),
    status: McaFilingStatus.rejected,
    financialYear: '2024-25',
    fees: 400,
    penaltyAmount: 1200,
    certifyingProfessional: 'CS Meena Rao (M.No. ACS 34567)',
  ),

  // co-003: Bharat Infrastructure (Public Ltd)
  McaFiling(
    id: 'mca-006',
    companyId: 'co-003',
    companyName: 'Bharat Infrastructure & Projects Limited',
    cin: 'L65910DL1995PLC234567',
    formType: McaFormType.mgt9,
    dueDate: DateTime(2025, 10, 30),
    filedDate: DateTime(2025, 10, 28),
    srn: 'G34567890',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 1200,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Dinesh Agrawal (M.No. 234567)',
  ),
  McaFiling(
    id: 'mca-007',
    companyId: 'co-003',
    companyName: 'Bharat Infrastructure & Projects Limited',
    cin: 'L65910DL1995PLC234567',
    formType: McaFormType.adt1,
    dueDate: DateTime(2025, 10, 14),
    filedDate: DateTime(2025, 10, 10),
    srn: 'G45678901',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 500,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Dinesh Agrawal (M.No. 234567)',
  ),
  McaFiling(
    id: 'mca-008',
    companyId: 'co-003',
    companyName: 'Bharat Infrastructure & Projects Limited',
    cin: 'L65910DL1995PLC234567',
    formType: McaFormType.mgmt14,
    dueDate: DateTime(2026, 4, 15),
    status: McaFilingStatus.pending,
    financialYear: '2025-26',
    fees: 500,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Dinesh Agrawal (M.No. 234567)',
  ),

  // co-004: Sunshine Agro
  McaFiling(
    id: 'mca-009',
    companyId: 'co-004',
    companyName: 'Sunshine Agro Processing Private Limited',
    cin: 'U85100GJ2016PTC789012',
    formType: McaFormType.mgt7,
    dueDate: DateTime(2025, 11, 29),
    status: McaFilingStatus.filed,
    financialYear: '2024-25',
    fees: 600,
    penaltyAmount: 0,
    certifyingProfessional: 'CS Anjali Shah (M.No. FCS 56789)',
  ),
  McaFiling(
    id: 'mca-010',
    companyId: 'co-004',
    companyName: 'Sunshine Agro Processing Private Limited',
    cin: 'U85100GJ2016PTC789012',
    formType: McaFormType.dir3kyc,
    dueDate: DateTime(2025, 9, 30),
    status: McaFilingStatus.rejected,
    financialYear: '2025-26',
    fees: 500,
    penaltyAmount: 5000,
  ),

  // co-005: Anand Wellness OPC
  McaFiling(
    id: 'mca-011',
    companyId: 'co-005',
    companyName: 'Anand Wellness OPC Private Limited',
    cin: 'U85300TN2019OPC567890',
    formType: McaFormType.aoc4,
    dueDate: DateTime(2025, 9, 27),
    filedDate: DateTime(2025, 9, 25),
    srn: 'G56789012',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 400,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Sridhar Balaji (M.No. 345678)',
  ),
  McaFiling(
    id: 'mca-012',
    companyId: 'co-005',
    companyName: 'Anand Wellness OPC Private Limited',
    cin: 'U85300TN2019OPC567890',
    formType: McaFormType.mgt7,
    dueDate: DateTime(2025, 11, 29),
    status: McaFilingStatus.pending,
    financialYear: '2024-25',
    fees: 600,
    penaltyAmount: 2000,
    certifyingProfessional: 'CA Sridhar Balaji (M.No. 345678)',
  ),

  // co-006: Horizon Media
  McaFiling(
    id: 'mca-013',
    companyId: 'co-006',
    companyName: 'Horizon Media & Entertainment Private Limited',
    cin: 'U74120MH2010PTC345678',
    formType: McaFormType.mgt7,
    dueDate: DateTime(2025, 11, 29),
    filedDate: DateTime(2025, 11, 15),
    srn: 'G67890123',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 600,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Vivek Joshi (M.No. 456789)',
  ),
  McaFiling(
    id: 'mca-014',
    companyId: 'co-006',
    companyName: 'Horizon Media & Entertainment Private Limited',
    cin: 'U74120MH2010PTC345678',
    formType: McaFormType.inc22a,
    dueDate: DateTime(2025, 12, 25),
    filedDate: DateTime(2025, 12, 20),
    srn: 'G78901234',
    status: McaFilingStatus.approved,
    financialYear: '2025-26',
    fees: 5000,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Vivek Joshi (M.No. 456789)',
  ),
  McaFiling(
    id: 'mca-015',
    companyId: 'co-006',
    companyName: 'Horizon Media & Entertainment Private Limited',
    cin: 'U74120MH2010PTC345678',
    formType: McaFormType.dir3kyc,
    dueDate: DateTime(2026, 9, 30),
    status: McaFilingStatus.draft,
    financialYear: '2025-26',
    fees: 500,
    penaltyAmount: 0,
  ),

  // co-007: Eastern Logistics (struck off)
  McaFiling(
    id: 'mca-016',
    companyId: 'co-007',
    companyName: 'Eastern Logistics Private Limited',
    cin: 'U74110WB2005PTC678901',
    formType: McaFormType.mgt7,
    dueDate: DateTime(2023, 11, 29),
    status: McaFilingStatus.rejected,
    financialYear: '2023-24',
    fees: 600,
    penaltyAmount: 50000,
  ),

  // co-008: Rajputana Foods
  McaFiling(
    id: 'mca-017',
    companyId: 'co-008',
    companyName: 'Rajputana Foods & Beverages Private Limited',
    cin: 'U85400RJ2022PTC890123',
    formType: McaFormType.aoc4,
    dueDate: DateTime(2025, 10, 29),
    filedDate: DateTime(2025, 10, 22),
    srn: 'G89012345',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 400,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Pooja Mehta (M.No. 567890)',
  ),
  McaFiling(
    id: 'mca-018',
    companyId: 'co-008',
    companyName: 'Rajputana Foods & Beverages Private Limited',
    cin: 'U85400RJ2022PTC890123',
    formType: McaFormType.mgt7,
    dueDate: DateTime(2025, 11, 29),
    filedDate: DateTime(2025, 12, 10),
    srn: 'G90123456',
    status: McaFilingStatus.approved,
    financialYear: '2024-25',
    fees: 600,
    penaltyAmount: 3600,
    certifyingProfessional: 'CA Pooja Mehta (M.No. 567890)',
  ),
  McaFiling(
    id: 'mca-019',
    companyId: 'co-008',
    companyName: 'Rajputana Foods & Beverages Private Limited',
    cin: 'U85400RJ2022PTC890123',
    formType: McaFormType.dir3kyc,
    dueDate: DateTime(2026, 9, 30),
    status: McaFilingStatus.pending,
    financialYear: '2025-26',
    fees: 500,
    penaltyAmount: 0,
  ),
  McaFiling(
    id: 'mca-020',
    companyId: 'co-003',
    companyName: 'Bharat Infrastructure & Projects Limited',
    cin: 'L65910DL1995PLC234567',
    formType: McaFormType.aoc4,
    dueDate: DateTime(2025, 10, 29),
    filedDate: DateTime(2025, 10, 29),
    srn: 'G01234567',
    status: McaFilingStatus.filed,
    financialYear: '2024-25',
    fees: 1200,
    penaltyAmount: 0,
    certifyingProfessional: 'CA Dinesh Agrawal (M.No. 234567)',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All MCA companies.
final mcaCompaniesProvider = Provider<List<Company>>(
  (_) => List.unmodifiable(_mockCompanies),
);

/// All MCA filings.
final mcaFilingsProvider = Provider<List<McaFiling>>(
  (_) => List.unmodifiable(_mockFilings),
);

// --- Status filter ---

final mcaStatusFilterProvider =
    NotifierProvider<McaStatusFilterNotifier, McaFilingStatus?>(
      McaStatusFilterNotifier.new,
    );

class McaStatusFilterNotifier extends Notifier<McaFilingStatus?> {
  @override
  McaFilingStatus? build() => null;

  void update(McaFilingStatus? value) => state = value;
}

// --- Form type filter ---

final mcaFormTypeFilterProvider =
    NotifierProvider<McaFormTypeFilterNotifier, McaFormType?>(
      McaFormTypeFilterNotifier.new,
    );

class McaFormTypeFilterNotifier extends Notifier<McaFormType?> {
  @override
  McaFormType? build() => null;

  void update(McaFormType? value) => state = value;
}

// --- ROC jurisdiction filter ---

final mcaRocFilterProvider = NotifierProvider<McaRocFilterNotifier, String?>(
  McaRocFilterNotifier.new,
);

class McaRocFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Distinct ROC jurisdictions derived from company list.
final mcaRocJurisdictionsProvider = Provider<List<String>>((ref) {
  final companies = ref.watch(mcaCompaniesProvider);
  final jurisdictions = companies.map((c) => c.rocJurisdiction).toSet().toList()
    ..sort();
  return List.unmodifiable(jurisdictions);
});

/// Filings filtered by active status and form type filters.
final mcaFilteredFilingsProvider = Provider<List<McaFiling>>((ref) {
  final filings = ref.watch(mcaFilingsProvider);
  final statusFilter = ref.watch(mcaStatusFilterProvider);
  final formTypeFilter = ref.watch(mcaFormTypeFilterProvider);
  final rocFilter = ref.watch(mcaRocFilterProvider);

  final companies = ref.watch(mcaCompaniesProvider);
  final companyRoc = {for (final c in companies) c.id: c.rocJurisdiction};

  return filings.where((f) {
    if (statusFilter != null && f.status != statusFilter) return false;
    if (formTypeFilter != null && f.formType != formTypeFilter) return false;
    if (rocFilter != null && companyRoc[f.companyId] != rocFilter) return false;
    return true;
  }).toList();
});

/// Count of overdue filings.
final mcaOverdueCountProvider = Provider<int>((ref) {
  final filings = ref.watch(mcaFilingsProvider);
  return filings.where((f) => f.isOverdue).length;
});

/// Filings due within the next 30 days (upcoming deadlines).
final mcaUpcomingFilingsProvider = Provider<List<McaFiling>>((ref) {
  final filings = ref.watch(mcaFilingsProvider);
  final now = DateTime(2026, 3, 10);
  final cutoff = now.add(const Duration(days: 30));
  return filings
      .where(
        (f) =>
            f.status != McaFilingStatus.approved &&
            f.status != McaFilingStatus.filed &&
            f.dueDate.isAfter(now) &&
            f.dueDate.isBefore(cutoff),
      )
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

/// Filings grouped per company (for the Companies tab).
final mcaFilingsByCompanyProvider = Provider.family<List<McaFiling>, String>((
  ref,
  companyId,
) {
  final filings = ref.watch(mcaFilingsProvider);
  return filings.where((f) => f.companyId == companyId).toList();
});
