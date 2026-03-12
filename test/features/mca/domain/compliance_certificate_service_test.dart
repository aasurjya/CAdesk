import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca/domain/models/company.dart';
import 'package:ca_app/features/mca/domain/models/compliance_certificate.dart';
import 'package:ca_app/features/mca/domain/models/director_detail.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';
import 'package:ca_app/features/mca/domain/services/compliance_certificate_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Company _makeCompany() => Company(
  id: 'c1',
  cin: 'U74999MH2018PTC123456',
  companyName: 'Test Private Ltd',
  incorporationDate: DateTime(2018, 1, 1),
  category: CompanyCategory.privateLimited,
  paidUpCapital: 100000,
  authorisedCapital: 1000000,
  registeredAddress: '123 MG Road, Mumbai',
  rocJurisdiction: 'ROC Mumbai',
  directors: const [],
);

Mgt7Return _makeMgt7() => Mgt7Return(
  cin: 'U74999MH2018PTC123456',
  companyName: 'Test Private Ltd',
  registeredOffice: '123 MG Road, Mumbai',
  financialYear: 2024,
  agmDate: DateTime(2024, 9, 15),
  shareholdingPattern: const [],
  directors: [
    DirectorDetail(
      din: '12345678',
      name: 'Rajesh Kumar',
      designation: 'Director',
      dateOfAppointment: DateTime(2018, 1, 1),
      shareholding: 100.0,
    ),
  ],
  keyManagerialPersonnel: const [],
  meetings: const [],
  penalties: const [],
);

void main() {
  // -------------------------------------------------------------------------
  // generateMgt8
  // -------------------------------------------------------------------------
  group('ComplianceCertificateService.generateMgt8', () {
    test('returns ComplianceCertificate with certType MGT-8', () {
      final company = _makeCompany();
      final mgt7 = _makeMgt7();
      final cert = ComplianceCertificateService.instance.generateMgt8(
        mgt7,
        company,
      );
      expect(cert.certType, 'MGT-8');
    });

    test('certificate period matches financial year', () {
      final company = _makeCompany();
      final mgt7 = _makeMgt7();
      final cert = ComplianceCertificateService.instance.generateMgt8(
        mgt7,
        company,
      );
      // FY 2024 → period "2023-24"
      expect(cert.period, contains('2023'));
    });

    test('certifiedBy is non-empty', () {
      final company = _makeCompany();
      final mgt7 = _makeMgt7();
      final cert = ComplianceCertificateService.instance.generateMgt8(
        mgt7,
        company,
      );
      expect(cert.certifiedBy, isNotEmpty);
    });

    test('date is set on the certificate', () {
      final company = _makeCompany();
      final mgt7 = _makeMgt7();
      final cert = ComplianceCertificateService.instance.generateMgt8(
        mgt7,
        company,
      );
      expect(cert.date, isNotNull);
    });

    test('declarations list is non-empty', () {
      final company = _makeCompany();
      final mgt7 = _makeMgt7();
      final cert = ComplianceCertificateService.instance.generateMgt8(
        mgt7,
        company,
      );
      expect(cert.declarations, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // generateSecretarialAuditReport
  // -------------------------------------------------------------------------
  group('ComplianceCertificateService.generateSecretarialAuditReport', () {
    test('returns ComplianceCertificate with certType Secretarial Audit', () {
      final company = _makeCompany();
      final cert = ComplianceCertificateService.instance
          .generateSecretarialAuditReport(company, 2024);
      expect(cert.certType, contains('Secretarial Audit'));
    });

    test('period covers the given financial year', () {
      final company = _makeCompany();
      final cert = ComplianceCertificateService.instance
          .generateSecretarialAuditReport(company, 2024);
      // FY 2024 → period "2023-24"
      expect(cert.period, contains('2023'));
    });

    test('certifiedBy is non-empty', () {
      final company = _makeCompany();
      final cert = ComplianceCertificateService.instance
          .generateSecretarialAuditReport(company, 2024);
      expect(cert.certifiedBy, isNotEmpty);
    });

    test('declarations list is non-empty', () {
      final company = _makeCompany();
      final cert = ComplianceCertificateService.instance
          .generateSecretarialAuditReport(company, 2024);
      expect(cert.declarations, isNotEmpty);
    });

    test('different FY produces different period string', () {
      final company = _makeCompany();
      final cert2024 = ComplianceCertificateService.instance
          .generateSecretarialAuditReport(company, 2024);
      final cert2023 = ComplianceCertificateService.instance
          .generateSecretarialAuditReport(company, 2023);
      expect(cert2024.period, isNot(equals(cert2023.period)));
    });
  });

  // -------------------------------------------------------------------------
  // ComplianceCertificate model tests
  // -------------------------------------------------------------------------
  group('ComplianceCertificate model', () {
    test('copyWith preserves unchanged fields', () {
      final cert = ComplianceCertificate(
        certType: 'MGT-8',
        period: '2023-24',
        certifiedBy: 'CS Priya Sharma',
        din: 'CS001234',
        date: DateTime(2024, 10, 1),
        declarations: const ['Company has complied with all provisions'],
      );

      final updated = cert.copyWith(certifiedBy: 'CS Rohit Verma');
      expect(updated.certType, 'MGT-8');
      expect(updated.period, '2023-24');
      expect(updated.certifiedBy, 'CS Rohit Verma');
    });

    test('equality based on all fields', () {
      final date = DateTime(2024, 10, 1);
      final a = ComplianceCertificate(
        certType: 'MGT-8',
        period: '2023-24',
        certifiedBy: 'CS Priya Sharma',
        din: 'CS001234',
        date: date,
        declarations: const ['Declaration 1'],
      );
      final b = ComplianceCertificate(
        certType: 'MGT-8',
        period: '2023-24',
        certifiedBy: 'CS Priya Sharma',
        din: 'CS001234',
        date: date,
        declarations: const ['Declaration 1'],
      );
      expect(a, equals(b));
    });

    test('hashCode consistent with equality', () {
      final date = DateTime(2024, 10, 1);
      final a = ComplianceCertificate(
        certType: 'MGT-8',
        period: '2023-24',
        certifiedBy: 'CS Priya Sharma',
        din: 'CS001234',
        date: date,
        declarations: const ['Declaration 1'],
      );
      final b = ComplianceCertificate(
        certType: 'MGT-8',
        period: '2023-24',
        certifiedBy: 'CS Priya Sharma',
        din: 'CS001234',
        date: date,
        declarations: const ['Declaration 1'],
      );
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
