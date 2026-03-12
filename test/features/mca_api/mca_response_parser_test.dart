import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';
import 'package:ca_app/features/mca_api/domain/services/mca_response_parser.dart';

void main() {
  final parser = const McaResponseParser();

  // -------------------------------------------------------------------------
  // validateCin
  // -------------------------------------------------------------------------
  group('McaResponseParser.validateCin', () {
    test('valid listed company CIN returns true', () {
      expect(parser.validateCin('L17110MH1973PLC019786'), isTrue);
    });

    test('valid unlisted company CIN returns true', () {
      expect(parser.validateCin('U74999MH2018PTC123456'), isTrue);
    });

    test('CIN with wrong first char returns false', () {
      expect(parser.validateCin('X17110MH1973PLC019786'), isFalse);
    });

    test('CIN shorter than 21 chars returns false', () {
      expect(parser.validateCin('L17110MH1973PLC01978'), isFalse);
    });

    test('CIN longer than 21 chars returns false', () {
      expect(parser.validateCin('L17110MH1973PLC0197860'), isFalse);
    });

    test('empty string returns false', () {
      expect(parser.validateCin(''), isFalse);
    });

    test('lowercase letters in state code returns false', () {
      expect(parser.validateCin('L17110mh1973PLC019786'), isFalse);
    });

    test('non-numeric industry code returns false', () {
      expect(parser.validateCin('LXXXXXMH1973PLC019786'), isFalse);
    });

    test('non-alphabetic company type returns false', () {
      expect(parser.validateCin('L17110MH1973123019786'), isFalse);
    });

    test('non-numeric sequence number returns false', () {
      expect(parser.validateCin('L17110MH1973PLCABCDEF'), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // validateDin
  // -------------------------------------------------------------------------
  group('McaResponseParser.validateDin', () {
    test('valid 8-digit numeric DIN returns true', () {
      expect(parser.validateDin('00001008'), isTrue);
    });

    test('all zeros DIN returns true', () {
      expect(parser.validateDin('00000000'), isTrue);
    });

    test('DIN shorter than 8 digits returns false', () {
      expect(parser.validateDin('1234567'), isFalse);
    });

    test('DIN longer than 8 digits returns false', () {
      expect(parser.validateDin('123456789'), isFalse);
    });

    test('DIN with letters returns false', () {
      expect(parser.validateDin('ABCD1234'), isFalse);
    });

    test('empty DIN returns false', () {
      expect(parser.validateDin(''), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // parseCompanyLookup
  // -------------------------------------------------------------------------
  group('McaResponseParser.parseCompanyLookup', () {
    final validJson = {
      'status': '1',
      'data': {
        'cin': 'L17110MH1973PLC019786',
        'company_name': 'RELIANCE INDUSTRIES LIMITED',
        'roc_code': 'RoC-Mumbai',
        'registration_number': '019786',
        'company_status': 'Active',
        'date_of_incorporation': '08/05/1973',
        'authorized_capital': 1000000000,
        'paid_up_capital': 634900000,
        'registered_office_address': 'Maker Chambers IV, Mumbai',
        'state': 'MH',
        'company_category': 'Company limited by Shares',
        'company_sub_category': 'Indian Non-Government Company',
      },
    };

    test('parses CIN correctly', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.cin, 'L17110MH1973PLC019786');
    });

    test('parses company name correctly', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.companyName, 'RELIANCE INDUSTRIES LIMITED');
    });

    test('parses roc correctly', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.roc, 'RoC-Mumbai');
    });

    test('parses active status correctly', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.status, McaCompanyStatus.active);
    });

    test('parses date_of_incorporation in DD/MM/YYYY format', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.dateOfIncorporation, DateTime(1973, 5, 8));
    });

    test('parses authorized_capital correctly', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.authorizedCapital, 1000000000);
    });

    test('parses paid_up_capital correctly', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.paidUpCapital, 634900000);
    });

    test('parses state correctly', () {
      final result = parser.parseCompanyLookup(validJson);
      expect(result.state, 'MH');
    });

    test('parses dormant status correctly', () {
      final dormantJson = Map<String, dynamic>.from(validJson);
      (dormantJson['data'] as Map<String, dynamic>)['company_status'] =
          'Dormant';
      final result = parser.parseCompanyLookup(dormantJson);
      expect(result.status, McaCompanyStatus.dormant);
    });

    test('parses struck off status correctly', () {
      final struckJson = Map<String, dynamic>.from(validJson);
      (struckJson['data'] as Map<String, dynamic>)['company_status'] =
          'Strike Off';
      final result = parser.parseCompanyLookup(struckJson);
      expect(result.status, McaCompanyStatus.strikedOff);
    });

    test('parses under liquidation status correctly', () {
      final liqJson = Map<String, dynamic>.from(validJson);
      (liqJson['data'] as Map<String, dynamic>)['company_status'] =
          'Under Liquidation';
      final result = parser.parseCompanyLookup(liqJson);
      expect(result.status, McaCompanyStatus.underLiquidation);
    });

    test('parses amalgamated status correctly', () {
      final amalgJson = Map<String, dynamic>.from(validJson);
      (amalgJson['data'] as Map<String, dynamic>)['company_status'] =
          'Amalgamated';
      final result = parser.parseCompanyLookup(amalgJson);
      expect(result.status, McaCompanyStatus.amalgamated);
    });

    test('throws FormatException for missing data key', () {
      expect(
        () => parser.parseCompanyLookup({'status': '1'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for missing cin in data', () {
      final badJson = {
        'status': '1',
        'data': {
          'company_name': 'Test',
          'company_status': 'Active',
          'date_of_incorporation': '01/01/2020',
          'authorized_capital': 100000,
          'paid_up_capital': 100000,
          'roc_code': 'RoC-Mumbai',
          'state': 'MH',
          'registered_office_address': '123 Test',
          'company_category': 'Test',
          'company_sub_category': 'Test',
        },
      };
      expect(
        () => parser.parseCompanyLookup(badJson),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // parseDirectorLookup
  // -------------------------------------------------------------------------
  group('McaResponseParser.parseDirectorLookup', () {
    final validJson = {
      'status': '1',
      'data': {
        'din': '00001008',
        'name': 'Mukesh Dhirubhai Ambani',
        'status': 'Approved',
        'number_of_companies': 5,
        'nationality': 'Indian',
        'date_of_birth': '19/04/1957',
        'father_name': 'Dhirubhai Ambani',
        'associated_companies': ['L17110MH1973PLC019786'],
      },
    };

    test('parses DIN correctly', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.din, '00001008');
    });

    test('parses director name correctly', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.directorName, 'Mukesh Dhirubhai Ambani');
    });

    test('parses approved status correctly', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.status, McaDirectorStatus.approved);
    });

    test('isDisqualified is false for approved status', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.isDisqualified, isFalse);
    });

    test('parses disqualified status correctly', () {
      final disqJson = Map<String, dynamic>.from(validJson);
      (disqJson['data'] as Map<String, dynamic>)['status'] = 'Disqualified';
      final result = parser.parseDirectorLookup(disqJson);
      expect(result.status, McaDirectorStatus.disqualified);
      expect(result.isDisqualified, isTrue);
    });

    test('parses deactivated status correctly', () {
      final deactJson = Map<String, dynamic>.from(validJson);
      (deactJson['data'] as Map<String, dynamic>)['status'] = 'Deactivated';
      final result = parser.parseDirectorLookup(deactJson);
      expect(result.status, McaDirectorStatus.deactivated);
    });

    test('parses date_of_birth in DD/MM/YYYY format', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.dateOfBirth, DateTime(1957, 4, 19));
    });

    test('parses father_name correctly', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.fatherName, 'Dhirubhai Ambani');
    });

    test('parses nationality correctly', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.nationality, 'Indian');
    });

    test('parses associated_companies correctly', () {
      final result = parser.parseDirectorLookup(validJson);
      expect(result.associatedCompanies, ['L17110MH1973PLC019786']);
    });

    test('handles null date_of_birth gracefully', () {
      final noDobJson = Map<String, dynamic>.from(validJson);
      (noDobJson['data'] as Map<String, dynamic>).remove('date_of_birth');
      final result = parser.parseDirectorLookup(noDobJson);
      expect(result.dateOfBirth, isNull);
    });

    test('handles null father_name gracefully', () {
      final noFatherJson = Map<String, dynamic>.from(validJson);
      (noFatherJson['data'] as Map<String, dynamic>).remove('father_name');
      final result = parser.parseDirectorLookup(noFatherJson);
      expect(result.fatherName, isNull);
    });

    test('throws FormatException for missing data key', () {
      expect(
        () => parser.parseDirectorLookup({'status': '1'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // parseFormStatus
  // -------------------------------------------------------------------------
  group('McaResponseParser.parseFormStatus', () {
    final validJson = {
      'status': '1',
      'data': {
        'srn': 'A12345678',
        'form_type': 'MGT-7',
        'cin': 'L17110MH1973PLC019786',
        'filed_at': '2024-09-15T10:30:00',
        'status': 'Approved',
        'approval_date': '2024-10-01T09:00:00',
        'remarks': 'All documents verified',
      },
    };

    test('parses SRN correctly', () {
      final result = parser.parseFormStatus(validJson);
      expect(result.srn, 'A12345678');
    });

    test('parses form type correctly', () {
      final result = parser.parseFormStatus(validJson);
      expect(result.formType, 'MGT-7');
    });

    test('parses CIN correctly', () {
      final result = parser.parseFormStatus(validJson);
      expect(result.cin, 'L17110MH1973PLC019786');
    });

    test('parses approved status correctly', () {
      final result = parser.parseFormStatus(validJson);
      expect(result.status, McaEFormStatusValue.approved);
    });

    test('parses pending status correctly', () {
      final pendingJson = Map<String, dynamic>.from(validJson);
      (pendingJson['data'] as Map<String, dynamic>)['status'] = 'Pending';
      final result = parser.parseFormStatus(pendingJson);
      expect(result.status, McaEFormStatusValue.pending);
    });

    test('parses under processing status correctly', () {
      final procJson = Map<String, dynamic>.from(validJson);
      (procJson['data'] as Map<String, dynamic>)['status'] =
          'Under Processing';
      final result = parser.parseFormStatus(procJson);
      expect(result.status, McaEFormStatusValue.underProcessing);
    });

    test('parses rejected status correctly', () {
      final rejJson = Map<String, dynamic>.from(validJson);
      (rejJson['data'] as Map<String, dynamic>)['status'] = 'Rejected';
      final result = parser.parseFormStatus(rejJson);
      expect(result.status, McaEFormStatusValue.rejected);
    });

    test('parses resubmission required status correctly', () {
      final resubJson = Map<String, dynamic>.from(validJson);
      (resubJson['data'] as Map<String, dynamic>)['status'] =
          'Resubmission Required';
      final result = parser.parseFormStatus(resubJson);
      expect(result.status, McaEFormStatusValue.resubmissionRequired);
    });

    test('parses approval_date correctly', () {
      final result = parser.parseFormStatus(validJson);
      expect(result.approvalDate, isNotNull);
    });

    test('parses remarks correctly', () {
      final result = parser.parseFormStatus(validJson);
      expect(result.remarks, 'All documents verified');
    });

    test('handles null approval_date gracefully', () {
      final noApprovalJson = Map<String, dynamic>.from(validJson);
      (noApprovalJson['data'] as Map<String, dynamic>).remove('approval_date');
      final result = parser.parseFormStatus(noApprovalJson);
      expect(result.approvalDate, isNull);
    });

    test('throws FormatException for missing data key', () {
      expect(
        () => parser.parseFormStatus({'status': '1'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // parseFilingHistory
  // -------------------------------------------------------------------------
  group('McaResponseParser.parseFilingHistory', () {
    final validJson = {
      'status': '1',
      'data': {
        'cin': 'L17110MH1973PLC019786',
        'filings': [
          {
            'srn': 'A11111111',
            'form_type': 'MGT-7',
            'filed_at': '2023-11-15T12:00:00',
            'status': 'Approved',
            'document_description': 'Annual Return FY 2022-23',
            'fees_paid': 30000,
          },
          {
            'srn': 'A22222222',
            'form_type': 'AOC-4',
            'filed_at': '2023-10-20T09:00:00',
            'status': 'Approved',
            'document_description': 'Financial Statements FY 2022-23',
            'fees_paid': 20000,
          },
        ],
      },
    };

    test('parses CIN correctly', () {
      final result = parser.parseFilingHistory(validJson);
      expect(result.cin, 'L17110MH1973PLC019786');
    });

    test('parses two filings correctly', () {
      final result = parser.parseFilingHistory(validJson);
      expect(result.filings.length, 2);
    });

    test('first filing has correct SRN', () {
      final result = parser.parseFilingHistory(validJson);
      expect(result.filings.first.srn, 'A11111111');
    });

    test('first filing has correct form type', () {
      final result = parser.parseFilingHistory(validJson);
      expect(result.filings.first.formType, 'MGT-7');
    });

    test('first filing has correct fees paid', () {
      final result = parser.parseFilingHistory(validJson);
      expect(result.filings.first.feesPaid, 30000);
    });

    test('lastFiledDate is the most recent filing date', () {
      final result = parser.parseFilingHistory(validJson);
      expect(result.lastFiledDate, isNotNull);
    });

    test('handles empty filings list', () {
      final emptyJson = {
        'status': '1',
        'data': {
          'cin': 'L17110MH1973PLC019786',
          'filings': <Map<String, dynamic>>[],
        },
      };
      final result = parser.parseFilingHistory(emptyJson);
      expect(result.filings, isEmpty);
      expect(result.lastFiledDate, isNull);
    });

    test('throws FormatException for missing data key', () {
      expect(
        () => parser.parseFilingHistory({'status': '1'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
