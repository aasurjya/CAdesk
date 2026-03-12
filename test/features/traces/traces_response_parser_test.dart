import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/traces/domain/services/traces_response_parser.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';
import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';

void main() {
  const parser = TracesResponseParser();

  group('TracesResponseParser.parsePanVerificationResponse', () {
    test('parses a valid active PAN (status E)', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ABCDE1234F',
          'name': 'John Doe',
          'aadhaarLinked': true,
          'status': 'E',
        },
      };
      final result = parser.parsePanVerificationResponse(json);
      expect(result.pan, 'ABCDE1234F');
      expect(result.name, 'John Doe');
      expect(result.aadhaarLinked, isTrue);
      expect(result.status, PanStatus.valid);
    });

    test('parses invalid PAN (status I)', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ZZZZZ9999Z',
          'name': '',
          'aadhaarLinked': false,
          'status': 'I',
        },
      };
      final result = parser.parsePanVerificationResponse(json);
      expect(result.status, PanStatus.invalid);
    });

    test('parses deleted PAN (status X)', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ABCDE1234F',
          'name': 'Old Name',
          'aadhaarLinked': false,
          'status': 'X',
        },
      };
      final result = parser.parsePanVerificationResponse(json);
      expect(result.status, PanStatus.deleted);
    });

    test('parses aadhaar not linked (status A) as inactive', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ABCDE1234F',
          'name': 'Some Name',
          'aadhaarLinked': false,
          'status': 'A',
        },
      };
      final result = parser.parsePanVerificationResponse(json);
      expect(result.status, PanStatus.inactive);
    });

    test('verifiedAt is set to a recent time', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ABCDE1234F',
          'name': 'John',
          'aadhaarLinked': true,
          'status': 'E',
        },
      };
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final result = parser.parsePanVerificationResponse(json);
      expect(result.verifiedAt.isAfter(before), isTrue);
    });

    test('parses optional dateOfBirth field when present', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ABCDE1234F',
          'name': 'John',
          'aadhaarLinked': true,
          'status': 'E',
          'dateOfBirth': '01/01/1985',
        },
      };
      final result = parser.parsePanVerificationResponse(json);
      expect(result.dateOfBirth, '01/01/1985');
    });

    test('dateOfBirth is null when absent', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ABCDE1234F',
          'name': 'John',
          'aadhaarLinked': true,
          'status': 'E',
        },
      };
      final result = parser.parsePanVerificationResponse(json);
      expect(result.dateOfBirth, isNull);
    });

    test('throws ArgumentError for unknown status code', () {
      final json = {
        'status': '1',
        'response': {
          'pan': 'ABCDE1234F',
          'name': 'John',
          'aadhaarLinked': true,
          'status': 'Z',
        },
      };
      expect(
        () => parser.parsePanVerificationResponse(json),
        throwsArgumentError,
      );
    });
  });

  group('TracesResponseParser.parseChallanStatusResponse', () {
    test('parses fully-consumed matched challan (bookingStatus F)', () {
      final json = {
        'status': '1',
        'response': {
          'bsrCode': '0001234',
          'date': '01/04/2024',
          'serial': '00001',
          'tan': 'MUMA12345B',
          'section': '192',
          'amount': 50000,
          'consumed': 50000,
          'balance': 0,
          'bookingStatus': 'F',
        },
      };
      final result = parser.parseChallanStatusResponse(json);
      expect(result.bsrCode, '0001234');
      expect(result.challanSerial, '00001');
      expect(result.tan, 'MUMA12345B');
      expect(result.section, '192');
      expect(result.depositedAmount, 50000);
      expect(result.consumedAmount, 50000);
      expect(result.balanceAmount, 0);
      expect(result.status, ChallanBookingStatus.matched);
    });

    test('parses unmatched challan (bookingStatus U)', () {
      final json = {
        'status': '1',
        'response': {
          'bsrCode': '0001234',
          'date': '01/04/2024',
          'serial': '00002',
          'tan': 'MUMA12345B',
          'section': '194C',
          'amount': 25000,
          'consumed': 0,
          'balance': 25000,
          'bookingStatus': 'U',
        },
      };
      final result = parser.parseChallanStatusResponse(json);
      expect(result.status, ChallanBookingStatus.unmatched);
    });

    test('parses booking confirmed challan (bookingStatus B)', () {
      final json = {
        'status': '1',
        'response': {
          'bsrCode': '0001234',
          'date': '15/06/2024',
          'serial': '00003',
          'tan': 'DELA99999Z',
          'section': '194J',
          'amount': 100000,
          'consumed': 80000,
          'balance': 20000,
          'bookingStatus': 'B',
        },
      };
      final result = parser.parseChallanStatusResponse(json);
      expect(result.status, ChallanBookingStatus.bookingConfirmed);
      expect(result.balanceAmount, 20000);
    });

    test('parses over-booked challan (bookingStatus O)', () {
      final json = {
        'status': '1',
        'response': {
          'bsrCode': '1112223',
          'date': '10/09/2024',
          'serial': '00010',
          'tan': 'CHNA00001A',
          'section': '194A',
          'amount': 5000,
          'consumed': 7000,
          'balance': -2000,
          'bookingStatus': 'O',
        },
      };
      final result = parser.parseChallanStatusResponse(json);
      expect(result.status, ChallanBookingStatus.overBooked);
    });

    test('challanDate is parsed correctly from dd/MM/yyyy format', () {
      final json = {
        'status': '1',
        'response': {
          'bsrCode': '0001234',
          'date': '15/08/2024',
          'serial': '00001',
          'tan': 'MUMA12345B',
          'section': '192',
          'amount': 10000,
          'consumed': 10000,
          'balance': 0,
          'bookingStatus': 'F',
        },
      };
      final result = parser.parseChallanStatusResponse(json);
      expect(result.challanDate.year, 2024);
      expect(result.challanDate.month, 8);
      expect(result.challanDate.day, 15);
    });

    test('throws ArgumentError for unknown bookingStatus', () {
      final json = {
        'status': '1',
        'response': {
          'bsrCode': '0001234',
          'date': '01/04/2024',
          'serial': '00001',
          'tan': 'MUMA12345B',
          'section': '192',
          'amount': 10000,
          'consumed': 10000,
          'balance': 0,
          'bookingStatus': 'Z',
        },
      };
      expect(
        () => parser.parseChallanStatusResponse(json),
        throwsArgumentError,
      );
    });
  });

  group('TracesResponseParser.parseForm16StatusResponse', () {
    test('parses available form 16 request (status A)', () {
      final json = {
        'status': '1',
        'response': {
          'requestId': 'REQ001',
          'tan': 'MUMA12345B',
          'pan': 'ABCDE1234F',
          'financialYear': 2024,
          'requestType': 'form16',
          'status': 'A',
          'downloadUrl': 'https://traces.gov.in/download/REQ001',
        },
      };
      final result = parser.parseForm16StatusResponse(json);
      expect(result.requestId, 'REQ001');
      expect(result.status, Form16RequestStatus.available);
      expect(result.downloadUrl, 'https://traces.gov.in/download/REQ001');
    });

    test('parses processing form 16 request (status P)', () {
      final json = {
        'status': '1',
        'response': {
          'requestId': 'REQ002',
          'tan': 'MUMA12345B',
          'pan': 'ABCDE1234F',
          'financialYear': 2024,
          'requestType': 'form16a',
          'status': 'P',
        },
      };
      final result = parser.parseForm16StatusResponse(json);
      expect(result.status, Form16RequestStatus.processing);
      expect(result.downloadUrl, isNull);
    });

    test('parses failed form 16 request (status F)', () {
      final json = {
        'status': '1',
        'response': {
          'requestId': 'REQ003',
          'tan': 'MUMA12345B',
          'pan': null,
          'financialYear': 2023,
          'requestType': 'justificationReport',
          'status': 'F',
        },
      };
      final result = parser.parseForm16StatusResponse(json);
      expect(result.status, Form16RequestStatus.failed);
      expect(result.pan, isNull);
    });

    test('parses form16b requestType correctly', () {
      final json = {
        'status': '1',
        'response': {
          'requestId': 'REQ004',
          'tan': 'MUMA12345B',
          'pan': 'ABCDE1234F',
          'financialYear': 2024,
          'requestType': 'form16b',
          'status': 'A',
          'downloadUrl': 'https://traces.gov.in/download/REQ004',
        },
      };
      final result = parser.parseForm16StatusResponse(json);
      expect(result.requestType, Form16RequestType.form16b);
    });

    test('throws ArgumentError for unknown request status', () {
      final json = {
        'status': '1',
        'response': {
          'requestId': 'REQ005',
          'tan': 'MUMA12345B',
          'pan': 'ABCDE1234F',
          'financialYear': 2024,
          'requestType': 'form16',
          'status': 'Z',
        },
      };
      expect(
        () => parser.parseForm16StatusResponse(json),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for unknown requestType', () {
      final json = {
        'status': '1',
        'response': {
          'requestId': 'REQ006',
          'tan': 'MUMA12345B',
          'pan': 'ABCDE1234F',
          'financialYear': 2024,
          'requestType': 'unknownType',
          'status': 'A',
          'downloadUrl': 'https://traces.gov.in/download/REQ006',
        },
      };
      expect(
        () => parser.parseForm16StatusResponse(json),
        throwsArgumentError,
      );
    });
  });

  group('TracesResponseParser.parseJustificationReport', () {
    test('parses empty justification report', () {
      final json = {
        'status': '1',
        'response': {
          'tan': 'MUMA12345B',
          'financialYear': 2024,
          'quarter': 1,
          'shortDeductions': <Map<String, dynamic>>[],
          'lateDeductions': <Map<String, dynamic>>[],
          'totalShortfall': 0,
          'totalInterestDemand': 0,
        },
      };
      final result = parser.parseJustificationReport(json);
      expect(result.tan, 'MUMA12345B');
      expect(result.financialYear, 2024);
      expect(result.quarter, TdsQuarter.q1);
      expect(result.shortDeductions, isEmpty);
      expect(result.lateDeductions, isEmpty);
      expect(result.totalShortfall, 0);
      expect(result.totalInterestDemand, 0);
    });

    test('parses report with short deductions', () {
      final json = {
        'status': '1',
        'response': {
          'tan': 'MUMA12345B',
          'financialYear': 2024,
          'quarter': 2,
          'shortDeductions': [
            {
              'pan': 'ABCDE1234F',
              'section': '192',
              'amountPaid': 100000,
              'tdsDeducted': 5000,
              'tdsRequired': 10000,
              'shortfall': 5000,
            }
          ],
          'lateDeductions': <Map<String, dynamic>>[],
          'totalShortfall': 5000,
          'totalInterestDemand': 300,
        },
      };
      final result = parser.parseJustificationReport(json);
      expect(result.shortDeductions.length, 1);
      expect(result.shortDeductions.first.pan, 'ABCDE1234F');
      expect(result.shortDeductions.first.shortfall, 5000);
      expect(result.totalShortfall, 5000);
      expect(result.totalInterestDemand, 300);
    });

    test('parses report with late deductions', () {
      final json = {
        'status': '1',
        'response': {
          'tan': 'MUMA12345B',
          'financialYear': 2024,
          'quarter': 3,
          'shortDeductions': <Map<String, dynamic>>[],
          'lateDeductions': [
            {
              'pan': 'PQRST5678A',
              'section': '194C',
              'dueDate': '07/11/2024',
              'depositedDate': '15/11/2024',
              'daysLate': 8,
              'interest': 200,
            }
          ],
          'totalShortfall': 0,
          'totalInterestDemand': 200,
        },
      };
      final result = parser.parseJustificationReport(json);
      expect(result.lateDeductions.length, 1);
      expect(result.lateDeductions.first.pan, 'PQRST5678A');
      expect(result.lateDeductions.first.daysLate, 8);
      expect(result.quarter, TdsQuarter.q3);
    });

    test('parses all four quarters correctly', () {
      for (var q = 1; q <= 4; q++) {
        final json = {
          'status': '1',
          'response': {
            'tan': 'MUMA12345B',
            'financialYear': 2024,
            'quarter': q,
            'shortDeductions': <Map<String, dynamic>>[],
            'lateDeductions': <Map<String, dynamic>>[],
            'totalShortfall': 0,
            'totalInterestDemand': 0,
          },
        };
        final result = parser.parseJustificationReport(json);
        expect(result.quarter.index + 1, q);
      }
    });
  });
}
