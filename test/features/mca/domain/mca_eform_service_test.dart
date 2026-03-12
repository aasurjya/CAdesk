import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca/domain/models/aoc4_financial_statement.dart';
import 'package:ca_app/features/mca/domain/models/director_detail.dart';
import 'package:ca_app/features/mca/domain/models/mca_eform.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';
import 'package:ca_app/features/mca/domain/services/mca_eform_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Mgt7Return _makeMgt7({String cin = 'U74999MH2018PTC123456'}) => Mgt7Return(
  cin: cin,
  companyName: 'Test Pvt Ltd',
  registeredOffice: '123 MG Road',
  financialYear: 2024,
  agmDate: DateTime(2024, 9, 15),
  shareholdingPattern: const [],
  directors: [
    DirectorDetail(
      din: '12345678',
      name: 'Rajesh Kumar',
      designation: 'Director',
      dateOfAppointment: DateTime(2018, 1, 1),
      shareholding: 50.0,
    ),
  ],
  keyManagerialPersonnel: const [],
  meetings: const [],
  penalties: const [],
);

Aoc4FinancialStatement _makeAoc4({String cin = 'U74999MH2018PTC123456'}) =>
    Aoc4FinancialStatement(
      cin: cin,
      financialYear: 2024,
      auditReportDate: DateTime(2024, 8, 20),
      agmDate: DateTime(2024, 9, 15),
      balanceSheetTotal: 5000000,
      profitAfterTax: 200000,
      dividendPaid: 0,
      auditQualifications: const [],
    );

McaEForm _makeDraftForm({
  EFormType formType = EFormType.mgt7,
  EFormStatus status = EFormStatus.draft,
}) => McaEForm(
  id: 'form-001',
  formType: formType,
  status: status,
  xmlPayload: '',
  attachments: const [],
  createdAt: DateTime(2024, 9, 1),
);

