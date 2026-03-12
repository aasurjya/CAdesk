import 'package:ca_app/features/mca/domain/models/company.dart';
import 'package:ca_app/features/mca/domain/models/compliance_certificate.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';

/// Stateless service for generating compliance certificates issued by a
/// Practising Company Secretary (PCS).
///
/// Covers:
/// - MGT-8: Certificate by PCS annexed to MGT-7 Annual Return
/// - Secretarial Audit Report (Form MR-3) under Section 204
class ComplianceCertificateService {
  ComplianceCertificateService._();

  static final ComplianceCertificateService instance =
      ComplianceCertificateService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Generate an MGT-8 certificate annexed to an Annual Return.
  ///
  /// MGT-8 is required for listed companies and public companies with
  /// paid-up capital ≥ ₹10 crore or turnover ≥ ₹50 crore.
  ///
  /// The [certifiedBy] and [din] fields use placeholder values and must be
  /// replaced with the actual PCS credentials before filing.
  ComplianceCertificate generateMgt8(Mgt7Return annual, Company company) {
    final fy = _fyString(annual.financialYear);

    return ComplianceCertificate(
      certType: 'MGT-8',
      period: fy,
      certifiedBy: 'Practising Company Secretary',
      din: 'CS000000',
      date: DateTime.now(),
      declarations: _mgt8Declarations(company.companyName, fy),
    );
  }

  /// Generate a Secretarial Audit Report (Form MR-3) under Section 204 of
  /// the Companies Act 2013 for the given [financialYear].
  ComplianceCertificate generateSecretarialAuditReport(
    Company company,
    int financialYear,
  ) {
    final fy = _fyString(financialYear);

    return ComplianceCertificate(
      certType: 'Secretarial Audit Report (MR-3)',
      period: fy,
      certifiedBy: 'Practising Company Secretary',
      din: 'CS000000',
      date: DateTime.now(),
      declarations: _secretarialAuditDeclarations(company.companyName, fy),
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Format financial year as "YYYY-YY" string (e.g. "2023-24").
  String _fyString(int yearEnd) {
    final start = yearEnd - 1;
    final shortEnd = (yearEnd % 100).toString().padLeft(2, '0');
    return '$start-$shortEnd';
  }

  List<String> _mgt8Declarations(String companyName, String fy) => [
    'I have examined the registers, records, books and papers of '
        '$companyName (the Company) as required to be maintained under the '
        'Companies Act, 2013 and the rules made thereunder for the financial '
        'year ended 31st March $fy.',
    'In my opinion and to the best of my information and according to the '
        'examinations carried out by me and explanations furnished to me by '
        'the Company, its officers and agents, I certify that in respect of '
        'the aforesaid financial year.',
    'The Company has kept and maintained all registers as stated in Annexure '
        'A to this certificate, as per the provisions of the Act and the '
        'rules made thereunder and all entries therein have been duly '
        'recorded.',
    'The Company has duly filed the forms and returns as stated in Annexure '
        'B to this certificate, with the Registrar of Companies, Regional '
        'Director, Central Government, Company Law Board or other authorities '
        'within the time prescribed under the Act and the rules made '
        'thereunder except as mentioned.',
  ];

  List<String> _secretarialAuditDeclarations(
    String companyName,
    String fy,
  ) => [
    'I have conducted the secretarial audit of the compliance of applicable '
        'statutory provisions and the adherence to good corporate practices '
        'by $companyName (hereinafter called the Company) for the audit '
        'period covering the financial year ended on 31st March $fy.',
    'Secretarial Audit was conducted in a manner that provided me a '
        'reasonable basis for evaluating the corporate conducts/statutory '
        'compliances and expressing my opinion thereon.',
    'Based on my verification of the Company books, papers, minute books, '
        'forms and returns filed and other records maintained by the Company '
        'and also the information provided by the Company, its officers, '
        'agents and authorized representatives during the conduct of '
        'secretarial audit, I hereby report that in my opinion, the Company '
        'has, during the audit period, complied with the statutory provisions '
        'listed hereunder and also that the Company has proper '
        'Board-processes and compliance-mechanism in place to the extent, '
        'in the manner and subject to the reporting made hereinafter.',
    'I have examined the books, papers, minute books, forms and returns '
        'filed and other records maintained by the Company for the financial '
        'year ended on 31st March $fy according to the provisions of the '
        'Companies Act, 2013 and the Rules made thereunder.',
  ];
}
