import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_record.dart';
import 'package:ca_app/features/mca_api/domain/repositories/mca_repository.dart';

/// CIN pattern: [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}
final _cinRegex = RegExp(r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$');

/// DIN pattern: exactly 8 numeric digits.
final _dinRegex = RegExp(r'^[0-9]{8}$');

/// Mock implementation of [McaRepository] for use in tests and demos.
///
/// No real HTTP calls are made. All responses are deterministic mock data.
class MockMcaRepository implements McaRepository {
  const MockMcaRepository();

  // -------------------------------------------------------------------------
  // Validation helpers
  // -------------------------------------------------------------------------

  void _assertValidCin(String cin) {
    if (!_cinRegex.hasMatch(cin)) {
      throw ArgumentError.value(
        cin,
        'cin',
        'CIN must match [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}',
      );
    }
  }

  void _assertValidDin(String din) {
    if (!_dinRegex.hasMatch(din)) {
      throw ArgumentError.value(
        din,
        'din',
        'DIN must be exactly 8 numeric digits',
      );
    }
  }

  // -------------------------------------------------------------------------
  // McaRepository
  // -------------------------------------------------------------------------

  @override
  Future<McaCompanyLookup> lookupByCin(String cin) async {
    _assertValidCin(cin);
    return McaCompanyLookup(
      cin: cin,
      companyName: 'RELIANCE INDUSTRIES LIMITED',
      registeredOfficeAddress:
          'Maker Chambers IV, Nariman Point, Mumbai 400021',
      state: 'MH',
      dateOfIncorporation: DateTime(1973, 5, 8),
      status: McaCompanyStatus.active,
      authorizedCapital: 1000000000,
      paidUpCapital: 634900000,
      companyCategory: 'Company limited by Shares',
      companySubCategory: 'Indian Non-Government Company',
      roc: 'RoC-Mumbai',
    );
  }

  @override
  Future<McaCompanyLookup> searchByName(String name) async {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Search term must not be empty');
    }
    return McaCompanyLookup(
      cin: 'L17110MH1973PLC019786',
      companyName: 'RELIANCE INDUSTRIES LIMITED',
      registeredOfficeAddress:
          'Maker Chambers IV, Nariman Point, Mumbai 400021',
      state: 'MH',
      dateOfIncorporation: DateTime(1973, 5, 8),
      status: McaCompanyStatus.active,
      authorizedCapital: 1000000000,
      paidUpCapital: 634900000,
      companyCategory: 'Company limited by Shares',
      companySubCategory: 'Indian Non-Government Company',
      roc: 'RoC-Mumbai',
    );
  }

  @override
  Future<McaDirectorLookup> lookupDirector(String din) async {
    _assertValidDin(din);
    return McaDirectorLookup(
      din: din,
      directorName: 'Mukesh Dhirubhai Ambani',
      dateOfBirth: DateTime(1957, 4, 19),
      fatherName: 'Dhirubhai Hirachand Ambani',
      nationality: 'Indian',
      status: McaDirectorStatus.approved,
      associatedCompanies: const [
        'L17110MH1973PLC019786',
        'U65923MH2006PTC166197',
      ],
    );
  }

  @override
  Future<McaEFormStatus> getFormStatus(String srn) async {
    return McaEFormStatus(
      srn: srn,
      formType: 'MGT-7',
      cin: 'L17110MH1973PLC019786',
      filedAt: DateTime(2024, 9, 15, 10, 30),
      status: McaEFormStatusValue.approved,
      approvalDate: DateTime(2024, 10, 1, 9, 0),
      remarks: 'All documents verified and accepted.',
    );
  }

  @override
  Future<McaEFormStatus> prefillAndSubmitForm(
    String cin,
    String formType,
    Map<String, String> prefillData,
  ) async {
    _assertValidCin(cin);
    final srn = _generateSrn();
    return McaEFormStatus(
      srn: srn,
      formType: formType,
      cin: cin,
      filedAt: DateTime.now(),
      status: McaEFormStatusValue.pending,
      approvalDate: null,
      remarks: null,
    );
  }

  @override
  Future<McaFilingHistory> getFilingHistory(String cin) async {
    _assertValidCin(cin);
    final filings = [
      McaFilingRecord(
        srn: 'A11111111',
        formType: 'MGT-7',
        filedAt: DateTime(2024, 11, 10, 14, 0),
        status: 'Approved',
        documentDescription: 'Annual Return FY 2023-24',
        feesPaid: 30000,
      ),
      McaFilingRecord(
        srn: 'A22222222',
        formType: 'AOC-4',
        filedAt: DateTime(2024, 10, 15, 11, 0),
        status: 'Approved',
        documentDescription: 'Financial Statements FY 2023-24',
        feesPaid: 20000,
      ),
      McaFilingRecord(
        srn: 'A33333333',
        formType: 'MGT-7',
        filedAt: DateTime(2023, 11, 5, 10, 0),
        status: 'Approved',
        documentDescription: 'Annual Return FY 2022-23',
        feesPaid: 30000,
      ),
    ];
    return McaFilingHistory(cin: cin, filings: filings);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Generates an SRN of the form "A" + 8-digit millisecond timestamp suffix.
  String _generateSrn() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final suffix = (ts % 100000000).toString().padLeft(8, '0');
    return 'A$suffix';
  }
}