void main() {
  // -------------------------------------------------------------------------
  // generateMgt7Xml
  // -------------------------------------------------------------------------
  group('McaEFormService.generateMgt7Xml', () {
    test('returns non-empty string', () {
      final form = _makeMgt7();
      final xml = McaEFormService.instance.generateMgt7Xml(form);
      expect(xml, isNotEmpty);
    });

    test('XML contains root element', () {
      final form = _makeMgt7();
      final xml = McaEFormService.instance.generateMgt7Xml(form);
      expect(xml, contains('<root>'));
      expect(xml, contains('</root>'));
    });

    test('XML contains CIN', () {
      final form = _makeMgt7();
      final xml = McaEFormService.instance.generateMgt7Xml(form);
      expect(xml, contains('U74999MH2018PTC123456'));
    });

    test('XML contains company name', () {
      final form = _makeMgt7();
      final xml = McaEFormService.instance.generateMgt7Xml(form);
      expect(xml, contains('Test Pvt Ltd'));
    });

    test('XML contains formType MGT-7', () {
      final form = _makeMgt7();
      final xml = McaEFormService.instance.generateMgt7Xml(form);
      expect(xml, contains('MGT-7'));
    });

    test('XML contains director DIN', () {
      final form = _makeMgt7();
      final xml = McaEFormService.instance.generateMgt7Xml(form);
      expect(xml, contains('12345678'));
    });

    test('XML is well-formed (balanced tags)', () {
      final form = _makeMgt7();
      final xml = McaEFormService.instance.generateMgt7Xml(form);
      // Simple check: number of < equals number of >
      expect(xml.split('<').length - 1, equals(xml.split('>').length - 1));
    });
  });

  // -------------------------------------------------------------------------
  // generateAoc4Xml
  // -------------------------------------------------------------------------
  group('McaEFormService.generateAoc4Xml', () {
    test('returns non-empty string', () {
      final form = _makeAoc4();
      final xml = McaEFormService.instance.generateAoc4Xml(form);
      expect(xml, isNotEmpty);
    });

    test('XML contains root element', () {
      final form = _makeAoc4();
      final xml = McaEFormService.instance.generateAoc4Xml(form);
      expect(xml, contains('<root>'));
      expect(xml, contains('</root>'));
    });

    test('XML contains CIN', () {
      final form = _makeAoc4();
      final xml = McaEFormService.instance.generateAoc4Xml(form);
      expect(xml, contains('U74999MH2018PTC123456'));
    });

    test('XML contains formType AOC-4', () {
      final form = _makeAoc4();
      final xml = McaEFormService.instance.generateAoc4Xml(form);
      expect(xml, contains('AOC-4'));
    });

    test('XML contains balance sheet total', () {
      final form = _makeAoc4(cin: 'U74999MH2018PTC123456');
      final xml = McaEFormService.instance.generateAoc4Xml(form);
      expect(xml, contains('5000000'));
    });
  });

  // -------------------------------------------------------------------------
  // computePenalty
  // -------------------------------------------------------------------------
  group('McaEFormService.computePenalty', () {
    test('no penalty when filed on due date', () {
      final form = _makeDraftForm();
      // MGT-7 FY 2024: deadline = November 29, 2024
      final filedDate = DateTime(2024, 11, 29);
      final penalty = McaEFormService.instance.computePenalty(form, filedDate);
      expect(penalty, 0);
    });

    test('100 paise per day penalty for 1 day late', () {
      // MGT-7 FY 2024: deadline = November 29 → filed Nov 30 = 1 day late
      final form = _makeDraftForm(formType: EFormType.mgt7);
      final filedDate = DateTime(2024, 11, 30);
      final penalty = McaEFormService.instance.computePenalty(form, filedDate);
      // 1 day × ₹100 = 100 rupees = 10000 paise
      expect(penalty, 10000);
    });

    test('10 days late → 10 × ₹100 = ₹1000 = 100000 paise', () {
      final form = _makeDraftForm(formType: EFormType.mgt7);
      final filedDate = DateTime(2024, 12, 9); // 10 days after Nov 29
      final penalty = McaEFormService.instance.computePenalty(form, filedDate);
      expect(penalty, 100000);
    });

    test('no penalty when status is already approved', () {
      final form = _makeDraftForm(status: EFormStatus.approved);
      final filedDate = DateTime(2025, 3, 1); // well past due date
      final penalty = McaEFormService.instance.computePenalty(form, filedDate);
      expect(penalty, 0);
    });

    test('AOC-4 penalty — 100 per day same as default', () {
      final form = _makeDraftForm(formType: EFormType.aoc4);
      // AOC-4 FY 2024: deadline = October 29 → filed Nov 28 = 30 days late
      final filedDate = DateTime(2024, 11, 28);
      final penalty = McaEFormService.instance.computePenalty(form, filedDate);
      // 30 days × ₹100 = ₹3000 = 300000 paise
      expect(penalty, 300000);
    });
  });

  // -------------------------------------------------------------------------
  // getFilingDeadline
  // -------------------------------------------------------------------------
  group('McaEFormService.getFilingDeadline', () {
    test('MGT-7 deadline for FY 2024 is November 29, 2024', () {
      final deadline = McaEFormService.instance.getFilingDeadline(
        'MGT-7',
        2024,
      );
      expect(deadline, DateTime(2024, 11, 29));
    });

    test('AOC-4 deadline for FY 2024 is October 29, 2024', () {
      final deadline = McaEFormService.instance.getFilingDeadline(
        'AOC-4',
        2024,
      );
      expect(deadline, DateTime(2024, 10, 29));
    });

    test('DIR-3 KYC deadline for FY 2024 is September 30, 2024', () {
      final deadline = McaEFormService.instance.getFilingDeadline(
        'DIR-3 KYC',
        2024,
      );
      expect(deadline, DateTime(2024, 9, 30));
    });

    test('MGT-7 deadline for FY 2023 is November 29, 2023', () {
      final deadline = McaEFormService.instance.getFilingDeadline(
        'MGT-7',
        2023,
      );
      expect(deadline, DateTime(2023, 11, 29));
    });

    test('unknown form returns a far-future sentinel date', () {
      final deadline = McaEFormService.instance.getFilingDeadline(
        'UNKNOWN-99',
        2024,
      );
      expect(deadline.year, greaterThanOrEqualTo(2024));
    });
  });
}
