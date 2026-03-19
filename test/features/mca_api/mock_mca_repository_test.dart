import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca_api/data/mock_mca_repository.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';

void main() {
  late MockMcaRepository repository;

  setUp(() {
    repository = const MockMcaRepository();
  });

  // -------------------------------------------------------------------------
  // lookupByCin
  // -------------------------------------------------------------------------
  group('MockMcaRepository.lookupByCin', () {
    test('returns McaCompanyLookup for a valid CIN', () async {
      final result = await repository.lookupByCin('L17110MH1973PLC019786');
      expect(result, isA<McaCompanyLookup>());
    });

    test('returned company has correct CIN', () async {
      const cin = 'L17110MH1973PLC019786';
      final result = await repository.lookupByCin(cin);
      expect(result.cin, cin);
    });

    test('returned company has non-empty name', () async {
      final result = await repository.lookupByCin('L17110MH1973PLC019786');
      expect(result.companyName, isNotEmpty);
    });

    test('returned company status is active for mock CIN', () async {
      final result = await repository.lookupByCin('L17110MH1973PLC019786');
      expect(result.status, McaCompanyStatus.active);
    });

    test('throws ArgumentError for CIN shorter than 21 chars', () async {
      expect(
        () => repository.lookupByCin('L17110MH1973PLC'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for CIN with invalid format', () async {
      expect(
        () => repository.lookupByCin('X17110MH1973PLC019786'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for empty CIN', () async {
      expect(() => repository.lookupByCin(''), throwsA(isA<ArgumentError>()));
    });

    test('works for unlisted company CIN starting with U', () async {
      final result = await repository.lookupByCin('U74999MH2018PTC123456');
      expect(result.cin, 'U74999MH2018PTC123456');
    });

    test('authorizedCapital is positive integer (paise)', () async {
      final result = await repository.lookupByCin('L17110MH1973PLC019786');
      expect(result.authorizedCapital, greaterThan(0));
    });

    test('paidUpCapital is positive integer (paise)', () async {
      final result = await repository.lookupByCin('L17110MH1973PLC019786');
      expect(result.paidUpCapital, greaterThan(0));
    });

    test('state field is non-empty', () async {
      final result = await repository.lookupByCin('L17110MH1973PLC019786');
      expect(result.state, isNotEmpty);
    });

    test('roc field is non-empty', () async {
      final result = await repository.lookupByCin('L17110MH1973PLC019786');
      expect(result.roc, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // searchByName
  // -------------------------------------------------------------------------
  group('MockMcaRepository.searchByName', () {
    test('returns McaCompanyLookup for a non-empty name', () async {
      final result = await repository.searchByName('Reliance');
      expect(result, isA<McaCompanyLookup>());
    });

    test('company name contains the search term (case-insensitive)', () async {
      final result = await repository.searchByName('reliance');
      expect(result.companyName.toLowerCase(), contains('reliance'));
    });

    test('throws ArgumentError for empty search term', () async {
      expect(() => repository.searchByName(''), throwsA(isA<ArgumentError>()));
    });
  });

  // -------------------------------------------------------------------------
  // lookupDirector
  // -------------------------------------------------------------------------
  group('MockMcaRepository.lookupDirector', () {
    test('returns McaDirectorLookup for a valid 8-digit DIN', () async {
      final result = await repository.lookupDirector('00001008');
      expect(result, isA<McaDirectorLookup>());
    });

    test('returned director has correct DIN', () async {
      const din = '00001008';
      final result = await repository.lookupDirector(din);
      expect(result.din, din);
    });

    test('returned director name is non-empty', () async {
      final result = await repository.lookupDirector('00001008');
      expect(result.directorName, isNotEmpty);
    });

    test('throws ArgumentError for DIN shorter than 8 digits', () async {
      expect(
        () => repository.lookupDirector('1234'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for non-numeric DIN', () async {
      expect(
        () => repository.lookupDirector('ABCD1234'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for empty DIN', () async {
      expect(
        () => repository.lookupDirector(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('isDisqualified is false for approved director', () async {
      final result = await repository.lookupDirector('00001008');
      expect(result.isDisqualified, isFalse);
    });

    test('associatedCompanies is a list', () async {
      final result = await repository.lookupDirector('00001008');
      expect(result.associatedCompanies, isA<List<String>>());
    });

    test('nationality is non-empty', () async {
      final result = await repository.lookupDirector('00001008');
      expect(result.nationality, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // getFormStatus
  // -------------------------------------------------------------------------
  group('MockMcaRepository.getFormStatus', () {
    test('returns McaEFormStatus for any SRN', () async {
      final result = await repository.getFormStatus('A12345678');
      expect(result, isA<McaEFormStatus>());
    });

    test('status is approved for any SRN', () async {
      final result = await repository.getFormStatus('A12345678');
      expect(result.status, McaEFormStatusValue.approved);
    });

    test('returned SRN matches input', () async {
      const srn = 'A99887766';
      final result = await repository.getFormStatus(srn);
      expect(result.srn, srn);
    });

    test('approvalDate is set for approved forms', () async {
      final result = await repository.getFormStatus('A12345678');
      expect(result.approvalDate, isNotNull);
    });
  });

  // -------------------------------------------------------------------------
  // prefillAndSubmitForm
  // -------------------------------------------------------------------------
  group('MockMcaRepository.prefillAndSubmitForm', () {
    test('returns McaEFormStatus with pending status', () async {
      final result = await repository.prefillAndSubmitForm(
        'L17110MH1973PLC019786',
        'MGT-7',
        {'cin': 'L17110MH1973PLC019786', 'financial_year': '2024'},
      );
      expect(result.status, McaEFormStatusValue.pending);
    });

    test('returned SRN starts with A', () async {
      final result = await repository.prefillAndSubmitForm(
        'L17110MH1973PLC019786',
        'MGT-7',
        {},
      );
      expect(result.srn, startsWith('A'));
    });

    test('returned SRN is 9 characters (A + 8 digits)', () async {
      final result = await repository.prefillAndSubmitForm(
        'L17110MH1973PLC019786',
        'MGT-7',
        {},
      );
      expect(result.srn.length, 9);
    });

    test('formType matches submitted form type', () async {
      final result = await repository.prefillAndSubmitForm(
        'L17110MH1973PLC019786',
        'AOC-4',
        {},
      );
      expect(result.formType, 'AOC-4');
    });

    test('cin matches submitted CIN', () async {
      const cin = 'L17110MH1973PLC019786';
      final result = await repository.prefillAndSubmitForm(cin, 'MGT-7', {});
      expect(result.cin, cin);
    });

    test('throws ArgumentError for invalid CIN', () async {
      expect(
        () => repository.prefillAndSubmitForm('INVALID', 'MGT-7', {}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // getFilingHistory
  // -------------------------------------------------------------------------
  group('MockMcaRepository.getFilingHistory', () {
    test('returns McaFilingHistory for a valid CIN', () async {
      final result = await repository.getFilingHistory('L17110MH1973PLC019786');
      expect(result, isA<McaFilingHistory>());
    });

    test('returned filing history has correct CIN', () async {
      const cin = 'L17110MH1973PLC019786';
      final result = await repository.getFilingHistory(cin);
      expect(result.cin, cin);
    });

    test('filings list is not empty for mock CIN', () async {
      final result = await repository.getFilingHistory('L17110MH1973PLC019786');
      expect(result.filings, isNotEmpty);
    });

    test('lastFiledDate is not null when filings exist', () async {
      final result = await repository.getFilingHistory('L17110MH1973PLC019786');
      expect(result.lastFiledDate, isNotNull);
    });

    test('throws ArgumentError for invalid CIN', () async {
      expect(
        () => repository.getFilingHistory('INVALID'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
